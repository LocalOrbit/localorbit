#!/bin/bash
cd /var/www/$1/www/img;

for i in {1 .. $2}
do
   mkdir $i;
   chmod 777 $i;
done