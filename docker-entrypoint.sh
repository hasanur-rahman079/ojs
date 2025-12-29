#!/bin/bash
set -e

# --- 1. DIAGNOSTICS & LOGGING ---
echo "--- Starting OJS Configuration Management ---"
echo "Shell: $SHELL"

# Function to safely check and log environment variables
check_var() {
    local var_name="$1"
    local val=$(eval echo "\$$var_name")
    if [ -n "$val" ]; then
        echo "[FOUND] $var_name is present (Length: ${#val})"
    else
        echo "[MISSING] $var_name is not in the environment."
    fi
}

echo "--- Diagnostic Check ---"
check_var "OJSCONFIG_GENERAL_ALLOWED_HOSTS"
check_var "OJSCONFIG_SECURITY_SALT"
check_var "OJSCONFIG_EMAIL_DMARC_COMPLIANT_FROM_DISPLAYNAME"
check_var "OJS_DB_PASSWORD"
echo "--------------------------"

# --- 2. THE NEW set_config (POSIX COMPLIANT & SMART) ---
set_config() {
    local section="$1"
    local key="$2"
    local raw_value="$3"
    
    if [ -z "$raw_value" ]; then
        return
    fi

    # 1. Clean the value (remove outer quotes if they leaked from Dokploy)
    local value=$(echo "$raw_value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^["'\'']//' -e 's/["'\'']$//')
    
    # 2. Determine quoting style
    local q_value="$value"
    
    # Special Case: JSON Lists (like allowed_hosts) should use SINGLE quotes for INI compatibility
    if echo "$value" | grep -q "\[.*\]"; then
        q_value="'$value'"
    else
        case "$value" in
            On|Off|true|false) ;; # Booleans: no quotes
            [0-9]*) # Pure Numbers: no quotes
                case "$value" in
                    *[!0-9]*) q_value="\"$value\"" ;; # Has non-digits
                    *) ;;
                esac
                ;;
            *) q_value="\"$value\"" ;; # Strings: double quotes
        esac
    fi

    echo "  [+] Setting $key = $q_value in [$section]"
    # Use ! as delimiter to handle paths/URLs safely
    sed -i "/^\[$section\]/,/^\[/ s|^;*[[:space:]]*$key[[:space:]]*=.*|$key = $q_value|" config.inc.php
}

# Ensure config file exists
if [ ! -f config.inc.php ]; then
    echo "Creating config.inc.php from template..."
    cp config.TEMPLATE.inc.php config.inc.php
fi

# --- 3. APPLY CORE OVERRIDES ---
echo "--- Applying Core Configuration ---"
set_config "general" "installed" "On"
set_config "general" "restful_urls" "On"
set_config "general" "display_errors" "Off"
set_config "general" "show_stacktrace" "Off"
set_config "general" "trust_x_forwarded_for" "On"

set_config "database" "driver" "${OJS_DB_DRIVER:-postgres}"
set_config "database" "host" "${OJS_DB_HOST}"
set_config "database" "port" "${OJS_DB_PORT:-5432}"
set_config "database" "username" "${OJS_DB_USER}"
set_config "database" "password" "${OJS_DB_PASSWORD}"
set_config "database" "name" "${OJS_DB_NAME}"

# --- 4. APPLY DYNAMIC OJSCONFIG_ VARIABLES ---
# We use a temp file to avoid subshell issues with while read
env | grep "^OJSCONFIG_" > /tmp/env_vars || true
while read -r var_line; do
    [ -z "$var_line" ] && continue
    clean_line=${var_line#OJSCONFIG_}
    key_part=${clean_line%%=*}
    val_part=${clean_line#*=}
    
    section=$(echo "$key_part" | cut -d'_' -f1 | tr '[:upper:]' '[:lower:]')
    key=$(echo "$key_part" | cut -d'_' -f2- | tr '[:upper:]' '[:lower:]')
    
    set_config "$section" "$key" "$val_part"
done < /tmp/env_vars

# --- 5. EXPLICIT FALLBACKS (Ensure critical settings are NEVER missed) ---
echo "--- Running Explicit Overrides ---"
set_config "general" "allowed_hosts" "$OJSCONFIG_GENERAL_ALLOWED_HOSTS"
set_config "general" "base_url" "${OJS_BASE_URL:-$PKP_CONF_GENERAL_BASE_URL}"
set_config "security" "salt" "$OJSCONFIG_SECURITY_SALT"
set_config "security" "api_key_secret" "$OJSCONFIG_SECURITY_API_KEY_SECRET"
set_config "email" "dmarc_compliant_from_displayname" "$OJSCONFIG_EMAIL_DMARC_COMPLIANT_FROM_DISPLAYNAME"
set_config "email" "require_validation" "$OJSCONFIG_EMAIL_REQUIRE_VALIDATION"
set_config "schedule" "task_runner" "$OJSCONFIG_SCHEDULE_TASK_RUNNER"
set_config "oai" "repository_id" "$OJSCONFIG_OAI_REPOSITORY_ID"

# --- 6. CLEANUP & PERMISSIONS ---
# Generate APP_KEY if empty
if ! grep -q "app_key = .*" config.inc.php || [ -z "$(grep "app_key =" config.inc.php | cut -d'=' -f2 | xargs)" ]; then
    APP_KEY=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)
    echo "Generated new app_key"
    sed -i "s/app_key =.*/app_key = $APP_KEY/" config.inc.php
fi

chown -R www-data:www-data /var/www/html /var/www/ojs-files public/ plugins/ cache/
chmod -R 775 /var/www/html /var/www/ojs-files public/ plugins/ cache/

echo "--- OJS Configuration Ready ---"
exec "$@"
