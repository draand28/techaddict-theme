#!/bin/bash
set -e
cat > /tmp/ta-phpbb-mailtest.php <<'PHP'
<?php
define('IN_PHPBB', true);
$phpbb_root_path = '/var/www/techaddict.ro/html/forum/';
$phpEx = 'php';
require $phpbb_root_path . 'common.php';
require $phpbb_root_path . 'includes/functions_messenger.php';

$err = '';
$headers = array('From: TechAddict <no-reply@techaddict.ro>', 'Content-Type: text/plain; charset=UTF-8');
$ok = phpbb_mail('draand28@gmail.com', 'TechAddict phpBB SMTP test', 'This message was sent by phpBB through the Brevo SMTP relay.', $headers, "\r\n", $err);
echo 'result=' . var_export($ok, true) . ' error=' . $err . "\n";
PHP
chown www-data:www-data /tmp/ta-phpbb-mailtest.php
cd /var/www/techaddict.ro/html/forum
sudo -u www-data php /tmp/ta-phpbb-mailtest.php 2>&1 | tail -5
rm -f /tmp/ta-phpbb-mailtest.php