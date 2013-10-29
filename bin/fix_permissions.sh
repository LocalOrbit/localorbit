#!/bin/bash
cd /var/www/$1/www/img;

for (( c=1; c<=$2; c++ ))
do
   mkdir $c;
   chown ubuntu:ubuntu $c;
   chmod 777 $c;
done