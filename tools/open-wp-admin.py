#!/usr/bin/env python3
import shutil
conf = '/etc/apache2/sites-enabled/techaddict.ro.conf'
backup = '/root/backups/techaddict-malware-2026-11-21/techaddict.ro.conf.before-wp-admin'
shutil.copy2(conf, backup)
s = open(conf).read()
old = "    RewriteRule ^/wp-(login|admin|content|json|includes) - [G,L]\n"
if old not in s:
    raise SystemExit('block rule not found')
s = s.replace(old, "", 1)
open(conf, 'w').write(s)
print('wp-login/wp-admin block removed; xmlrpc and /picture stay blocked')
