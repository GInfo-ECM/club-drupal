#!/bin/sh

. /users/guest/assos/bin/script-config.sh
. /users/guest/assos/bin/scripts-utils.sh

# This script generate settings.php and settings.local.php from settings.php

for settings in $(find $d7_dir_sites -mindepth 2 -maxdepth 2 -name settings.php) ; do
    # Get infos from settings.php
    d7_site_name=$(grep "^\s*'database' => '\(.*\)'" $settings | sed "s/^ *'database' => '\(.*\)'.*/\1/")
    db_user=$(grep "^ *'username' => '\(.*\)'" $settings | sed "s/^ *'username' => '\(.*\)'.*/\1/")
    db_password=$(grep "^\s*'password' => '\(.*\)'" $settings | sed "s/^ *'password' => '\(.*\)'.*/\1/")
    base_url=$(grep "^\s*\$base_url = '\(.*\)'" $settings | sed "s/^ *\$base_url = '\(.*\)'.*/\1/")

    settings_dir=`give_dir $settings`

    chmod 700 $settings

    rm $settings

    # We go into the settings.php directory
    cd $settings_dir

    cp $d7_settings settings.php
    chmod 400 settings.php

    generate_settings_local $d7_site_name $site_password $d7_settings_local_template settings.local.php

    chmod 400 settings.local.php
done
