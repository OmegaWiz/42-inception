FROM debian:oldstable-slim

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update package lists and install MariaDB server
RUN apt-get update \
    && apt-get install -y mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /var/run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql \
    && chmod 755 /var/run/mysqld

# Configure MariaDB to listen on all interfaces
# RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Expose the default MariaDB port
EXPOSE 3306

# Copy and set up the start script
COPY ./tools/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT [ "/usr/local/bin/start.sh" ]

# Start MariaDB when the container launches
# CMD ["mysqld", "--user=mysql"]
CMD ["mariadbd-safe", "--user=mysql", "--datadir=/var/lib/mysql", "--bind-address=0.0.0.0", "--port=3306"]
