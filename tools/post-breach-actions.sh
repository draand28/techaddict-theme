#!/bin/bash
set -e
W=/var/www/techaddict.ro/html
Q=/root/techaddict-cleanup/quarantine

# Put the plugin back briefly so WordPress can deactivate it cleanly
if [ -d "$Q/wp-file-manager" ] && [ ! -d "$W/wp-content/plugins/wp-file-manager" ]; then
	mv "$Q/wp-file-manager" "$W/wp-content/plugins/wp-file-manager"
fi
cd "$W"
sudo -u www-data wp --path="$W" plugin deactivate wp-file-manager 2>&1 | tail -1 || true
mv "$W/wp-content/plugins/wp-file-manager" "$Q/wp-file-manager"
sudo -u www-data wp --path="$W" option get active_plugins --format=json 2>/dev/null

# Force a password change on next login for every forum account
cd "$W/forum"
sudo -u www-data php bin/phpbbcli.php config:set chg_passforce 1 2>&1 | tail -1
sudo -u www-data php bin/phpbbcli.php config:get chg_passforce 2>&1 | tail -1
sudo -u www-data php bin/phpbbcli.php cache:purge 2>&1 | tail -1

# Drop all forum sessions (forces fresh logins)
FPW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -utcn_forum -p"$FPW" -D techaddict_phpbb -e "DELETE FROM phpbb_sessions; SELECT ROW_COUNT() AS sessions_deleted;" 2>/dev/null
