FROM php:fpm-alpine

RUN apk add --no-cache nginx supervisor \
    && apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev postgresql-dev icu-dev curl git g++ make autoconf \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev \
	  && pecl install redis \
	  && docker-php-ext-enable redis \
	  && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
	  && docker-php-ext-install -j$(nproc) pgsql pdo_mysql pdo_pgsql intl\
    && rm /var/lib/nginx/logs \
    && mkdir -p /var/lib/nginx/logs \
    && ln -s /dev/stderr /var/lib/nginx/logs/error.log \
    && mkdir -p /etc/nginx/server.d/ \
    && mkdir -p /etc/nginx/location.d/ \
	  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR "/application"

ADD etc/ /etc/

VOLUME /srv/data /tmp /var/tmp /run /var/log

EXPOSE 443 80

ENTRYPOINT ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
