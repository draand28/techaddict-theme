#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
SUDO="sudo -u www-data"
$SUDO wp --path="$PWD" core update 2>&1 | tail -6
$SUDO wp --path="$PWD" core verify-checksums 2>&1 | tail -2
$SUDO wp --path="$PWD" plugin update --all 2>&1 | tail -15
echo "=== plugins that still fail checksums"
for p in $($SUDO wp --path="$PWD" plugin list --field=name 2>/dev/null); do
	if ! $SUDO wp --path="$PWD" plugin verify-checksums "$p" --quiet >/dev/null 2>&1; then echo "FAIL $p"; fi
done
echo "=== theme updates"
$SUDO wp --path="$PWD" theme list --update=available --fields=name,version,update_version 2>&1 | tail -6
echo "=== core version"
$SUDO wp --path="$PWD" core version 2>&1 | tail -1
