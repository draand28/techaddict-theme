#!/bin/bash
set -e
cd /var/www/techaddict.ro/html/forum
sudo -u www-data php bin/phpbbcli.php config:set chg_passforce 3650 2>&1 | tail -1
FPW=$(php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -utcn_forum -p"$FPW" -D techaddict_phpbb -e "
UPDATE phpbb_users SET user_passchg=0 WHERE user_type IN (0,3);
SELECT COUNT(*) AS forced FROM phpbb_users WHERE user_passchg=0 AND user_type IN (0,3);
" 2>/dev/null
sudo -u www-data php bin/phpbbcli.php cache:purge 2>&1 | tail -1
