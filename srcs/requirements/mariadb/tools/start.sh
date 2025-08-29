#!/bin/sh

if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

echo "=========================================  Check file in $MYSQL_DATABASE ========================================= "

if [ -d /var/lib/mysql/$MYSQL_DATABASE ]
then

    echo "Database has already installed ..."

else

    mysql_install_db --user=mysql
    chown -R mysql:mysql /var/lib/mysql

    /etc/init.d/mariadb start

    mariadb-secure-installation <<_EOF_

n
Y
$MYSQL_ROOT_PASSWORD
$MYSQL_ROOT_PASSWORD
Y
n
Y
Y
_EOF_

    echo "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE; GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;" | mysql -uroot -p$MYSQL_ROOT_PASSWORD
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;" | mysql -uroot -p$MYSQL_ROOT_PASSWORD

    mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE </usr/local/bin/wordpress.sql

    echo "========================================= Start Stop mysql ========================================= "
    sed -i "s|password =|password = $MYSQL_ROOT_PASSWORD|g" /etc/mysql/debian.cnf
    /etc/init.d/mariadb stop
    echo "========================================= Finish Stop mysql ========================================= "

    echo "Database installs Success !!!"
fi

echo "========================================= Start executer command ========================================= "
exec "$@"
