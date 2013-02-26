#!/bin/bash
TRUNK_PATH=$1
MYSQL_PASSWORD=$2
MYSQL_PASSWORD_ARG=-$2

if [ -z "$2" ]; then
   MYSQL_PASSWORD_ARG=""
fi

rm -Rf $TRUNK_PATH/www/img/products/raws/*.dat
rm -Rf $TRUNK_PATH/www/img/products/cache/*.dat

rm $TRUNK_PATH/www/img/newsletters/*.jpg
rm $TRUNK_PATH/www/img/newsletters/*.png
rm $TRUNK_PATH/www/img/newsletters/*.gif

rm $TRUNK_PATH/www/img/organizations/*.jpg
rm $TRUNK_PATH/www/img/organizations/*.png
rm $TRUNK_PATH/www/img/organizations/*.gif
rm $TRUNK_PATH/www/img/organizations/cached/*.jpg

rm $TRUNK_PATH/www/img/weeklyspec/*.jpg
rm $TRUNK_PATH/www/img/weeklyspec/*.png
rm $TRUNK_PATH/www/img/weeklyspec/*.gif

scp -r 'lo-web1:/var/www/production/www/img/organizations/*.jpg' $TRUNK_PATH/www/img/organizations
scp -r 'lo-web1:/var/www/production/www/img/organizations/*.gif' $TRUNK_PATH/www/img/organizations
scp -r 'lo-web1:/var/www/production/www/img/organizations/*.png' $TRUNK_PATH/www/img/organizations
scp -r 'lo-web1:/var/www/production/www/img/products/raws/*.dat' $TRUNK_PATH/www/img/products/raws
scp -r 'lo-web1:/var/www/production/www/img/newsletters/*' $TRUNK_PATH/www/img/newsletters
scp -r 'lo-web1:/var/www/production/www/img/weeklyspec/*' $TRUNK_PATH/www/img/weeklyspec

# dump production db
echo 'downloading production db...'	
ssh lo-web1 "mysqldump localorb_www_production -h localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com -u localorb_www -pl0cal1sdab3st" > localorb_local_temp.sql
echo 'SET FOREIGN_KEY_CHECKS = 0;' > localorb_local.sql
echo 'DROP DATABASE if exists localorb_www_dev;' >> localorb_local.sql
echo 'CREATE DATABASE localorb_www_dev;' >> localorb_local.sql
echo 'use localorb_www_dev;' >> localorb_local.sql
cat localorb_local_temp.sql >> localorb_local.sql
echo 'SET FOREIGN_KEY_CHECKS = 1;' >> localorb_local.sql
echo 'update domains set hostname = concat("dev",hostname);
update customer_entity set password="SRVI5jqkxdG1099AxS5l4Hd44VKqXj6tR-993b65a0e5f0f10e093bc9662009388a096ff3d113a2b71ec466d4c2b49069fc5bb274f39978db5efeab5f67591e89a0a04a2a71c4ace3022441d059fa42c7da" where entity_id=219;' >> localorb_local.sql
echo 'update customer_entity set email = concat("localorbit.testing+",entity_id,"@gmail.com") where org_id <> 1;' >> localorb_local.sql
echo 'grant all on localorb_www_dev.* to localorb_www identified by "localorb_www_dev";' >> localorb_local.sql

# execute sql script
echo 'running script...'
mysql -u root -p$MYSQL_PASSWORD < localorb_local.sql
echo 'done.'

