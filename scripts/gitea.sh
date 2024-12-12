#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/zlib.sh
. ./scripts/dropbear.sh
. ./scripts/sftp_server.sh
. ./scripts/curl.sh
. ./scripts/bash.sh
. ./scripts/git.sh

gitea() {
    if [ ! -d $build/zlib ]; then
        zlib
    fi
    if [ ! -d $build/dropbear ]; then
        dropbear
    fi
    if [ ! -d $build/sftp_server ]; then
        sftp_server
    fi
    if [ ! -d $build/curl ]; then
        curl
    fi
    if [ ! -d $build/curl ]; then
        bash
    fi
    if [ ! -d $build/git ]; then
        git
    fi
    cp -v $root/downloads/gitea-1.22.4-linux-arm-5 $rootfspath/usr/bin/gitea
    chmod +x $rootfspath/usr/bin/gitea
    check $? "download and install gitea to rootfs"
}
