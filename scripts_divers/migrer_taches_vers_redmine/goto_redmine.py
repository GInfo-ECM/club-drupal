"""
Pandoc est requis pour convertir le html en textile !
"""

import url_parser  #permet de connaître les id des taches
import urllib.request
import httplib2
import json
import re
import os

SUBMITERS = {'jenselme': '4a36554437feef722e82a206de1bc1c1250df973'}
Headers = {'content-type': 'application/json', 'X-Redmine-API-Key': ''}
URL = 'http://localhost/redmine/issues'
LIST_TODO = 'http://localhost/portail/liste-tache'
BASE_URL = 'http://localhost/portail'
PROJECT_ID = 1
TRACKER_ID = 2
DONE_RATIO = {'À commencer': 0, 'Entamée': 20, 'Bien avancé': 80, 'Terminée (success)': 100, 'Fermée (won\'t fix)': 100}
PRIORITY = {'5 - Très basse': 3, '4 - Basse': 3, '3 - Moyenne': 4, '2 - Haute': 5, '1 - Très haute': 6,\
'0': 3, '1': 3, '2': 4, '3': 5, '4': 6}
STATUS = {'En cours': 2, 'Fermée': 5, 'Rejetée': 6, 'En pause': 7}
DRUPAL_VERSION = {'17': [{"id":1, "value": "1"}], '18': [{"id":1, "value": "2"}]}

def give_api_key(submiter):
    if submiter in SUBMITERS:
        return SUBMITERS[submiter]
    else:
        return  SUBMITERS['jenselme']


def give_comments_ids(nid):
    page = urllib.request.urlopen(BASE_URL + 'entity_json/node/' + nid)
    page_json = json.load(page)
    return list(page_json['comments'].keys())


def give_comments(cids):
    comments = list()
    for cid in cids:
        comment = urllib.request.urlopen(BASE_URL + '/comment/' + cid + '.json').read()
        comments.append(json.load(comment))
    return comments


def format(txt):
    txt.replace('\n', '')
    txt.replace('\t', '')
    with open('tmp.html', 'w') as f:
        f.write(txt)
    os.system('pandoc -f html tmp.html -t textile -o tmp.textile')
    with open('tmp.textile', 'r') as f:
        txt = f.read()
    return txt


def give_redmine_status_id(tache):
    drupal_status = ''
    for elt in tache['field_avancement']:
        if "Terminée" in elt:
            drupal_status = 'Fermée'
            break
        elif "Fermée" in elt:
            drupal_status = 'Rejetée'
            break
        elif "pause" in elt:
            drupal_status = 'En pause'
            del elt
            break
    return STATUS[drupal_status]


def give_redmine_issue(tache):
    issue = dict()
    issue['project_id'] = PROJECT_ID
    issue['tracker_id'] = TRACKER_ID
    issue['subject'] = tache['title']
    issue['description'] = format(tache['body']['value'])
    issue['priority_id'] = PRIORITY[tache['field_prioritaecute']]
    issue['done_ratio'] = DONE_RATIO[tache['field_avancement']]
    issue['status_id'] = give_redmine_status_id(tache)
    tache['custom_fields'] = DRUPAL_VERSION[tache['taxonomy_term_8']]


nids, urls = url_parser.give_json_urls(LIST_TODO, BASE_URL)

h = httplib2.Http()

for post_url in urls:
    nid = nids[urls.index(post_url)]
    tache_json = urllib.request.urlopen(post_url)
    tache_drupal = json.load(tache_json)

    cids = give_comments_ids(nid)
    comments_drupal = give_comments(cids)

    issue = {}
    issue['issue'] = give_redmine_issue(tache_drupal)
    data = json.dumps(issue)

    Headers['X-Redmine-API-Key'] = SUBMITERS['jenselme']

    resp, content = h.request(URL + '.json', 'POST', body=data, headers=Headers)

    #on récupère l’issue id pour savoir où poster les commentaires
    iid = re.findall(r',"id":([0-9]*),', content.decode('utf-8'))[0]

    #on a besoin de l’url à laquelle on met les commentaires, pour changer le status
    put_url = ''
    for index, comment in enumerate(comments_drupal):
        submiter = comment['name']  #le premier est celui qui a soumis le node
        Headers['X-Redmine-API-Key'] = give_api_key(submiter)
        #si la personne n’a pas sa clé, on modifie le commentaire
        comment_body = format(comment['comment_body']['value'])
        if not submiter in SUBMITERS:
            comment_body = "{} a dit que : {}".format(submiter, comment_body)
        update = {}
        update['issue'] = {'notes': comment_body}
        data = json.dumps(update)
        put_url = URL + '/' + iid + '.json'
        h.request(put_url, 'PUT', body=data, headers=Headers)

    #Les taches sont crées avec le status nouveau peu importe ce qu’il y a dans le json
    #on modifie le status après coup
    update_status = {'issue': {'status_id': issue['issue']['status_id']}}
    data = json.dumps(update_status)
    h.request(put_url, 'PUT', body=data, headers=Headers)
