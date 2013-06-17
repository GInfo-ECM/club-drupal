#!/bin/sh

#Ce script est une automatisation de ce qui est détaillé ici :
#https://forge.centrale-marseille.fr/projects/clubdrupal/wiki/Utilisation_de_Drupal_multi-site#Cr%C3%A9ation-du-site-drupal-7
#Ce script ne crée que des sites sur le sous domaine assos.


#fonction de demande de mot de passe (entree cachee)
# usage: pass=$(askpasswd "Tu me pretes ton mot de passe ?")
askpasswd() {
  echo $1 >&2
  echo -n ">" >&2
  stty_avant=$(stty -g)
  stty -echo
  read p
  stty $stty_avant
  echo "$p"
  unset p
}


#Prend comme paramètre le nom du site
#On génère le mot de passe
#on se place dans le home de asso en début de script
#les fichiers par défaut sont sur le bureau de assos

#On vérifie que le nom du site est bien passé en argument.
if [ -z $1 ]
then
    echo 'Le nom du site doit être donné en paramètre'
    echo 'creation_site_D7.sh NOM_SITE'
    exit 1
fi

#On vérifie que la longueur du nom du site est <= 16 caractères. Sinon mysql ne peut pas créer l’utilisateur
if [ $(echo $1 | wc -n) -le 16 ]
then
    echo 'Le nom du site ne peut exéder 16 caractères'
    exit 1
fi


vers_home="/users/guest/assos"
cd $vers_home

#On récupère le nom du site donné en paramètre
nom_site=$1

site_rep="$vers_home/htmltest/sites/assos.centrale-marseille.fr.$1"
site_settings="$site_rep/settings.php"

settings_default="settings-D7-bddinde-template.php"
template_settings="$vers_home/Desktop/$settings_default"

nom_serveurbdd="myassos.serv.int"
user_bdd="assos"

#on récupère le mot de passe, je ne prétends pas qu’il s’agit de la meilleure méthode loin de là.
#Pour ce faire, on va envoyer une requête mysql vide.
mdp_assos="pourquemysqldemandepas"

#requête mysql fantoche
#l’option -h permet de sélectionner le serveur
#l’option -e permet d’exécuter la commande mysql qui suit (on met le mdp après)
while ! mysql -h $nom_serveurbdd -u $user_bdd -p$mdp_assos -e "" 2>/dev/null;
do
    mdp_assos=$(askpasswd "Entrer le mot de passe la base de donnée MySQL :")
    echo ""
done


#on génère le mdp
#        *avec des caractères spéciaux*. On se protège du caractère / qui
#signifie que l’expression régulière de sed est finie (voir plus bas). On boucle
#tant que le mot de passe contient /
mdp_site='/'
taille_mdp=20
while echo "$mdp_site" | grep -Fq '/'
do
    mdp_site=`dd if=/dev/urandom count=1 | uuencode -m - | head -n 2 | tail -n 1 | cut -c-$taille_mdp`
done

#On ajoute des précaution :
# - On teste si le dossier existe déjà, s’il n’existe pas, on s’arrête
# - On vérifie que la base de données n’existe pas

#Vérifie base de donnée
if ! mysql -h $nom_serveurbdd -u $user_bdd -e "USE $nom_site" -p$mdp_assos 2>/dev/null
then
    #On vérifie pour le dossier
    if ! [ -d $site_rep ]
    then
	#on crée le dossier
	mkdir $site_rep

	#mysql (besoin du mot de passe assos)
	mysql -h $nom_serveurbdd -u $user_bdd -e "CREATE DATABASE $nom_site" -p$mdp_assos

#la ligne suivante vient de http://www.siteduzero.com/tutoriel-3-613143-syntaxe-sql-et-premieres-commandes.html
#voir là-bas pour les explications
	mysql -h $nom_serveurbdd -u $user_bdd -e "GRANT ALL PRIVILEGES ON $1.* TO '$nom_site'@'%' IDENTIFIED BY '$mdp_site'" -p$mdp_assos



#on veut modifer le nom de la base de donnée (%%DBNAME%%), le nom de l’utilisateur (%%DBUSER%%), son mot de passe (%%DBPASS%%) et base_url (%%nomdusite%%)
	sed "s/\%\%DBUSER\%\%/$nom_site/ ; s/\%\%DBNAME\%\%/$nom_site/ ; s/\%\%DBPASS\%\%/$mdp_site/ ; s/\%\%nomsite\%\%/$nom_site/" < $template_settings > $site_settings

	#on crée le lien symbolique (on doit se placer dans le bon répertoire !)
	cd $site_rep
	cd ./../..
	ln -s . $nom_site
	#on retourne dans home
	cd $vers_home

	#On affiche le lien
	echo "Suivez les instructions de http://assos.centrale-marseille.fr/$nom_site/install.php pour continuer."
	echo "Pressez entrée une fois les actions effectuées"
	read touche

	#On appelle init_var.sh
	cd $site_rep
	init_var.sh

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

	#On met les bons droits unix
	chmod -R 755 $site_rep
	chmod 400 $site_settings

	#On donne les dernières instructions
	echo "Quelques dernières instructions :"
	echo "- Conseiller à l'administrateur de ne pas laisser les inscriptions ouvertes à son site"
	echo "- Donner à l'administrateur le lien des tutoriels écrits par le club Drupal "
	echo "\n"
	echo "Référencement du site"
	echo "- créer un contenu de type \"Site\" sur la page du projet multiassos"
	echo "- demander à l'administrateur du site de s’inscrire sur la liste de diffusion webmasters@listes.centrale-marseille.fr (l’inscription est automatique)"

    else
	echo "Le dossier $site_rep existe déjà"
	exit 1
    fi
else
    echo "La base de donnée existe déjà"
    exit 1
fi
