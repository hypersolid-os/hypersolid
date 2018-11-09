#!/usr/bin/env bash

set -xe

# create grub image
mkdir -p /boot/efi/EFI/BOOT

grub-mkimage \
    --format x86_64-efi \
    --compress none \
    --prefix /EFI/BOOT \
    --directory /usr/lib/grub/x86_64-efi \
    --output /boot/efi/EFI/BOOT/bootx64.efi \
    fat iso9660 part_gpt part_msdos normal boot linux configfile loopback chain efifwsetup efi_gop \
    efi_uga ls search search_label search_fs_uuid search_fs_file gfxterm gfxterm_background \
    gfxterm_menu test all_video loadenv