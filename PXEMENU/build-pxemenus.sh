#!/usr/bin/env bash
find /var/lib/tftpboot/menus/ -type f -name '*.conf' -delete

/usr/local/bin/create-install-menus
/usr/local/bin/create-live-menus
/usr/local/bin/create-stock-menus
/usr/local/bin/create-server-alternate-menus
/usr/local/bin/create-netboot-menus
#create-utility-menu
/usr/local/bin/create-submenus
/usr/local/bin/create-main-menu
