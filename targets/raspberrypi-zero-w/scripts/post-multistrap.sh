#!/usr/bin/env bash

set -xe

# Download Raspberry pre-build Kernel + Modules + proprietary Firmware (wifi)

# vars
RASPBERRY_KERNEL_VERSION="4.14.70+"
RASPBERRY_FIRMWARE_RELEASE="1.20180919"

# store kernel version (required for mkinitramfs)
#echo "${RASPBERRY_KERNEL_VERSION}" > ${ROOTFS}/etc/kernel_version

# get kernel + precompiled modules/firmware
mkdir -p ${ROOTFS}/lib/modules/${RASPBERRY_KERNEL_VERSION}
wget -O /tmp/raspberry-firmware.zip https://github.com/raspberrypi/firmware/archive/${RASPBERRY_FIRMWARE_RELEASE}.zip
unzip -q /tmp/raspberry-firmware.zip -d /tmp
cp -R /tmp/firmware-${RASPBERRY_FIRMWARE_RELEASE}/boot/* /home/build/boot
cp -R /tmp/firmware-${RASPBERRY_FIRMWARE_RELEASE}/modules/${RASPBERRY_KERNEL_VERSION}/* ${ROOTFS}/lib/modules/${RASPBERRY_KERNEL_VERSION}

# download nonfree firmware (wifi..)
mkdir -p ${ROOTFS}/lib/firmware/brcm
cd ${ROOTFS}/lib/firmware/brcm
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.bin
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.txt
