OSgenie ISO PXE server
======================

Scripts for building a server which automatically converts liveCD isos to a PXE bootable format.
Designed to be used in conjunction with the OSgenie ISO update server
https://github.com/OSgenie/ISO-update-server

## Currently with the following menus.
  1. Stock - PXEboots iso as downloaded
  2. Live - PXEboots directly into the live desktop.
  3. Install - PXEboots an OEM install
  4. Server and Alternate - Traditional PXE boot option with an auto build seed (user:ubuntu pass:ubuntu)

## Variables are all contained in .config files for easy modification
  1. Currently configured with a 192.168.11.0 subnet
  2. Default server IP is 192.168.11.18
  3. All variables for the server and services are in build.config

## To build the server follow these steps
  1. Hardware Requirements
    1. RAM - 512MB min, 1024MB preferred
    2. Two hard drives
      1. 4GB+ for root
      2. 1TB+ for /var (use multiple drives for LVM or RAID)
  2. Install Ubuntu 12.04 Server
  3. Install Git and run Build Scripts
    1. sudo apt-get install git-core
    2. git clone https://github.com/OSgenie/ISO-PXE-server.git
    3. cd ISO-PXE-server
    4. edit settings in build.config as needed
    5. sudo ./build-ISO-to-PXE-boot-server.sh
  4. After the server is built you will need to generate the update lists based on version and architecture
    1. Goto http://192.168.11.18:9091/transmission/web/ to verify that all isos have finished downloading. Default user:pass is transmission:proceed
    2. ssh -t 192.168.11.18 sudo generate-update-lists
