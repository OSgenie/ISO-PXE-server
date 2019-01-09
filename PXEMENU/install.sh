#!/usr/bin/env bash
source ../install.config

function install_config_source_local_bin ()
{
	cat > $binary_dir/pxe.config << EOF
	server_ip=$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
	tftp_folder=/var/lib/tftpboot
	nfs_server=\$server_ip
EOF
}

function install_scripts_local_bin ()
{
	install $script_dir/build-pxemenus.sh $binary_dir/build-pxemenus
	install $script_dir/create-install-menus.sh $binary_dir/create-install-menus
	install $script_dir/create-live-menus.sh $binary_dir/create-live-menus
	install $script_dir/create-submenus.sh $binary_dir/create-submenus
	install $script_dir/create-stock-menus.sh $binary_dir/create-stock-menus
	install $script_dir/create-server-alternate-menus.sh $binary_dir/create-server-alternate-menus
	install $script_dir/create-netboot-menus.sh $binary_dir/create-netboot-menus
#install $script_dir/create-utility-menu.sh $binary_dir/create-utility-menu
	install $script_dir/create-main-menu.sh $binary_dir/create-main-menu
	install $script_dir/create-preseed-files.sh $binary_dir/create-preseed-files
	cp -r $script_dir/preseed.configs $binary_dir/
}

function configure_crontab ()
{
	crontab -l | { cat; echo "45 03 * * * $binary_dir/build-pxemenus  > $log_dir/build-pxemenus.log"; } | crontab -
}

function generate_preseeds ()
{
	create-preseed-files
}

check_for_sudo
install_config_source_local_bin
install_scripts_local_bin
configure_crontab
generate_preseeds
