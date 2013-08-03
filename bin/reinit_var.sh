#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin


##############
# nlehuby - 21 mai 2012
# ce script permet de réinitialiser un certain nombre de variables et configurations. VERSION 2, sans duplication de code
# TODO : tester que ça fonctionne ^^
# Plus d'info : http://ginfo.centrale-marseille.fr/wiki/index.php?title=Scripts_et_t%C3%A2ches_planifi%C3%A9es#la_r.C3.A9initialisation_des_variables_dangeureuses
##############

#installation drupal 7
/users/guest/assos/bin/drushall_atest init #lance le script init_var pour toute l'installation d7

#installation drupal 6
cd /users/guest/assos/html/sites
/users/guest/assos/bin/drushall vset --always-set reverse_proxy TRUE
/users/guest/assos/bin/drushall vset --always-set --format=json reverse_proxy_addresses '["147.94.19.16","147.94.19.17"]'
drush @sites ev "variable_set('update_notify_emails', array('assos@centrale-marseille.fr'));" --yes
