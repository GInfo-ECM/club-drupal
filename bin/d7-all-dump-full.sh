#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

# Dump D7 databases at once.
mysqldump --defaults-extra-file=$myassos_cnf --all-databases > $d7_dir_full_backup/myassos/$current_date.d7_full.sql
