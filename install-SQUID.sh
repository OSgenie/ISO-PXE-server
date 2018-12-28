#!/usr/bin/env bash
source build.config

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function install_packages ()
{
apt-get install -y squid
}

function configure_squid3 ()
{
cp /etc/squid3/squid.conf /etc/squid3/squid.conf.orig
chmod a-w /etc/squid3/squid.conf.orig
# Configure access
sed -i 's/#http_access allow localnet/http_access allow localnet/g' /etc/squid3/squid.conf
if [ "$IP_subnet" == "10.0.0.0/8" ]; then
sed -i 's/#acl localnet src 10.0.0.8\/acl localnet src 10.0.0.0\/8/g'/etc/squid3/squid.conf
elif [ "$IP_subnet" == "172.16.0.0/12" ]; then
sed -i 's/#acl localnet src 172.16.0.0\/12/acl localnet src 172.16.0.0\/12/g' /etc/squid3/squid.conf
elif [ "$IP_subnet" == "192.168.0.0/16" ]; then
sed -i 's/#acl localnet src 192.168.0.0\/16/acl localnet src 192.168.0.0\/16/g' /etc/squid3/squid.conf
fi
# enable cache for 50GB
sed -i 's/#cache_dir ufs \/var\/spool\/squid3 100 16 256/cache_dir ufs \/var\/spool\/squid3 51200 16 256/g' /etc/squid3/squid.conf
# Set port
#sed -i 's/http_port 3128/http_port 8888/g' /etc/squid3/squid.conf
service squid3 restart
}

check_for_sudo
install_packages
configure_squid3
