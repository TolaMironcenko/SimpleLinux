#!/bin/bash

#------------- grub rescue ---------------------------
grub_rescue() {
    grub-mkrescue -o $build/simplelinux.iso $rootfspath &>> $fulllogfile
    check $? "Build grub-rescue"
    cp -v $build/simplelinux.iso $out/ &>> $fulllogfile
}
#-----------------------------------------------------

#------------------ rootfs archive -------------------
rootfs_archive() {
    cd $rootfspath
    tar -czvf $out/simplelinux-$version-rootfs.tar.gz . &>> $fulllogfile
    check $? "Build rootfs archive"
}
#-----------------------------------------------------
