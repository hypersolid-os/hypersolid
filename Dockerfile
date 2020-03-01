FROM debian:buster

# READ https://wiki.debian.org/EmDebian/CrossDebootstrap
ENV DEBIAN_FRONTEND=noninteractive

# working dir
WORKDIR /opt

# proxy config
COPY apt-proxy.conf /etc/apt/apt.conf.d/01-proxy.conf

# build-system packages
RUN set -xe \
    && echo "deb http://ftp2.de.debian.org/debian/ buster main contrib non-free" > /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates apt-transport-https \
        mount unzip wget util-linux nano multistrap binfmt-support qemu-user-static \
        squashfs-tools gnupg gdisk \
        debian-keyring debian-archive-keyring

# structure
RUN set -xe \
    && mkdir -p /opt/bootfs \
    && mkdir -p /opt/rootfs

# copy build system files
COPY buildfs/ /

# copy target system files
COPY rootfs/ /opt/rootfs/
COPY bootfs/ /opt/bootfs/
COPY rootfs/.build/entrypoint.sh /entrypoint.sh

# start bash
ENTRYPOINT [ "/bin/bash" , "-c"]
CMD [ "/entrypoint.sh" ]