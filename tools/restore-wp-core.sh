#!/bin/bash
# Replace infected WordPress core with the clean 7.1.3 release.
# Backups already exist in /root/backups/techaddict-malware-2026-11-21/.
set -e
SITE=/var/www/techaddict.ro/html
CLEAN=/root/techaddict-cleanup/wordpress
QUAR=/root/techaddict-cleanup
cd "$SITE"

grep -q "'7.1.3'" "$CLEAN/wp-includes/version.php" || { echo "clean tree version mismatch"; exit 1; }

# Keep the infected trees for inspection, outside the web root.
[ -d "$QUAR/infected-wp-admin" ] || mv wp-admin "$QUAR/infected-wp-admin"
cp -a "$CLEAN/wp-admin" ./wp-admin

[ -d "$QUAR/infected-wp-includes" ] || mv wp-includes "$QUAR/infected-wp-includes"
cp -a "$CLEAN/wp-includes" ./wp-includes

# Root core PHP files, never wp-config.php
for f in "$CLEAN"/*.php; do
	b=$(basename "$f")
	[ "$b" = "wp-config.php" ] && continue
	cp -a "$f" "./$b"
done

# Attacker files in the web root
rm -f wp-intec.php wp-xmltec.php wp-xmlrpc.php wp-customize.php

# Attacker files outside core
rm -f .well-known/about.php .well-known/index.php

# Stock rewrite rules, no DirectoryIndex hijack
cat > .htaccess <<'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF

# Remove the loader line from wp-config.php if it is still there
if sed -n '71p' wp-config.php | grep -q 'rss-tec'; then
	sed -i '71d' wp-config.php
fi

chown -R www-data:www-data wp-admin wp-includes .htaccess wp-config.php
chown www-data:www-data ./*.php

echo "syntax checks:"
for f in wp-config.php index.php wp-blog-header.php wp-settings.php wp-load.php; do php -l "$f"; done
echo "remaining rss-tec references:"
grep -rl 'rss-tec' . --include='*.php' 2>/dev/null | head
echo done
