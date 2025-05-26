FROM debian:bullseye-slim

WORKDIR /app

RUN pwd

COPY ./conf/requirements.txt ./

RUN apt-get update && \
	cat ./requirements.txt | xargs apt-get install -y

COPY ./tools/ ./

EXPOSE 8080

CMD ["nginx", "-c", "/app/nginx.conf", "-g", "daemon off;"]

