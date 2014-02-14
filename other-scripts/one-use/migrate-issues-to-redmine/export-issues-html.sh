#!/bin/bash

mysql -h debian -e "SELECT id FROM issues WHERE project_id = $1" -u root -ptata redmine_default > issues_id_list

mkdir issues_html
cd issues_html
while read line; do
    wget -k http://debian/redmine/issues/$line > /dev/null
done < ../issues_id_list
