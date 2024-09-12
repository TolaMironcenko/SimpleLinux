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

#--- script version ---
version=0.0.1 
#----------------------

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

#---------- import build kernel funcs ---------
. ./scripts/kernel.sh
#----------------------------------------------

#-------- import build glibc funcs ------------
. ./scripts/glibc.sh
#----------------------------------------------

#-------- import build initramfs funcs --------
. ./scripts/initramfs.sh
#----------------------------------------------

#----------- import build rootfs funcs --------
. ./scripts/rootfs.sh
#----------------------------------------------

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
