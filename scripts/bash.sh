#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh

bash() {
    printf "$GREEN** Building and installing bash\n$RESET"
    mkdir $build/bash
    cd $build/bash
    tar -xvf $root/downloads/bash-5.2.32.tar.gz
    check $? "Extract bash"
    cd bash-5.2.32
    ./configure \
        --prefix=/usr \
        --host=$CROSS_COMPILE
    check $? "Configure bash"
    make $makeflags
    check $? "Build bash"
    cp -v bash $rootfspath/usr/bin
    $CROSS_COMPILE-strip --strip-unneeded $rootfspath/usr/bin/bash
    check $? "Installing to rootfs bash"
}
