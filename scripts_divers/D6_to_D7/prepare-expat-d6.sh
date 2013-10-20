#!/bin/bash

cd /var/www/expat

drush cc all

# We uninstall the good modules in drupal 6
modules2uninstall=(mapbox contemplate openlayers_ui openlayers_views openlayers flowplayer flowplayer3 wijering wijering4 swftools geotaxonomy views_export views_cloud content_profile_registration content_profile fivestar_comment)

for i in ${!modules2uninstall[*]} ; do
    drush -y dis ${modules2uninstall[$i]}
    drush -y pm-uninstall ${modules2uninstall[$i]}
done


cd /var/www/expatd7

# We install the good module in drupal 7
modules2install=(module_filter token addthis blog cas comment_notify imce lightbox2 masquerade pathauto ctools contact ckeditor views views_ui fivestar media)

for i in ${!modules2install[*]} ; do
    drush -n dl ${modules2install[$i]}
    drush -y en ${modules2install[$i]}
done

#modules2install_assos=(addthis lightbox2 votingapi fivestar)
