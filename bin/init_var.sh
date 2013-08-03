#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin


##############
# nlehuby - 20 mai 2012
# ce script permet d'initialiser un certain nombre de variables et configurations.
# Plus d'info : http://ginfo.centrale-marseille.fr/wiki/index.php?title=Utilisation_de_Drupal_multi-site#M.C3.A9thode_Drupal_7
##############

####### General variables
drush -y vset --always-set reverse_proxy TRUE
drush -y vset --always-set --format=json reverse_proxy_addresses '["147.94.19.16","147.94.19.17"]'
drush -y ev "variable_set('update_notify_emails', array('assos@centrale-marseille.fr'));"
drush vset error_level 0


####### Piwik
#On active piwik l’outil de statistique
drush -y vset piwik_site_id "101"
drush -y vset piwik_url_http "http://piwik.centrale-marseille.fr/"
drush -y vset piwik_url_https "https://piwik.centrale-marseille.fr/"
# active le cache local du javascript
drush -y vset piwik_cache 1
drush -y vset piwik_visibility_roles "1"
# active les stats pour anonymous et authentifié
drush -y vset --format=json piwik_roles '{"1":0,"2":0}'
drush -y vset piwik_page_title_hierarchy 1
# si la recherche locale est activée
drush -y vset piwik_site_search 1
# on active le module
drush -y en piwik
