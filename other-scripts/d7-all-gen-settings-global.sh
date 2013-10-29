#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. scripts-utils.sh

for dir in `find $d7_dir_sites -maxdepth 1 -mindepth 1 -type d ! -name all` ; do
    cd $dir
    pwd
    chmod 700 settings.php
    rm settings.php
    cp ../template.settings.php ./settings.php
    chmod 400 settings.php
done
