#!/usr/bin/env bash

docker-compose kill
docker-compose up -d || exit

printf "%s" "Waiting for UE to attach"
while ! docker exec -t -t virtual-srsepc timeout 0.2 ping -c 1 -n 172.16.0.2 &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "UE is attached"

printf "%s\n" "Configuring routing"
docker exec virtual-srsepc iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o eth0 -j MASQUERADE
docker exec virtual-srsue ip route replace default via 172.16.0.1

printf "%s\n" "Configured, test with: docker exec virtual-srsue ping example.com"
printf "%s\n" "The logs can be accessed and followed with: docker-compose logs -f"
