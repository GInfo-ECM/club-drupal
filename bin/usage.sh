#!/bin/sh

. /home/assos/bin/scripts-config.sh
. scripts-utils.sh

help="# ARGS: Drupal_version, project_status, project_name\n
# List sites that have the project_name with the corresponding project_status.\n
# project status: enabled or disabled"

check_arguments $# 3 "$help"

if [ $1 = d7 ] ; then
    cd $d7_dir_sites
else
    echo Unrecognize version.
fi

number_found=0

for dir in $(find . -maxdepth 1 -mindepth 1 -type d ! -name all ! -name languages ! -name images | sort) ; do
    # List projects that correspond to the status.
    # Keep project_name if listed.
    # Count line result. 0 if not listed or 1 if listed.
    # Print site_dir if listed.

    cd $dir;
	if [ 1 -le $(drush pml --status=$2 | grep $3 | wc -l) ] ; then
        echo $dir;
        number_found=$(($number_found + 1))
    fi
    cd -
done

echo "Number of sites found for project $3 and status $2 : $number_found";
