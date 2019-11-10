#!/usr/bin/env bash

set -xe

# create grub image
mkdir -p /boot/efi/EFI/BOOT

cat <<EOF > /boot/efi/EFI/BOOT/grub.cfg
search.fs_label rootfs root
set prefix=(\$root)'/boot/grub'
configfile \$prefix/grub.cfg
EOF

cat /boot/efi/EFI/BOOT/grub.cfg

grub-mkimage \
    --config /boot/efi/EFI/BOOT/grub.cfg \
    --format x86_64-efi \
    --compress none \
    --prefix /EFI/BOOT \
    --directory /usr/lib/grub/x86_64-efi \
    --output /boot/efi/EFI/BOOT/bootx64.efi \
    fat iso9660 part_gpt normal boot linux configfile loopback chain efifwsetup efi_gop \
    efi_uga ls search search_label search_fs_uuid gfxterm gfxterm_background \
    gfxterm_menu test all_video loadenv nativedisk pata reboot uhci
