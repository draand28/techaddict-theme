#!/bin/bash
set -e
W=/var/www/techaddict.ro/html
Q=/root/techaddict-cleanup/quarantine
cd "$W"
S="sudo -u www-data wp --path=$W"

# Allow WordPress background updates again (Site Health critical issue)
sed -i "/define('AUTOMATIC_UPDATER_DISABLED', true);/d" wp-config.php
chown www-data:www-data wp-config.php
chmod 640 wp-config.php

# Remove inactive plugins
mkdir -p "$Q/plugins"
for p in dx-delete-attached-media rollback-update-failure; do
	if [ -d "$W/wp-content/plugins/$p" ]; then
		mv "$W/wp-content/plugins/$p" "$Q/plugins/$p"
		echo "quarantined plugin $p"
	fi
done

# Remove unused themes, keep the active theme and the default Twenty Twenty-Five
mkdir -p "$Q/themes"
for t in twentyfifteen twentynineteen twentyseventeen twentysixteen twentytwenty twentyfour twentyone twentythree twentytwentytwo; do
	if [ -d "$W/wp-content/themes/$t" ]; then
		mv "$W/wp-content/themes/$t" "$Q/themes/$t"
		echo "quarantined theme $t"
	fi
done

# Pass the Authorization header through to PHP (application passwords, REST auth)
python3 - <<'PY'
p='/var/www/techaddict.ro/html/.htaccess'
s=open(p).read()
line='RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]\n'
if 'HTTP_AUTHORIZATION' not in s:
    s=s.replace('RewriteEngine On\n', 'RewriteEngine On\n'+line, 1)
    open(p,'w').write(s)
PY
chown www-data:www-data .htaccess
chmod 644 .htaccess

$S rewrite flush --hard >/dev/null 2>&1 || true
echo "=== active plugins"
$S plugin list --status=active --fields=name,version 2>/dev/null
echo "=== themes"
$S theme list --fields=name,status 2>/dev/null
echo "=== site"
curl -s -o /dev/null -w 'wp %{http_code}\n' https://techaddict.ro/
curl -s -o /dev/null -w 'forum %{http_code}\n' https://techaddict.ro/forum/
curl -s -o /dev/null -w 'rest %{http_code}\n' https://techaddict.ro/wp-json/
