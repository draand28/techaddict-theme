$ErrorActionPreference = 'Stop'
function B64($s) { [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($s)) }
$app = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get MYSQL_DRAAND28_PASSWORD).Trim()
$root = (& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Get MYSQL_ROOT_PASSWORD).Trim()

$script = @'
set -e
umask 077
printf '%s' '__APP__' | base64 -d > /tmp/.app.pw
printf '%s' '__ROOT__' | base64 -d > /tmp/.root.pw
APP=$(cat /tmp/.app.pw); ROOT=$(cat /tmp/.root.pw)
echo "root@dot133:"
mysql -h192.168.1.245 -uroot -p"$ROOT" -N -e "SELECT 'ok';" 2>/dev/null
echo "app login:"
mysql -h192.168.1.245 -udraand28 -p"$APP" -N -e "SELECT 'ok';" 2>/dev/null
echo "app db access:"
for db in ade reforme nubis_site tcn_authme tcn_bungeeauth tcn_forum tcn_killstats tcn_onlinetime tcn_panel tcn_phpbb3; do
	mysql -h192.168.1.245 -udraand28 -p"$APP" -D "$db" -N -e "SELECT 1;" >/dev/null 2>&1 && echo "  ok $db" || echo "  FAIL $db"
done
echo "global grants:"
mysql -h192.168.1.245 -udraand28 -p"$APP" -N -e "SHOW GRANTS FOR CURRENT_USER();" 2>/dev/null | grep '\*\.\*' || true
rm -f /tmp/.app.pw /tmp/.root.pw
'@

($script.Replace('__APP__', (B64 $app)).Replace('__ROOT__', (B64 $root)) -replace "`r", "") | ssh root@192.168.45.133 "bash -s"
