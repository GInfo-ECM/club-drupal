#!/usr/bin/env python3

# This script is intended to fix the cas_user table. Just give the database name.

import argparse
from getpass import getpass

def fix_cas(db, host, user, password, prefix, roles):
    import pymysql as mysql

    while not password:
        password = getpass('Please enter the password: ')
    password = password.strip()

    conn = mysql.connect(host=host, user=user, passwd=password, db=db, charset='utf8')
    with conn:
        cur = conn.cursor()

        # We format the name of the tables according to prefix
        tables = {'users': '{}users', 'users_roles': '{}users_roles',\
                  'role': '{}role', 'cas_user': '{}cas_user'}
        for key, elt in tables.items():
            tables[key] = elt.format(prefix)

        # We take into account the roles to modify
        for role in roles:
            i = roles.index(role)
            roles[i] = "'" + role + "'"
        format_dict = {'roles_to_modify': ', '.join(roles)}

        # We are ready to format queries
        format_dict.update(tables)

        select = """SELECT {users}.name, {users}.uid FROM {users}
        JOIN {users_roles} ON {users_roles}.uid = {users}.uid
        JOIN {role} ON {role}.rid = {users_roles}.rid
        WHERE {role}.name IN ({roles_to_modify}) AND {users}.uid NOT IN
        (SELECT uid FROM {cas_user})
        """.format(**format_dict)

        insert = """INSERT INTO {cas_user} (uid, cas_name)
        VALUES (%s, %s)
        """.format(**format_dict)

        cur.execute(select)
        rows = cur.fetchall()

        for name, uid in rows:
            cur.execute(insert, (uid, name))

        conn.commit()



###### Main

parser = argparse.ArgumentParser(description='Fill the cas_user table from the users table for a specific role or all roles. Requires pymysql to query the database.')
parser.add_argument('database', metavar='database', help='name of the database to fix')
parser.add_argument('--host', dest='host', default='localhost')
parser.add_argument('--user', '-u', dest='user', default='root')
parser.add_argument('--password', '--passwd', '-p', dest='password')
parser.add_argument('--prefix', dest='prefix', default='')
parser.add_argument('--roles', '-r', dest='roles', nargs='+', default=['authenticated user'])

args = parser.parse_args()
fix_cas(args.database, args.host, args.user, args.password, args.prefix, args.roles)
