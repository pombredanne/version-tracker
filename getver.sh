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

#set -x

#set log path depending on running user
PATH_LIST="/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin"
#PATH_LIST="/usr/local/cpanel /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin"
LOG="getver.log"
ME=`whoami`
if [ $ME = "root" ]; then 
	LOG_TO="/var/log/${LOG}"
else
	LOG_TO="/home/${ME}/${LOG}"
fi
rm -f $LOG_TO

getversion() 
{
    echo Checking $1...
    VERSIONLIST=""

    case  $1 in
    	*Apache*)
            APPNAME="httpd"
            ;;
        *Django*)
            APPNAME="django-admin.py"
            ;;
        *MySQL*)
            APPNAME="mysql"
            ;;
        *ImageMagick*)
           	APPNAME="identify"
           	;;
        *Subversion*)
           	APPNAME="svnserve"
           	;;
        *Mercurial*)
           	APPNAME="hg"
           	;;
        *RubyGems*)
           	APPNAME="gem"
           	;;
        *)
           	APPNAME=$1
           	;;
    esac
    
	EXECS=`find $PATH_LIST -maxdepth 1 -regextype posix-extended -iregex ".*/${APPNAME}(|[0-9]+|[0-9]+.[0-9]+)"`
    #let sw (gems, libs, etc) that has no exec be processed
    if [[ -z "$EXECS" ]]; then
        EXECS=`echo $1 | awk '{print tolower($0)}'`
    fi

	for EXEC in $EXECS
	do
	    if [[ ! -d "$EXEC" ]]; then
		    case $EXEC in
			    *ssh*)
                    OUTPUT=`$EXEC -V 2>&1`
                    ;;
                *ffmpeg*) 
                    OUTPUT=`$EXEC -version`
                    ;;
                *apache* | *httpd*)
                    OUTPUT=`$EXEC -v`
                    ;;
                *bundler* | *rmagick*)
                    OUTPUT=`gem list | grep ^$EXEC `
                    ;;
                *python*)
                    OUTPUT=`$EXEC --version 2>&1`
                    ;;
                *cpanel*)
                    OUTPUT=`$EXEC -V`
                    ;;
                *softaculous*)
                    OUTPUT=`php /usr/local/cpanel/whostmgr/docroot/cgi/softaculous/cli.php -v` 
                    ;;
                *solus*)
                    OUTPUT=`rpm -qa | grep xen-[0-9].*\.soluslabs`
                    ;;
                *onapp*)
                    OUTPUT=`rpm -qa | grep onapp-hv-install`
                    ;;
                *) 
                    OUTPUT=`$EXEC --version`
                    ;;
		    esac 

     		if [[ -n $OUTPUT ]]; then
                case $EXEC in
                    *bundler* | *rake* | *flvtool2* | *rmagick*)
                        VERSION=`echo $OUTPUT | grep -o '\([0-9]\+\.\)\+[0-9]\+'`
                        ;;
                    *solus* | *onapp*)
                        VERSION=`echo $OUTPUT | grep -o '\([0-9]\+\.\)\+[0-9]\+-[0-9]\+'`
                        ;;
                    *)
                        VERSION=`echo $OUTPUT | grep -o '\([0-9]\+\.\)\+[0-9]\+' | head -1`
                        ;;
                esac
                VERSIONLIST=`echo $VERSIONLIST $VERSION`
            fi
        fi
    done
}

VERSIONSFILE="version_list.txt"
if [ -f $VERSIONSFILE ]; then
    for SW in `cat $VERSIONSFILE | cut -d' ' -f1 | uniq `;
    do
	    SW=`echo $SW | tr -d ' \n\r'`
	    getversion $SW

        if [[ -z $VERSIONLIST ]]; then
            VERSIONLIST="NA"
        else 
            #remove doubles in the version list
            VERSIONLIST=`echo $VERSIONLIST | awk '!arr[$1]++' RS=" "`
        fi

        for VERSION in $VERSIONLIST
        do
            echo $SW, $VERSION >> $LOG_TO
        done
    done
else
    echo "ERROR: Could not find $VERSIONS file. Please make sure it is located at `pwd`."
fi

echo "I am \"$ME\" and logging to $LOG_TO"
