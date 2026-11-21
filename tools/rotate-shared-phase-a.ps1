# Phase A: rotate the shared MySQL password and update every consumer.
# Grants are tightened in a second step after this verifies.
$ErrorActionPreference = 'Stop'
$srv = 'root@192.168.45.133'
$game = 'root@192.168.45.203'

$new = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
$newB64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($new))

$siteScript = @'
set -e
umask 077
printf '%s' '__NEWB64__' | base64 -d > /tmp/.rot.new
python3 - <<'PY'
import os, re
cfg = open('/var/www/terracactus.net/html/config.php').read()
m = re.search(r"\$dbpasswd = '([^']*)'", cfg)
if not m:
    raise SystemExit('old password not found in config')
old = m.group(1)
new = open('/tmp/.rot.new').read()
open('/tmp/.rot.old', 'w').write(old)

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
print('config files updated:', len(changed))
for p in changed:
    print(' ', p)
PY

OLD=$(cat /tmp/.rot.old)
NEW=$(cat /tmp/.rot.new)
mysql -h192.168.1.245 -udraand28 -p"$OLD" -e "ALTER USER 'draand28'@'%' IDENTIFIED BY '$NEW';"
mysql -h192.168.1.245 -udraand28 -p"$NEW" -N -e "SELECT 'new password works';"
base64 -w0 /tmp/.rot.old > /tmp/.rot.old.b64
rm -f /tmp/.rot.new
'@

($siteScript.Replace('__NEWB64__', $newB64) -replace "`r", "") | ssh $srv "bash -s"

# Carry the old password to the game host as base64 (captured locally, not printed)
$oldB64 = (& ssh $srv "cat /tmp/.rot.old.b64").Trim()
ssh $srv "rm -f /tmp/.rot.old.b64 /tmp/.rot.old"

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
print('game configs updated:', len(changed))
for p in changed:
    print(' ', p)
PY
rm -f /tmp/.rot.old /tmp/.rot.new
'@

($gameScript.Replace('__OLD__', $oldB64).Replace('__NEW__', $newB64) -replace "`r", "") | ssh $game "bash -s"
ssh $game "docker restart bd4fc18ffbe5 >/dev/null && echo 'bungee container restarted'"

& powershell -NoProfile -File C:\Users\draan\.secrets\secrets.ps1 -Set MYSQL_DRAAND28_PASSWORD -Value $new
"phase A complete"
