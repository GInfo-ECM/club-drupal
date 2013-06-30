#!/usr/env python3

'''Ce script supprime TOUTES les tâches redmines du projet indiqué. À utiliser avec prudence.
'''

import requests #pour faire des requêtes http
import json
import sys

import constantes as const

print('Ce script supprime TOUTES les tâches redmines du projet indiqué. À utiliser avec prudence.')
ok = input('Continuer ? (oui/non) : ')

if ok == 'oui':
    const.Headers_GET['X-Redmine-API-Key'] = const.SUBMITERS[const.MANAGER]
    r = requests.get(const.URL_ISSUES_JSON + '?status_id=*&limit=100', headers=const.Headers_GET)

    taches_json = json.loads(r.text)['issues']

    sys.stdout.write('Pourcentage de complétion : 00%\b\b\b')
    sys.stdout.flush()
    compt = 0
    for tache in taches_json:
        tid = tache['id']
        r = requests.delete(const.URL_REDMINE + '/issues/{}.json'.format(tid), headers=const.Headers_GET)

        #on affiche le pourcentage de complétion
        compt += 1
        pourcentage = compt/len(taches_json)*100
        sys.stdout.write(str(pourcentage) + '%\b\b\b')
        sys.stdout.flush()
else:
    print('Sage décision')
