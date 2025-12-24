# Clean URLs Setup Guide for OJS 3.5

This guide explains how to enable clean URLs in your OJS installation, transforming URLs from:
- `http://localhost:8000/index.php/index/index` 
- to: `http://localhost:8000/`

## ✅ What Was Configured

### 1. Created `.htaccess` File
A new `.htaccess` file has been created in the OJS root directory with:
- URL rewriting rules to remove `index.php`
- Security configurations to protect sensitive files
- Performance optimizations (compression, caching)
- Proper MIME types for static files

### 2. Updated `config.inc.php`
Changed the configuration setting:
```ini
restful_urls = On
```

## 🔧 Requirements

### Apache Requirements:
1. **mod_rewrite** must be enabled
2. **AllowOverride** must be set to allow `.htaccess` overrides

### Check if mod_rewrite is enabled:
```bash
# On Ubuntu/Debian
sudo a2enmod rewrite
sudo systemctl restart apache2

# Check if it's loaded
apache2ctl -M | grep rewrite
```

### For PHP Built-in Server (Development):
The built-in PHP server doesn't support `.htaccess` files. You need to use a router script instead:

```bash
# Instead of: php -S localhost:8000
# Use:
php -S localhost:8000 lib/pkp/router.php
```

Or create a custom router file:

```php
<?php
// router.php in OJS root
$path = $_SERVER["REQUEST_URI"];
if (preg_match('/\.(?:png|jpg|jpeg|gif|css|js|ico|svg|woff|woff2|ttf)$/', $path)) {
    return false; // serve the requested resource as-is
}
$_SERVER["PATH_INFO"] = $path;
include "index.php";
```

Then run:
```bash
php -S localhost:8000 router.php
```

## 🧪 Testing Clean URLs

### Test 1: Homepage
**Before**: `http://localhost:8000/index.php/index/index`  
**After**: `http://localhost:8000/`

### Test 2: Journal Pages
**Before**: `http://localhost:8000/index.php/journal-name/index`  
**After**: `http://localhost:8000/journal-name`

### Test 3: About Page
**Before**: `http://localhost:8000/index.php/journal-name/about`  
**After**: `http://localhost:8000/journal-name/about`

### Test 4: Article Page
**Before**: `http://localhost:8000/index.php/journal-name/article/view/123`  
**After**: `http://localhost:8000/journal-name/article/view/123`

## 🔍 Troubleshooting

### Issue 1: 404 Errors After Enabling Clean URLs

**Symptoms**: All pages return 404 errors

**Solutions**:
1. Check if mod_rewrite is enabled:
   ```bash
   apache2ctl -M | grep rewrite
   ```

2. Check Apache configuration for AllowOverride:
   ```apache
   # In your Apache config or VirtualHost
   <Directory /path/to/ojs>
       AllowOverride All
   </Directory>
   ```

3. Verify `.htaccess` is in the OJS root directory:
   ```bash
   ls -la /home/unix/git_repos/ojs/.htaccess
   ```

4. Check Apache error logs:
   ```bash
   tail -f /var/log/apache2/error.log
   ```

### Issue 2: Static Files Not Loading (CSS, JS, Images)

**Symptoms**: Pages load but without styling or images

**Solutions**:
1. Check the RewriteCond exclusions in `.htaccess`
2. Verify the RewriteBase is correct (should be `/` for root installation)
3. Clear browser cache
4. Check file permissions:
   ```bash
   chmod -R 755 /home/unix/git_repos/ojs/public
   chmod -R 755 /home/unix/git_repos/ojs/plugins
   ```

### Issue 3: Internal Server Error (500)

**Symptoms**: Server returns 500 error

**Solutions**:
1. Check Apache error logs for specific error messages
2. Verify PHP settings in `.htaccess` are compatible
3. Comment out the PHP settings section if needed:
   ```apache
   # <IfModule mod_php.c>
   #     ...
   # </IfModule>
   ```

### Issue 4: Clean URLs Work But Some Pages Don't

**Symptoms**: Homepage works but other pages don't

**Solutions**:
1. Make sure the RewriteBase matches your installation:
   - Root installation: `RewriteBase /`
   - Subdirectory: `RewriteBase /ojs/`

2. Clear OJS cache:
   ```bash
   rm -rf /home/unix/git_repos/ojs/cache/*.php
   rm -rf /home/unix/git_repos/ojs/cache/t_cache
   rm -rf /home/unix/git_repos/ojs/cache/t_compile
   ```

