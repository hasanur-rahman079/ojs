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
    libpq-dev \
    postgresql-client \
    curl \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions required by OJS
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    gd \
    intl \
    mbstring \
    xml \
    zip \
    bcmath \
    curl \
    fileinfo \
    gettext \
    ftp

# Install Node.js (Required for OJS 3.5 Assets)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Enable Apache modules required for OJS and Proxies
RUN a2enmod rewrite headers remoteip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application source
COPY . .

# Copy and set up the runtime entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Fetch Git Submodules (Crucial for lib/pkp and plugins)
RUN git config --global --add safe.directory /var/www/html \
    && git submodule update --init --recursive

# Install Node dependencies and build assets (Required for OJS 3.5)
RUN npm install && npm run build

# Install PHP dependencies (Core and Plugins)
RUN composer -d lib/pkp install --no-dev --optimize-autoloader \
    && for d in $(find plugins -name composer.json -exec dirname {} \;); do \
    composer install --no-dev -d $d --no-interaction --optimize-autoloader; \
    done

# Create necessary directories and set permissions
RUN mkdir -p /var/www/ojs-files \
    && mkdir -p cache/t_cache cache/t_compile cache/t_config cache/_db \
    && chown -R www-data:www-data /var/www/html /var/www/ojs-files \
    && chmod -R 775 /var/www/html /var/www/ojs-files

# Apache Configuration for OJS (Clean URLs and HTTPS)
RUN printf "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Options -MultiViews +FollowSymLinks\n\
    Require all granted\n\
    <IfModule mod_rewrite.c>\n\
    RewriteEngine On\n\
    RewriteBase /\n\
    RewriteCond %%{REQUEST_FILENAME} !-d\n\
    RewriteCond %%{REQUEST_FILENAME} !-f\n\
    RewriteRule ^(.*)$ index.php/\$1 [QSA,L]\n\
    </IfModule>\n\
    </Directory>\n\
    SetEnvIf X-Forwarded-Proto \"^https$\" HTTPS=on\n" > /etc/apache2/conf-available/ojs.conf \
    && a2enconf ojs

EXPOSE 80
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
