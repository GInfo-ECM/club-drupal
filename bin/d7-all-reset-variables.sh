#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

for site in $(sites_list); do
    echo "${site}"
    d7-reset-variables.sh "${site}"
done
