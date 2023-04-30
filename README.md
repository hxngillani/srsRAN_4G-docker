# srsran-docker-emulated

This is a minimal example of an end-to-end [srsRAN](https://github.com/srsran/srsRAN) LTE system running with Docker.
The core network, base station and user device all run in
separate containers. The air interface is emulated via [ZeroMQ](https://github.com/zeromq/libzmq).


## Script

To easily set this all up, use the provided shell script:

```bash
./start.sh
```

## Manual configuration

- Start the containers with the following command:

```bash
docker-compose up
```

- After a while you'll see the UE attach:
```bash
virtual-srsue | Network attach successful. IP: 172.16.0.2
virtual-srsenb | User 0x46 connected
```
- Now you can test the connection in a new terminal:
```bash
docker exec -i -t virtual-srsepc ping 172.16.0.2
PING 172.16.0.2 (172.16.0.2) 56(84) bytes of data.
64 bytes from 172.16.0.2: icmp_seq=1 ttl=64 time=25.3 ms
64 bytes from 172.16.0.2: icmp_seq=2 ttl=64 time=24.2 ms
```
**A note on configuration:** During build, the example config files are copied
into the workdir. These are the files you see used in the compose file with some
option overrides. If you want to play around with the config yourself, it is
much easier to place your custom files in this directory and `ADD` them in the
Dockerfile. You can find the exact versions in [srsepc], [srsenb] and [srsue].

[srsepc]: https://github.com/srsran/srsRAN/tree/5275f33360f1b3f1ee8d1c4d9ae951ac7c4ecd4e/srsepc
[srsenb]: https://github.com/srsran/srsRAN/tree/5275f33360f1b3f1ee8d1c4d9ae951ac7c4ecd4e/srsenb
[srsue]: https://github.com/srsran/srsRAN/tree/5275f33360f1b3f1ee8d1c4d9ae951ac7c4ecd4e/srsue

**Adding UEs:** The compose file contains an optional second UE. It uses the
second IMSI from the default user_db.csv (srsEPC). To add more UEs, add IMSIs to
the csv and tell the UEs to use them.

### Internet access for UEs

By default, containers are attached to a Docker network with a default
route. This means everyone has internet access through the virtualized Docker
network. It takes two extra steps to make UEs access the internet through the
EPC instead. First configure network address translation at the EPC

    docker exec virtual-srsepc iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o eth0 -j MASQUERADE

This will masquerade all forwarded traffic from UEs (matched by source IP
address) leaving the EPC's eth0 (Docker) interface.

Second, tell the UE to route traffic via the EPC by default

    docker exec virtual-srsue ip route replace default via 172.16.0.1

Now you have network access through the EPC

    docker exec virtual-srsue ping google.com

You can verify that this ping is using the LTE connection by checking whether
it has about 20 ms added latency due to uplink scheduling or by waiting until
the UE enters "RRC IDLE" state, in which your ping command will trigger a
random access and connection setup. The UE enters that state after one minute
of not having sent or received any data through the LTE connection, so make
sure no pings are running.

## Credits

* [srsRAN](https://github.com/srsran/srsRAN)
* [pgorczak](https://github.com/pgorczak): This container is a fork from https://github.com/pgorczak/srslte-docker-emulated
  - [jgiovatto](https://github.com/jgiovatto): Implemented shared memory interfaces in the previous version
  - [FabianEckermann](https://github.com/FabianEckermann): Integrating shared memory with docker IPC in the previous version
  
