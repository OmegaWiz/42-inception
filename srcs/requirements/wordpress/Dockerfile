FROM debian:oldstable-slim

RUN apt-get update \
 && apt-get install -y \
      wget \
      curl \
      bash \
      vim \
      lsb-release \
      ca-certificates \
      apt-transport-https

RUN curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
 && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
 && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
 && apt-get update \
 && apt-get install -y \
      php8.2 \
      php8.2-cli \
      php8.2-fpm \
      php8.2-mysqli \
      php8.2-pdo-mysql \
      php8.2-gd \
      php8.2-curl \
      php8.2-mbstring \
      php8.2-xml \
      php8.2-zip \
      mariadb-client \
 && rm -rf /var/lib/apt/lists/*

# prepare directory for runtime data
RUN mkdir -p /var/www/html \
 && mkdir -p /run/php

# # installing wordpress
# RUN curl -O https://wordpress.org/latest.tar.gz \
#  && tar -xzf latest.tar.gz \
#  && mv wordpress/* /var/www/html/ \
#  && rm -rf wordpress latest.tar.gz

# install wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
 && chmod +x wp-cli.phar \
 && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

EXPOSE 9000

# config php-fpm
COPY ./conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

RUN touch /var/log/fpm-php.www.log && chmod 666 /var/log/fpm-php.www.log \
 && ln -sf /dev/stderr /var/log/fpm-php.www.log \
 && touch /var/log/fpm-php.www.access.log && chmod 666 /var/log/fpm-php.www.access.log \
 && ln -sf /dev/stdout /var/log/fpm-php.www.access.log

COPY ./tools/wp-install.sh /usr/local/bin/wp-install.sh
RUN chmod +x /usr/local/bin/wp-install.sh

ENTRYPOINT ["/usr/local/bin/wp-install.sh"]

CMD ["/usr/sbin/php-fpm8.2", "-F"]
