#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

help="ARG: [database password]"

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

if [ -z $1 ] ; then
    db_password=`ask_password_db $db_server $db_user`
else
    db_password=$1
fi


# Dump D6 database with webassos user.
mysqldump --single-transaction webassos -h myweb.serv.int -u webassos --password=$db_password > $d6_dir_full_backup/webassos/$current_date.webassos.sql
