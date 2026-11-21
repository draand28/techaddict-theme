#!/usr/bin/env python3
import shutil
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
shutil.copy2(conf, '/root/backups/techaddict-malware-2026-11-21/techaddict.ro.conf.before-permalinks')
s = open(conf).read()
needle = "    RewriteRule ^/wp-(login|admin|content|json|includes) - [G,L]\n"
# that rule is already gone; anchor on the xxmlrpc rule instead
anchor = "    RewriteRule ^/xmlrpc\\.php - [G,L]\n"
add = anchor + "    RewriteRule ^/index\\.php/(.*)$ /$1 [R=301,L]\n"
if "RewriteRule ^/index\\.php/(.*)$" not in s:
    if anchor not in s:
        raise SystemExit('anchor rule not found')
    s = s.replace(anchor, add, 1)
open(conf, 'w').write(s)
print('legacy /index.php/ redirect added')
