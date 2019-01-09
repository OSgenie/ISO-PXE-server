#!/usr/bin/env bash
source ../install.config

function install_generate_update_lists ()
{
  mkdir -p /var/transmission/complete/updatelist
  install $script_dir/generate-update-lists.sh $binary_dir/generate-update-lists
}

function install_scripts_local_bin ()
{
install $script_dir/extract-iso.sh $binary_dir/extract-isos
install $script_dir/remove-older-iso-revisions.sh $binary_dir/remove-older-iso-revisions
}

function configure_crontab ()
{
  crontab -l | { cat; echo "00 * * * * $binary_dir/extract-isos  > $log_dir/extract-isos.log"; } | crontab -
  crontab -l | { cat; echo "30 00 * * * $binary_dir/remove-older-iso-revisions  > $log_dir/remove-older-isos.log"; } | crontab -
}

install_scripts_local_bin
configure_crontab
