#!/bin/sh

if [ -f ./wp-load.php ]; then
    echo "Wordpress has already been installed"
else
    wp core download --allow-root
fi

if [ ! -f ./wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOSTNAME" \
        --allow-root
else
    echo "WordPress configuration already exists"
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install \
        --url="$WP_SITE_URL" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --allow-root
else
    echo "WordPress core already installed"
fi

if ! wp user exists "$WP_TEST_USER" --allow-root 2>/dev/null; then
    wp user create "$WP_TEST_USER" "$WP_TEST_EMAIL" \
        --user_pass="$WP_TEST_PASSWORD" \
        --allow-root
else
    echo "User $WP_TEST_USER already exists"
fi
