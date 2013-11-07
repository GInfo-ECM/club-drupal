#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

# This script puts the correct permissions to sites folders, settings.php and scripts.

######### drupal 6
for dir in `find $d6_dir_sites -type d -maxdepth 1 -mindepth 1 ! -name all ! -name images ! -name languages` ; do
    chmod 755 $dir
    chmod 400 $dir/settings.php
done

######### drupal 7
for dir in `find $d7_dir_sites -type d -maxdepth 1 -mindepth 1 ! -name all` ; do
    chmod 755 $dir
    chmod 400 $dir/settings.php
    chmod 400 $dir/settings.local.php
done

####### bin
chmod -R 700 $dir_scripts

####### backup
chmod -R 700 $dir_backup

####### log
chmod -R 700 $dir_log

####### private
chmod -R 700 $dir_private
