from html.parser import HTMLParser
import re

DONE_RATIO = {'À commencer': 0, 'Entamée': 20, 'Bien avancé': 80, 'Terminée (success)': 100, 'Fermée (won\'t fix)': 100}
PRIORITY = {'5 - Très basse': 3, '4 - Basse': 3, '3 - Moyenne': 4, '2 - Haute': 5, '1 - Très haute': 6}
STATUS = {'En cours': 2, 'Fermée': 5, 'Rejetée': 6, 'En pause': 7}

class LinksParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.recording = 0
        self.data = []

    def handle_starttag(self, tag, attributes):
        if tag != 'div':
            return
        if self.recording:
            self.recording += 1
            return
        for name, value in attributes:
            if name == 'class' and value == 'node-content':
                break
        else:
            return
        self.recording = 1

    def handle_endtag(self, tag):
        if tag == 'div' and self.recording:
            self.recording -= 1

    def handle_data(self, data):
        if self.recording:
            self.data.append(data)

def parse_tache(input):
    p = LinksParser()
    output = ""
    drupal_title = ''
    for ligne in input:
        if not drupal_title:
            drupal_title = re.findall(r'<title>(.*?)</title>', ligne)
        ligne = re.sub(r'<p( class="[a-z -]*")?( id="[a-z]*")?>', r'', ligne)
        ligne = re.sub(r'</p>', r'', ligne)
        ligne = re.sub(r'<h([1-9])( class="[a-z -]*")?( id="[a-z]*")?( rel="nofollow")?>\n?', r'\nh\1. ', ligne)
        ligne = re.sub(r'</h[1-9]>', r'\n', ligne)
        ligne = re.sub(r'^[ \t]+', '', ligne)
        ligne = re.sub(r'<br />', r'\n', ligne)
        ligne = re.sub(r'<li( class="[a-z -]*")?( id="[a-z]*")?>', r'', ligne)
        ligne = re.sub(r'(.*)</li>', r'# \1', ligne)
        ligne = re.sub(r'<ol( class="[a-z -]*")?( id="[a-z]*")?>', r'', ligne)
        ligne = re.sub(r'</ol>', r'', ligne)
        ligne = re.sub(r'<ul( class="[a-z -]*")?( id="[a-z]*")?>', r'', ligne)
        ligne = re.sub(r'</ul>', r'', ligne)
        ligne = re.sub(r'<pre( class="[a-z -]*")?( id="[a-z]*")?>', r'balise_pre', ligne)
        ligne = re.sub(r'</pre>', r'/balise_pre', ligne)
        ligne = re.sub(r'<code( class="[a-z -]*")?( id="[a-z]*")?>', r'balise_code', ligne)
        ligne = re.sub(r'</code>', r'/balise_code', ligne)
        ligne = re.sub(r'<em( class="[a-z -]*")?( id="[a-z]*")?>', r'_', ligne)
        ligne = re.sub(r'</em>', r'_', ligne)
        ligne = re.sub(r'<b( class="[a-z -]*")?( id="[a-z]*")?>', r'*', ligne)
        ligne = re.sub(r'</b>', r'*', ligne)
        ligne = re.sub(r'<strong( class="[a-z -]*")?( id="[a-z]*")?>', r'*', ligne)
        ligne = re.sub(r'</strong>', r'*', ligne)
# #        ligne = re.sub(r'<a href="(.*)"( class="[a-z -]*")?( id="[a-z]*")?>(.*)</a>', r'\1', ligne)
        ligne = re.sub(r'<a', r'', ligne)
#        ligne = re.sub(r'href="(.*)"', r'\1', ligne)
        ligne = re.sub(r'</a>', r'', ligne)

        output += ligne

    p.feed(output)
    list_node = list()
    for comment in p.data:
        comment = re.sub(r'^\n*', r'', comment)
        comment = re.sub(r'\n*$', r'', comment)
        comment = re.sub(r'^ *', r'', comment)
        comment = re.sub(r' *$', r'', comment)
        comment = re.sub(r'/balise_pre', r'</pre>', comment)
        comment = re.sub(r'balise_pre', r'<pre>', comment)
        comment = re.sub(r'/balise_code', r'</code> ', comment)
        comment = re.sub(r'balise_code', r'<code> ', comment)
        if comment:
            list_node.append(comment)

    i = 1
    drupal_respo = list()
    while "Avancement" not in list_node[i]:
        drupal_respo.append(list_node[i])
        i += 1

    i += 1
    drupal_done_ratio = list()
    while "Priorité" not in list_node[i]:
        drupal_done_ratio.append(list_node[i])
        i += 1

    #on supprime attente des anciens/cri et à tester (à ajouter à la main)
    for elt in drupal_done_ratio:
        if "tester" in elt or 'Attente' in elt:
            del elt

    #On se préocupe du status_id qui est dans la liste drupal_done_ratio
    drupal_status = ''
    for elt in drupal_done_ratio:
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

    #on vérifie que drupal_done_ratio n’est pas vide
    if not drupal_done_ratio:
        drupal_done_ratio = ['Entamée']

    i += 1
    drupal_priority = list_node[i]

    i += 1
    drupal_files = list()
    while "Version" not in list_node[i]:
        drupal_files.append(list_node[i])
        i += 1

    i += 1
    drupal_version = list_node[i]
    drupal_body = list_node[i + 1]

    tache = {}
    tache['project_id'] = 1
    tache['tracker_id'] = 2
    tache['subject'] = drupal_title[0]
    tache['description'] = drupal_body
    tache['priority_id'] = PRIORITY[drupal_priority]
    tache['done_ratio'] = DONE_RATIO[drupal_done_ratio[0]]
    tache['status_id'] = STATUS[drupal_status]
    if '7' in drupal_version:
        tache['custom_fields'] = [{"id":1, "value": "1"}]
    else:
        tache['custom_fields'] = [{"id":1, "value": "2"}]
        #print(drupal_files)
    return tache
