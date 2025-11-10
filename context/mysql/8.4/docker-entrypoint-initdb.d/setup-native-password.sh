#!/bin/bash
set -e

echo "Setting mysql_native_password for root user..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
    ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL
echo "Root user authentication updated to mysql_native_password"
