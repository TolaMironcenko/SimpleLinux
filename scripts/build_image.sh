#!/bin/sh

#--------------------------------- Logo ---------------------------------------------------------------------
# #######   ##   ##      ##   #######   ##        #######   |  ##        ##   ##    ##   ##    ##   ##  ##  |
# ##        ##   ####  ####   ##   ##   ##        ##        |  ##        ##   ##    ##   ##    ##   ##  ##  |
# ##             ##  ##  ##   ##   ##   ##        ##        |  ##             ##    ##   ##    ##   ##  ##  |
# ##        ##   ##  ##  ##   ##   ##   ##        ##        |  ##        ##   ###   ##   ##    ##     ##    |
# #######   ##   ##      ##   #######   ##        #######   |  ##        ##   ####  ##   ##    ##     ##    |
#      ##   ##   ##      ##   ##        ##        ##        |  ##        ##   ##  ####   ##    ##     ##    |
#      ##   ##   ##      ##   ##        ##        ##        |  ##        ##   ##   ###   ##    ##   ##  ##  |
#      ##   ##   ##      ##   ##        ##        ##        |  ##        ##   ##    ##   ##    ##   ##  ##  |
# #######   ##   ##      ##   ##        #######   #######   |  #######   ##   ##    ##   ########   ##  ##  |
#------------------------------------------------------------------------------------------------------------

# Script to build linux install media image
version=0.0.1 # script version
# TolaMironcenko is licensed under MIT

#--- import rolors ---
. ./scripts/colors.sh
#---------------------
#--- import funcs ----
. ./scripts/funcs.sh
#---------------------
#----- import config variables ----------
. ./scripts/config.sh
#----------------------------------------
#----- import busybox build funcs ---
. ./scripts/busybox.sh
#------------------------------------

#-------- check root ------------------
check_root
#--------------------------------------

mkdir $out &>> $fulllogfile
mkdir $root/.log &>> $fulllogfile

#--------- import Download sources funcs ------
. ./scripts/download.sh
#----------------------------------------------

#--------------- Building Linux Kernel ---------------------
kernel() {
    printf "$UGREEN** Building Linux Kernel\n$RESET"
    rm -r $build/kernel &>> $fulllogfile
    mkdir -p $build/kernel &>> $fulllogfile
    cd $build/kernel
    printf "$UGREEN** Extracting Linux Kernel\n$RESET"
    tar -xvf $root/downloads/linux-6.7.4.tar.xz  &>> $fulllogfile
    check $? "Extract Linux Kernel"
    cd linux-6.7.4
    printf "$UGREEN** Configuring Linux Kernel\n$RESET"
    make mrproper  &>> $fulllogfile
    cp -v $root/kernel/config-6.7.4 .config &>> $fulllogfile
    make oldconfig &>> $fulllogfile
    check $? "Configure Linux Kernel"
    printf "$UGREEN** Building Linux Kernel\n$RESET"
    make $makeflags  &>> $fulllogfile
    check $? "Build Linux Kernel"
    ls -lh arch/x86/boot/bzImage
} # kernel
#-----------------------------------------------------------

#----------- Build and Install kernel modules --------------
kernel_modules() {
    printf "$UGREEN** Building Linux Kernel modules\n$RESET"
    cd $build/kernel/linux-6.7.4
    make modules &>> fulllogfile
    check $? "Build Linux Kernel modules"
    printf "$UGREEN** Installing Linux Kernel modules into rootfs path\n$RESET"
    mkdir -pv $rootfspath/usr/lib &>> fulllogfile
    cd $rootfspath
    ln -sv usr/lib lib &>> $fulllogfile
    cd $root/build/kernel/linux-6.7.4
    make INSTALL_MOD_PATH=$rootfspath modules_install &>> $fulllogfile
    check $? "Install Linux Kernel modules"
} # kernel_modules
#-----------------------------------------------------------

