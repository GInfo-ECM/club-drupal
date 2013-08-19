#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

# Dump D7 databases at once.
mysqldump -h $db_server -u $db_user -pNoNo82jJ --all-databases > $d7_dir_full_backup/myassos/$current_date.d7_full.sql
