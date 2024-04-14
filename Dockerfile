FROM php:8.2.13-cli-alpine3.18

RUN apk add --no-cache \
        curl \
        libcurl \
        wget \
        libzip-dev \
        libmcrypt-dev \
        libxslt-dev \
        libxml2-dev \
        libssl-dev \
        icu-dev \
        zip \
        unzip \
        linux-headers \
        pkg-config

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

# PHP settings
RUN sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' "$PHP_INI_DIR/php.ini-production" && \
    sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' "$PHP_INI_DIR/php.ini-production" && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Nginx
RUN apk add --no-cache nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
RUN [ -d /etc/nginx/conf.d ] ||  mkdir /etc/nginx/conf.d
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

# PDO database drivers support
RUN apk --no-cache add postgresql-dev
RUN docker-php-ext-install \
        pgsql pdo_pgsql pdo_mysql

# MongoDB support
RUN pecl install zlib zip mongodb \
    && docker-php-ext-enable mongodb

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

RUN docker-php-source delete \
        && apk del ${BUILD_DEPENDS}
