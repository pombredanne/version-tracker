version-tracker
===============


  Shell script used to scan common paths on the server ( /usr/bin;/usr/local/bin, etc.) 
and log installed software versions of the programs listed in version_list.txt. 

 

  SYNOPSIS

      getver.sh [-u username | -h]
 
  PARAMETERS
          
      -u username : run the script as user "username" (and ensure that everything is executed/stored under 
                        the user's home directory and not/tmp or elsewhere)
          
      -h          : display help screen
          
  RESULT
  
        getver.log - csv file located in /var/log for root or ~/ for other users
        
  
  NOTES
  
      It is assumed that the script is run as root by default.
      version_list.txt must be present in the same folder as the script.
      Log file is overwritten.
