#!/bin/sh

usage() {
    printf "d7-all-dump-individual.sh -m MODE\nRecognized mode are:\n\t%s\n\t%s\n" 'manunal' 'auto'
    printf "d7-all-dump-individual.sh -h prints this help message.\n"
}

mode=''
while getopts "hm:" opt; do
    case "${opt}" in
	h)
	    usage; exit 0;;
	m)
	    mode="${OPTARG}";;
	:)
	    echo "Option -${OPTARG} requires an argument." >&2
	    usage >&2; exit 1;;
	\?)
	    usage >&2; exit 1;;
    esac
done
shift $((OPTIND-1))


. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh


current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")

for site in $(sites_list); do
    drush @"${site}" cc all

    dir=$(get_site_dir_from_name "${site}")

    if [ "${mode}" = 'auto' ] ; then
        drush @"${site}" sql-dump --result-file="${d7_dir_individual_auto_backup}/${dir}/${current_date}.${dir}.sql" --gzip
    else
        drush @"${site}" sql-dump --result-file="${d7_dir_individual_manual_backup}/${dir}/${current_date}.${dir}.sql" --gzip
    fi
done
