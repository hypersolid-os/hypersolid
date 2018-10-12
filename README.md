hypersolid
=====================================================

**PRELIMINARY VERSION**

**Build a customized, embedded debian os based on raspberry-kernel**

> NOTE: this buildsystem is targeted to advanced/professional users with a several years of experience with linux/debian/docker only!

Feature
--------------------

* Build a full customized debian image from scratch
* Multistrap based bootstrapping
* [Immutable filesystem](docs/filesystem.md) (squashfs base with tmpfs overlay via overlayfs)
* [Persistent storage](docs/filesystem.md) option (additional overlayfs base)
* Build environment is isolated within a [Docker container](Dockerfile)
* Minimal system including systemd and networking
* Initramfs creation
* CLI mode (no GUI)

Tested Devices
--------------------

* [Raspberry PI](docs/raspberry-pi.md) Zero W

Build Requirements
--------------------

* Linux based Host System
* Host System with running Docker daemon
* Host System with enabled `binfmt-support` (qemu armel emulation)
* Active Internet connection to fetch the packages

Usage
--------------------


License
-------

**hypersolid** is OpenSource and licensed under the Terms of [GNU General Public Licence v2](LICENSE.txt). You're welcome to [contribute](CONTRIBUTE.md)!