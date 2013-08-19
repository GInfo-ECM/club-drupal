#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

# ARGS: auto or manual, site_prefix
# WARNING : backup are regularly flushed, put your backup in a safe place.

cd $dir_individual_backup

#récupération des tables du site dans le fichier liste_tables.temp
tables='_%'
liste="$1$tables"

mysql -h myweb.serv.int -u webassos --password=HBVH2ljgyZCA0AP251DY -BNe "show tables like '"$liste"'" webassos | tr '\r\n' ' ' > liste_tables.temp

#transformation de cette liste en une variable
var=$(cat liste_tables.temp)

#sauvegarde de toutes ces tables
current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`
suffixe="_dump$current_date.sql"
fichier="$1$suffixe"

if [ $1 = 'auto' ] ; then
    mysqldump webassos -h myweb.serv.int -u webassos --password=HBVH2ljgyZCA0AP251DY $var > $d6_dir_individual_auto_backup/$fichier
else
    mysqldump webassos -h myweb.serv.int -u webassos --password=HBVH2ljgyZCA0AP251DY $var > $d6_dir_individual_manual_backup/$fichier
fi

#suppression du fichier temporaire utilisé
rm liste_tables.temp
