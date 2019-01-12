#!/usr/bin/env bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/common.functions

function generate_config_files ()
{
	./generate-config-files.sh
}

function prepare_server ()
{
	./prepare-server.sh
}

function build_PXE_server ()
{
	./$script_dir/install-APT-CACHER.sh
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
	./install-SCRIPTS.sh
}

function load_initial_iso_torrents ()
{
	get-torrents
}

function download_initial_iso ()
{
	mkdir -p /var/nfs/iso
}

check_for_sudo
generate_config_files
prepare_server

build_PXE_server
DHCP_server_installation_decision
install_scripts

load_initial_iso_torrents
download_initial_iso
