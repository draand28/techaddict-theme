#!/bin/bash
set -e
W=/var/www/techaddict.ro/html
Q=/root/techaddict-cleanup/quarantine
cd "$W"
S="sudo -u www-data wp --path=$W"

# Allow WordPress to install updates/plugins again; keep the file editor disabled
if grep -q "define('DISALLOW_FILE_MODS', true);" wp-config.php; then
	sed -i "/define('DISALLOW_FILE_MODS', true);/d" wp-config.php
fi
chown www-data:www-data wp-config.php
chmod 640 wp-config.php

# Updates
$S plugin update disable-wp-new-user-notification 2>&1 | tail -2 || true
$S theme update twentytwenty 2>&1 | tail -2 || true

# Retire abandoned or risky plugins (reversible: files are quarantined)
for p in google-sitemap-generator ssh-sftp-updater-support who-stole-the-text-justify-button; do
	$S plugin deactivate "$p" 2>&1 | tail -1 || true
done
mkdir -p "$Q"
for p in google-sitemap-generator ssh-sftp-updater-support who-stole-the-text-justify-button wp-piwik hello-dolly; do
	if [ -d "$W/wp-content/plugins/$p" ]; then
		mv "$W/wp-content/plugins/$p" "$Q/$p-plugin"
		echo "quarantined $p"
	fi
done

# Settings that reduce spam and notification noise
$S option update default_pingback_flag 0 >/dev/null
$S option update default_ping_status closed >/dev/null
$S option update comment_moderation 1 >/dev/null
$S option update timezone_string Europe/Bucharest >/dev/null
$S transient delete --expired >/dev/null 2>&1 || true

# Drop cron hooks whose plugins are gone
for h in jetpack_clean_nonces jetpack_v2_heartbeat jp_purge_transients_cron sm_ping_daily; do
	$S cron event delete "$h" >/dev/null 2>&1 || true
done

echo "=== active plugins"
$S plugin list --status=active --fields=name,version 2>/dev/null

echo "=== checks"
$S option get default_pingback_flag 2>/dev/null
$S option get default_ping_status 2>/dev/null
$S option get comment_moderation 2>/dev/null
$S option get timezone_string 2>/dev/null
stat -c '%a %U:%G %n' wp-config.php
curl -s -o /dev/null -w 'wp %{http_code}\n' https://techaddict.ro/
curl -s -o /dev/null -w 'sitemap %{http_code}\n' https://techaddict.ro/wp-sitemap.xml
