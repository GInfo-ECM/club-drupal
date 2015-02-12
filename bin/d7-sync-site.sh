#!/usr/bin/env bash

usage() {
    help="This script is intended to ease the synchronisation between any site hosted by assos.
Typically, this script is usefull when you have (or want to have) a test site based on
a already working site. It relies on bash, drush and drush aliases.

Before synching the site, the destination site's database is backuped. If the
destination site does not exist, it is created. If prod is set, the site is not in
maintenance mode.

usage: d7-sync.sh -s SOURCE_SITENAME -d DEST_SITENAME [-p]"
    echo -e "${help}"
}

source_site_name=''
dest_site_name=''
prod=false
while getopts "hs:d:p" opt; do
    case "${opt}" in
	s)
	    source_site_name="${OPTARG}";;
	d)
	    dest_site_name="${OPTARG}";;
	p)
	    prod=true;;
	h)
	    usage; exit 0;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    usage >&2; exit 1;;
	\?)
	    usage >&2; exit 1;;
    esac
done
shift $((OPTIND-1))

if [ -z "${source_site_name}" ] || [ -z "${dest_site_name}" ]; then
    echo "At least a required parameter is missing." >&2
    usage >&2
    exit 1
fi


. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh


# Create site if necessary
if ! site_exists "${dest_site_name}" > /dev/null ; then
    echo "${dest_site_name} does not exit. We will create it"
    d7-create-site.sh "${dest_site_name}" --no-init-database
    # if the site is new, there is no database
    new_site=1
fi


# Backup the database of SOURCE_SITE
current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")
if [ "${source_site_name}" = "default" ] ; then
    dir="${dest_site_name}"
else
    dir="assos.centrale-marseille.fr.${dest_site_name}"
fi
if [ -z "${new_site}" ] ; then
    drush -y "@${source_site_name}" sql-dump --result-file="${d7_dir_individual_manual_backup}/${dir}/${current_date}.${dir}.sql" --gzip
fi


# Sync files
drush -y rsync --delete --exclude="*.php" "@${1}:%site" "@${2}:%site"


# Sync databases
## Save file system
if [ -z "${new_site}" ] ; then
    private_path=$(drush "@${dest_site_name}" vget --format=string file_private_path 2> /dev/null)
    public_path=$(drush "@${dest_site_name}" vget --format=string file_public_path 2> /dev/null)
    temp_path=$(drush "@${dest_site_name}" vget --format=string file_temporary_path 2> /dev/null)
fi

## Sync
current_date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")
sql_file="${dir_tmp}/${current_date}.${source_site_name}.sql"
drush -y "@${source_site_name}" sql-dump --result-file="${sql_file}"
sed -i -e "s#https?://assos.centrale-marseille.fr/${source_site_name}#https://assos.centrale-marseille.fr/${dest_site_name}#g" "${sql_file}"
sed -i -e "s#/${source_site_name}/sites/assos.centrale-marseille.fr.${source_site_name}#/${dest_site_name}/sites/assos.centrale-marseille.fr.${dest_site_name}#g" "${sql_file}"
drush "@${dest_site_name}" sql-drop
drush "@${dest_site_name}" sql-cli < "${sql_file}"
rm "${sql_file}"

## Restore file system
if [ -n "${private_path}" ] ; then
    drush -y "@${dest_site_name}" vset file_private_path "${private_path}"
fi
if [ -n "${public_path}" ] ; then
    drush -y "@${dest_site_name}" vset file_public_path "${public_path}"
fi
if [ -n "${temp_path}" ] ; then
    drush -y "@${dest_site_name}" vset file_temporary_path "${temp_path}"
fi

if "${prod}"; then
    drush -y "@${dest_site_name}" vset maintenance_mode 0
else
    drush -y "@${dest_site_name}" vset maintenance_mode 1
fi
