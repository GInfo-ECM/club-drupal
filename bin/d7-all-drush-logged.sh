#!/bin/sh

. /home/assos/bin/scripts-config.sh
. scripts-utils.sh

help="# ARGS: drush_command"

check_arguments $# 1 "$help"

cd $d7_dir_sites

for dir in `find . -maxdepth 1 -mindepth 1 -type d ! -name all | sort` ; do
    cd $dir
    current_date=`date "+%Y-%m-%d_%Hh:%Mm"`
    echo "======$current_date======" >> $d7_dir_log/$dir.log
    echo "Arguments are: $* " >> $d7_dir_log/$dir.log
    drush $* >> $d7_dir_log/$dir.log
    #To have the same caracters limit we needed 'end' that have 4 caracters, we used the Croate language for this ! LOL
    echo -e "=============KRAJ=============\n" >> $d7_dir_log/$dir.log
    cd -
done
