#!/bin/bash
set -e
W=/var/www/techaddict.ro/html
cd "$W"
PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
M="mysql -h192.168.1.245 -utcn_wp -p$PW -D techaddict_wp"

echo "=== table sizes before"
$M -e "SELECT table_name, ROUND((data_length+index_length)/1024/1024) AS mb, table_rows FROM information_schema.tables WHERE table_schema='techaddict_wp' AND table_name IN ('wp_users','wp_usermeta');" 2>/dev/null

echo "=== schema default"
$M -N -e "SHOW CREATE TABLE wp_users;" 2>/dev/null | grep -o "user_registered[^,]*"

echo "=== optimize with relaxed sql_mode"
$M -e "SET SESSION sql_mode=''; OPTIMIZE TABLE wp_users, wp_usermeta; ANALYZE TABLE wp_users, wp_usermeta;" 2>/dev/null

echo "=== table sizes after"
$M -e "SELECT table_name, ROUND((data_length+index_length)/1024/1024) AS mb, table_rows FROM information_schema.tables WHERE table_schema='techaddict_wp' AND table_name IN ('wp_users','wp_usermeta');" 2>/dev/null
$M -e "SELECT ROUND(SUM(data_length+index_length)/1024/1024) AS total_mb FROM information_schema.tables WHERE table_schema='techaddict_wp';" 2>/dev/null

echo "=== remove Zoho SMTP settings"
$M -e "DELETE FROM wp_options WHERE option_name='wp_mail_smtp' OR option_name LIKE 'wp_mail_smtp%'; SELECT ROW_COUNT();" 2>/dev/null

echo "=== dump integrity"
gzip -t /root/backups/techaddict-malware-2026-11-21/techaddict_wp.before-spam-delete.sql.gz && echo "dump ok"

curl -s -o /dev/null -w 'wp %{http_code}\n' https://techaddict.ro/
