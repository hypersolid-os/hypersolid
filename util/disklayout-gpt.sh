#!/usr/bin/env bash

set -xe

DISK=/dev/sda

# paritioning
# -----------------------------------------

# erase parition table
sgdisk --zap-all $DISK

# bootloader volume 10MB - TYPE:bios boot
sgdisk -n 0:0:+10MiB -t 0:ef02 -c 0:boot $DISK

# persistent config storage 1gb - TYPE:linux_filesystem
sgdisk -n 0:0:+1GiB -t 0:8300 -c 0:conf $DISK

# swap volume 4gb - TYPE:swap
sgdisk -n 0:0:+4GiB -t 0:8200 -c 0:swap $DISK

# data volume - TYPE:linux_filesystem
sgdisk -n 0:0:0 -t 0:8300 -c 0:data $DISK

# gpt partition 1 legacy bios bootable
sgdisk $DISK --attributes=1:set:2

# filesystems
# -----------------------------------------
mkfs.ext2 ${DISK}1
mkfs.ext4 ${DISK}2
mkswap ${DISK}3
mkfs.ext4 ${DISK}4
