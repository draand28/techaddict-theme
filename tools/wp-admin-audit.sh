#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
echo "=== core"
$S core version 2>/dev/null
$S core check-update 2>/dev/null | tail -3
echo "=== plugins"
$S plugin list --fields=name,status,version,update,update_version 2>/dev/null
echo "=== themes"
$S theme list --fields=name,status,version,update,update_version 2>/dev/null
echo "=== users"
$S user list --fields=ID,user_login,roles --format=csv 2>/dev/null | head -5
$S user list --role=administrator --fields=ID,user_login,user_email 2>/dev/null
echo "=== options"
for o in siteurl home admin_email users_can_register default_role blog_public permalink_structure timezone_string default_pingback_flag default_ping_status default_comment_status comment_moderation comment_registration require_name_email; do
	printf "%s = " "$o"; $S option get "$o" 2>/dev/null | head -1
done
echo "=== cron hooks"
$S cron event list --fields=hook,next_run_relative 2>/dev/null | head -30
echo "=== comments"
$S comment list --status=hold --format=count 2>/dev/null
$S comment list --status=spam --format=count 2>/dev/null
$S comment list --status=approve --format=count 2>/dev/null
echo "=== transients / autoload"
$S transient list --format=count 2>/dev/null
$S db query "SELECT SUM(LENGTH(option_value)) AS autoload_bytes FROM wp_options WHERE autoload='yes';" 2>/dev/null
echo "=== orphans"
$S db query "SELECT COUNT(*) AS orphan_usermeta FROM wp_usermeta m LEFT JOIN wp_users u ON u.ID=m.user_id WHERE u.ID IS NULL;" 2>/dev/null
$S db query "SELECT COUNT(*) AS orphan_postmeta FROM wp_postmeta m LEFT JOIN wp_posts p ON p.ID=m.post_id WHERE p.ID IS NULL;" 2>/dev/null
echo "=== config constants"
grep -nE "DISALLOW_FILE_EDIT|WP_DEBUG|FORCE_SSL_ADMIN|AUTOMATIC_UPDATER|DISALLOW_FILE_MODS|WP_AUTO_UPDATE" wp-config.php
echo "=== permissions"
stat -c '%a %U:%G %n' wp-config.php wp-content wp-content/uploads wp-content/plugins .htaccess
echo "=== htaccess"
cat .htaccess
