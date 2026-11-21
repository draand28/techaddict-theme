$ErrorActionPreference = 'Stop'
$login = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get BREVO_SMTP_LOGIN).Trim()
$key = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get BREVO_SMTP_PASSWORD).Trim()
$b64 = { param($s) [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($s)) }
$remote = @'
set -e
umask 077
printf '%s' '__LOGIN__' | base64 -d > /tmp/ta-smtp-login
printf '%s' '__KEY__' | base64 -d > /tmp/ta-smtp-key
python3 - <<'PY'
import json
login = open('/tmp/ta-smtp-login').read()
key = open('/tmp/ta-smtp-key').read()
open('/tmp/ta-smtp.json','w').write(json.dumps({'login': login, 'key': key}))
PY
chown www-data:www-data /tmp/ta-smtp.json
chmod 600 /tmp/ta-smtp.json
cat > /tmp/ta-set-phpbb-smtp.php <<'PHP'
<?php
define('IN_PHPBB', true);
$phpbb_root_path = '/var/www/techaddict.ro/html/forum/';
$phpEx = 'php';
require $phpbb_root_path . 'common.php';
$data = json_decode(file_get_contents('/tmp/ta-smtp.json'), true);
$config->set('smtp_username', $data['login']);
$config->set('smtp_password', $data['key']);
echo 'login_len=' . strlen($config->offsetGet('smtp_username')) . ' pass_len=' . strlen($config->offsetGet('smtp_password')) . "\n";
PHP
chown www-data:www-data /tmp/ta-set-phpbb-smtp.php
cd /var/www/techaddict.ro/html/forum
sudo -u www-data php /tmp/ta-set-phpbb-smtp.php
sudo -u www-data php bin/phpbbcli.php cache:purge 2>&1 | tail -1
rm -f /tmp/ta-smtp-login /tmp/ta-smtp-key /tmp/ta-smtp.json /tmp/ta-set-phpbb-smtp.php
echo cleaned
'@
$script = $remote.Replace('__LOGIN__', (& $b64 $login)).Replace('__KEY__', (& $b64 $key))
($script -replace "`r", "") | ssh root@192.168.45.133 "bash -s"
