#!/bin/sh

# fail on error
set -xe

# mount binfmt_misc
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

# enable support
update-binfmts --enable

# chroot into fs (emulated mode)
chroot /home/build/rootfs/ /bin/bash -c "/.setup/setup.sh"

# move initramfs
mv /home/build/rootfs/boot/initrd.img-* /home/build/boot/initramfs.img