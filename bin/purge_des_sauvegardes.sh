#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin:/users/guest/assos/bin

init_scripts.sh

######## sauvegardes individuelles

#####
# À réfléchir
#####
# va dans le dossier des sauvegardes individuelles
cd $manual_backup_dir

#s'il y a plus de 2 x (le nombre de site d7) - 1 fichiers alors
nb_sites_d7=$(d7_give_nb_sites)

let "c=2*$nb_sites_d7 - 1" >/dev/null

if [ $(ls -l | wc -l)  -gt  $c ]
then
    echo "je supprime des sauvegardes isolées"
    #supprime (le nombre de site d7) plus vieux fichiers
    ls -tr | head -$nbsitesd7 | xargs rm;
else
    #sinon, alerte
    echo "La purge des sauvegardes des sites individuelles n'a pas pu être effectuée car il n'y avait pas assez de fichiers dans le dossier." | mail -s "[dump assos] Sauvegardes de bdd individuelles" assos@centrale-marseille.fr;

fi
echo `ls -l | wc -l `



######## SAUVEGARDES COMPLÈTES
#### sauvegardes complètes d6
#va dans le site des sauvegardes complètes d6
cd $d6_backup_dir

nb_files=$(ls -l | wc -l)

if [ $nb_files -gt 6 ]
then
    #s'il y a plus de 6 fichiers alors
    echo "je supprime du d6"

    #supprime les assez de fichiers pour qu’il n’en reste que trois
    let "to_delete = $nb_files - 6"
    ls -tr | head -$to_delete | xargs rm
else
    #sinon, alerte
    echo "La purge des sauvegardes complètes des bases de données drupal 6 n'a pas pu être effectuée car il n'y avait pas assez de fichiers dans le dossier. Il faudrait vérifier que le script de sauvegarde s'exécute correctement" | mail -s "[dump assos] Purge sauvegardes de bdd complète d6" assos@centrale-marseille.fr ;
fi

echo $(ls -l | wc -l)


###### sauvegardes complètes d7
cd $d7_backup_dir

for dir in $(ls)
do
    cd $dir
    nb_files=$(ls | wc -l)
    let "to_delete = nb_files - 3"
    if [ $to_delete -gt 0 ]
    then
	ls | head -$to_delete | xargs rm
    else
	 echo "La purge des sauvegardes automatiques d7 dans $dir n'a pas pu être effectuée car il n'y avait pas assez de fichiers dans le dossier. Il faudrait vérifier que le script de sauvegarde s'exécute correctement" | mail -s "[dump assos] $dir a des soucis de sauvegardes de bdd" assos@centrale-marseille.fr;
    fi
    cd -
done
