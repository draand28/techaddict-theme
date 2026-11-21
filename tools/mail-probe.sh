#!/bin/bash
cd /var/www/techaddict.ro/html/forum
PW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -udraand28 -p"$PW" -D techaddict_phpbb -N -e "select config_name,config_value from phpbb_config where config_name in ('board_email','email_enable','smtp_delivery','smtp_host','smtp_username','smtp_port')"
echo ---
grep -n "DB_NAME\|table_prefix" /var/www/techaddict.ro/html/wp-config.php | head -3
