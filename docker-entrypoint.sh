#!/bin/bash
set -e

# Debug: Show inherited environment (filtered for OJS)
echo "--- Environment Check ---"
env | grep -E "^(OJS|PKP|OJSCONFIG)_" | grep -iv "PASSWORD" || true
echo "--------------------------"

# Ensure config.inc.php exists
if [ ! -f config.inc.php ]; then
    echo "Creating config.inc.php from template..."
    cp config.TEMPLATE.inc.php config.inc.php
fi

# Function to update OJS config
set_config() {
    local section=$1
    local key=$2
    local value=$3
    if [ -n "$value" ]; then
        echo "Configuring [$section] $key = $value"
        # Search for the key in the specific section and replace it
        # Handles both commented and uncommented lines
        sed -i "/^\[$section\]/,/^\[/ s|^;*[[:space:]]*$key[[:space:]]*=.*|$key = $value|" config.inc.php
    fi
}

# 1. Force Post-Install Mode and Clean URLs
set_config "general" "installed" "On"
set_config "general" "restful_urls" "On"
set_config "general" "display_errors" "Off"
set_config "general" "show_stacktrace" "Off"
set_config "general" "trust_x_forwarded_for" "On"

# 2. Essential Security/Proxy Defaults
set_config "security" "force_ssl" "On"
set_config "security" "force_login_ssl" "On"

# 3. Database Mapping
set_config "database" "driver" "${OJS_DB_DRIVER:-postgres}"
set_config "database" "host" "${OJS_DB_HOST}"
set_config "database" "port" "${OJS_DB_PORT:-5432}"
set_config "database" "username" "${OJS_DB_USER}"
set_config "database" "password" "${OJS_DB_PASSWORD}"
set_config "database" "name" "${OJS_DB_NAME}"

# 4. Files Mapping
set_config "files" "files_dir" "/var/www/ojs-files"

# 5. Base URL (Needs quotes in OJS)
if [ -n "$OJS_BASE_URL" ]; then
    set_config "general" "base_url" "\"$OJS_BASE_URL\""
fi

# 6. Dynamic Configuration via OJSCONFIG_ prefix (Case Sensitive Section/Key)
# Format: OJSCONFIG_SECTION_KEY (e.g. OJSCONFIG_EMAIL_SMTP_SERVER)
# We use a custom parser to handle underscores in section names if needed
for var in $(env | grep "^OJSCONFIG_"); do
    config_pair=${var#OJSCONFIG_}
    config_key_full=${config_pair%%=*}
    config_value=${config_pair#*=}
    
    # Simple split at the first underscore for section
    section=$(echo $config_key_full | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    key=$(echo $config_key_full | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    
    # If the key is just numbers or basic text, don't quote. Otherwise quote.
    if [[ "$config_value" =~ ^[0-9]+$ ]] || [[ "$config_value" =~ ^(On|Off|true|false)$ ]]; then
        set_config "$section" "$key" "$config_value"
    else
        set_config "$section" "$key" "\"$config_value\""
    fi
done

# 7. Handle PKP_CONF_ style variables
for var in $(env | grep "^PKP_CONF_"); do
    config_pair=${var#PKP_CONF_}
    config_key_full=${config_pair%%=*}
    config_value=${config_pair#*=}
    
    section=$(echo $config_key_full | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    key=$(echo $config_key_full | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    
    set_config "$section" "$key" "$config_value"
done

# 8. Generate APP_KEY if it's empty
if [ -z "$(grep "app_key =" config.inc.php | cut -d'=' -f2 | xargs)" ]; then
    APP_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    echo "Generated new app_key"
    sed -i "s/app_key =.*/app_key = $APP_KEY/" config.inc.php
fi

# 9. Fix permissions for runtime
chown -R www-data:www-data /var/www/html /var/www/ojs-files public/ plugins/ cache/
chmod -R 775 /var/www/html /var/www/ojs-files public/ plugins/ cache/

exec "$@"
