#!/usr/bin/env python3

import pymysql as mysql
import re

db = mysql.connect(host="localhost", user="root", passwd="tata", db="expatd7", charset='utf8')

with db:
    cur = db.cursor()
    # We fix the text format for comments and nodes
    update_text_format = "UPDATE {table} SET {format} = 'filtered_html' WHERE {format} = -1"
    cur.execute(update_text_format.format(table='field_data_body', format='body_format'))
    cur.execute(update_text_format.format(table='field_data_comment_body', format='comment_body_format'))

    ### We fix the images
    fetch_d6_infos = """
    SELECT node.title, files.filepath
    FROM node
    JOIN image ON node.nid = image.nid
    JOIN files ON files.fid = image.fid
    WHERE image.image_size =  '_original'"""

    # We prepare the infos from D6
    results = []
    rows = ()

    db_d6 = mysql.connect(host="localhost", user="root", passwd="tata", db="expat", charset="utf8")
    with db_d6:
        cur_d6 = db_d6.cursor()
        cur_d6.execute(fetch_d6_infos)
        rows = cur_d6.fetchall()

        for row in rows:
            results.append(list(row))

        for r in results:
            # filepath is sites/default/files/… instead of …
            r[1] = re.sub(r'sites/default/files/(.*)', r'\1', r[1])

    # To find the nid and fid in D7
    fetch_nid = """
    SELECT nid FROM node WHERE title = %s
    """
    fetch_fid = """
    SELECT fid FROM file_managed WHERE uri = %s
    """

    # We do the update
    update_file_usage = """INSERT INTO file_usage (fid, module, type, id, count)
        VALUES (%s, 'node', 'file', %s, 1)"""

    update_field_data_image = """
    INSERT INTO field_data_field_image
    (entity_type, bundle, deleted, entity_id, revision_id, language, delta, field_image_fid, field_image_alt, field_image_title, field_image_width, field_image_height)
    VALUES ('node', 'image_dans_la_galerie', 0, %s, %s, 'und', 0, %s, '', '', 275, 183)
    """

    for r in results:
        cur.execute(fetch_nid, (r[0]))
        nid = cur.fetchall()[0][0] # returns something like ((133L,),)

        cur.execute(fetch_fid, ('public://' + r[1]))
        fid = cur.fetchall()[0][0]

        cur.execute(update_file_usage, (fid, nid))
        cur.execute(update_field_data_image, (nid, nid, fid))


    ### We fix the taxonomy
    vid2termName_d6 = {3: 'Image Galleries', 4: 'Pays', 5: 'Tags', 6: 'Université partenaire'}
    vid2termName_d7 = {1: 'Tags', 2: 'Pays', 3: 'Université partenaire', 4: 'Image Galleries'}
    termName2vid_d7 = {value: key for key, value in vid2termName_d7.items()}
    vocabulary2table = {'Tags': 'field_data_field_tags', 'Pays': 'field_data_field_pays', 'Université partenaire': 'field_data_field_universite_partenaire',\
    'Image Galleries': 'field_data_field_image_galleries'}
    vocabulary2column = {'Tags': 'field_tags_tid', 'Pays': 'field_pays_tid', 'Université partenaire': 'field_universite_partenaire_tid',\
    'Image Galleries': 'field_image_galleries_tid'}

    # NB: profile are not migrated automatically
    fetch_d6_nodeTitle_termName = """
    SELECT node.title, term_data.name FROM node
    JOIN term_node ON node.nid = term_node.nid
    JOIN term_data ON term_node.tid = term_data.tid
    WHERE term_data.vid = %s AND type <> 'profile' ORDER BY node.nid
    """

    fetch_d7_tids = """
    SELECT name, tid FROM taxonomy_term_data
    """

    fetch_d7_nid_created = """
    SELECT nid, created FROM node WHERE title = %s
    """

    update_taxonomy_index = """
    INSERT INTO taxonomy_index (nid, tid, sticky, created) VALUES
    (%s, %s, 0, %s)
    """

    update_field_data_field = """
    INSERT INTO {}
    (entity_type, bundle, deleted, entity_id, revision_id, language, delta, {})
    VALUES
    ('node', 'image_dans_la_galerie', 0, %s, %s, 'und', %s, %s)
    """

    # We fetch node titles and taxonomy term name for each vocabulary in drupal 6
    nodeTitle_termName = {}
    db_d6 = mysql.connect(host="localhost", user="root", passwd="tata", db="expat", charset="utf8")
    with db_d6:
        cur_d6 = db_d6.cursor()
        for vid in vid2termName_d6.keys():
            cur_d6.execute(fetch_d6_nodeTitle_termName, (vid))
            vocabulary = vid2termName_d6[vid]
            nodeTitle_termName[vocabulary] = cur_d6.fetchall()


    # We fetch tids for each term in drupal 7
    termName2tid = {}
    cur.execute(fetch_d7_tids)
    rows = cur.fetchall()
    for row in rows:
        termName2tid[row[0]] = row[1]

    # We perform the update
    delta, previous_title = 0, '' # We need this for multiple term taxonomy
    for vocabulary, t in nodeTitle_termName.items():
        for content in t:
            title, term_name = content
            cur.execute(fetch_d7_nid_created, (title))
            rows = cur.fetchall()
            nid, created = rows[0]
            tid = termName2tid[term_name]
            # We take into account the value of delta
            if previous_title == title:
                delta += 1
            else:
                delta = 0
                previous_title = title
            cur.execute(update_taxonomy_index,\
                        (nid, tid, created))
            cur.execute(update_field_data_field.\
                        format(vocabulary2table[vocabulary],\
                               vocabulary2column[vocabulary]),
                         (nid, nid, delta, tid))
    db.commit()
