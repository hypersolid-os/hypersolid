#!/usr/bin/env bash

set -x

export BUILDFS=/opt/build
export ROOTFS=/opt/rootfs
export BOOTFS=/opt/bootfs

# container build ready - attach to interactive bash
if [ -f "/.buildready" ]; then
    # just start bash
    /bin/bash
    exit 0
fi

# get function utilities
source $ROOTFS/.build/functions

# load config
source $ROOTFS/.build/config

log_info "initial container startup - running build"

# create firstrun flag
touch /.buildready

# copy static gpg keys
mkdir -p $BUILDFS/etc/apt/trusted.gpg.d
cp $ROOTFS/etc/apt/trusted.gpg.d/* $BUILDFS/etc/apt/trusted.gpg.d

# run multistrap - $ROOTFS will be overwritten!
multistrap \
    --arch $CONF_ARCH \
    --dir $BUILDFS \
    --file /etc/multistrap/multistrap.ini || {
        panic "multistrap failed"
    }

# copy additional files
cp -R $ROOTFS/. $BUILDFS

# busybox libmusl - just override binary
# required to enabled full busybox support within initramfs (e.g. DNS)
BUSYBOX_BIN=
case "$CONF_ARCH" in
    armel)
        BUSYBOX_BIN="busybox-armv5l"
        ;;
    armhf)
        BUSYBOX_BIN="busybox-armv7l"
        ;;
    arm64)
        BUSYBOX_BIN="busybox-armv8l"
        ;;
    *)
        # x86 64 default
        BUSYBOX_BIN="busybox-x86_64"
esac

log_info "downloading ${BUSYBOX_BIN}" 

# trigger download
wget -O $BUILDFS/bin/busybox https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/${BUSYBOX_BIN} && {
    log_success "done"
} || {
    panic "download failed"
}

# run post multistrap script hook ?
if [ -x "$BUILDFS/.build/scripts/post-multistrap.sh" ]; then
    log_info "hook [post-multistrap]"
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
log_info "chroot into rootfs to execute postinstall actions"
chroot $BUILDFS /bin/bash -c "/.build/postinstall-chroot.sh"

# run post configure script hook ?
if [ -x "$BUILDFS/.build/scripts/post-configure.sh" ]; then
    log_info "hook [post-configure]"
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
        $BUILDFS/initrd* \
&& {
    log_success "squashfs file created in $BUILDFS $BOOTFS/system.img"
} || {
    panic "failed to create squashfs image"
}

# run post build script hook ?
if [ -x "$BUILDFS/.build/scripts/post-build.sh" ]; then
    log_info "hook [post-build]"
    $BUILDFS/.build/scripts/post-build.sh
fi
