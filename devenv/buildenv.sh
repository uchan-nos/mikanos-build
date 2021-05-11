# Usage: source buildenv.sh

BASEDIR="$HOME/osbook/devenv/x86_64-elf"
EDK2DIR="$HOME/edk2"

if [ ! -d $BASEDIR ]
then
    echo "$BASEDIR が存在しません."
    echo "以下のファイルを手動でダウンロードし，$HOME/osbook/devenv/に展開してください．"
    echo "https://github.com/uchan-nos/mikanos-build/releases/download/v2.0/x86_64-elf.tar.gz "
else
    export CPPFLAGS="\
    -I$BASEDIR/include/c++/v1 -I$BASEDIR/include -I$BASEDIR/include/freetype2 \
    -I$EDK2DIR/MdePkg/Include -I$EDK2DIR/MdePkg/Include/X64 \
    -nostdlibinc -D__ELF__ -D_LDBL_EQ_DBL -D_GNU_SOURCE -D_POSIX_TIMERS \
    -DEFIAPI='__attribute__((ms_abi))'"
    export LDFLAGS="-L$BASEDIR/lib"
fi