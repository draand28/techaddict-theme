#!/usr/bin/env python3
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
s = open(conf).read()
# Root filesystem must not allow overrides
s = s.replace("    <Directory />\n        Options FollowSymLinks\n        AllowOverride FileInfo", "    <Directory />\n        Options FollowSymLinks\n        AllowOverride None", 1)
# Remove any forum block previously inserted inside a vhost
import re
s = re.sub(r"\n\s*<Directory /var/www/techaddict\.ro/html/forum>\s*\n\s*AllowOverride None\s*\n\s*</Directory>\s*\n", "\n", s)
# Append a global, path-specific block (overrides the parent for /forum)
if 'html/forum' not in s:
    s += """

<Directory "/var/www/techaddict.ro/html/forum">
    AllowOverride None
</Directory>
"""
open(conf, 'w').write(s)
print('Directory overrides corrected')