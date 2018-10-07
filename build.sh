#!/usr/bin/env bash

set -xe

# build image
docker build -t raspberry-build .

# remove old container
docker container rm raspberry-env

# run postbuild
docker run --tty --name raspberry-env --interactive --privileged raspberry-build /home/build/rootfs/.setup/postinstall.sh


# copy files
docker cp raspberry-env:/home/build/ tmp/
