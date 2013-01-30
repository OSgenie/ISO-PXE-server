#!/bin/bash
set_subnet=192.168.100
set_netmask=255.255.255.0
system_eth=eth0 
system_ip=3
gateway_ip=1
nameserver_ip=192.168.11.1 #full IP

function configure_network_interfaces ()
{
network_interface_specs=()
network_interface_specs=("${network_interface_specs[@]}"
"# The loopback network interface"
"auto lo"
"iface lo inet loopback"
""
"# System network interface on $system_eth"
"auto $system_eth"
"iface $system_eth inet static"
"       address $set_subnet.$system_ip"
"       network $set_subnet.0"
"       netmask $set_netmask"
"       broadcast $set_subnet.255"
"       gateway $set_subnet.$gateway_ip"
"       dns-nameservers=$nameserver_ip"
)

sudo service networking stop
if [ ! -f /etc/network/interfaces.orig ]; then
    sudo mv /etc/network/interfaces /etc/network/interfaces.orig
else
    sudo rm /etc/network/interfaces
fi 
sudo touch /etc/network/interfaces
for (( i=0;i<${#network_interface_specs[@]};i++)); do
    echo "${network_interface_specs[$i]}"  | sudo tee -a /etc/network/interfaces
done
sudo service networking restart
}

configure_network_interfaces
./install-APT-CACHER.sh
echo 'Acquire::http { Proxy "http://'$set_subnet'.'$system_ip':3142"; };' | sudo tee /etc/apt/apt.conf
sudo apt-get update
./install-NFS.sh
./install-BT.sh
./install-SQUID.sh