######## Dict of people who have an api-keys
#id: key
SUBMITERS = {'jenselme': 'b3ce5345b1444b66f05f6a143ffec6f401e8f17e', 'admin': 'a7630a1244be353424cc0f56a49657c3fa9dbcc6'}
MANAGER = 'admin' # Can post issues
#MANAGER = 'jenselme'


######## HTTP headers
Headers = {'content-type': 'application/json', 'X-Redmine-API-Key': ''}
Headers_GET = {'X-Redmine-API-Key': ''}


######## Base URL of where to post the issues
URL_ISSUES = 'http://debian/redmine/issues'
#URL_POST_ISSUES = 'https://forge.centrale-marseille.fr/issues'


######## Issues list in redmine of a give project
URL_ISSUES_JSON = 'http://debian/redmine/projects/test/issues.json'
#URL_ISSUES_JSON = 'https://forge.centrale-marseille.fr/projects/clubdrupal/issues.json'

######## Project URL
URL_PROJECT = 'http://debian/redmine/projects/test'
#URL_PROJECT = 'https://forge.centrale-marseille.fr/projects/clubdrupal'
URL_REDMINE = 'http://debian/redmine'
#URL_REDMINE = 'http://forge.centrale-marseille.fr'


######## Issues location in drupal (node id in a csv file to be parsed)
LIST_TODO = 'http://debian/portail/liste-tache'
LIST_TODO_CSV = 'http://debian/portail/liste_tache_csv'


######## Base url of drupal
BASE_URL = 'http://debian/portail'


######## Various id
PROJECT_ID = 1
#PROJECT_ID = 30
TRACKER_ID = 2
USER_ID = {'ftorregrosa': 45, 'Ismaeil ABOULJAMAL': 44, 'iabouljamal': 44,\
           'Nono LiNux': 47, 'nlehuby': 47, 'gfranchi': 78, 'assos': 78, '82': 78, 'dgeo': 22,\
           'Jean': 48,'jfeutry': 48, 'adeprey': 49,'jpennec': 46, 'gt': 42, 'jenselme': 43,
           '1': 44, '176': 43, '123': 48, '114': 49,\
           '99': 46, '97': 45, '20': 47, '16': 42, '9': 22}


######## Dict to translate drupal's fields into redmine ids
DONE_RATIO = {'En pause': 50, 'À commencer': 0, 'Entamée': 20, 'Bien avancée': 80, 'Terminée (success)': 100, 'Fermée (won\'t fix)': 100}
PRIORITY = {'5 - Très basse': 3, '4 - Basse': 3, '3 - Moyenne': 4, '2 - Haute': 5,\
            '1 - Très haute': 6, 'Très basse': 3, 'Basse': 3, 'Moyenne': 4,\
            'Haute': 5, 'Très haute':6, '0': 3, '1': 3, '2': 4, '3': 5, '4': 6}
STATUS = {'En cours': 2, 'Fermée': 5, 'Rejetée': 6, 'En pause': 7}
#NB: sur le portail, on a les équivalences suivantes
# For drupal_version_field : 17 : drupal6, 18 : drupal7
DRUPAL_VERSION = {'17': 2, '18': 1}


###### Other
REGEXP_NAME = 'http://debian/portail/content/t%C3%A2che/(.*)'
