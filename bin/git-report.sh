#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

if ! `check_if_work_tree_clean` ; then
    mail_unclean_work_tree "[git] WORK TREE UNCLEAN"
fi

git_log=`git log -p --after=yesterday`
if [ -n "$git_log" ] ; then
    echo $git_log | mail -s "[git] Report"
fi

git pull --rebase
git push
