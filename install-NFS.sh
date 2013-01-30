#!/bin/bash

IP_subnet=192.168.0.0/16

function install_packages ()
{
sudo apt-get install -y nfs-kernel-server
}

function create_directories ()
{
# Create updater nfs folders
sudo mkdir -p /var/nfs/updatediso/install/md5/
sudo chmod -R 777 /var/nfs/updatediso/install/
sudo mkdir -p /var/nfs/updatediso/live/md5/
sudo chmod -R 777 /var/nfs/updatediso/live/
# Create pxeboot nfs folders
sudo mkdir -p /var/nfs/pxeboot/stock/
sudo mkdir -p /var/nfs/pxeboot/live/
sudo mkdir -p /var/nfs/pxeboot/install/
# Transmission complete folder (redundant)
sudo mkdir -p /var/nfs/transmission/complete
}

function configure_exports_file ()
{
echo "/var/nfs              $IP_subnet(rw,fsid=0,insecure,no_subtree_check,async)" | sudo tee -a /etc/exports
echo "/var/nfs/updatediso   $IP_subnet(rw,nohide,insecure,no_subtree_check,async)" | sudo tee -a /etc/exports
echo "/var/nfs/pxeboot      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | sudo tee -a /etc/exports
echo "/var/nfs/transmission/complete      $IP_subnet(ro,no_root_squash,insecure,no_subtree_check,async)" | sudo tee -a /etc/exports
}

install_packages
create_directories
configure_exports_file
sudo /etc/init.d/nfs-kernel-server restart