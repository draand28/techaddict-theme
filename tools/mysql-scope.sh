#!/bin/bash
# MySQL compromise scope: users, databases, and which site configs use draand28.
echo "=== configs referencing draand28"
grep -rl "draand28" /var/www --include='wp-config.php' --include='config.php' --include='.env' --include='*.env' 2>/dev/null | head -20
echo
echo "=== mysql users"
PW=$(cd /var/www/techaddict.ro/html && grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
mysql -h192.168.1.245 -udraand28 -p"$PW" -e "SELECT user,host,plugin,account_locked,password_expired FROM mysql.user ORDER BY user;" 2>/dev/null
echo
echo "=== databases"
mysql -h192.168.1.245 -udraand28 -p"$PW" -e "SHOW DATABASES;" 2>/dev/null
echo
echo "=== triggers/events in techaddict DBs"
mysql -h192.168.1.245 -udraand28 -p"$PW" -e "SELECT trigger_schema,trigger_name,event_object_table FROM information_schema.triggers WHERE trigger_schema LIKE 'techaddict%'; SELECT event_schema,event_name FROM information_schema.events WHERE event_schema LIKE 'techaddict%';" 2>/dev/null
echo
echo "=== definers in techaddict_wp"
mysql -h192.168.1.245 -udraand28 -p"$PW" -e "SELECT DISTINCT definer FROM information_schema.routines WHERE routine_schema LIKE 'techaddict%';" 2>/dev/null
