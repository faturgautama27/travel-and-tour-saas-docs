#!/bin/bash

# Tour & Travel ERP - SSL & Subdomain Setup
# Setup Let's Encrypt SSL for multiple subdomains

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

# Set domains
FRONTEND_DOMAIN="dev.jourva.com"
BACKEND_DOMAIN="apidev.jourva.com"

log "========================================="
log "Setting up SSL for:"
log "  Frontend: $FRONTEND_DOMAIN"
log "  Backend: $BACKEND_DOMAIN"
log "========================================="

# Step 1: Install Certbot
log "Step 1: Installing Certbot..."
sudo apt update
sudo apt install -y certbot python3-certbot-nginx

# Step 2: Create Nginx configs FIRST (before SSL)
log "Step 2: Creating Nginx configurations..."

# Frontend config (HTTP only first)
sudo tee /etc/nginx/sites-available/frontend > /dev/null << EOF
server {
    listen 80;
    server_name $FRONTEND_DOMAIN;

    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# Backend config (HTTP only first)
sudo tee /etc/nginx/sites-available/backend > /dev/null << EOF
server {
    listen 80;
    server_name $BACKEND_DOMAIN;

    location / {
        proxy_pass http://localhost:5000/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable sites
sudo ln -sf /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-enabled/tourtravel

# Test and reload
sudo nginx -t
sudo systemctl reload nginx

log "Nginx configs created"

# Step 3: Obtain SSL certificates
log "Step 3: Obtaining SSL certificates..."
log "Make sure DNS A records point to this server IP (31.97.220.52)!"
echo -e "${YELLOW}Press Enter to continue...${NC}"
read

# Get certificate for frontend
sudo certbot --nginx -d $FRONTEND_DOMAIN --non-interactive --agree-tos --email admin@jourva.com || {
    error "Failed to obtain SSL certificate for $FRONTEND_DOMAIN"
    exit 1
}

# Get certificate for backend
sudo certbot --nginx -d $BACKEND_DOMAIN --non-interactive --agree-tos --email admin@jourva.com || {
    error "Failed to obtain SSL certificate for $BACKEND_DOMAIN"
    exit 1
}

log "SSL certificates obtained and installed"

# Step 4: Update Nginx configs with better settings
log "Step 4: Updating Nginx configurations..."

sudo tee /etc/nginx/sites-available/frontend > /dev/null << EOF
server {
    listen 80;
    server_name $FRONTEND_DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $FRONTEND_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$FRONTEND_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$FRONTEND_DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Frontend
    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
        
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# Step 4: Update Nginx configs with better settings
log "Step 4: Updating Nginx configurations..."

sudo tee /etc/nginx/sites-available/frontend > /dev/null << EOF
server {
    listen 80;
    server_name $FRONTEND_DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $FRONTEND_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$FRONTEND_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$FRONTEND_DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        root /var/www/html;
        try_files \$uri \$uri/ /index.html;
        
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
EOF

# Step 5: Configure Nginx for Backend
log "Step 5: Configuring Nginx for backend..."

sudo tee /etc/nginx/sites-available/backend > /dev/null << EOF
server {
    listen 80;
    server_name $BACKEND_DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $BACKEND_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$BACKEND_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$BACKEND_DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Backend API (root path, no /api prefix)
    location / {
        proxy_pass http://localhost:5000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
EOF

# Step 5: Configure Nginx for Backend
log "Step 5: Configuring Nginx for backend..."

sudo tee /etc/nginx/sites-available/backend > /dev/null << EOF
server {
    listen 80;
    server_name $BACKEND_DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $BACKEND_DOMAIN;

    ssl_certificate /etc/letsencrypt/live/$BACKEND_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$BACKEND_DOMAIN/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:5000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
EOF

# Step 6: Enable sites and remove old config
log "Step 6: Enabling sites..."
sudo ln -sf /etc/nginx/sites-available/frontend /etc/nginx/sites-enabled/
sudo ln -sf /etc/nginx/sites-available/backend /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-enabled/tourtravel

# Test and reload nginx
sudo nginx -t
sudo systemctl reload nginx

# Step 7: Setup auto-renewal
log "Step 7: Setting up SSL auto-renewal..."
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Step 8: Update frontend .env
log "Step 8: Updating frontend .env..."
cat > /var/www/tourtravel/frontend/.env << EOF
VITE_API_URL=https://$BACKEND_DOMAIN
EOF

log "Rebuilding frontend..."
cd /var/www/tourtravel/frontend
npm run build
sudo cp -r dist/* /var/www/html/

log "========================================="
log "SSL Setup Completed!"
log "========================================="
log ""
log "Your application is now accessible at:"
log ""
log "Frontend:"
log "  https://$FRONTEND_DOMAIN"
log ""
log "Backend API:"
log "  https://$BACKEND_DOMAIN/api/..."
log "  https://$BACKEND_DOMAIN/swagger"
log "  https://$BACKEND_DOMAIN/health"
log "  https://$BACKEND_DOMAIN/hangfire"
log ""
log "SSL certificates will auto-renew before expiry"
log "Check renewal status: sudo certbot renew --dry-run"
log "========================================="

exit 0
