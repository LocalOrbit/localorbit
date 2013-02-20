#!/bin/bash
MYSQL_PASSWORD=$1
MYSQL_PASSWORD_ARG=-$1
HTTPD_CONF=$(apachectl -V | grep -Po '(?<=SERVER_CONFIG_FILE=").+(?=")')
LOG_DIR=$(grep -Po '(?<=ErrorLog ").+(?=/[^/]+")' $HTTPD_CONF)

if [ -z "$1" ]; then
   MYSQL_PASSWORD_ARG=""
fi

# check out current files
svn co svn+ssh://svn/opt/localorbit/lo3/trunk/

#copy images
scp -r 'lo-web1:/var/www/production/www/img/organizations/*.jpg' $PWD/trunk/www/img/organizations
scp -r 'lo-web1:/var/www/production/www/img/organizations/*.gif' $PWD/trunk/www/img/organizations
scp -r 'lo-web1:/var/www/production/www/img/organizations/*.png' $PWD/trunk/www/img/organizations
scp -r 'lo-web1:/var/www/production/www/img/products/raws/*.dat' $PWD/trunk/www/img/products/raws
scp -r 'lo-web1:/var/www/production/www/img/newsletters/*' $PWD/trunk/www/img/newsletters
scp -r 'lo-web1:/var/www/production/www/img/weeklyspec/*' $PWD/trunk/www/img/weeklyspec

chmod 777 $PWD/trunk/www/img/products/cache
chmod 777 $PWD/trunk/www/img/organizations/cached

# dump production db
echo "downloading production db..."
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
mysql -u root -p$MYSQL_PASSWORD < localorb_local.sql

# export the hosts file
mysql -u localorb_www -p'localorb_www_dev' -e 'select concat("127.0.0.1\t", hostname) from domains;' -s -r -N localorb_www_dev > hosts_localorb
echo '127.0.0.1   dev.localorb.it' >> hosts_localorb

echo "NameVirtualHost *:80

<VirtualHost *:80>
   ServerAdmin webmaster@localhost
   ServerName  dev.localorb.it
   ServerAlias dev*.localorb.it
   DocumentRoot $PWD/trunk/www

   <Directory />
      Options FollowSymLinks
      AllowOverride All
   </Directory>

   <Directory $PWD/trunk/www>
      Options Indexes FollowSymLinks MultiViews
      AllowOverride All
      Order allow,deny
      allow from all
   </Directory>

   ErrorLog $LOG_DIR/error-dev.log

   # Possible values include: debug, info, notice, warn, error, crit,
   # alert, emerg.
   LogLevel warn

   CustomLog $LOG_DIR/access-dev.log combined

</VirtualHost>" > httpd-localorb.conf

echo "
Listen 443

<IfModule mod_ssl.c>
<VirtualHost _default_:443>
   ServerAdmin webmaster@localhost
   ServerName dev.localorb.it
   ServerAlias dev*.localorb.it
   DocumentRoot $PWD/trunk/www
   NameVirtualHost *:443
   SSLEngine on
   SSLCertificateFile    $PWD/trunk/etc/ssl/2012-2013_ssl.crt
   SSLCertificateKeyFile $PWD/trunk/etc/ssl/2012-2013.decrypted.key
   SSLCertificateChainFile $PWD/trunk/etc/ssl/2012-2013_intermediate.crt

   <Directory />
      Options FollowSymLinks
      AllowOverride All
   </Directory>
   <Directory $PWD/trunk/www>
      Options Indexes FollowSymLinks MultiViews
      AllowOverride All
      Order allow,deny
      allow from all
   </Directory>

   ErrorLog $LOG_DIR/error-dev.log

   # Possible values include: debug, info, notice, warn, error, crit,
   # alert, emerg.
   LogLevel warn

   CustomLog $LOG_DIR/access-dev.log combined

</VirtualHost>" >> httpd-localorb.conf
