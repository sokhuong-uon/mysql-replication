#!/bin/bash
set -e

# Create necessary directories and set permissions
mkdir -p /var/log/mysql /var/lib/mysql
chown -R mysql:mysql /var/log/mysql /var/lib/mysql
chmod 755 /var/log/mysql

# Start MySQL
docker-entrypoint.sh mysqld &

# Wait for MySQL to be ready
until mysqladmin ping -h"localhost" --silent; do
  sleep 1
done

# Set up replication
mysql -e "change replication source to \
source_host='$PRIMARY_DATABASE_HOST', \
source_ssl=1, \
source_ssl_ca='/etc/mysql/certs/ca.pem', \
source_ssl_cert='/etc/mysql/certs/client-cert.pem', \
source_ssl_key='/etc/mysql/certs/client-key.pem', \
get_source_public_key=1;"

# Keep the container running
wait