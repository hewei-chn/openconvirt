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

# Jd: fix time formatting issue between centos/rhel and ubuntu/debian flavors
# Jd: Look for by-path first, then by-id, on CentOS, RHEL there seems to be a
#     problem with iscsi where by-path are generated only for last device. 
#     This seems to be a problem with iscsiadm version 2.0-868 
# Note : If all machines are same version, then things should work fine.

function make_automatic {
    output=`grep 'node.startup = manual' /etc/iscsi/iscsid.conf`
    if [ "${output}" != "" ]; then
        sed -i 's|node.startup = manual|node.startup = automatic|' /etc/iscsi/iscsid.conf
    fi
}

function parse_disk_details {
    target=`iscsiadm -m session --sid $1 -P3 2>/dev/null | grep "Target:" | sed  's/:/=/;s/ //'`
    portal=`iscsiadm -m session --sid $1 -P3 2>/dev/null | grep "Current" | sed    's/:/=/;s/ //'` 
    total=0
    for i in `iscsiadm -m session --sid $1 -P3 2>/dev/null | grep "Lun\|Attached.*disk" | grep -B1 "State:" | sed '$!N;;s/\n/ /' | awk '{print $6"="$7"|device="$11"|"$12"="$13}'`
   do
    uuid=""
    device_name=`echo $i | awk -F'|' '{print $2}' | cut -d'=' -f2`

    #Get disk size. We have issue in getting disk in first attempt. So we are looping through for 10 times.
    #If in between, we get the disk size then we are breaking the loop.
    counter=0
    while [ $counter -le 10 ];
    do
        output=`iscsiadm -m discovery -t st -p "$server" 2>&1 2>/dev/null`
        output=`iscsiadm -m session --sid $1`
        disk_size=`fdisk -l /dev/${device_name} 2>/dev/null | grep "Disk /dev/${device_name}" | awk '{print $5}'`
        if [ "$disk_size" != "" ]; then
            break
        fi
        (( counter++ ))
    done

    #disk size check is to avoid "(standard_in) 1: parse error"
    if [ "$disk_size" == "" ]; then
        disk_size=0
    fi
    disk_size_in_GB=`echo "scale=2; $disk_size / 1024 /1024 /1024" | bc`
    lun=`echo $i | awk -F'|' '{print $1}' | sed 's/://'`
    state=`echo $i | awk -F'|' '{print $3}' | sed  's/://'`
    # look for in /dev/disk/by-uuid
    uuid=`ls -al --time-style="+%Y-%m-%d %H:%M:%S" /dev/disk/by-uuid/* 2>/dev/null | grep ${device_name}$ | awk '{print $8}'`
    # if not found look for in /dev/disk/by-path
    if [ "$uuid" == "" ]; then
	uuid=`ls -al --time-style="+%Y-%m-%d %H:%M:%S" /dev/disk/by-path/* 2>/dev/null | grep ${device_name}$ | awk '{print $8}'`
    fi
    # if not found look for in /dev/disk/by-id
    if [ "$uuid" == "" ]; then
	uuid=`ls -al --time-style="+%Y-%m-%d %H:%M:%S" /dev/disk/by-id/* 2>/dev/null | grep ${device_name}$ | awk '{print $8}'`
    fi
    # if not just return the path
    if [ "$uuid" == "" ]; then
        echo "Could not find uuid for ${device_name}, using ${device_name} as uuid"
	uuid=/dev/${device_name}
    fi
    echo "OUTPUT=OUTPUT|$target|$portal|$lun|mount_point=/dev/${device_name}|SIZE=$disk_size_in_GB|$state|uuid=$uuid"
    total=`echo "$total + $disk_size_in_GB" | bc`
   done;
   echo "SUMMARY=SUMMARY|TOTAL=${total}"
}




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
        w)      fileFilter="$OPTARG";;
      * )
          echo "$OPTARG"
          ;;
        esac
done

# source common files
source "$script_loc/storage_functions"


# parse user name and password
parse_field_values $usernameAndpassword 'username'
username=$value
parse_field_values $usernameAndpassword 'password'
password=$value

# parse the iscsi target
parse_field_values $serverAndstorageTarget 'server'
server=$value
parse_field_values $serverAndstorageTarget 'target'
target=$value

# run prereqs
check_prerequisite 'iscsi' 'iscsiadm'

# validate params
if [ "$storage_type" == "" ]; then
  echo "ERROR:The required parameter storage type is missing."
  exit 1
fi
if [ "$command" == "" ]; then
  echo "ERROR:The required parameter command is missing."
  exit 1
fi

if [ "$server" == "" ]; then
  echo "ERROR:The required parameter server is missing."
  exit 1
fi

if [ "$target" == "" ]; then
  echo "ERROR:The required parameter target is missing."
  exit 1
fi

case "$storage_type" in
  iscsi )
    case "$command" in
      GET_DISKS | GET_DISKS_SUMMARY) 
	      
                if [ "$username" != "" ]; then
                    output=`iscsiadm -m node --targetname ${target} --op=update --name=node.session.auth.authmethod --value=CHAP 2>&1`
                    check_function_return_value "Unable to authenticate:${output}"

                    output=`iscsiadm -m node --targetname ${target} --op=update --name=node.session.auth.username --value=${username} 2>&1`
                    check_function_return_value "Unable to update username:${output}"

                    output=`iscsiadm -m node --targetname ${target} --op=update --name=node.session.auth.password --value=${password} 2>&1`
                    check_function_return_value "Unable to update password:${output}"

                fi

                  iscsiadm --mode node --targetname ${target} --portal $server --login 2>&1
	      
                  output=`iscsiadm -m discovery -t st -p "$server" 2>&1 2>/dev/null`
                  check_function_return_value "Unable to connect to server:$output"

                  total=0
                  sessionId=`iscsiadm -m session | grep "${target}" | sed 's@\[\(.*\)\] .*@\1@g' | cut -d':' -f2 2>&1 2>/dev/null`
                  check_function_return_value "Unable to get sessionId for:$sessionId"
                  parse_disk_details $sessionId
                  ;;

      DETACH ) output=`iscsiadm --mode node --targetname ${target} --portal $server -u --logout 2>&1 `
               check_function_return_value "Unable to logout:$output"
               ;;

      ATTACH ) make_automatic
               if [ "$username" != "" ]; then
                    output=`iscsiadm -m node --targetname ${target} --op=update --name=node.session.auth.authmethod --value=CHAP 2>&1`
                    check_function_return_value "Unable to authenticate:${output}"

                    output=`iscsiadm -m node --targetname ${target} --op=update --name=node.session.auth.username --value=${username} 2>&1`
                    check_function_return_value "Unable to update username:${output}"

                    output=`iscsiadm -m node --targetname ${target} --op=update --name=node.session.auth.password --value=${password} 2>&1`
                    check_function_return_value "Unable to update password:${output}"

               fi
               output=`iscsiadm --mode discovery --type sendtargets --portal $server 2>&1`
               check_function_return_value "Unable to connect to server:$output"

                #check whether session exists or not. If session not exists then login
                sessionId=`iscsiadm -m session | grep "${target}" | sed 's@\[\(.*\)\] .*@\1@g' | cut -d':' -f2 2>&1 2>/dev/null`
                if [ "${sessionId}" == "" ] ; then
                    echo "Logging to iscsi target"
                    output=`iscsiadm --mode node --targetname ${target} --portal $server --login 2>&1`
                    check_function_return_value "Unable to login:$output"
                fi
               ;;
      * )
          #echo "Usage: -t{iscsi} -o{GET_DISKS|DETACH|ATTACH}"
          exit 1
          ;;
  esac
esac
