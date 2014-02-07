#!/usr/bin/bash

help=<<EOF
This script is intended to ease the synchronisation of any site hosted by assos. It relies on bash, drush and requires @ssh assos@ to work.
The drupal installation is synched using git, the website files and database using rsync.

usage: d7-sync.sh [SITENAME]
If a sitename is provided, the script will sync the drupal installation and the sites'
folders and database. Othewise, only the drupal installation is synched.

You must launch this script at the root of the drupal instance.
EOF

### sync drupal tree
git pull --rebase

### sync files
if [ -z "$1" ] ; then
    exit 0
fi

root=$(pwd)
cd htmltest/sites

ret=$?
if [ $ret -ne 0 ] ; then
    echo 'Not in the right directory. Exiting.'
    exit 1
fi

if [ $1 = default ] ; then
    dir_site=$1
else
    dir_site=assos.centrale-marseille.fr.$1
fi
mkdir $dir_site
cd $dir_site
rsync -rl --progress assos:~/htmltest/sites/$dir_site/* .
# Change permissions for Apache
# TODO: do something less permissive than 755
chmod -R 755 .
chmod -R 777 files


### sync databases
now=$(date +%s)
sql_file="$1.$now.sql"
remote_sql_file="~/tmp/$sql_file"
ssh assos "drush @$1 sql-dump > $remote_sql_file"
scp assos:$remote_sql_file .
mysql -u root -e "DROP DATABASE IF EXISTS $1; CREATE DATABASE $1"
mysql -u root $1 < $sql_file
rm $sql_file
ssh assos "rm $remote_sql_file"

### modify settings.php
python3 $root/other-scripts/modify-settings.py settings.local.php --baseurl assos.local/$1

### various drush cmd to finish synchronisation
drush -y dis piwik
drush -y vset maintenace_mode 0
drush -y vset error_level 2
drush cc all
