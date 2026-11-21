#!/bin/bash
cd /var/www/techaddict.ro/html/forum
PW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -udraand28 -p"$PW" -D techaddict_phpbb -e "
select * from phpbb_acl_groups where group_id=5 limit 20;
select * from phpbb_acl_users where user_id=104 limit 20;
select role_id, role_name, role_type from phpbb_acl_roles where role_type='a' limit 20;
select user_id, username, user_permissions from phpbb_users where user_id in (2,104);
"
