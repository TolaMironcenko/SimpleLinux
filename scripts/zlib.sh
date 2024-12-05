#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh

zlib() {
    printf "$GREEN** Building and installing zlib\n$RESET"
    mkdir $build/zlib
    cd $build/zlib
    tar -xvf $root/downloads/zlib-1.3.1.tar.gz
    check $? "Extract zlib"
    cd zlib-1.3.1
    CC=${CROSS_COMPILE}-gcc ./configure --prefix=/usr --shared
    check $? "Configure zlib"
    make $makeflags
    check $? "Build zlib"
    make DESTDIR=$rootfspath install
    rm -rv $rootfspath/usr/include $rootfspath/usr/share/man $rootfspath/usr/lib/{pkgconfig,libz.a}
    ${CROSS_COMPILE}-strip --strip-unneeded $rootfspath/usr/lib/libz.so.1.3.1
    check $? "Installing to rootfs zlib"
}
