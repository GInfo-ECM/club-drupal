#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

if ! work_tree_clean ; then
    mail_unclean_work_tree "[git] WORK TREE UNCLEAN"
fi

git pull --rebase > /dev/null 2>&1
git push > /dev/null 2>&1
