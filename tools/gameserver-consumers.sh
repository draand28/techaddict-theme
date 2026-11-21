#!/bin/bash
BASE=/var/lib/pterodactyl/volumes
for f in \
	$BASE/274c0164-f37b-496c-aeb3-109d5fbf03db/plugins/fastlogin/config.yml \
	$BASE/274c0164-f37b-496c-aeb3-109d5fbf03db/plugins/onlinetime/config.yml \
	$BASE/274c0164-f37b-496c-aeb3-109d5fbf03db/plugins/snap/plugins/BungeeOnlineTime/settings.yml ; do
	echo "-- $f"
	[ -f "$f" ] || { echo missing; continue; }
	grep -aiE 'host|database|db|user|port' "$f" | head -10
done
echo "=== other volume configs mentioning tcn_ databases"
grep -rIl 'tcn_bungeeauth\|tcn_onlinetime\|tcn_killstats' /var/lib/pterodactyl/volumes 2>/dev/null | head -10
