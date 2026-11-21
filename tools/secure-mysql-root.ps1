# Lock remote root@% and give root only to the two admin hosts, with a new
# random password stored in the secrets store.
$ErrorActionPreference = 'Stop'
$nas = 'root@192.168.1.245'
$new = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
$b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($new))

$script = @'
set -e
umask 077
printf '%s' '__PW__' | base64 -d > /tmp/.root.new
NEW=$(cat /tmp/.root.new)
C=ix-mysql8-mysql8-1
ROOTPW=$(docker inspect "$C" | python3 -c '
import json,sys
for e in json.load(sys.stdin)[0]["Config"]["Env"]:
    if e.startswith("MYSQL_ROOT_PASSWORD="):
        print(e.split("=",1)[1]); break
')
docker exec -i "$C" mysql -uroot -p"$ROOTPW" <<SQL
CREATE USER IF NOT EXISTS 'root'@'192.168.45.133' IDENTIFIED BY '$NEW';
ALTER USER 'root'@'192.168.45.133' IDENTIFIED BY '$NEW';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.45.133' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS 'root'@'192.168.45.203' IDENTIFIED BY '$NEW';
ALTER USER 'root'@'192.168.45.203' IDENTIFIED BY '$NEW';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'192.168.45.203' WITH GRANT OPTION;
ALTER USER 'root'@'%' ACCOUNT LOCK;
FLUSH PRIVILEGES;
SELECT user, host, account_locked FROM mysql.user WHERE user='root';
SQL
rm -f /tmp/.root.new
'@

($script.Replace('__PW__', $b64) -replace "`r", "") | ssh $nas "bash -s"
& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set MYSQL_ROOT_PASSWORD -Value $new
"root accounts updated"
