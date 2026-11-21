#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
echo "=== files"
grep -rl 'wp_password_change_notification' . --include='*.php' --include='*.txt' --include='*.json' 2>/dev/null | head -10
echo "=== options"
$S db query "SELECT option_name, LEFT(option_value,120) FROM wp_options WHERE option_value LIKE '%wp_password_change_notification%';" 2>/dev/null
echo "=== posts/meta"
$S db query "SELECT ID,post_type FROM wp_posts WHERE post_content LIKE '%wp_password_change_notification%';" 2>/dev/null
$S db query "SELECT post_id,meta_key FROM wp_postmeta WHERE meta_value LIKE '%wp_password_change_notification%' LIMIT 10;" 2>/dev/null
echo "=== wpcode options"
$S db query "SELECT option_name, LENGTH(option_value) FROM wp_options WHERE option_name LIKE '%wpcode%';" 2>/dev/null
