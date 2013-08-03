#!/bin/sh

#Ce script initialise toutes les variables utiles d’un site.
#Il prend le nom du site en paramètre
#Il a besoin des variables de init_scripts.sh

if [ -z "$web_dir" ] #test si $web_dir (variable de init_scripts.sh) est définie
then
    echo "Import de init_scripts.sh requit"
    exit 1
fi

site_name=$1 #plus explicite
d7_site_dir="$d7_site_dir/assos.centrale-marseille.fr.$nom_site"
d7_site_settings="$site_dir/settings.php"
