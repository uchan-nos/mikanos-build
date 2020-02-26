#!/bin/sh -ex

if [ $# -lt 2 ]
then
    echo "Usage: $0 <image name> <mount point>"
    exit 1
fi

DEVENV_DIR=$(dirname "$0")
DISK_IMG=$1
MOUNT_POINT=$2

if [ ! -f $DISK_IMG ]
then
    echo "No such file: $DISK_IMG"
    exit 1
fi

mkdir -p $MOUNT_POINT
sudo mount -o loop $DISK_IMG $MOUNT_POINT
