#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
echo "=== wp-config lines 60-85"
sed -n '60,85p' wp-config.php
echo "=== constants"
grep -nE "DB_NAME|DB_USER|DB_PASSWORD|DB_HOST|table_prefix|WP_DEBUG|AUTH_KEY" wp-config.php | cut -c1-90
echo "=== wordpress install check"
php -r '
define("WP_USE_THEMES", false);
require "/var/www/techaddict.ro/html/wp-load.php";
echo "siteurl=", get_option("siteurl"), "\n";
echo "blogname=", get_option("blogname"), "\n";
echo "users=", count_users()["total_users"], "\n";
' 2>&1 | head -20
echo "=== apache errors"
tail -40 /var/log/apache2/error.log | grep -iE "techaddict|mysql|fatal|error" | tail -10
