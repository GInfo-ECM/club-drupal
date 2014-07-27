#!/bin/sh

. /home/assos/bin/scripts-config.sh

help="This script is intended to help you update drupal core. It fellows steps describe here: https://forge.centrale-marseille.fr/projects/clubdrupal/wiki/Utilisation_de_Drupal_multi-site#Mise-%C3%A0-jour-du-noyau-de-Drupal
Please do not launch in cron."

if ! tty -s ; then
    echo $help
    exit 1
fi

set -e # Exit immediatly if a command exits with a non zero value

# Backup transaltion
translations_backupdir=/var/tmp
cp $translations_fr $translations_backupdir

d7-all-dump-individual.sh manual

d7-all-update-contrib.sh

d7-all-drush.sh -y en update

d7-all-drush.sh -y upc drupal

d7-all-drush.sh updb

d7-all-drush.sh -y dis update

# Get the new subversion number:
# cd to $d7_dir, filter drush status to get the drupal version line,
# remove end line whitespaces, and get the 2 last caracters of the string.
drupal_version=$(cd $d7_dir && drush status | grep "Drupal version" | tr -d ' ' | tail -c 3)

# Try to download new translation. If it fails, restore the old one.
if ! curl -f http://ftp.drupal.org/files/translations/7.x/drupal/drupal-7.28.fr.po -o $translations_fr ; then
    cp $translations_backupdir/fr.po $translations_fr
fi

echo "Check for settings.php update."
echo "If everything is fine, run:"
echo -e "\tgit add -A drupal7 && git commit -m 'Udpate to 7.$drupal_version'"
