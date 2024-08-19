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
. ./colors.sh
#---------------------
#--- import funcs ----
. ./funcs.sh
#---------------------

#------------ config ------------------
root=$(pwd)                                 # root build directory
disk="sdz"                                  # disk to write install image
distro_name="Simple"                        # distro name
distro_desc="Simple linux distro"           # distro desctiption
distro_codename="zero_zero_one"             # distro codename
hyperv_support="false"                      # hyperv support for kernel image
out=$root/out                               # output directory
build=$root/build                           # build directory
sourcesfilename=sources.txt                 # sources file for downloading
initramfsfile=$root/initramfs/initramfs.txt # file to created directories for initramfs
initramfspath=$build/initramfs              # initramfs build directory
rootfsfile=$root/rootfs/rootfs.txt          # file to created directories for rootfs
rootfspath=$build/rootfs                    # rootfs build directory
fulllogfile=/dev/null                       # file for full build logs
makeflags=-j16                              # makeflags
#--------------------------------------

#-------- check root ------------------
if [ $(id -u) -ne 0 ]; then
    printf "$URED** You are not root\n$RESET"
    exit 1
fi
#--------------------------------------

mkdir $out &> $fulllogfile
mkdir $root/.log &> $fulllogfile

#------------ Download needed sources from sources.txt ------------------
download_sources() {
    printf "$UGREEN** Downloading sources\n$RESET"
    cat $sourcesfilename
    if [ ! -d downloads ]; then mkdir downloads; fi
    wget --input-file=$sourcesfilename --continue --directory-prefix=$root/downloads
    check $? "Download sources"
}
#------------------------------------------------------------------------

#--------------- Building Linux Kernel ---------------------
kernel() {
    printf "$UGREEN** Building Linux Kernel\n$RESET"
    rm -r $build/kernel &> $fulllogfile
    mkdir -p $build/kernel &> $fulllogfile
    cd $build/kernel
    printf "$UGREEN** Extracting Linux Kernel\n$RESET"
    tar -xvf $root/downloads/linux-*.tar.xz  &> $fulllogfile
    check $? "Extract Linux Kernel"
    cd linux-*
    printf "$UGREEN** Configuring Linux Kernel\n$RESET"
    make defconfig  &> $fulllogfile
    check $? "Configure Linux Kernel"
    printf "$UGREEN** Building Linux Kernel\n$RESET"
    make $makeflags  &> $fulllogfile
    check $? "Build Linux Kernel"
    ls -lh arch/x86/boot/bzImage
} # kernel
#-----------------------------------------------------------

#----------- Build and Install kernel modules --------------
kernel_modules() {
    printf "$UGREEN** Building Linux Kernel modules\n$RESET"
    cd $build/kernel/linux-*
    make modules &> fulllogfile
    check $? "Build Linux Kernel modules"
    printf "$UGREEN** Installing Linux Kernel modules into rootfs path\n$RESET"
    mkdir -pv $rootfspath/usr/lib &> fulllogfile
    cd $rootfspath
    ln -sv usr/lib lib &> $fulllogfile
    cd $root/build/kernel/linux-*
    make INSTALL_MOD_PATH=$rootfspath modules_install &> $fulllogfile
    check $? "Install Linux Kernel modules"
} # kernel_modules
#-----------------------------------------------------------

#------------------ Building initramfs.img ------------------------
initramfs() {
    printf "$UGREEN** Building initramfs\n$RESET"

#--------- Creating directories and files -------------------
    rm -r $initramfspath &> $fulllogfile 
    mkdir -p $initramfspath;
    cd $initramfspath;
    mkdir -p $(cat $initramfsfile);
    cp $root/initramfs/init.in $initramfspath/init
    chmod 755 $initramfspath/init
#------------------------------------------------------------

#------------ Building initramfs busybox and copy to initramfs directory --------------------
    rm -r $build/busybox &> $fulllogfile
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
    make CROSS_COMPILE=x86_64-buildroot-linux-uclibc- $makeflags &> $root/.log/busybox-build.log
    check $? "Build busybox all logs in .log"
    cp busybox $initramfspath/bin
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
    rm -rv $rootfspath &> $fulllogfile
    mkdir -pv $rootfspath &> $fulllogfile
    cd $rootfspath
    mkdir -pv $(cat $rootfsfile) &> $fulllogfile
    ln -sv usr/lib lib &> $fulllogfile
    ln -sv usr/lib lib64 &> $fulllogfile
    ln -sv usr/bin bin &> $fulllogfile
    ln -sv usr/bin sbin &> $fulllogfile
    cd usr
    ln -sv bin sbin &> $fulllogfile
    ln -sv lib lib64 &> $fulllogfile
    cp -rv $root/rootfs/etc/* $rootfspath/etc/ &> $fulllogfile
    cp -rv $root/rootfs/usr/* $rootfspath/usr/ &> $fulllogfile

    rm -rv $build/busybox &> $fulllogfile
    mkdir -v $build/busybox &> $fulllogfile
    cd $build/busybox
    tar -xvjf $root/downloads/busybox-*.tar.bz2 &> $fulllogfile
    cd busybox-*
    cp -v $root/busybox/busybox-rootfs-config .config &> $fulllogfile
    printf "$UGREEN** Configuring busybox\n$RESET"
    make oldconfig &> $root/.log/busybox-configure.log
    check $? "Configure busybox all logs in .log"
    printf "$UGREEN** Building busybox\n$RESET"
    make $makeflags &> $root/.log/busybox-build.log
    check $? "Build busybox all logs in .log"
    cp -v busybox $rootfspath/usr/bin &> $fulllogfile
    cd $rootfspath/usr/bin
    for i in $(./busybox --list); do ln -s busybox $i; done

    chmod 640 $rootfspath/etc/shadow $rootfspath/etc/inittab
    chmod 755 $rootfspath/etc/init.d/* $rootfspath/usr/share/udhcpc/default.script
    chmod 644 $rootfspath/etc/{passwd,group,hostname,hosts,fstab,shells,issue} $rootfspath/etc/network/interfaces

    check $? "Build rootfs"
} # rootfs
#--------------------------------------------------

#---------- Cleaning build and out directory ---------
clean() {
    printf "$UGREEN** Cleaning build and out directories\n$RESET"
    rm -rv $out &> $fulllogfile
    rm -rv $build &> $fulllogfile
    printf "$UGREEN** SUCCESS: Cleaning build and out directories\n$RESET"
} # clean
#-----------------------------------------------------

if [ "$1" = "clean" ]; then
    clean
    exit 0
fi

clean
# download_sources
# kernel
# kernel_modules
# initramfs
rootfs
