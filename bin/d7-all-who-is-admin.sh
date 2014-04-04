#!/bin/sh

. /home/assos/bin/scripts-config.sh

for dir in $(find $d7_dir_sites -maxdepth 1 -mindepth 1 -type d ! -name all | sort) ; do
    cd $dir
    echo $dir
    drush sqlq "SELECT name, mail FROM users WHERE uid IN (SELECT uid FROM users_roles WHERE rid=3);"
done
