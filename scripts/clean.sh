#!/bin/bash

#---------- Cleaning build and out directory ---------
clean() {
    printf "$UGREEN** Cleaning build and out directories\n$RESET"
    rm -rv $root/.log/* &>> $fulllogfile >> $(tty)
    mkdir -p $root/.log
    rm -rv $out &>> $fulllogfile >> $(tty)
    mkdir -p $out
    rm -rv $build &>> $fulllogfile >> $(tty)
    mkdir -p $build
    printf "$UGREEN** SUCCESS: Cleaning build and out directories\n$RESET"
} # clean
#-----------------------------------------------------
