#!/bin/sh

# Read Docker secrets if they exist, otherwise use environment variables
if [ -f /run/secrets/mysql_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
fi

if [ -f /run/secrets/mysql_password ]; then
    MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
fi

# Ensure required environment variables are set
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ]; then
    echo "Error: Required environment variables are not set"
    echo "MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD, MYSQL_DATABASE, and MYSQL_USER must be defined"
    exit 1
fi

if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

echo "=========================================  Check database $MYSQL_DATABASE ========================================= "

if [ -d /var/lib/mysql/$MYSQL_DATABASE ]
then
    echo "Database has already been installed ..."
else
    echo "Installing MariaDB database..."

    # Initialize the database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql

    # Start MariaDB temporarily for configuration
    mysqld_safe --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!

    # Wait for MySQL to start
    echo "Waiting for MariaDB to start..."
    while ! mysqladmin ping --silent; do
        sleep 1
    done

    echo "MariaDB started. Configuring database..."

    # Set root password and create database/user
    mysql -uroot <<_EOF_
-- Set root password
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$MYSQL_ROOT_PASSWORD');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create database and user
CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';

-- Allow root access from any host
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
_EOF_

    echo "========================================= Stopping temporary MariaDB ========================================= "
    mysqladmin -uroot -p$MYSQL_ROOT_PASSWORD shutdown
    wait $MYSQL_PID
    echo "========================================= MariaDB configuration completed ========================================= "

    echo "Database installation completed successfully!"
fi

echo "========================================= Starting MariaDB ========================================= "
exec "$@"
