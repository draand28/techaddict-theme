$ErrorActionPreference = 'Stop'
$key = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get BREVO_API_KEY).Trim()
$b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($key))
$remote = @'
set -e
umask 077
printf '%s' '__KEY__' | base64 -d > /tmp/ta-brevo.key
chown www-data:www-data /tmp/ta-brevo.key
chmod 600 /tmp/ta-brevo.key
cat > /tmp/ta-set-brevo.php <<'PHP'
<?php
$key = trim(file_get_contents('/tmp/ta-brevo.key'));
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
chown www-data:www-data /tmp/ta-set-brevo.php
chmod 644 /tmp/ta-set-brevo.php
cd /var/www/techaddict.ro/html
sudo -u www-data wp --path="$PWD" eval-file /tmp/ta-set-brevo.php
sudo -u www-data wp --path="$PWD" eval 'var_dump(wp_mail("draand28@gmail.com","TechAddict mail test","WordPress Brevo setup test."));'
rm -f /tmp/ta-brevo.key /tmp/ta-set-brevo.php /root/techaddict-cleanup/brevo.key /root/techaddict-cleanup/set-brevo-mail.php
echo "temp files removed"
'@
($remote.Replace('__KEY__', $b64) -replace "`r", "") | ssh root@192.168.45.133 "bash -s"
