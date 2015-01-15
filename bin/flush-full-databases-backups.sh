#!/bin/sh

usage() {
    echo "ARGS: Drupal version"
}

. /home/assos/bin/print-help-if-required.sh

. /home/assos/bin/scripts-config.sh

cd "${dir_full_backup}/$1"

for dir in $(ls) ; do
    cd "${dir}"
    flush-files.sh -n "${db_full_backup_number}" -m "${email_multi_assos}"
    cd -
done
