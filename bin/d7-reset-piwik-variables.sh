#!/bin/sh

###### Common to all sites
drush -yq en piwik
drush -yq vset piwik_url_http "http://piwik.centrale-marseille.fr/"
drush -yq vset piwik_url_https "https://piwik.centrale-marseille.fr/"
# Piwik cache.
drush -yq vset piwik_cache 1
drush -yq vset piwik_visibility_roles "1"
# Piwik is enable for everyone except the administrator
drush -yq vset --format=json piwik_roles '[3]'
drush -yq vset piwik_page_title_hierarchy 1
# Activate local search.
drush -yq vset piwik_site_search 1

##### Specific
# Note: you can read the piwik site id from the url in piwik
case $1 in
    accueil)
    piwik_id=286
    ;;
    agora)
    piwik_id=116
    ;;
    bda)
	piwik_id=273
	;;
    bde)
	piwik_id=274
	;;
    bds)
	piwik_id=275
	;;
    cac13)
	piwik_id=276
	;;
    cheer-up)
	piwik_id=277
	;;
    clubfinance)
	piwik_id=278
	;;
    clubrobot)
	piwik_id=279
	;;
    echangesphoceens)
	piwik_id=280
	;;
    eluseleves)
	piwik_id=281
	;;
    ercm)
	piwik_id=282
	;;
	fablab)
    piwik_id=151
    ;;
    forumentreprises)
    piwik_id=270
    ;;
    ginfo)
	piwik_id=283
	;;
    icm)
	piwik_id=284
	;;
    isf)
	piwik_id=285
	;;
    ksi)
	piwik_id=209
	;;
	mdv)
    piwik_id=99
    ;;
    tvp)
    piwik_id=110
    ;;
    *)
	piwik_id=287
	;;
esac

# Default is an exception and cannot be treated in the case
if echo $1 | grep default ; then
    piwik_id=101
fi

drush -yq vset piwik_site_id $piwik_id
