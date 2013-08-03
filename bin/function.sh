#!/bin/sh

#Ce script doit contenir toutes les fonctions utiles aux scripts afin de pouvoir les réutiliser facilement.

#permet de demander un mot de passe sans l’afficher
#NB : read -s ne fonctionne pas en sh
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

ask_password_bdd() {
    #on récupère le mot de passe de la bdd, je ne prétends pas qu’il s’agit de la meilleure méthode loin de là.
    #prend le nom du serveur et le nom d’utilisateur comme argument.
    # Pour ce faire, on va envoyer une requête mysql vide.
    local db_passwd="pourquemysqldemandepas"
    #requête mysql fantoche
    #l’option -h permet de sélectionner le serveur
    #l’option -e permet d’exécuter la commande mysql qui suit (on met le mdp après)
    while ! mysql -h $1 -u $2 -p$db_passwd -e "" 2>/dev/null;
    do
	db_passwd=$(askpasswd "Entrer le mot de passe la base de donnée MySQL :")
	echo ""
    done
}

gen_password(){
    #on génère le mdp
    #        *avec des caractères spéciaux*. On se protège du caractère / qui
    #signifie que l’expression régulière de sed est finie (voir plus bas). On boucle
    #tant que le mot de passe contient /
    local site_passwd='/'
    local passwd_size=20
    while echo "$site_passwd" | grep -Fq '/'
    do
	site_passwd=`dd if=/dev/urandom count=1 | uuencode -m - | head -n 2 | tail -n 1 | cut -c-$passwd_size`
    done

    echo $site_passwd
}


d7_give_nb_sites(){
    # Return the number of drupal 7 sites
    find $d7_sites_dir -type d ! -name all -maxdepth 1 | wc -l
}
