#!/bin/bash
# Mark one preview session as an admin session so the ACP opens for screenshots.
# Usage: set-admin-session.sh <sid>
cd /var/www/techaddict.ro/html/forum
PW=$(php -r 'include "config.php"; echo $dbpasswd;')
SID=$(echo "$1" | tr -cd 'a-f0-9')
mysql -h192.168.1.245 -udraand28 -p"$PW" -D techaddict_phpbb -e "
update phpbb_sessions set session_admin=1 where session_id='$SID';
select session_id, session_user_id, session_admin from phpbb_sessions where session_id='$SID';
"
