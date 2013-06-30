#Dictionnaire des gens dont on a la clé API
#id: clé
SUBMITERS = {'jenselme': '', 'admin': 'a7630a1244be353424cc0f56a49657c3fa9dbcc6'}
MANAGER_TEST = 'admin'
MANAGER = 'jenselme'

#les entêtes des requêtes http
Headers = {'content-type': 'application/json', 'X-Redmine-API-Key': ''}
Headers_GET = {'X-Redmine-API-Key': ''}

#là où on poste les tâches
URL_POST_ISSUES = 'https://forge.centrale-marseille.fr/issues'
#La liste des tâches
URL_ISSUES_JSON_TEST = 'http://localhost/redmine/projects/test/issues.json'
URL_ISSUES_JSON = 'https://forge.centrale-marseille.fr/projects/clubdrupal/issues.json'
#l’url du projet
URL_PROJECT_TEST = 'http://localhost/redmine/projects/test'
URL_PROJECT = 'https://forge.centrale-marseille.fr/projects/clubdrupal'
URL_REDMINE_TEST = 'http://localhost/redmine'
URL_REDMINE = 'http://forge.centrale-marseille.fr'

#là où sont les tâches
LIST_TODO = 'http://localhost/portail/liste-tache'

#url de base de l’emplacement du contenu
BASE_URL = 'http://localhost/portail'
PROJECT_ID = 30
TRACKER_ID = 2


########## dictionnaires de correspondance
DONE_RATIO = {'En pause': 50, 'À commencer': 0, 'Entamée': 20, 'Bien avancée': 80, 'Terminée (success)': 100, 'Fermée (won\'t fix)': 100}
PRIORITY = {'5 - Très basse': 3, '4 - Basse': 3, '3 - Moyenne': 4, '2 - Haute': 5,\
            '1 - Très haute': 6, 'Très basse': 3, 'Basse': 3, 'Moyenne': 4,\
            'Haute': 5, 'Très haute':6, '0': 3, '1': 3, '2': 4, '3': 5, '4': 6}
STATUS = {'En cours': 2, 'Fermée': 5, 'Rejetée': 6, 'En pause': 7}
#NB sur le portail, on a les équivalences suivantes
#pour le champ version de drupal : 17 : drupal6, 18 : drupal7
DRUPAL_VERSION = {'17': 2, '18': 1}
