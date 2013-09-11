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
if [ $ME = "root" ]
then 
	LOG_TO="/var/log/${LOG}"
else
	LOG_TO="/home/${ME}/${LOG}"
fi

echo "I am \"$ME\" and logging to $LOG_TO"

getversion() 
{
	resarr=()
	version="NA"
	#getting executables
	echo ***$1
	execs=`find $PATH_LIST -regextype posix-extended -iregex ".*/${1}(|[0-9]+|[0-9]+.[0-9]+)"`
	for exec in $execs
	do
		case $exec in
			"ssh") flag="-V";;
            "ffmpeg") flag="-version";;
            "apache") flag="-v";;
			*) flag="--version";;
		esac 
		if ! echo "$exec" | egrep -q "lib"
		then
			echo $exec
			output=`$exec $flag`
			if [ $? = 0 ]
			then
				version=`echo $output | grep -o ' [0-9]\..*'`
			fi
		fi
	done
    echo version:$version
	echo arr:`echo ${resarr[@]} | uniq`
}

VERSIONS="version_list.txt"
for SW in `cat $VERSIONS | cut -d' ' -f1 | uniq `;
do
	SW=`echo $SW | tr -d ' \n\r'`
	getversion $SW
done

