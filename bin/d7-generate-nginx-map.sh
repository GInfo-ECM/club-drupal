#!/bin/sh

. /home/assos/bin/scripts-config.sh

help=<<EOF
Generate nginx map from Drupal's sites.php

The left part of the map is $http_host$uri.
The right part is $subdir.
EOF

# Only for sites with url like assos.centrale-marseille.fr/subsite (other sites don't need to be in the map)
cut -d"'" -f2,4 "${sites_php}" |\
 grep '^assos\.centrale-marseille\.fr\.' |\
 # In reverse order.
 sort -r |\
 # Remove the ' at the end of the line.
 sed "s/'/ /" |\
 # Put slashes where they are needed (beware of tabs).
 sed 's/ assos.centrale-marseille.fr\./	/; s/assos.centrale-marseille.fr\./assos.centrale-marseille.fr\//; s/	/\/\.\*\$	\//; s/$/;/' >> "${d7_nginx_map_content}"
