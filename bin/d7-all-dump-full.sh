#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")

# Dump D7 databases at once.
mysqldump --defaults-extra-file=$myassos_cnf --all-databases | gzip > $d7_dir_full_backup/myassos/$current_date.d7_full.sql.gz
