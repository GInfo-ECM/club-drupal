#!/bin/sh

# This script contains useful functions for other scripts.

# Check if scripts-config.sh is imported.
if [ -z "${scripts_config}" ] ; then
    echo "Import of scripts-config.sh required."
    . /home/assos/bin/scripts-config.sh
fi

scripts_utils='imported'

ask_password() {
    # read -s doesn't work with sh.
    # usage: pass=$(ask_password "password please:")
    echo "$1" >&2
    echo -n ">" >&2
    stty_avant=$(stty -g)
    stty -echo
    read password
    stty "${stty_avant}"
    echo "${password}"
    unset password
}

generate_password() {
    # ARGS: [password_length]
    # The password contains special characters. '/' must be excluded to avoid sed malfunction.

    local site_password='/'

    if [ -z "$1" ] ; then
        local password_length=20
    else
        local password_length="$1"
    fi

    while echo "$site_password" | grep -Fq '/' ; do
        site_password=$(dd if=/dev/random count=1 | uuencode -m - | head -n 2 | tail -n 1 | cut -c-"${password_length}")
    done

    echo "$site_password"
}

check_arguments() {
    # ARGS: number of arguments passed to script, number of arguments required, [help text]
    if [ "$1" -lt "$2"  ] ; then
        echo "Not enough arguments." >&2
	echo -e "$3" >&2
        exit 1
    fi
}

generate_settings_local() {
    # ARGS: site_name, site_password, d7_settings_local_template, d7_site_settings_local
    sed "s/\%\%DBUSER\%\%/$1/ ; s/\%\%DBNAME\%\%/$1/ ; s/\%\%DBPASS\%\%/$2/ ; s/\%\%SITE_NAME\%\%/$1/" < "$3" > "$4"
}

give_dir() {
    # ARG: file
    # Return the abosulte directory path of a file or a dir.
    settings_location=$(realpath "$1")
    echo $(dirname "${settings_location}")
}

work_tree_clean() {
    git_status_output=$(git status --porcelain)
    if [ -z "${git_status_output}" ] ; then
	return 0
    else
	return 1
    fi
}

mail_unclean_work_tree() {
    cd "${dir_multi_assos}"
    git_status_output=$(git status)
    echo "${git_status_output}" | mail -s "$1" "${email_multi_assos}"
}

commit_if_unclean() {
    if ! work_tree_clean ; then
	commit_message="COMMIT OF UNCLEAN STUFF"
	commit -a -m "${commit_message}"
	mail_unclean_work_tree "[git] ${commit_message}"
    fi
}

commit() {
    # ARG: commit message
    if [ -z "$1" ] ; then
	echo "Empty commit message. Nothing was commited." >&2
	return 2
    fi
    cd "${dir_multi_assos}"
    git commit -a -m "$1"
}

site_exists() {
    # Check if site database exists.
    if mysql --defaults-extra-file="${myassos_cnf}" -e "USE $1" 2>/dev/null ; then
	echo "Database $1 already exits." >&2
	return 0
    fi

    # Check if site folder already exists.
    dir="${d7_dir_sites}/$1"
    if [ -d "${dir}" ] ; then
	echo "Folder ${dir} already exists." >&2
	return 0
    fi
    return 1
}

get_site_dir_from_name() {
    if [ "$1" = 'default' ]; then
	dir='default'
    else
	dir="assos.centrale-marseille.fr.$1"
    fi

    echo "${dir}"
}

get_absolute_site_dir_from_name() {
    dir=$(get_site_dir_from_name "$1")
    echo "${d7_dir_sites}/${dir}"
}

sites_list() {
    # The commands output assos.centrale-marseille.fr/<site-name> or assos.centrale-marseille.fr (default).
    # Since we want only the site name (and default for default), we replace assos.centrale-marseille.fr by
    # assos.centrale-marseille.fr/default so it si like other site. We then use awk to split the strip on /
    # and get only the site name.
    # grep -v "^self$" is used to remove self that appear if command is launched in one of drupal directories
    drush sa --format=csv --fields="name","uri" |
        sed 's#^assos.centrale-marseille.fr$#asoss.centrale-marseille.fr/default#' |
        awk '{if ($1 != "") { split($1, a, "/"); print a[2];}}' |
        sort |
        grep -v "^self$"
}
