Changelog
============================

Branch 1.x
---------------------------

### 1.1.0 ###

* Added: support for derived images (inheritance)
* Added: support for `.d` style setup scripts
* Updated: `bash-functions` to `v0.3.0`

### 1.0.0 ###

* **Stable release**
* Replaced docker based build environment with `systemd-nspawn`
* Refactored the whole build process
* Changed: build directory structure and variable names
* Changed: multistrap configurations are named by the debian release

Preliminary
---------------------------

* Docker isolated build environment