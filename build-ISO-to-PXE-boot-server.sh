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

function build_PXE_server ()
{
cd $scriptdir
./install-APT-CACHER.sh
echo 'Acquire::http { Proxy "http:'$primary_eth_ip':3142"; };' | tee /etc/apt/apt.conf
apt-get update
apt-get upgrade -y
./install-NFS.sh
./install-BT.sh
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
    echo "  dhcp-boot=pxelinux.0,pxeserver,$set_subnet.$system_ip"
    echo "*************************************************************************************************"
fi
}

function install_PXE_scripts ()
{
git clone https://github.com/OSgenie/PXE-scripts.git
./PXE-scripts/install-PXE-scripts-to-crontab.sh
}

check_for_sudo
configure_network_interfaces
build_PXE_server
add_DHCP_server
install_PXE_scripts