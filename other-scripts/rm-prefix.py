#!/usr/bin/env python3

# This was created in order to delete the prefix of drupal database
# These prefix were useful when all sites were in the same database

import pymysql as mysql
import sys
import re

db = sys.argv[1]
prefix = sys.argv[2]
host = 'localhost'
passwd = 'tata'
user = 'root'
port = ''

db = mysql.connect(host=host, user=user, passwd=passwd, db=db, charset='utf8')
with db:
    cur = db.cursor()
    cur.execute('SHOW TABLES')
    tables = cur.fetchall()
    for table in tables:
        table = table[0]
        if re.match('^{}'.format(prefix), table):
            new_table = re.sub('^{}(.*)'.format(prefix), r'\1', table)
            cur.execute('DROP TABLE IF EXISTS {}'.format(new_table))
            cur.execute('RENAME TABLE {} TO {}'.format(table, new_table))
    db.commit()