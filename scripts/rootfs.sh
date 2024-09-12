#!/bin/bash

#----------- Building rootfs ----------------------
rootfs() {
    printf "$UGREEN** Building rootfs\n$RESET"
    rm -rv $rootfspath &>> $fulllogfile >> $(tty)
    mkdir -pv $rootfspath &>> $fulllogfile >> $(tty)
    cd $rootfspath
    mkdir -pv $(cat $rootfsfile) &>> $fulllogfile >> $(tty)
    ln -sv usr/lib lib &>> $fulllogfile >> $(tty)
    ln -sv usr/lib lib64 &>> $fulllogfile >> $(tty)
    ln -sv usr/bin bin &>> $fulllogfile >> $(tty)
    ln -sv usr/bin sbin &>> $fulllogfile >> $(tty)
    cd usr
    ln -sv bin sbin &>> $fulllogfile >> $(tty)
    ln -sv lib lib64 &>> $fulllogfile >> $(tty)
    cp -rv $root/rootfs/etc/* $rootfspath/etc/ &>> $fulllogfile >> $(tty)
    cp -rv $root/rootfs/usr/* $rootfspath/usr/ &>> $fulllogfile >> $(tty)
    cp -rv $root/rootfs/boot/* $rootfspath/boot/ &>> $fulllogfile >> $(tty)
    cd ..
    ln -sv /proc/mounts etc/mtab &>> $fulllogfile >> $(tty)

    busybox rootfs
    cp -v $build/busybox/busybox-1.36.1/busybox $rootfspath/usr/bin &>> $fulllogfile >> $(tty)
    cd $rootfspath/usr/bin
    for i in $(./busybox --list); do ln -s busybox $i; done

    glibc
    kernel
    cp -v $root/build/kernel/linux-6.7.4/arch/x86/boot/bzImage $rootfspath/boot/vmlinuz-linux &>> $fulllogfile >> $(tty)
    kernel_modules
    initramfs
    cp -v $root/build/initramfs.img $rootfspath/boot/ &>> $fulllogfile >> $(tty)

    chmod 640 $rootfspath/etc/shadow $rootfspath/etc/inittab
    chmod 755 $rootfspath/etc/init.d/* $rootfspath/usr/share/udhcpc/default.script
    chmod 644 $rootfspath/etc/{passwd,group,hostname,hosts,fstab,shells,issue} $rootfspath/etc/network/interfaces

    check $? "Build rootfs"
} # rootfs
#--------------------------------------------------
