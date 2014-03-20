#!/usr/bin/env bash

help=<<EOF
This script is intended to ease the synchronisation between any site hosted by assos.
Typically, this script is usefull when you have (or want to have) a test site based on
a already working site. It relies on bash, drush and drush aliases.

Before synching the ssite, the destination site's database is backuped. If the
destination site does not exist, it is created.

usage: d7-sync.sh SOURCE_SITENAME DEST_SITENAME
EOF

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

# Create site if necessary
if ! site_exists $2 ; then
    echo "$2 does not exit. We will create it"
    d7-create-site.sh $2 --no-init-database
fi

# Backup the database of SOURCE_SITE
current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")
if [ $1 = "default" ] ; then
    dir=$1
else
    dir=assos.centrale-marseille.fr.$1
fi
drush -y @$1 sql-dump | gzip  > $d7_dir_individual_manual_backup/$dir/$current_date.$dir.sql.gz

# Sync files
drush -y rsync --delete --exclude="*.php" @${1}:%site @${2}:%site

# Sync databases
## Save file system
private_path=$(drush @$2 vget --format=string file_private_path 2> /dev/null)
public_path=$(drush @$2 vget --format=string file_public_path 2> /dev/null)
temp_path=$(drush @$2 vget --format=string file_temporary_path 2> /dev/null)
## Sync
drush sql-sync @$1 @$2
## Restore file system
if [ -n $private_path ] ; then
    drush -y @$2 vset file_private_path $private_path
fi
if [ -n $public_path ] ; then
    drush -y @$2 vset file_public_path $public_path
fi
if [ -n $temp_path ] ; then
    drush -y @$2 vset file_temporary_path $temp_path
fi

# Finish sync
drush -y vset maintenance_mode 0
