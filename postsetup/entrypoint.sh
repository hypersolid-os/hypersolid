#!/usr/bin/env bash

set -e

export ROOTFS=/home/build/rootfs

# container build ready - attach to interactive bash
if [ -f "/.buildready" ]; then
    # just start bash
    /bin/bash
    exit 0
fi

# create firstrun flag
touch /.buildready

# run post multistrap script hook ?
if [ -x "$ROOTFS/.build/scripts/post-multistrap.sh" ]; then
    echo "hook [post-multistrap]"
    $ROOTFS/.build/scripts/post-multistrap.sh
fi

# mount binfmt_misc
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

# enable support
update-binfmts --enable

# copy qemu binaries
cp /usr/bin/qemu-arm-static /home/build/rootfs/usr/bin/

# chroot into fs (emulated mode)
chroot /home/build/rootfs/ /bin/bash -c "/.build/postinstall-chroot.sh"

# move initramfs
mv /home/build/rootfs/boot/initramfs.img /home/build/boot/initramfs.img

# cleanup setup dir
rm -rf /home/build/rootfs/.build

# cleanup binaries
rm /home/build/rootfs/usr/bin/qemu-*

# create squashfs
mksquashfs /home/build/rootfs /home/build/boot/system.img -comp lzo