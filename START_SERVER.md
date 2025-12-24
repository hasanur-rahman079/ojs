# Starting OJS with Clean URLs

## 🚀 Quick Start

Since you're using `localhost:8000`, you're likely using the PHP built-in development server. Here's how to enable clean URLs:

### Option 1: Using the Router Script (Recommended for Development)

```bash
cd /home/unix/git_repos/ojs
php -S localhost:8000 router.php
```

This will start the server with clean URLs enabled!

### Option 2: Using Apache

If you're using Apache, the `.htaccess` file will handle everything automatically. Just make sure:

1. **mod_rewrite is enabled**:
   ```bash
   sudo a2enmod rewrite
   sudo systemctl restart apache2
   ```

2. **Virtual host or directory has AllowOverride set**:
   ```apache
   <Directory /home/unix/git_repos/ojs>
       AllowOverride All
   </Directory>
   ```

## ✅ What's Configured

- ✅ `.htaccess` created with rewrite rules
- ✅ `config.inc.php` updated (`restful_urls = On`)
- ✅ `router.php` created for PHP built-in server

## 🧪 Test Your URLs

After starting the server, test these URLs:

### Before (Old URLs with index.php):
- ❌ `http://localhost:8000/index.php/index/index`
- ❌ `http://localhost:8000/index.php/journal-name/about`
- ❌ `http://localhost:8000/index.php/journal-name/article/view/123`

### After (Clean URLs):
- ✅ `http://localhost:8000/`
- ✅ `http://localhost:8000/journal-name/about`
- ✅ `http://localhost:8000/journal-name/article/view/123`

## 📋 Full Example

```bash
# Navigate to OJS directory
cd /home/unix/git_repos/ojs

# Clear cache (recommended)
rm -rf cache/*.php cache/t_*

# Start server with clean URLs
php -S localhost:8000 router.php

# Open in browser
# http://localhost:8000/
```

## 🔧 Troubleshooting

### Problem: URLs still show index.php

**Solution**: Make sure you're using `router.php`:
```bash
php -S localhost:8000 router.php
```

### Problem: Static files (CSS, JS) not loading

**Solution**: The router is configured to serve static files. Make sure the files exist and check permissions:
```bash
chmod -R 755 public/ plugins/ js/ styles/
```

### Problem: 404 errors on all pages

**Solution**: 
1. Clear cache: `rm -rf cache/*.php cache/t_*`
2. Restart the server
3. Check that `restful_urls = On` in `config.inc.php`

## 🌐 Production Deployment

For production, use Apache or Nginx instead of the PHP built-in server:

### Apache Configuration:
The `.htaccess` file is already configured. Just ensure:
- mod_rewrite is enabled
- AllowOverride is set to All

### Nginx Configuration:
See `CLEAN_URLS_SETUP.md` for Nginx configuration example.

## 📚 More Information

See `CLEAN_URLS_SETUP.md` for detailed documentation including:
- Complete troubleshooting guide
- Security features
- Performance optimizations
- Nginx configuration
- URL structure reference

---

## Quick Commands

```bash
# Start with clean URLs (Development)
php -S localhost:8000 router.php

# Start without clean URLs (Old way)
php -S localhost:8000

# Check if router exists
ls -l router.php

# Clear cache
rm -rf cache/*.php cache/t_*

# Check config
grep "restful_urls" config.inc.php
```

