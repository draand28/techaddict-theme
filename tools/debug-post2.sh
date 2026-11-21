#!/bin/bash
cd /var/www/techaddict.ro/html || exit 1
S="sudo -u www-data wp --path=$PWD"
ID=113
echo "=== post content tail"
$S post get "$ID" --field=post_content 2>/dev/null | tail -40
echo "=== image-ish blocks"
$S post get "$ID" --field=post_content 2>/dev/null | grep -nE 'wp:image|img|attachment|gallery|figure' | head -20
echo "=== featured image"
$S post meta get "$ID" _thumbnail_id 2>/dev/null
echo "=== attachments for post"
$S post list --post_type=attachment --post_parent="$ID" --fields=ID,post_title,guid,post_mime_type 2>/dev/null
echo "=== snippet 123 type meta (all)"
$S db query "SELECT meta_key,meta_value FROM wp_postmeta WHERE post_id=123;" 2>/dev/null
