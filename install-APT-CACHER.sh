#!/usr/bin/env bash

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function install_packages ()
{
apt-get install -y apt-cacher-ng
}

function configure_conf ()
{
sed -i 's/# Remap-secdeb: security.debian.org/Remap-secdeb: security.debian.org/g' /etc/apt-cacher-ng/acng.conf
sed -i 's/# PidFile: \/var\/run\/apt-cacher-ng\/pid/PidFile: \/var\/run\/apt-cacher-ng\/pid/g' /etc/apt-cacher-ng/acng.conf
sed -i 's/.*# BindAddress: localhost 192.168.7.254 publicNameOnMainInterface.*/&\nBindAddress: 0.0.0.0/' /etc/apt-cacher-ng/acng.conf
}

check_for_sudo
install_packages
configure_conf
service apt-cacher-ng restart