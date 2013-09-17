#!/bin/bash

BASH=/bin/bash
USAGE="\n\t$0 [-u username | -h]\n"

if [ $# -gt 0 ]; then
    case "$1" in
        -u) 
            if [ -z $2 ] ; then
                printf "USAGE:$USAGE"
                exit 1
            fi
            sudo -u $2 $BASH getversion.sh 
            ;;
        -h) 
            echo "Script that checks the installed versions of the programs from version_list.txt"
            echo "The script assumes it's run by root unless otherwise specified by the -u flag."
            printf "USAGE:$USAGE"
            ;;
        *) 
            printf  "USAGE:$USAGE"
            ;;
    esac
else 
    $BASH getversion.sh
fi
