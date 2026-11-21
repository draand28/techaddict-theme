# Phase B: keep only the databases the live services need, drop global rights.
$ErrorActionPreference = 'Stop'
$srv = 'root@192.168.45.133'
$pw = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get MYSQL_DRAAND28_PASSWORD).Trim()
if (-not $pw) { throw 'password missing from secrets' }
$b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pw))

$script = @'
set -e
umask 077
printf '%s' '__PW__' | base64 -d > /tmp/.rot.new
PW=$(cat /tmp/.rot.new)
mysql -h192.168.1.245 -udraand28 -p"$PW" <<'SQL'
GRANT ALL PRIVILEGES ON `ade`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `reforme`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `nubis_site`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_authme`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_bungeeauth`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_forum`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_killstats`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_onlinetime`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_panel`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_phpbb3`.* TO 'draand28'@'%';
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'draand28'@'%';
SQL
mysql -h192.168.1.245 -udraand28 -p"$PW" -N -e "SHOW GRANTS FOR CURRENT_USER();" 2>/dev/null
rm -f /tmp/.rot.new
'@

($script.Replace('__PW__', $b64) -replace "`r", "") | ssh $srv "bash -s"
"grants updated"
