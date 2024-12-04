#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh

#--------------- Building Linux Kernel ---------------------
kernel() {
    printf "$UGREEN** Building Linux Kernel\n$RESET"
    rm -r $build/kernel # &>> $fulllogfile
    mkdir -p $build/kernel # &>> $fulllogfile
    cd $build/kernel
    printf "$UGREEN** Extracting Linux Kernel\n$RESET"
    tar -xvf $root/downloads/linux-6.1.91.tar.xz  # &>> $fulllogfile
    check $? "Extract Linux Kernel"
    cd linux-6.1.91
    printf "$UGREEN** Configuring Linux Kernel\n$RESET"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE mrproper  # &>> $fulllogfile
    cp -v $root/kernel/config-6.1.91 .config # &>> $fulllogfile
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE oldconfig # &>> $fulllogfile
    check $? "Configure Linux Kernel"
    printf "$UGREEN** Building Linux Kernel\n$RESET"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE $makeflags  # &>> $fulllogfile
    check $? "Build Linux Kernel"
    ls -lh arch/$ARCH/boot/zImage
} # kernel
#-----------------------------------------------------------

#----------- Build and Install kernel modules --------------
kernel_modules() {
    printf "$UGREEN** Building Linux Kernel modules\n$RESET"
    cd $build/kernel/linux-6.1.91
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE modules # &>> fulllogfile
    check $? "Build Linux Kernel modules"
    printf "$UGREEN** Installing Linux Kernel modules into rootfs path\n$RESET"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$rootfspath modules_install # &>> $fulllogfile
    rm -v $rootfspath/usr/lib/modules/6.1.91/{source,build}
    check $? "Install Linux Kernel modules"
} # kernel_modules
#-----------------------------------------------------------

#--------------- Building Linux Kernel with rootfs ---------
kernel_with_rootfs() {
    printf "$UGREEN** Building Linux Kernel with rootfs\n$RESET"
    if [ ! -d $out ]; then
        mkdir -pv $out
    fi
    cd $build/kernel/linux-6.1.91
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE CONFIG_INITRAMFS_SOURCE=$rootfspath $makeflags # &>> fulllogfile
    check $? "Build Linux Kernel with rootfs"
    printf "$UGREEN** Installing Linux Kernel into images path\n$RESET"
    # make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE INSTALL_MOD_PATH=$rootfspath modules_install # &>> $fulllogfile
    # rm -v $rootfspath/usr/lib/modules/6.1.91/{source,build}
    cp -v arch/$ARCH/boot/zImage $sdroot/boot
    check $? "Install Linux Kernel into images path"
}
#-----------------------------------------------------------
