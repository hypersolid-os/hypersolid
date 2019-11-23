hypersolid
=====================================================

**PRELIMINARY VERSION**

**Build a customized, embedded debian os**

> **NOTE:** this buildsystem is targeted to advanced/professional users with a several years of experience with linux/debian/docker only!
>
> **DO NOT USE THIS SYSTEM/IMAGES AS BEGINNER**

Feature
--------------------

* 3 File - full featured - embedded Debian Linux (live system)
* Build a full customized debian image from scratch
* Multistrap based bootstrapping
* [Immutable filesystem](docs/filesystem.md) (squashfs base with tmpfs overlay via overlayfs)
* [Persistent storage](docs/filesystem.md#persistent-storage) option (additional overlayfs base)
* Build environment is isolated within a [Docker container](Dockerfile)
* Minimal system including systemd and networking
* Initramfs creation
* CLI mode (no GUI)

Target platforms
--------------------

* servers/hostsystems
* embedded systems

Tested Devices
--------------------

* Generic x86_64 baremetal systems
* Generic x86_64 virtualized maschines (kvm/quemu)
* [Raspberry PI Zero W](docs/raspberry-pi.md)

Build Requirements
--------------------

* Linux based Host System
* Host System with running Docker daemon
* Host System with enabled `binfmt-support` (for qemu armel emulation)
* Active Internet connection to fetch the packages or local package server

Usage
--------------------

Run `hypersolid.sh <targetdir>`

**Build**

```bash
$ ./hypersolid targets/raspberrypi-zero-w/
```

How it works
--------------------

1. hypersolid builds a docker container named `hypersolid-build` which isolates the build process from the host systems
2. the rootfs (default files) as well as the target file are merged within a temp dir
3. the temp dir content is copied into the docker build context
4. [multistrap](https://wiki.debian.org/Multistrap) is invoked within the container to build the base system `/opt/build`
5. a custom [initramfs](https://wiki.gentoo.org/wiki/Custom_Initramfs) is created which spawns the transparent, tmpfs based overlay
6. the root-file-system is stored within a compressed [squashfs](https://wiki.gentoo.org/wiki/SquashFS) image
7. the kernel image, squashfs image + initramfs image are copied into the `dist/` dir of the build system

License
-------

**hypersolid** is OpenSource and licensed under the Terms of [GNU General Public Licence v2](LICENSE.txt). You're welcome to [contribute](CONTRIBUTE.md)!