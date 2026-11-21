#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
echo "=== homepage status (via Cloudflare)"
curl -s -o /tmp/home.html -w '%{http_code} %{size_download}\n' https://techaddict.ro/
echo "=== markers in homepage"
grep -c 'rss-tec\|wp-xmltec\|e26\|base64_decode' /tmp/home.html || true

echo "=== php files in uploads"
find wp-content/uploads -type f \( -name '*.php' -o -name '*.phtml' -o -name '*.phar' -o -name '*.htaccess' \) -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null | head -20

echo "=== mu-plugins"
find wp-content/mu-plugins -type f 2>/dev/null

echo "=== .user.ini / php.ini in tree"
find . -maxdepth 3 \( -name '.user.ini' -o -name 'php.ini' \) -printf '%p\n' 2>/dev/null

echo "=== suspicious eval/base64 with request input (wp-content)"
grep -rlnE '\b(eval|assert)[[:space:]]*\(.*\$_(POST|GET|REQUEST|COOKIE)|base64_decode[[:space:]]*\(.*\$_(POST|GET|REQUEST|COOKIE)' wp-content --include='*.php' 2>/dev/null | head -30

echo "=== unusual dot-php files anywhere"
find . -path ./forum -prune -o -type f -name '.*.php' -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null

echo "=== files modified in attacker batches"
find . -path ./forum -prune -o -type f -name '*.php' -newermt '2026-02-03' ! -newermt '2026-02-05' -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null | head -40
