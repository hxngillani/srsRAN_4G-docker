#!/bin/bash

echo "Welcome to the Ookla Speedtest and traceroute CLI setup script!"
echo "This script will install the Ookla Speedtest CLI and"
echo "traceroute on your virtual srsUE docker container."
echo

read -p "Do you want to install traceroute? (y/n): " install_traceroute

if [ "$install_traceroute" == "y" ]; then
echo "Installing traceroute..."
docker exec -it virtual-srsue bash -c 'apt update; apt-get install traceroute'
echo "Traceroute has been installed."
echo
fi

read -p "Do you want to install the Ookla Speedtest CLI? (y/n): " install_speedtest

if [ "$install_speedtest" == "y" ]; then
echo "Installing the Ookla Speedtest CLI..."
docker exec -it virtual-srsue bash -c 'curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash; apt-get install speedtest'
echo "The Ookla Speedtest CLI has been installed."
echo
fi

read -p "Do you want to test traceroute to www.unipi.it? (y/n): " test_traceroute

if [ "$test_traceroute" == "y" ]; then
echo "Testing traceroute to www.unipi.it..."
docker exec -it virtual-srsue bash -c 'timeout 5 traceroute -m 30 -w 1 www.unipi.it'
echo "Traceroute to www.unipi.it has been completed."
echo
fi

echo "Thank you for using the setup script. Have a nice day!"
