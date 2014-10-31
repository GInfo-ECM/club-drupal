#!/bin/sh
. /home/assos/bin/scripts-config.sh

log=$(cat)
command="$1"

current_day=$(date "+%Y-%m-%d")
current_time=$(date "+%H-%M-%S")
log_file="${d7_dir_log}/${current_day}.log"

echo -e "#### ${command} — ${current_time}\n${log}\n#### END\n" >> "${log_file}"
