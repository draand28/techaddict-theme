#!/bin/bash
set -e
Q=/root/techaddict-cleanup
umask 077
KEY=$(powershell -NoProfile -Command "& 'C:\Users\draan\.secrets\secrets.ps1' -Get BREVO_API_KEY" 2>/dev/null | tr -d '\r\n')
# KEY is passed over SSH stdin below, not as an argument
cat > "$Q/brevo.key"
chmod 600 "$Q/brevo.key"

cat > "$Q/set-brevo-mail.php" <<'PHP'
<?php
$key = trim(file_get_contents('/root/techaddict-cleanup/brevo.key'));
$opt = get_option('wp_mail_smtp');
if (!is_array($opt)) { $opt = array(); }
$opt['mail'] = array(
	'from_email' => 'no-reply@techaddict.ro',
	'from_name' => 'TechAddict.Ro',
	'mailer' => 'sendinblue',
	'return_path' => true,
	'from_email_force' => true,
	'from_name_force' => false,
);
$opt['sendinblue'] = array(
	'api_key' => $key,
	'domain' => 'techaddict.ro',
);
update_option('wp_mail_smtp', $opt);
echo "mailer=" . $opt['mail']['mailer'] . " from=" . $opt['mail']['from_email'] . "\n";
PHP

chown www-data:www-data "$Q/set-brevo-mail.php"
cd /var/www/techaddict.ro/html
sudo -u www-data wp --path="$PWD" eval-file "$Q/set-brevo-mail.php"
rm -f "$Q/brevo.key" "$Q/set-brevo-mail.php"
echo "key file removed"
