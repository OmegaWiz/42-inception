#!/bin/sh

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h"$MYSQL_HOSTNAME" --silent; do
    sleep 1
done
echo "MariaDB is ready."

if [ -f ./wp-config.php ]
	then
		echo "wordpress have already been installed"
	else
    rm -rf *
		wget https://wordpress.org/latest.tar.gz
		tar -xvf latest.tar.gz
		mv wordpress/* .
		rm -rf latest.tar.gz
		rm -rf wordpress

    #where envsubst

    #envsubst < wp-config-temp.php > wp-config.php

		cp wp-config-sample.php wp-config.php
    echo $MYSQL_DATABASE
		sed -i "s/database_name_here/$MYSQL_DATABASE/g" wp-config.php
    echo $MYSQL_USER
		sed -i "s/username_here/$MYSQL_USER/g" wp-config.php
    echo $MYSQL_PASSWORD_FILE
    sed -i "s/password_here/$(cat $MYSQL_PASSWORD_FILE)/g" wp-config.php
    echo $MYSQL_HOSTNAME
		sed -i "s/localhost/$MYSQL_HOSTNAME/g" wp-config.php
    echo "done?"
fi

echo "YESSSS"

exec "$@"

# # Read secrets if they exist
# if [ -f "$MYSQL_PASSWORD" ]; then
#     DB_PASSWORD=$(cat "$MYSQL_PASSWORD")
# else
#     DB_PASSWORD="$MYSQL_PASSWORD"
# fi

# if [ -f "$WP_ADMIN_PASSWORD" ]; then
#     ADMIN_PASSWORD=$(cat "$WP_ADMIN_PASSWORD")
# else
#     ADMIN_PASSWORD="$WP_ADMIN_PASSWORD"
# fi

# if [ -f "$WP_TEST_PASSWORD" ]; then
#     TEST_PASSWORD=$(cat "$WP_TEST_PASSWORD")
# else
#     TEST_PASSWORD="$WP_TEST_PASSWORD"
# fi

# if [ -f /var/www/html/wp-config.php ]; then
#     echo "WordPress is already installed."
# else
#     echo "Installing WordPress..."

#     wp core download --allow-root

#     wp config create \
#         --dbname="$MYSQL_DATABASE" \
#         --dbuser="$MYSQL_USER" \
#         --dbpass="$MYSQL_PASSWORD" \
#         --dbhost="$MYSQL_HOSTNAME" \
#         --allow-root

#     wp core install \
#         --url="$WP_SITE_URL" \
#         --admin_user="$WP_ADMIN_USER" \
#         --admin_password="$WP_ADMIN_PASSWORD" \
#         --skip-email \
#         --allow-root
#         # --title="$WP_TITLE" \

#     wp user create "$WP_TEST_USER" "$WP_TEST_EMAIL" \
#         --role=author \
#         --user_pass="$WP_TEST_PASSWORD" \
#         --allow-root

#     echo "WordPress installation complete."
# fi

# echo "Starting PHP-FPM..."
# exec "$@"
