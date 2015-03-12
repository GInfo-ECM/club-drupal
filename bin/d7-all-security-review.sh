#!/bin/sh

. /home/assos/bin/scripts-config.sh

d7-all-drush.sh security-review --results -q --store 2>&1 
