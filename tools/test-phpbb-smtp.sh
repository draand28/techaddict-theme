#!/bin/bash
set -e
cat > /tmp/ta-phpbb-smtptest.php <<'PHP'
<?php
define('IN_PHPBB', true);
$phpbb_root_path = '/var/www/techaddict.ro/html/forum/';
$phpEx = 'php';
require $phpbb_root_path . 'common.php';
require $phpbb_root_path . 'includes/functions_messenger.php';

$addresses = array('to' => array(array('email' => 'draand28@gmail.com', 'name' => '')));
$headers = array('From: TechAddict <no-reply@techaddict.ro>', 'Content-Type: text/plain; charset=UTF-8');
$err = '';
$ok = smtpmail($addresses, 'TechAddict phpBB SMTP test', 'This message was sent through phpBB smtpmail() and Brevo.', $err, $headers);
echo 'result=' . var_export($ok, true) . ' error=' . strip_tags((string) $err) . "\n";
PHP
chown www-data:www-data /tmp/ta-phpbb-smtptest.php
cd /var/www/techaddict.ro/html/forum
sudo -u www-data php /tmp/ta-phpbb-smtptest.php 2>&1 | tail -6
rm -f /tmp/ta-phpbb-smtptest.php