### Issue 5: URLs Still Show index.php

**Symptoms**: URLs work but still contain `index.php`

**Solutions**:
1. Verify `restful_urls = On` in `config.inc.php`
2. Clear template cache:
   ```bash
   rm -rf cache/t_*
   ```
3. Clear browser cache
4. Regenerate pages database:
   ```bash
   php tools/rebuildSearchIndex.php -d
   ```

## 📁 File Structure

```
/home/unix/git_repos/ojs/
├── .htaccess                 # NEW: URL rewriting rules
├── config.inc.php            # MODIFIED: restful_urls = On
├── index.php                 # OJS entry point
├── public/                   # Static files (not rewritten)
├── plugins/                  # Plugin files (not rewritten)
├── js/                       # JavaScript files (not rewritten)
├── styles/                   # CSS files (not rewritten)
└── cache/                    # Cache directory (protected)
```

## 🔒 Security Features in .htaccess

The `.htaccess` file includes several security enhancements:

1. **Disable Directory Browsing**: Prevents listing directory contents
2. **Protect Sensitive Files**: Blocks access to `.inc`, `.conf`, `.bak`, etc.
3. **Protect Configuration**: Restricts access to `config.inc.php`
4. **Protect Cache Directory**: Denies direct access to cached files

## ⚡ Performance Optimizations

The `.htaccess` file includes:

1. **GZIP Compression**: Compresses HTML, CSS, JS, JSON
2. **Browser Caching**: Sets cache headers for static assets
3. **Proper MIME Types**: Ensures correct content-type headers

## 🌐 Using with Nginx

If you're using Nginx instead of Apache, use this configuration:

```nginx
server {
    listen 80;
    server_name localhost;
    root /home/unix/git_repos/ojs;
    index index.php;

    location / {
        try_files $uri $uri/ @rewrite;
    }

    location @rewrite {
        rewrite ^/(.*)$ /index.php/$1 last;
    }

    location ~ \.php {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Protect sensitive files
    location ~ \.(inc|conf|bak|old|sql)$ {
        deny all;
    }

    # Allow access to public directories
    location ~* \.(jpg|jpeg|gif|png|css|js|ico|xml|svg|woff|woff2|ttf)$ {
        expires 1y;
        access_log off;
        add_header Cache-Control "public";
    }
}
```

## 🚀 Next Steps

After enabling clean URLs:

1. **Test all major pages** to ensure they work correctly
2. **Update bookmarks and links** if needed
3. **Update sitemap** (OJS will regenerate it automatically)
4. **Check Google Search Console** if you're indexed
5. **Update robots.txt** if custom rules exist

## 📚 URL Structure Reference

With clean URLs enabled, your OJS will use this structure:

### Site Level:
- Homepage: `/`
- Login: `/login`
- Register: `/user/register`

### Journal Level:
- Journal home: `/journal-name`
- About: `/journal-name/about`
- Archives: `/journal-name/issue/archive`
- Current issue: `/journal-name/issue/current`
- Specific issue: `/journal-name/issue/view/123`
- Article: `/journal-name/article/view/456`
- Search: `/journal-name/search`

### API:
- REST API: `/api/v1/...` (not affected by URL rewriting)

## 🔗 Additional Resources

- [OJS Documentation](https://docs.pkp.sfu.ca/)
- [OJS Admin Guide](https://docs.pkp.sfu.ca/admin-guide/)
- [Apache mod_rewrite Documentation](https://httpd.apache.org/docs/current/mod/mod_rewrite.html)

## ⚠️ Important Notes

1. **Backup First**: Always backup your installation before making configuration changes
2. **Test Thoroughly**: Test all functionality after enabling clean URLs
3. **Clear Cache**: Clear both OJS cache and browser cache after changes
4. **Monitor Logs**: Watch error logs for any issues after enabling

---

## Quick Command Reference

```bash
# Enable mod_rewrite (Ubuntu/Debian)
sudo a2enmod rewrite
sudo systemctl restart apache2

# Check if mod_rewrite is loaded
apache2ctl -M | grep rewrite

# Clear OJS cache
rm -rf cache/*.php cache/t_*

# Check Apache error logs
tail -f /var/log/apache2/error.log

# Test .htaccess syntax
apachectl configtest

# Fix file permissions
chmod 644 .htaccess
chmod 644 config.inc.php
```

