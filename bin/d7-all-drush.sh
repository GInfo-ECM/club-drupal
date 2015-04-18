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

for site in $(sites_list) ; do
    echo "${site}"
    drush @"${site}" "$@"
    sleep 5
done
