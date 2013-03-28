#!/bin/bash
# Date Written: May 20, 2011
# Convirt
# Desc: This shell script checks to see if the CentOS patch for  
# mysql needs to be run or not.  In some cases of CentOS mysql 
# does not create the foreign key constraint.  In such cases a patch
# has to be applied as supplied from Convirt
if [ $# -ne 3 ]; then
  echo "***************************************************************************"
   echo "Usage: centospatch.sh <dbname> <dbuser> <dbpasswd>";
   echo "Example:centospatch.sh convirt john doe";
  echo "***************************************************************************"
   exit 1
fi
dbname=$1
dbuser=$2
dbpasswd=$3
centoschk=`mysql -u$dbuser -p$dbpasswd $dbname < centoschk.sql | grep -i constraint`
if [[ -n $centoschk ]]; then
  echo "***************************************************************************"
  echo "Please proceed to Upgrade"
  echo "***************************************************************************"
else
  echo "***************************************************************************"
  echo "Please follow instructions to run the CentOS patch and then do the Upgrade"
  echo "***************************************************************************"
fi
