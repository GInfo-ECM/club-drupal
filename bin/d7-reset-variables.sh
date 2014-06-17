#!/bin/sh

. /home/assos/bin/scripts-config.sh

# ARGS: [site_name]

if [ ! -z $1 ] ; then
    . scripts-config-site.sh $1
    # default is an exception to the rule
    if echo $1 | grep default > /dev/null ; then
	    cd $d7_dir_sites/default
    else
	cd $d7_site_dir
    fi
fi

current_timestamp=$(date "+%s")

random_1=$(dd if=/dev/urandom count=1 2> /dev/null | cksum | cut -f1 -d" ")
random_2=$(dd if=/dev/urandom count=1 2> /dev/null | cksum | cut -f1 -d" ")

####### General variables
drush -yq vset --always-set reverse_proxy TRUE
drush -yq vset --always-set --format=json reverse_proxy_addresses '["147.94.19.16","147.94.19.17"]'
drush -yq ev "variable_set('update_notify_emails', array('$email_multi_assos_update'));"
drush -yq vset error_level 0
drush -yq vset dblog_row_limit 1000
drush -yq vset cron_safe_threshold 0

###### Hidden captcha
drush -yq en hidden_captcha
# Log wrong answers.
drush -yq vset captcha_log_wrong_responses 1
# Use hidden captcha for all forms.
drush -yq sqlq --db-prefix "UPDATE {captcha_points} SET module = 'hidden_captcha', captcha_type = 'Hidden CAPTCHA' WHERE module is NULL;"
# Flush captcha cache.
drush -yq vdel captcha_placement_map_cache
# Randomely generate a math question as the label of the hidden captcha field.
drush -yq vset hidden_captcha_label "$random_1 + $random_2"


####### Piwik
d7-reset-piwik-variables.sh $d7_site_name

###### Security review
# For untrusted roles:
# 1: anonymous user
# 2: authenticated user
# 3: administrator
drush -yq en security_review
drush -yq ev "variable_set('security_review_untrusted_roles', array('1'));"
# The default method to check settings.php do not work because we include a global and local settings.php
drush -yq vset security_review_base_url_method include
# Used to initialise entries in the database schema.
drush -yq security-review --store
# file_perms : Security Review can't check for files permissions on multi_assos if launched within the web interface.
# private_files : we have chosen a private path in the files repository and Security Review raise errors but this path is secure.
drush -yq sqlq --db-prefix "UPDATE {security_review} SET skip = '1', skiptime = $current_timestamp, skipuid = '1' WHERE reviewcheck IN ('file_perms', 'private_files');"
drush -yq sqlq --db-prefix "UPDATE {security_review} SET skip = '0', skiptime = '0', skipuid = NULL WHERE reviewcheck NOT IN ('file_perms', 'private_files');"

###### Performance
# Active cache
drush -yq vset cache 1
drush -yq vset block_cache 1
# Lifetime : 0, 60, 180, 300, 600, 900, 1800, 2700, 3600, 10800, 21600, 32400, 43200
drush -yq vset cache_lifetime 0
drush -yq vset page_cache_maximum_age 300
# Compression
drush -yq vset page_compression 1
drush -yq vset preprocess_css 1
drush -yq vset preprocess_js 1
