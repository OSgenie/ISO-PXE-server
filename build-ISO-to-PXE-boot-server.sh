#!/usr/bin/env bash
source build.config
scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

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

# System network interface on $system_eth
auto $primary_eth
iface $primary_eth inet static
       address $primary_eth_ip
       network $primary_eth_subnet
       netmask $primary_eth_netmask
       broadcast $primary_eth_broadcast
       gateway $primary_eth_gateway
       dns-nameservers $nameserver_1 $nameserver_2
EOM
wait 5
ifup $primary_eth
}

function build_PXE_server ()
{
cd $scriptdir
./install-APT-CACHER.sh
#echo 'Acquire::http { Proxy "http:'$primary_eth_ip':3142"; };' | tee /etc/apt/apt.conf
echo 'Acquire::http { Proxy "http:'192.168.11.10':3142"; };' | tee /etc/apt/apt.conf
apt-get update
apt-get upgrade -y
./install-NFS.sh
./install-BT.sh
./install-SQUID.sh
./install-PXE.sh
}

function add_DHCP_server ()
{
echo "PXE booting requires a DHCP configured to deliver the pxelinux.0 file to booting clients"
echo "You can either install a DHCP services on this server or configure an existing DHCP server for PXE booting"
echo "To configure a DD-WRT router, add 'dhcp-boot=pxelinux.0,pxeserver,$set_subnet.$system_ip' to the DNSMasq options"
echo "Only choose to install DHCP on this server if it is going to be authoritative"
read -p "Do you want to install DHCP service on this server (yes/no)? " choice
echo ""
if [ "$choice" == "yes" ]; then
    ./install-DHCP.sh
elif [ "$choice" == "no" ]; then
    echo "Don't forget to add 'dhcp-boot=pxelinux.0,pxeserver,$set_subnet.$system_ip' to the DNSMasq options of your router"
else
    echo "Your answer wasn't understood"
    add_DHCP_server
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
clear
add_DHCP_server
install_PXE_scripts