FROM debian:oldstable-slim

RUN apt-get update \
 && apt-get install -y wget \
    curl \
    bash \
    vim \
    php \
    php-mysql \
    php-fpm \
    mariadb-client \
 && rm -rf /var/lib/apt/lists/*

# install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp

# prepare directory for runtime data
RUN mkdir -p /var/www/html \
 && mkdir -p /run/php

WORKDIR /var/www/html

# install wordpress (on runtime)
COPY ./tools/wp-install.sh /usr/local/bin/wp-install.sh
RUN  chmod 755 /usr/local/bin/wp-install.sh

EXPOSE 9000

# config php-fpm
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

RUN touch /var/log/fpm-php.www.log && chmod 666 /var/log/fpm-php.www.log \
 && ln -sf /dev/stderr /var/log/fpm-php.www.log \
 && touch /var/log/fpm-php.www.access.log && chmod 666 /var/log/fpm-php.www.access.log \
 && ln -sf /dev/stdout /var/log/fpm-php.www.access.log

ENTRYPOINT ["/usr/local/bin/wp-install.sh"]

CMD ["/usr/sbin/php-fpm7.4", "-F"]
