#!/bin/sh
cd ~;
echo 'backing up and compressing database...'
ssh lo-web1 "mysqldump --host=localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com --user=localorb_www --password=l0cal1sdab3st localorb_www_production > ~/prod.sql; zip -rqq ~/prod.zip ~/prod.sql;rm ~/prod.sql;";
echo 'downloading backup...'
scp -q lo-web1:~/prod.zip /tmp;
echo 'deflating backup...'
unzip -jqq /tmp/prod.zip
echo 'running backup...'
mysql --host=localhost --user=localorb_www --password=localorb_www_dev localorb_www_dev < ~/prod.sql;
ssh lo-web1 "rm ~/prod.zip;";
rm /tmp/prod.zip;
#rm ~/prod.sql;
#rm /tmp/lo-prod.sql;
echo 'cleaning up...'
mysql --host=localhost --user=localorb_www --password=localorb_www_dev localorb_www_dev -e "update customer_entity set email=concat_ws('','localorbit.testing+',entity_id,'@gmail.com') where org_id<>1;";
echo 'removing payment methods...'
mysql --host=localhost --user=localorb_www --password=localorb_www_dev localorb_www_dev -e "delete from organization_payment_methods;";
echo 'updating domains...'
mysql --host=localhost --user=localorb_www --password=localorb_www_dev localorb_www_dev -e "update domains set hostname=concat_ws('','dev',hostname);";
