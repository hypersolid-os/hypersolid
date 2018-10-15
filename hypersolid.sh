#!/usr/bin/env bash

# Fail on Error !
set -e

# basedir
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check directory
if [ ! -d "$BASEDIR/$1" ]; then
  echo "target [$1] does not exists!"
  exit 1
fi

# assign target dir
TARGET_DIR=$1

# Check config file
if [ ! -f "$BASEDIR/$1/config" ]; then
  echo "target config [$1] does not exists!"
  exit 1
fi

# read config
source $TARGET_DIR/config

# build image
docker build \
    --build-arg ARCH=$ARCH \
    --build-arg TARGET_DIR=$TARGET_DIR \
    -t hypersolid-build .

# remove old container
docker container rm hypersolid-env

# run postbuild
docker run \
    --privileged \
    --tty \
    --interactive \
    --name hypersolid-env \
    hypersolid-build

# copy files
docker cp hypersolid-env:/home/build/boot tmp/
