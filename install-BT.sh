#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com
IP_whitelist=192.168.*.* #Allowable client access list
read -s -p "Choose a password for accessing the transmission server :" transmission_pass
echo ""
echo "Thank you, the user name will be 'transmission'"

function install_packages ()
{
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:transmissionbt/ppa
sudo apt-get update
sudo apt-get install -y transmission-daemon
}

function create_directories ()
{
sudo mkdir -p /var/nfs/transmission/torrents
sudo mkdir -p /var/nfs/transmission/incomplete
sudo mkdir -p /var/nfs/transmission/complete
sudo chown debian-transmission:debian-transmission -R /var/nfs/transmission
}

function configure_transmission_daemon ()
{
sudo /etc/init.d/transmission-daemon stop
# Set Password
sudo sed -i '/\"rpc-password\": \"}/d'  /etc/transmission-daemon/settings.json
sudo sed -i "s/.*}.*/    \"rpc-password\": \"$transmission_pass\",\n&/" /etc/transmission-daemon/settings.json
# Set Other Settings.
sudo sed -i "s/\"alt-speed-down\": 50,/\"alt-speed-down\": 3000,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"alt-speed-time-enabled\": false,/\"alt-speed-time-enabled\": true,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"alt-speed-time-end\": 1020,/\"alt-speed-time-end\": 1425,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"alt-speed-up\": 50,/\"alt-speed-up\": 1000,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"incomplete-dir\": \"\/home\/$USER\/Downloads\",/\"incomplete-dir\": \"\/var\/nfs\/transmission\/incomplete\",/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"lpd-enabled\": false,/\"lpd-enabled\": true,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"ratio-limit\": 2,/\"ratio-limit\": 3,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"ratio-limit-enabled\": false,/\"ratio-limit-enabled\": true,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"rpc-whitelist\": \"127.0.0.1\",/\"rpc-whitelist\": \"127.0.0.1,$IP_whitelist\",/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"speed-limit-down\": 100,/\"speed-limit-down\": 1000,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"speed-limit-up\": 100,/\"speed-limit-up\": 500,/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"download-dir\": \"\/var\/lib\/transmission-daemon\/downloads\",/\"download-dir\": \"\/var\/nfs\/transmission\/complete\",/g" /etc/transmission-daemon/settings.json
sudo sed -i "s/\"utp-enabled\": true/\"utp-enabled\": true,/g"  /etc/transmission-daemon/settings.json
sudo sed -i "s/.*}.*/    \"watch-dir\": \"\/var\/nfs\/transmission\/torrents\",\n&/" /etc/transmission-daemon/settings.json
sudo sed -i "s/.*}.*/    \"watch-dir-enabled\": true\n&/" /etc/transmission-daemon/settings.json
sudo /etc/init.d/transmission-daemon start
}

install_packages
create_directories
configure_transmission_daemon