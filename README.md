hypersolid
=====================================================

**build a custom debian image with multistrap into a single squasfs-file with tmpfs overlay**

> **NOTE:** this buildsystem is targeted to advanced/professional users with a several years of experience with linux/debian/docker only!
>
> **DO NOT USE THIS SYSTEM/IMAGES AS BEGINNER**

Features
--------------------

* **3 File - full featured - Debian Linux**
* Build a full customized debian image from scratch
* Multistrap based bootstrapping
* rootfs wrapped into single squashfs file
* [Immutable filesystem](docs/filesystem.md) (squashfs base with tmpfs overlay via overlayfs)
* [Persistent storage](docs/filesystem.md#persistent-storage) option (additional overlayfs base)
* Build environment is isolated within a `systemd-nspawn` container
* Minimal system including systemd and networking
* Multiple build hooks to run custom scripts during build process
* Hooks for setup/signing/deployment tasks
* Initramfs creation
* CLI mode (no GUI)

Devices / Use Cases
--------------------

Create highly customizable and fully immutable images for:

* Servers
* Workstations
* Fat-clients / thin-clients
* IoT devices
* Firewall/Networkworking equipment
* Embedded Systems

Target platforms
--------------------

* Generic x86_64 baremetal systems
* Generic x86_64 virtualized maschines (kvm/quemu)
* [Raspberry PI Zero W](docs/raspberry-pi.md)
* [Raspberry PI 3+4](docs/raspberry-pi.md)

Build System Requirements
--------------------

* Debian Linux based Host System
* Host System with enabled `binfmt-support` (for qemu armel emulation)
* Active Internet connection to fetch the packages or local package server
* Recommended: apt-cacher-ng within your network or hostsystem
* `sudo` to run `systemd-nspawn` as user
* `~450MB` disk space for the build system
* `~5GB` disk space for the target system

### Build System Dependencies ###

```bash
apt-get install sudo systemd-container multistrap binfmt-support qemu-user-static 
```

### sudo for systemd-nspawn ###

```bash
# create group with sudo access to systemd-nspawn
groupadd nspawn

# assign group to your build user
usermod -a -G nspawn myBuildUser
```

**File** `/etc/sudoers.d/nspawn`

```
%nspawn ALL=(root) NOPASSWD:/usr/bin/systemd-nspawn
```

Usage
--------------------

Run `hypersolid.sh build <targetdir>`

**Build**

```bash
$ ./hypersolid build targets/raspberrypi-zero-w/
```

How it works
--------------------

1. An isolated debian environment it created in `/tmp/hypersolid-env` via [multistrap](https://wiki.debian.org/Multistrap)
2. The build content (rootfs, scripts, multistrap config) is copied into `/tmp/hypersolid-env/build/*`
3. **STAGE-1** multistrap is invoked within the build-env to build the base system in `<hypersolid-env>/build/target` | systemd-nspawn in `<hypersolid-env>`
4. **STAGE-2** package configuration `dpkg --configure` is executed within the target environment | systemd-nspawn in `<hypersolid-env>/build/target`
5. **STAGE-3** squashfs/cpio images are created and kernel+initramfs are copied into `<hypersolid-env>/build/dist` | systemd-nspawn in `<hypersolid-env>`

### Directories ###

* `/tmp/hypersolid-env` - the isolated build system
* `<hypersolid-env>/build/rootfs` - merged rootfs (hypersolid generic + target)
* `<hypersolid-env>/build/target` - the multistrap chroot containing the final system
* `<hypersolid-env>/build/dist` - output directory including the kernel+initramfs+system image and optional file

License
-------

**hypersolid** is OpenSource and licensed under the Terms of [GNU General Public Licence v2](LICENSE.txt). You're welcome to [contribute](CONTRIBUTE.md)!