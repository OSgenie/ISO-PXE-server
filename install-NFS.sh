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
apt-get install -y nfs-kernel-server apache2
}

function create_directories ()
{
# Create updater nfs folders
mkdir -p /var/nfs/updatediso/install/md5/
chmod -R 777 /var/nfs/updatediso/install/
mkdir -p /var/nfs/updatediso/live/md5/
chmod -R 777 /var/nfs/updatediso/live/
# Create pxeboot nfs folders
mkdir -p /var/nfs/pxeboot/stock/
mkdir -p /var/nfs/pxeboot/live/
mkdir -p /var/nfs/pxeboot/install/
mkdir -p /var/nfs/pxeboot/preseed/
# Create transmission folder so export doesn't  fail.
mkdir -p /var/nfs/transmission/complete
}

function configure_exports_file ()
{
echo "/var/nfs              $IP_subnet(rw,fsid=0,insecure,no_subtree_check,async)" | tee -a /etc/exports
echo "/var/nfs/updatediso   $IP_subnet(rw,nohide,insecure,no_subtree_check,async)" | tee -a /etc/exports
echo "/var/nfs/pxeboot      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | tee -a /etc/exports
echo "/var/nfs/transmission/complete      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | tee -a /etc/exports
service nfs-kernel-server restart
}

function configure_apache_root ()
{
service apache2 stop
sed -i 's/DocumentRoot \/var\/www/DocumentRoot \/var\/nfs\/pxeboot/g' /etc/apache2/sites-available/default
sed -i 's/<Directory \/var\/www\/>/<Directory \/var\/nfs\/pxeboot\/>/g' /etc/apache2/sites-available/default
service apache2 start
}

check_for_sudo
install_packages
create_directories
configure_exports_file
configure_apache_root