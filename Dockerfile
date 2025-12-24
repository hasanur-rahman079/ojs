# Use PHP 8.3 with Apache as base
FROM php:8.3-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    libonig-dev \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by OJS
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    gd \
    intl \
    mbstring \
    xml \
    zip \
    bcmath \
    curl \
    fileinfo \
    gettext \
    session

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application source
COPY . .

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html

# Install PHP dependencies
RUN composer -d lib/pkp install --no-dev --optimize-autoloader

# Create OJS Files Directory (outside web root)
RUN mkdir -p /var/www/ojs-files \
    && chown -R www-data:www-data /var/www/ojs-files \
    && chmod -R 775 /var/www/ojs-files

# Apache Configuration for OJS
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>" > /etc/apache2/conf-available/ojs.conf \
    && a2enconf ojs

# Entrypoint setup if needed, but for now we'll use default apache2-foreground
EXPOSE 80
CMD ["apache2-foreground"]
