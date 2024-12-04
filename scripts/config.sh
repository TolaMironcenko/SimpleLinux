#!/bin/sh

#------------ config ------------------
export PATH=$PATH:/opt/toolchains/arm-buildroot-linux-uclibcgnueabihf/bin
export version=0.0.1                                  # script version
export root=$(pwd)                                    # root build directory
# disk="sdz"                                     # disk to write install image
export distro_name="Simple"                           # distro name
export distro_desc="Simple linux distro"              # distro desctiption
export distro_codename="zero_zero_one"                # distro codename
# hyperv_support="false"                         # hyperv support for kernel image
export out=$root/out                                  # output directory
export build=$root/build                              # build directory
export sourcesfilename=sources.txt                    # sources file for downloading
# initramfsfile=$root/initramfs/initramfs.txt    # file to created directories for initramfs
# initramfspath=$build/initramfs                 # initramfs build directory
export rootfsfile=$root/rootfs/rootfs.txt             # file to created directories for rootfs
export rootfspath=$build/rootfs                       # rootfs build directory
export fulllogfile=$root/.log/fulllog.log             # file for full build logs
export makeflags=-j$(nproc) # makeflags
export CROSS_COMPILE=arm-buildroot-linux-uclibcgnueabihf-
export ARCH=arm
export sdroot=$out/sdroot
#--------------------------------------
