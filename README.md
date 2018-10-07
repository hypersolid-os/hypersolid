DEBIAN Imgae Builder for RaspberryPI (armel)
==============================================

**Build a customized, embedded debian os based on raspberry-kernel**

> NOTE: this buildsystem is targeted to advanced/professional users with a several years of experience with linux/debian/docker only!

Feature
--------------------

* Debian stretch latest
* Build a full customized debian image from scratch (no raspbian)
* Build environment is isolated within a Docker container
* Multistrap based bootstrapping
* Initramfs creation
* [Official Raspberry Kernel](https://github.com/raspberrypi/firmware) including firmware modules and proprietary stuff
* CLI mode (no GUI)

Proprietary Packages
--------------------

* https://github.com/raspberrypi/firmware
* https://github.com/RPi-Distro/firmware-nonfree

Requirements
--------------------

* Linux based Host System
* Host System with running Docker daemon
* Host System with enabled `binfmt-support` (qemu armel emulation)
* Active Internet connection to fetch the packages

Usage
--------------------

1. run 