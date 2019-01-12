#!/usr/bin/env bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/common.functions
source $script_dir/transmission.config

function create_directories ()
{
mkdir -p /var/transmission/torrents
mkdir -p /var/transmission/incomplete
mkdir -p /var/iso/stock
chown debian-transmission:debian-transmission -R /var/transmission
chown debian-transmission:debian-transmission -R /var/iso/stock
}

function install_transmission_daemon ()
{
apt-get install -y python-software-properties software-properties-common
add-apt-repository -y ppa:transmissionbt/ppa
apt-get update
apt-get install -y transmission-daemon
}

function configure_transmission_daemon ()
{
/etc/init.d/transmission-daemon stop
# Configure Access
sed -i "s/\"rpc-whitelist\": \"127.0.0.1\",/\"rpc-whitelist\": \"127.0.0.1,$IP_whitelist\",/g" /etc/transmission-daemon/settings.json
sed -i '/\"rpc-password\": \"}/d'  /etc/transmission-daemon/settings.json
sed -i "s/.*}.*/    \"rpc-password\": \"$transmission_pass\",\n&/" /etc/transmission-daemon/settings.json
# Configure Bandwidth usage.
sed -i "s/\"ratio-limit\": 2,/\"ratio-limit\": 3,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"ratio-limit-enabled\": false,/\"ratio-limit-enabled\": true,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"speed-limit-down\": 100,/\"speed-limit-down\": 1000,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"speed-limit-up\": 100,/\"speed-limit-up\": 500,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"alt-speed-down\": 50,/\"alt-speed-down\": 3000,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"alt-speed-time-enabled\": false,/\"alt-speed-time-enabled\": true,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"alt-speed-time-end\": 1020,/\"alt-speed-time-end\": 1425,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"alt-speed-up\": 50,/\"alt-speed-up\": 1000,/g" /etc/transmission-daemon/settings.json
# Configure Directories.
sed -i "s/\"incomplete-dir\": \"\/home\/$USER\/Downloads\",/\"incomplete-dir\": \"\/var\/transmission\/incomplete\",/g" /etc/transmission-daemon/settings.json
sed -i "s/\"incomplete-dir-enabled\": false,/\"incomplete-dir-enabled\": true,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"download-dir\": \"\/var\/lib\/transmission-daemon\/downloads\",/\"download-dir\": \"\/var\/iso\/stock\",/g" /etc/transmission-daemon/settings.json
sed -i "s/.*}.*/    \"watch-dir\": \"\/var\/transmission\/torrents\",\n&/" /etc/transmission-daemon/settings.json
sed -i "s/.*}.*/    \"watch-dir-enabled\": true\n&/" /etc/transmission-daemon/settings.json
# Other Settings
sed -i "s/\"lpd-enabled\": false,/\"lpd-enabled\": true,/g" /etc/transmission-daemon/settings.json
sed -i "s/\"utp-enabled\": true/\"utp-enabled\": true,/g"  /etc/transmission-daemon/settings.json
/etc/init.d/transmission-daemon start
}

check_for_sudo
create_directories
install_transmission_daemon
configure_transmission_daemon
