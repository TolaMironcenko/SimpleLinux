#!/bin/bash

#------------- grub rescue ---------------------------
grub_rescue() {
    grub-mkrescue -o $build/simplelinux.iso $rootfspath &>> $fulllogfile >> $(tty)
    check $? "Build grub-rescue"
    cp -v $build/simplelinux.iso $out/ &>> $fulllogfile
}
#-----------------------------------------------------

#------------------ rootfs archive -------------------
rootfs_archive() {
    cd $rootfspath
    tar -czvf $out/simplelinux-$version-rootfs.tar.gz . &>> $fulllogfile >> $(tty)
    check $? "Build rootfs archive"
}
#-----------------------------------------------------
