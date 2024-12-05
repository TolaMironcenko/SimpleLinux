#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/zlib.sh

dropbear() {
    if [ ! -d $build/zlib ]; then
        zlib
    fi
    printf "$GREEN** Building and installing dropbear\n$RESET"
    mkdir $build/dropbear
    cd $build/dropbear
    tar -xvf $root/downloads/DROPBEAR_2024.86.tar.gz
    check $? "Extract dropbear"
    cd dropbear-DROPBEAR_2024.86
    ./configure  \
        --prefix=/usr \
        --host=$CROSS_COMPILE \
        --with-zlib=$build/rootfs
    # CC=${CROSS_COMPILE}gcc ./configure --prefix=/usr --shared
    check $? "Configure dropbear"
    make $makeflags
    check $? "Build dropbear"
    make DESTDIR=$rootfspath install
    check $? "Installing to rootfs dropbear"
    rm -rv $rootfspath/usr/include $rootfspath/usr/share/man $rootfspath/usr/lib/{pkgconfig,libz.a}
    ${CROSS_COMPILE}-strip --strip-unneeded $rootfspath/usr/bin/*
    mkdir -pv $build/rootfs/etc/dropbear
    # check $? "Installing to rootfs zlib"
}
