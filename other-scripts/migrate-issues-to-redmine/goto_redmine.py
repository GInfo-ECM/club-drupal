#!/usr/bin/env python3

"""This script can migrate issues from drupal to redmine.

It is design be launched with the -i option: most variables you may need for
debugging are easily accessible from interpreter (like HTTP status codes).
We make some assertion based on HTTP status code. Here are the codet you may
wish to know:
- 200: OK
- 201: Created
- 404: Not found
- 403: Forbidden
- 500: Internal error
Redmine gives you more intel in its response. Read them!
Pandoc is required to convert html syntax to textile syntax
"""

import requests
import json
import sys
import datetime
import os #we need system() to call pandoc
import re

import constantes as cst

######## Global variables
REGEXP_FIND_IMG = re.compile('!/.*!')
REGEXP_NAME_IMG = re.compile('!.*/(.*)!')

######## Common functions

def handle_image(txt):
    "Images are not posted automatically. There are only few of them.\
    We just format the text with the correct textile syntax and when we post them,\
    we will add comment and node id into a file. They should be attached to the\
    correct issue afterwards"
    has_image = False
    # In textile, images are between !
    images = REGEXP_FIND_IMG.findall(txt)
    if images:
        has_image = True
        for image in images:
            img_name = REGEXP_NAME_IMG.sub(r'!\1!', image)
            txt = txt.replace(image, img_name)
    return txt, has_image

def html2textile(txt):
    "Convert a txt from html to textile using pandoc"
    # We remove line breaks and tabs, otherwise the conversion doesn't work properly
    txt.replace('\n', '')
    txt.replace('\t', '')
    # pandoc can only manipulates files
    with open('tmp.html', 'w') as f:
        f.write(txt)
    os.system('pandoc -f html tmp.html -t textile -o tmp.textile')
    with open('tmp.textile', 'r') as f:
        txt = f.read()
    # Cleaning temporary files
    os.remove('tmp.html')
    os.remove('tmp.textile')
    return handle_image(txt)

def egalise(string, length):
    "Make the length of string equals to length if shorter"
    if len(string) < length:
        return ' '*(length - len(string)) + string
    else:
        return string

def percentage(integer):
    "Converts integer into a string used to indicate the percentage of completion\
    of a command"
    string = str(integer)
    string = egalise(string, 3)
    string = 'Completion: ' + string + '%'
    return string + '\b'*len(string)

def print_progress(str):
    sys.stdout.write(str)
    sys.stdout.flush()

def format_date(timestamp):
    str_timestamp = float(timestamp)
    date = datetime.datetime.fromtimestamp(str_timestamp)
    return date.strftime('%Y-%m-%d %H:%M:%S')



######## Definition of classes


class Comment:
    """Represents a drupal comment
    """

    def __init__(self, cid, author, post_date, content, has_img):
        self._cid = cid # comment id in drupal
        self._author = author
        self._post_date = post_date
        self._content = content
        # json representation, to be posted in redmine
        self._update = {'issue': {'notes': self._content }}
        self._update_json = json.dumps(self._update)
        self._resp = None #will be used to store the put response
        self._has_img = has_img

    def post(self, url, headers, iid, post_nb):
        "Post the comment to url with headers (required for authentication)"
        self._resp = requests.put(url, headers=headers, data=self._update_json)
        assert self._resp.status_code == 200

        # We write iid,author_id,created_on in comments.csv
        with open('comments.csv', 'a', encoding='utf8') as comments_csv:
            comments_csv.write('{},{},{}\n'.\
                        format(iid, cst.USER_ID[self._author], self._post_date))
        with open('fix_url_comments.csv', 'a', encoding='utf8') as fix_url_csv:
            fix_url_csv.write('{},{},{}\n'.format(self._cid, iid, post_nb))

    @property
    def post_date(self):
        return self._post_date

    @property
    def resp(self):
        return self._resp

    @property
    def cid(self):
        return self._cid

    @property
    def has_img(self):
        return self._has_img



class Updates:
    """Represents all the comments of a task
    """

    def __init__(self, comments):
        self._comments = comments

    def sort(self):
        "Sort all the updates by date of creation"
        sorted_date = False
        while not sorted_date:
            sorted_date = True
            i = 0
            while i < len(self._comments) - 1:
                if self._comments[i].post_date > self._comments[i + 1].post_date:
                    self._comments[i], self._comments[i + 1] = self._comments[i + 1],\
                                                               self._comments[i]
                    sorted_date = False
                i += 1

    def __getitem__(self, index):
        return self._comments[index]

    def __len__(self):
        return len(self._comments)

    def __iter__(self):
        self.__i = -1
        return self

    def __next__(self):
        self.__i += 1
        if self.__i >= len(self._comments) or len(self._comments) == 0:
            raise StopIteration
        return self._comments[self.__i]



