#!/bin/sh

#------------ Download needed sources from sources.txt ------------------
download_sources() {
    printf "$UGREEN** Downloading sources\n$RESET"
    cat $sourcesfilename
    if [ ! -d downloads ]; then mkdir downloads; fi
    wget --input-file=$sourcesfilename --continue --directory-prefix=$root/downloads
    check $? "Download sources"
}
#------------------------------------------------------------------------
