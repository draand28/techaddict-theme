#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
F=wp-content/uploads/2021/05/card-main.png
echo "=== file"
ls -la "$F" 2>&1
curl -s -o /dev/null -w 'http %{http_code}\n' https://techaddict.ro/wp-content/uploads/2021/05/card-main.png
echo "=== attachment meta"
$S post meta get 114 _wp_attached_file 2>/dev/null
$S post meta get 114 _wp_attachment_metadata 2>/dev/null
echo "=== search filesystem for card-main"
find /var/www -iname 'card-main*' -printf '%TY-%Tm-%Td %s %p\n' 2>/dev/null | head -20
echo "=== uploads 2021/05"
ls -la wp-content/uploads/2021/05 2>&1 | head -20
