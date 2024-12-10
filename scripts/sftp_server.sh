#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/dropbear.sh

sftp_server() {
    if [ ! -d $build/zlib ]; then
        zlib
    fi
    if [ ! -d $build/dropbear ]; then
        dropbear
    fi
    printf "$UGREEN** Building sftp-server\n$RESET"
    mkdir -p $build/sftp_server # &>> $fulllogfile
    cd $build/sftp_server
    tar -xvf $root/downloads/openssh-9.9p1.tar.gz # &>> $fulllogfile
    check $? "Extract openssh"
    cd openssh-9.9p1
    ./configure \
        --prefix=/usr \
        --host=arm-buildroot-linux-uclibcgnueabihf \
        --without-openssl \
        --with-zlib=$rootfspath
    check $? "Configure openssh"
    make sftp-server $makeflags # &>> $fulllogfile
    check $? "Build sftp-server"
    cp -v sftp-server $rootfspath/usr/bin/
    $CROSS_COMPILE-strip $rootfspath/usr/bin/sftp-server
    check $? "Install sftp-server to rootfs directory"
    check $? "Build and install sftp-server to rootfs directory"
}
