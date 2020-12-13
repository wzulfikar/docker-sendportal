FROM php:7.4-fpm-alpine

RUN apk --update add wget \
    curl \
    git \
    grep \
    build-base \
    libmemcached-dev \
    libmcrypt-dev \
    libxml2-dev \
    imagemagick-dev \
    pcre-dev \
    libtool \
    make \
    autoconf \
    g++ \
    cyrus-sasl-dev \
    libgsasl-dev \
    supervisor

RUN docker-php-ext-install mysqli pdo pdo_mysql tokenizer xml pcntl posix

RUN pecl channel-update pecl.php.net && \
    pecl install mcrypt && \
    pecl install memcached && \
    pecl install imagick && \
    pecl install redis && \
    docker-php-ext-enable mcrypt && \
    docker-php-ext-enable memcached && \
    docker-php-ext-enable imagick && \
    docker-php-ext-configure opcache --enable-opcache && \
    docker-php-ext-install opcache && \
    docker-php-ext-enable redis && \
    rm /var/cache/apk/* && \
    mkdir -p /var/www

COPY opcache.ini $PHP_INI_DIR

# Setup sendportal
WORKDIR /app
RUN git clone https://github.com/mettle/sendportal.git .
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --ignore-platform-reqs
RUN chmod +x /app/artisan
RUN chown -R www-data:www-data /app/storage

# Publish laravel horizon assets
RUN /app/artisan horizon:publish

# Add SendPortal cron jobs that runs every minute
RUN echo '* * * * * php /app/artisan schedule:run >> /dev/null 2>&1' > /etc/crontabs/root
RUN echo '* * * * * php /app/artisan sp:campaigns:dispatch >> /dev/null 2>&1' >> /etc/crontabs/root

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
