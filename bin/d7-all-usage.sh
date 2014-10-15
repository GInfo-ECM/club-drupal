#!/bin/sh

. /home/assos/bin/scripts-config.sh

# For each modules and themes, list and count how much sites use its.

cd "${d7_dir_sites}"

for line in $(drush pml --no-core --pipe); do
    usage.sh d7 enabled "${line}"
    echo -e "\n"
done
