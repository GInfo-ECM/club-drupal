#!/bin/sh

# This script contains all the variables that are required to execute other scrits
# (database server, backup directories,…). It is design to make other scripts
# indendant of the current configuration and to change it without editing them.
# *These variables must be used in scripts*

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin
PATH="$PATH":/home/assos/bin

scripts_config='imported'

email_multi_assos="assos@centrale-marseille.fr"
email_multi_assos_update="assos+update@centrale-marseille.fr"

dir_multi_assos='/home/assos'
dir_scripts="${dir_multi_assos}/bin"
dir_template="${dir_multi_assos}/template"
dir_private="${dir_multi_assos}/private"
dir_tmp="${dir_multi_assos}/tmp"

###### Aliases
### Bash
. "${dir_multi_assos}/.aliases"

### Drush
dot_drush="${dir_multi_assos}/.drush"
aliases_drushrc_php="${dot_drush}/aliases.drushrc.php"

###### Database
db_server="myassos.serv.int"
db_user="assos"
dir_log="${dir_multi_assos}/log"

###### Backup
db_full_backup_number=3
db_individual_manual_backup_number=2
db_individual_auto_backup_number=3

dir_backup="${dir_multi_assos}/backup"
dir_full_backup="${dir_backup}/full"
dir_individual_backup="${dir_backup}/individual"
dir_individual_manual_backup="${dir_individual_backup}/manual"
dir_individual_auto_backup="${dir_individual_backup}/auto"

myassos_cnf="${dir_private}/myassos.cnf"

###### D7 variables
d7_dir="${dir_multi_assos}/drupal7"
d7_dir_sites="${d7_dir}/sites"
sites_php="${d7_dir_sites}/sites.php"
translations_fr="${d7_dir}/profiles/standard/translations/fr.po"

### Log
d7_dir_log="${dir_log}/d7"

### Backup
d7_dir_full_backup="${dir_full_backup}/d7"
d7_dir_individual_manual_backup="${dir_individual_manual_backup}/d7"
d7_dir_individual_auto_backup="${dir_individual_auto_backup}/d7"

### Template
d7_settings_name="d7-settings.php"
d7_settings_local_template_name="d7-settings-local-template.php"
d7_settings="${dir_template}/${d7_settings_name}"
d7_settings_local_template="${dir_template}/${d7_settings_local_template_name}"
nginx_map_template="$dir_template/template/nginx-map-template"

### Nginx
nginx_site_names=""
nginx_sites_map=""
