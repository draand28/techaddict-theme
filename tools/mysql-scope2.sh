#!/bin/bash
SITE=/var/www/techaddict.ro/html
cd "$SITE" || exit 1
PW=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
M="mysql -h192.168.1.245 -udraand28 -p$PW"
echo "=== grants for other accounts"
$M -e "SHOW GRANTS FOR 'backup_GWH5id'@'%'; SHOW GRANTS FOR 'root'@'%'; SHOW GRANTS FOR 'oc_draand28'@'%';" 2>/dev/null
echo
echo "=== client hosts seen recently"
$M -e "SELECT host,current_connections,total_connections FROM performance_schema.hosts ORDER BY total_connections DESC LIMIT 15;" 2>/dev/null
echo
echo "=== current connections"
$M -e "SELECT user,host,db,command FROM information_schema.processlist;" 2>/dev/null
echo
echo "=== config files containing the current shared password (count only)"
grep -rl -- "$PW" /var/www 2>/dev/null | wc -l
grep -rl -- "$PW" /var/www 2>/dev/null | head -25
