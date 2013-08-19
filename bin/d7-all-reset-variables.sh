#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

for dir in `find $d7_dir_sites -maxdepth 1 -mindepth 1 -type d ! -name all | sort` ; do
    cd $dir
    echo $dir
    d7-reset-variables.sh
done
