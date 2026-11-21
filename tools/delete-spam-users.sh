#!/bin/bash
set -e
W=/var/www/techaddict.ro/html
BK=/root/backups/techaddict-malware-2026-11-21
cd "$W"

PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")

# Fresh dump before removing accounts
mysqldump -h192.168.1.245 -utcn_wp -p"$PW" --single-transaction --quick techaddict_wp \
	| gzip -1 > "$BK/techaddict_wp.before-spam-delete.sql.gz"
ls -lh "$BK/techaddict_wp.before-spam-delete.sql.gz"

mysql -h192.168.1.245 -utcn_wp -p"$PW" -D techaddict_wp <<'SQL'
CREATE TEMPORARY TABLE keep_users (ID bigint unsigned PRIMARY KEY);
INSERT INTO keep_users
  SELECT ID FROM wp_users WHERE user_registered < '2022-01-01' OR ID IN (1,2);

SELECT COUNT(*) AS keep_count FROM keep_users;

DELETE FROM wp_usermeta WHERE user_id NOT IN (SELECT ID FROM keep_users);
DELETE FROM wp_users WHERE ID NOT IN (SELECT ID FROM keep_users);

SELECT COUNT(*) AS users_left FROM wp_users;
SELECT COUNT(*) AS usermeta_left FROM wp_usermeta;
SELECT COUNT(*) AS admins_left FROM wp_usermeta WHERE meta_key='wp_capabilities' AND meta_value LIKE '%administrator%';
SQL

mysql -h192.168.1.245 -utcn_wp -p"$PW" -D techaddict_wp -e "OPTIMIZE TABLE wp_users, wp_usermeta;" 2>/dev/null
mysql -h192.168.1.245 -utcn_wp -p"$PW" -N -e "SELECT ROUND(SUM(data_length+index_length)/1024/1024) FROM information_schema.tables WHERE table_schema='techaddict_wp';" 2>/dev/null
curl -s -o /dev/null -w 'wp %{http_code}\n' https://techaddict.ro/
