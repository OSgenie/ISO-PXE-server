#!/bin/bash
netboot_dir=/var/lib/tftpboot/
netboot_configs=tftpboot.configs

for config in $netboot_configs/*.configs; do
  fullname=${basename $config}
  extension=${fullname##*.}
  distro=$(basename $iso .$extension)
  for release in ${config/*}; do
    release_name=$(cat $release)
    for arch in ${distro".arches/*"}; do
      arch_name=$(cat $arch)
    mkdir -p $netbootdir/$distro/$release/$arch
    cd $netbootdir/$distro/$release/$arch/
    wget --no-clobber "http://us.archive.ubuntu.com/ubuntu/dists/"$release_name"/main/installer-"$arch_name"/current/images/netboot/ubuntu-installer/"$arch_name"/initrd.gz"
    wget --no-clobber "http://us.archive.ubuntu.com/ubuntu/dists/"$release_name"/main/installer-"$arch_name"/current/images/netboot/ubuntu-installer/"$arch_name"/linux"
    done
  done
done
