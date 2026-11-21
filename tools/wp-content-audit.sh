#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
echo "=== wpcode snippets"
$S post list --post_type=wpcode --fields=ID,post_title,post_status 2>/dev/null
for id in $($S post list --post_type=wpcode --field=ID 2>/dev/null); do
	echo "-- snippet $id"
	$S post get "$id" --field=post_content 2>/dev/null | head -20
done
echo "=== insert headers settings"
$S option get ihaf_settings 2>/dev/null | head -40
echo "=== suspicious scripts in options"
$S db query "SELECT option_name, LEFT(option_value,200) FROM wp_options WHERE option_value LIKE '%<script%' AND option_name NOT LIKE '%transient%' LIMIT 15;" 2>/dev/null
echo "=== wpcode settings"
$S db query "SELECT option_name FROM wp_options WHERE option_name LIKE '%wpcode%' LIMIT 15;" 2>/dev/null
echo "=== active plugin options of interest"
$S db query "SELECT option_name FROM wp_options WHERE option_name IN ('akismet_settings','cookie_notice_settings','wpforms_settings') LIMIT 10;" 2>/dev/null
