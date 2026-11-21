#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
M="mysql -h192.168.1.245 -utcn_wp -p$PW -D techaddict_wp -N"
echo "users by year:"
$M -e "SELECT YEAR(user_registered), COUNT(*) FROM wp_users GROUP BY YEAR(user_registered) ORDER BY 1;" 2>/dev/null
echo "users before 2022:"
$M -e "SELECT COUNT(*) FROM wp_users WHERE user_registered < '2022-01-01';" 2>/dev/null
echo "post/comment authors:"
$M -e "SELECT DISTINCT post_author FROM wp_posts WHERE post_author > 0;" 2>/dev/null
$M -e "SELECT DISTINCT user_id FROM wp_comments WHERE user_id > 0;" 2>/dev/null
echo "usermeta rows:"
$M -e "SELECT COUNT(*) FROM wp_usermeta;" 2>/dev/null
echo "=== other WP core checks"
for d in /var/www/reforme.ro/html /var/www/adelina.party/html; do
	[ -f "$d/wp-config.php" ] || continue
	echo "-- $d"
	timeout 90 sudo -u www-data wp --path="$d" core verify-checksums 2>&1 | tail -1
done
