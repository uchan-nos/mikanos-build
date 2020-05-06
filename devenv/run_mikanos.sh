#!/bin/sh -ex

DEVENV_DIR=$(dirname "$0")
DISK_IMG=./disk.img

DISK_IMG=$DISK_IMG $DEVENV_DIR/make_mikanos_image.sh
$DEVENV_DIR/run_image.sh $DISK_IMG
