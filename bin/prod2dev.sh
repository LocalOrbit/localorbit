#!/bin/sh
cd ~;
ssh lo-web1 "mysqldump --host=localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com --user=localorb_www --password=l0cal1sdab3st localorb_www_production > ~/prod.sql; zip -r ~/prod.zip ~/prod.sql;rm ~/prod.sql;";
scp lo-web1:~/prod.zip /tmp;
unzip -j /tmp/prod.zip;
mysql --host=localhost --user=root --password=root localorb_www_dev < ~/prod.sql;
ssh lo-web1 "rm ~/prod.zip;";
rm /tmp/prod.zip;
rm ~/prod.sql;
#rm /tmp/lo-prod.sql;
mysql --host=localhost --user=localorb_www --password=localorb_www_dev localorb_www_dev -e "update customer_entity set email=concat_ws('','localorbit.testing+',entity_id,'@gmail.com') where org_id<>1;";
mysql --host=localhost --user=localorb_www --password=localorb_www_dev localorb_www_dev -e "delete from organization_payment_methods;";
mysql --host=localhost --user=localorb_www --password=localorb_www_dev localorb_www_dev -e "update domains set hostname=concat_ws('','dev',hostname);";

