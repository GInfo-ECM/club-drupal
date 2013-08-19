#!/bin/sh

. scripts-config.sh

cd $d6_dir_sites
d6-all-drush.sh vset --always-set reverse_proxy TRUE
d6-all-drush.sh vset --always-set --format=json reverse_proxy_addresses '["147.94.19.16","147.94.19.17"]'
drush @sites ev "variable_set('update_notify_emails', array($email_multi_assos));" --yes