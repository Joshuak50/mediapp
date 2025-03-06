# Etapa de construcción (build stage)
FROM php:8.2-fpm AS builder

# Instalar dependencias del sistema y extensiones PHP
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

# Directorio de trabajo
WORKDIR /var/www

# Copiar archivos de configuración
COPY package*.json .
COPY composer.* .

# Instalar dependencias
RUN composer install --no-dev --no-scripts --no-autoloader \
    && npm ci --prefer-offline --no-audit

# Copiar todo el proyecto
COPY . .

# Compilar assets y optimizar
RUN composer dump-autoload --optimize \
    && npm run build \
    && npm cache clean --force \
    && rm -rf /var/lib/apt/lists/*

# Etapa de producción
FROM httpd:2.4-alpine AS production

# Instalar PHP-FPM y dependencias
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
    supervisor \
    apache2-proxy

# Configuración de Apache
COPY docker/httpd.conf /usr/local/apache2/conf/httpd.conf
COPY docker/extra/httpd-vhosts.conf /usr/local/apache2/conf/extra/httpd-vhosts.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configuración de PHP-FPM
COPY docker/php-fpm.conf /etc/php82/php-fpm.d/www.conf

# Copiar archivos desde el builder
COPY --from=builder /var/www /home/mediapp/backend-jesus-mediapp/mediapp

# Configurar permisos para EC2-user
RUN chown -R ec2-user:ec2-user /home/mediapp/backend-jesus-mediapp/mediapp \
    && chmod -R 775 /home/mediapp/backend-jesus-mediapp/mediapp/storage \
    && sed -i 's#^DocumentRoot ".*#DocumentRoot "/home/mediapp/backend-jesus-mediapp/mediapp/public"#g' /usr/local/apache2/conf/httpd.conf

# Variables de entorno
ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_MEMORY_CONSUMPTION=128

# Exponer puertos
EXPOSE 80

# Comando de inicio
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]