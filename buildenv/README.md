hypersolid build environment
===============================

These files are related to the **isolated** build environment.

`multistrap` is used to create a minimal (~500MB) system including all dependencies to build hypersolid images.

hypersolid uses `systemd-nspawn` to start the build process within the created rootfs.

How it works
-----------------------

1. `create-hypersolid-env` is invoked by `hypersolid::prepare` routine
2. `multistrap` is invoked as **!!current user!!** using `multistrap.ini`
3. The rootfs is created in `/tmp/hypersolid-env`
4. Finally `dpkg --configure -a` is executed via `systemd-nspawn`

Each hypersolid build task re-uses the directory `/tmp/hypersolid-env/build` (cleanup after build)


