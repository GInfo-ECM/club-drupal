#!/bin/sh

. /home/assos/bin/scripts-config.sh
. scripts-utils.sh

help="# ARGS: drush_command"

check_arguments $# 1 "$help"

#Store the drush command name (sqlq, vget, cron). This is the first argument. 
drush_command_name="$1"
#shift will remove the fist argument so that $* will have the second, third...arguments.
shift
for dir in $(find $d7_dir_sites -maxdepth 1 -mindepth 1 -type d ! -name all | sort) ; do
    cd $dir
    echo $dir
    drush  $drush_command_name """$*"""
done
