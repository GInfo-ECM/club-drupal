#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

# This script puts the correct permissions to sites folders, settings.php and scripts.

######### drupal 7
for site in $(sites_list); do
    dir=$(get_absolute_site_dir_from_name "${site}")
    chmod 755 "${dir}"
    chmod 400 "${dir}/settings.php"
    chmod 400 "${dir}/settings.local.php"
done

####### bin
chmod -R 700 "${dir_scripts}"

####### backup
chmod -R u=rwX,go-rwx "${dir_backup}"

####### log
chmod -R u=rwX,go-rwx "${dir_log}"

####### private
chmod -R u=rwX,go-rwx "${dir_private}"
