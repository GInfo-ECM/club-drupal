#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

help="ARGS: # ARGS: auto or manual, site_prefix"

check_arguments $# 2 "$help"

# WARNING : backup are regularly flushed, put your backup in a safe place.

cd $dir_individual_backup

#récupération des tables du site dans le fichier liste_tables.temp
tables='_%'
liste="$1$tables"

mysql --defaults-extra-file=$webassos_cnf -BNe "show tables like '"$liste"'" webassos | tr '\r\n' ' ' > liste_tables.temp

#transformation de cette liste en une variable
var=$(cat liste_tables.temp)

#sauvegarde de toutes ces tables
current_date=`date "+%Y-%m-%d-%Hh%Mm%Ss"`
suffixe="_dump$current_date.sql"
fichier="$1$suffixe"

if [ $1 = 'auto' ] ; then
    mysqldump webassos --defaults-extra-file=$webassos_cnf $var > $d6_dir_individual_auto_backup/$fichier
else
    mysqldump webassos --defaults-extra-file=$webassos_cnf $var > $d6_dir_individual_manual_backup/$fichier
fi

#suppression du fichier temporaire utilisé
rm liste_tables.temp
