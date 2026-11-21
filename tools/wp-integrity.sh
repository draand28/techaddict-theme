#!/bin/bash
set -e
cd /var/www/techaddict.ro/html

# 24 GB of deprecation noise, already preserved inside the full backup tar
rm -f wp-content/debug.log
sed -i "s/define('WP_DEBUG_LOG', true);/define('WP_DEBUG_LOG', false);/" wp-config.php
sed -i "s/define('WP_DEBUG', true);/define('WP_DEBUG', false);/" wp-config.php

# WP-CLI for integrity checks
if ! command -v wp >/dev/null 2>&1; then
	curl -sS -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod 755 /usr/local/bin/wp
fi
wp --allow-root --version
echo "=== core checksums"
sudo -u www-data wp --path=/var/www/techaddict.ro/html core verify-checksums 2>&1 | tail -5
echo "=== plugin checksums"
sudo -u www-data wp --path=/var/www/techaddict.ro/html plugin verify-checksums --all 2>&1 | tail -15
echo "=== disk"
du -sh /var/www/techaddict.ro/html
grep -nE '^define\(.?WP_DEBUG' wp-config.php
