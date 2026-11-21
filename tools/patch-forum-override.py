#!/usr/bin/env python3
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
s = open(conf).read()
block = """    <Directory /var/www/techaddict.ro/html/forum>
        AllowOverride None
    </Directory>

"""
if 'html/forum>' not in s:
    s = s.replace('</VirtualHost>', block + '</VirtualHost>', 1)
open(conf, 'w').write(s)
print('forum overrides disabled')