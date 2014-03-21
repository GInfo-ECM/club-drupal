#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

commit_if_unclean

d7-all-drush.sh -y en update
# Launch cron to check for updates.
d7-all-drush.sh -q cron

d7-all-dump-individual.sh auto

d7-all-drush-logged.sh -y upc --no-core
d7-all-drush.sh -y updb

d7-all-drush.sh -y dis update

d7-all-drush.sh cron

git add -A $d7_dir_sites/all
commit "Weekly update of contrib modules"
