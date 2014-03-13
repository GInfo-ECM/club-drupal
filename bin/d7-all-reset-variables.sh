#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

for dir in `find $d7_dir_sites -maxdepth 1 -mindepth 1 -type d ! -name all | sort` ; do
    echo $dir
    site_name=`echo $dir | tr '.' '\n' | tail -n 1`
    d7-reset-variables.sh $site_name
done
