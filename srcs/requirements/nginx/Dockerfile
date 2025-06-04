FROM debian:oldstable

RUN apt update
RUN apt install -y \
	nginx

COPY ./conf/nginx.conf /etc/nginx/conf.d

RUN mkdir -p /run/nginx

RUN rm -f /var/log/nginx/access.log /var/log/nginx/error.log && \
	ln -s /dev/stdout /var/log/nginx/access.log  && \
	ln -s /dev/stderr /var/log/nginx/error.log

# Change to 443 when SSL is implemented
EXPOSE 80

# Placeholder when volumes are not implemented
COPY ./tools/index.php /var/www/html/index.php

CMD ["nginx", "-g", "daemon off;"]
