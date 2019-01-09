#!/usr/bin/env bash
find /var/lib/tftpboot/menus/ -type f -name '*.conf' -delete

create-install-menus
create-live-menus
create-stock-menus
create-server-alternate-menus
create-netboot-menus
#create-utility-menu
create-submenus
create-main-menu
