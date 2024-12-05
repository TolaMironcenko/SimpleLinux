#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/kernel.sh
. ./scripts/uboot.sh
. ./scripts/initramfs.sh

#--- sdroot ---
sdroot() {
    printf "$GREEN** Generating sdroot\n$RESET"
    rm -rv $sdroot
    if [ ! -d $sdroot ]; then
        mkdir -pv $sdroot
    fi
    printf "$GREEN** Creating dirs\n$RESET"
    mkdir -pv $sdroot/boot/{dtbs,extlinux}
    check $? "Creating dirs"
    printf "$GREEN** Copy extlinux.conf\n$RESET"
    cp -v $root/extlinux/extlinux.conf $sdroot/boot/extlinux
    check $? "Copy extlinux.conf"
    kernel_with_rootfs
    uboot
    printf "$GREEN** Creating rootfs.ext4\n$RESET"
    cd $out
    rawsdrootsize=$(du -s $sdroot)
    echo $rawsdrootsize
    sdrootsize=(${rawsdrootsize// / })
    echo $sdrootsize
    echo $(($sdrootsize+2))
    dd if=/dev/zero of=rootfs.ext4 bs=1K count=$(($sdrootsize+3000))
    check $? "Write zero rootfs.ext4"
    mkfs.ext4 rootfs.ext4
    check $? "Creating ext4 filesystem"
    rawuuid=$(echo $(blkid rootfs.ext4 | echo $(awk '{print $2}')))
    echo $rawuuid
    uuidIN=(${rawuuid//=/ })
    uuid=${uuidIN[1]}
    echo $uuid
    cp -v $root/genimage/genimage.cfg .
    check $? "Copy genimage.cfg"
    sed -i "s/FILEUUID/$uuid/g" genimage.cfg
    mkdir -v rootmnt
    sudo mount -v rootfs.ext4 rootmnt
    sudo cp -rv $sdroot/* rootmnt/
    sudo umount -v rootfs.ext4
    rm -rv rootmnt
    mkdir input
    mv -v ./{rootfs.ext4,u-boot-sunxi-with-spl.bin} input
    genimage --config genimage.cfg
    check $? "Generating sdcard.img"
}
#--------------

sdroot_usable() {
    printf "$GREEN** Generating sdroot usable\n$RESET"
    rm -rv $sdroot
    if [ ! -d $sdroot ]; then
        mkdir -pv $sdroot
    fi
    printf "$GREEN** Creating dirs\n$RESET"
    mkdir -pv $sdroot/boot/{dtbs,extlinux}
    check $? "Creating dirs"
    printf "$GREEN** Copy extlinux.conf\n$RESET"
    cp -v $root/extlinux/extlinux_usable.conf $sdroot/boot/extlinux/extlinux.conf
    check $? "Copy extlinux.conf"
    # kernel_with_rootfs
    cp -rv $build/rootfs/* $sdroot/
    initramfs
    cp -v $build/initramfs.img $sdroot/boot
    cp -v $build/kernel/linux-6.1.91/arch/$ARCH/boot/zImage $sdroot/boot
    uboot
    printf "$GREEN** Creating rootfs.ext4\n$RESET"
    cd $out
    rawsdrootsize=$(du -s $sdroot)
    echo $rawsdrootsize
    sdrootsize=(${rawsdrootsize// / })
    echo $sdrootsize
    echo $(($sdrootsize+2))
    dd if=/dev/zero of=rootfs.ext4 bs=1K count=$(($sdrootsize+3000))
    check $? "Write zero rootfs.ext4"
    mkfs.ext4 rootfs.ext4
    check $? "Creating ext4 filesystem"
    rawuuid=$(echo $(blkid rootfs.ext4 | echo $(awk '{print $2}')))
    echo $rawuuid
    uuidIN=(${rawuuid//=/ })
    uuid=${uuidIN[1]}
    echo $uuid
    cp -v $root/genimage/genimage.cfg .
    check $? "Copy genimage.cfg"
    sed -i "s/FILEUUID/$uuid/g" genimage.cfg
    sed -i "s/ROOTUUID/$uuid/g" $sdroot/boot/extlinux/extlinux.conf
    sed -i "s/sdcard.img/sdcard_usable.img/g" genimage.cfg
    mkdir -v rootmnt
    sudo mount -v rootfs.ext4 rootmnt
    sudo cp -rv $sdroot/* rootmnt/
    sudo umount -v rootfs.ext4
    rm -rv rootmnt
    mkdir input
    mv -v ./{rootfs.ext4,u-boot-sunxi-with-spl.bin} input
    genimage --config genimage.cfg
    check $? "Generating sdcard_usable.img"
}
