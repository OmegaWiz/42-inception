FROM debian:bullseye-slim

WORKDIR /app

COPY ./conf/requirements.txt ./

RUN apt-get update &&\
	cat ./requirements.txt | xargs apt-get install -y

COPY ./conf/nginx.conf .

COPY ./tools/index.html .

EXPOSE 443

CMD ["nginx", "-g", "daemon off", "-c", "/app/nginx.conf;"]
