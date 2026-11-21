#!/bin/bash
# Read-only diagnostic: admin preview user state and recent admin log.
cd /var/www/techaddict.ro/html/forum
PW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -udraand28 -p"$PW" -D techaddict_phpbb -e "
select user_id, username, user_type, user_inactive_reason, user_actkey from phpbb_users where username='ta_acp_preview';
select g.group_id, g.group_name, ug.user_id from phpbb_groups g join phpbb_user_group ug on ug.group_id=g.group_id join phpbb_users u on u.user_id=ug.user_id where u.username='ta_acp_preview';
select log_id, log_time, log_operation, log_data from phpbb_log order by log_id desc limit 12;
"
