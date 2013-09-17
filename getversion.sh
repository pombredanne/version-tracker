
#set log path depending on running user
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
        *Railgun*)
            APPNAME="rg-listener"
            ;;
        *)
           	APPNAME=`echo $1 | tr '[:upper:]' '[:lower:]'`
           	;;
    esac
    
    DEPTH=1
    case $APPNAME in
        php)
            PATH_LIST="/usr/local/php* /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin"
            DEPTH=2
            ;;
        cpanel)
            PATH_LIST="/usr/local/cpanel /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin"
            ;;
        *)
            PATH_LIST="/usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin"
            ;;
    esac
	EXECS=`find $PATH_LIST -maxdepth $DEPTH -regextype posix-extended -iregex ".*/${APPNAME}(|[0-9]+|[0-9]+.[0-9]+)"`
    #let sw (gems, libs, etc) that has no exec be processed
    if [[ -z "$EXECS" ]]; then
        EXECS=$APPNAME
    fi
    
	for EXEC in $EXECS
	do
	    if [[ ! -d "$EXEC" ]]; then
		    case $EXEC in
			    *ssh*)
                    OUTPUT=`$EXEC -V 2>&1`
                    ;;        
                *apache* | *httpd*)
                    OUTPUT=`$EXEC -v`
                    ;;
                bundler | rmagick)
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
                *rvsitebuilder*)
                    OUTPUT=`cat /var/cpanel/rvglobalsoft/rvsitebuilder/rvsitebuilderversion.txt`
                    ;;
                *ffmpeg-php*)
                    if [[ $ME = root ]]; then
                        PHPINFOPATH=/etc/httpd/htdocs/phpinfo.php
                    else
                        PHPINFOPATH=~/public_html/phpinfo.php
                    fi
                    OUTPUT=`php $PHPINFOPATH | grep ffmpeg-php | grep -o '\([0-9]\+\.\)\+[0-9]\+' | head -1`
                    ;;
                *ffmpeg*) 
                    OUTPUT=`$EXEC -version`
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
                    *solus* | *onapp* | "ffmpeg")
                        VERSION=`echo $OUTPUT | grep -o '\([0-9]\+\.\)\+[0-9]\+-[0-9]\+'`
                        ;;
                    *mysql*)
                        VERSION=`echo $OUTPUT | grep -o 'Distrib \([0-9]\+\.\)\+[0-9]\+' | cut -d' ' -f2`
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

