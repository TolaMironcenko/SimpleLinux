#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh

#------------ glibc ----------------------------------------
uclibc() {
    printf "$UGREEN** Building uclibc\n$RESET"
    mkdir -p $build/uclibc # &>> $fulllogfile
    cd $build/uclibc
    tar -xvf $root/downloads/uClibc-ng-1.0.50.tar.xz # &>> $fulllogfile
    check $? "Extract uclibc"
    cd uClibc-ng-1.0.50
    cp -rv $root/uclibc/config-1.0.50 .config
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE- oldconfig
    check $? "Configure uclibc"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE- $makeflags # &>> $fulllogfile
    check $? "Build uclibc"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE- DESTDIR=$rootfspath install # &>> $fulllogfile
    check $? "Install uclibc to rootfs"
    cd $rootfspath
    find -name \*.a -delete # &>> $fulllogfile
    find -name \*.o -delete
    rm -v $rootfspath/usr/lib/libc.so
    ${CROSS_COMPILE}-strip --strip-unneeded $rootfspath/usr/lib/* $rootfspath/usr/bin/* # &>> $fulllogfile
    rm -rv $rootfspath/usr/include
    cd $root
    check $? "Build and install uclibc"
}
#-----------------------------------------------------------