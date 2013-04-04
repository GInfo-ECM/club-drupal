#!/bin/sh


##############
# nlehuby - 8 juillet 2011
##############

#activer ces modules du fichier texte
for line in $(cat modules_tiers.txt); do drush en -y "$line" ; done  

#effacer le fichier texte après ?
