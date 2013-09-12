#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

d7-all-drush.sh -y en update
# Launch cron to check for updates.
d7-all-drush.sh -q cron

d7-all-dump-individual.sh auto

d7-all-drush-logged.sh -y upc --no-core
d7-all-drush.sh -y updb

d7-all-drush.sh -y dis update

d7-all-drush.sh cc all

d7-all-drush.sh cron
