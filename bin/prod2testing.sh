#!/bin/sh
echo "stage 1: dumping production db"
mysqldump --user=localorb_www --password=l0cal1sdab3st localorb_www_production > /root/dbdump.sql;
echo "stage 2: restoring to testing"
mysql --user=localorb_www --password=l0cal1sdab3st localorb_www_testing < /root/dbdump.sql;
echo "stage 3: changing hostnames to foodhubresource.com"
mysql --user=localorb_www --password=l0cal1sdab3st localorb_www_testing < /var/www/testing/db/change_prod2testing.sql;
echo "stage 4: changing customer emails"
php -f /var/www/testing/bin/prod2testqa_emails.php
echo "stage 5: moving profile images"
rm /var/www/testing/www/img/organizations/*.jpg;
rm /var/www/testing/www/img/organizations/cached/*.jpg;
cp -v /var/www/production/www/img/organizations/*.jpg /var/www/testing/www/img/organizations/;
echo "stage 6: moving product images"
rm -Rf /var/www/testing/www/img/products/raws/*.dat;
rm -Rf /var/www/testing/www/img/products/cache/*.dat;
cp -v /var/www/production/www/img/products/raws/*.dat /var/www/testing/www/img/products/raws/;

echo "stage 7: moving newsletter images"
rm /var/www/testing/www/img/newsletters/*.jpg;
rm /var/www/testing/www/img/newsletters/*.png;
rm /var/www/testing/www/img/newsletters/*.gif;
cp -v /var/www/production/www/img/newsletters/* /var/www/testing/www/img/newsletters/;

echo "stage 8: moving organizations images"
rm /var/www/testing/www/img/organizations/*.jpg;
rm /var/www/testing/www/img/organizations/*.png;
rm /var/www/testing/www/img/organizations/*.gif;
rm /var/www/testing/www/img/organizations/cached/*.jpg;
cp -v /var/www/production/www/img/organizations/*.jpg /var/www/testing/www/img/organizations/;
cp -v /var/www/production/www/img/organizations/*.png /var/www/testing/www/img/organizations/;
cp -v /var/www/production/www/img/organizations/*.gif /var/www/testing/www/img/organizations/;

echo "stage 9: moving weekly special images"
rm /var/www/testing/www/img/weeklyspec/*.jpg;
rm /var/www/testing/www/img/weeklyspec/*.png;
rm /var/www/testing/www/img/weeklyspec/*.gif;
cp -v /var/www/production/www/img/weeklyspec/* /var/www/testing/www/img/weeklyspec/;

echo "stage 10: cleanup";
rm /root/dbdump.sql;
