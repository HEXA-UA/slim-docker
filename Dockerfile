FROM php:7.2-fpm
MAINTAINER Hexa "info@hexa.com.ua"

# Environment settings
ENV DEBIAN_FRONTEND=noninteractive

ENV PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.7 \
    VERSION_PHING=2.* \
    COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update \
    && apt-get install -y zlib1g-dev git gnupg curl apt-utils \
    openssh-client procps net-tools xvfb libpng-dev libjpeg-dev --no-install-recommends \
    && apt-get -y autoclean \
    && /usr/local/bin/docker-php-ext-configure gd --with-jpeg-dir=/usr/include \
    && docker-php-ext-install zip \
    && docker-php-ext-install sockets \
    && docker-php-ext-install gd

RUN pecl install xdebug-2.6.0 \
    && docker-php-ext-enable xdebug

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

RUN composer global require --optimize-autoloader \
        "phing/phing:${VERSION_PHING}" \
        && composer global dumpautoload --optimize \
        && composer clear-cache

# Install nodejs, webpack
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs build-essential
RUN npm install -g webpack

RUN curl -LO https://deployer.org/releases/v4.3.4/deployer.phar
RUN mv deployer.phar /usr/local/bin/dep
RUN chmod +x /usr/local/bin/dep

# Debug info
RUN node -v
RUN npm -v