class Issue:
    """Represents a drupal issue
    """

    def __init__(self, nid, comments):
        self._nid = nid #node id
        self._iid = None #issue id, unknown until creation
        self._resp = None #will be used to store the response of requests.post
        self._comments = Updates(comments)
        self._comments.sort()
        self._issue = self.give_redmine_issue(nid) #the actual content, it's a dict

    def give_redmine_status_id(self, node):
        "Translate the drupal status field to an integer representing the\
        redmine status id"
        drupal_status = ''
        for elt in node['field_avancement']:
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
        if not drupal_status:
            drupal_status = 'En cours'
        return cst.STATUS[drupal_status]

    def give_redmine_issue(self, nid):
        "Uses the nid to find the node and converts its content to something\
        redmine can understand. Read examples for more intels"
        node_json = requests.get(cst.BASE_URL + '/node/{}.json'.format(nid)).text
        node = json.loads(node_json)
        issue = dict()
        issue['project_id'] = cst.PROJECT_ID
        issue['tracker_id'] = cst.TRACKER_ID
        issue['subject'] = node['title']
        issue['description'], self._has_img = html2textile(node['body']['value'])
        # We get the name of the node
        self._name = re.findall(cst.REGEXP_NAME, node['url'])[0]
        # field_prioritaecute can be empty. We then assume it is normal
        if node['field_prioritaecute']:
            issue['priority_id'] = cst.PRIORITY[node['field_prioritaecute']]
        else:
            issue['priority_id'] = cst.PRIORITY['3 - Moyenne']
        # field_avancement can be empty. We then assume it is to be started
        if node['field_avancement']:
            issue['done_ratio'] = cst.DONE_RATIO[node['field_avancement'][0]]
        else:
            issue['done_ratio'] = cst.DONE_RATIO['À commencer']
        # Status id = open, fix, closed…
        issue['status_id'] = self.give_redmine_status_id(node)
        issue['fixed_version_id'] = cst.DRUPAL_VERSION[node['taxonomy_vocabulary_8']['id']]
        issue['created'] = format_date(node['created'])
        issue['author_id'] = node['author']['id']
        # Do we have attached files?
        if node['field_fichier']:
            self._has_files = True
        else:
            self._has_files = False
        return issue

    def post(self, url, headers):
        "Post the comment to url with headers (required for authentication)"
        issue = {'issue': self._issue}
        data = json.dumps(issue)

        self._resp = requests.post(url, headers=headers, data=data)

        assert self._resp.status_code == 201

        resp_json = json.loads(self._resp.text)
        self._iid = resp_json['issue']['id']

        # We write iid,author_id,created_on in issues.csv
        with open('issues.csv', 'a', encoding='utf8') as issues_csv:
            author_id = self._issue['author_id']
            redmine_author_id = cst.USER_ID[author_id]
            created_on = self._issue['created']
            issues_csv.write('{},{},{}\n'.\
                             format(self._iid, redmine_author_id, created_on))
        with open('fix_url_issues.csv', 'a') as fix_url:
            fix_url.write('{},{},{}\n'.format(self._nid, self._name, self._iid))

        # We post comments
        nb_comments = len(self._comments)
        i = 0
        for comment in self._comments:
            i += 1
            put_url =  cst.URL_ISSUES + '/{}.json'.format(self._iid)
            comment.post(put_url, headers, self._iid, i)
            print_progress(percentage(i//nb_comments*100))

        # We take care of images and files
        self.handle_image()
        self.handle_files()

    def handle_files(self):
        if self._has_files:
            with open('has_files.txt', 'a', encoding='utf8') as has_files_file:
                has_files_file.write('{}\n'.format(self._nid))

    def handle_image(self):
        for comment in self._comments:
            self._has_img = comment.has_img or self._has_img
        if self._has_img:
            with open('has_img.txt', 'a', encoding='utf8') as has_img_file:
                has_img_file.write('{}\n'.format(self._nid))

    @property
    def resp(self):
        return self._resp

    @property
    def comments_resp(self):
        resps = dict()
        for comment in self._comments:
            resps[comment.cid] = comment.resp
        return resps



class Laundry:
    """Contains all issues and has methods to perform the migration

    Iteration of this object traverses all issues.
    You can access any issue with the container notation
    """

    def __init__(self, url, test=True):
        self._issues = self.give_issues(url, test)

    def give_issues(self, url, test):
        "Returns a list of all issues"
        issues = []
        r = requests.get(url)

        assert r.status_code == 200

        # 1st element is 'Nid', and last is ''
        nids = r.text.split('\r\n')[1:-1]
        # for test, we only use 3 issues (faster)
        if test:
            nids = nids[:3]
        self.nb_task = len(nids)
        i = 0
        for nid in nids:
            i += 1
            comments = self.give_comments(nid)
            print('Fetching issue no {} on {}'.format(i, self.nb_task))
            issues.append(Issue(nid, comments))
        return issues

    def give_comments(self, nid):
        "Returns the list of all comments of a node"
        cids, comments_json = self.give_comments_json(nid)
        comments = []
        i = 0
        nb_comments = len(comments_json)
        for comment_json in comments_json:
            author = comment_json['name']
            post_date = format_date(comment_json['created'])
            content, has_img = html2textile(comment_json['comment_body']['value'])
            comments.append(Comment(cids[comments_json.index(comment_json)], author, post_date, content, has_img))
            i += 1
            print_progress(percentage(i//nb_comments*100))
        return comments

    def give_comments_json(self, nid):
        "Get the raw json version of the drupal comment"
        cids = self.give_comments_ids(nid)
        comments = list()
        for cid in cids:
            comment = requests.get(cst.BASE_URL + '/comment/' + cid + '.json')
            comments.append(json.loads(comment.text))
        return cids, comments

    def give_comments_ids(self, nid):
        "Get the cid (comnments id) for a node"
        headers = cst.Headers_GET
        headers['X-Redmine-API-Key'] = cst.SUBMITERS[cst.MANAGER]
        r = requests.get(cst.BASE_URL + '/entity_json/node/{}'.format(nid), headers=headers)
        page_json = json.loads(r.text)
        comments_json = page_json['comments']
        #If the issue has no comment, comments_json is a list, not a dict
        if comments_json:
            comments = list(comments_json.keys())
            return comments
        else:
            return list()

    def __iter__(self):
        self.__i = -1
        return self

    def __next__(self):
        self.__i += 1
        if self.__i >= len(self._issues):
            raise StopIteration
        return self._issues[self.__i]

    def __getitem__(self, index):
        return self._issues[index]

    def __len__(self):
        return len(self._issues)



class Redmine:
    """Main class.

    Allows the interaction with the program
    You can access any issue with the container notation.
    """
    def __init__(self, test=True):
        self.reset()
        self._test = test

    def reset(self):
        "Go to initial stage. All attributes are set to None"
        self._laundry = None
        self._headers = None
        self._headers_get = None

    def init(self, issues_file='issues.csv', x_redmine_api_key=cst.SUBMITERS[cst.MANAGER]):
        "Initialize the attribute for post uses"
        self._headers = cst.Headers
        self._headers['X-Redmine-API-Key'] = x_redmine_api_key
        self._laundry = Laundry(cst.LIST_TODO_CSV, self._test)

    def post(self, post_url=cst.URL_ISSUES_JSON):
        "Post all issues"
        nb_issues = len(self._laundry)
        i = 0
        for issue in self._laundry:
            i += 1
            print('Posting issues {} on {}'.format(i, nb_issues))
            issue.post(post_url, self._headers)

    def sweep(self):
        "Clean the redmine project of all issues."
        print('You are about to delete all issues on your redmine project.')
        ok = input('Do you wish to continue? (yes/no): ')

        if ok == 'yes':
            # Get the right headers
            self._headers_get = cst.Headers_GET
            self._headers_get['X-Redmine-API-Key'] = cst.SUBMITERS[cst.MANAGER]
            # Redmine give at maximum 100 issues. We may need to do it many times
            pass_number = 1
            while True:
                r = requests.get(cst.URL_ISSUES_JSON + '?status_id=*&limit=100',\
                                 headers=cst.Headers_GET)

                assert r.status_code == 200

                if not json.loads(r.text)['issues']: # There are no more issues to sweep
                    break
                print('Pass {}'.format(pass_number))
                taches_json = json.loads(r.text)['issues']
                # Print a nice completion percentage
                sys.stdout.flush()
                compt = 0
                print_progress(percentage(compt//len(taches_json)*100))
                for tache in taches_json:
                    tid = tache['id']
                    r = requests.delete(cst.URL_REDMINE + '/issues/{}.json'.format(tid),\
                                        headers=cst.Headers_GET)
                    compt += 1
                    print_progress(percentage(int(compt/len(taches_json)*100)))
                sys.stdout.write("\n")
                pass_number += 1
        else:
            print('Wise decision')

    def __getitem__(self, index):
        if self._laundry:
            return self._laundry[index]
        else:
            raise IndexError('Index out of range')




######## Main program
if __name__ == "__main__":
    redmine = Redmine(test=False)
    redmine.init()
    redmine.post()
