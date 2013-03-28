#!/bin/bash
# 
# This script modifies the xend configuration file: xend-config.sxp
# to allow xmlrpc access over tcp and to allow domain relocation
# (migration) to all hosts.
#
#
#  Author - Haphazard
#  Copyright (c) 2007 Convirture Corporation
# 
#
# This software is subject to the GNU Lesser General Public License (LGPL)
# available at: http://www.fsf.org/licensing/licenses/lgpl.txt
#

base=`dirname $0`

ORIGCONFIG="/etc/xen/xend-config.sxp"

if [ "$1" ==  "" ]; then
    echo "Usage :$0 <xen_version>"
    echo "xen_version not specified. "
    echo "Please specify 3.0.3 or 3.0.4 depending on you Xen version." 
    exit 1 
fi

if [ "$1" !=  "" ]; then
    XEN_VER="$1"
    if [ "$XEN_VER" != "3.0.3" ] && [ "$XEN_VER" != "3.0.4" ]; then
       echo "Invalid xen version : supported Xen version are 3.0.3 and 3.0.4."
       exit 1 
    fi
fi

MULTI_BRIDGE_SETUP=$3
BRIDGE_SETUP=$4

#save the config file
cp $ORIGCONFIG $ORIGCONFIG.orig.`date +"%Y%m%d.%H%M%S"`


# make the necessary configuration changes to 
# enable xml-tcp-rpc and domain relocation.
sed -i "
# Enable tcp-xmlrpc
/xend-tcp-xmlrpc-server/ {s/^#//;s/no/yes/}

# Enable relocation server and addresses
/(xend-relocation-port/ s/^#//
/(xend-relocation-server/ {s/^#//;s/no/yes/}
/(xend-relocation-address/ s/^#//

# Allow relocation to any host.
/(xend-relocation-hosts-allow '')/ s/^#//
/^(xend-relocation-hosts-allow.*localhost/ s/^/#/

# for ubuntu fix the bridge entry
/(network-script / s/network-dummy/network-bridge/

" "$ORIGCONFIG"

if [ "$BRIDGE_SETUP" == "true" ]; then
  sed -i "
  # for ubuntu fix the bridge entry ???
  /(network-script / s/network-dummy/network-bridge/
  #
  s/(network-script )/(network-script network-bridge)/
" "$ORIGCONFIG"
fi

if [ "$BRIDGE_SETUP" == "true" ] && [ "$MULTI_BRIDGE_SETUP" == "true" ]; then
  sed -i "
  #enable public network bridge setup with custom script
  /^#(network-script[ ]*network-bridge)/ {s/^#//;s/network-bridge)/convirt-xen-multibridge)/}
  /^(network-script[ ]*network-bridge)/ {s/network-bridge)/convirt-xen-multibridge)/}
 /^#(vif-script[ ]*vif-bridge)/ s/^#//
 /^(network-script[ ]*network-route)/ s/^/#/
 /^(vif-script[ ]*vif-route)/ s/^/#/
 /^(network-script[ ]*network-nat)/ s/^/#/
 /^(vif-script[ ]*vif-nat)/ s/^/#/
 " "$ORIGCONFIG"
fi

echo "Modified xend-config successfully"

# patch XMLRPCServer
sh $base/patch_XMLRPCServer $base/XMLRPCServer.py-$XEN_VER-diff

if [ "$?" != 0 ]; then
   echo "Patching failed."
   exit 1
fi

# restart xend for the new config to take effect.
#/sbin/service xend restart
/etc/init.d/xend restart
if [ $? -ne 0 ]; then
    exit 1
fi
exit 0

