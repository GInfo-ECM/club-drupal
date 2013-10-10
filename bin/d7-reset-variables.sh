#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

# ARGS: [site_name]

if [ ! -z $1 ] ; then
    . scripts-config-site.sh $1
    cd $d7_site_dir
fi

current_timestamp=`date "+%s"`

random_1=`dd if=/dev/urandom count=1 2> /dev/null | cksum | cut -f1 -d" "`
random_2=`dd if=/dev/urandom count=1 2> /dev/null | cksum | cut -f1 -d" "`

####### General variables
drush -y vset --always-set reverse_proxy TRUE
drush -y vset --always-set --format=json reverse_proxy_addresses '["147.94.19.16","147.94.19.17"]'
drush -y ev "variable_set('update_notify_emails', array('$email_multi_assos'));"
drush -y vset error_level 0
drush -y vset dblog_row_limit 1000
drush -y vset cron_safe_threshold 0

###### Hidden captcha
drush -y en hidden_captcha
# Log wrong answers.
drush -y vset captcha_log_wrong_responses 1
# Use hidden captcha for all forms.
drush -y sqlq --db-prefix "UPDATE {captcha_points} SET module = 'hidden_captcha', captcha_type = 'Hidden CAPTCHA' WHERE module is NULL;"
# Flush captcha cache.
drush -y vdel captcha_placement_map_cache
# Randomely generate a math question as the label of the hidden captcha field.
drush -y vset hidden_captcha_label "$random_1 + $random_2"


####### Piwik
drush -y en piwik
drush -y vset piwik_site_id "101"
drush -y vset piwik_url_http "http://piwik.centrale-marseille.fr/"
drush -y vset piwik_url_https "https://piwik.centrale-marseille.fr/"
# Piwik cache.
drush -y vset piwik_cache 1
drush -y vset piwik_visibility_roles "1"
# Piwik is enable for everyone except the administrator
drush -y vset --format=json piwik_roles '[3]'
drush -y vset piwik_page_title_hierarchy 1
# Activate local search.
drush -y vset piwik_site_search 1


###### Security review
# For untrusted roles:
# 1: anonymous user
# 2: authenticated user
# 3: administrator
drush -y en security_review
drush -y ev "variable_set('security_review_untrusted_roles', array('1'));"
drush vset security_review_base_url_method include
# Used to initialise entries in the database schema.
drush security-review --store
# Security review can't check for files permissions on multi_assos if launched within the web interface.
drush -y sqlq --db-prefix "UPDATE {security_review} SET skip = '1', skiptime = $current_timestamp, skipuid = '1' WHERE reviewcheck IN ('file_perms');"
drush -y sqlq --db-prefix "UPDATE {security_review} SET skip = '0', skiptime = '0', skipuid = NULL WHERE reviewcheck NOT IN ('file_perms');"
