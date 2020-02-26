#!/bin/sh

dd if=build-edk2.sh | vagrant ssh -c 'dd of=build-edk2.sh; chmod +x build-edk2.sh; ./build-edk2.sh'
