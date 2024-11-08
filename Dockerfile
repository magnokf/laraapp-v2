FROM php:8.3-fpm-alpine

ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000

# Install system dependencies including shadow package
RUN apk add --no-cache \
    git \
    zip \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    linux-headers \
    postgresql-dev \
    postgresql-libs \
    libpq-dev \
    shadow \
    $PHPIZE_DEPS

# Install PHP extensions including pdo_pgsql
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        bcmath \
        opcache \
        zip \
        gd \
        intl \
    && pecl install redis \
    && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configure PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Add custom PHP configurations
RUN echo "upload_max_filesize = 50M" >> $PHP_INI_DIR/conf.d/custom.ini \
    && echo "post_max_size = 50M" >> $PHP_INI_DIR/conf.d/custom.ini \
    && echo "memory_limit = 256M" >> $PHP_INI_DIR/conf.d/custom.ini \
    && echo "max_execution_time = 600" >> $PHP_INI_DIR/conf.d/custom.ini \
    && echo "default_socket_timeout = 600" >> $PHP_INI_DIR/conf.d/custom.ini

# Setup user with correct permissions
RUN usermod -u ${HOST_USER_ID} www-data \
    && groupmod -g ${HOST_GROUP_ID} www-data

# Copy and setup entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create necessary directories
RUN mkdir -p /var/www/nested \
    && chown -R www-data:www-data /var/www/nested

WORKDIR /var/www/nested

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]