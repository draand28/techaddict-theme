#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
echo "=== config"
grep -nE "AUTOMATIC_UPDATER_DISABLED|DISALLOW_FILE_MODS|DISALLOW_FILE_EDIT|WP_DEBUG" wp-config.php
echo "=== checksums"
$S core verify-checksums 2>/dev/null | tail -1
for p in $($S plugin list --field=name 2>/dev/null); do
	$S plugin verify-checksums "$p" --quiet >/dev/null 2>&1 || echo "FAIL plugin $p"
done
echo "=== content"
$S plugin list --status=active --fields=name,version 2>/dev/null
$S theme list --fields=name,status 2>/dev/null
$S option get permalink_structure 2>/dev/null
echo "=== http"
for u in https://techaddict.ro/ https://techaddict.ro/forum/ https://techaddict.ro/wp-login.php https://techaddict.ro/wp-json/ https://techaddict.ro/wp-sitemap.xml https://techaddict.ro/xmlrpc.php; do
	curl -s -o /dev/null -w "%{http_code} $u\n" "$u"
done
