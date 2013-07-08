#!/bin/sh

madate=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

#Dump D6 database with webassos user.
/usr/local/bin/mysqldump --single-transaction webassos -h myweb.serv.int -u webassos --password=HBVH2ljgyZCA0AP251DY > /users/guest/assos/Desktop/dump_d6/webassos.dump$madate.sql

#Dump D6 form database with forum user.
/usr/local/bin/mysqldump forum -h myweb.serv.int -u forum --password=dtcAltF12 > /users/guest/assos/Desktop/dump_d6/forum.dump$madate.sql

#Dump D7 databases at once.
/usr/local/bin/mysqldump -h myassos.serv.int -u assos -pNoNo82jJ --all-databases > /users/guest/assos/Desktop/dump_d7/d7_all$madate.sql
