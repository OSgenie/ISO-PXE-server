#!/usr/bin/env bash
##	echo "/var              $IP_subnet(rw,fsid=0,insecure,no_subtree_check,async)" | tee -a /etc/exports
source server.config

function check_for_sudo ()
{
	if [ $UID != 0 ]; then
			echo "You need root privileges"
			exit 2
	fi
}

function install_packages ()
{
	apt-get install -y nfs-kernel-server apache2
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

function configure_exports_file ()
{
	echo "/var/updatediso   $IP_subnet(rw,nohide,insecure,no_subtree_check,async)" | tee -a /etc/exports
	echo "/var/pxeboot      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | tee -a /etc/exports
	echo "/var/transmission/complete      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | tee -a /etc/exports
	service nfs-kernel-server restart
}

function configure_apache_root ()
{
	service apache2 stop
	sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/pxeboot/g' /etc/apache2/sites-available/000-default.conf
	sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/pxeboot/g' /etc/apache2/sites-enabled/000-default.conf
	sed -i 's/<Directory \/var\/www\/>/<Directory \/var\/pxeboot\/>/g' /etc/apache2/apache2.conf
	service apache2 start
}

check_for_sudo
install_packages
create_directories
configure_exports_file
configure_apache_root
