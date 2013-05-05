#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin


##############
# nlehuby - 21 mai 2012
# ce script permet d'effectuer les mises à jour des projets pour l'installation drupal 7
##############

#Lancer le cron pour que les sites sachent s'il y a des majs à faire
/users/guest/assos/bin/drushall_atest -q cron 
#Supprimer le cache pour réduire de moitié la taille des bases de données sauvegardées 
/users/guest/assos/bin/drushall_atest cc all
#Script de sauvegarde des bases de données
/bin/sh /users/guest/assos/bin/dump_site_atest_all
#Mettre à jour le code des modules et thèmes tiers
/users/guest/assos/bin/drushall_atest --no-core -y upc 
/users/guest/assos/bin/drushall_atest -y updb
#Rapport du cron
/users/guest/assos/bin/drushall_atest cron | mail -s "Rapport cron" assos@centrale-marseille.fr
#Rapport sur la taille utilisée du disque
/bin/sh /users/guest/assos/bin/taille.sh | mail -s "Rapport utilisation disque" assos@centrale-marseille.fr 
