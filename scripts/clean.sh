#!/bin/bash

#---------- Cleaning build and out directory ---------
clean() {
    printf "$UGREEN** Cleaning build and out directories\n$RESET"
    rm -rv $root/.log/* &>> $fulllogfile
    mkdir -p $root/.log
    rm -rv $out &>> $fulllogfile
    mkdir -p $out
    rm -rv $build &>> $fulllogfile
    mkdir -p $build
    printf "$UGREEN** SUCCESS: Cleaning build and out directories\n$RESET"
} # clean
#-----------------------------------------------------
