#!/bin/bash
source ../install.config

function install_scripts_local_bin ()
{
  install $script_dir/get-torrents.sh $binary_dir/get-torrents
  cp -r $script_dir/torrent.configs $binary_dir/
}

function configure_crontab ()
{
  crontab -l | { cat; echo "30 02 * * 0 $binary_dir/get-torrents  > $log_dir/get-torrents.log"; } | crontab -
}

install_scripts_local_bin
configure_crontab
