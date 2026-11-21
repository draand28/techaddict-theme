#!/bin/bash
set -e
cd /var/www/techaddict.ro/html

# Normalise CRLF first; patterns below assume LF
sed -i 's/\r$//' wp-config.php

# Remove the duplicate early WP_DEBUG
sed -i '/^define( "WP_DEBUG", true );$/d' wp-config.php

# Restore the table prefix that lived on the removed malware line
if ! grep -q '^\$table_prefix' wp-config.php; then
	sed -i "/^\/\*\*#@-\*\/$/a\\
\\
\$table_prefix = 'wp_';" wp-config.php
fi

chown www-data:www-data wp-config.php
php -l wp-config.php
grep -nE '^\$table_prefix|^define\(.?WP_DEBUG|^// Enable WP_DEBUG' wp-config.php
