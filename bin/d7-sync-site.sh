#!/usr/bin/env bash

help=<<EOF
This script is intended to ease the synchronisation between any site hosted by assos.
Typically, this script is usefull when you have (or want to have) a test site based on
a already working site. It relies on bash, drush and drush aliases.

Before synching the ssite, the destination site's database is backuped. If the
destination site does not exist, it is created.

usage: d7-sync.sh SOURCE_SITENAME DEST_SITENAME [--prod]
EOF

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

check_arguments $# 2 "$help"


# Create site if necessary
if ! site_exists $2 > /dev/null ; then
    echo "$2 does not exit. We will create it"
    d7-create-site.sh $2 --no-init-database
    # if the site is new, there is no database
    new_site=1
fi


# Backup the database of SOURCE_SITE
current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")
if [ $1 = "default" ] ; then
    dir=$2
else
    dir=assos.centrale-marseille.fr.$2
fi
if [ -z "$new_site" ] ; then
    drush -y @$1 sql-dump --result-file=$d7_dir_individual_manual_backup/$dir/$current_date.$dir.sql --gzip
fi


# Sync files
drush -y rsync --delete --exclude="*.php" @${1}:%site @${2}:%site


# Sync databases
## Save file system
if [ -z "$new_site" ] ; then
    private_path=$(drush @$2 vget --format=string file_private_path 2> /dev/null)
    public_path=$(drush @$2 vget --format=string file_public_path 2> /dev/null)
    temp_path=$(drush @$2 vget --format=string file_temporary_path 2> /dev/null)
fi

## Sync
current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")
sql_file=$dir_tmp/$current_date.$1.sql
drush -y @$1 sql-dump --result-file=$sql_file
sed -i -e "s#https?://assos.centrale-marseille.fr/$1#https://assos.centrale-marseille.fr/$2#g" $sql_file
mysql --defaults-extra-file=$myassos_cnf -e "DROP DATABASE IF EXISTS $2; CREATE DATABASE $2"
mysql --defaults-extra-file=$myassos_cnf $2 < $sql_file
rm $sql_file

## Restore file system
if [ -n "$private_path" ] ; then
    drush -y @$2 vset file_private_path $private_path
fi
if [ -n "$public_path" ] ; then
    drush -y @$2 vset file_public_path $public_path
fi
if [ -n "$temp_path" ] ; then
    drush -y @$2 vset file_temporary_path $temp_path
fi

if [ "$3" = "--prod" ] ; then
    drush -y @$2 vset maintenance_mode 0
else
    drush -y @$2 vset maintenance_mode 1
fi
