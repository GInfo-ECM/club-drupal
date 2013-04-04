#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin


##############
# nlehuby - 20 mai 2012
# ce script permet d'initialiser un certain nombre de variables et configurations. 
# Plus d'info : http://ginfo.centrale-marseille.fr/wiki/index.php?title=Utilisation_de_Drupal_multi-site#M.C3.A9thode_Drupal_7
##############

drush php-eval variable_set\(\'allow_authorize_operations\',FALSE\)\; 
drush vset --always-set reverse_proxy TRUE
drush vset --always-set --format=json reverse_proxy_addresses '["147.94.19.16","147.94.19.17"]'
drush ev "variable_set('update_notify_emails', array('assos@centrale-marseille.fr'));"
drush vset error_level 0

