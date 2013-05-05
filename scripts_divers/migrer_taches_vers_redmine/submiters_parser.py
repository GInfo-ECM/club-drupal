from html.parser import HTMLParser

class LinksParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.recording = 0
        self.data = []

    def handle_starttag(self, tag, attributes):
        if tag != 'a':
            return
        if self.recording:
            self.recording += 1
            return
        for name, value in attributes:
            if name == 'class' and value == 'username':
                break
        else:
            return
        self.recording = 1

    def handle_endtag(self, tag):
        if tag == 'a' and self.recording:
            self.recording -= 1

    def handle_data(self, data):
        if self.recording:
            self.data.append(data)

def parse_submiters(input):
    p = LinksParser()

    output = ""

    for ligne in input:
        output += ligne
    p.feed(output)

    #le premier est celui qui a créé la tache et le dernier est potentiellement celui qui n’a pas encore posté de commentaires
    return p.data
