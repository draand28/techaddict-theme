#!/usr/bin/env python3
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
s = open(conf).read()
fallback = """    RewriteCond %{REQUEST_URI} !^/forum(/|$)
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]

"""
if fallback in s:
    s = s.replace(fallback, '', 1)
# WordPress needs to read its own .htaccess for the front controller
s = s.replace("        AllowOverride None\n", "        AllowOverride FileInfo\n")
open(conf, 'w').write(s)
print('fallback removed; AllowOverride FileInfo enabled')