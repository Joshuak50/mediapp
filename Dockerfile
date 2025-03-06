# Build Stage
FROM php:8.2-fpm AS builder

# Instalar dependencias y extensiones PHP
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libssl-dev \
    && docker-php-ext-install \
    pdo pdo_mysql \
    mbstring exif pcntl \
    bcmath gd zip opcache

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


# Instalar Node.js 18.x
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

WORKDIR /home/mediapp/backend-jesus-mediapp/mediapp
RUN ls -la /home/mediapp/backend-jesus-mediapp/mediapp


COPY composer.* package*.json ./

RUN composer install --no-dev --no-scripts --no-autoloader \
    && npm ci --prefer-offline --no-audit

COPY . .


RUN composer dump-autoload --optimize \
    && npm run build \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/*

# Production Stage
FROM httpd:2.4-alpine

RUN apk add --no-cache \
    php82-fpm \
    php82-pdo \
    php82-pdo_mysql \
    php82-mbstring \
    php82-opcache \
    php82-gd \
    php82-zip \
    php82-session \
    php82-tokenizer \
    supervisor

COPY docker/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY docker/extra/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/php-fpm.conf /etc/php82/php-fpm.d/www.conf

COPY --from=builder /home/mediapp/backend-jesus-mediapp/mediapp /home/mediapp/backend-jesus-mediapp/mediapp
COPY --from=builder /home/mediapp/backend-jesus-mediapp/mediapp /var/www/

RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www


RUN chown -R www-data:www-data /home/mediapp/backend-jesus-mediapp/mediapp/storage \
    && chmod -R 775 /home/mediapp/backend-jesus-mediapp/mediapp/storage

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]