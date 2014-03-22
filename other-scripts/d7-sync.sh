#!/usr/bin/env bash

help=<<EOF
This script is intended to ease the synchronisation of any site hosted by assos.
It relies on bash, drush and requires a valid d7-sync-config.sh.
The drupal installation is synched using git, the website files and database using rsync.

usage: d7-sync.sh [SITENAME]
If a sitename is provided, the script will sync the drupal installation and the sites'
folders and database. Othewise, only the drupal installation is synched.

TODO: improve chmod on files.
EOF

### Init
# Config
source d7-sync-config.sh || source d7-sync-config.example.sh
source ~/.bashrc
shopt -s expand_aliases
cd $DIR_MULTIASSOS
ret=$?
if [ $ret -ne 0 ] ; then
    echo "No config file. Exiting."
    exit 2
fi
# git
git checkout master
git branch $LOCAL_BRANCH_NAME

### sync drupal tree
git pull --rebase
git checkout $LOCAL_BRANCH_NAME
# Auto solve conflicts: it takes the version from master in case of conflict.
git rebase master --strategy-option ours

### sync files
if [ -z "$1" ] ; then
    exit 0
fi

cd $DIR_DRUPAL7_SITES

# Some variables are different for default
if [ $1 = default ] ; then
    dir_site=$1
    base_url=http://$DOMAIN
    local_db_name=assos_default
else
    dir_site=assos.centrale-marseille.fr.$1
    base_url=http://$DOMAIN/$1
    local_db_name=$1
fi

mkdir $dir_site
cd $dir_site
rsync_from_assos -rltp --progress --delete drupal7/sites/$dir_site/* .
# Change permissions for Apache
# TODO: do something less permissive than 755
chmod -R 755 .
chmod -R 777 files


### sync databases
now=$(date +%s)
sql_file="$1.$now.sql"
remote_sql_file="~/tmp/$sql_file"
assos "drush @$1 sql-dump > $remote_sql_file"
scp_from_assos $remote_sql_file .
mysql -u root -e "DROP DATABASE IF EXISTS $local_db_name; CREATE DATABASE $local_db_name"
ret=$?
if [ $ret -ne 0 ] ; then
    echo "mysql daemon is not started. Exiting."
    assos "rm $remote_sql_file"
    rm $sql_file
    exit 1
fi
mysql -u root $local_db_name < $sql_file
rm $sql_file
assos "rm $remote_sql_file"

### modify settings.php
python3 $DIR_MULTIASSOS/other-scripts/modify-settings.py settings.local.php --baseurl $base_url --database $local_db_name
chmod 666 *.php

### Modify sites.php
sed "s/\['assos.centrale-marseille.fr[a-b1-9]*/['$DOMAIN/g" < $SITES_PHP > $SITES_PHP.tmp
mv $SITES_PHP.tmp $SITES_PHP
git commit -a -m "Modify sites.php"

### various drush cmd to finish synchronisation
drush status > /dev/null
ret=$?
if [ $ret -ne 0 ] ; then
    echo "drush or site has a problem. Exiting."
    exit 1
fi
drush -y dis piwik
drush -y vset maintenace_mode 0
drush -y vset error_level 2
drush -y dis cas
drush -y user-unblock 1
drush cc all
