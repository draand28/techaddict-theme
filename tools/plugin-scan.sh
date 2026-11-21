#!/bin/bash
cd /var/www/techaddict.ro/html/wp-content/plugins/wp-piwik || exit 1
for f in libs/matomo-php-tracker/Seo.php proxy/StorageCountry.php; do
	echo "=== $f"
	stat -c '%y %s' "$f"
	head -c 320 "$f"
	echo
done
echo
echo "=== per-plugin checksum verification"
cd /var/www/techaddict.ro/html || exit 1
for p in akismet cookie-notice customify disable-wp-new-user-notification google-sitemap-generator insert-headers-and-footers pixelgrade-assistant ssh-sftp-updater-support who-stole-the-text-justify-button wp-file-manager wp-mail-smtp wpforms-lite dx-delete-attached-media rollback-update-failure wp-piwik; do
	out=$(sudo -u www-data wp --path="$PWD" plugin verify-checksums "$p" 2>&1)
	code=$?
	echo "$code $p"
	if [ "$code" -ne 0 ]; then echo "$out" | tail -4; fi
done
echo
echo "=== theme checksums"
sudo -u www-data wp --path="$PWD" theme verify-checksums --all 2>&1 | tail -8
