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
systemctl enable hypersolid-firstboot.service

# remove ssh keys
rm /etc/ssh/ssh_host_*

# run console setup
setupcon --save-only

# get last recent kernel version based on lib/modules
ls -1 /lib/modules | sort -r | head -n1 > /etc/kernel_version

# print info
echo "kernel version: $(cat /etc/kernel_version)"

# create initramfs
mkinitramfs -o /boot/initramfs.img -v "$(cat /etc/kernel_version)"

# remove temporary packages
dpkg -r --force-depends apt busybox-static initramfs-tools debian-archive-keyring

# set root password
# password hash provided via ENV ?
if [ ! -z "$HYPERSOLID_ROOTPW" ]; then
    echo "root:$HYPERSOLID_ROOTPW" | chpasswd -e
else
    echo "root:root" | chpasswd
fi

# external uuid set ?
if [ ! -z "$HYPERSOLID_UUID" ]; then
    echo "$HYPERSOLID_UUID" > /etc/hypersolid_uuid

    # add to prelogin issue message
    echo -e ">> hypersolid [$HYPERSOLID_UUID]\nDebian GNU/Linux on \l\n" > /etc/issue
fi

# set hypersolid build info
cat > "/etc/hypersolid_build" <<- EOF
$HYPERSOLID_NAME
$(date)
EOF

# run post configure script hook ?
if [ -x "/.build/scripts/post-chroot.sh" ]; then
    echo "hook [post-chroot]"
    /.build/scripts/post-chroot.sh
fi
