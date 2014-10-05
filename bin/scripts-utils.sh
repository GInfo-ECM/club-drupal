#!/bin/sh

# This script contains useful functions for other scripts.

# Check if scripts-config.sh is imported.
if [ -z $scripts_config ] ; then
    echo "Import of scripts-config.sh required."
    . scripts-config.sh
fi

scripts_utils='imported'

ask_password() {
    # read -s doesn't work with sh.
    # usage: pass=$(ask_password "password please:")
    echo $1 >&2
    echo -n ">" >&2
    stty_avant=$(stty -g)
    stty -echo
    read password
    stty $stty_avant
    echo "$password"
    unset password
}

generate_password() {
    # ARGS: [password_length]
    # The password contains special characters. '/' must be excluded to avoid sed malfunction.

    local site_password='/'

    if [ -z $1 ] ; then
        local password_length=20
    else
        local password_length=$1
    fi

    while echo "$site_password" | grep -Fq '/' ; do
        site_password=$(dd if=/dev/random count=1 | uuencode -m - | head -n 2 | tail -n 1 | cut -c-$password_length)
    done

    echo $site_password
}

count_d7_sites() {
    find $d7_dir_sites -type d ! -name all -maxdepth 1 | wc -l
}

check_arguments() {
    # ARGS: number of arguments passed to script, number of arguments required, [help text]
    if [ $1 -lt $2  ] ; then
        echo "Number of arguments insuffisant."
	echo -e $3
        exit 1
    fi
}

generate_settings_local() {
    # ARGS: site_name, site_password, d7_settings_local_template, d7_site_settings_local
    sed "s/\%\%DBUSER\%\%/$1/ ; s/\%\%DBNAME\%\%/$1/ ; s/\%\%DBPASS\%\%/$2/ ; s/\%\%SITE_NAME\%\%/$1/" < $3 > $4
}

give_dir() {
    # ARG: file
    # Return the abosulte directory path of a file or a dir.
    settings_location=$(realpath $1)
    echo $(dirname $settings_location)
}

work_tree_clean() {
    git_status_output=$(git status --porcelain)
    if [ -z "$git_status_output" ] ; then
	return 0
    else
	return 1
    fi
}

mail_unclean_work_tree() {
    cd $dir_multi_assos
    git_status_output=$(git status)
    echo "$git_status_output" | mail -s "$1" $email_multi_assos
}

commit_if_unclean() {
    if ! work_tree_clean ; then
	commit_message="COMMIT OF UNCLEAN STUFF"
	commit -a -m "$commit_message"
	mail_unclean_work_tree "[git] $commit_message"
    fi
}

commit() {
    # ARG: commit message
    if [ -z "$1" ] ; then
	echo "Empty commit message. Nothing was commited."
	return 2
    fi
    cd $dir_multi_assos
    git commit -a -m "$1"
}

site_exists() {
    # Check if site database exists.
    if mysql --defaults-extra-file=$myassos_cnf -e "USE $1" 2>/dev/null ; then
	echo "Database $1 already exits."
	return 0
    fi

    # Check if site folder already exists.
    dir=$d7_dir_sites/$1
    if [ -d "$dir" ] ; then
	echo "Foder $dir already exists."
	return 0
    fi
    return 1
}

update_nginx_map() {
    nginx_map_template='map $uri $subsite {\n
    ~^/(?P<sub>%%PATTERN%%) $sub;\n
}\n'
    new_nginx_map_pattern=$(cat $nginx_site_names | tr "\n" "|" | head -c -1)
    new_nginx_sites_map=${nginx_map_template/"%%PATTERN%%"/$new_nginx_map_pattern}

    echo -e $new_nginx_sites_map > $nginx_sites_map
}
