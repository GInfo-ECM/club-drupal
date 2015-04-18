#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

for dir in $(find "${d7_dir_sites}" -maxdepth 1 -mindepth 1 -type d ! -name all | sort); do
    echo "${dir}"
    site_name=$(get_site_name_from_dir_name "${dir}")
    d7-reset-variables.sh "${site_name}"
done
