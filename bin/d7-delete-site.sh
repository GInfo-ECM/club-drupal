#!/bin/sh

. /home/assos/bin/scripts-config.sh
. scripts-config-site.sh $1
. scripts-utils.sh

help="# ARGS: site name."

check_arguments $# 1 "$help"

echo 'Awaiting for git status. (may take a while)'
if ! `work_tree_clean` ; then
    echo "Your work tree is not clean. Solve this before $0 can continue."
    exit 2
fi

echo 'Delete database.'
mysql --defaults-extra-file=$myassos_cnf -e "DROP DATABASE $d7_site_name"

echo 'Delete MYSQL user.'
mysql --defaults-extra-file=$myassos_cnf -e "DROP USER '$d7_site_name'@'%'"

echo "Delete site's folder."
chmod -R 700 $d7_site_dir
rm -r $d7_site_dir

# Delete symbolic link.
rm $d7_dir/$d7_site_name

echo 'Remove site line from sites.php'
chmod +w $sites_php
grep -sv "^\$.*$d7_site_name';$" $sites_php > $dir_tmp/sites.php
mv $dir_tmp/sites.php $sites_php
chmod 400 $sites_php

echo 'Remove site alias from aliases.drushrc.php'
grep -sv "$d7_site_name'" $aliases_drushrc_php > $dir_tmp/aliases.php
mv $dir_tmp/aliases.php $aliases_drushrc_php

echo 'Delete database backups.'
rm -r $d7_dir_individual_auto_backup/assos.centrale-marseille.fr.$d7_site_name
rm -r $d7_dir_individual_manual_backup/assos.centrale-marseille.fr.$d7_site_name

echo "Don't forget to:"
echo "- Refresh node site on default"
echo "- Check particular behavior (normally detailed on site node)"

commit "Deletion of site: $d7_site_name"
