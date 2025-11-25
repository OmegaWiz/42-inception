#!/bin/sh

# Read Docker secrets if they exist, otherwise use environment variables
if [ -f /run/secrets/mysql_root_password ]; then
    MYSQL_ROOT_PASSWORD=$(cat $MYSQL_ROOT_PASSWORD_FILE)
fi

if [ -f /run/secrets/mysql_password ]; then
    MYSQL_PASSWORD=$(cat $MYSQL_PASSWORD_FILE)
fi

# Ensure required environment variables are set
if [ -z "$MYSQL_ROOT_PASSWORD" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ]; then
    echo "Error: Required environment variables are not set"
    echo "MYSQL_ROOT_PASSWORD, MYSQL_PASSWORD, MYSQL_DATABASE, and MYSQL_USER must be defined"
    exit 1
fi


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}
warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}
error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

DATADIR="/var/lib/mysql"

# Ensure log directory and datadir exist and are owned by mysql
LOG_DIR="/var/log/mysql"
mkdir -p "$LOG_DIR" "$DATADIR"
chown -R mysql:mysql "$LOG_DIR" "$DATADIR" 2>/dev/null || true
chmod 750 "$LOG_DIR" "$DATADIR" 2>/dev/null || true

# Create a MariaDB config fragment to enable comprehensive logging
CONF_DIR="/etc/mysql/conf.d"
LOG_CONF="$CONF_DIR/zz-logging.cnf"
mkdir -p "$CONF_DIR"
cat > "$LOG_CONF" <<EOF
[mysqld]
# General query log: logs all statements (may be very verbose)
general_log = ON
general_log_file = $LOG_DIR/general.log

# Error log
log_error = $LOG_DIR/error.log

# Slow query log
slow_query_log = ON
slow_query_log_file = $LOG_DIR/slow.log
long_query_time = 1
log_output = FILE

# Verbosity
log_warnings = 2

# Optional: enable binary logging to capture all changes (uncomment if desired)
# log_bin = $LOG_DIR/mysql-bin
# binlog_format = MIXED
EOF

# Ensure files exist and are owned by mysql
: > "$LOG_DIR/general.log" 2>/dev/null || true
: > "$LOG_DIR/error.log" 2>/dev/null || true
: > "$LOG_DIR/slow.log" 2>/dev/null || true
chown mysql:mysql "$LOG_DIR/"*.log 2>/dev/null || true
chmod 640 "$LOG_DIR/"*.log 2>/dev/null || true

if [ ! -d "$DATADIR/mysql" ]; then
    log "Database directory not found. Initializing database..."
    mariadb_install_db --user=mysql --datadir="$DATADIR"
fi
log "MariaDB data directory initialized successfully."


log "Starting MariaDB for secure installation"
mariadbd-safe --user=mysql

log "Waiting for MariaDB to start..."
i=0
while [ $i -lt 60 ]; do
    if ! mariadb-admin ping --silent; then
        log "MariaDB service has started."
        break
    fi
    sleep 1
    i=$((i + 1))
done
if [ $i -eq 60 ]; then
    error "MariaDB failed to start within 60 seconds."
    kill $(pgrep -u mysql)
    exit 1
fi

log "ensuring secure installation..."
log "Setting root password..."
mariadb-admin -u root password "${MYSQL_ROOT_PASSWORD}"
log "Removing remote root access..."
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "DELETE FROM mysql.user WHERE User = 'root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
log "Removing anonymous users..."
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "DELETE FROM mysql.user WHERE User = '';"
log "Removing test database..."
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" drop test
log "Reloading privilege tables..."
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" flush-privileges
log "MariaDB secure installation completed."

log "Creating user and database..."
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e \
    "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" flush-privileges
log "User and database created."

log "Shutting down temporary MariaDB server..."
mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait $MYSQL_PID
log "Temporary MariaDB server shut down."

exec "$@"
