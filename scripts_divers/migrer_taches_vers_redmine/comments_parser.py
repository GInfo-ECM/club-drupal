from html.parser import HTMLParser
import re

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
            if name == 'class' and value == 'comment-content':
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


def parse_comment(input):
    p = LinksParser()

    output = ""
    for ligne in input:
        ligne = re.sub(r'<p( class="[a-z -]*")?( id="[a-z]*")?>', r'', ligne)
#        ligne = re.sub(r'<p(.*)>', r'', ligne)
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
#        ligne = re.sub(r'<a href="(.*)"( class="[a-z -]*")?( id="[a-z]*")?>(.*)</a>', r'\1', ligne)
        ligne = re.sub(r'<a', r'', ligne)
        ligne = re.sub(r'href="(.*)"', r'\1', ligne)
        ligne = re.sub(r'</a>', r'', ligne)
        output += ligne
        a = open("k", 'w')
        a.write(output)

    p.feed(output)

    list_comments = list()
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
            list_comments.append(comment)
    return list_comments
