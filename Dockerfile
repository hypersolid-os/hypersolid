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
        squashfs-tools gnupg gdisk

# copy build system files
COPY / /

# build directories (mounted tmp dir!)
ENV \
    BASEFS="/" \
    BUILDFS="/opt/build" \
    ROOTFS="/opt/rootfs" \
    BOOTFS="/opt/bootfs"
