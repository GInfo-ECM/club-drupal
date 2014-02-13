#!/bin/bash

for dir in $(find /users/guest/assos/drupal7/sites -maxdepth 1 -mindepth 1 -type d ! -name all | sort) ; do

    ## Get database name
    site=${dir##*/}
    db=${site##*.}
    if [ $db = 'default' ] ; then
	db='default_assos'
    fi

    ##  Look in the variable table
    mysql --defaults-extra-file=~/private/myassos.cnf -N -e "SELECT value FROM $db.variable WHERE CONVERT(value USING utf8) LIKE '%htmltest%'" > ~/tmp/out

    ## If results
    if [ $(cat ~/tmp/out | wc -l) -ne 0 ] ; then
	sed 's/htmltest/drupal7/g' < ~/tmp/out > ~/tmp/in

	i=$((0))
	while read line ; do
	    out[$i]=$line
	    i=$((i+1))
	done < ~/tmp/out

	i=$((0))
	while read line ; do
	    in[$i]=$line
	    i=$((i+1))
	done < ~/tmp/in

	for i in $(seq 0 $((${#out[*]}-1))) ; do
	    mysql --defaults-extra-file=~/private/myassos.cnf -e "UPDATE $db.variable SET value=${in[$i]} WHERE value = ${out[$i]}"
	done

	rm ~/tmp/out ~/tmp/in
    fi
    read key
done
