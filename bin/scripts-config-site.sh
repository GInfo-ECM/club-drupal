#!/bin/sh

# Sets useful variables of a site.
# ARGS: site_name
# Requires scripts-config.sh
# check_argumements is not used to avoid multiple imports

# Check if scripts-config.sh is imported.
if [ -z "${scripts_config}" ] ; then
    echo "Import of scripts-config.sh required."
    exit 1
fi

if [ -z "$1" ] ; then
    echo "This script needs a site name as argument."
    exit 1
fi

scripts_config_site='imported'

d7_site_name="$1"
d7_site_dir="${d7_dir_sites}/assos.centrale-marseille.fr.${d7_site_name}"
d7_site_settings="${d7_site_dir}/settings.php"
d7_site_settings_local="${d7_site_dir}/settings.local.php"
