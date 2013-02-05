#!/usr/bin/env bash
set_subnet=192.168.100
set_netmask=255.255.255.0
system_eth=eth0 
system_ip=3
gateway_ip=1
nameserver_ip=192.168.100.1 #full IP
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
service networking stop
mv /etc/network/interfaces /etc/network/interfaces.orig
chmod a-w /etc/network/interfaces.orig
cat > /etc/network/interfaces << EOM
# The loopback network interface
auto lo
iface lo inet loopback

# System network interface on $system_eth
auto $system_eth
iface $system_eth inet static
       address $set_subnet.$system_ip
       network $set_subnet.0
       netmask $set_netmask
       broadcast $set_subnet.255
       gateway $set_subnet.$gateway_ip
       dns-nameservers=$nameserver_ip
EOM

sudo service networking restart
}

function build_PXE_server ()
{
.$scriptdir/install-APT-CACHER.sh
echo 'Acquire::http { Proxy "http://'$set_subnet'.'$system_ip':3142"; };' | sudo tee /etc/apt/apt.conf
apt-get update
.$scriptdir/install-NFS.sh
.$scriptdir/install-BT.sh
.$scriptdir/install-SQUID.sh
.$scriptdir/install-PXE.sh
}

function add_DHCP_server ()
{
echo "PXE booting requires a DHCP configured to deliver the pxelinux.0 file to booting clients"
echo "You can either install a DHCP services on this server or configure an existing DHCP server for PXE booting"
echo "To configure a DD-WRT router, add 'dhcp-boot=pxelinux.0,pxeserver,$set_subnet.$system_ip' to the DNSMasq options"
echo "Only choose to install DHCP on this server if it is going to be authoritative"
read -p "Do you want to install DHCP service on this server (yes/no)? " choice
echo ""
if [ '$choice' == 'yes' ]; then
    .$scriptdir/install-DHCP.sh
elif [ '$choice' == 'no' ]; then
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