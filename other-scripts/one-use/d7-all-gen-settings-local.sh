#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

# This script generate settings.php and settings.local.php from settings.php

for settings in $(find $d7_dir_sites -mindepth 2 -maxdepth 2 -name settings.php) ; do
    # Get infos from settings.php
    db_name=$(grep "^ *'database' => '\(.*\)'" $settings | sed "s/^ *'database' => '\(.*\)'.*/\1/")
    db_user=$(grep "^ *'username' => '\(.*\)'" $settings | sed "s/^ *'username' => '\(.*\)'.*/\1/")
    db_password=$(grep "^ *'password' => '\(.*\)'" $settings | sed "s/^ *'password' => '\(.*\)'.*/\1/")
    base_url=$(grep "^ *\$base_url = '\(.*\)'" $settings | sed "s/^ *\$base_url = '\(.*\)'.*/\1/")

    settings_dir=`give_dir $settings`

    chmod 700 $settings

    rm $settings

    # We go into the settings.php directory.
    cd $settings_dir
    pwd

    cp $d7_settings settings.php
    chmod 400 settings.php

    sed "s/\%\%DBUSER\%\%/$db_user/ ; s/\%\%DBNAME\%\%/$db_name/ ; s/\%\%DBPASS\%\%/$db_password/ ; s#\%\%BASE_URL\%\%#$base_url#" < ~/tmp/d7-settings-local-template.php > settings.local.php

    chmod 400 settings.local.php
done
