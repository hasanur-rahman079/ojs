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
    libcurl4-openssl-dev \
    libssl-dev \
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
    session \
    ftp

# Install Node.js (Required for OJS 3.5 Assets)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application source
COPY . .

# Ensure config.inc.php exists and pre-configure it for SSL/Proxies
RUN if [ ! -f config.inc.php ]; then cp config.TEMPLATE.inc.php config.inc.php; fi \
    && sed -i 's|base_url = ".*"|base_url = "https://my.ems.pub"|' config.inc.php \
    && sed -i '/base_url = "https:\/\/my.ems.pub"/a base_url[index] = "https://my.ems.pub"' config.inc.php \
    && sed -i 's/trust_x_forwarded_for = Off/trust_x_forwarded_for = On/' config.inc.php \
    && sed -i 's/force_ssl = Off/force_ssl = On/' config.inc.php \
    && sed -i 's/force_login_ssl = Off/force_login_ssl = On/' config.inc.php

# Fetch Git Submodules (Crucial for lib/pkp and plugins)
RUN git config --global --add safe.directory /var/www/html \
    && git submodule update --init --recursive

# Install Node dependencies and build assets
RUN npm install && npm run build

# Install PHP dependencies (Core and Plugins)
RUN composer -d lib/pkp install --no-dev --optimize-autoloader \
    && for d in $(find plugins -name composer.json -exec dirname {} \;); do \
    composer install --no-dev -d $d --no-interaction --optimize-autoloader; \
    done

# Create OJS Files Directory (outside web root)
RUN mkdir -p /var/www/ojs-files

# Set permissions for the entire web root and files directory
RUN chown -R www-data:www-data /var/www/html /var/www/ojs-files \
    && chmod -R 775 /var/www/html /var/www/ojs-files

# Apache Configuration for OJS
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
    </Directory>\n\
    SetEnvIf X-Forwarded-Proto \"^https$\" HTTPS=on" > /etc/apache2/conf-available/ojs.conf \
    && a2enconf ojs

EXPOSE 80
CMD ["apache2-foreground"]
