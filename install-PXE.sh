#!/usr/bin/env bash
source build.config
tftpboot_root="/var/lib/tftpboot"

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function install_packages ()
{
apt-get install -y tftpd-hpa syslinux nfs-kernel-server initramfs-tools
}

function create_directories ()
{
mkdir -p /mnt/pxeboot
echo "create kernel directories"
mkdir -p $tftpboot_root/boot/
echo "create PXE menu directories"
mkdir -p $tftpboot_root/menus/stock
mkdir -p $tftpboot_root/menus/live
mkdir -p $tftpboot_root/menus/install
mkdir -p $tftpboot_root/menus/server
}

function configure_tftpd ()
{
echo 'RUN_DAEMON="yes"' | tee -a /etc/default/tftpd-hpa
echo 'OPTIONS="-l -s $tftpboot_root"' | tee -a /etc/default/tftpd-hpa
/etc/init.d/tftpd-hpa restart
}

function copy_pxelinux ()
{
cd $tftpboot_root
wget http://us.archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/ubuntu-installer/i386/boot-screens/vesamenu.c32
wget http://us.archive.ubuntu.com/ubuntu/dists/precise/main/installer-i386/current/images/netboot/ubuntu-installer/i386/pxelinux.0
}

function set_pxelinux_default ()
{
mkdir $tftpboot_root/pxelinux.cfg
cat > $tftpboot_root/pxelinux.cfg/default << EOM
# D-I config version 2.0
default vesamenu.c32
include mainmenu.conf
EOM
}

function install_PXE_scripts ()
{
git clone https://github.com/OSgenie/PXE-scripts.git
./PXE-scripts/install-PXE-scripts-to-crontab.sh
}

check_for_sudo
install_packages
create_directories
configure_tftpd
copy_pxelinux
set_pxelinux_default
install_PXE_scripts