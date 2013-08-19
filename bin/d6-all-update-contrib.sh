#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

d6-all-drush.sh -y en update
# Launch cron to check for updates.
d6-all-drush.sh -q cron

d6-all-drush.sh cc all
d6-all-dump-full.sh

d6-all-drush.sh -y upc --no-core
d6-all-drush.sh -y updb

d6-all-drush.sh -y dis update

d6-all-drush.sh cron
