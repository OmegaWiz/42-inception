#!/bin/sh

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
