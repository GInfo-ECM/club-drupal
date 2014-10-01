#!/bin/sh

. /home/assos/bin/scripts-config.sh
. scripts-utils.sh

help="# ARGS: drush_command"

check_arguments $# 1 "$help"

for dir in $(find $d7_dir_sites -maxdepth 1 -mindepth 1 -type d ! -name all | sort) ; do
    cd $dir
    echo $dir
    drush -q cron
    sleep $1
done
