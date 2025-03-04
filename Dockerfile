# Imagen base con PHP y extensiones necesarias que se ocuparán para el proyecto
FROM php:8.2-fpm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Definir el directorio de trabajo dentro del contenedor
WORKDIR /var/www

# Copiar los archivos del proyecto al contenedor
COPY . .

# Instalar dependencias de Laravel
RUN composer install --no-dev --optimize-autoloader

# Exponer el puerto en el que se ejecutará la aplicaciónss
EXPOSE 9000

CMD ["php-fpm"]