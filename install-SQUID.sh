#!/bin/bash
function install_packages ()
{
sudo apt-get install -y squid
}

function configure_squid3 ()
{
sudo cp /etc/squid3/squid.conf /etc/squid3/squid.conf.orig
sudo chmod a-w /etc/squid3/squid.conf.orig
# Configure access
sudo sed -i 's/#acl localnet src 192.168.0.0\/16/acl localnet src 192.168.0.0\/16/g' /etc/squid3/squid.conf
sudo sed -i 's/#http_access allow localnet/http_access allow localnet/g' /etc/squid3/squid.conf
# enable cache for 50GB
sudo sed -i 's/#cache_dir ufs \/var\/spool\/squid3 100 16 256/cache_dir ufs \/var\/spool\/squid3 51200 16 256/g' /etc/squid3/squid.conf
# Set port
#sudo sed -i 's/http_port 3128/http_port 8888/g' /etc/squid3/squid.conf
sudo service squid3 restart
}

install_packages
configure_squid3