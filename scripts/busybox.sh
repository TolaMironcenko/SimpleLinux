#!/bin/sh

#--- import rolors ---
. ./scripts/colors.sh
#---------------------
#--- import funcs ----
. ./scripts/funcs.sh
#---------------------
. ./scripts/config.sh

#----------- Building busybox for rootfs ----------
busybox_rootfs() {
    printf "$UGREEN** Building busybox for rootfs\n$RESET"
    rm -rv $build/busybox # &>> $fulllogfile
    mkdir -pv $build/busybox # &>> $fulllogfile
    cd $build/busybox
    tar -xvjf $root/downloads/busybox-1.36.1.tar.bz2 # &>> $fulllogfile
    cd busybox-1.36.1
    cp -v $root/busybox/busybox-rootfs-config .config # &>> $fulllogfile
    printf "$UGREEN** Configuring busybox\n$RESET"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE oldconfig # &>> $fulllogfile
    check $? "Configure busybox all logs in .log"
    printf "$UGREEN** Building busybox\n$RESET"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE $makeflags # &>> $fulllogfile
    check $? "Build busybox all logs in .log"
}
#--------------------------------------------------