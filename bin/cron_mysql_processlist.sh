#!/bin/bash
# * * * * * /home/ubuntu/cron_mysql_processlist.sh

echo '--------------------------------------------------------------' >> /var/log/mysql_processlist.txt
date >> /var/log/mysql_processlist.txt
mysql --host=localorb.cc2ndox9watl.us-west-2.rds.amazonaws.com --user=localorb_www --password=l0cal1sdab3st localorb_www_qa -e 'show full processlist;' >> /var/log/mysql_processlist.txt 
echo '--------------------------------------------------------------' >> /var/log/mysql_processlist.txt
cat /var/log/mysql_processlist.txt

