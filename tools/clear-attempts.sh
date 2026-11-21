#!/bin/bash
# Clear the preview admin's failed-login counter (safe: only this test account).
cd /var/www/techaddict.ro/html/forum
PW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -udraand28 -p"$PW" -D techaddict_phpbb -e "
delete from phpbb_login_attempts where username_clean='ta_acp_preview';
select count(*) as attempts_left from phpbb_login_attempts where username_clean='ta_acp_preview';
"
