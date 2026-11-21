#!/usr/bin/env python3
import shutil, re

conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
backup = '/root/backups/techaddict-malware-2026-11-21/techaddict.ro.conf.before-www'
shutil.copy2(conf, backup)
s = open(conf).read()

# Serve the www hostname on both vhosts
s = s.replace("        ServerName techaddict.ro\n", "        ServerName techaddict.ro\n        ServerAlias www.techaddict.ro\n", 1)
s = s.replace("\tServerName techaddict.ro\n\t#ServerAlias www.techaddict.ro\n",
              "\tServerName techaddict.ro\n\tServerAlias www.techaddict.ro\n", 1)

# Canonical redirect and security headers on the TLS vhost
needle = "    RewriteEngine On\n"
addition = """    RewriteEngine On
    RewriteCond %{HTTP_HOST} ^www\\.techaddict\\.ro$ [NC]
    RewriteRule ^ https://techaddict.ro%{REQUEST_URI} [R=301,L]
    Header always set Strict-Transport-Security "max-age=31536000"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"
"""
assert s.count(needle) == 1, s.count(needle)
s = s.replace(needle, addition, 1)

open(conf, 'w').write(s)
print("patched", conf)
