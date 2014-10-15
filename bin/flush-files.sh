#!/bin/sh

help="# ARGS: number of files to keep, [email address]\n
# usage: flush files from a folder except a number equal to argument.\n
# It only prints a warning if scripts-utils.sh is not imported in order to be used
# from the terminal."

# Check if scripts-utils.sh is imported.
if [ -z "${scripts_utils}" ] ; then
    echo "Import of scripts-utils.sh required."
    . scripts-utils.sh
fi

check_arguments "$#" 1 "$help"

# Must not be quoted to avoid problem with ((…))
backups_number=$(ls | wc -l)
((number_of_backups_to_delete = backups_number - $1))

if [ "${number_of_backups_to_delete}" -gt 0 ] ; then
    ls | head "-${number_of_backups_to_delete}" | xargs rm
else
    if [ ! -z "$2" ] ; then
        dir=$(pwd)
        echo "There are not enough files in $dir to Flush it. Check if backup script works fine." | mail -s "[db] $dir has a backup problem" "$2"
    fi
fi
