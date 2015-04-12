#!/bin/sh


help='d7-all-drush.sh drush_arguments'

usage() {
    echo "${help}"
}

if [ "$1" = "-h" ] ; then
    usage()
    exit 0
fi


. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh


check_arguments "$#" 1 "${help}"

for dir in $(find "${d7_dir_sites}" -maxdepth 1 -mindepth 1 -type d ! -name all | sort) ; do
    cd "${dir}"
    echo "${dir}"
    drush "$@"
    sleep 5
done
