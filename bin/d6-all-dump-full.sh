#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

help="ARG: database password"

check_arguments $# 1 "$help"

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

# Dump D6 database with webassos user.
mysqldump --single-transaction webassos -h myweb.serv.int -u webassos --password=$1 > $d6_dir_full_backup/webassos/$current_date.webassos.sql
