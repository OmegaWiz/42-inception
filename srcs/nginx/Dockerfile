FROM debian:bullseye-slim

WORKDIR /app

COPY ./conf/requirements.txt ./

RUN apt-get update && \
	cat ./requirements.txt | xargs apt-get install -y

COPY ./conf/nginx.conf ./

COPY ./srcs/ ./

EXPOSE 8080

CMD ["nginx", "-c", "/app/nginx.conf", "-g", "daemon off;"]
