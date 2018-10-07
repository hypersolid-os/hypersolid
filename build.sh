#!/usr/bin/env bash

set -xe

# build image
docker build -t raspberry-build .

# remove old container
docker container rm raspberry-env

# create container
docker create --tty --name raspberry-env --interactive --privileged raspberry-build

# copy files
#docker cp raspberry-env:/home/build/ tmp/
