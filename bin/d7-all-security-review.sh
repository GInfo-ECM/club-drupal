#!/bin/sh

. /home/assos/bin/scripts-config.sh

# grep -v success to keep site_name and error lines.
d7-all-drush.sh security-review --store 2>&1 | grep -v success | mail -s d7-all-security-review.sh "${email_multi_assos}"
