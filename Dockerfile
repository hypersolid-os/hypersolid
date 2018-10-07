FROM andidittrich/debian-raw:9.4

# READ https://wiki.debian.org/EmDebian/CrossDebootstrap

ARG RASPBERRY_KERNEL_VERSION=4.14.70+

ENV DEBIAN_FRONTEND=noninteractive

# build-system packages
RUN set -xe \
    && echo "deb http://ftp2.de.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \ 
        ca-certificates mount unzip wget util-linux nano multistrap binfmt-support qemu-user-static apt-transport-https

# copy firmware
COPY assets/firmware.zip /tmp/raspberry-firmware

# firmware unzip
RUN set -xe \
    && mkdir -p /home/build/boot \
    && unzip /tmp/raspberry-firmware -d /home/build \
    && cp -r /home/build/firmware-1.20180919/boot/* /home/build/boot

# copy additional files (raspberry boot config)
COPY bootconfig/ home/build/boot

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

# copy modules
RUN set -xe \
    && cp -R /home/build/firmware-1.20180919/modules /home/build/rootfs/lib/modules \
    && echo "${RASPBERRY_KERNEL_VERSION}" > /home/build/rootfs/etc/raspberry_kernel

# copy addtional rootfs files
COPY rootfs/ /home/build/rootfs

# copy scripts
COPY emu/ /home/build/rootfs/.setup

# download nonfree firmware (wifi..)
RUN set -xe \
    && mkdir -p /home/build/rootfs/lib/firmware/brcm \
    && cd /home/build/rootfs/lib/firmware/brcm \
    && wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.bin \
    && wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.txt

# working dir
WORKDIR /home/build

# start bash
ENTRYPOINT [ "/bin/bash" ]