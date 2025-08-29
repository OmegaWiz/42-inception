FROM debian:oldstable-slim

# Set environment variables for non-interactive installation
#ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install MariaDB server
RUN apt-get update \
    && apt-get install -y mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/mysqld \
 && chown -R mysql:mysql /var/run/mysqld \
 && chmod 777 /var/run/mysqld

# Expose the default MariaDB port
EXPOSE 3306

COPY ./tools/start.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT [ "/usr/local/bin/start.sh" ]

# Start MariaDB when the container launches
CMD ["mysqld", "--bind-address=0.0.0.0", "--user=mysql"]
