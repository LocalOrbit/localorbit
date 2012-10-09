#!/bin/bash

if [ $# -eq 1 ]
then
	now=$(date +"%Y_%m_%d_%s")
	echo "backup is stored in /var/backups/$1_$now.images.zip"

	echo "stage 1: zipping images"
	zip -r "/var/backups/$1_$now.images.zip" "/var/www/$1/www/img/"
	
	echo "stage 2: scp to amazon"
	s3cmd put /var/backups/$1_$now.images.zip s3://ProductionImagesBackup/$1_$now.images.zip
	#scp /var/backups/$1_$now.zip guanaco.iqguys.com:/var/backups/localorbit/
	rm /var/backups/$1_$now.images.zip;
	
	echo "done."
	exit
else
	echo "Usage: backupimages.sh [production|qa|testing]"
fi

