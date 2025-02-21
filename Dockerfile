FROM php:8.3-cli-alpine3.21

ENV TZ="UTC"
ENV COMPOSER_ALLOW_SUPERUSER=1

COPY --from=ghcr.io/mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/install-php-extensions
COPY --from=composer:2.8.4 /usr/bin/composer /usr/bin/composer

RUN apk update && apk add --no-cache \
  bash \
  ca-certificates \
  icu-data-full icu-libs \
  libgpg-error libgcrypt libxslt \
  libzip \
  linux-headers \
  lz4-libs \
  openssh-client \
  ${PHPIZE_DEPS} \
  && install-php-extensions pgsql \
  && install-php-extensions pdo_pgsql \
  && install-php-extensions pdo_mysql \
  && install-php-extensions intl \
  && install-php-extensions zip \
  && install-php-extensions opcache \
  && install-php-extensions exif \
  && install-php-extensions bcmath \
  && install-php-extensions xsl \
  && install-php-extensions pcntl \
  && install-php-extensions sockets \
  && apk del --no-cache ${PHPIZE_DEPS} \
  && rm -rf /tmp/*

# PHP settings
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
  && echo "memory_limit=2048M" >> "$PHP_INI_DIR/conf.d/docker-php.ini"
  && echo "post_max_size=1024M" >> "$PHP_INI_DIR/conf.d/docker-php.ini"

# Nginx
RUN apk add --no-cache nginx
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
RUN [ -d /etc/nginx/conf.d ] ||  mkdir /etc/nginx/conf.d
COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf
