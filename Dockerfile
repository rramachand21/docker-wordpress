FROM wordpress:4-php7.1-fpm-alpine

RUN apk --no-cache add openssl

ENV PHPREDIS_VERSION 3.1.2
ENV WPFPM_FLAG WPFPM_
ENV PAGER more

RUN docker-php-source extract \
  && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
  && tar xfz /tmp/redis.tar.gz \
  && rm -r /tmp/redis.tar.gz \
  && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
  && docker-php-ext-install redis \
  && docker-php-source delete \
  && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

ADD uploads.ini /usr/local/etc/php/conf.d/
ADD .bashrc /root
COPY docker-entrypoint2.sh /usr/local/bin/
COPY secure-db-connection.1.1.4.zip /tmp

RUN unzip /tmp/secure-db-connection.1.1.4.zip -d /usr/src/wordpress/wp-content/plugins
COPY db.php /usr/src/wordpress/wp-content/db.php
COPY wp-config.php /tmp/

ENTRYPOINT ["docker-entrypoint2.sh"]
CMD ["php-fpm"]
