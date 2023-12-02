FROM php:8.2.13-cli-alpine3.18

RUN apk add --no-cache \
        curl \
        libcurl \
        wget \
        libzip-dev \
        libmcrypt-dev \
        libxslt-dev \
        libxml2-dev \
        icu-dev \
        zip

RUN docker-php-ext-install \
        opcache \
        zip \
        xsl \
        dom \
        exif \
        intl \
        pcntl \
        bcmath \
        sockets

RUN apk add --no-cache nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
RUN [ -d /etc/nginx/conf.d ] ||  mkdir /etc/nginx/conf.d
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

RUN docker-php-source delete \
        && apk del ${BUILD_DEPENDS}
