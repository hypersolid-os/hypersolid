#!/bin/bash

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C

# Fail on Error !
set -e

# get function utilities
source /.build/functions

# run pre configure script hook ?
if [ -x "/.build/scripts/pre-chroot.sh" ]; then
    log_info "hook [pre-chroot]"
    /.build/scripts/pre-chroot.sh
fi

# hotfix - base-passwd not available before base-files
cp /usr/share/base-passwd/passwd.master /etc/passwd
cp /usr/share/base-passwd/group.master /etc/group

# configure packages
log_info "configuring packages.."
dpkg --configure -a && log_success "packages configured"

# generate locales
log_info "generating locales.."
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
log_success "kernel version: $(cat /etc/kernel_version)"

# create initramfs
log_info "creating initramfs.."
mkinitramfs -o /boot/initramfs.cpio -v "$(cat /etc/kernel_version)"

# remove temporary packages
log_info "removing temporary packages.."
dpkg -r --force-depends apt busybox-static initramfs-tools debian-archive-keyring

# set root password
# password hash provided via ENV ?
if [ ! -z "$HYPERSOLID_ROOTPW" ]; then
    log_success "using external root password"
    echo "root:$HYPERSOLID_ROOTPW" | chpasswd -e
else
    log_warning "using default root password"
    echo "root:root" | chpasswd
fi

# external uuid set ?
if [ ! -z "$HYPERSOLID_UUID" ]; then
    log_info "external UUID provided"
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
    log_info "hook [post-chroot]"
    /.build/scripts/post-chroot.sh
fi

# success
log_success "postinstall actions finished"
