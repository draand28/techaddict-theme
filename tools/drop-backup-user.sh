#!/bin/bash
set -e
C=ix-mysql8-mysql8-1
ROOTPW=$(docker inspect "$C" | python3 -c '
import json,sys
for e in json.load(sys.stdin)[0]["Config"]["Env"]:
    if e.startswith("MYSQL_ROOT_PASSWORD="):
        print(e.split("=",1)[1]); break
')
docker exec -i "$C" mysql -uroot -p"$ROOTPW" -e "DROP USER IF EXISTS 'backup_GWH5id'@'%'; SELECT user,host FROM mysql.user WHERE user LIKE 'backup%';"