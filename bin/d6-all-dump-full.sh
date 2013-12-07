#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

# Dump D6 database with webassos user.
mysqldump --defaults-extra-file=$webassos_cnf --single-transaction webassos > $d6_dir_full_backup/webassos/$current_date.webassos.sql
