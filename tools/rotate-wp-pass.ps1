# Rotate the techaddict WordPress DB password (the previous value was printed
# by a masking bug in the terminal output).
$ErrorActionPreference = 'Stop'
function New-Pass {
	-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 28 | ForEach-Object { [char]$_ })
}
$new = New-Pass
$srv = 'root@192.168.45.133'

$remote = @'
set -e
cd /var/www/techaddict.ro/html
OLD=$(grep -o "define( *'DB_PASSWORD' *, *'[^']*'" wp-config.php | sed "s/.*'\([^']*\)'$/\1/")
mysql -h192.168.1.245 -utcn_wp -p"$OLD" -e "ALTER USER USER() IDENTIFIED BY '__NEW__';"
python3 - <<'PY'
import re
p = '/var/www/techaddict.ro/html/wp-config.php'
s = open(p).read()
s = re.sub(r"define\('DB_PASSWORD', '[^']*'\);", "define('DB_PASSWORD', '__NEW__');", s, count=1)
open(p, 'w').write(s)
PY
chown www-data:www-data wp-config.php
sudo -u www-data wp db check >/dev/null && echo "wp db ok"
'@

$script = $remote.Replace('__NEW__', $new)
($script -replace "`r", "") | ssh $srv "bash -s"

& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set TECHADDICT_WP_DB_PASSWORD -Value $new
"rotated"
