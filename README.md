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

1. A temporary build context for the docker container is created (merge rootfs, configs)
2. hypersolid builds a docker container named `hypersolid-build` which isolates the build process from the host systems
3. the temp dir content is copied into the docker build context
4. [multistrap](https://wiki.debian.org/Multistrap) is invoked within the container to build the base system `/opt/build` (via `entrypoint.sh`)
5. a custom [initramfs](https://wiki.gentoo.org/wiki/Custom_Initramfs) is created which spawns the transparent, tmpfs based overlay
6. the root-file-system is stored within a compressed [squashfs](https://wiki.gentoo.org/wiki/SquashFS) image
7. the kernel image, squashfs image + initramfs image are copied into the `dist/` dir of the build system

Buildsystem
--------------------

### Docker build context ###

A temporary directory is automatically created which holds the full build context to build the docker image:

**Directories**

* `/tmp/[tmpdir]/rootfs` includes the basic rootfs of hypersolid and the customized target rootfs (overwrite) provided via `<target_dir>/rootfs`
* `/tmp/[tmpdir]/buildfs` - additional files required for the isolated build environment/docker container (e.g. multistrap configuration); directly copied into container root
* `/tmp/[tmpdir]/bootfs` - output directory including the kernel+initramfs+system image and optional files provided via `<target_dir>/bootfs`

This layout (file merge) is created by the `hypersolid` script

### Docker container directories ###

The build context is copied into the following directories:

* `/` (from `/tmp/[tmpdir]/buildfs`) - build configuration
* `/opt/rootfs` (from `/tmp/[tmpdir]/rootfs`) - merged rootfs (hypersolid generic + target)
* `/opt/build` - the multistrap chroot containing the final system
* `/opt/bootfs` - output directory

License
-------

**hypersolid** is OpenSource and licensed under the Terms of [GNU General Public Licence v2](LICENSE.txt). You're welcome to [contribute](CONTRIBUTE.md)!