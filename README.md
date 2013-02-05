ISO-to-PXE-server
===========

Scripts for building a server which automatically converts liveCD isos to a PXE bootable format.

Currently with 3 options
  1. Stock - PXEboots iso as downloaded
  2. Live - PXEboots directly into the live desktop.
  3. Install - PXEboots an OEM install

To build the server follow these steps
  1. Hardware Requirements
    1. RAM - 512MB min, 1024MB preferred
    2. Two hard drives
        1. 4GB+ for root
        2. 1TB+ for /var (use multiple drives for LVM or RAID)
  2. Install Ubuntu 12.04 Server
  3. Install Git and Run Build Scripts
      1. sudo apt-get install git-core
      2. git clone https://github.com/OSgenie/ISO-to-PXE-server.git
      3. sudo ./ISO-to-PXE-server/build-ISO-to-PXE-boot-server.sh
