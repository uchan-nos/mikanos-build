#!/bin/sh -ex

if [ $# -lt 3 ]
then
    echo "Usage: $0 <image name> <mount point> <.efi file> [another file]"
    exit 1
fi

DEVENV_DIR=$(dirname "$0")
DISK_IMG=$1
MOUNT_POINT=$2
EFI_FILE=$3
ANOTHER_FILE=$4

if [ ! -f $EFI_FILE ]
then
    echo "No such file: $EFI_FILE"
    exit 1
fi

rm -f $DISK_IMG
qemu-img create -f raw $DISK_IMG 200M
mkfs.fat -n 'MIKAN OS' -s 2 -f 2 -R 32 -F 32 $DISK_IMG

$DEVENV_DIR/mount_image.sh $DISK_IMG $MOUNT_POINT
if [ `uname` = 'Darwin' ]; then
    mkdir -p $MOUNT_POINT/EFI/BOOT
    cp $EFI_FILE $MOUNT_POINT/EFI/BOOT/BOOTX64.EFI
else
    sudo mkdir -p $MOUNT_POINT/EFI/BOOT
    sudo cp $EFI_FILE $MOUNT_POINT/EFI/BOOT/BOOTX64.EFI
fi
if [ "$ANOTHER_FILE" != "" ]
then
    if [ `uname` = 'Darwin' ]; then
        cp $ANOTHER_FILE $MOUNT_POINT/
    else
        sudo cp $ANOTHER_FILE $MOUNT_POINT/
    fi
fi
sleep 0.5
if [ `uname` = 'Darwin' ]; then
    hdiutil detach $MOUNT_POINT
else
    sudo umount $MOUNT_POINT
fi
