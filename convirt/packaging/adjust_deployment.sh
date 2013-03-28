#!/bin/bash
# Adjust development.ini. Pass on full path to development.ini
adjust_dev_ini()
{
  dev_ini=$1

  echo "Processing $1"
  BACKUP_SUFFIX=`date +"%Y%m%d.%H%M%S"`
  sed -i "
    /image_store/ { s/image_store.*/image_store=\/var\/lib\/convirt\/image_store/ }
    /appliance_store/ { s/appliance_store.*/appliance_store=\/var\/lib\/convirt\/appliance_store/ }
    /updates_file/ {s/updates_file.*/updates_file=\/var\/lib\/convirt\/updates\/updates.xml/ }
    /snapshots_dir/ {s/snapshots_dir.*/snapshots_dir=\/var\/lib\/convirt\/snapshots/ }
    /VM_CONF_DIR/ {s/VM_CONF_DIR.*/VM_CONF_DIR=\/var\/lib\/convirt\/vm_configs/ }
    /user_config/ {s/user_config.*/user_config=\/var\/lib\/convirt\/user_config/ }
    /hash_dir/ {s/hash_dir.*/hash_dir=\/var\/lib\/convirt\/hash_dir/ }
    /cache_dir/ {s/cache_dir.*/cache_dir=\/var\/run\/convirt\/data/ }
    /ssh_file/ {s/ssh_file.*/ssh_file=\/var\/lib\/convirt\/identity\/cms_id_rsa/ }
    /sqlalchemy.url/ {s/mysql:\/\/root:convirt/mysql:\/\/root:/ }
    /args.*=.*paster.log/ { s/'paster.log'/'\/var\/log\/convirt\/paster.log'/ }
    /args.*=.*convirt.log/ { s/'convirt.log'/'\/var\/log\/convirt\/convirt.log'/ }
  " $dev_ini
}

taint_deployment()
{
# taint the version for .deb files
  utils_py=$1

  echo "Processing $1"
  BACKUP_SUFFIX=`date +"%Y%m%d.%H%M%S"`
  sed -i "
    /deployment.deployment_id=guid/ { s/$/ + \'-deb\'/ }
  " $utils_py
}

# TBD : Adjust setup.py
adjust_setup_py()
{
   # This one needs to remove all dependencies.. so at setup time and install time no packages are 
   # pulled in.
   # Ofcourse, we need to make sure that the dependencies required by ConVirt are met using .deb
   # packages.
   setup_file=$1

   echo "Processing $setup_file is not implemented, but instead reference file is used." 
   echo "Copying the setup.py from packaging directory."

   echo "cp $CONVIRT_DIR/packaging/setup.py $setup_file"
   cp $CONVIRT_DIR/packaging/setup.py $setup_file

}

adjust_egg_info()
{
   egg_info_dir=$1

   echo "Copying the egg_info_dir from packaging directory, to avoid running python setup.py"

   echo "cp -r $CONVIRT_DIR/packaging/convirt.egg-info $egg_info_dir"
   rm -rf $egg_info_dir/convirt.egg-info
   cp -r $CONVIRT_DIR/packaging/convirt.egg-info $egg_info_dir
}

adjust_install_config()
{
  install_config=$1

  echo "Processing $1"
  BACKUP_SUFFIX=`date +"%Y%m%d.%H%M%S"`
  sed -i.${BACKUP_SUFFIX} "
    /CONVIRT_BASE/ { s/CONVIRT_BASE=~/CONVIRT_BASE=\/opt/ }
  " $install_config
}


## main
CONVIRT_DIR=$1

PRG_BASE=`dirname $0`
BASE=`readlink -f $PRG_BASE`

if [ "${CONVIRT_DIR}" == "" ]; then
   CONVIRT_DIR=`readlink -f $BASE/..`
   echo "Deployment Location not specified.e.g. /opt/convirt"
   echo "The current location $CONVIRT_DIR would be used."
fi

DEV_INI=$CONVIRT_DIR/src/convirt/web/convirt/development.ini
SETUP_PY=$CONVIRT_DIR/src/convirt/web/convirt/setup.py
CONVIRT_CTL=$CONVIRT_DIR/convirt-ctl
CONVIRT_INSTALL_CONFIG=$CONVIRT_DIR/install/cms/scripts/install_config
CONVIRT_EGG_INFO_DIR=$CONVIRT_DIR/src/convirt/web/convirt
UTILS_PY=$CONVIRT_DIR/src/convirt/core/utils/utils.py


adjust_dev_ini $DEV_INI
adjust_setup_py $SETUP_PY
adjust_install_config $CONVIRT_INSTALL_CONFIG
adjust_egg_info $CONVIRT_EGG_INFO_DIR

taint_deployment $UTILS_PY



