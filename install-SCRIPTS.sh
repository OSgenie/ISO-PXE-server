#!/bin/bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/common.functions
source application.config

function initialize_crontab ()
{
echo "# m h  dom mon dow   command" | crontab -
}

function install_PXEMENU_scripts ()
{
  sh PXEMENU/install.sh
}

function install_PXEBOOT_scripts ()
{
  sh PXEBOOT/install.sh
}

function install_PXEISO_scripts ()
{
  sh PXEISO/install.sh
}

check_for_sudo
initialize_crontab
install_PXEMENU_scripts
install_PXEBOOT_scripts
install_PXEISO_scripts
