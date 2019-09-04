#
# Install PHP Dependencies
#
FROM alpine as wordpress

RUN mkdir /wordpress 
WORKDIR /wordpress
RUN wget https://wordpress.org/latest.tar.gz && tar xzvf latest.tar.gz 


FROM composer as vendor

WORKDIR /app

COPY composer.json composer.json

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist


#
# Frontend , if you using node as bulding themes uncomment
#
# FROM node as frontend
# 
# RUN mkdir -p /app/public
# 
# COPY package.json webpack.mix.js yarn.lock /app/
# COPY resources/assets/ /app/resources/assets/
# 
# WORKDIR /app
# 
# RUN yarn install && yarn production

#
# Application Build
#

FROM php:7.3-fpm-alpine
RUN docker-php-ext-install mysqli && apk add php7-redis
COPY --chown=33:88 --from=wordpress  /wordpress/wordpress/ /server/http/public/
COPY --chown=33:88 --from=vendor /app/vendor/ /server/http/public/vendor/
COPY ./fix-permission /bin/
#COPY ./wp-config-sample.php /server/http/public/wp-config.php
COPY ./docker-compose-entrypoint.sh /docker-compose-entrypoint.sh
RUN chmod +x /docker-compose-entrypoint.sh && touch /server/http/public/.env

# uncomment this lines if you dont want to use redis as session handler 

# RUN sed -i 's/session.save_handler = files/session.save_handler = redis/' /usr/local/etc/php/php.ini-* \
# && sed -i 's/;session.save_path = "\/tmp"/session.save_path = tcp:\/\/redis:6379/' /usr/local/etc/php/php.ini-*


#COPY --from=frontend /app/public/js/ /var/www/html/public/js/
#COPY --from=frontend /app/public/css/ /var/www/html/public/css/
#COPY --from=frontend /app/mix-manifest.json /var/www/html/mix-manifest.json