#!/bin/sh

# Ce script est une automatisation de ce qui est détaillé ici :
 #https://forge.centrale-marseille.fr/projects/clubdrupal/wiki/Utilisation_de_Drupal_multi-site#Cr%C3%A9ation-du-site-drupal-7
# Ce script ne crée que des sites sur le sous domaine assos.


# Prend comme paramètre le nom du site
# On génère le mot de passe
# On se place dans le home de asso en début de script
# Les fichiers par défaut sont sur le bureau de assos
init_scripts.sh
init_scripts_site.sh $1


######## Exceptions
#On vérifie que le nom du site est bien passé en argument.
if [ -z $1 ]
then
    echo 'Le nom du site doit être donné en paramètre'
    echo 'creation_site_D7.sh NOM_SITE'
    exit 1
fi

#si le nom contient '-' on arrête le script car les instructions concernant la
#base de données ne supportent pas ce caractère.
if $(echo $1 | grep -)
then
	echo 'Le nom du site ne doit pas contenir le caractère -'
	exit 1
fi

#On vérifie que la longueur du nom du site est <= 16 caractères. Sinon mysql ne peut pas créer l’utilisateur
if [ $(echo $1 | wc -n) -le 16 ]
then
    echo 'Le nom du site ne peut exéder 16 caractères'
    exit 1
fi

###### Initialisation
cd $d7_dir
db_passwd=`ask_password_bdd $nom_serveurbdd $user_bdd`
site_passwd=`gen_password`
nom_site=$1


# Précautions
# - On teste si le dossier existe déjà, s’il n’existe pas, on s’arrête
# - On vérifie que la base de données n’existe pas

#Vérifie base de données
if mysql -h $db_server -u $db_user -e "USE $nom_site" -p$db_passwd 2>/dev/null
then
    echo "La base de donnée existe déjà"
    exit 1
fi


#On vérifie pour le dossier
if [ -d $d7_site_dir ]
then
    echo "Le dossier $site_rep existe déjà"
    exit 1
fi


###### Main
#on crée le dossier
mkdir $d7_site_dir

# on crée ce qu’il faut pour les sauvegardes
mkdir $d7_backup_dir/$site_name
date=$(date "+%Y-%m-%d-%Hh%Mm%Ss")
touch $d7_backup_dir/$site_name/date.sql
touch $d7_backup_dir/$site_name/date.sql
touch $d7_backup_dir/$site_name/date.sql

#mysql (besoin du mot de passe assos)
mysql -h $db_server -u $db_user -e "CREATE DATABASE $nom_site" -p$db_passwd

#la ligne suivante vient de http://www.siteduzero.com/tutoriel-3-613143-syntaxe-sql-et-premieres-commandes.html
#voir là-bas pour les explications
mysql -h $db_server -u $db_user -e "GRANT ALL PRIVILEGES ON $1.* TO '$site_name'@'%' IDENTIFIED BY '$site_passwd'" -p$db_passwd



#on veut modifer le nom de la base de donnée (%%DBNAME%%), le nom de l’utilisateur (%%DBUSER%%), son mot de passe (%%DBPASS%%) et base_url (%%nomdusite%%)
sed "s/\%\%DBUSER\%\%/$nom_site/ ; s/\%\%DBNAME\%\%/$nom_site/ ; s/\%\%DBPASS\%\%/$mdp_site/ ; s/\%\%nomsite\%\%/$nom_site/" < $d7_template_settings > $d7_site_settings

#on crée le lien symbolique (on doit se placer dans le bon répertoire !)
cd $d7_site_dir
cd ./../..
ln -s . $site_name

#On affiche le lien
echo "Suivez les instructions de http://assos.centrale-marseille.fr/$nom_site/install.php pour continuer."
echo "Pressez entrée une fois les actions effectuées"
read touche

#On appelle init_var.sh
cd $d7_site_dir
init_var.sh

#on met les bons droits unix
chmod -R 755 $d7_site_dir
chmod 400 $d7_site_settings

#On donne les dernières instructions
echo "Quelques dernières instructions :"
echo "- Conseiller à l'administrateur de ne pas laisser les inscriptions ouvertes à son site"
echo "- Donner à l'administrateur le lien des tutoriels écrits par le club Drupal "
echo "\n"
echo "Référencement du site"
echo "- créer un contenu de type \"Site\" sur la page du projet multiassos"
echo "- demander à l'administrateur du site de s’inscrire sur la liste de diffusion webmasters@listes.centrale-marseille.fr (l’inscription est automatique)"
