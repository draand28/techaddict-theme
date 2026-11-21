#!/bin/bash
set -e
W=/var/www/techaddict.ro/html
Q=/root/techaddict-cleanup/quarantine
cd "$W"
S="sudo -u www-data wp --path=$W"

# Remove the abandoned plugin whose update fails (notifications are handled by WP)
$S plugin deactivate disable-wp-new-user-notification 2>&1 | tail -1 || true
mkdir -p "$Q"
[ -d "$W/wp-content/plugins/disable-wp-new-user-notification" ] && mv "$W/wp-content/plugins/disable-wp-new-user-notification" "$Q/disable-wp-new-user-notification-plugin"

# Clean permalinks: the /index.php/ prefix broke REST and sitemaps
$S option update permalink_structure '/%postname%/' >/dev/null
$S rewrite flush --hard >/dev/null

echo "permalink: $($S option get permalink_structure 2>/dev/null)"
curl -s -o /dev/null -w 'home %{http_code}\n' https://techaddict.ro/
curl -s -o /dev/null -w 'sitemap %{http_code}\n' https://techaddict.ro/wp-sitemap.xml
curl -s -o /dev/null -w 'rest %{http_code}\n' https://techaddict.ro/wp-json/
