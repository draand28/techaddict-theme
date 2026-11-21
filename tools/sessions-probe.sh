#!/bin/bash
cd /var/www/techaddict.ro/html/forum
PW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -udraand28 -p"$PW" -D techaddict_phpbb -e "
describe phpbb_sessions;
select session_id, session_user_id, session_admin, session_start, session_time from phpbb_sessions order by session_time desc limit 5;
"
