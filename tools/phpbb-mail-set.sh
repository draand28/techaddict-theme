#!/bin/bash
set -e
cd /var/www/techaddict.ro/html/forum
run() { sudo -u www-data php bin/phpbbcli.php config:set "$1" "$2" >/dev/null; echo "$1=$2"; }
run email_enable 1
run board_email no-reply@techaddict.ro
run board_contact draand28@gmail.com
run smtp_delivery 1
run smtp_host smtp-relay.brevo.com
run smtp_port 587
run smtp_allow_self_signed 0
run smtp_verify_peer 1
sudo -u www-data php bin/phpbbcli.php cache:purge 2>&1 | tail -1
