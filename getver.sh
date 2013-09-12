#!/bin/bash

# 1. Scan common paths on the server for software versions (i.e. /usr/bin;/usr/local/bin)
# 2. Output the information to a text file (/var/log/ when executing as root and the users home directory when not 
# executing as root)
# 3. This text file should be in an easily parsable format (such as .csv or space/comma deliminated)
# 4. If a software version can't be located, instead of leaving the output blank, the letters "NA" should be inserted 
# instead (meaning Not Available).
# 5. Overwriting the previous file each time it executes is OK.
# 6. Preferably add a flag to the script for non-root execution (assume root by default), such as: ./script.sh -u and e
# nsure that everything is executed/stored under the user's home directory and not /tmp or elsewhere.

#set log path depending on running user
PATH_LIST="/usr/local /usr/sbin /usr/bin /sbin /bin"
LOG="getver.log"
ME=`whoami`
if [ $ME = "root" ]; then 
	LOG_TO="/var/log/${LOG}"
else
	LOG_TO="/home/${ME}/${LOG}"
fi
echo "I am \"$ME\" and logging to $LOG_TO"
rm -f $LOG_TO

getversion() 
{
	version="NA"
	execs=`find $PATH_LIST -regextype posix-extended -iregex ".*/${1}(|[0-9]+|[0-9]+.[0-9]+)"`
    #let sw (gems) that has no exec be processed
    if [ -z "$execs" ]; then
        execs=`echo $SW | awk '{print tolower($0)}'`
    fi
    echo execs:$execs
	for exec in $execs
	do
		if [[ ! -d "$exec" ]]; then
		    case $exec in
			    *ssh*)
                    output=`$exec -V 2>&1`
                    ;;
                *ffmpeg*) 
                    output=`$exec -version`
                    ;;
                *apache*)
                    output=`$exec -v`
                    ;;
                *bundler* | *rake* | *flvtool2* | *rmagick*)
                    exec=`echo $SW | awk '{print tolower($0)}'`
                    output=`gem list | grep $exec`
                    ;;
                *python*)
                    output=`$exec --version 2>&1`
                    ;;
			    *) 
                    output=`$exec --version`
                    ;;
		    esac 
     		if [ $? = 0 ]; then
				#version=`echo $output | grep -o '[0-9]\..*'`
                version=$output
			fi
            echo $SW, $version >> $LOG_TO
		fi
    done
}

VERSIONS="version_list.txt"
if [ -f $VERSIONS ]; then
    for SW in `cat $VERSIONS | cut -d' ' -f1 | uniq `;
    do
	    SW=`echo $SW | tr -d ' \n\r'`
	    getversion $SW
    done
else
    echo "ERROR: Could not find $VERSIONS file. Please make sure it is located at `pwd`."
fi

