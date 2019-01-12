#!/bin/bash
source $script_dir/server.config

function configure_network_interfaces ()
{
ifdown $primary_eth
mv /etc/network/interfaces /etc/network/interfaces.orig
chmod a-w /etc/network/interfaces.orig
cat > /etc/network/interfaces << EOM
# The loopback network interface
auto lo
iface lo inet loopback

# System network interface on $primary_eth
auto $primary_eth
iface $primary_eth inet static
       address $primary_eth_ip
       network $primary_eth_subnet
       netmask $primary_eth_netmask
       broadcast $primary_eth_broadcast
       gateway $primary_eth_gateway
       dns-nameservers $nameserver_1 $nameserver_2
EOM
ifup $primary_eth
}

function network_configuration_decision ()
{
	clear
	echo "*************************************************************************************************"
	echo "Configure Network Interface? (yes/no)"
	echo "*************************************************************************************************"
	read configure_network
	if [ "$configure_network" == "yes" ]; then
    configure_network_interfaces
	elif [ "$configure_network" == "no" ]; then
    clear
    echo "*************************************************************************************************"
    echo "*** IMPORTANT NOTIFICATION "
    echo "*** /etc/network/interfaces is not being configured, it will remain"
		echo "*************************************************************************************************"
	cat /etc/network/interfaces
    echo "*************************************************************************************************"
	else
		network_configuration_decision
	fi
}

network_configuration_decision
configure_network_interfaces
