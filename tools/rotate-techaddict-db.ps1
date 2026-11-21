# Give techaddict.ro its own least-privilege MySQL users and stop using the
# shared superuser account. Passwords are generated in this process and stored
# in the DPAPI secrets store; they are never printed.
$ErrorActionPreference = 'Stop'

function New-Pass {
	-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 28 | ForEach-Object { [char]$_ })
}

$wpPass = New-Pass
$forumPass = New-Pass
$srv = 'root@192.168.45.133'

$sql = @"
CREATE USER IF NOT EXISTS 'tcn_wp'@'192.168.45.133' IDENTIFIED BY '$wpPass';
ALTER USER 'tcn_wp'@'192.168.45.133' IDENTIFIED BY '$wpPass';
GRANT ALL PRIVILEGES ON techaddict_wp.* TO 'tcn_wp'@'192.168.45.133';
CREATE USER IF NOT EXISTS 'tcn_forum'@'192.168.45.133' IDENTIFIED BY '$forumPass';
ALTER USER 'tcn_forum'@'192.168.45.133' IDENTIFIED BY '$forumPass';
GRANT ALL PRIVILEGES ON techaddict_phpbb.* TO 'tcn_forum'@'192.168.45.133';
FLUSH PRIVILEGES;
"@

$remote = @'
set -e
cd /var/www/techaddict.ro/html
OLD=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
mysql -h192.168.1.245 -udraand28 -p"$OLD" <<'SQL'
__SQL__
SQL

python3 - <<'PY'
import re

wp = '/var/www/techaddict.ro/html/wp-config.php'
s = open(wp).read()
s = s.replace("define('DB_USER', 'draand28');", "define('DB_USER', 'tcn_wp');")
s = re.sub(r"define\('DB_PASSWORD', '[^']*'\);", "define('DB_PASSWORD', '__WPPASS__');", s, count=1)
open(wp, 'w').write(s)

fc = '/var/www/techaddict.ro/html/forum/config.php'
s = open(fc).read()
s = re.sub(r"\$dbuser = '[^']*';", "$dbuser = 'tcn_forum';", s, count=1)
s = re.sub(r"\$dbpasswd = '[^']*';", "$dbpasswd = '__FORUMPASS__';", s, count=1)
open(fc, 'w').write(s)
PY

chown www-data:www-data wp-config.php forum/config.php
chmod 640 forum/config.php
rm -f wp-config.php.0
grep -n "DB_USER\|DB_PASSWORD" wp-config.php | sed 's/=.*/= ***/'
grep -n "dbuser\|dbpasswd" forum/config.php | sed 's/=.*/= ***/'
'@

$script = $remote.Replace('__SQL__', $sql).Replace('__WPPASS__', $wpPass).Replace('__FORUMPASS__', $forumPass)
($script -replace "`r", "") | ssh $srv "bash -s"

& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set TECHADDICT_WP_DB_PASSWORD -Value $wpPass
& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set TECHADDICT_FORUM_DB_PASSWORD -Value $forumPass

"users switched; configs updated"
