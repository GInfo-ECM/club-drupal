#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

# Dump D6 database with webassos user.
mysqldump --single-transaction webassos -h myweb.serv.int -u webassos --password=HBVH2ljgyZCA0AP251DY > $d6_dir_full_backup/webassos/$current_date.webassos.sql

# Dump D6 form database with forum user.
mysqldump forum -h myweb.serv.int -u forum --password=dtcAltF12 > $d6_dir_full_backup/forum/$current_date.forum.sql
