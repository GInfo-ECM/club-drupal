#!/usr/bin/env bash

help=<<EOF
This script takes 2 arguments: the old and new location of assos' bin directory. It remplace
all occurences of the former emplacement are remplaced by the new one.
EOF

correct_path() {
    sed "s#$1#$2#" < $3 > $3.tmp
    mv $3.tmp $3
}


# Bin
for file in $(ls bin/*.sh) ; do
   correct_path $1 $2 $file
done

# drush aliases
correct_path $1 $2 .drush/aliases.drushrc.php
