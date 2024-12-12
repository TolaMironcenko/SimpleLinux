#!/bin/sh

. ./scripts/colors.sh
. ./scripts/funcs.sh
. ./scripts/config.sh
. ./scripts/zlib.sh

curl() {
    if [ ! -d $build/zlib ]; then
        zlib
    fi
    printf "$GREEN** Building and installing curl\n$RESET"
    mkdir $build/curl
    cd $build/curl
    tar -xvf $root/downloads/curl-8.9.1.tar.xz
    check $? "Extract curl"
    cd curl-8.9.1
    ./configure \
        --prefix=/usr \
        --host=$CROSS_COMPILE \
        --without-ssl \
        --disable-static \
        --enable-shared \
        --with-zlib=$rootfspath
    check $? "Configure curl"
    make $makeflags
    check $? "Build curl"
    make DESTDIR=$rootfspath install
    rm \
        -rv \
        $rootfspath/usr/include \
        $rootfspath/usr/share/aclocal \
        $rootfspath/usr/share/man \
        $rootfspath/usr/lib/*.a \
        $rootfspath/usr/lib/*.la \
        $rootfspath/usr/lib/pkgconfig
    $CROSS_COMPILE-strip --strip-unneeded $rootfspath/usr/bin/curl $rootfspath/usr/lib/libcurl.so.4.8.0
    check $? "Installing to rootfs curl"
}
