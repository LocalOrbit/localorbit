#!/bin/sh


log() {
    echo ""
    echo ""
    echo "============================================================================================="
    echo "$1"
    echo "============================================================================================="
}


switch_web() {
    log "update_web*****************************************"
	
	# turn on maintenance mode
    log "turn on maintenance mode"
	mv /var/www/qa/www/htaccess_maintenance /var/www/qa/www/.htaccess
    
    #switch svn to new code base
    cd /var/www/qa
#sudo svn switch svn+ssh://lo-svn/opt/localorbit/lo3/tags/$VERSION_NUMBER
#sudo svn update
    sudo svn info
    
    # echo version number into file
	echo $VERSION_NUMBER > /var/www/qa/www/version.php
	
	mysql --host=localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com --user=localorb_www --password=l0cal1sdab3st localorb_www_qa -e 'select * from migrations;'	
    log "RUN DATABASE UPDATES!!!"
}


live_web() {
    log "live_web*****************************************"
	
	mv /var/www/qa/www/.htaccess /var/www/qa/www/htaccess_maintenance
}
cd

if [ $# -lt 2 ]
then
	echo "USAGE:"
	echo "$0 [switch live] version"
else
	case "$1" in
		switch)
			VERSION_NUMBER=$2
			echo $VERSION_NUMBER
			switch_web
 		;;
		live)
			live_web
 		;;
		*)
			echo "USAGE:"
			echo "$0 switch version"
		;;	
	esac
fi