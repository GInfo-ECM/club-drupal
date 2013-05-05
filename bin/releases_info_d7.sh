#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin
##############
#Send a mail with following infos:
#- version of a module or theme that exists in sites/*
#- all versions that are available for same project on drupal.org
##############
#modules
cd /users/guest/assos/htmltest/sites/all/modules
for x in $(ls -1); do
  if [ -d $x ]; then
    drush pm-releases $x
  fi
done
#themes
cd /users/guest/assos/htmltest/sites/all/themes
for x in $(ls -1); do
  if [ -d $x ]; then
    drush pm-releases $x
  fi
done
