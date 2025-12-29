#!/bin/bash
set -e

# --- DEBUGGING AND ENVIRONMENT ---
echo "--- Starting OJS Configuration Management ---"
echo "Current Shell: $SHELL"
echo "--- Environment Variable Check ---"
# Check if critical var is present
if [ -n "$OJSCONFIG_GENERAL_ALLOWED_HOSTS" ]; then
    echo "[FOUND] OJSCONFIG_GENERAL_ALLOWED_HOSTS is present."
else
    echo "[MISSING] OJSCONFIG_GENERAL_ALLOWED_HOSTS is NOT in the environment."
fi

# Function to update OJS config (POSIX COMPLIANT)
set_config() {
    local section="$1"
    local key="$2"
    local value="$3"
    
    if [ -z "$value" ]; then
        return
    fi

    # Handle quoting logic
    # We want to ensure strings and JSON are quoted for the .ini file
    local q_value="$value"
    
    # Check if already starts with a quote
    case "$value" in
        \"*\"|\'*\') 
            # Already quoted, keep as is
            ;;
        *) 
            # Not quoted. Check if it's a number or boolean
            local is_simple=0
            case "$value" in
                *[!0-9]*) ;; # Not a pure number
                *) is_simple=1 ;; # It is a number
            esac
            
            case "$value" in
                On|Off|true|false) is_simple=1 ;;
            esac
            
            if [ "$is_simple" -eq 0 ]; then
                q_value="\"$value\""
            fi
            ;;
    esac

    echo "[+] Configuring [$section] $key = $q_value"
    # Use ! as the sed delimiter to safely handle / in URLs
    # Range is from [section] to the next [
    sed -i "/^\[$section\]/,/^\[/ s|^;*[[:space:]]*$key[[:space:]]*=.*|$key = $q_value|" config.inc.php
}

# Ensure config.inc.php exists
if [ ! -f config.inc.php ]; then
    echo "Creating config.inc.php from template..."
    cp config.TEMPLATE.inc.php config.inc.php
fi

# 1. Base Defaults
set_config "general" "installed" "On"
set_config "general" "restful_urls" "On"
set_config "general" "display_errors" "Off"
set_config "general" "show_stacktrace" "Off"
set_config "general" "trust_x_forwarded_for" "On"
set_config "security" "force_ssl" "On"
set_config "security" "force_login_ssl" "On"
set_config "files" "files_dir" "/var/www/ojs-files"

# 2. Database Defaults (Using standard OJS_DB_ env vars)
set_config "database" "driver" "${OJS_DB_DRIVER:-postgres}"
set_config "database" "host" "${OJS_DB_HOST}"
set_config "database" "port" "${OJS_DB_PORT:-5432}"
set_config "database" "username" "${OJS_DB_USER}"
set_config "database" "password" "${OJS_DB_PASSWORD}"
set_config "database" "name" "${OJS_DB_NAME}"

# 3. Dynamic OJSCONFIG_ variables
# We use 'env' and filter. 
env | grep "^OJSCONFIG_" | while read -r line; do
    # line is "OJSCONFIG_SECTION_KEY=value"
    clean_line=${line#OJSCONFIG_}
    c_key_full=${clean_line%%=*}
    c_value=${clean_line#*=}
    
    # We expect OJSCONFIG_SECTION_KEY_SUBKEY...
    c_section=$(echo "$c_key_full" | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    c_key=$(echo "$c_key_full" | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    
    set_config "$c_section" "$c_key" "$c_value"
done

# 4. Explicit Overrides for critical settings (to be double sure)
# Even if they were caught in the loop above, we re-apply them here.
echo "Running Explicit Overrides..."
set_config "general" "allowed_hosts" "${OJSCONFIG_GENERAL_ALLOWED_HOSTS}"
set_config "security" "salt" "${OJSCONFIG_SECURITY_SALT}"
set_config "security" "api_key_secret" "${OJSCONFIG_SECURITY_API_KEY_SECRET}"
set_config "email" "dmarc_compliant_from_displayname" "${OJSCONFIG_EMAIL_DMARC_COMPLIANT_FROM_DISPLAYNAME}"
set_config "email" "require_validation" "${OJSCONFIG_EMAIL_REQUIRE_VALIDATION}"
set_config "schedule" "task_runner" "${OJSCONFIG_SCHEDULE_TASK_RUNNER}"
set_config "oai" "repository_id" "${OJSCONFIG_OAI_REPOSITORY_ID}"

# 5. Anti-Spam / DMARC Compliance
if [ -n "$OJSCONFIG_EMAIL_SMTP_USERNAME" ]; then
    set_config "email" "allow_envelope_sender" "On"
    set_config "email" "default_envelope_sender" "$OJSCONFIG_EMAIL_SMTP_USERNAME"
    set_config "email" "force_default_envelope_sender" "On"
    set_config "email" "force_dmarc_compliant_from" "On"
fi

# 6. PKP_CONF_ style (Standard PKP convention)
env | grep "^PKP_CONF_" | while read -r line; do
    clean_line=${line#PKP_CONF_}
    c_key_full=${clean_line%%=*}
    c_value=${clean_line#*=}
    c_section=$(echo "$c_key_full" | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    c_key=$(echo "$c_key_full" | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    set_config "$c_section" "$c_key" "$c_value"
done

# 7. Fallback for OJS_BASE_URL
if [ -n "$OJS_BASE_URL" ] && [ -z "$PKP_CONF_GENERAL_BASE_URL" ]; then
    set_config "general" "base_url" "$OJS_BASE_URL"
fi

# 8. APP_KEY Generation
if ! grep -q "app_key = .*" config.inc.php || [ -z "$(grep "app_key =" config.inc.php | cut -d'=' -f2 | xargs)" ]; then
    APP_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    echo "Generated new app_key"
    sed -i "s/app_key =.*/app_key = $APP_KEY/" config.inc.php
fi

# Permissions fix
chown -R www-data:www-data /var/www/html /var/www/ojs-files public/ plugins/ cache/
chmod -R 775 /var/www/html /var/www/ojs-files public/ plugins/ cache/

echo "--- Configuration Ready ---"
exec "$@"
