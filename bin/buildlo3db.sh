#!/bin/sh
echo "stage 1: restoring lo2 database"
mysql --user=localorb_www --password=l0cal1sdab3st localorb_www_testing < ../db/lo3_base.sql;
echo "stage 2: applying basic structural changes"
mysql --user=localorb_www --password=l0cal1sdab3st localorb_www_testing < ../db/patches/2012-01-22__prod2lo3a.sql;
echo "stage 3: user/org/address/order migration to new structures"
rm -Rf /var/www/testing/img/organizations/*.jpg;
php -f ./convert_to_lo3.php;
echo "stage 4: domain migration to new structures"
php -f ./convert_domains_to_lo3.php;
echo "stage 5: product migration to new structures"
php -f ./convert_products_to_lo3.php;
echo "stage 6: product image migration to new structures"
rm -Rf /var/www/testing/img/products/raws/*.dat;
rm -Rf /var/www/testing/img/products/cache/*.dat;
php -f ./convert_product_images_to_lo3.php;
echo "stage 7: category migration to new structure"
php -f ./convert_categories_to_lo3.php;
echo "stage 8: final cleanup of old data"
mysql --user=localorb_www --password=l0cal1sdab3st localorb_www_testing < ../db/patches/2012-02-17__finalize.sql;

echo "done!"
