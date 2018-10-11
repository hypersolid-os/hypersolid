hypersolid
=====================================================

**PRELIMINARY VERSION**

**Build a customized, embedded debian os based on raspberry-kernel**

> NOTE: this buildsystem is targeted to advanced/professional users with a several years of experience with linux/debian/docker only!

Feature
--------------------

* Minimal system including systemd and networking
* Debian stretch latest
* Build a full customized debian image from scratch (no raspbian)
* Build environment is isolated within a Docker container
* Multistrap based bootstrapping
* Initramfs creation
* [Official Raspberry Kernel](https://github.com/raspberrypi/firmware) including firmware modules and proprietary stuff
* CLI mode (no GUI)

Devices
--------------------

* Raspberry Zero (W)

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

License
-------

**hypersolid** is OpenSource and licensed under the Terms of [GNU General Public Licence v2](LICENSE.txt). You're welcome to [contribute](CONTRIBUTE.md)!