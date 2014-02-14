#!/usr/bin/env python3

# In the expat website, when we try to migarte it, the images not found
# and the only solution we found is to use this script to patch its database
# and so repair the links

import pymysql as mysql
import re

db = mysql.connect(host="localhost", user="root", passwd="tata", db="expat", charset='utf8')

with db:
    cur = db.cursor()


    ## Update user's pictures
    sql_select = """
    SELECT uid, picture FROM users
    """

    sql_update = """
    UPDATE users SET picture = %s WHERE uid = %s
    """

    cur.execute(sql_select)
    rows = cur.fetchall()
    for uid, picture in rows:
        picture = re.sub(r'sites/assos.centrale-marseille.fr.expat/files/(.*)', r'\1', picture)
        cur.execute(sql_update, (picture, uid))


    ## Update other files
    sql_select = """
    SELECT fid, filepath FROM files
    """

    sql_update = """
    UPDATE files SET filepath = %s WHERE fid = %s
    """

    cur.execute(sql_select)
    rows = cur.fetchall()
    for fid, file_path in rows:
        file_path = re.sub(r'sites/assos.centrale-marseille.fr.expat/files/(.*)', r'\1', file_path)
        cur.execute(sql_update, (file_path, fid))

    db.commit()