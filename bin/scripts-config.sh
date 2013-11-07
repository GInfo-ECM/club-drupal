#!/bin/sh

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/games:/usr/local/sbin:/usr/local/bin:/users/guest/assos/bin
PATH=$PATH:/usr/guest/assos/bin

scripts_config='imported'

email_multi_assos="assos@centrale-marseille.fr"

dir_multi_assos='/users/guest/assos'
dir_scripts="$dir_multi_assos/bin"
dir_template="$dir_multi_assos/template"
dir_private="$dir_multi_assos/private"

###### Database
db_server="myassos.serv.int"
db_user="assos"
dir_log="$dir_multi_assos/log"

###### Backup
db_full_backup_number=3
db_individual_manual_backup_number=2
db_individual_auto_backup_number=3

dir_backup="$dir_multi_assos/backup"
dir_full_backup="$dir_backup/full"
dir_individual_backup="$dir_backup/individual"
dir_individual_manual_backup="$dir_individual_backup/manual"
dir_individual_auto_backup="$dir_individual_backup/auto"


###### D7 variables
d7_dir="$dir_multi_assos/htmltest"
d7_dir_sites="$d7_dir/sites"
sites_php="$d7_dir_sites/sites.php"

### Log
d7_dir_log="$dir_log/d7"

### Backup
d7_dir_full_backup="$dir_full_backup/d7"
d7_dir_individual_manual_backup="$dir_individual_manual_backup/d7"
d7_dir_individual_auto_backup="$dir_individual_auto_backup/d7"

### Template
d7_settings_name="d7-settings.php"
d7_settings_local_template_name="d7-settings-local-template.php"
d7_settings="$dir_template/$d7_settings_name"
d7_settings_local_template="$dir_template/$d7_settings_local_template_name"


###### D6 variables
d6_dir="$dir_multi_assos/html"
d6_dir_sites="$d6_dir/sites"

### Backup
d6_dir_full_backup="$dir_full_backup/d6"
d6_dir_individual_manual_backup="$dir_individual_manual_backup/d6"
d6_dir_individual_auto_backup="$dir_individual_auto_backup/d6"
