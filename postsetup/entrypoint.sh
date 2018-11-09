#!/usr/bin/env bash

set -e

export ROOTFS=/home/build/rootfs

# container build ready - attach to interactive bash
if [ -f "/.buildready" ]; then
    # just start bash
    /bin/bash
    exit 0
fi

# load config
source $ROOTFS/.build/config

# create firstrun flag
touch /.buildready

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
chroot /home/build/rootfs/ /bin/bash -c "/.build/postinstall-chroot.sh"

# run post configure script hook ?
if [ -x "$ROOTFS/.build/scripts/post-configure.sh" ]; then
    echo "hook [post-configure]"
    $ROOTFS/.build/scripts/post-configure.sh
fi

# move initramfs
mv /home/build/rootfs/boot/initramfs.img /home/build/boot/initramfs.img

# cleanup setup dir
rm -rf /home/build/rootfs/.build

# cleanup binaries
if [ "$CONF_ARCH" == "armel" ]; then
    rm /home/build/rootfs/usr/bin/qemu-*
fi

# create squashfs
mksquashfs /home/build/rootfs /home/build/boot/system.img -comp lzo