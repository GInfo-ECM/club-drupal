#!/bin/sh

madate=`date "+%Y-%m-%d-%Hh%Mm%Ss"`

/usr/local/bin/mysqldump --single-transaction webassos -h myweb.serv.int -u webassos --password=HBVH2ljgyZCA0AP251DY > /users/guest/assos/Desktop/dump_d6/webassos.dump$madate.sql
/usr/local/bin/mysqldump forum -h myweb.serv.int -u forum --password=dtcAltF12 > /users/guest/assos/Desktop/dump_d6/forum.dump$madate.sql
/usr/local/bin/mysqldump sudfinance -h myweb.serv.int -u sudfinance --password=JLSMiisuRxrjLmqT2A7R > /users/guest/assos/Desktop/dump_d6/sudfinance.dump$madate.sql
