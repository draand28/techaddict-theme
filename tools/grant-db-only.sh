#!/bin/bash
# Grant only the databases used by live services. No global privileges.
set -e
C=ix-mysql8-mysql8-1
ROOTPW=$(docker inspect "$C" | python3 -c '
import json,sys
cfg=json.load(sys.stdin)[0]["Config"]["Env"]
for e in cfg:
    if e.startswith("MYSQL_ROOT_PASSWORD="):
        print(e.split("=",1)[1]); break
')
docker exec -i "$C" mysql -uroot -p"$ROOTPW" <<'SQL'
GRANT ALL PRIVILEGES ON `ade`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `reforme`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `nubis_site`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_authme`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_bungeeauth`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_forum`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_killstats`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_onlinetime`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_panel`.* TO 'draand28'@'%';
GRANT ALL PRIVILEGES ON `tcn_phpbb3`.* TO 'draand28'@'%';
FLUSH PRIVILEGES;
SHOW GRANTS FOR 'draand28'@'%';
SQL
