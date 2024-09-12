#!/bin/sh

#------------------ Building initramfs.img ------------------------
initramfs() {
    printf "$UGREEN** Building initramfs\n$RESET"

#--------- Creating directories and files -------------------
    rm -r $initramfspath &>> $fulllogfile 
    mkdir -p $initramfspath
    cd $initramfspath
    mkdir -p $(cat $initramfsfile)
    cp $root/initramfs/init.in $initramfspath/init
    chmod 755 $initramfspath/init
#------------------------------------------------------------

#------------ Building initramfs busybox and copy to initramfs directory --------------------
    busybox initramfs
    cp $build/busybox/busybox-1.36.1/busybox $initramfspath/bin
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
