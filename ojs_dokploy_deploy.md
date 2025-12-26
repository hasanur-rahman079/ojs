# Deploying OJS 3.5 to Dokploy with External PostgreSQL

This guide provides a step-by-step walkthrough and technical reference for deploying Open Journal Systems (OJS) 3.5.0 on the Dokploy platform, integrated with an external PostgreSQL database. 

## 🏗️ Architecture Overview

- **App Server**: Dokploy (Docker on Ubuntu)
- **Base Image**: `php:8.3-apache`
- **Database**: External PostgreSQL (Managed or standalone)
- **Reverse Proxy**: Dokploy (Traefik/Nginx) with SSL termination

---

## 🛠️ Step 1: Dockerfile Preparation

OJS 3.5 requires specific PHP extensions and a Node.js build step for modern UI components.

### Essential Extensions
You must include `pdo_pgsql` and `pgsql` for database connectivity.
```dockerfile
RUN apt-get update && apt-get install -y libpq-dev postgresql-client
RUN docker-php-ext-install pdo_pgsql pgsql
```

### Apache Configuration
To support **Clean URLs** and correct **HTTPS detection** behind the Dokploy proxy, use this configuration:
```dockerfile
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
```

---

## ⚙️ Step 2: Runtime Configuration (`docker-entrypoint.sh`)

OJS stores configuration in a static `config.inc.php` file. To make it "Docker-ready," we use a startup script to inject environment variables.

### Key Features of the Entrypoint:
1.  **Strict Quoting**: Values like `base_url` or email strings **must** be wrapped in double quotes in `config.inc.php`. Numbers and Booleans (`On`/`Off`) should not be quoted.
2.  **Case Transformation**: Converts `OJSCONFIG_SECTION_KEY` to `[section] key = value`.
3.  **Permissions**: Ensures `www-data` owns the `public/` and `cache/` directories.

---

## 🔑 Step 3: Deployment & Environmental Variables

In the **Dokploy Environment Tab**, set the following variables:

### Database
- `OJS_DB_HOST`: Your database IP or hostname.
- `OJS_DB_PORT`: `5433` (or your custom port).
- `OJS_DB_USER`: `emspubadmin`
- `OJS_DB_PASSWORD`: Your password.
- `OJS_DB_NAME`: `ojs_db`

### Email (Anti-Spam/DMARC)
To prevent emails from going to spam, we use a "No-Reply" strategy:
- `OJSCONFIG_EMAIL_DEFAULT=smtp`
- `OJSCONFIG_EMAIL_SMTP_SERVER=mail.yourdomain.com`
- `OJSCONFIG_EMAIL_SMTP_PORT=465`
- `OJSCONFIG_EMAIL_SMTP_AUTH=ssl`
- `OJSCONFIG_EMAIL_SMTP_USERNAME=noreply@yourdomain.com`

---

## 🆘 Troubleshooting & Common Errors

### 1. The "Installer Port" Workaround
**Error**: Installer defaults to port `5432` even if configured otherwise.
**Solution**: During the web installation form, manually enter the host as `IP:Port` (e.g., `72.61.117.6:5433`). The web form overrides the config file during installation.

### 2. Broken CSS / Styles
**Error**: Site looks like plain text; browser shows 404 for CSS files.
**Solution**: This is usually caused by invalid syntax in `config.inc.php` (missing quotes on `base_url`) or Apache's `MultiViews` option interfering with cleaner routes. Ensure `Options -MultiViews` is set in Apache.

### 3. Emails in Spam
**Error**: Emails are sent "from" the user's Gmail/Outlook address, failing SPF/DMARC checks.
**Solution**: Enable these settings in `config.inc.php` (handled automatically by our script if `OJSCONFIG` is set):
- `force_default_envelope_sender = On`
- `force_dmarc_compliant_from = On`
This makes the authorized `noreply@` the technical sender while keeping the user's name as the display sender.

### 4. Upload Directory Permissions
**Error**: "The directory specified for uploaded files does not exist or is not writable."
**Solution**: The upload directory (default: `/var/www/ojs-files`) must be **outside** the web root and owned by `www-data`.
```bash
mkdir -p /var/www/ojs-files && chown -R www-data:www-data /var/www/ojs-files
```

---

## 🏁 Final Check
Once deployed, check your Dokploy logs for the `--- Environment Check ---` section. If your variables are listed there and the site loads with styles, your deployment is successful!

---
*Created by Antigravity AI for Advanced OJS Deployments.*
