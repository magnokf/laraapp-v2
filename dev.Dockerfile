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
    libxml2-dev \
    openldap-dev \
    # Node.js e npm
    nodejs \
    npm \
    $PHPIZE_DEPS

# Install PHP extensions including pdo_pgsql, soap, and ldap
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
        soap \
        ldap \
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

# Configurar npm globalmente
RUN mkdir -p /usr/local/lib/node_modules \
    && chmod -R 777 /usr/local/lib/node_modules \
    && npm install -g npm@latest \
    && npm config set cache /home/www-data/.npm --global \
    && npm config set prefer-offline true --global \
    && npm config set fund false --global \
    && npm config set audit false --global \
    && npm config set update-notifier false --global

# Configure PHP-FPM
RUN echo "Creating PHP-FPM configuration..." \
    && echo "[www]" > /usr/local/etc/php-fpm.d/www.conf \
    && echo "user = www-data" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "group = www-data" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "listen = 9000" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm = dynamic" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.max_children = 5" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.start_servers = 2" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.min_spare_servers = 1" >> /usr/local/etc/php-fpm.d/www.conf \
    && echo "pm.max_spare_servers = 3" >> /usr/local/etc/php-fpm.d/www.conf

# Setup user and permissions
RUN usermod -u ${HOST_USER_ID} www-data \
    && groupmod -g ${HOST_GROUP_ID} www-data \
    && mkdir -p /home/www-data \
    && chown -R www-data:www-data /home/www-data \
    && mkdir -p /.npm \
    && chown -R www-data:www-data /.npm \
    && mkdir -p /.config \
    && chown -R www-data:www-data /.config \
    && chown -R www-data:www-data /usr/local/lib/node_modules

# Copy and setup entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create necessary directories
RUN mkdir -p /var/www/nested \
    && chown -R www-data:www-data /var/www/nested

WORKDIR /var/www/nested

EXPOSE 5173 9000

USER www-data

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]