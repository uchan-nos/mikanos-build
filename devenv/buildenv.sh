# Usage: source buildenv.sh

BASEDIR="$HOME/osbook/devenv/x86_64-elf"
export CPPFLAGS="-I$BASEDIR/include/c++/v1 -I$BASEDIR/include -I$BASEDIR/include/freetype2 -nostdlibinc -D__ELF__ -D_LDBL_EQ_DBL -D_GNU_SOURCE -D_POSIX_TIMERS"
export LDFLAGS="-L$BASEDIR/lib"
