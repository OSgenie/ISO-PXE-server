#!/bin/bash
# Kirtley Wienbroer
# kirtley@osgenie.com

function install_packages ()
{
sudo apt-get update
sudo apt-get install -y apt-cacher-ng
}

function set_port ()
{
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3142
sudo iptables -t nat -L PREROUTING
sudo iptables-save
sudo iptables -t nat -L PREROUTING
}

function configure_conf ()
{
sudo sed -i 's/# Remap-secdeb: security.debian.org/Remap-secdeb: security.debian.org/g' /etc/apt-cacher-ng/acng.conf
sudo sed -i 's/# PidFile: \/var\/run\/apt-cacher-ng\/pid/PidFile: \/var\/run\/apt-cacher-ng\/pid/g' /etc/apt-cacher-ng/acng.conf
sudo sed -i 's/.*# BindAddress: localhost 192.168.7.254 publicNameOnMainInterface.*/&\nBindAddress: 0.0.0.0/' /etc/apt-cacher-ng/acng.conf
}

install_packages
set_port
configure_conf
sudo service apt-cacher-ng restart