#!/bin/bash

# Tour & Travel ERP - PostgreSQL Remote Access Setup
# Allow remote connections to PostgreSQL from your laptop

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

log "========================================="
log "PostgreSQL Remote Access Setup"
log "========================================="

# Step 1: Configure PostgreSQL to listen on all interfaces
log "Step 1: Configuring PostgreSQL to accept remote connections..."

PG_VERSION=$(psql --version | grep -oP '\d+' | head -1)
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

# Backup original files
sudo cp $PG_CONF ${PG_CONF}.backup
sudo cp $PG_HBA ${PG_HBA}.backup

# Update postgresql.conf to listen on all addresses
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF
sudo sed -i "s/listen_addresses = 'localhost'/listen_addresses = '*'/" $PG_CONF

log "PostgreSQL configured to listen on all interfaces"

# Step 2: Update pg_hba.conf to allow remote connections
log "Step 2: Updating pg_hba.conf..."

# Add rule to allow connections from anywhere (you can restrict this to your IP)
echo "" | sudo tee -a $PG_HBA
echo "# Allow remote connections" | sudo tee -a $PG_HBA
echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a $PG_HBA

log "pg_hba.conf updated"

# Step 3: Restart PostgreSQL
log "Step 3: Restarting PostgreSQL..."
sudo systemctl restart postgresql

# Step 4: Open firewall port
log "Step 4: Opening PostgreSQL port in firewall..."
sudo ufw allow 5432/tcp

log "Firewall configured"

# Step 5: Get server IP
SERVER_IP=$(curl -s ifconfig.me)

log "========================================="
log "PostgreSQL Remote Access Configured!"
log "========================================="
log ""
log "Connection Details:"
log "  Host: $SERVER_IP (or 31.97.220.52)"
log "  Port: 5432"
log "  Database: tourtravel_db"
log "  Username: postgres"
log "  Password: postgres"
log ""
log "Connection String:"
log "  Host=$SERVER_IP;Port=5432;Database=tourtravel_db;Username=postgres;Password=postgres"
log ""
log "Test from your laptop:"
log "  psql -h $SERVER_IP -U postgres -d tourtravel_db"
log ""
log "GUI Tools (DBeaver, pgAdmin, TablePlus):"
log "  Host: $SERVER_IP"
log "  Port: 5432"
log "  Database: tourtravel_db"
log "  Username: postgres"
log "  Password: postgres"
log ""
log "SECURITY WARNING:"
log "  This allows connections from ANY IP address!"
log "  For production, restrict to specific IPs in pg_hba.conf"
log "  Example: host all all YOUR_IP/32 md5"
log "========================================="

exit 0
