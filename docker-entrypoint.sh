#!/bin/bash
set -e

# Debug: Show inherited environment (filtered)
echo "--- Environment Check ---"
env | grep -E "^(OJS|PKP|OJSCONFIG)_" | grep -iv "PASSWORD" | sort || true
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
        # If value is not already quoted and is not a number/boolean, wrap in quotes
        if [[ ! "$value" =~ ^['"].*['"]$ ]] && [[ ! "$value" =~ ^[0-9]+$ ]] && [[ ! "$value" =~ ^(On|Off|true|false)$ ]]; then
            value="\"$value\""
        fi
        # Handles both commented and uncommented lines, more robust section matching
        # We look for the section, then search for the key until the next section
        sed -i "/^\[$section\]/,/^\[/ s|^;*[[:space:]]*$key[[:space:]]*=.*|$key = $value|" config.inc.php
    fi
}

# 1. Base Defaults (Inject these first)
set_config "general" "installed" "On"
set_config "general" "restful_urls" "On"
set_config "general" "display_errors" "Off"
set_config "general" "show_stacktrace" "Off"
set_config "general" "trust_x_forwarded_for" "On"
set_config "security" "force_ssl" "On"
set_config "security" "force_login_ssl" "On"
set_config "files" "files_dir" "/var/www/ojs-files"

# 2. Database Defaults
set_config "database" "driver" "${OJS_DB_DRIVER:-postgres}"
set_config "database" "host" "${OJS_DB_HOST}"
set_config "database" "port" "${OJS_DB_PORT:-5432}"
set_config "database" "username" "${OJS_DB_USER}"
set_config "database" "password" "${OJS_DB_PASSWORD}"
set_config "database" "name" "${OJS_DB_NAME}"

# 3. Handle OJSCONFIG_ style variables
env | grep "^OJSCONFIG_" | while read -r var_line; do
    # var_line is "OJSCONFIG_SECTION_KEY=value"
    config_pair=${var_line#OJSCONFIG_}
    config_key_full=${config_pair%%=*}
    config_value=${config_pair#*=}
    
    # Section is the first part, Key is everything else
    section=$(echo "$config_key_full" | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    key=$(echo "$config_key_full" | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    
    set_config "$section" "$key" "$config_value"
done

# 3.1 Explicit Overrides for critical settings (ensure they are applied)
set_config "general" "allowed_hosts" "${OJSCONFIG_GENERAL_ALLOWED_HOSTS}"
set_config "security" "salt" "${OJSCONFIG_SECURITY_SALT}"
set_config "security" "api_key_secret" "${OJSCONFIG_SECURITY_API_KEY_SECRET}"
set_config "email" "dmarc_compliant_from_displayname" "${OJSCONFIG_EMAIL_DMARC_COMPLIANT_FROM_DISPLAYNAME}"
set_config "email" "require_validation" "${OJSCONFIG_EMAIL_REQUIRE_VALIDATION}"
set_config "schedule" "task_runner" "${OJSCONFIG_SCHEDULE_TASK_RUNNER}"

# 4. Anti-Spam / DMARC Compliance (Apply if email username is present)
if [ -n "$OJSCONFIG_EMAIL_SMTP_USERNAME" ]; then
    echo "Applying Anti-Spam / DMARC Compliance settings..."
    set_config "email" "allow_envelope_sender" "On"
    set_config "email" "default_envelope_sender" "\"$OJSCONFIG_EMAIL_SMTP_USERNAME\""
    set_config "email" "force_default_envelope_sender" "On"
    set_config "email" "force_dmarc_compliant_from" "On"
fi

# 5. Handle PKP_CONF_ style variables
env | grep "^PKP_CONF_" | while read -r var_line; do
    config_pair=${var_line#PKP_CONF_}
    config_key_full=${config_pair%%=*}
    config_value=${config_pair#*=}
    
    section=$(echo "$config_key_full" | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    key=$(echo "$config_key_full" | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    
    set_config "$section" "$key" "$config_value"
done

# 6. Fallback for OJS_BASE_URL (Ensure it's QUOTED)
if [ -n "$OJS_BASE_URL" ] && [ -z "$PKP_CONF_GENERAL_BASE_URL" ]; then
    set_config "general" "base_url" "\"$OJS_BASE_URL\""
fi

# 7. Generate APP_KEY if it's empty
if [ -z "$(grep "app_key =" config.inc.php | cut -d'=' -f2 | xargs)" ]; then
    APP_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    echo "Generated new app_key"
    sed -i "s/app_key =.*/app_key = $APP_KEY/" config.inc.php
fi

# 8. Fix permissions for runtime
chown -R www-data:www-data /var/www/html /var/www/ojs-files public/ plugins/ cache/
chmod -R 775 /var/www/html /var/www/ojs-files public/ plugins/ cache/

exec "$@"
