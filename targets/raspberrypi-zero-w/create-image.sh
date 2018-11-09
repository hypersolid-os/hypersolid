#!/usr/bin/env bash

set -xe

VIRTUAL_DISK=/tmp/disk.img

# remove motd
rm ${ROOTFS}/etc/motd

# Create sparse file to represent our disk
truncate --size 4G /tmp/disk.img
 
# Create partition layout
sgdisk --clear \
  --new 1::+550M --typecode=1:ef00 --change-name=1:'EFI System' \
  --new 2::-0 --typecode=2:8300 --change-name=2:'Linux root filesystem' \
  ${VIRTUAL_DISK}

# show layout
gdisk -l ${VIRTUAL_DISK}

# mount disk
LOOPDEV=$(losetup --find --show ${VIRTUAL_DISK})

