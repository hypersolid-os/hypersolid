#!/bin/bash

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C

# run pre configure script hook ?
if [ -x "/.build/scripts/pre-chroot.sh" ]; then
    echo "hook [pre-chroot]"
    /.build/scripts/pre-chroot.sh
fi

# run dash hook
/var/lib/dpkg/info/dash.preinst install

# configure packages
dpkg --configure -a

# generate locales
locale-gen

# set default target
systemctl set-default multi-user.target

# disable services
systemctl disable console-setup
systemctl disable apt-daily.timer
systemctl disable apt-daily.service

# enable first-boot service
systemctl enable hy-firstboot.service

# remove ssh keys
rm /etc/ssh/ssh_host_*

# run console setup
setupcon --save-only

# get last recent kernel version based on lib/modules
ls -1 /lib/modules | sort -r | head -n1 > /etc/kernel_version

# create initramfs
mkinitramfs -o /boot/initramfs.img -v "$(cat /etc/kernel_version)"

# set root password
echo "root:root" | chpasswd

# run post configure script hook ?
if [ -x "/.build/scripts/post-chroot.sh" ]; then
    echo "hook [post-chroot]"
    /.build/scripts/post-chroot.sh
fi
