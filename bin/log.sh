#!/bin/sh
. /home/assos/bin/scripts-config.sh

log=$(cat)

current_day=$(date "+%Y-%m-%d")
log_file="${d7_dir_log}/${current_day}.log"

echo "$log" > "${log_file}"
