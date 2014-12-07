#!/bin/sh
. /home/assos/bin/scripts-config.sh

current_day=$(date "+%Y-%m-%d")
log_file="${d7_dir_log}/${current_day}.log"

unlog "${log_file}" --config /home/assos/.unlog  --mail-subject "Unlog: ${current_day}"
