<?php

/**
 * @file router.php
 *
 * Router for PHP built-in web server (for development only)
 *
 * This file enables clean URLs when using the PHP built-in server.
 * The built-in server doesn't support .htaccess, so we need this router.
 *
 * Usage:
 *   php -S localhost:8000 router.php
 *
 * DO NOT use this in production. Use Apache or Nginx with proper configuration.
 */

// Get the requested URI
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Serve static files directly
if (preg_match('/\.(?:png|jpg|jpeg|gif|css|js|ico|xml|json|svg|woff|woff2|ttf|eot|otf|map|pdf|txt|md)$/i', $path)) {
    // Check if file exists
    $filePath = __DIR__ . $path;
    if (file_exists($filePath)) {
        return false; // Let PHP built-in server serve it
    }
}

// Special handling for certain paths
if ($path === '/') {
    $_SERVER['PATH_INFO'] = '/';
} else {
    // Remove trailing slash if present
    $path = rtrim($path, '/');
    $_SERVER['PATH_INFO'] = $path;
}

// Set script name for OJS routing
$_SERVER['SCRIPT_NAME'] = '/index.php';

// Include the main OJS index file
require __DIR__ . '/index.php';
