#!/usr/bin/env bash

help=<<EOF
This script takes 2 arguments: the old and new location of assos' bin directory. It remplace
all occurences of the former emplacement are remplaced by the new one.
EOF

for file in $(ls $1/bin/*.sh) ; do
    sed "s#$1#$2#" > $file.tmp
    mv $file.tmp $file
done
