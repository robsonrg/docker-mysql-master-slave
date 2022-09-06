# Docker MySQL replication

MySQL 8 replication (master-slave) with using Docker.

> Initially it is a copy of the article *MySQL Master-Slave Replication using Docker* by Vladyslav Babak, but I want to make new implementations in the future for studies and experiments.
>
> Visit the article: https://hackernoon.com/mysql-master-slave-replication-using-docker-3pp3u97

## Run

To run this examples you will need to start containers with "docker-compose" and after starting setup replication. See commands inside `./build.sh`.

#### Create 2 MySQL containers with primary-replica row-based replication

```sh
$ sh ./build.sh
```

#### Make changes to primary

```sh
$ docker exec mysql_primary sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'create table code(code int); insert into code values (100), (200)'"
```

#### Read changes from replica

```
docker exec mysql_replica sh -c "export MYSQL_PWD=111; mysql -u root mydb -e 'select * from code \G'"
```

## Troubleshooting

#### Check Logs

```
docker-compose logs
```

#### Start containers in "normal" mode

> Go through "build.sh" and run command step-by-step.

#### Check running containers

```
docker-compose ps
```

#### Clean data dir

```sh
$ rm -rf ./primary/data/*
$ rm -rf ./replica/data/*
```

#### Run command inside "mysql_primary"

```sh
$ docker exec mysql_primary sh -c 'mysql -u root -p111 -e "SHOW MASTER STATUS \G"'
```

#### Run command inside "mysql_replica"

```sh
$ docker exec mysql_replica sh -c 'mysql -u root -p111 -e "SHOW SLAVE STATUS \G"'
```

#### Enter into "mysql_primary"

```sh
$ docker exec -it mysql_primary bash
```

#### Enter into "mysql_replica"

```sh
$ docker exec -it mysql_replica bash
```
