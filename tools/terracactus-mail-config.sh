#!/bin/bash
cd /var/www/terracactus.net/html || exit 1
PW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -udraand28 -p"$PW" -D tcn_phpbb3 -N -e "
select config_name,config_value from phpbb_config
where config_name in ('board_email','email_enable','smtp_delivery','smtp_host','smtp_port','smtp_username','email_function_name');
" 2>/dev/null
