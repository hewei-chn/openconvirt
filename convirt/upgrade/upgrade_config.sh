#!/bin/bash
# Date Written: Oct 1, 2010
# Convirt
# Desc: This shell script updates the development.ini from 
# It saves the original development.ini as development.ini_bak
# 2.0 to 2.0.1.
############################################################################
script_path=`readlink -f $0`
base=`dirname $script_path`
devloc="$base/../src/convirt/web/convirt"

# This needs to be refactored and moved into respective directory

if [ $# -ne 1 ]; then
   echo "Usage : upgrade_config.sh <from_ver-to_ver>"
   echo "Example : upgrade_config.sh 2.0-2.0.1"
   exit 1
fi


if [ ! -d "$base/$1" ]; then
   echo "$base/$1 directory does not exist."
   echo "Please provide exact upgrade versions."
   exit 1
fi

backup_ext=".orig.`date +"%Y%m%d.%H%M%S"`"

# save the original config file.
DEV_INI="$devloc/development.ini"
/bin/cp $DEV_INI $DEV_INI${backup_ext}

if [ "$?" != "0" ]; then
   echo "Error backing up $devloc/development.ini"
   exit 1
fi

echo "Sourcing $base/$1/upgrade_config"
source "$base/$1/upgrade_config"

# invoke the version specific function
upgrade_config "$base" "$DEV_INI"
if [ "$?" != 0 ]; then
   echo "Error upgrdaing configuration file."
   exit 1
fi

echo "Upgrade of configuration file succeeded."
