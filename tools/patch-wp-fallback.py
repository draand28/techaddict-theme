#!/usr/bin/env python3
import shutil
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
shutil.copy2(conf, '/root/backups/techaddict-malware-2026-11-21/techaddict.ro.conf.before-wp-fallback')
s = open(conf).read()

# No directory listings and no content negotiation surprises
s = s.replace('Options Indexes FollowSymLinks MultiViews', 'Options FollowSymLinks', 1)

# WordPress front controller fallback (vhost has AllowOverride None, so .htaccess is ignored)
fallback = """    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]

"""
anchor = "    RewriteRule ^/thread/([0-9]+)"
if fallback.strip() not in s:
    marker = "\n\tErrorLog ${APACHE_LOG_DIR}/error.log"
    if marker not in s:
        raise SystemExit('ErrorLog anchor not found')
    s = s.replace(marker, "\n" + fallback + marker, 1)

open(conf, 'w').write(s)
print('wp fallback rewrite and Options hardening added')
