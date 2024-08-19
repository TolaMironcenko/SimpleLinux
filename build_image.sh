#!/bin/sh

# Script to build linux install media image
version=0.0.1
# TolaMironcenko is licensed under MIT

. ./colors.sh
. ./funcs.sh

#------------ config ------------------
root=$(pwd)
disk="sdz"
distro_name="Simple"
distro_desc="Simple linux distro"
distro_codename="zero_zero_one"
hyperv_support="false"
out=$root/out
build=$root/build
kernel=""
busybox=""
sourcesfilename=sources.txt
initramfsfile=$root/initramfs/initramfs.txt
initramfspath=$build/initramfs
rootfsfile=$root/rootfs/rootfs.txt
rootfspath=$build/rootfs
#--------------------------------------

#-------- check root ------------------
if [ $(id -u) -ne 0 ]; then
    printf "$URED** You are not root\n$RESET"
    exit 1
fi
#--------------------------------------

mkdir $out
mkdir $root/.log

download_sources() {
    printf "$UGREEN** Downloading sources\n$RESET"
    cat $sourcesfilename
    if [ ! -d downloads ]; then mkdir downloads; fi
    wget --input-file=$sourcesfilename --continue --directory-prefix=$root/downloads
    check $? "Download sources"
}

initramfs() {
    printf "$UGREEN** Building initramfs\n$RESET"
    rm -r $initramfspath;
    mkdir -p $initramfspath;
    cd $initramfspath;
    mkdir -p $(cat $initramfsfile);
    cp $root/initramfs/init.in $initramfspath/init
    chmod 755 $initramfspath/init
    rm -r $build/busybox
    mkdir -p $build/busybox
    cd $build/busybox
    tar -xjf $root/downloads/busybox-1.36.1.tar.bz2
    check $? "Extract busybox"
    cd busybox-1.36.1
    cp $root/busybox/busybox-initramfs-config .config
    export PATH=$PATH:/opt/toolchains/x86_64-buildroot-linux-uclibc-gcc/bin
    printf "$UGREEN** Configuring busybox\n$RESET"
    make CROSS_COMPILE=x86_64-buildroot-linux-uclibc- oldconfig &> $root/.log/busybox-configure.log
    check $? "Configure busybox all logs in .log"
    printf "$UGREEN** Building busybox\n$RESET"
    make CROSS_COMPILE=x86_64-buildroot-linux-uclibc- -j16 &> $root/.log/busybox-build.log
    check $? "Build busybox all logs in .log"
    cp busybox $initramfspath/bin
    cd $initramfspath/bin
    for i in $(./busybox --list); do ln -s busybox $i; done
    cd ..
    find . | cpio -H newc -o | gzip > ../initramfs.img
    check $? "Build initramfs.img image"
    cd $root
}

rootfs() {
    rm -rv $rootfspath
    mkdir -pv $rootfspath
    cd $rootfspath
    mkdir -pv $(cat $rootfsfile)
}

clean() {
    rm -rv $out
    rm -rv $build
}

# download_sources
initramfs
