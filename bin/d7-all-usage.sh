#!/bin/sh

. /home/assos/bin/scripts-config.sh

# For each modules and themes, list and count how much sites use its.

for line in $(drush @default pml --no-core --pipe); do
    usage.sh -v d7 -s enabled -n "${line}"
    echo -e "\n"
done
