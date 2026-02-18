#!/bin/bash

# Tour & Travel ERP - Native Frontend Deployment Script
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
log "Deploying Frontend (Native)"
log "========================================="

# Step 1: Pull latest code
log "Step 1: Pulling latest code from dev branch..."
cd /var/www/tourtravel/frontend
git fetch origin
git checkout dev
git pull origin dev

# Step 2: Install dependencies
log "Step 2: Installing dependencies..."
npm install

# Step 3: Build frontend
log "Step 3: Building frontend..."
npm run build

# Step 4: Deploy to nginx
log "Step 4: Deploying to nginx..."
sudo rm -rf /var/www/html/*
sudo cp -r dist/* /var/www/html/

# Step 5: Reload nginx
log "Step 5: Reloading nginx..."
sudo nginx -t
sudo systemctl reload nginx

log "========================================="
log "Frontend deployment completed!"
log "========================================="
log "Access: http://31.97.220.52"
log "========================================="

exit 0
