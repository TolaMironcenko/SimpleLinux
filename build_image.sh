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
fulllogfile=$root/.log/fulllog.log          # file for full build logs
makeflags=-j16                              # makeflags
#--------------------------------------

#-------- check root ------------------
if [ $(id -u) -ne 0 ]; then
    printf "$URED** You are not root\n$RESET"
    exit 1
fi
#--------------------------------------

mkdir $out &>> $fulllogfile
mkdir $root/.log &>> $fulllogfile

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
    rm -r $build/kernel &>> $fulllogfile
    mkdir -p $build/kernel &>> $fulllogfile
    cd $build/kernel
    printf "$UGREEN** Extracting Linux Kernel\n$RESET"
    tar -xvf $root/downloads/linux-*.tar.xz  &>> $fulllogfile
    check $? "Extract Linux Kernel"
    cd linux-*
    printf "$UGREEN** Configuring Linux Kernel\n$RESET"
    make mrproper  &>> $fulllogfile
    cp -v $root/kernel/config-6.7.4 .config
    make oldconfig
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
    cd $build/kernel/linux-*
    make modules &>> fulllogfile
    check $? "Build Linux Kernel modules"
    printf "$UGREEN** Installing Linux Kernel modules into rootfs path\n$RESET"
    mkdir -pv $rootfspath/usr/lib &>> fulllogfile
    cd $rootfspath
    ln -sv usr/lib lib &>> $fulllogfile
    cd $root/build/kernel/linux-*
    make INSTALL_MOD_PATH=$rootfspath modules_install &>> $fulllogfile
    check $? "Install Linux Kernel modules"
} # kernel_modules
#-----------------------------------------------------------

#------------ glibc ----------------------------------------
glibc() {
    printf "$UGREEN** Building glibc\n$RESET"
    mkdir -p $build/glibc &>> $fulllogfile
    cd $build/glibc
    tar -xvf $root/downloads/glibc-*.tar.xz &>> $fulllogfile
    check $? "Extract glibc"
    cd glibc-*
    mkdir build
    cd build
    echo "rootsbindir=/usr/bin" > configparms
    ../configure \
        --prefix=/usr \
        --disable-werror \
        --enable-kernel=4.19 \
        --enable-stack-protector=strong \
        --disable-nscd \
        libc_cv_slibdir=/usr/lib &>> $fulllogfile
    check $? "Configure glibc"
    make $makeflags &>> $fulllogfile
    check $? "Build glibc"
    make DESTDIR=$rootfspath install &>> $fulllogfile
    check $? "Install glibc to rootfs"
    cd $rootfspath
    find -name \*.a -delete &>> $fulllogfile
    strip --strip-unneeded $rootfspath/usr/lib/* $rootfspath/usr/bin/* &>> $fulllogfile
    chroot $rootfspath /bin/sh -c "mkdir -p /usr/lib/locale;localedef -i C -f UTF-8 C.UTF-8;localedef -i en_US -f UTF-8 en_US.UTF-8;localedef -i ru_RU -f UTF-8 ru_RU-UTF-8;"
    cd $root
    check $? "Build and install glibc"
}
#-----------------------------------------------------------

#------------------ Building initramfs.img ------------------------
initramfs() {
    printf "$UGREEN** Building initramfs\n$RESET"

#--------- Creating directories and files -------------------
    rm -r $initramfspath &>> $fulllogfile 
    mkdir -p $initramfspath;
    cd $initramfspath;
    mkdir -p $(cat $initramfsfile);
    cp $root/initramfs/init.in $initramfspath/init
    chmod 755 $initramfspath/init
#------------------------------------------------------------

#------------ Building initramfs busybox and copy to initramfs directory --------------------
    rm -r $build/busybox &>> $fulllogfile
    mkdir -p $build/busybox
    cd $build/busybox
    tar -xjf $root/downloads/busybox-1.36.1.tar.bz2
    check $? "Extract busybox"
    cd busybox-1.36.1
    cp $root/busybox/busybox-initramfs-config .config
    export PATH=$PATH:/opt/toolchains/x86_64-buildroot-linux-uclibc-gcc/bin
    printf "$UGREEN** Configuring busybox\n$RESET"
    make CROSS_COMPILE=x86_64-buildroot-linux-uclibc- oldconfig &> $fulllogfile
    check $? "Configure busybox all logs in .log"
    printf "$UGREEN** Building busybox\n$RESET"
    make CROSS_COMPILE=x86_64-buildroot-linux-uclibc- $makeflags &> $fulllogfile
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

    rm -rv $build/busybox &>> $fulllogfile
    mkdir -v $build/busybox &>> $fulllogfile
    cd $build/busybox
    tar -xvjf $root/downloads/busybox-*.tar.bz2 &>> $fulllogfile
    cd busybox-*
    cp -v $root/busybox/busybox-rootfs-config .config &>> $fulllogfile
    printf "$UGREEN** Configuring busybox\n$RESET"
    make oldconfig &> $fulllogfile
    check $? "Configure busybox all logs in .log"
    printf "$UGREEN** Building busybox\n$RESET"
    make $makeflags &> $fulllogfile
    check $? "Build busybox all logs in .log"
    cp -v busybox $rootfspath/usr/bin &>> $fulllogfile
    cd $rootfspath/usr/bin
    for i in $(./busybox --list); do ln -s busybox $i; done

    glibc
    kernel
    cp -v $root/build/kernel/linux-*/arch/x86/boot/bzImage $rootfspath/boot/vmlinuz-linux
    kernel_modules
    initramfs
    cp -v $root/build/initramfs.img $rootfspath/boot/

    chmod 640 $rootfspath/etc/shadow $rootfspath/etc/inittab
    chmod 755 $rootfspath/etc/init.d/* $rootfspath/usr/share/udhcpc/default.script
    chmod 644 $rootfspath/etc/{passwd,group,hostname,hosts,fstab,shells,issue} $rootfspath/etc/network/interfaces

    check $? "Build rootfs"
} # rootfs
#--------------------------------------------------

#---------- Cleaning build and out directory ---------
clean() {
    printf "$UGREEN** Cleaning build and out directories\n$RESET"
    rm -rv $root/.log/* &>> $fulllogfile
    rm -rv $out &>> $fulllogfile
    rm -rv $build &>> $fulllogfile
    printf "$UGREEN** SUCCESS: Cleaning build and out directories\n$RESET"
} # clean
#-----------------------------------------------------

#------------- grub rescue ---------------------------
grub_rescue() {
    grub-mkrescue -o $build/simplelinux.iso $rootfspath
}
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
grub_rescue
