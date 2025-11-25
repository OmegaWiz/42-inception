#!/bin/sh

# Read Docker secrets if they exist, otherwise use environment variables
if [ -f /run/secrets/mysql_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat ${MYSQL_ROOT_PASSWORD_FILE})
fi

if [ -f /run/secrets/mysql_password ]; then
    MYSQL_PASSWORD=$(cat ${MYSQL_PASSWORD_FILE})
fi

if [ -f /run/secrets/wp_admin_password ]; then
    WP_ADMIN_PASSWORD=$(cat ${WP_ADMIN_PASSWORD_FILE})
fi

if [ -f /run/secrets/wp_test_password ]; then
    WP_TEST_PASSWORD=$(cat ${WP_TEST_PASSWORD_FILE})
fi

# Ensure required environment variables are set
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$WP_ADMIN_PASSWORD" ] || [ -z "$WP_TEST_PASSWORD" ]; then
    echo "Error: Required environment variables are not set"
    echo "MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD, MYSQL_DATABASE, MYSQL_USER, WP_ADMIN_PASSWORD, and WP_TEST_PASSWORD must be defined"
    exit 1
fi


# Wait for MariaDB to be ready
# echo "Waiting for MariaDB to be ready..."
# while ! mysqladmin ping -h"$MYSQL_HOSTNAME" --silent; do
#     sleep 1
# done
# echo "MariaDB is ready."

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
        --skip-email \
        --allow-root
        # --title="$WP_TITLE" \

    echo "Creating test user..."
    wp user create "$WP_TEST_USER" "$WP_TEST_EMAIL" \
        --role=author \
        --user_pass="$WP_TEST_PASSWORD" \
        --allow-root

    echo "WordPress installation complete."
fi

echo "Starting PHP-FPM..."
exec "$@"
