#!/usr/bin/python3

"""Ce script permet de modifier un fichier settings.php d’un site. Il prend le chemin du settings en paramètre.
"""

import re
import sys
import argparse
import os

def modify_settings(args):
    settings_path = args.settings
    settings_new_path = settings_path + '.new'

    regexp = "'{}' => '(.*)'"

    with open(settings_path, 'r') as settings:
        with open(settings_new_path, 'w') as settings_new:
            for ligne in settings:
                ligne = re.sub(regexp.format('password'),\
                               "'password' => '{}'".format(args.password), ligne)
                if args.database:
                    ligne = re.sub(regexp.format('database'),\
                               "'database' => '{}'".format(args.database), ligne)
                ligne = re.sub(regexp.format('username'),\
                               "'username' => '{}'".format(args.user), ligne)
                ligne = re.sub(regexp.format('host'),\
                               "'host' => '{}'".format(args.host), ligne)
                if args.port:
                    ligne = re.sub(regexp.format('port'),\
                               "'port' => '{}'".format(args.port), ligne)
                if args.prefix:
                    ligne = re.sub(regexp.format('prefix'),\
                               "'prefix' => '{}'".format(args.prefix), ligne)
                if args.baseurl:
                    ligne = re.sub("\$base_url = (.*)",\
                               "$base_url = '{}';  // NO trailing slash!".format(args.baseurl), ligne)
                settings_new.write(ligne)
            os.chmod(settings_path, 700)
            os.remove(settings_path)
            os.rename(settings_new_path, settings_path)
            os.chmod(settings_path, 600)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('settings', metavar='settings', help='The path to the settings.')
    parser.add_argument('--user', '-u', dest='user', default='root', help='Database user')
    parser.add_argument('--password', '-p', dest='password', default='', help='Database password')
    parser.add_argument('--database', dest='database', help='New database name')
    parser.add_argument('--host', dest='host', default='localhost', help='The new host of the database.')
    parser.add_argument('--prefix', dest='prefix', help='The prefix for the database.')
    parser.add_argument('--port', dest='port', help='The database port.')
    parser.add_argument('--baseurl', dest='baseurl', help='The new base url')
    args = parser.parse_args()
    modify_settings(args)
