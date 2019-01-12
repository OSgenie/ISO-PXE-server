#!/usr/bin/env bash
##	echo "/var              $IP_subnet(rw,fsid=0,insecure,no_subtree_check,async)" | tee -a /etc/exports
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/common.functions
source $script_dir/nfs_squid.config

function check_for_sudo ()
{
	if [ $UID != 0 ]; then
			echo "You need root privileges"
			exit 2
	fi
}

function create_directories ()
{
# Create updater nfs folders
	mkdir -p /var/updatediso/install/md5/
	chmod -R 777 /var/updatediso/install/
	mkdir -p /var/updatediso/live/md5/
	chmod -R 777 /var/updatediso/live/
	# Create pxeboot nfs folders
	mkdir -p /var/pxeboot/stock/
	mkdir -p /var/pxeboot/live/
	mkdir -p /var/pxeboot/install/
	mkdir -p /var/pxeboot/preseed/
}

function install_nfs-kernel-server ()
{
	apt-get install -y nfs-kernel-server
}

function install_apache2 ()
{
	apt-get install -y apache2
}

function configure_nfs_exports ()
{
	service nfs-kernel-server stop
	echo "/var/updatediso   $IP_subnet(rw,nohide,insecure,no_subtree_check,async)" | tee -a /etc/exports
	echo "/var/pxeboot      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | tee -a /etc/exports
	echo "/var/iso      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | tee -a /etc/exports
	service nfs-kernel-server start
}

function configure_apache2 ()
{
	service apache2 stop
	sed -i "s/DocumentRoot \/var\/www\/html/DocumentRoot ${apache_root_dir//\//\\\/}/g" /etc/apache2/sites-available/000-default.conf
	sed -i "s/DocumentRoot \/var\/www\/html/DocumentRoot ${apache_root_dir//\//\\\/}/g" /etc/apache2/sites-enabled/000-default.conf
	sed -i "s/<Directory \/var\/www\/>/<Directory ${apache_root_dir//\//\\\/}>/g" /etc/apache2/apache2.conf
	service apache2 start
}

check_for_sudo
create_directories
install_nfs-kernel-server
configure_nfs_exports
install_apache2
configure_apache2
