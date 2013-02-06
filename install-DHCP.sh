#!/usr/bin/env bash
PXE_subnet=192.168.100.0
PXE_netmask=255.255.255.0
PXE_IP_range_start=192.168.100.201
PXE_IP_range_end=192.168.100.254
set_domain=example.com
DNS_server1=192.168.100.1
DNS_server2=8.8.4.4

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function install_packages ()
{
apt-get install -y dhcp3-server
}

function configure_dhcp ()
{
mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.orig
chmod a-w /etc/dhcp/dhcpd.conf.orig
cat > /etc/dhcp/dhcpd.conf << EOM
# For configuration examples, see /etc/dhcp/dhcpd.conf.orig 
#  
# Attention: If /etc/ltsp/dhcpd.conf exists, that will be used as
# configuration file instead of this file.
#
#('none', since DHCP v2 did not have support for DDNS.)
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name "$set_domain";
option domain-name-servers $DNS_server1, ns2.example.org;

default-lease-time 600;
max-lease-time 7200;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

#subnet declaration
subnet $PXE_subnet netmask $PXE_netmask {
        range $PXE_IP_range_start $PXE_IP_range_end;
        filename "pxelinux.0";
}
EOM
}

install_packages
configure_dhcp
service isc-dhcp-server restart