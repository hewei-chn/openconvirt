#!/bin/bash
# Date Written: Oct 1, 2010
# Convirt
# Desc: This shell script reads each .sql file in the upgrade/rev
# folder and applies it to the database that the user gives as
# input.
# Get the script location
script_path=`readlink -f $0`
base=`dirname $script_path`
#base=`dirname $0`
#echo "Number of arguments is $#"
if [ $# -ne 5 ]; then
   echo "Usage: upgrade_repository.sh <version> <dbtype> <dbname> <dbuser> <dbpasswd>";
   echo "Example:upgrade_repository.sh 2.0-2.0.1 mysql convirt john doe";   
   exit 1
fi
sqlloc=$1
dbtype=$2
dbname=$3
dbuser=$4
dbpasswd=$5
if [ $dbtype = "oracle" ]; then
	ORA_HOME=`echo $ORACLE_HOME`
	export ORACLE_HOME="$ORA_HOME"
	export PATH=$PATH:$ORA_HOME/bin
	export LD_LIBRARY_PATH=$ORA_HOME/lib
	/usr/sbin/setenforce 0	
	if [ "$ORA_HOME" = "" ]; then
	   echo "Please set ORACLE_HOME environment variable"
	   exit 1
	fi
fi	
echo "*******************Started on `date`*********************";
if [ -e $base/$sqlloc ]; then
   #cd $base/upgrade/$sqlloc
   filenames=`echo "$base/$sqlloc/*.sql"`
   #echo $filenames  
   for f in $filenames
    do
     fname=`basename $f`
     if [ $dbtype = "mysql" ]; then
            echo "mysql file $f"
            mysql -u$dbuser -p$dbpasswd $dbname < $f
     elif [ $dbtype = "oracle" ]; then
             if [ -e $base/$sqlloc/oracle/$fname ]; then
            	echo "specific oracle file in $base/upgrade/$sqlloc/oracle/$fname"
                sqlplus  -s $dbuser/$dbpasswd@localhost:1521/xe < $base/$sqlloc/oracle/$fname 
             else
            	echo "oracle file in common $f"
                sqlplus -s $dbuser/$dbpasswd@localhost:1521/xe  < $f
             fi
     else 
       echo " Invalid dbtype - dbtype should be oracle or mysql (case sensitive)"
       exit 1
     fi
    done
else
   echo "Can not find the specified upgrade directory : "$sqlloc
   exit 1
fi
echo "*******************Ended on `date`*********************";
