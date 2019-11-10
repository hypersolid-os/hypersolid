#!/usr/bin/env bash

set -xe

export ROOTFS=/opt/rootfs
export BOOTFS=/opt/bootfs

# container build ready - attach to interactive bash
if [ -f "/.buildready" ]; then
    # just start bash
    /bin/bash
    exit 0
fi

echo "first container startup - running build"

# load config
source $ROOTFS/.build/config

# create firstrun flag
touch /.buildready

# run multistrap
multistrap \
    --arch $CONF_ARCH \
    --dir /opt/rootfs \
    --file /etc/multistrap/multistrap.ini

# run post multistrap script hook ?
if [ -x "$ROOTFS/.build/scripts/post-multistrap.sh" ]; then
    echo "hook [post-multistrap]"
    $ROOTFS/.build/scripts/post-multistrap.sh
fi

# arm ? use emulation
if [ "$CONF_ARCH" == "armel" ]; then
    # mount binfmt_misc
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

    # enable support
    update-binfmts --enable

    # copy qemu binaries
    cp /usr/bin/qemu-arm-static /home/build/rootfs/usr/bin/
fi

# chroot into fs (emulated mode)
echo "chroot into rootfs to execute postinstall actions"
chroot $ROOTFS /bin/bash -c "/.build/postinstall-chroot.sh"

# run post configure script hook ?
if [ -x "$ROOTFS/.build/scripts/post-configure.sh" ]; then
    echo "hook [post-configure]"
    $ROOTFS/.build/scripts/post-configure.sh
fi

# move initramfs
mv $ROOTFS/boot/initramfs.img $BOOTFS/initramfs.img

# move kernel (if exists)
if [ -f $ROOTFS/vmlinuz ]; then
    cp $ROOTFS/vmlinuz $BOOTFS/kernel.img
fi

# cleanup stock kernel, initramfs
rm $ROOTFS/vmlinuz*
rm $ROOTFS/initrd*
rm $ROOTFS/boot/*

# cleanup setup dir
rm -rf $ROOTFS/.build
rm -rf $ROOTFS/etc/initramfs-tools

# cleanup binaries
if [ "$CONF_ARCH" == "armel" ]; then
    rm $ROOTFS/usr/bin/qemu-*
fi

# create squashfs
mksquashfs $ROOTFS $BOOTFS/system.img -comp lzo