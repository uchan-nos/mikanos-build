#!/bin/bash -ex

cd $HOME
if [ ! -d edk2 ]
then
  git clone https://github.com/tianocore/edk2.git
fi

cd edk2

make -C /home/vagrant/edk2/BaseTools/Source/C

source ./edksetup.sh

sed -i '/ACTIVE_PLATFORM/ s:= .*$:= OvmfPkg/OvmfPkgX64.dsc:' Conf/target.txt
sed -i '/TARGET_ARCH/ s:= .*$:= X64:' Conf/target.txt
sed -i '/TOOL_CHAIN_TAG/ s:= .*$:= CLANG38:' Conf/target.txt

sed -i '/CLANG38/ s/-flto//' Conf/tools_def.txt

build
