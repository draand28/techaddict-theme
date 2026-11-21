#!/bin/bash
set -e
cd /root/techaddict-cleanup
if [ ! -f phpbb.zip ]; then
	curl -sS -o phpbb.zip https://download.phpbb.com/pub/release/3.3/3.3.19/phpBB-3.3.19.zip
fi
rm -rf phpbb-clean
mkdir phpbb-clean
cd phpbb-clean
unzip -q ../phpbb.zip

SITE=/var/www/techaddict.ro/html/forum
echo "=== phpBB version"
grep -n "PHPBB_VERSION" "$SITE/includes/constants.php" | head -1

echo "=== modified/extra core files (excluding config, cache, store, files, images)"
diff -rq /root/techaddict-cleanup/phpbb-clean/phpBB "$SITE" 2>/dev/null \
	| grep -vE "Only in $SITE/(cache|store|files|images|ext|styles/techaddict)" \
	| grep -vE "config\\.php|config\\.yml" | head -30

echo "=== admin group members"
PW=$(cd "$SITE" && php -r 'include "config.php"; echo $dbpasswd;')
mysql -h192.168.1.245 -utcn_forum -p"$PW" -D techaddict_phpbb -e "
select u.user_id,u.username,u.user_email from phpbb_users u
join phpbb_user_group g on g.user_id=u.user_id and g.group_id=5;" 2>/dev/null

echo "=== php shells (request-driven eval)"
grep -rlnE '\b(eval|assert)[[:space:]]*\(.*\$_(POST|GET|REQUEST|COOKIE)|base64_decode[[:space:]]*\(.*\$_(POST|GET|REQUEST|COOKIE)' "$SITE" --include='*.php' 2>/dev/null | head -10

echo "=== odd dot-php/files"
find "$SITE" -maxdepth 2 -name '.*.php' -o -maxdepth 2 -name '.*' -type f 2>/dev/null | head
