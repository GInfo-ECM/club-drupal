#!/bin/sh

usage() {
    help="flush-files.sh -n number_of_files_to_keep [-m email_address]\n
usage: flush files from a folder except a number equal to argument.\n
It only prints a warning if scripts-utils.sh is not imported in order to be used
from the terminal."
    echo -e "${help}"
}


number_of_files_to_keep=''
email_address=''
while getopts "hn:m:" opt; do
    case "${opt}" in
	h)
	    usage; exit 0;;
	n)
	    number_of_files_to_keep="${OPTARG}";;
	m)
	    email_address="${OPTARG}";;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    usage >&2; exit 1;;
	\?)
	    usage >&2; exit 1;;
    esac
done
shift $((OPTIND-1))


# Check that all required parameters are there
if [ -z "${number_of_files_to_keep}" ]; then
    echo "At least a required parameter is missing." >&2
    usage >&2
    exit 1
fi


# Check if scripts-utils.sh is imported.
if [ -z "${scripts_utils}" ] ; then
    echo "Import of scripts-utils.sh required."
    . scripts-utils.sh
fi


# Must not be quoted to avoid problem with ((…))
backups_number=$(ls | wc -l)
number_of_backups_to_delete=$((backups_number - ${number_of_files_to_keep}))

if [ "${number_of_backups_to_delete}" -gt 0 ] ; then
    ls | head "-${number_of_backups_to_delete}" | xargs rm
else
    if [ -n "${email_address}" ] ; then
        dir=$(pwd)
        echo "There are not enough files in $dir to Flush it. Check if backup script works fine." | mail -s "[db] $dir has a backup problem" "${email_address}"
    fi
fi
