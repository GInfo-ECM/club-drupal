#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

# This script change the base URL to switch from http to https.

for local_settings in $(find $d7_dir_sites -mindepth 2 -maxdepth 2 -name settings.local.php) ; do
    # Go into the site repository.
    settings_dir=`give_dir $local_settings`
    cd $settings_dir

    chmod 700 settings.local.php

    # Need to use a tmp file.
    cp settings.local.php settings.local.tmp.php
    sed "s/http/https/" < settings.local.tmp.php > settings.local.php
    rm settings.local.tmp.php

    chmod 400 settings.local.php
done