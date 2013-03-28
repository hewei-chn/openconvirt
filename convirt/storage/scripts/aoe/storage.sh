#!/bin/bash 
#
#   ConVirt   -  Copyright (c) 2008 Convirture Corp.
#   ======
#
# ConVirt is a Virtualization management tool with a graphical user
# interface that allows for performing the standard set of VM operations
# (start, stop, pause, kill, shutdown, reboot, snapshot, etc...). It
# also attempts to simplify various aspects of VM lifecycle management.
#
#
# This software is subject to the GNU General Public License, Version 2 (GPLv2)
# and for details, please consult it at:
#
#    http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
# 
#
# author : mkelkar@users.sourceforge.net
#



# parse the command line parameters
while getopts t:o:p:c:s:l:w: a
do case "$a" in
        t)      storage_type="$OPTARG";;
        o)      command="$OPTARG";;
        p)      usernameAndpassword="$OPTARG"
                ;;
        c)      serverAndstorageTarget="$OPTARG"
                ;;
	s)      script_loc="$OPTARG"
                ;;
        l)      logfilename="$OPTARG"
                ;;
        w)      fileFilter="$OPTARG"
                ;;
      * )
          echo "$OPTARG"
          ;;
        esac
done

# source common files
source "$script_loc/storage_functions"

check_prerequisite '' 'aoe-stat'

echo "$command $storage_type $username $password $server $target" >>$logfilename

if [ "$command" == "" ]; then
  echo "ERROR:The required parameter command is missing."
  exit 1
fi



case "$storage_type" in
  aoe )
    case "$command" in
      GET_DISKS | GET_DISKS_SUMMARY) output=`aoe-stat | awk '{print "OUTPUT=OUTPUT|uuid=/dev/etherd/"$1"|SIZE="$2"|INTERFACENAME="$3"|State="$4"\r\n"}' | sed 's/SIZE=\(.*\)GB/SIZE=\1/'`
                  check_function_return_value "Unable to get stat:$output"
                  echo $output
                  #;; Fall through
       #GET_DISKS_SUMMARY) 
                  total=0
                  for size in `aoe-stat | awk '{print $2}' | sed 's/GB//'`
                  do 
                    total=`echo $total + $size | bc`
                  done
                  echo "SUMMARY=SUMMARY|TOTAL=${total}"
                  ;;
      DETACH ) 
                  ;;
      ATTACH ) 
               ;;
      * )
          echo "Usage: -t{aoe} -o{GET_DISKS|DETACH|ATTACH}"
          exit 1
          ;;
  esac
esac
