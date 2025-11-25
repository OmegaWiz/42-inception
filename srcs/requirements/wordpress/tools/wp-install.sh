#!/bin/sh

# Wait for MariaDB to be ready
# echo "Waiting for MariaDB to be ready..."
# while ! mysqladmin ping -h"$MYSQL_HOSTNAME" --silent; do
#     sleep 1
# done
# echo "MariaDB is ready."

if [ -f /run/secrets/mysql_password ]; then
    MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
fi

if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat $WP_ADMIN_PASSWORD_FILE)
fi

if [ -f /run/secrets/wp_test_password ]; then
    WP_TEST_PASSWORD=$(cat $WP_TEST_PASSWORD_FILE)
fi

# Ensure required environment variables are set
if  [ -z "$MYSQL_PASSWORD" ] || \
    [ -z "$WP_ADMIN_PASSWORD" ] || \
    [ -z "$WP_TEST_PASSWORD" ] || \
    [ -z "$MYSQL_DATABASE" ] || \
    [ -z "$MYSQL_USER" ] || \
    [ -z "$MYSQL_HOSTNAME" ] || \
    [ -z "$WP_SITE_URL" ] || \
    [ -z "$WP_ADMIN_USER" ] || \
    [ -z "$WP_ADMIN_EMAIL" ] || \
    [ -z "$WP_SITE_TITLE" ] || \
    [ -z "$WP_TEST_USER" ] || \
    [ -z "$WP_TEST_EMAIL" ]; then
    echo "Error: Required environment variables are not set"
    echo "MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD, MYSQL_DATABASE, and MYSQL_USER must be defined"
    exit 1
fi


# if [ -f ./wp-config.php ]
# 	then
# 		echo "wordpress have already been installed"
# 	else
# 		rm -rf *
# 		wget https://wordpress.org/latest.tar.gz
# 		tar -xvf latest.tar.gz
# 		mv wordpress/* .
# 		rm -rf latest.tar.gz
# 		rm -rf wordpress

#     #where envsubst

#     #envsubst < wp-config-temp.php > wp-config.php

# 		cp wp-config-sample.php wp-config.php
# 		sed -i "s/database_name_here/$MYSQL_DATABASE/g" wp-config.php
# 		sed -i "s/username_here/$MYSQL_USER/g" wp-config.php
# 		sed -i "s/password_here/$MYSQL_PASSWORD)/g" wp-config.php
# 		sed -i "s/localhost/$MYSQL_HOSTNAME/g" wp-config.php
# fi

if [ -f /var/www/html/wp-config.php ]; then
    echo "WordPress is already installed."
else
    echo "Installing WordPress..."

    wp core download --allow-root

    echo "Creating wp-config.php file..."
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOSTNAME:3306" \
        --allow-root

    echo "Installing WordPress..."
    wp core install \
        --url="$WP_SITE_URL" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
		--admin_email="$WP_ADMIN_EMAIL" \
        --title="$WP_SITE_TITLE" \
        --allow-root

    echo "Creating test user..."
    wp user create "$WP_TEST_USER" "$WP_TEST_EMAIL" \
        --role=author \
        --user_pass="$WP_TEST_PASSWORD" \
        --allow-root

    echo "WordPress installation complete."
fi

echo "Starting PHP-FPM..."

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
