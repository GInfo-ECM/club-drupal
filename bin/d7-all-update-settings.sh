#!/bin/sh

. /home/assos/bin/script-config.sh
. /home/assos/bin/scripts-utils.sh

# This script updates all drupal 7 settings.php according to a new template. Site informations located in settings.local.php are left intact.

for settings in $(find $d7_dir_sites -mindepth 2 -maxdepth 2 -name settings.php) ; do

    # We go into the settings.php directory.
    settings_dir=$(give_dir $settings)
    cd $settings_dir

    chmod 700 $settings
    rm $settings

    cp $d7_settings settings.php
    chmod 400 settings.php
done
