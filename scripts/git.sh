#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/curl.sh

git() {
    if [ ! -d $build/curl ]; then
        curl
    fi
    printf "$GREEN** Building and installing git\n$RESET"
    mkdir $build/git
    cd $build/git
    tar -xvf $root/downloads/git-2.46.0.tar.xz
    check $? "Extract git"
    cd git-2.46.0
    ./configure \
        --prefix=/usr \
        --host=$CROSS_COMPILE \
        NO_ICONV=true \
        ac_cv_fread_reads_directories=true \
        ac_cv_snprintf_returns_bogus=false
    check $? "Configure git"
    make $makeflags
    check $? "Build git"
    make DESTDIR=$rootfspath install
    $CROSS_COMPILE-strip --strip-unneeded $rootfspath/usr/bin/* $rootfspath/libexec/git-core/*
    printf "$GREEN** SUCCESS: Building and installing git\n$RESET"
}
