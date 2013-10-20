#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-config-site.sh $1
. /users/guest/assos/bin/scripts-utils.sh

help="# ARGS: site name"

######## Exceptions
check_arguments $# 1 "$help"

# "-" is forbidden because it provokes database error.
if [ `echo $1 | grep -` ] ; then
    echo '"-" is forbidden in the site name'
    exit 1
fi

# Site name length must be lower or equal to 16 due to database limitations.
if [`echo $1 | wc -c` -gt 16 ] ; then
    echo "site name can't have more than 16 characters"
    exit 1
fi

###### Initialisation
cd $d7_dir
db_password=`ask_password_db $db_server $db_user`
site_password=`generate_password`

# Check if site database already exists.
if mysql -h $db_server -u $db_user -e "USE $d7_site_name" -p$db_password 2>/dev/null ; then
    echo "Database $d7_site_name already exists"
    exit 1
fi

# Check if site folder already exists.
if [ -d $d7_site_dir ] ; then
    echo "Folder $d7_site_dir already exists"
    exit 1
fi

###### Main
mkdir $d7_site_dir
dir_site_name="assos.centrale-marseille.fr.$d7_site_name"

# Backup requirements
mkdir $d7_dir_individual_auto_backup/$dir_site_name
mkdir $d7_dir_individual_manual_backup/$dir_site_name
current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

# NB : ls sort by considering the 1st characters
touch $d7_dir_individual_auto_backup/$dir_site_name/$current_date.$dir_site_name.sql
touch $d7_dir_individual_auto_backup/$dir_site_name/$current_date.$dir_site_name.sql2
touch $d7_dir_individual_auto_backup/$dir_site_name/$current_date.$dir_site_name.sql3
touch $d7_dir_individual_auto_backup/$dir_site_name/$current_date.$dir_site_name.sql4

# Create and grant privileges on database
mysql -h $db_server -u $db_user -e "CREATE DATABASE $d7_site_name" -p$db_password
mysql -h $db_server -u $db_user -e "GRANT ALL PRIVILEGES ON $d7_site_name.* TO '$d7_site_name'@'%' IDENTIFIED BY '$site_password'" -p$db_password

# Create settings.php
cp $d7_settings $d7_site_settings
generate_settings_local $d7_site_name $site_password $d7_settings_local_template $d7_site_settings_local

# Create symbolic link
cd $d7_dir
ln -s . $d7_site_name

# Update sites.php
echo "assos.centrale-marseille.fr.$d7_site_name" >> $sites_php

# Next Instructions
echo "Go to http://assos.centrale-marseille.fr/$d7_site_name/install.php to continue."
echo "Press enter when ready to go on."
read key

# Init variables
d7-reset-variables.sh $d7_site_name

# Permissions
chmod -R 755 $d7_site_dir
chmod 400 $d7_site_settings

# Last instructions
echo "Last instructions:"
echo "- Advice the webmaster to close account creation on the website"
echo "- Give the webmaster a link to the club Drupal's tutorials "
echo "- Create a node of type \"Site\" on default"
echo "- Register the webmaster on webmasters@listes.centrale-marseille.fr"
