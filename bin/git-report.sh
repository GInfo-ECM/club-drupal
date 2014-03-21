#!/bin/sh

. /home/assos/bin/scripts-config.sh
. /home/assos/bin/scripts-utils.sh

if ! `work_tree_clean` ; then
    mail_unclean_work_tree "[git] WORK TREE UNCLEAN"
fi

git_log=`git log -p --since="yesterday" --pretty=format:"########## %s ###########"`
if [ -n "$git_log" ] ; then
    echo "$git_log" | mail -s "[git] Report" $email_multi_assos
fi

git pull --rebase > /dev/null
git push > /dev/null
