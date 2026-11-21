#!/bin/bash
set -e
SITE=/var/www/techaddict.ro/html
cd "$SITE"

# Quarantine the unreferenced sensor demo (not part of WP or phpBB)
if [ -d smarthome ]; then
	mkdir -p /root/techaddict-cleanup/quarantine
	mv smarthome /root/techaddict-cleanup/quarantine/smarthome
fi

# Close open registration
sudo -u www-data wp --path="$SITE" option update users_can_register 0 2>&1 | tail -1
sudo -u www-data wp --path="$SITE" option get users_can_register 2>&1 | tail -1

# New auth salts: logs out every WordPress session and invalidates stolen cookies
sudo -u www-data wp --path="$SITE" config shuffle-salts 2>&1 | tail -2

# Check what the app DB user may do
PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
mysql -h192.168.1.245 -udraand28 -p"$PW" -e "SELECT user,host FROM mysql.user WHERE user='draand28'; SHOW GRANTS FOR CURRENT_USER();" 2>/dev/null
