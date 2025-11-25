FROM  debian:oldstable-slim

RUN   apt update
RUN   apt install -y \
	      nginx \
        openssl

COPY  ./conf/nginx.conf  /etc/nginx/conf.d

RUN   mkdir -p /etc/nginx/ssl
RUN   openssl req -x509 -newkey rsa:2048 -nodes \
        -keyout /etc/nginx/ssl/kkaiyawo.key \
        -out /etc/nginx/ssl/kkaiyawo.crt \
        -days 7 \
        -subj "/C=TH/ST=bangkok/L=Bangkok/O=42/OU=kkaiyawo/CN=kkaiyawo.42.fr"

RUN   mkdir -p /run/nginx

RUN   rm -f /var/log/nginx/access.log /var/log/nginx/error.log && \
	    ln -s /dev/stdout /var/log/nginx/access.log  && \
	    ln -s /dev/stderr /var/log/nginx/error.log

# Change to 443 when SSL is implemented
EXPOSE 443

# Placeholder when volumes are not implemented
#COPY  ./tools/index.php /var/www/html/index.php
RUN   mkdir -p /var/www/html
WORKDIR /var/www/html

CMD   ["nginx", "-g", "daemon off;"]
