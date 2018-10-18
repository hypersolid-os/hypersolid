hypersolid
=====================================================

**PRELIMINARY VERSION**

**Build a customized, embedded debian os**

> NOTE: this buildsystem is targeted to advanced/professional users with a several years of experience with linux/debian/docker only!

Feature
--------------------

* Build a full customized debian image from scratch
* Multistrap based bootstrapping
* [Immutable filesystem](docs/filesystem.md) (squashfs base with tmpfs overlay via overlayfs)
* [Persistent storage](docs/filesystem.md#persistent-storage) option (additional overlayfs base)
* Build environment is isolated within a [Docker container](Dockerfile)
* Minimal system including systemd and networking
* Initramfs creation
* CLI mode (no GUI)

Tested Devices
--------------------

* [Raspberry PI Zero W](docs/raspberry-pi.md)

Build Requirements
--------------------

* Linux based Host System
* Host System with running Docker daemon
* Host System with enabled `binfmt-support` (qemu armel emulation)
* Active Internet connection to fetch the packages

Usage
--------------------

Run `hypersolid.sh <targetdir>`

**Build**

```bash
$ ./hypersolid.sh targets/raspberrypi-zero-w/
```

How it works
--------------------

1. hypersolid builds a docker container named `hypersolid-build` which isolated the build process from the host systems
2. docker container based on a standard debian image


License
-------

**hypersolid** is OpenSource and licensed under the Terms of [GNU General Public Licence v2](LICENSE.txt). You're welcome to [contribute](CONTRIBUTE.md)!