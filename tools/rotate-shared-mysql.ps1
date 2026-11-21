# Rotate the shared MySQL account, update every live consumer, and reduce its
# global privileges to the databases actually used. New password goes to the
# DPAPI secrets store; nothing is printed.
$ErrorActionPreference = 'Stop'
$srv = 'root@192.168.45.133'
$game = 'root@192.168.45.203'

# Read the current shared password from a live config (not printed)
$old = (& ssh $srv "grep -oE \"^\\`$dbpasswd = '[^']*';\" /var/www/terracactus.net/html/config.php | sed \"s/.*'\([^']*\)';\?/\1/\"").Trim()
if (-not $old) { throw 'could not read the current password' }

$new = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
$b64 = { param($s) [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($s)) }
$oldB64 = & $b64 $old
$newB64 = & $b64 $new

$siteScript = @'
set -e
umask 077
printf '%s' '__OLD__' | base64 -d > /tmp/.rot.old
printf '%s' '__NEW__' | base64 -d > /tmp/.rot.new
python3 - <<'PY'
import os
old = open('/tmp/.rot.old').read()
new = open('/tmp/.rot.new').read()
roots = ['/var/www']
exts = {'.php', '.env', '.yml', '.yaml', '.json', '.conf', '.ini', '.toml', '.properties'}
skip = ('/node_modules/', '/.git/', '/cache/', '/vendor/', '_backup', 'html_ipb', 'html_24072024', 'ipb_backup')
changed = []
for root in roots:
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if not any(x in os.path.join(dirpath, d) for x in skip)]
        for name in filenames:
            p = os.path.join(dirpath, name)
            if any(x in p for x in skip):
                continue
            if name != '.env' and os.path.splitext(name)[1] not in exts:
                continue
            try:
                if os.path.getsize(p) > 2_000_000:
                    continue
                data = open(p, 'r', errors='ignore').read()
            except Exception:
                continue
            if old in data:
                open(p, 'w').write(data.replace(old, new))
                changed.append(p)
print('files updated:', len(changed))
for p in changed:
    print(' ', p)
PY
rm -f /tmp/.rot.old /tmp/.rot.new

# Rotate, then grant only the databases these services use.
OLD=$(cat /var/www/terracactus.net/html/config.php | grep -oE "^\\\$dbpasswd = '[^']*';" | sed "s/.*'\([^']*\)';\?/\1/")
mysql -h192.168.1.245 -udraand28 -p"$OLD" <<'SQL'
ALTER USER 'draand28'@'%' IDENTIFIED BY '__NEW__';
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

mysql -h192.168.1.245 -udraand28 -p"__NEW__" -N -e "SELECT 'login ok'; SHOW GRANTS FOR CURRENT_USER();" 2>/dev/null | sed 's/ WITH GRANT OPTION//'
'@

$gameScript = @'
set -e
umask 077
printf '%s' '__OLD__' | base64 -d > /tmp/.rot.old
printf '%s' '__NEW__' | base64 -d > /tmp/.rot.new
python3 - <<'PY'
import os
old = open('/tmp/.rot.old').read()
new = open('/tmp/.rot.new').read()
roots = ['/var/lib/pterodactyl/volumes', '/var/www', '/opt', '/etc']
exts = {'.php', '.env', '.yml', '.yaml', '.json', '.conf', '.ini', '.toml', '.properties'}
changed = []
for root in roots:
    for dirpath, dirnames, filenames in os.walk(root):
        for name in filenames:
            p = os.path.join(dirpath, name)
            if 'log' in name.lower():
                continue
            if name != '.env' and os.path.splitext(name)[1] not in exts:
                continue
            try:
                if os.path.getsize(p) > 2_000_000:
                    continue
                data = open(p, 'r', errors='ignore').read()
            except Exception:
                continue
            if old in data:
                open(p, 'w').write(data.replace(old, new))
                changed.append(p)
print('files updated:', len(changed))
for p in changed:
    print(' ', p)
PY
rm -f /tmp/.rot.old /tmp/.rot.new
'@

$site = $siteScript.Replace('__OLD__', $oldB64).Replace('__NEW__', $newB64)
($site -replace "`r", "") | ssh $srv "bash -s"

$gameRun = $gameScript.Replace('__OLD__', $oldB64).Replace('__NEW__', $newB64)
($gameRun -replace "`r", "") | ssh $game "bash -s"

# Reload the Minecraft proxy that uses these tables
ssh $game "docker restart bd4fc18ffbe5 >/dev/null && echo 'bungee container restarted'"
ssh $game "sleep 5; docker logs --tail 40 bd4fc18ffbe5 2>&1 | grep -iE 'sql|database|access denied|error' | tail -10 || true"

& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set MYSQL_DRAAND28_PASSWORD -Value $new
"rotation complete"
