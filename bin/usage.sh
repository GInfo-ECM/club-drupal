#!/bin/sh

usage() {
    help="usage.sh -v Drupal_version -s project_status -n project_name\n
# List sites that have the project_name with the corresponding project_status.\n
# project status: enabled or disabled"
    echo -e "${help}"
}

drupal_version=''
project_status=''
project_name=''
while getopts "hv:s:n:" opt; do
    case "${opt}" in
	h)
	    usage; exit 0;;
	v)
	    drupal_version="${OPTARG}";;
	s)
	    project_status="${OPTARG}";;
	n)
	    project_name="${OPTARG}";;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    usage >&2; exit 1;;
	\?)
	    usage >&2; exit 1;;
    esac
done
shift $((OPTIND-1))

# Check that all required parameters are there
if [ -z "${drupal_version}" ] || [ -z "${project_status}" ] || [ -z "${project_name}" ]; then
    echo "At least a required parameter is missing." >&2
    usage >&2
    exit 1
fi


. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh


if [ ! "${drupal_version}" = d7 ] ; then
    echo Unrecognize version. >&2
    exit 1
fi

number_found=0

for site in $(sites_list) ; do
    # List projects that correspond to the status.
    # Keep project_name if listed.
    # Count line result. 0 if not listed or 1 if listed.
    # Print site_dir if listed.

    if [ 1 -le $(drush @"${site}" pml --status="${project_status}" | grep "${project_name}" | wc -l) ] ; then
        echo "${site}";
        number_found=$((${number_found} + 1))
    fi
done

echo "Number of sites found for project ${project_name} and status ${project_status} : $number_found";
