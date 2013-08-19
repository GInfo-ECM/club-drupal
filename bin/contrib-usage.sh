#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. scripts-utils.sh

help="# ARGS: Drupal_version, project_status, project_name\n
# List sites that have the project_name with the corresponding project_status.\n
# project status: enabled or disabled"

check_arguments $# 3 "$help"

if [ $1 = d6 ] ; then
    cd $d6_dir_sites
else
    cd $d7_dir_sites
fi

for dir in `find . -maxdepth 1 -mindepth 1 -type d ! -name all ! -name languages ! -name images | sort ` ; do
    # List non-core projects that correspond to the status.
    # Keep project_name if listed.
    # Count line result. 0 if not listed or 1 if listed.
	# Print site_dir if listed.

    cd $dir;
	if [ 1 -eq `drush pml --no-core --status=$2 | grep $3 | wc -l` ] ; then
        echo $dir;
    fi
    cd -
done
