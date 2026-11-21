#!/bin/bash
set -e
P=/var/www/techaddict.ro/html/wp-content/plugins/wp-piwik
Q=/root/techaddict-cleanup/quarantine
mkdir -p "$Q"
cd "$P"
[ -f libs/matomo-php-tracker/Seo.php ] && mv libs/matomo-php-tracker/Seo.php "$Q/wp-piwik-Seo.php"
[ -f proxy/StorageCountry.php ] && mv proxy/StorageCountry.php "$Q/wp-piwik-StorageCountry.php"
cd /var/www/techaddict.ro/html
sudo -u www-data wp --path="$PWD" plugin verify-checksums wp-piwik 2>&1 | tail -2
echo "=== updates"
sudo -u www-data wp --path="$PWD" core check-update 2>&1 | tail -3
sudo -u www-data wp --path="$PWD" plugin list --update=available --fields=name,version,update_version 2>&1 | tail -20
echo "=== marker in IPB backup"
grep -n 'wp-xmltec\|rss-tec\|mdudql\|e9b41d635eb83057eedb535bdd6d5456' /var/www/techaddict_forum_ipb_backup/applications/blog/setup/index.php 2>/dev/null | head -3
