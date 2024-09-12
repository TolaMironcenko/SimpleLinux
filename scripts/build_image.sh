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

buid_image() {
    clean
    download_sources
    rootfs
    grub_rescue
    rootfs_archive
}

case "$1" in
    clean)
        clean
        ;;
    build)
        buid_image
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
