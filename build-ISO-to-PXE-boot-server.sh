#!/usr/bin/env bash
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $scriptdir/build.config

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

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

function build_PXE_server ()
{
	./$scriptdir/install-APT-CACHER.sh
	echo 'Acquire::http { Proxy "http:'$primary_eth_ip':3142"; };' | tee /etc/apt/apt.conf.d/01proxy
	apt-get update
	apt-get upgrade -y
	./install-BT.sh
	./install-NFS-and-WWW.sh
	./install-SQUID.sh
	./install-PXE.sh
}

function add_DHCP_server ()
{
	if [ "$install_dhcp" == "yes" ]; then
	    ./install-DHCP.sh
	elif [ "$install_dhcp" == "no" ]; then
    clear
    echo "*************************************************************************************************"
    echo "*** IMPORTANT NOTIFICATION "
    echo "DHCP services are not being installed on this server!"
    echo "You must add the following to the DNSMasq options of your router"
    echo "  dhcp-boot=pxelinux.0,pxeserver,$primary_eth_ip"
    echo "*************************************************************************************************"
	else
		DHCP_server_installation_decision
	fi
}

function DHCP_server_installation_decision ()
{
	clear
	echo "********** Notification **************************************************************************************"
	echo "PXE booting requires a DHCP server configured to deliver the pxelinux.0 file to booting clients"
	echo "This setup proceedure can install a DHCP server on this server configured for PXE booting"
	echo "To configure a DD-WRT router, add 'dhcp-boot=pxelinux.0,pxeserver,$primary_eth_ip' to the DNSMasq options"
	echo "Do you want to install DHCP service on this server (yes/no)?"
	echo "**************************************************************************************************************"
	read install_dhcp
	add_DHCP_server
}

function install_scripts ()
{
	git clone https://github.com/OSgenie/PXE-scripts.git
	./PXE-scripts/install.sh
}

function load_initial_iso_torrents ()
{
	get-torrents
	/etc/init.d/transmission-daemon restart
}

function download_initial_iso ()
{
	mkdir -p /var/nfs/iso
}

check_for_sudo
network_configuration_decision
build_PXE_server
DHCP_server_installation_decision
install_scripts
load_initial_iso_torrents
download_initial_iso
