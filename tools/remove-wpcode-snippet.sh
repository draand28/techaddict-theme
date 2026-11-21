#!/bin/bash
set -e
cd /var/www/techaddict.ro/html
sudo -u www-data wp --path="$PWD" post delete 123 --force 2>&1 | tail -2
sudo -u www-data wp --path="$PWD" cache flush >/dev/null 2>&1 || true
echo "remaining snippets:"
sudo -u www-data wp --path="$PWD" post list --post_type=wpcode --fields=ID,post_title,post_status 2>/dev/null
curl -s -o /tmp/ta-post.html -w 'post %{http_code}\n' https://techaddict.ro/20-de-euro-gratuit/
echo "raw snippet occurrences: $(grep -c 'wp_password_change_notification' /tmp/ta-post.html || true)"
