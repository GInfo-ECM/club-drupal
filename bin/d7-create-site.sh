#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-config-site.sh $1
. /users/guest/assos/bin/scripts-utils.sh

help="# ARGS: site name"

######## Exceptions
check_arguments $# 1 "$help"

if ! `work_tree_clean` ; then
    echo "Your work tree is not clean. Solve this before $0 can continue."
    exit 2
fi

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
site_password=`generate_password`
site_line_sites_php="\$sites['assos.centrale-marseille.fr.$d7_site_name'] = 'assos.centrale-marseille.fr.$d7_site_name';"
site_line_aliases_drushrc_php="\$aliases['$d7_site_name'] = array('uri' => 'assos.centrale-marseille.fr/$d7_site_name', 'root' => '/users/guest/assos/drupal7/', );"

# Check if site database already exists.
if mysql --defaults-extra-file=$myassos_cnf -e "USE $d7_site_name" 2>/dev/null ; then
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
mysql --defaults-extra-file=$myassos_cnf -e "CREATE DATABASE $d7_site_name"
mysql --defaults-extra-file=$myassos_cnf -e "GRANT ALL PRIVILEGES ON $d7_site_name.* TO '$d7_site_name'@'%' IDENTIFIED BY '$site_password'"

# Create settings.php
cp $d7_settings $d7_site_settings
generate_settings_local $d7_site_name $site_password $d7_settings_local_template $d7_site_settings_local

# Create symbolic link
cd $d7_dir
ln -s . $d7_site_name
git add $d7_site_name

# Update sites.php
chmod +w $sites_php
echo $site_line_sites_php >> $sites_php
chmod 400 $sites_php

### Update aliases.drushrc.php
# For site
echo $site_line_aliases_drushrc_php >> $aliases_drushrc_php
# @d7
sed s/"'site-list' => array("/"'site-list' => array(%'assos.centrale-marseille.fr\/$d7_site_name',"/ < $aliases_drushrc_php | tr '%' '\n    ' > $dir_tmp/aliases.tmp
mv $dir_tmp/aliases.tmp $aliases_drushrc_php

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
echo -e "- If line to add to sites.php differs from the line below, please correct it\n\t$site_line_sites_php"

commit "Creation of site: $d7_site_name"
