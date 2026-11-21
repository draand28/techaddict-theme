#!/bin/bash
# Compare the live core against the clean WordPress release tree.
SITE=/var/www/techaddict.ro/html
CLEAN=/root/techaddict-cleanup/wordpress
echo "=== files that exist in the site but not in the clean release (core paths only)"
cd "$SITE" || exit 1
find . -type f \( -name '*.php' -o -name '*.phtml' -o -name '*.phar' \) \
	-not -path './wp-content/*' -not -path './forum/*' -not -path './wp-includes/*' -not -path './wp-admin/*' \
	| while read -r f; do [ -e "$CLEAN/$f" ] || echo "$f"; done
echo
echo "=== root-level php files"
find . -maxdepth 1 -type f -name '*.php' | sort | while read -r f; do [ -e "$CLEAN/$f" ] || echo "EXTRA $f"; done
echo
echo "=== content diff, wp-includes + wp-admin (names only)"
diff -rq "$CLEAN/wp-includes" "$SITE/wp-includes" 2>/dev/null | head -40
diff -rq "$CLEAN/wp-admin" "$SITE/wp-admin" 2>/dev/null | head -40
echo
echo "=== root php files differing from clean release"
for f in "$CLEAN"/*.php; do
	b=$(basename "$f")
	[ -f "$SITE/$b" ] || { echo "MISSING $b"; continue; }
	cmp -s "$f" "$SITE/$b" || echo "DIFF $b"
done
