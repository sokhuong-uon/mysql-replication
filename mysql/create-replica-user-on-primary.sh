#!/bin/bash
set -e

mysql -u root -p${MYSQL_ROOT_PASSWORD} <<-EOSQL
  create user if not exists '${MYSQL_REPLICATION_USER}'@'%' identified with caching_sha2_password by '${MYSQL_REPLICATION_PASSWORD}';
  grant replication slave on *.* to '${MYSQL_REPLICATION_USER}'@'%';
  flush privileges;
EOSQL