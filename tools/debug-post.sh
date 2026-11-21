#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
echo "=== post"
ID=$($S post list --name=20-de-euro-gratuit --field=ID 2>/dev/null | head -1)
echo "ID=$ID"
$S post get "$ID" --field=post_content 2>/dev/null | head -40
echo
echo "=== wpcode snippet 123 meta"
$S post meta list 123 --format=table 2>/dev/null
echo "=== image URLs in content"
$S post get "$ID" --field=post_content 2>/dev/null | grep -oE 'src="[^"]+"' | head -10
