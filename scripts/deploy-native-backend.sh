#!/bin/bash

# Tour & Travel ERP - Native Backend Deployment Script
# No Docker - Direct deployment

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
log "Deploying Backend (Native)"
log "========================================="

# Step 1: Pull latest code
log "Step 1: Pulling latest code from dev branch..."
cd /var/www/tourtravel/backend
git fetch origin
git checkout dev
git pull origin dev

# Step 2: Build backend
log "Step 2: Building backend..."
cd /var/www/tourtravel/backend/TourTravel.API
dotnet restore
dotnet build -c Release
dotnet publish -c Release -o /var/www/tourtravel/backend/publish

# Step 3: Run migrations
log "Step 3: Running database migrations..."
export PATH="$PATH:$HOME/.dotnet/tools"
dotnet ef database update --project ../TourTravel.Infrastructure

# Step 4: Restart backend service
log "Step 4: Restarting backend service..."
sudo systemctl restart tourtravel-backend

# Wait for service to start
sleep 5

# Step 5: Check health
log "Step 5: Checking backend health..."
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    log "✓ Backend is healthy!"
else
    error "Backend health check failed!"
    log "Checking logs..."
    sudo journalctl -u tourtravel-backend -n 50 --no-pager
    exit 1
fi

log "========================================="
log "Backend deployment completed!"
log "========================================="
log "Check status: sudo systemctl status tourtravel-backend"
log "View logs: sudo journalctl -u tourtravel-backend -f"
log "========================================="

exit 0
