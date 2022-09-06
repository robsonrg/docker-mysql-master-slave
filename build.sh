#!/bin/bash

docker-compose down -v
rm -rf ./primary/data/*
rm -rf ./replica/data/*
docker-compose build
docker-compose up -d

until docker exec mysql_primary sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_primary database connection..."
    sleep 4
done

priv_stmt='CREATE USER "mydb_replica_user"@"%" IDENTIFIED BY "mydb_replica_pwd"; GRANT REPLICATION SLAVE ON *.* TO "mydb_replica_user"@"%"; FLUSH PRIVILEGES;'
docker exec mysql_primary sh -c "export MYSQL_PWD=111; mysql -u root -e '$priv_stmt'"

echo "***Primary ok"

until docker-compose exec mysql_replica sh -c 'export MYSQL_PWD=111; mysql -u root -e ";"'
do
    echo "Waiting for mysql_replica database connection..."
    sleep 4
done

MS_STATUS=`docker exec mysql_primary sh -c 'export MYSQL_PWD=111; mysql -u root -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk '{print $6}'`
CURRENT_POS=`echo $MS_STATUS | awk '{print $7}'`

start_replica_stmt="CHANGE MASTER TO MASTER_HOST='mysql_primary',MASTER_USER='mydb_replica_user',MASTER_PASSWORD='mydb_replica_pwd',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_replica_cmd='export MYSQL_PWD=111; mysql -u root -e "'$start_replica_stmt'"'
docker exec mysql_replica sh -c "$start_replica_cmd"

echo "***Replica ok"

docker exec mysql_replica sh -c "export MYSQL_PWD=111; mysql -u root -e 'SHOW SLAVE STATUS \G'"
