#!/bin/bash
set -e
cd /var/www/techaddict.ro/html
sudo -u www-data wp --path="$PWD" option delete wpcode_snippets 2>&1 | tail -1 || true
sudo -u www-data wp --path="$PWD" cache flush >/dev/null 2>&1 || true
sudo -u www-data wp --path="$PWD" transient delete --all >/dev/null 2>&1 || true
echo "option after delete:"
sudo -u www-data wp --path="$PWD" option get wpcode_snippets 2>&1 | head -1 || true
echo "page check:"
curl -s https://techaddict.ro/20-de-euro-gratuit/?nocache=1 -o /tmp/ta-post5.html
echo "occurrences: $(grep -c 'wp_password_change_notification' /tmp/ta-post5.html || true)"
head -c 200 /tmp/ta-post5.html
