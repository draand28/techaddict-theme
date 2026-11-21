#!/bin/bash
echo "=== access-log lines for removed shells"
grep -hE 'wp-(customize|xmltec|xmlrpc|intec)\.php|mdudql|rss-tec\.svg|options-fafjqn|ms-dbaltr|elyqpn|eojgsa|lopbvy|lwgztx' /var/log/apache2/*access*.log 2>/dev/null | cut -c1-220 | head -15
echo
echo "=== exact malicious filenames anywhere under /var/www"
find /var/www \( -name 'wp-xmltec.php' -o -name 'wp-intec.php' -o -name 'wp-customize.php' -o -name 'wp-xmlrpc.php' \
	-o -name 'rss-tec.svg' -o -name '.mdudql.php' -o -name 'options-fafjqn.php' -o -name 'ms-dbaltr.php' \
	-o -name 'elyqpn.php' -o -name '.eojgsa.php' -o -name '.lopbvy.php' -o -name '.lwgztx.php' \
	-o -name 'class-wp-rest-autosaves-controller-duotone.php' -o -name 'Fe-calendar.php' \) 2>/dev/null
echo
echo "=== hardcoded shell password hashes"
grep -rl 'e9b41d635eb83057eedb535bdd6d5456\|5152f9348705e9a3645e9c9055bddef7d62ada27\|c16dfb9255d73f3041c2dc7d80eed086\|0007ddd64a53dbc7aaec3629fb7bc765' /var/www 2>/dev/null | head
