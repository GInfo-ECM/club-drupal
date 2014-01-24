#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh
. /users/guest/assos/bin/scripts-utils.sh

if ! `work_tree_clean` ; then
    mail_unclean_work_tree "[git] WORK TREE UNCLEAN"
fi

git_log=`git log -p --since=yesterday -n 1 --pretty=format:"########         %s       ########%nDate: %ai%nby %cn %n"`
if [ -n "$git_log" ] ; then
    echo $git_log | mail -s "[git] Report" $email_multi_assos
fi

git pull --rebase > /dev/null
git push > /dev/null
