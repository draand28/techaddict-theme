#!/bin/bash
# Inventory: which live configs use the shared draand28 account, and which DBs.
echo "=== /var/www live configs"
for f in \
	/var/www/techaddict.ro/html/wp-config.php \
	/var/www/techaddict.ro/html/forum/config.php \
	/var/www/reforme.ro/html/wp-config.php \
	/var/www/adelina.party/html/wp-config.php \
	/var/www/nubis.ro/html/config.php \
	/var/www/terracactus.net/html/config.php \
	/var/www/ciprian.party/html/paneltcn/.env ; do
	[ -f "$f" ] || continue
	echo "-- $f"
	grep -aoE "DB_NAME[^,;]*|DB_USER[^,;]*|DB_DATABASE[^ ]*|DB_USERNAME[^ ]*|\\\$dbname[^;]*|\\\$dbuser[^;]*" "$f" 2>/dev/null | sed 's/=.*/= <set>/' | head -8
done
