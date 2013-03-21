#!/usr/bin/env bash
source build.config

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
default-lease-time 600;
max-lease-time 7200;
option domain-name "$set_domain";
option domain-name-servers $DHCP_nameserver1, $DHCP_nameserver2;
option routers $DHCP_gateway;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
log-facility local7;

#subnet declaration
subnet $DHCP_subnet netmask $DHCP_netmask {
        range $DHCP_IP_range_start $DHCP_IP_range_end;
        filename "pxelinux.0";
}
EOM
}

check_for_sudo
install_packages
configure_dhcp
service isc-dhcp-server restart