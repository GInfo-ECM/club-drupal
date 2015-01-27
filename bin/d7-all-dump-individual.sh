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
. scripts-utils.sh


current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")

cd "${d7_dir_sites}"

for dir in $(find . -maxdepth 1 -mindepth 1 -type d ! -name all | cut -c3-); do
    cd "${dir}"
    drush cc all
    if [ "${mode}" = 'auto' ] ; then
        drush sql-dump --result-file="${d7_dir_individual_auto_backup}/${dir}/${current_date}.${dir}.sql" --gzip
    else
        drush sql-dump --result-file="${d7_dir_individual_manual_backup}/${dir}/${current_date}.${dir}.sql" --gzip
    fi
    cd -
done
