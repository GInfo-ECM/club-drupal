#!/bin/sh

usage() {
    echo "ARGS: manual or auto, Drupal version."
}

. /home/assos/bin/print-help-if-required.sh

. /home/assos/bin/scripts-config.sh

cd "${dir_individual_backup}/$1/$2"

for dir in $(ls) ; do
    cd "${dir}"
    if [ "$1" = 'auto' ] ; then
        flush-files.sh -n "${db_individual_auto_backup_number}" -m "${email_multi_assos}"
    else
        flush-files.sh -n "${db_individual_manual_backup_number}"
    fi
    cd -
done
