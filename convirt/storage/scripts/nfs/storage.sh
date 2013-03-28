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
function remove_mount
{
    sed -i "s|${server}:${share} ${mountpoint} ${storage_type} defaults||" /etc/fstab
}

function scan_disks
{
   for i in `find ${mountpoint} -type f -name "${fileFilter}" -printf "%p %k %s\n" 2>/dev/null | awk '{print "Disk="$1"|Used="$2"|Available="$3""}'`    
    do
    disk_name=`echo $i | awk -F'|' '{print $1}' | cut -d'=' -f2`
    used_size=`echo $i | awk -F'|' '{print $2}' | cut -d'=' -f2`
    size=`echo $i | awk -F'|' '{print $3}' | cut -d'=' -f2`
    disk_size=`echo "scale=2; $size/1024/1024/1024" | bc`
    disk_used_size=`echo "scale=2; $used_size/1024/1024" | bc`
    echo "DISK_DETAILS=DISK_DETAILS|uuid=$disk_name|USED=$disk_used_size|SIZE=$disk_size"
    total_size=`echo "scale=2; $total_size+$disk_size" | bc`
    done;
}

while getopts t:o:p:c:s:l:w: a
do case "$a" in
        t)      storage_type="$OPTARG";;
        o)      command="$OPTARG";;
        p)      usernameAndpassword="$OPTARG";;
        c)      mountParams="$OPTARG";;
        l)      logfilename="$OPTARG";;
        s)      script_loc="$OPTARG";;
        w)      fileFilter="$OPTARG";;
        * )
          echo "$OPTARG"
          ;;
        esac
done

total_size=0

# source common files
source "$script_loc/storage_functions"

parse_field_values $mountParams 'server'
server=$value
parse_field_values $mountParams 'mount_point'
mountpoint=$value
parse_field_values $mountParams 'share'
share=$value

check_prerequisite '' 'df'

echo "DateTime: $(date)" >>$logfilename
echo "$command $storage_type $server" >>$logfilename

isRequiedParamPresent ${command} 'command'

case "$storage_type" in
  nfs )  
    case "$command" in

      GET_DISKS | GET_DISKS_SUMMARY ) output=`df --block-size=G | grep -v "Used" |  awk '{ if (NF == 1)  printf("%s ", $0); else print;}' |   grep -w ${server} | awk '{ if ($6 == "'${mountpoint}'") print; }' |  awk '{sub(/G/,"",$2); sub(/G/,"",$3); sub(/G/,"",$4); print "OUTPUT=OUTPUT|FILESYSTEM="$1"|SIZE="$2"|USED="$3"|AVAILABLE="$4"|MOUNT="$6""}'`
                  check_function_return_value "Unable to get stat:$output"
                  if [ "${output}" = "" ]; then
                    echo "ERROR:server name or mount point is incorrect"
                    exit 1
                  fi
                  echo $output
                  scan_disks
                #  ;; Fall through
      #GET_DISKS_SUMMARY)
                  total=0
                  output=`df --block-size=G | grep -v "Used" |  awk '{ if (NF == 1)  printf("%s ", $0); else print;}' |   grep -w ${server} | awk '{ if ($6 == "'${mountpoint}'") print; }' |  awk '{sub(/G/,"",$2); sub(/G/,"",$3); sub(/G/,"",$4); print "SUMMARY=SUMMARY|TOTAL="$2""}'` #$2 #'${total_size}'
                  echo $output
                  ;;
       DETACH ) umount ${mountpoint}
                remove_mount
                  ;;
       ATTACH ) #check whether mountpoint exists or not, if not then mount storage.
                #here first check for share and mountpoint 
                #then check for for server, share and mountpoint in case share is on different machine.
                output=`mount | awk '{if ($1 == "'${share}'" && $3 == "'${mountpoint}'") print;}'`
                if [ "${output}" == "" ] ; then
                    temp_share="${server}":"${share}"
                    output=`mount | awk '{if ($1 == "'${temp_share}'" && $3 == "'${mountpoint}'") print;}'`
                    if [ "${output}" == "" ] ; then
                        echo "Mounting nfs storage..."
                        mount -t ${storage_type} ${server}:${share} ${mountpoint}

                        #check mountpoint entry in fstab
                        output=`grep "'${share}'" /etc/fstab | awk '{if($2 == "'${mountpoint}'") print};'`
                        if [ "${output}" == "" ] ; then
                            output=`grep "'${temp_share}'" /etc/fstab | awk '{if($2 == "'${mountpoint}'") print};'`
                            if [ "${output}" == "" ] ; then
                                #add to fstab
                                echo "Adding entry to fstab..."
                                echo "${server}:${share} ${mountpoint} ${storage_type} defaults" >> /etc/fstab
                            fi
                        fi
                    else
                        echo "nfs storage already mounted..."
                    fi
                fi
                  ;;
      * )
          echo "Usage: -t{nfs} -o{GET_DISKS|DETACH|ATTACH}"
          exit 1
          ;;
  esac
esac
