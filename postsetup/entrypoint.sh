#!/usr/bin/env bash

set -xe

export BUILDFS=/opt/build
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

# copy static gpg keys
mkdir -p $BUILDFS/etc/apt/trusted.gpg.d
cp $ROOTFS/etc/apt/trusted.gpg.d/* $BUILDFS/etc/apt/trusted.gpg.d

# run multistrap - $ROOTFS will be overwritten!
multistrap \
    --arch $CONF_ARCH \
    --dir $BUILDFS \
    --file /etc/multistrap/multistrap.ini

# copy additional files
cp -R $ROOTFS/. $BUILDFS

# busybox libmusl - just override binary
case "$CONF_ARCH" in
        armel)
            echo "downloading busybox busybox-armv5l"
            wget -O $BUILDFS/bin/busybox https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-armv5l
            ;;
        *)
            # x86 64 default
            echo "downloading busybox-x86_64"
            wget -O $BUILDFS/bin/busybox https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-x86_64
esac

# run post multistrap script hook ?
if [ -x "$BUILDFS/.build/scripts/post-multistrap.sh" ]; then
    echo "hook [post-multistrap]"
    $BUILDFS/.build/scripts/post-multistrap.sh
fi

# arm ? use emulation
if [ "$CONF_ARCH" == "armel" ]; then
    # mount binfmt_misc
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

    # enable support
    update-binfmts --enable

    # copy qemu binaries
    cp /usr/bin/qemu-arm-static $BUILDFS/usr/bin/
fi

# chroot into fs (emulated mode)
echo "chroot into rootfs to execute postinstall actions"
chroot $BUILDFS /bin/bash -c "/.build/postinstall-chroot.sh"

# run post configure script hook ?
if [ -x "$BUILDFS/.build/scripts/post-configure.sh" ]; then
    echo "hook [post-configure]"
    $BUILDFS/.build/scripts/post-configure.sh
fi

# move initramfs
mv $BUILDFS/boot/initramfs.img $BOOTFS/initramfs.img

# move kernel (if exists)
if [ -f $BUILDFS/vmlinuz ]; then
    cp $BUILDFS/vmlinuz $BOOTFS/kernel.img
fi

# create squashfs
mksquashfs $BUILDFS $BOOTFS/system.img \
    -comp lzo \
    -e \
        $BUILDFS/boot \
        $BUILDFS/.build \
        $BUILDFS/etc/initramfs-tools \
        $BUILDFS/usr/bin/qemu-* \
        $BUILDFS/vmlinuz* \
        $BUILDFS/initrd*

# run post build script hook ?
if [ -x "$BUILDFS/.build/scripts/post-build.sh" ]; then
    echo "hook [post-build]"
    $BUILDFS/.build/scripts/post-build.sh
fi
