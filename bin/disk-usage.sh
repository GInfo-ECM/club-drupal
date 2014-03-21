#!/bin/sh

. /home/assos/bin/scripts-config.sh

echo -e "*Quotas: 9.1 GB*\n"

echo "Assos:"
du -hcs $dir_multi_assos | grep total
echo -e "\n"

echo "D7:"
cd $d7_dir_sites
du -h -d 1
echo -e "\n"

echo "Logs:"
du -hcs $dir_log | grep total
echo -e "\n"

echo "Backups:"
cd $dir_backup
du -h -d 2
