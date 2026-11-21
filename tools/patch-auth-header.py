#!/usr/bin/env python3
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
s = open(conf).read()
if 'CGIPassAuth On' not in s:
    s = s.replace('    <Directory /var/www/techaddict.ro/html/>\n',
                  '    <Directory /var/www/techaddict.ro/html/>\n        CGIPassAuth On\n        SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1\n', 1)
    open(conf, 'w').write(s)
print('authorization header passthrough added')
