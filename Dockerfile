FROM andidittrich/debian-raw:9.4

# READ https://wiki.debian.org/EmDebian/CrossDebootstrap
ENV DEBIAN_FRONTEND=noninteractive

# default arguments
ARG TARGET_DIR=raspberrypi-zero-w
ARG ARCH=amd64

# build-system packages
RUN set -xe \
    && echo "deb http://ftp2.de.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \ 
        ca-certificates mount unzip wget util-linux nano multistrap binfmt-support qemu-user-static apt-transport-https \
        squashfs-tools debian-archive-keyring gnupg

# structure
RUN set -xe \
    && mkdir -p /home/build/boot \
    && mkdir -p /home/build/rootfs \
    && mkdir -p /home/build/target

# copy mutlistrap base config
COPY multistrap/ /etc/multistrap

# copy multistrap target config
COPY ${TARGET_DIR}/multistrap.ini /etc/multistrap/multistrap.ini

# Run multistrap build
RUN set -xe \
    && multistrap \
        --arch ${ARCH} \
        --dir  /home/build/rootfs \
        --file /etc/multistrap/multistrap.ini

# copy additional files to boot partition
COPY ${TARGET_DIR}/bootfs home/build/boot

# copy (additional) rootfs files
COPY rootfs/ /home/build/rootfs
COPY ${TARGET_DIR}/rootfs /home/build/rootfs

# copy postinstall scripts
COPY postsetup/ /home/build/rootfs/.build
COPY postsetup/entrypoint.sh /entrypoint.sh

# copy postinstall scripts
COPY ${TARGET_DIR}/scripts /home/build/rootfs/.build/scripts

# copy initramfs config
COPY initramfs/ /home/build/rootfs/etc/initramfs-tools

# working dir
WORKDIR /home/build

# start bash
ENTRYPOINT [ "/bin/bash" , "-c"]
CMD [ "/entrypoint.sh" ]