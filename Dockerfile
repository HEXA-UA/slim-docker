FROM php:7.2-fpm
MAINTAINER Hexa "info@hexa.com.ua"

# Environment settings
ENV DEBIAN_FRONTEND=noninteractive

ENV PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.7 \
    COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update \
    && apt-get install -y zlib1g-dev git gnupg curl apt-utils --no-install-recommends openssh-client \
    && apt-get -y autoclean \
    && docker-php-ext-install zip \
    && docker-php-ext-install sockets

RUN pecl install xdebug-2.6.0

# Install composer
RUN apt-get purge -y g++ \
    && apt-get autoremove -y \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer clear-cache

# Install composer plugins
RUN composer global require --optimize-autoloader \
        "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" \
        && composer global dumpautoload --optimize \
        && composer clear-cache

# Install nodejs, webpack
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs build-essential
RUN npm install -g webpack

# Debug info
RUN node -v
RUN npm -v