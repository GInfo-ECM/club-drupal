#!/bin/sh
. /home/assos/bin/scripts-config.sh

current_day=$(date "+%Y-%m-%d")
log_file="${d7_dir_log}/${current_day}.log"

cat "${log_file}" | mail -s "Log: ${current_day}" assos
python3 /home/assos/tmp/unlog/unlog/main.py "${log_file}" --config /home/assos/.unlog  --mail-subject "Unlog: ${current_day}"
