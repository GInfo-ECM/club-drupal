#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

# Exit on error
set -e

# This script regenerate settings.local.php from the template for all sites.

for settings in $(find "${d7_dir_sites}" -mindepth 2 -maxdepth 2 -name settings.local.php) ; do
    # Get infos from settings.php
    db_name=$(grep "^ *'database' => '\(.*\)'" "${settings}" | sed "s/^ *'database' => '\(.*\)'.*/\1/")
    db_user=$(grep "^ *'username' => '\(.*\)'" "${settings}" | sed "s/^ *'username' => '\(.*\)'.*/\1/")
    db_password=$(grep "^ *'password' => '\(.*\)'" "${settings}" | sed "s/^ *'password' => '\(.*\)'.*/\1/")
    base_url=$(grep "^ *\$base_url = '\(.*\)'" "${settings}" | sed "s/^ *\$base_url = '\(.*\)'.*/\1/")

    echo "Changing ${settings}"
    chmod 600 "${settings}"
    sed "s/\%\%DBUSER\%\%/$db_user/ ; s/\%\%DBNAME\%\%/$db_name/ ; s/\%\%DBPASS\%\%/$db_password/ ; s#\%\%BASE_URL\%\%#$base_url#" < "${d7_settings_local_template}" > "${settings}"
    chmod 400 "${settings}"
    echo Done
done
