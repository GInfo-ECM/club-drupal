#!/bin/sh

. /home/assos/bin/scripts-config.sh

# List version of a module or theme that exists in sites/all/*
# and all versions that are available for same project on drupal.org

# modules
cd "${d7_dir_sites}/all/modules"
for dir in "$(ls -1)" ; do
    if [ -d "${dir}" ] ; then
        drush pm-releases "${dir}"
    fi
done

# themes
cd "${d7_dir_sites}/all/themes"
for dir in "$(ls -1)" ; do
    if [ -d "${dir}" ] ; then
        drush pm-releases "${dir}"
    fi
done
