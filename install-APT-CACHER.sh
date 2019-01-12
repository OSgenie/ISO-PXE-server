#!/usr/bin/env bash
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/common.functions

function install_apt_cacher ()
{
	apt-get update
	apt-get install -y apt-cacher-ng
}

function configure_apt_cacher ()
{
	service apt-cacher-ng stop
	sed -i 's/# Remap-secdeb: security.debian.org/Remap-secdeb: security.debian.org/g' /etc/apt-cacher-ng/acng.conf
	sed -i 's/# PidFile: \/var\/run\/apt-cacher-ng\/pid/PidFile: \/var\/run\/apt-cacher-ng\/pid/g' /etc/apt-cacher-ng/acng.conf
	sed -i 's/.*# BindAddress: localhost 192.168.7.254 publicNameOnMainInterface.*/&\nBindAddress: 0.0.0.0/' /etc/apt-cacher-ng/acng.conf
	service apt-cacher-ng start
}

check_for_sudo
install_apt_cacher
configure_apt_cacher
