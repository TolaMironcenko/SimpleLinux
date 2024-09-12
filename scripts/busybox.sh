#!/bin/sh

#--- import rolors ---
. ./scripts/colors.sh
#---------------------
#--- import funcs ----
. ./scripts/funcs.sh
#---------------------

#------------------ Building busybox for initramfs ----------------
busybox_initramfs() {
    printf "$UGREEN** Building busybox for initramfs\n$RESET"
    rm -r $build/busybox &>> $fulllogfile
    mkdir -p $build/busybox
    cd $build/busybox
    tar -xjf $root/downloads/busybox-1.36.1.tar.bz2
    check $? "Extract busybox"
    cd busybox-1.36.1
    cp $root/busybox/busybox-initramfs-config .config
    export PATH=$PATH:/opt/toolchains/x86_64-buildroot-linux-uclibc-gcc/bin
    printf "$UGREEN** Configuring busybox\n$RESET"
    make CROSS_COMPILE=x86_64-buildroot-linux-uclibc- oldconfig &>> $fulllogfile
    check $? "Configure busybox all logs in .log"
    printf "$UGREEN** Building busybox\n$RESET"
    make CROSS_COMPILE=x86_64-buildroot-linux-uclibc- $makeflags &>> $fulllogfile
    check $? "Build busybox all logs in .log"
}
#------------------------------------------------------------------

#----------- Building busybox for rootfs ----------
busybox_rootfs() {
    printf "$UGREEN** Building busybox for rootfs\n$RESET"
    rm -rv $build/busybox &>> $fulllogfile
    mkdir -v $build/busybox &>> $fulllogfile
    cd $build/busybox
    tar -xvjf $root/downloads/busybox-1.36.1.tar.bz2 &>> $fulllogfile
    cd busybox-1.36.1
    cp -v $root/busybox/busybox-rootfs-config .config &>> $fulllogfile
    printf "$UGREEN** Configuring busybox\n$RESET"
    make oldconfig &>> $fulllogfile
    check $? "Configure busybox all logs in .log"
    printf "$UGREEN** Building busybox\n$RESET"
    make $makeflags &>> $fulllogfile
    check $? "Build busybox all logs in .log"
}
#--------------------------------------------------

#------------------ Building busybox ------------------------------
busybox() {
    case "$1" in
        initramfs)
            busybox_initramfs
            ;;
        rootfs)
            busybox_rootfs
            ;;
    esac
}
#------------------------------------------------------------------
