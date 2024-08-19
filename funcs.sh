#!/bin/sh

. ./colors.sh

check() {
    if [ $1 -ne 0 ]; then
        printf "$URED** ERROR: $2\n$RESET"
        exit 1
    fi
    printf "$UGREEN** SUCCESS: $2\n$RESET" 
}
