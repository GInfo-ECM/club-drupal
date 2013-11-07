#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

help="ARG: database password"

check_arguments $# 1 "$help"

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

# Dump D7 databases at once.
mysqldump -h $db_server -u $db_user -p$1 --all-databases > $d7_dir_full_backup/myassos/$current_date.d7_full.sql
