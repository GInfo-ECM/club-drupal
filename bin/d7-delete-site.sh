#!/bin/sh

usage() {
    echo "d7-delete-site.sh -s site_name."
}

site_name=''
while getopts "hs:" opt; do
    case "${opt}" in
	h)
	    usage; exit 0;;
	s)
	    site_name="${OPTARG}";;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    usage >&2; exit 1;;
	\?)
	    usage >&2; exit 1;;
    esac
done
shift $((OPTIND-1))

. /home/assos/bin/scripts-config.sh
. scripts-config-site.sh "${site_name}"
. scripts-utils.sh

echo 'Awaiting for git status. (may take a while)'
if ! work_tree_clean ; then
    echo "Your work tree is not clean. Solve this before $0 can continue."
    exit 2
fi

echo 'Delete database.'
mysql --defaults-extra-file="${myassos_cnf}" -e "DROP DATABASE ${d7_site_name}"

echo 'Delete MYSQL user.'
mysql --defaults-extra-file="${myassos_cnf}" -e "DROP USER '${d7_site_name}'@'%'"

echo "Delete site's folder."
chmod -R u=rwX,go-rwx "${d7_site_dir}"
rm -r "${d7_site_dir}"

# Delete symbolic link.
rm "${d7_dir}/${d7_site_name}"

echo 'Remove site line from sites.php'
chmod +w "${sites_php}"
grep -sv "^\$.*$d7_site_name';$" "${sites_php}" > "${dir_tmp}/sites.php"
mv "${dir_tmp}/sites.php" "${sites_php}"
chmod 400 "${sites_php}"

echo 'Remove site alias from aliases.drushrc.php'
grep -sv "${d7_site_name}'" "${aliases_drushrc_php}" > "${dir_tmp}/aliases.php"
mv "${dir_tmp}/aliases.php" "${aliases_drushrc_php}"

echo 'Delete database backups.'
rm -r "${d7_dir_individual_auto_backup}/assos.centrale-marseille.fr.${d7_site_name}"
rm -r "${d7_dir_individual_manual_backup}/assos.centrale-marseille.fr.${d7_site_name}"

echo 'Remove site from nginx_map'
d7-generate-nginx-map.sh
# Restart nginx
sudo service nginx restart

echo "Don't forget to:"
echo "- Refresh node site on default"
echo "- Check particular behavior (normally detailed on site node)"

commit "Deletion of site: ${d7_site_name}"
