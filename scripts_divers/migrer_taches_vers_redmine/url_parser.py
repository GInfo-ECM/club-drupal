#!/usr/share/env python3

from html.parser import HTMLParser
import httplib2


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

def give_nids(url):
    p = LinksParser()
    h = httplib2.Http()

    resp, content = h.request(url, 'GET')
    text = content.decode('utf-8')

    p.feed(text)
    return p.data

def give_json_urls(url, base_url):
    nids = give_nids(url)
    tache_urls = []
    for nid in nids:
        tache_urls.append(base_url + '/node/' + nid + '.json')
    return nids, tache_urls