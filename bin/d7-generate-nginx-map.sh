#!/bin/sh

usage() {
    help=<<EOF
Generate nginx map from Drupal's sites.php.

No option required.

The left part of the map is $http_host$uri.
The right part is $subdir.
EOF
    echo -e "${help}"
}
. /home/assos/bin/print-help-if-required.sh


. /home/assos/bin/scripts-config.sh

# Only for sites with url like assos.centrale-marseille.fr/subsite (other sites don't need to be in the map)
cut -d"'" -f2,4 "${sites_php}" |\
 grep '^assos\.centrale-marseille\.fr\.' |\
 # In reverse order.
 sort -r |\
 # Remove the ' at the end of the line.
 sed "s/'/ /" |\
 # Put slashes where they are needed (beware of tabs).
 sed 's/ assos.centrale-marseille.fr\./	/; s/assos.centrale-marseille.fr\./~*^assos.centrale-marseille.fr\//; s/	/\/\.\*\$	\//; s/$/;/' \
 > "${d7_nginx_map_content}"
