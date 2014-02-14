#!/bin/bash

# This scripts generates site aliases for our install.

aliases_drushrc_php='aliases.drushrc.php'

echo '<?php' > $aliases_drushrc_php

# Generate @d7
echo "\$aliases['d7'] = array(
    'site-list' => array(" >> $aliases_drushrc_php
for dir in `find ../htmltest/sites/ -maxdepth 1 -type d ! -name all | sort` ; do
    site_name=`echo $dir | tr '.' '\n' | tail -n 1`
    echo "        'assos.centrale-marseille.fr/$site_name'," >> $aliases_drushrc_php
done
echo '    ),' >> $aliases_drushrc_php
echo "    'root' => '/users/guest/assos/htmltest/'," >> $aliases_drushrc_php
echo ');' >> $aliases_drushrc_php

# Generate aliases for each site
for dir in `find ../htmltest/sites/ -maxdepth 1 -type d ! -name all | sort` ; do
    site_name=`echo $dir | tr '.' '\n' | tail -n 1`
    echo "\$aliases['$site_name'] = array('uri' => 'assos.centrale-marseille.fr/$site_name', 'root' => '/users/guest/assos/htmltest/', );" >> $aliases_drushrc_php
done
