#!/bin/sh

. ./scripts/colors.sh
. ./scripts/config.sh
. ./scripts/funcs.sh
. ./scripts/download.sh
. ./scripts/busybox.sh
. ./scripts/kernel.sh
. ./scripts/rootfs.sh
. ./scripts/uboot.sh
. ./scripts/sdroot.sh
. ./scripts/dropbear.sh

case $1 in
    build)
        if [ ! -d downloads ]; then
            download_sources
        fi
        rootfs
        if [ "$image_usable_enable" = "true" ]; then
            sdroot_usable
        fi
        sdroot
        # kernel_with_rootfs
        # uboot
        # busybox_rootfs
        # kernel
        ;;
    dropbear)
        dropbear
        ;;
    download)
        download_sources
        ;;
    sdroot_usable)
        if [ ! -d downloads ]; then
          download_sources
        fi
        rootfs
        sdroot_usable
        ;;
    *)
        printf "$UYELLOW** $0 script using: $0 {clean|build|download|rootfs}\n$RESET"
        exit 1
esac
