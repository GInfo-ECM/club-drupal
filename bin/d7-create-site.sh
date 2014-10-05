#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-config-site.sh "$1"
. /home/assos/bin/scripts-utils.sh

help="# ARGS: site_name site_mail admin_password [--no-init-database]"

check_arguments "$#" 3 "${help}"

# Check if site already exists.
if site_exists "${d7_site_name}" ; then
    exit 1
fi

init_db=1
if [ "$4" = "--no-init-database" ] ; then
    init_db=0
fi

######## Exceptions
echo "Checking if work tree is clean (may take a while)"
if ! work_tree_clean ; then
    echo "Your work tree is not clean. Solve this before $0 can continue."
    exit 2
fi

# "-" is forbidden because it provokes database error.
if [ "$(echo "$1" | grep -)" ] ; then
    echo '"-" is forbidden in the site name'
    exit 1
fi

# Site name length must be lower or equal to 16 due to database limitations.
if [ "$(echo "$1" | wc -c)" -gt 16 ] ; then
    echo "site name can't have more than 16 characters"
    exit 1
fi

# drush site-install needs the translation file
if [ ! -f "${translation_fr}" ] ; then
    echo "The translation file $translation_fr does not exist"
    exit 1
fi

###### Initialisation
cd "${d7_dir}"
site_password="$(generate_password)"
site_line_sites_php="\$sites['assos.centrale-marseille.fr.$d7_site_name'] = 'assos.centrale-marseille.fr.$d7_site_name';"
site_line_aliases_drushrc_php="\$aliases['$d7_site_name'] = array('uri' => 'assos.centrale-marseille.fr/$d7_site_name', 'root' => '/home/assos/drupal7/', );"
# NB: site_name is initialised in script-config-site.sh
site_mail="$2"
admin_password="$3"


###### Main
mkdir "${d7_site_dir}"
dir_site_name="assos.centrale-marseille.fr.${d7_site_name}"

# Backup requirements
mkdir "${d7_dir_individual_auto_backup}/${dir_site_name}"
mkdir "${d7_dir_individual_manual_backup}/${dir_site_name}"
current_date="$(date "+%Y-%m-%d-%Hh%Mm%Ss")"

# NB : ls sort by considering the 1st characters
touch "${d7_dir_individual_auto_backup}/${dir_site_name}/${current_date}.${dir_site_name}.sql"
touch "${d7_dir_individual_auto_backup}/${dir_site_name}/${current_date}.${dir_site_name}.sql2"
touch "${d7_dir_individual_auto_backup}/${dir_site_name}/${current_date}.${dir_site_name}.sql3"
touch "${d7_dir_individual_auto_backup}/${dir_site_name}/${current_date}.${dir_site_name}.sql4}"

# Create and grant privileges on database
mysql --defaults-extra-file="${myassos_cnf}" -e "CREATE DATABASE ${d7_site_name}"
mysql --defaults-extra-file="${myassos_cnf}" -e "GRANT ALL PRIVILEGES ON ${d7_site_name}.* TO '${d7_site_name}'@'%' IDENTIFIED BY '${site_password}'"

# Create settings.local.php
cp "${d7_settings}" "${d7_site_settings}"
generate_settings_local "${d7_site_name}" "${site_password}" "${d7_settings_local_template}" "${d7_site_settings_local}"

# Install the site
drush site-install -y standard --account-mail="${site_mail}" --account-name="admin" --account-pass="${admin_password}" --locale=fr --site-mail="${site_mail}" --site-name="${d7_site_name}" --sites-subdir="${dir_site_name}"

# Create symbolic link
cd "${d7_dir}"
ln -s . "${d7_site_name}"
git add "${d7_site_name}"

# Update sites.php
chmod +w "${sites_php}"
echo "${site_line_sites_php}" >> "${sites_php}"
chmod 400 "${sites_php}"

### Update aliases.drushrc.php
# For site
echo "${site_line_aliases_drushrc_php}" >> "${aliases_drushrc_php}"
# @d7
sed s/"'site-list' => array("/"'site-list' => array(%'assos.centrale-marseille.fr\/$d7_site_name',"/ < "${aliases_drushrc_php}" | tr '%' '\n    ' > "${dir_tmp}/aliases.tmp"
mv "${dir_tmp}/aliases.tmp" "${aliases_drushrc_php}"

### Update nginx_sites_map
echo $d7_site_name >> $nginx_site_names
# The sort must be reversed so that nginx aplly the rules correctly.
cat $nginx_site_names | sort -r > $nginx_site_names
update_nginx_map

commit "Creation of site: ${d7_site_name}"

# Next Instructions
if [ "${init_db}" -eq 0 ] ; then
    exit 0
fi

# Init variables
d7-reset-variables.sh "${d7_site_name}"

# Permissions
chmod -R 755 "${d7_site_dir}"
chmod 400 "${d7_site_settings}"

# Last instructions
echo "Last instructions:"
echo "- Advice the webmaster to close account creation on the website"
echo "- Give the webmaster a link to the club Drupal's tutorials "
echo "- Create a node of type \"Site\" on default"
echo "- Register the webmaster on webmasters@listes.centrale-marseille.fr"
echo -e "- If line to add to sites.php differs from the line below, please correct it\n\t$site_line_sites_php"
