Filesystem
=====================

**squashfs+tmpfs+overlayfs**

Features
--------------

* The root-filesystem is an immutable, lzo-compressed, readonly **squashfs** image
* A tmpfs is used as rw layer (no persistent storage!)
* The root-filesystem and tmpfs are merged with **overlayfs**
* A persistent storage can be enabled which mounts an additional partition via overlayfs (above the squashfs)
* Filesystem is initialized via a [init-bottom script](initramfs/scripts/init-bottom/squashfs-tmpfs-overlay) within the initramfs

Persistent Storage
---------------------
