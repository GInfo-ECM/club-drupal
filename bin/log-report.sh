#!/bin/sh
. /home/assos/bin/scripts-config.sh
. /home/assos/.functions

current_day=$(date "+%Y-%m-%d")
log_file="${d7_dir_log}/${current_day}.log"

# We use the function my-unlog to activate the virtualenv and then correctly
# use unlog in it.
my-unlog "${log_file}" --config /home/assos/.unlog  --mail-subject "Unlog: ${current_day}"
