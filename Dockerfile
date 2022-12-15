FROM php:8.0-apache

ARG PORT

RUN  echo "PORT1: "$PORT

ENV PORT=$PORT

RUN echo "PORT2: "$PORT

ENV COMPOSER_ALLOW_SUPERUSER=1

EXPOSE 80
WORKDIR /app

# git, unzip & zip are for composer
RUN apt-get update -qq && \
    apt-get install -qy \
    git \
    gnupg \
    unzip \
    zip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PHP Extensions
RUN docker-php-ext-install -j$(nproc) opcache pdo_mysql
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/app.ini"

# Apache
COPY config/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY config/apache.conf /etc/apache2/conf-available/z-app.conf
COPY / /app/

# Composer
RUN composer install --optimize-autoloader --no-dev --no-interaction --no-progress

# .env
RUN cp .env.example .env
RUN BORSCH_TEMP_KEYGEN=`openssl rand -base64 32`; sed -i "s/APP_KEY=/APP_KEY=$BORSCH_TEMP_KEYGEN/g" .env

# Apache
RUN a2enmod rewrite remoteip && a2enconf z-app