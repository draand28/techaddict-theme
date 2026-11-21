#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
SUDO="sudo -u www-data wp --path=$PWD"
echo "=== WP users"
$SUDO user list --fields=ID,user_login,user_email,user_registered 2>/dev/null | head -20
echo "=== WPForms entries (personal data likely)"
$SUDO db query "SHOW TABLES LIKE 'wp_wpforms%';" 2>/dev/null
$SUDO db query "SELECT COUNT(*) AS entries FROM wp_wpforms_entries;" 2>/dev/null || true
echo "=== phpBB private messages / users"
FPW=$(cd forum && php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -utcn_forum -p"$FPW" -D techaddict_phpbb -e "
SELECT COUNT(*) AS users FROM phpbb_users WHERE user_id > 1;
SELECT COUNT(*) AS privmsgs FROM phpbb_privmsgs;
SELECT COUNT(*) AS posts FROM phpbb_posts;" 2>/dev/null
echo "=== wp-mail-smtp credentials stored in DB"
mysql -h192.168.1.245 -utcn_wp -p"$($SUDO config get DB_PASSWORD 2>/dev/null)" -D techaddict_wp -e "
SELECT option_name FROM wp_options WHERE option_name LIKE 'wp_mail_smtp%' LIMIT 10;" 2>/dev/null
echo "=== MySQL binlogs"
PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
mysql -h192.168.1.245 -utcn_wp -p"$PW" -e "SHOW VARIABLES LIKE 'log_bin'; SHOW VARIABLES LIKE 'general_log'; SHOW VARIABLES LIKE 'secure_file_priv';" 2>/dev/null
echo "=== access logs mentioning the techaddict shells"
zgrep -hE 'rss-tec\.svg|wp-xmltec|wp-customize\.php|wp-intec\.php|mdudql' /var/log/apache2/*access*.log* 2>/dev/null | grep -i 'techaddict' | cut -c1-200 | head -10
echo "(lines found: $(zgrep -hcE 'rss-tec\.svg|wp-xmltec|wp-customize\.php|wp-intec\.php|mdudql' /var/log/apache2/*access*.log* 2>/dev/null | paste -sd+ | bc 2>/dev/null))"
echo "=== log files available"
ls -la /var/log/apache2/ | head -12
