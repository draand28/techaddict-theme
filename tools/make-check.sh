#!/bin/bash
set -e
F=/var/www/techaddict.ro/html/ta-check.php
cat > "$F" <<'PHP'
<?php
require __DIR__ . '/wp-load.php';
header('Content-Type: application/json');
echo json_encode(array(
	'is_ssl' => is_ssl(),
	'HTTPS' => isset($_SERVER['HTTPS']) ? $_SERVER['HTTPS'] : null,
	'SERVER_PORT' => isset($_SERVER['SERVER_PORT']) ? $_SERVER['SERVER_PORT'] : null,
	'HTTP_X_FORWARDED_PROTO' => isset($_SERVER['HTTP_X_FORWARDED_PROTO']) ? $_SERVER['HTTP_X_FORWARDED_PROTO'] : null,
	'HTTP_HOST' => isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : null,
	'home' => home_url(),
	'siteurl' => site_url(),
	'force_ssl_admin' => defined('FORCE_SSL_ADMIN') ? FORCE_SSL_ADMIN : null,
));
PHP
chown www-data:www-data "$F"
chmod 644 "$F"
echo "written $(wc -c < "$F") bytes"
