#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
M="mysql -h192.168.1.245 -utcn_wp -p$PW -D techaddict_wp -N"
echo "wp_users:"
$M -e "SELECT COUNT(*) FROM wp_users;" 2>/dev/null
echo "first/last registration:"
$M -e "SELECT MIN(user_registered), MAX(user_registered) FROM wp_users;" 2>/dev/null
echo "administrators:"
$M -e "SELECT COUNT(*) FROM wp_usermeta WHERE meta_key='wp_capabilities' AND meta_value LIKE '%administrator%';" 2>/dev/null
echo "subscribers (approx):"
$M -e "SELECT COUNT(*) FROM wp_usermeta WHERE meta_key='wp_capabilities' AND meta_value LIKE '%subscriber%';" 2>/dev/null
echo "users before 2026-11-01:"
$M -e "SELECT COUNT(*) FROM wp_users WHERE user_registered < '2026-11-01';" 2>/dev/null
echo "comments / posts:"
$M -e "SELECT COUNT(*) FROM wp_comments;" 2>/dev/null
$M -e "SELECT post_type, COUNT(*) FROM wp_posts GROUP BY post_type;" 2>/dev/null
echo "spam-looking logins:"
$M -e "SELECT COUNT(*) FROM wp_users WHERE user_login LIKE 'TRADE %';" 2>/dev/null
echo "real-looking accounts (registered before 2024):"
$M -e "SELECT ID,user_login,user_email,user_registered FROM wp_users WHERE user_registered < '2024-01-01' ORDER BY ID LIMIT 10;" 2>/dev/null
echo "db size:"
$M -e "SELECT table_schema, ROUND(SUM(data_length+index_length)/1024/1024) AS mb FROM information_schema.tables WHERE table_schema='techaddict_wp' GROUP BY table_schema;" 2>/dev/null
echo "phpbb users by type:"
cd forum || exit 1
FPW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -utcn_forum -p"$FPW" -D techaddict_phpbb -e "SELECT user_type, COUNT(*) FROM phpbb_users GROUP BY user_type;" 2>/dev/null
