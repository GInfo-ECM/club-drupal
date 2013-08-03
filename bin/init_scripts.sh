#!/bin/sh

#Ce script crée toutes les variables communes à tous les sites
scripts_location='/users/guest/assos/bin'

web_dir='/users/guest/assos'
manual_backup_dir='/users/guest/assos/Desktop/dump_individuels'

d7_dir="$web_dir/htmltest"
d7_sites_dir="$d7_dir/sites"
d7_backup_dir='/users/guest/assos/Desktop/dump_d7'

db_server="myassos.serv.int"
db_user="assos"

template_location="/users/guest/assos/Desktop"
d7_template_name="settings-D7-bddinde-template.php"
d7_template_settings="$template_location/$d7_template_name"

###### Variable d6
d6_backup_dir='/users/guest/assos/Desktop/dump_d6'
