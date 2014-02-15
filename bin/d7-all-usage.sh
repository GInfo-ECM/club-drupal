#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

# For each modules and themes, list and count how much sites use its.

cd $d7_dir_sites

drush pml --no-core --pipe > $dir_tmp/pml.txt

for line in $(cat $dir_tmp/pml.txt); do
    usage.sh d7 enabled "$line"
done

rm $dir_tmp/pml.txt