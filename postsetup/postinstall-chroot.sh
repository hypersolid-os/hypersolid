#!/bin/bash

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C

# run dash hook
/var/lib/dpkg/info/dash.preinst install

# configure packages
dpkg --configure -a

# set default target
systemctl set-default multi-user.target

# disable services
systemctl disable console-setup
systemctl disable apt-daily.timer
systemctl disable apt-daily.service

# systemctl disable systemd-timesyncd

# run console setup
setupcon --save-only

# get last recent kernel version based on lib/modules
ls -1 /lib/modules | sort -r | head -n1 > /etc/kernel_version

# create initramfs
mkinitramfs -o /boot/initramfs.img -v "$(cat /etc/kernel_version)"

#update-initramfs -k "all" -c -v

# set root password
echo "root:root" | chpasswd