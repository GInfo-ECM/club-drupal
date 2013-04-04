#!/bin/sh
mysqldump --single-transaction webassos -h myweb.serv.int -u webassos --password=aiFw1JNzGMbNnL6 > ~/Desktop/$(date '+%d-%m-%H-%M').webassos.dump.sql
mysqldump forum -h myweb.serv.int -u forum --password=dtcAltF12 > ~/Desktop/$(date '+%d-%m-%H-%M').forum.dump.sql
