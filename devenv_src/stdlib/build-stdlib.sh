#!/bin/sh -eux

BASEDIR=/usr/local/src
PREFIX=/usr/local/x86_64-elf
COMMON_CFLAGS="-nostdlibinc -O2 -D__ELF__ -D_LDBL_EQ_DBL -D_GNU_SOURCE -D_POSIX_TIMERS"
CC=clang
CXX=clang++
TARGET_TRIPLE=x86_64-elf

cd $BASEDIR
git clone --depth 1 --branch fix-build https://github.com/uchan-nos/newlib-cygwin.git

cd $BASEDIR
mkdir build_newlib
cd build_newlib
../newlib-cygwin/newlib/configure \
  CC=$CC \
  CC_FOR_BUILD=$CC \
  CFLAGS="-fPIC $COMMON_CFLAGS" \
  --target=$TARGET_TRIPLE --prefix=$PREFIX --disable-multilib --disable-newlib-multithread
make -j 4
make install

cd $BASEDIR
git clone --depth 1 --branch llvmorg-8.0.1 https://github.com/llvm/llvm-project.git

cd $BASEDIR
mkdir build_libcxxabi
cd build_libcxxabi
cmake -G "Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_CXX_FLAGS="-I$PREFIX/include $COMMON_CFLAGS -D_LIBCPP_HAS_NO_THREADS" \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_C_FLAGS="-I$PREFIX/include $COMMON_CFLAGS -D_LIBCPP_HAS_NO_THREADS" \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXXABI_LIBCXX_INCLUDES="$BASEDIR/llvm-project/libcxx/include" \
  -DLIBCXXABI_ENABLE_EXCEPTIONS=False \
  -DLIBCXXABI_ENABLE_THREADS=False \
  -DLIBCXXABI_TARGET_TRIPLE=$TARGET_TRIPLE \
  -DLIBCXXABI_ENABLE_SHARED=False \
  -DLIBCXXABI_ENABLE_STATIC=True \
  $BASEDIR/llvm-project/libcxxabi

make -j4
make install

cd $BASEDIR
mkdir build_libcxx

cmake -G "Unix Makefiles" \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_CXX_FLAGS="-I$PREFIX/include $COMMON_CFLAGS" \
  -DCMAKE_CXX_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_C_COMPILER=$CC \
  -DCMAKE_C_FLAGS="-I$PREFIX/include $COMMON_CFLAGS" \
  -DCMAKE_C_COMPILER_TARGET=$TARGET_TRIPLE \
  -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
  -DCMAKE_BUILD_TYPE=Release \
  -DLIBCXX_CXX_ABI=libcxxabi \
  -DLIBCXX_CXX_ABI_INCLUDE_PATHS="$BASEDIR/llvm-project/libcxxabi/include" \
  -DLIBCXX_CXX_ABI_LIBRARY_PATH="$PREFIX/lib" \
  -DLIBCXX_ENABLE_EXCEPTIONS=False \
  -DLIBCXX_ENABLE_FILESYSTEM=False \
  -DLIBCXX_ENABLE_MONOTONIC_CLOCK=False \
  -DLIBCXX_ENABLE_RTTI=False \
  -DLIBCXX_ENABLE_THREADS=False \
  -DLIBCXX_ENABLE_SHARED=False \
  -DLIBCXX_ENABLE_STATIC=True \
  $BASEDIR/llvm-project/libcxx

make -j4
make install

cd $BASEDIR
wget https://download.savannah.gnu.org/releases/freetype/freetype-2.10.1.tar.gz
tar xf freetype-2.10.1.tar.gz

cd $BASEDIR
mkdir build_freetype
cd build_freetype
../freetype-2.10.1/configure \
  CC=$CC \
  CFLAGS="-fPIC -I$PREFIX/include $COMMON_CFLAGS" \
  --host=$TARGET_TRIPLE --prefix=$PREFIX
make -j 4
make install

rm $PREFIX/lib/libfreetype.la
rm -rf $PREFIX/lib/pkgconfig
rm -rf $PREFIX/share
