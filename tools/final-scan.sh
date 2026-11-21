#!/bin/bash
echo "=== served trees: known malware markers"
grep -rl 'rss-tec\|wp-xmltec\|mdudql\|lqxuta\|wp-intec\|wp-customize\|options-fafjqn\|ms-dbaltr\|elyqpn\|eojgsa\|lopbvy\|lwgztx' \
	/var/www/*.ro/html /var/www/*.net/html /var/www/*.party/html /var/www/*.com/html /var/www/nubis.ro/html 2>/dev/null | head -20
echo
echo "=== access-log hits on removed shells"
grep -hE 'wp-(customize|xmltec|xmlrpc|intec)\.php|mdudql|rss-tec\.svg|options-fafjqn|ms-dbaltr|elyqpn|eojgsa|lopbvy|lwgztx' /var/log/apache2/*access*.log 2>/dev/null | wc -l
grep -hoE '^[0-9.]+' /var/log/apache2/*access*.log 2>/dev/null | sort | uniq -c | sort -rn | head -5
echo
echo "=== WordPress admins per site"
for d in /var/www/*/html /var/www/*/*/html; do
	[ -f "$d/wp-config.php" ] || continue
	echo "-- $d"
	sudo -u www-data wp --path="$d" user list --role=administrator --fields=user_login,user_email 2>/dev/null | tail -n +2 | head -5
done
