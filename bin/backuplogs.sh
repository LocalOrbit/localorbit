#!/bin/bash

if [ $# -eq 1 ]
then
	now=$(date +"%Y_%m_%d_%s")
	echo "backup is stored in /var/backups/$1_$now.log.zip"
	mv /tmp/$1-default.log  /var/backups/$1-default.log
	mv /tmp/$1-error.log  /var/backups/$1-error.log
	mv /tmp/$1-sql.log /var/backups/$1-sql.log
	if [ -f /var/log/apache2/error-$1.log ]
		then
			mv /var/log/apache2/error-$1.log /var/backups/error-$1-apache.log
	fi
	if [ -f /var/log/apache2/error-$1.log ]
		then
			mv /var/log/apache2/access-$1.log /var/backups/access-$1-apache.log
	fi
	
	echo "stage 1: zipping logs"
	zip -r "/var/backups/$1_$now.log.zip" /var/backups/*.log;
	rm /var/backups/*.log;
	
	echo "stage 2: scp to amazon"
	s3cmd put /var/backups/$1_$now.log.zip s3://ProductionLogBackup/$1_$now.log.zip
	rm /var/backups/$1_$now.log.zip;
	
	echo "done."
	exit
else
	echo "Usage: backuplogs.sh [production|qa|testing]"
fi

