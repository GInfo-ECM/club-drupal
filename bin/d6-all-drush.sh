#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. scripts-utils.sh

help="# ARGS: drush_command"

check_arguments $# 1 "$help"

for dir in `find $d6_dir_sites -maxdepth 1 -mindepth 1 -type d ! -name all ! -name languages ! -name images | sort` ; do
    cd $dir
    echo $dir
    drush $*
done
