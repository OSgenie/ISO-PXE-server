#!/bin/bash
source install.config


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

initialize_crontab
install_PXEMENU_scripts
install_PXEBOOT_scripts
install_PXEISO_scripts
