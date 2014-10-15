#!/bin/sh

. /home/assos/bin/scripts-config.sh
. scripts-utils.sh

help="# ARGS: auto or manual"

check_arguments "$#" 1 "$help"

current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")

cd "${d7_dir_sites}"

for dir in $(find . -maxdepth 1 -mindepth 1 -type d ! -name all | cut -c3-); do
    cd "${dir}"
    drush cc all
    if [ "$1" = 'auto' ] ; then
        drush sql-dump --result-file="${d7_dir_individual_auto_backup}/${dir}/${current_date}.${dir}.sql" --gzip
    else
        drush sql-dump --result-file="${d7_dir_individual_manual_backup}/${dir}/${current_date}.${dir}.sql" --gzip
    fi
    cd -
done
