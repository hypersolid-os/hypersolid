#!/usr/bin/env bash

# Fail on Error !
set -e

# get function utilities
source $ROOTFS/.build/functions

# load config
source $ROOTFS/.build/config

log_info "initial container startup - running build"

# copy static gpg keys
mkdir -p $BUILDFS/etc/apt/trusted.gpg.d $BUILDFS/etc/apt/apt.conf.d
cp $ROOTFS/etc/apt/trusted.gpg.d/* $BUILDFS/etc/apt/trusted.gpg.d

# copy apt proxy config
cp $BASEFS/apt-proxy.conf $BUILDFS/etc/apt/apt.conf.d/01-proxy.conf

log_info "starting multistrap"

# run multistrap - $ROOTFS will be overwritten!
/usr/sbin/multistrap \
    --arch $CONF_ARCH \
    --dir $BUILDFS \
    --file $BASEFS/etc/multistrap/multistrap.ini && {
        log_info "multistrap finished"
    } || {
        panic "multistrap failed"
    }

# copy additional files AFTER multistrap operation (content will be overwritten)
log_info "copying rootfs files.."
cp -RT $ROOTFS $BUILDFS

# cleanup apt config
log_info "removing target apt config"
rm -rf $BUILDFS/etc/apt

# busybox libmusl
# required to enabled full busybox support within initramfs (e.g. DNS,losetup)
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
if [[ "$CONF_ARCH" =~ ^(armel|armhf|arm64)$ ]]; then
    log_info "emulating target arch $CONF_ARCH"

    # mount binfmt_misc
    mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

    # enable support
    update-binfmts --enable

    # copy qemu binaries
    cp /usr/bin/qemu-arm-static $BUILDFS/usr/bin/
fi

# chroot into fs (emulated mode)
log_info "chroot into rootfs to execute postinstall actions"
/usr/sbin/chroot $BUILDFS /bin/bash -c "/.build/postinstall-chroot.sh"

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
log_info "creating squashfs system image (lz4 compressed)"
mksquashfs $BUILDFS $BOOTFS/system.img \
    -comp lz4 -Xhc \
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

# wrap system.img into CPIO
log_info "creating cpio wrapped squashfs image"
echo "system.img" | cpio --quiet -H newc -o --directory=$BOOTFS > $BOOTFS/system.cpio && {
    log_success "cpio wrapped squashfs file created in $BUILDFS $BOOTFS/system.cpio"
} || {
    panic "failed to create cpio wrapped image"
}

# run post build script hook ?
if [ -x "$BUILDFS/.build/scripts/post-build.sh" ]; then
    log_info "hook [post-build]"
    $BUILDFS/.build/scripts/post-build.sh
fi

# cleanup
log_info "removing temporary buildfs"
[ -d $BUILDFS ] && rm -rf $BUILDFS