#-------- import build glibc funcs ------------
. ./scripts/glibc.sh
#----------------------------------------------

#------------------ Building initramfs.img ------------------------
initramfs() {
    printf "$UGREEN** Building initramfs\n$RESET"

#--------- Creating directories and files -------------------
    rm -r $initramfspath &>> $fulllogfile 
    mkdir -p $initramfspath
    cd $initramfspath
    mkdir -p $(cat $initramfsfile)
    cp $root/initramfs/init.in $initramfspath/init
    chmod 755 $initramfspath/init
#------------------------------------------------------------

#------------ Building initramfs busybox and copy to initramfs directory --------------------
    busybox initramfs
    cp $build/busybox/busybox-1.36.1/busybox $initramfspath/bin
    cd $initramfspath/bin
    for i in $(./busybox --list); do ln -s busybox $i; done
    cd ..
#--------------------------------------------------------------------------------------------

#--------------------- Creating initramfs.img image ------------
    find . | cpio -H newc -o | gzip > ../initramfs.img
    check $? "Build initramfs.img image"
    cd $root
#---------------------------------------------------------------

} # initramfs
#------------------------------------------------------------------

#----------- Building rootfs ----------------------
rootfs() {
    printf "$UGREEN** Building rootfs\n$RESET"
    rm -rv $rootfspath &>> $fulllogfile
    mkdir -pv $rootfspath &>> $fulllogfile
    cd $rootfspath
    mkdir -pv $(cat $rootfsfile) &>> $fulllogfile
    ln -sv usr/lib lib &>> $fulllogfile
    ln -sv usr/lib lib64 &>> $fulllogfile
    ln -sv usr/bin bin &>> $fulllogfile
    ln -sv usr/bin sbin &>> $fulllogfile
    cd usr
    ln -sv bin sbin &>> $fulllogfile
    ln -sv lib lib64 &>> $fulllogfile
    cp -rv $root/rootfs/etc/* $rootfspath/etc/ &>> $fulllogfile
    cp -rv $root/rootfs/usr/* $rootfspath/usr/ &>> $fulllogfile
    cp -rv $root/rootfs/boot/* $rootfspath/boot/ &>> $fulllogfile
    cd ..
    ln -sv /proc/mounts etc/mtab &>> $fulllogfile

    busybox rootfs
    cp -v $build/busybox/busybox-1.36.1/busybox $rootfspath/usr/bin &>> $fulllogfile
    cd $rootfspath/usr/bin
    for i in $(./busybox --list); do ln -s busybox $i; done

    glibc
    kernel
    cp -v $root/build/kernel/linux-6.7.4/arch/x86/boot/bzImage $rootfspath/boot/vmlinuz-linux &>> $fulllogfile
    kernel_modules
    initramfs
    cp -v $root/build/initramfs.img $rootfspath/boot/ &>> $fulllogfile

    chmod 640 $rootfspath/etc/shadow $rootfspath/etc/inittab
    chmod 755 $rootfspath/etc/init.d/* $rootfspath/usr/share/udhcpc/default.script
    chmod 644 $rootfspath/etc/{passwd,group,hostname,hosts,fstab,shells,issue} $rootfspath/etc/network/interfaces

    check $? "Build rootfs"
} # rootfs
#--------------------------------------------------

#----------- import cleaning funcs -------------
. ./scripts/clean.sh
#-----------------------------------------------
#-------- import build artifacts funcs ---------
. ./scripts/artifacts.sh
#-----------------------------------------------

if [ "$1" = "clean" ]; then
    clean
    exit 0
fi

case "$1" in
    clean)
        clean
        ;;
    build)
        clean
        download_sources
        rootfs
        grub_rescue
        rootfs_archive
        ;;
    download)
        download_sources
        ;;
    rootfs)
        rootfs
        ;;
    *)
        printf "$UYELLOW** $0 script using: $0 {clean|build|download|rootfs}\n$RESET"
        exit 1
esac
