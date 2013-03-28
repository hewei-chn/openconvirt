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



ORIGCONFIG="/etc/xen/xend-config.sxp"
XEN_VER="4.1"
if [ "$1" !=  "" ]; then
    XEN_VER="$1"
    XEN_VER=${XEN_VER:0:3} # major.minor is enough
fi

if [ "$XEN_VER" != "4.1" ]; then
    echo "Only Xen 4.1 supported."
    exit 1
fi

USE_SSL=""
# check if SSL setup needs to be done or not.
if [ "$2" ==  "SSL" ]; then
    USE_SSL="SSL"
fi

MULTI_BRIDGE_SETUP=$3
BRIDGE_SETUP=$4


OPENSSL=openssl
if [ "$USE_SSL" == "SSL" ]; then
    python -c "import OpenSSL" &> /dev/null
    if [ "$?" != 0 ]; then
       echo "pyOpenSSL not found. Please make sure that pyOpenSSL is installed."
       exit 1 
    fi
    
    echo "Setting up self signed certificates"
    $OPENSSL version &> /dev/null
    if [ "$?" != 0 ]; then
       echo "$OPENSSL not found. Please make sure that openssl is installed and is in path."
       exit 1 
    fi
    # create a respose file for ssl certificate creation

    # Modify the certificate params for deployment details on response 
    # is as follows

    # Country Name (2 letter code)
    # State or Province Name (full name)
    # Locality Name (e.g. city)
    # Organization Name (eg, company)
    # Organizational Unit Name (eg, section)
    # Common Name (eg, your name or your server's hostname) 
    # Email Address 
    # A challenge password 
    # An optional company name 

    SSL_TEMP_FILE=`mktemp -t open_ssl.res.XXXXXXXXXX`
    cat  <<EOF > $SSL_TEMP_FILE
US
CA
SF
Test Corp
.
$HOSTNAME
.
.
.
EOF
    KEY=/etc/xen/xmlrpc.key
    CSR=/etc/xen/xmlrpc.csr
    CRT=/etc/xen/xmlrpc.crt
    $OPENSSL genrsa -out $KEY 1024
    $OPENSSL req -new -key $KEY -out $CSR < $SSL_TEMP_FILE
    $OPENSSL x509 -req -in $CSR -signkey $KEY -out $CRT
    rm $SSL_TEMP_FILE
fi

# Adjust the regexp for the config file
SPACE=" "
if [ "$USE_SSL" == "SSL" ]; then
   SPACE=""
fi

#save the config file
cp $ORIGCONFIG $ORIGCONFIG.orig.`date +"%Y%m%d.%H%M%S"`

# make the necessary configuration changes to 
# enable xml-tcp-rpc and domain relocation.
sed -i "
# Enable tcp-xmlrpc
/(xend-tcp-xmlrpc-server$SPACE/ {s/^#//;s/no/yes/}
/(xend-tcp-xmlrpc-server-address/ {s/#//;s/'localhost'/''/}
/(xend-tcp-xmlrpc-server-port/ {s/#//}

# Enable relocation server and addresses
/(xend-relocation-port/ s/^#//
/(xend-relocation-server$SPACE/ {s/^#//;s/no/yes/}
/(xend-relocation-address$SPACE/ s/^#//

# Allow relocation to any host.
/(xend-relocation-hosts-allow '')/ s/^#//
/^(xend-relocation-hosts-allow.*localhost/ s/^/#/

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

## THIS IS NOT REQUIRED and DOES NOT WORK.
## TYPO IN xend-config.sxp is fixed through regexp above
# patch XMLRPCServer
#sh ./patch_XMLRPCServer XMLRPCServer.py-$XEN_VER-diff

# restart xend for the new config to take effect.
#/sbin/service xend restart
/etc/init.d/xend restart
if [ $? -ne 0 ]; then
    exit 1
fi
exit 0

