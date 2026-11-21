#!/bin/bash
set -e
Q=/root/techaddict-cleanup/quarantine/themes
mkdir -p "$Q"
cd /var/www/techaddict.ro/html/wp-content/themes
for t in twentytwentyfour twentytwentyone twentytwentythree; do
	if [ -d "$t" ]; then
		mv "$t" "$Q/$t"
		echo "moved $t"
	fi
done
ls
