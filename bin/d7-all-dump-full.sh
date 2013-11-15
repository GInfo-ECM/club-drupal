#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

help="ARG: database password"

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

if [ -z $1 ] ; then
    db_password=`ask_password_db $db_server $db_user`
else
    db_password=$1
fi

# Dump D7 databases at once.
mysqldump -h $db_server -u $db_user -p$db_password --all-databases > $d7_dir_full_backup/myassos/$current_date.d7_full.sql
