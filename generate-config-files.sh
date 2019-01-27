#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function choose_ethernet_adapter ()
{
  readarray ethernet_adapters < /tmp/ethernet_adapter_list
	echo "Choose the Primary Ethernet Adapter"
  declare -i i
    i=1
  for ethernet_adapter in ${ethernet_adapters[*]}; do
		echo "$i) $ethernet_adapter"
    i=$((i+1))
  done
	read -p "Enter the number:" primary_eth
}

function identify_network_adapter ()
{
# Configure Ethernet Adapter
if [ -e /etc/netplan/01-netcfg.yaml ]; then
  cat /etc/netplan/01-netcfg.yaml | grep -A1 ethernets | cut -d: -f1 | awk '{getline; print $1}' > /tmp/ethernet_adapter_list
  network_configuration_file=/etc/netplan/01-netcfg.yaml
  choose_ethernet_adapter
elif [ -e /etc/network/interfaces.d/50-cloud-init.cfg ]; then
  cat /etc/network/interfaces.d/50-cloud-init.cfg | grep iface | cut -d" " -f2 | awk '{getline; print $1}' > /tmp/ethernet_adapter_list
  network_configuration_file=/etc/network/interfaces.d/50-cloud-init.cfg
  choose_ethernet_adapter
elif [ -e /etc/network/interfaces ]; then
  cat /etc/network/interfaces | grep iface | cut -d" " -f2 | awk '{getline; print $1}' > /tmp/ethernet_adapter_list
  network_configuration_file=/etc/network/interfaces
  choose_ethernet_adapter
else
  echo "Unable to identify Network Configuration"
fi
}

function create_administrator_credentials_file ()
{
	echo "Time to Configure the System!!"
	echo "The Following is to log into Unattended Installed Systems."
	echo "Enter the  <Full Name>  of the System Administrator:"
	echo "Spaces Allowed"
	read sys_admin_full_name
	clear
	echo "Enter the  <User Name>  for the System Administrator:"
	echo "Spaces Not Allowed"
	read sys_admin_user_name
	clear
	echo "Ehter the  <Pass Word>  for the System Administrator:"
	echo "This will be encrypted in the preseed files which get sent over the network but will be stored in plain text on this system"
	read sys_admin_pass_word
	cat > $script_dir/admin.config << EOF
sys_admin_full_name="$sys_admin_full_name"
sys_admin_user_name=$sys_admin_user_name
sys_admin_pass_word="$sys_admin_pass_word"
EOF
	clear
	echo "Done!!"
}

function create_domain_configuation_file ()
{
	echo "Time to Configure the System!!"
	echo "Enter the Domain Name of the Company"
  echo "e.g.   kirtley.io    "
	read domain_name
  echo "Enter the Domain Name to be used behind the Firewall"
  echo "e.g.   kirtley.local    "
	read kirtley.local
  echo "Generating domain.config file"
  cat > $scriptdir/domain.config << EOF
domain_name=$domain_name
local_domain=$local_domain
EOF
clear
echo "Done!!"
echo "domain.config file is located at $scriptdir/domain.config"
}

function create_server_parameters_file ()
{

	cat > $script_dir/server.config << EOF
#### System Configuration
### IP settings
## Primary Ethernet
primary_eth=$primary_eth
primary_eth_ip=192.168.11.18
primary_eth_subnet=192.168.11.0
primary_eth_netmask=255.255.255.0
primary_eth_broadcast=192.168.11.255
primary_eth_gateway=192.168.11.1
## Secondary Ethernet
secondary_eth=eth1
secondary_eth_ip=192.168.11.19
secondary_eth_subnet=192.168.11.0
secondary_eth_netmask=255.255.255.0
secondary_eth_broadcast=192.168.11.255
secondary_eth_gateway=192.168.11.1
## Nameservers
nameserver_1=192.168.11.1
nameserver_2=8.8.8.8
EOF
}

function create_transmission_parameters_file ()
{
	echo "Transmission BitTorrent is used to download Operating System ISO files"
	echo "The User Name to Access the Transmission Server is: transmission"
	read -p "Please enter the password:" transmission_pass
	cat > $script_dir/transmission.config << EOF
### Transmission BitTorrent Server
## Transmission Login Credentials
transmission_pass=$transmission_pass
## Allowable client subnet restriction
#IP_whitelist=10.*.*.*
#IP_whitelist=172.*.*.* #semi-restricted
IP_whitelist=192.168.*.*
EOF
}

function create_dhcp_parameters_file ()
{
	cat $script_dir/dhcp.config << EOF
### DHCP settings
DHCP_domain=example.com
DHCP_subnet=192.168.11.0
DHCP_netmask=255.255.255.0
DHCP_IP_range_start=192.168.11.201
DHCP_IP_range_end=192.168.11.254
DHCP_gateway=192.168.11.1
DHCP_nameserver1=192.168.11.1
DHCP_nameserver2=8.8.4.4
EOF
}

function create_nfs_and_squid_parameters_file ()
{
	cat $script_dir/nfs_squid.config << EOF
### NFS & SQUID
## Subnet
#IP_subnet=10.0.0.0/8
#IP_subnet=172.16.0.0/12
IP_subnet=192.168.0.0/16
EOF
}

identify_network_adapter
create_domain_configuation_file
create_administrator_credentials_file
create_server_parameters_file
create_transmission_parameters_file
create_dhcp_parameters_file
create_nfs_and_squid_parameters_file
