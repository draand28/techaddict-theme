#!/bin/bash
echo "reforme:"; grep -oE "DB_NAME'?, *'[^']*'" /var/www/reforme.ro/html/wp-config.php | head -1
echo "adelina:"; grep -oE "DB_NAME'?, *'[^']*'" /var/www/adelina.party/html/wp-config.php | head -1
echo "nubis:"; grep -nE "dbname|database|db_name|mysqli|PDO" /var/www/nubis.ro/html/config.php | head -8
echo "terracactus:"; grep -nE "dbname|dbuser" /var/www/terracactus.net/html/config.php | head -4
echo "panel:"; grep -E "DB_DATABASE|DB_USERNAME" /var/www/ciprian.party/html/paneltcn/.env
