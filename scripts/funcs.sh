#!/bin/bash

#--- Import colors ---
. ./scripts/colors.sh
#---------------------

#------- Check errors func -----------------
check() {
    if [ $1 -ne 0 ]; then
        printf "$URED** ERROR: $2\n$RESET"
        exit 1
    fi
    printf "$UGREEN** SUCCESS: $2\n$RESET" 
}
#-------------------------------------------

#------- Check root func -------------------
check_root() {
    if [ $(id -u) -ne 0 ]; then
        printf "$URED** You are not root\n$RESET"
        exit 1
    fi
}
#-------------------------------------------
