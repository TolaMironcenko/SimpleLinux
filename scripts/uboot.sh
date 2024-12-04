#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh

#--- uboot ---
uboot() {
    printf "$UGREEN** Building uboot\n$RESET"
    mkdir -p $build/uboot # &>> $fulllogfile
    cd $build/uboot
    tar -xvf $root/downloads/u-boot-v2024.10.tar.gz # &>> $fulllogfile
    check $? "Extract uboot"
    cd u-boot-2024.10
    # cp -rv $root/uclibc/config-1.0.50 .config
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE orangepi_pc_defconfig
    check $? "Configure uboot"
    make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE $makeflags # &>> $fulllogfile
    check $? "Build uboot"
    cp -v u-boot-sunxi-with-spl.bin $out
    cp -v arch/arm/dts/sun8i-h3-orangepi-pc.dtb $sdroot/boot/dtbs
    # make ARCH=$ARCH CROSS_COMPILE=$CROSS_COMPILE DESTDIR=$rootfspath install # &>> $fulllogfile
    check $? "Install uboot to out directory"
    check $? "Build and install uboot to out directory"
}
#-------------