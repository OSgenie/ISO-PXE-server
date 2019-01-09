#!/bin/bash
## Directory path sections are hard coded in
## Assuming iso directory structure of /var/iso/$iso_type/$rev_date

revdate=gold
iso_type=stock

pxe_http_server=http://192.168.11.18
pxe_share=/var/pxe_boot
all_isos=$(find /var/iso/* -type f -name *.iso)

function check_for_sudo ()
{
if [ $UID != 0 ]; then
		echo "You need root privileges"
		exit 2
fi
}

function extract_iso_to_dir ()
{
for iso in $all_isos; do
		iso_dir_path=$(dirname "$iso")
		iso_dir_path_array=${iso_dir_path//\// }
		iso_type=${iso_dir_path_array[2]}
		revdate=${iso_dir_path_array[3]}
		fullname=$(basename "$iso")
    extension=${fullname##*.}
    distro=$(basename $iso .$extension)
		distro_folders=${distro//-/\/}
    pxe_folder=$pxe_share"/"$iso_type"/"$distro_folders"/"$revdate
    if [ $extension == iso ]; then
        if [ ! -e $pxe_folder ]; then
            echo "COPY $iso_type - $fullname"
            mount -o ro,loop $iso /mnt/
            mkdir -p $pxe_folder
            cp -ru /mnt/* $pxe_folder
            cp -ru /mnt/.disk $pxe_folder
            umount /mnt/
        else
            echo "$pxe_folder exists!"
        fi
    fi
done
}

check_for_sudo
extract_iso_to_dir
