#!/bin/sh

##############
# nlehuby - 07 juillet 2012
# ce script permet de vérifier la consommation d'espace disque du compte assos, et de répérer d'éventuelles irrégularités (mises à jour foireuses, etc)
##############

echo "Utilisation totale du compte assos :"
du -hcs /users/guest/assos/ | grep total

#Line breaK
echo -e "\n"

echo "Taille des logs (Desktop/log/) :"
du -hcs /users/guest/assos/Desktop/log/ | grep total

#Line breaK 
echo -e "\n"

echo "*Utilisation de l'installation d6 (html/sites/) :"
du -hcs /users/guest/assos/html/sites/ | grep total

#Line breaK 
echo -e "\n"

echo "*Utilisation de l'installation d7 (htmltest/sites/) :"
du -hcs /users/guest/assos/htmltest/sites/ | grep total

#Line breaK 
echo -e "\n"

echo "Détails pour l'installation d6 :"
cd /users/guest/assos/html/sites
for x in $(ls -1 | grep -v 'all'); do
  if [ -d $x -a ! -L $x ]; then
  du -hs $x;
    fi
done

#Line breaK 
echo -e "\n"

echo "Détails pour l'installation d7 :"
cd /users/guest/assos/htmltest/sites
for x in $(ls -1 | grep -v 'all'); do
  if [ -d $x -a ! -L $x ]; then
  du -hs $x;
    fi
done
