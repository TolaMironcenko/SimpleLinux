#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/busybox.sh
. ./scripts/uclibc.sh
. ./scripts/kernel.sh
. ./scripts/zlib.sh
. ./scripts/dropbear.sh
. ./scripts/sftp_server.sh

#----------- Building rootfs ----------------------
rootfs() {
    printf "$UGREEN** Building rootfs\n$RESET"
    rm -rv $rootfspath # &>> $fulllogfile
    mkdir -pv $rootfspath # &>> $fulllogfile
    cd $rootfspath
    mkdir -pv $(cat $rootfsfile) # &>> $fulllogfile
    ln -sv usr/lib lib # &>> $fulllogfile
    ln -sv usr/lib lib32 # &>> $fulllogfile
    ln -sv usr/bin bin # &>> $fulllogfile
    ln -sv usr/bin sbin # &>> $fulllogfile
    ln -sv var/run run
    cd usr
    ln -sv bin sbin # &>> $fulllogfile
    ln -sv lib lib32 # &>> $fulllogfile
    ln -sv bin libexec
    cd ..
    tar -xvf $root/downloads/initscripts-0.0.1-orangepi-pc.tar.gz
    cp -rv initscripts-0.0.1-orangepi-pc/* .
    rm -rv initscripts-0.0.1-orangepi-pc
    ln -sv /proc/mounts etc/mtab # &>> $fulllogfile

    busybox_rootfs
    cp -v $build/busybox/busybox-1.36.1/busybox $rootfspath/usr/bin # &>> $fulllogfile
    cd $rootfspath/usr/bin
    for i in $(cat $root/busybox/busybox_list); do ln -sv busybox $i; done
    cp -v $root/rootfs/init.in $rootfspath/init
    uclibc
    kernel
    kernel_modules
    if [ "$ZLIB_ENABLE" = "true" ]; then
        zlib
    fi
    if [ "$DROPBEAR_ENABLE" = "true" ]; then
        dropbear
    fi
    if [ "$sftp_server_enable" = "true" ]; then
        sftp_server
    fi

    chmod 640 $rootfspath/etc/shadow $rootfspath/etc/inittab
    chmod 755 $rootfspath/etc/init.d/* $rootfspath/usr/share/udhcpc/default.script $rootfspath/init
    chmod 644 $rootfspath/etc/{passwd,group,hostname,hosts,fstab,shells,issue} $rootfspath/etc/network/interfaces

    check $? "Build rootfs"
} # rootfs
#--------------------------------------------------
