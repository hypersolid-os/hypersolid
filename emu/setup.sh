#!/bin/sh

export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
export LC_ALL=C LANGUAGE=C LANG=C

# run dash hook
/var/lib/dpkg/info/dash.preinst install

# configure packages
dpkg --configure -a

# create initramfs
update-initramfs -k 4.14.70+ -c -v