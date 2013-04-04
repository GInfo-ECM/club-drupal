#!/bin/sh


##############
# nlehuby - 8 juillet 2011
##############

#écrire le nom des modules non core dans un fichier
drush pml |grep -v Core* | grep Module | grep Enabled > fichier.temp
sed -e 's/\(.*(\)\(.*\)\().*\)/\2/' fichier.temp > modules_tiers.txt

#désactiver ces modules
for line in $(cat modules_tiers.txt); do drush dis -y "$line" ; done  

#effacer les fichiers créés
rm fichier.temp
