#!/bin/sh 
cp -r /server/http/public/ /var/www/html && fix-permission && php-fpm -F