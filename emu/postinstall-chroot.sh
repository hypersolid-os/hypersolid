#!/bin/bash

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C

# run dash hook
/var/lib/dpkg/info/dash.preinst install

# configure packages
dpkg --configure -a

# disable services
systemctl disable systemd-timesyncd
systemctl disable console-setup

# run console setup
setupcon --save-only

# create initramfs
update-initramfs -k "$(cat /etc/raspberry_kernel)" -c -v

# set root password
echo "root:root" | chpasswd