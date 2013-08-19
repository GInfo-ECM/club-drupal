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
    # usage: pass=`ask_password "password please:"`
    echo $1 >&2
    echo -n ">" >&2
    stty_avant=`stty -g`
    stty -echo
    read password
    stty $stty_avant
    echo "$password"
    unset password
}

ask_password_db() {
    # ARGS: server_name, user_name
    local db_password="pour_boucler"
    # empty db request to validate password
    while ! mysql -h $1 -u $2 -p$db_password -e "" 2>/dev/null ; do
        db_password=`ask_password "database password:"`
    done
    echo $db_password
}

generate_password(){
    # ARGS: [password_length]
    # The password contains special characters. '/' must be excluded to avoid sed malfunction.

    local site_password='/'

    if [ -z $1 ] ; then
        local password_length=20
    else
        local password_length=$1
    fi

    while echo "$site_password" | grep -Fq '/' ; do
        site_password=`dd if=/dev/urandom count=1 | uuencode -m - | head -n 2 | tail -n 1 | cut -c-$password_length`
    done

    echo $site_password
}

count_d7_sites(){
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
