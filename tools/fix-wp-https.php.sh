#!/bin/bash
set -e
cd /var/www/techaddict.ro/html
cp -a wp-config.php /root/backups/techaddict-malware-2026-11-21/wp-config.before-https-fix.php
python3 - <<'PY'
p='/var/www/techaddict.ro/html/wp-config.php'
s=open(p).read()
old="if ($_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https')\n $_SERVER['HTTPS']='on';"
new="// TLS terminates at Cloudflare; the origin only serves HTTPS\ntrust: $_SERVER['HTTPS'] = 'on';".replace('trust: ','')
if old in s:
    s=s.replace(old,new,1)
else:
    # fallback: remove stale conditional if spacing differs
    import re
    s=re.sub(r"if \(\$_SERVER\['HTTP_X_FORWARDED_PROTO'\]\s*==\s*'https'\)\s*\n\s*\$_SERVER\['HTTPS'\]\s*=\s*'on';", "$_SERVER['HTTPS'] = 'on';", s, count=1)
open(p,'w').write(s)
PY
chown www-data:www-data wp-config.php
chmod 640 wp-config.php
php -l wp-config.php
grep -n "HTTPS" wp-config.php | head -4
