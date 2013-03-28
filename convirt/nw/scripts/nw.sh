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

#echo "Invoked with ", $*
# parse the command line parameters
while getopts t:v:i:p:d:n:l:o:s:b: a
do case "$a" in
        t)      network_type="$OPTARG";;
        v)      vlan="$OPTARG";;
        i)      ip_network=`echo "$OPTARG" | cut -d'=' -f2` ;;
        p)      bondinfo="$OPTARG" ;;
	d)      dhcp_start=`echo "$OPTARG" | cut -d'|' -f1 | cut -d'=' -f2`
	        dhcp_end=`echo "$OPTARG" | cut -d'|' -f2 | cut -d'=' -f2`;;
	n)      interfaceName=`echo "$OPTARG" | cut -d'=' -f2`;;
        l)      logfilename="$OPTARG" ;;
        o)      command="$OPTARG" ;;
        s)      script_loc="$OPTARG" ;;
        b)      bridge_name=`echo "$OPTARG" | cut -d'|' -f3 | cut -d'=' -f2`
                netmask=`echo "$OPTARG" | cut -d'|' -f1 | cut -d'=' -f2`
                ip_address=`echo "$OPTARG" | cut -d'|' -f2 | cut -d'=' -f2`
                ;;
      * )
          echo "$OPTARG"
          ;;
   esac
done
echo "DateTime: $(date)" >>$logfilename
echo $script_loc
echo $network_type $ip_network $ip_address $dhcp_start $dhcp_end $intefaceName $bridge_name >>$logfilename

# source common files
common_scripts=$script_loc/../../common/scripts
source "$common_scripts/utils"
source "$common_scripts/functions"
source "$common_scripts/nw_functions"
detect_distro
if [ "$?" != "0" ]; then
   echo "Error detecting Linux distribution.Exiting."
   exit 1
fi

# dump information
echo "DISTRO ${DIST}" >>$logfilename
echo "VER ${VER}" >>$logfilename
echo "CODENAME ${CODE_NAME}" >>$logfilename
echo "KERNEL ${KERNEL}" >>$logfilename
echo "ARCH ${ARCH}" >>$logfilename

# include the distro specific file if it exists.
distro_functions=$common_scripts/${DIST}_functions
if [ -r $distro_functions ]; then
    echo "Info: Sourcing $distro_functions"
    source $distro_functions >>$logfilename
else
   echo "Info: $distro_functions not found." >>$logfilename
fi



NETWORK_CONF_FILE=$script_loc/../../networks/privatenw.conf

add_bridge_information() {
  if [ ! -e "$NETWORK_CONF_FILE" ]; then
    mkdir -p `dirname $NETWORK_CONF_FILE`
    touch $NETWORK_CONF_FILE 
  fi
  if [ `grep -c1 "$bridge_name" $NETWORK_CONF_FILE` -eq 0 ]; then 
    echo "BRIDGE_NAME=$bridge_name;IP_NETWORK=$ip_network;IP_ADDRESS=$ip_address;DHCP_START=$dhcp_start;DHCP_END=$dhcp_end;NET_MASK=$netmask;INTERFACE_NAME=$interfaceName"  >> $NETWORK_CONF_FILE
  fi
}
remove_bridge_information() {
  if [  -e $NETWORK_CONF_FILE ]; then
    if [ `grep -c1 "$bridge_name" $NETWORK_CONF_FILE` -eq 1 ]; then 
      cp $NETWORK_CONF_FILE $NETWORK_CONF_FILE.orig
      sed "/BRIDGE_NAME=$bridge_name/d" < $NETWORK_CONF_FILE > $NETWORK_CONF_FILE.new
      mv $NETWORK_CONF_FILE.new $NETWORK_CONF_FILE
      rm $NETWORK_CONF_FILE.orig
    fi
  fi
}

# validate params
if [ "$network_type" == "" ]; then
  echo "ERROR:The required parameter network type is missing."
  exit 1
fi
if [ "$command" == "" ]; then
  echo "ERROR:The required parameter command is missing."
  exit 1
fi

case "$command" in
  GET_DETAILS )
    case "$network_type" in
      HOST_PRIVATE_NW ) 
                  bridges=`brctl show | awk '{print $1=$4}'`
                  ;;
       PUBLIC_NW ) 
               ;;
    esac
    ;;
  ATTACH )
    case "$network_type" in
      HOST_PRIVATE_NW )
              setup_privatenw $bridge_name $ip_network $ip_address $dhcp_start $dhcp_end $netmask $interfaceName $logfileName
              # add bridge information to the configuration file
              add_bridge_information
              ;;
      PUBLIC_NW ) 
               ;;

    esac
     ;;
  DETACH  )
    case "$network_type" in
      HOST_PRIVATE_NW ) 
              remove_bridge_information
              remove_privatenw $bridge_name $ip_network $ip_address $dhcp_start $dhcp_end $netmask $interfaceName $logfilename
                  ;;
      PUBLIC_NW ) 
               ;;
    esac
   ;;
esac
