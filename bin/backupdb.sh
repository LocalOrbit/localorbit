#!/bin/bash

if [ $# -eq 1 ]
then
	now=$(date +"%Y_%m_%d_%s")
	echo "backup is stored in /var/backups/$1_$now.db.zip"

	echo "stage 1: dumping $1 db"
	mysqldump --user=localorb_www --password=l0cal1sdab3st localorb_www_$1 > /var/backups/$1_$now.sql;

	echo "stage 2: zipping"
	zip "/var/backups/$1_$now.db.zip" "/var/backups/$1_$now.sql"
	rm /var/backups/$1_$now.sql;
	
	echo "stage 3: scp to amazon"
	s3cmd put /var/backups/$1_$now.db.zip s3://ProductionDatabaseBackup/$1_$now.db.zip
	#scp /var/backups/$1_$now.zip guanaco.iqguys.com:/var/backups/localorbit/
	rm /var/backups/$1_$now.db.zip;

	echo "done."
	exit
else
	echo "Usage: backupdb.sh [production|qa|testing]"
fi

