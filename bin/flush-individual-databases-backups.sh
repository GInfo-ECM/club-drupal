#!/bin/sh

. /home/assos/bin/scripts-config.sh

# ARGS: manual or auto, Drupal version

cd "${dir_individual_backup}/$1/$2"

for dir in "$(ls)" ; do
    cd "${dir}"
    if [ $1 = 'auto' ] ; then
        flush-files.sh "${db_individual_auto_backup_number}" "${email_multi_assos}"
    else
        flush-files.sh "${db_individual_manual_backup_number}"
    fi
    cd -
done
