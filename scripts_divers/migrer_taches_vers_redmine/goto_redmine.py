import node_parser
import comments_parser
import submiters_parser
import url_parser
import httplib2
import json
import re

SUBMITERS = {'jenselme': 'auieeui'}
Headers = {'content-type': 'application/json', 'X-Redmine-API-Key': ''}
MY_API_KEY = '4a36554437feef722e82a206de1bc1c1250df973'
URL = 'http://localhost/redmine/issues'

def give_api_key(submiter):
    if submiter in SUBMITERS:
        return SUBMITERS[submiter]
    else:
        return  SUBMITERS['jenselme']

nids = url_parser.give_nids()
urls = url_parser.give_urls(nids)

h = httplib2.Http()

for post_url in urls:
    nid = nids[urls.index(post_url)]
    resp, page = h.request(post_url, 'GET')
    page = page.decode('utf-8')
    txt = page.read()
    #tout les scripts fonctionnent en lisant ligne à ligne le fichier.
    #la liste input permet de mimer ce comportement
    input = txt.split('\n')

    submiters = submiters_parser.parse_submiters(input)
    node = node_parser.parse_node(input)
    comments = comments_parser.parse_comment(input)

    #on a besoin de drupal_done_ratio pour fermer/rejeter une tache
    drupal_done_ratio = node['done_ratio']

    issue = {}
    issue['issue'] = node
    data = json.dumps(issue)

    Headers['X-Redmine-API-Key'] = give_api_key(submiters[0])

    resp, content = h.request(URL + '.json', 'POST', body=data, headers=Headers)

    iid = re.findall(r',"id":([0-9]*),', content.decode('utf-8'))[0]

    #on a besoin de l’url à laquelle on met les commentaires, pour changer le status
    put_url = ''
    for index, comment in enumerate(comments):
        submiter = submiters[index + 1]  #le premier est celui qui a soumis le node
        Headers['X-Redmine-API-Key'] = give_api_key(submiter)
        #si la personne n’a pas sa clé, on modifie le commentaire
        if not submiter in SUBMITERS:
            comment = "{} a dit que {}".format(submiter, comment)
        update = {}
        update['issue'] = {'notes': comment}
        data = json.dumps(update)
        put_url = URL + '/' + iid + '.json'
        h.request(put_url, 'PUT', body=data, headers=Headers)

    #Les taches sont crées avec le status nouveau peu importe ce qu’il y a dans le json
    #on modifie le status après coup
    update_status = {'issue': {'status_id': node['status_id']}}
    data = json.dumps(update_status)
    h.request(put_url, 'PUT', body=data, headers=Headers)