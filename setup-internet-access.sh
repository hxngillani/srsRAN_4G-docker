#!/bin/bash

echo "This script will set up internet access between the UE, eNB and EPC."
echo "This assumes you haven't changed any IPs for these services."
echo

read -s -p "Press ENTER to continue, or CTRL + C to exit"

echo
echo
echo "**** Checking connection between UE and eNB... ****"
echo

docker exec -i -t virtual-srsepc ping -c 4 172.16.0.2

echo
read -s -p "Press ENTER to continue, or CTRL + C to exit"
echo

echo "**** Current UE routing table ****"
echo
docker exec virtual-srsue ip route show

echo
read -s -p "Press ENTER to continue, or CTRL + C to exit"
echo

echo "**** UE currently connecting via virtualised Docker network. ****"
echo "**** Re-routing UE connection through the EPC... ****"
echo

# Configure network address translation (NAT) at the EPC
docker exec virtual-srsepc iptables -t nat -A POSTROUTING -s 172.16.0.0/24 -o eth0 -j MASQUERADE

# Set traffic from the UE to route via the EPC
docker exec virtual-srsue ip route replace default via 172.16.0.1

echo
echo "**** Updated UE routing table ****"
docker exec virtual-srsue ip route show

echo
echo "Everything looks good to go!"
echo

read -s -p "Press ENTER to continue."
echo
