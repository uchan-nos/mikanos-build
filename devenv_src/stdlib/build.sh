#!/bin/sh -eu

exe() {
    echo "$@"
    "$@"
}

echo "==========================================="
echo "Preparing build environment."
echo "==========================================="
IIDFILE=./docker-image-id
exe docker build --iidfile="${IIDFILE}" --tag stdlib-builder .
IID=$(cat ${IIDFILE})
exe rm ${IIDFILE}

echo "==========================================="
echo "Building standard libraries."
echo "==========================================="
CIDFILE=./docker-container-id
exe docker run --cidfile="${CIDFILE}" ${IID}
CID=$(cat ${CIDFILE})
exe rm ${CIDFILE}

echo "==========================================="
echo "Copying standard libraries."
echo "==========================================="
exe docker cp ${CID}:/usr/local/x86_64-elf ${HOME}/osbook/devenv

SRC=/usr/local/src
DST=${HOME}/osbook/devenv/x86_64-elf
exe docker cp ${CID}:${SRC}/newlib-cygwin/COPYING.NEWLIB ${DST}/LICENSE.newlib
exe docker cp ${CID}:${SRC}/llvm-project/libcxx/LICENSE.TXT ${DST}/LICENSE.libcxx
exe docker cp ${CID}:${SRC}/freetype-2.10.1/docs/FTL.TXT ${DST}/LICENSE.freetype

echo ""
echo "Done. Standard libraries at ${HOME}/osbook/devenv/x86_64-elf"
