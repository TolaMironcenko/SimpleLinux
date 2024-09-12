#!/bin/bash

#------------ glibc ----------------------------------------
glibc() {
    printf "$UGREEN** Building glibc\n$RESET"
    mkdir -p $build/glibc &>> $fulllogfile
    cd $build/glibc
    tar -xvf $root/downloads/glibc-2.39.tar.xz &>> $fulllogfile
    check $? "Extract glibc"
    cd glibc-2.39
    mkdir build
    cd build
    echo "rootsbindir=/usr/bin" > configparms
    ../configure \
        --prefix=/usr \
        --disable-werror \
        --enable-kernel=4.19 \
        --enable-stack-protector=strong \
        --disable-nscd \
        libc_cv_slibdir=/usr/lib &>> $fulllogfile
    check $? "Configure glibc"
    make $makeflags &>> $fulllogfile
    check $? "Build glibc"
    make DESTDIR=$rootfspath install &>> $fulllogfile
    check $? "Install glibc to rootfs"
    cd $rootfspath
    find -name \*.a -delete &>> $fulllogfile
    strip --strip-unneeded $rootfspath/usr/lib/* $rootfspath/usr/bin/* &>> $fulllogfile
    chroot $rootfspath /bin/sh -c "mkdir -p /usr/lib/locale;localedef -i C -f UTF-8 C.UTF-8;localedef -i en_US -f UTF-8 en_US.UTF-8;localedef -i ru_RU -f UTF-8 ru_RU-UTF-8;"
    cd $root
    check $? "Build and install glibc"
}
#-----------------------------------------------------------
