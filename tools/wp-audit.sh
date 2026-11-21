#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
echo "=== core version / integrity"
$S core version 2>/dev/null
$S core verify-checksums 2>/dev/null | tail -1
echo "=== admins"
$S user list --role=administrator --fields=ID,user_login,user_email 2>/dev/null
echo "=== registration"
$S option get users_can_register 2>/dev/null
$S option get default_role 2>/dev/null
echo "=== cron"
$S cron event list --fields=hook,next_run_relative 2>/dev/null | head -20
echo "=== application passwords"
$S user meta list 1 --keys=_application_passwords --format=table 2>/dev/null | head
echo "=== remaining suspicious php (wp-content)"
grep -rlnE '\b(eval|assert|create_function)[[:space:]]*\(.*\$_(POST|GET|REQUEST|COOKIE)|base64_decode[[:space:]]*\(.*\$_(POST|GET|REQUEST|COOKIE)' wp-content --include='*.php' 2>/dev/null | head -10
echo "=== dot-php outside core"
find . -path ./forum -prune -o -type f -name '.*.php' -print 2>/dev/null | head
echo "=== smarthome references"
mysql -N -h192.168.1.245 -u"$(grep -o "define( *'DB_USER' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")" \
	-p"$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")" \
	techaddict_wp -e "select count(*) from wp_posts where post_content like '%smarthome%';" 2>/dev/null
ls -la .well-known 2>/dev/null
