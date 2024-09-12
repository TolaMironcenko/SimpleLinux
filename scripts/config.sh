#!/bin/sh

#------------ config ------------------
version=0.0.1                               # script version
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
