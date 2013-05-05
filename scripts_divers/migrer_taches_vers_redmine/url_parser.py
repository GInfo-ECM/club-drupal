#!/usr/share/env python3

from html.parser import HTMLParser

SITE_URL = 'http://assos.centrale-marseille.fr'

class LinksParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.recording = 0
        self.data = []

    def handle_starttag(self, tag, attributes):
        if tag != 'span':
            return
        if self.recording:
            self.recording += 1
            return
        for name, value in attributes:
            if name == 'class' and value == 'parse_me':
                break
        else:
            return
        self.recording = 1

    def handle_endtag(self, tag):
        if tag == 'span' and self.recording:
            self.recording -= 1

    def handle_data(self, data):
        if self.recording:
            self.data.append(data)

def give_nids():
    p = LinksParser()

    with open('tache.html', 'r') as input:
        p.feed(input.read())
    return p.data

def give_urls(nids):
    tache_urls = []
    for nid in nids:
        tache_urls.append(SITE_URL + '/node/' + nid)
    return tache_urls