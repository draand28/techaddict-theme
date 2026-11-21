#!/usr/bin/env python3
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
s = open(conf).read()
old = """    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]"""
new = """    RewriteCond %{REQUEST_URI} !^/forum(/|$)
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]"""
if old not in s:
    raise SystemExit('fallback block not found')
s = s.replace(old, new, 1)
open(conf, 'w').write(s)
print('forum excluded from WP fallback')