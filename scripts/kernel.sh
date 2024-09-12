#!/bin/bash

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
