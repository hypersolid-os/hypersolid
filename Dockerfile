FROM andidittrich/debian-raw:9.4

# READ https://wiki.debian.org/EmDebian/CrossDebootstrap

ARG RASPBERRY_KERNEL_VERSION=4.14.70+
ARG RASPBERRY_FIRMWARE_RELEASE=1.20180919

ENV DEBIAN_FRONTEND=noninteractive

# build-system packages
RUN set -xe \
    && echo "deb http://ftp2.de.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \ 
        ca-certificates mount unzip wget util-linux nano multistrap binfmt-support qemu-user-static apt-transport-https lzop

# structure
RUN set -xe \
    && mkdir -p /home/build/boot \
    && mkdir -p /home/build/rootfs

# copy mutlistrap config
COPY multistrap/ /etc/multistrap

# Run multistrap build
RUN set -xe \
    && cat /etc/multistrap/multistrap.ini \
    && multistrap \
        -a armel \
        -d /home/build/rootfs \
        -f /etc/multistrap/multistrap.ini \
    && du -sh /home/build/rootfs \
    && cp /usr/bin/qemu-arm-static /home/build/rootfs/usr/bin/

# get kernel + precompiled modules/firmware
RUN set -xe \
    && mkdir -p /home/build/rootfs/lib/modules \
    && wget -O /tmp/raspberry-firmware.zip https://github.com/raspberrypi/firmware/archive/${RASPBERRY_FIRMWARE_RELEASE}.zip \
    && unzip /tmp/raspberry-firmware.zip -d /tmp \
    && cp -r /tmp/firmware-${RASPBERRY_FIRMWARE_RELEASE}/boot/* /home/build/boot \
    && cp -R /tmp/firmware-${RASPBERRY_FIRMWARE_RELEASE}/modules/* /home/build/rootfs/lib/modules \
    && echo "${RASPBERRY_KERNEL_VERSION}" > /home/build/rootfs/etc/raspberry_kernel

# download nonfree firmware (wifi..)
RUN set -xe \
    && mkdir -p /home/build/rootfs/lib/firmware/brcm \
    && cd /home/build/rootfs/lib/firmware/brcm \
    && wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.bin \
    && wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.txt

# copy additional files (raspberry boot config)
COPY rpi-bootconfig/ home/build/boot

# copy (additional) rootfs files
COPY rootfs/ /home/build/rootfs

# copy postinstall scripts
COPY postinstall/ /home/build/rootfs/.setup

# copy initramfs config
COPY initramfs/ /home/build/rootfs/etc/initramfs-tools

# working dir
WORKDIR /home/build

# start bash
ENTRYPOINT [ "/bin/bash" ]