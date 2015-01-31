<?php
/**
 * @file
 * Configuration file for Drupal's multi-site directory aliasing feature.
 *
 * This file allows you to define a set of aliases that map hostnames, ports, and
 * pathnames to configuration directories in the sites directory. These aliases
 * are loaded prior to scanning for directories, and they are exempt from the
 * normal discovery rules. See default.settings.php to view how Drupal discovers
 * the configuration directory when no alias is found.
 *
 * Aliases are useful on development servers, where the domain name may not be
 * the same as the domain of the live server. Since Drupal stores file paths in
 * the database (files, system table, etc.) this will ensure the paths are
 * correct when the site is deployed to a live server.
 *
 * To use this file, copy and rename it such that its path plus filename is
 * 'sites/sites.php'. If you don't need to use multi-site directory aliasing,
 * then you can safely ignore this file, and Drupal will ignore it too.
 *
 * Aliases are defined in an associative array named $sites. The array is
 * written in the format: '<port>.<domain>.<path>' => 'directory'. As an
 * example, to map http://www.drupal.org:8080/mysite/test to the configuration
 * directory sites/example.com, the array should be defined as:
 * @code
 * $sites = array(
 *   '8080.www.drupal.org.mysite.test' => 'example.com',
 * );
 * @endcode
 * The URL, http://www.drupal.org:8080/mysite/test/, could be a symbolic link or
 * an Apache Alias directive that points to the Drupal root containing
 * index.php. An alias could also be created for a subdomain. See the
 * @link http://drupal.org/documentation/install online Drupal installation guide @endlink
 * for more information on setting up domains, subdomains, and subdirectories.
 *
 * The following examples look for a site configuration in sites/example.com:
 * @code
 * URL: http://dev.drupal.org
 * $sites['dev.drupal.org'] = 'example.com';
 *
 * URL: http://localhost/example
 * $sites['localhost.example'] = 'example.com';
 *
 * URL: http://localhost:8080/example
 * $sites['8080.localhost.example'] = 'example.com';
 *
 * URL: http://www.drupal.org:8080/mysite/test/
 * $sites['8080.www.drupal.org.mysite.test'] = 'example.com';
 * @endcode
 *
 * @see default.settings.php
 * @see conf_path()
 * @see http://drupal.org/documentation/install/multi-site
 */
$sites['assos.centrale-marseille.fr.accueil'] = 'assos.centrale-marseille.fr.accueil';
$sites['forum.centrale-marseille.fr'] = 'assos.centrale-marseille.fr.agora';
$sites['assos.centrale-marseille.fr.annales'] = 'assos.centrale-marseille.fr.annales';
$sites['assos.centrale-marseille.fr.aoudad'] = 'assos.centrale-marseille.fr.aoudad';
$sites['assos.centrale-marseille.fr.apocaliste'] = 'assos.centrale-marseille.fr.apocaliste';
$sites['assos.centrale-marseille.fr.bda'] = 'assos.centrale-marseille.fr.bda';
$sites['assos.centrale-marseille.fr.bde'] = 'assos.centrale-marseille.fr.bde';
$sites['assos.centrale-marseille.fr.bds'] = 'assos.centrale-marseille.fr.bds';
$sites['assos.centrale-marseille.fr.cheer-up'] = 'assos.centrale-marseille.fr.cheer-up';
$sites['assos.centrale-marseille.fr.clubfinance'] = 'assos.centrale-marseille.fr.clubfinance';
$sites['assos.centrale-marseille.fr.clubrobot'] = 'assos.centrale-marseille.fr.clubrobot';
$sites['assos.centrale-marseille.fr.echangesphoceens'] = 'assos.centrale-marseille.fr.echangesphoceens';
$sites['assos.centrale-marseille.fr.election'] = 'assos.centrale-marseille.fr.election';
$sites['assos.centrale-marseille.fr.eluseleves'] = 'assos.centrale-marseille.fr.eluseleves';
$sites['assos.centrale-marseille.fr.eptest'] = 'assos.centrale-marseille.fr.eptest';
$sites['assos.centrale-marseille.fr.ercm'] = 'assos.centrale-marseille.fr.ercm';
$sites['fablab.centrale-marseille.fr'] = 'assos.centrale-marseille.fr.fablab';
$sites['www.forum-foceen.fr'] = 'assos.centrale-marseille.fr.forumentreprises';
$sites['assos.centrale-marseille.fr.ftorregrosa'] = 'assos.centrale-marseille.fr.ftorregrosa';
$sites['assos.centrale-marseille.fr.gala'] = 'assos.centrale-marseille.fr.gala';
$sites['assos.centrale-marseille.fr.ggaydier'] = 'assos.centrale-marseille.fr.ggaydier';
$sites['assos.centrale-marseille.fr.ginfo'] = 'assos.centrale-marseille.fr.ginfo';
$sites['assos.centrale-marseille.fr.icm'] = 'assos.centrale-marseille.fr.icm';
$sites['assos.centrale-marseille.fr.isf'] = 'assos.centrale-marseille.fr.isf';
$sites['assos.centrale-marseille.fr.jenselme'] = 'assos.centrale-marseille.fr.jenselme';
$sites['assos.centrale-marseille.fr.jenselmetest'] = 'assos.centrale-marseille.fr.jenselmetest';
$sites['assos.centrale-marseille.fr.jpennec'] = 'assos.centrale-marseille.fr.jpennec';
$sites['assos.centrale-marseille.fr.lessive'] = 'assos.centrale-marseille.fr.lessive';
$sites['assos.centrale-marseille.fr.mdv'] = 'assos.centrale-marseille.fr.mdv';
$sites['assos.centrale-marseille.fr.phytv'] = 'assos.centrale-marseille.fr.phytv';
$sites['tvp.centrale-marseille.fr'] = 'assos.centrale-marseille.fr.tvp';
$sites['assos.centrale-marseille.fr'] = 'default';
$sites['assos.centrale-marseille.fr.charlist'] = 'assos.centrale-marseille.fr.charlist';
$sites['assos.centrale-marseille.fr.ksi'] = 'assos.centrale-marseille.fr.ksi';
$sites['assos.centrale-marseille.fr.beret'] = 'assos.centrale-marseille.fr.beret';
$sites['assos.centrale-marseille.fr.msb'] = 'assos.centrale-marseille.fr.msb';
$sites['assos.centrale-marseille.fr.aeecm'] = 'assos.centrale-marseille.fr.aeecm';
$sites['assos.centrale-marseille.fr.septiluce'] = 'assos.centrale-marseille.fr.septiluce';
$sites['assos.centrale-marseille.fr.atrinhtest'] = 'assos.centrale-marseille.fr.atrinhtest';
