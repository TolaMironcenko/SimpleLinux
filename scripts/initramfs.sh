#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/busybox.sh

#------------------ Building initramfs.img ------------------------
initramfs() {
    printf "$UGREEN** Building initramfs\n$RESET"

#--------- Creating directories and files -------------------
    rm -r $initramfspath # &>> $fulllogfile  >> $(tty)
    mkdir -p $initramfspath
    cd $initramfspath
    mkdir -p $(cat $initramfsfile)
    cp $root/initramfs/init.in $initramfspath/init
    chmod 755 $initramfspath/init
#------------------------------------------------------------

#------------ Building initramfs busybox and copy to initramfs directory --------------------
    busybox_initramfs
    cp $build/busybox/busybox-1.36.1/busybox $initramfspath/bin
    cd $initramfspath/bin
    for i in $(cat $root/busybox/busybox_initramfs_list); do ln -s busybox $i; done
    cd ..
#--------------------------------------------------------------------------------------------

#--------------------- Creating initramfs.img image ------------
    find . | cpio -H newc -o | gzip > ../initramfs.img
    check $? "Build initramfs.img image"
    cd $root
#---------------------------------------------------------------

} # initramfs
#------------------------------------------------------------------