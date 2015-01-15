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
. scripts-utils.sh


if [ "${drupal_version}" = d7 ] ; then
    cd "${d7_dir_sites}"
else
    echo Unrecognize version.
fi

number_found=0

for dir in $(find . -maxdepth 1 -mindepth 1 -type d ! -name all ! -name languages ! -name images | sort) ; do
    # List projects that correspond to the status.
    # Keep project_name if listed.
    # Count line result. 0 if not listed or 1 if listed.
    # Print site_dir if listed.

    cd "${dir}";
	if [ 1 -le $(drush pml --status="${project_status}" | grep "${project_name}" | wc -l) ] ; then
        echo "${dir}";
        number_found=$(($number_found + 1))
    fi
    cd -
done

echo "Number of sites found for project ${project_name} and status ${project_status} : $number_found";
