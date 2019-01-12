#!/usr/bin/env bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/common.functions
source $script_dir/dhcp.config

function install_packages ()
{
	apt-get install -y dhcp3-server
}

function configure_dhcp ()
{
	service isc-dhcp-server stop
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
option domain-name "$DHCP_domain";
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
	service isc-dhcp-server start
}

check_for_sudo
install_packages
configure_dhcp
