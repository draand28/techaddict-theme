#!/bin/bash
cd /var/www/techaddict.ro/html/forum || exit 1
for k in email_enable board_email board_contact smtp_delivery smtp_host smtp_port smtp_username smtp_allow_self_signed smtp_verify_peer; do
	printf "%s = " "$k"
	sudo -u www-data php bin/phpbbcli.php config:get "$k" 2>/dev/null | tail -1
done
