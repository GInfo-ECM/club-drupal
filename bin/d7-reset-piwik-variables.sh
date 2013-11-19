#!/bin/sh

###### Common to all sites
drush -yq en piwik
drush -yq vset piwik_url_http "http://piwik.centrale-marseille.fr/"
drush -yq vset piwik_url_https "https://piwik.centrale-marseille.fr/"
# Piwik cache.
drush -yq vset piwik_cache 1
drush -yq vset piwik_visibility_roles "1"
# Piwik is enable for everyone except the administrator
drush -yq vset --format=json piwik_roles '[3]'
drush -yq vset piwik_page_title_hierarchy 1
# Activate local search.
drush -yq vset piwik_site_search 1

##### Specific
# Note: you can read the piwik site id from the url in piwik
if [ $1 = forumentreprises ] ; then
    piwik_id=270
elif [ $1 = fablab ] ; then
    piwik_id=151
elif [ $1 = agora ] ; then
    piwik_id=116
elif [ $1 = mdv ] ; then
    piwik_id=99
elif [ $1 = tvp ] ; then
    piwik_id=110
else
    piwik_id=101
fi

drush -yq vset piwik_site_id $piwik_id
