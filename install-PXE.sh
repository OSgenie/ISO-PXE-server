#!/usr/bin/env bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/common.functions
source $script_dir/application.config

function create_directories ()
{
	echo "create kernel directories"
	mkdir -p $tftpboot_root/boot/
	echo "create PXE menu directories"
	mkdir -p $tftpboot_root/menus/stock
	mkdir -p $tftpboot_root/menus/live
	mkdir -p $tftpboot_root/menus/install
	mkdir -p $tftpboot_root/menus/server
	mkdir -p $tftpboot_root/menus/netboot
}

function install_pxe_boot_environment ()
{
	apt-get install -y tftpd-hpa syslinux initramfs-tools
}

function install_preseed_script_dependencies ()
{
	apt-get install -y whois
}

function configure_tftpd ()
{
	echo 'RUN_DAEMON="yes"' | tee -a /etc/default/tftpd-hpa
	echo 'OPTIONS="-l -s $tftpboot_root"' | tee -a /etc/default/tftpd-hpa
	/etc/init.d/tftpd-hpa restart
}

function copy_pxelinux_to_tftpboot_root ()
{
	cd $tftpboot_root
	wget http://us.archive.ubuntu.com/ubuntu/dists/xenial/main/installer-i386/current/images/netboot/ubuntu-installer/i386/boot-screens/vesamenu.c32
	wget http://us.archive.ubuntu.com/ubuntu/dists/xenial/main/installer-i386/current/images/netboot/ubuntu-installer/i386/pxelinux.0
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

check_for_sudo
create_directories
install_pxe_boot_environment
install_preseed_script_dependencies
configure_tftpd
copy_pxelinux_to_tftpboot_root
set_pxelinux_default
