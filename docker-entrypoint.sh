#!/bin/bash
set -e

# Ensure config.inc.php exists
if [ ! -f config.inc.php ]; then
    echo "Creating config.inc.php from template..."
    cp config.TEMPLATE.inc.php config.inc.php
fi

# Function to update OJS config
# Usage: set_config "section" "key" "value"
set_config() {
    local section=$1
    local key=$2
    local value=$3
    if [ -n "$value" ]; then
        echo "Configuring [$section] $key = $value"
        # Find the section, then find the key within that section and replace it
        # We use | as delimiter for sed to handle URLs in base_url
        sed -i "/^\[$section\]/,/^\[/ s|^$key =.*|$key = $value|" config.inc.php
    fi
}

# 1. Apply Essential Defaults for Proxy/Dokploy
set_config "general" "restful_urls" "Off"
set_config "general" "trust_x_forwarded_for" "On"
set_config "security" "force_ssl" "On"
set_config "security" "force_login_ssl" "On"

# 2. Map standard OJS Environment Variables if they exist
# These are the ones we'll recommend for the Dokploy UI
set_config "general" "base_url" "\"${OJS_BASE_URL}\""
set_config "database" "driver" "${OJS_DB_DRIVER:-postgres}"
set_config "database" "host" "${OJS_DB_HOST}"
set_config "database" "username" "${OJS_DB_USER}"
set_config "database" "password" "\"${OJS_DB_PASSWORD}\""
set_config "database" "name" "${OJS_DB_NAME}"

# 3. Dynamic Configuration via OJSCONFIG_ prefix
# Format: OJSCONFIG_SECTION_KEY (e.g. OJSCONFIG_EMAIL_SMTP_SERVER)
for var in $(env | grep "^OJSCONFIG_"); do
    config_pair=${var#OJSCONFIG_}
    config_key_full=${config_pair%%=*}
    config_value=${config_pair#*=}
    
    # Extract Section and Key (assumes SECTION_KEY format)
    section=$(echo $config_key_full | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    key=$(echo $config_key_full | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    
    set_config "$section" "$key" "\"$config_value\""
done

# 4. Generate APP_KEY if it's empty
if [ -z "$(grep "app_key =" config.inc.php | cut -d'=' -f2 | xargs)" ]; then
    APP_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    echo "Generated new app_key"
    sed -i "s/app_key =.*/app_key = $APP_KEY/" config.inc.php
fi

# 5. Fix permissions for runtime
chown -R www-data:www-data /var/www/html /var/www/ojs-files public/ plugins/ cache/
chmod -R 775 /var/www/html /var/www/ojs-files public/ plugins/ cache/

exec "$@"
