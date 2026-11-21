#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
M="mysql -h192.168.1.245 -utcn_wp -p$PW -D techaddict_wp"
echo "=== WP users"
$M -e "SELECT ID,user_login,user_email,user_registered FROM wp_users ORDER BY ID;" 2>/dev/null
echo "=== WPForms tables and entries"
$M -e "SHOW TABLES LIKE 'wp_wpforms%';" 2>/dev/null
$M -e "SELECT COUNT(*) AS entries FROM wp_wpforms_entries;" 2>/dev/null
echo "=== Mail SMTP options (names only)"
$M -e "SELECT option_name FROM wp_options WHERE option_name LIKE 'wp_mail_smtp%' LIMIT 12;" 2>/dev/null
echo "=== phpBB counts"
cd forum || exit 1
FPW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -utcn_forum -p"$FPW" -D techaddict_phpbb -e "
SELECT COUNT(*) AS users FROM phpbb_users WHERE user_id > 1;
SELECT COUNT(*) AS privmsgs FROM phpbb_privmsgs;
SELECT COUNT(*) AS posts FROM phpbb_posts;" 2>/dev/null
echo "=== MySQL logging"
cd ..
mysql -h192.168.1.245 -utcn_wp -p"$PW" -e "SHOW VARIABLES LIKE 'log_bin'; SHOW VARIABLES LIKE 'general_log'; SHOW VARIABLES LIKE 'secure_file_priv';" 2>/dev/null
echo "=== shell URL hits in current access log"
grep -cE 'rss-tec\.svg|wp-xmltec|wp-customize\.php|wp-intec\.php|mdudql' /var/log/apache2/access.log 2>/dev/null
echo "=== log files"
ls -la /var/log/apache2/ | head -12
