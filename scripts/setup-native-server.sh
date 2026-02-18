#!/bin/bash

# Tour & Travel ERP - Native Server Setup (No Docker)
# Ubuntu Server 22.04/24.04
# Server: 31.97.220.52

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
log "Tour & Travel ERP - Native Setup"
log "========================================="

# Step 0: Remove Docker completely
log "Step 0: Removing Docker and cleaning up..."

# Stop all containers
if command -v docker &> /dev/null; then
    log "Stopping all Docker containers..."
    docker stop $(docker ps -aq) 2>/dev/null || true
    
    log "Removing all Docker containers..."
    docker rm $(docker ps -aq) 2>/dev/null || true
    
    log "Removing all Docker images..."
    docker rmi -f $(docker images -aq) 2>/dev/null || true
    
    log "Removing all Docker volumes..."
    docker volume rm $(docker volume ls -q) 2>/dev/null || true
    
    log "Removing all Docker networks..."
    docker network rm $(docker network ls -q) 2>/dev/null || true
    
    log "Removing Docker packages..."
    sudo apt remove -y docker docker-engine docker.io containerd runc docker-compose docker-compose-plugin 2>/dev/null || true
    sudo apt autoremove -y
    sudo apt autoclean
    
    log "Removing Docker directories..."
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd
    sudo rm -rf /etc/docker
    sudo rm -rf /opt/tourtravel
    
    log "Docker removed completely"
else
    log "Docker not installed, skipping removal"
fi

# Step 1: Update system
log "Step 1: Updating system packages..."
sudo apt update
sudo apt upgrade -y

# Step 2: Install PostgreSQL 16
log "Step 2: Installing PostgreSQL 16..."
sudo apt install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
sudo apt install -y postgresql-16 postgresql-contrib-16

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

log "PostgreSQL 16 installed and started"

# Step 3: Install .NET 8 SDK
log "Step 3: Installing .NET 8 SDK..."
cd ~
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt update
sudo apt install -y dotnet-sdk-8.0 aspnetcore-runtime-8.0

log ".NET 8 SDK installed"
dotnet --version

# Step 4: Install Node.js 20 (for frontend if needed later)
log "Step 4: Installing Node.js 20..."
cd ~
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

log "Node.js installed"
node --version
npm --version

# Step 5: Install Nginx
log "Step 5: Installing Nginx..."
sudo apt install -y nginx

sudo systemctl start nginx
sudo systemctl enable nginx

log "Nginx installed and started"

# Step 6: Install Git
log "Step 6: Installing Git..."
sudo apt install -y git

# Step 7: Setup PostgreSQL database and user
log "Step 7: Setting up PostgreSQL database..."

sudo -u postgres psql << EOF
-- Create database
CREATE DATABASE tourtravel_db;

-- Set password for postgres user
ALTER USER postgres WITH PASSWORD 'postgres';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE tourtravel_db TO postgres;

-- Connect to database and grant schema privileges
\c tourtravel_db
GRANT ALL ON SCHEMA public TO postgres;

\q
EOF

log "Database 'tourtravel_db' created with user 'postgres'"

# Step 8: Create application directories
log "Step 8: Creating application directories..."
sudo mkdir -p /var/www/tourtravel/backend
sudo mkdir -p /var/www/tourtravel/frontend
sudo mkdir -p /var/log/tourtravel

# Set ownership
sudo chown -R $USER:$USER /var/www/tourtravel
sudo chown -R $USER:$USER /var/log/tourtravel

# Step 9: Clone repositories
log "Step 9: Cloning repositories..."

# Backend
cd /var/www/tourtravel
git clone -b dev https://github.com/JourvaInternasionalProject/jourva-backend-erp-saas.git backend

# Frontend
git clone -b dev https://github.com/JourvaInternasionalProject/jourva-erp-frontend.git frontend

log "Repositories cloned"

# Step 10: Configure backend appsettings
log "Step 10: Configuring backend..."

cat > /var/www/tourtravel/backend/TourTravel.API/appsettings.Production.json << 'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=tourtravel_db;Username=postgres;Password=postgres;Pooling=true;MinPoolSize=10;MaxPoolSize=100"
  },
  "Jwt": {
    "Secret": "YourSuperSecretJWTKeyMinimum64CharactersLongForSecurity123456",
    "ExpiryMinutes": 60,
    "RefreshExpiryDays": 7
  },
  "Hangfire": {
    "DashboardPassword": "HangfireAdmin2024!"
  }
}
EOF

# Also update appsettings.json for migrations
cat > /var/www/tourtravel/backend/TourTravel.API/appsettings.json << 'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning",
      "Microsoft.EntityFrameworkCore": "Information"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=tourtravel_db;Username=postgres;Password=postgres"
  }
}
EOF

# Step 11: Build backend
log "Step 11: Building backend..."
cd /var/www/tourtravel/backend/TourTravel.API
dotnet restore
dotnet build -c Release
dotnet publish -c Release -o /var/www/tourtravel/backend/publish

log "Backend built successfully"

# Step 12: Install EF Core tools and run migrations
log "Step 12: Running database migrations..."
dotnet tool install --global dotnet-ef || true
export PATH="$PATH:$HOME/.dotnet/tools"

cd /var/www/tourtravel/backend/TourTravel.API
dotnet ef database update --project ../TourTravel.Infrastructure

log "Database migrations completed"

# Step 13: Create systemd service for backend
log "Step 13: Creating systemd service for backend..."

sudo tee /etc/systemd/system/tourtravel-backend.service > /dev/null << EOF
[Unit]
Description=Tour & Travel ERP Backend API
After=network.target postgresql.service

[Service]
Type=simple
User=$USER
WorkingDirectory=/var/www/tourtravel/backend/publish
ExecStart=/usr/bin/dotnet /var/www/tourtravel/backend/publish/TourTravel.API.dll
Restart=always
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=tourtravel-backend
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=ASPNETCORE_URLS=http://localhost:5000
TimeoutStartSec=60

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tourtravel-backend
sudo systemctl start tourtravel-backend

log "Backend service created and started"

# Step 14: Build frontend
log "Step 14: Building frontend..."
cd /var/www/tourtravel/frontend

# Create .env file
cat > .env << 'EOF'
VITE_API_URL=http://31.97.220.52/api
EOF

npm install
npm run build

# Copy build to nginx directory
sudo rm -rf /var/www/html/*
sudo cp -r dist/* /var/www/html/

log "Frontend built and deployed"

# Step 15: Configure Nginx
log "Step 15: Configuring Nginx..."

sudo tee /etc/nginx/sites-available/tourtravel > /dev/null << 'EOF'
server {
    listen 80;
    server_name 31.97.220.52;

    # Frontend
    location / {
        root /var/www/html;
        try_files $uri $uri/ /index.html;
        
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Backend API
    location /api/ {
        proxy_pass http://localhost:5000/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # Swagger
    location /swagger {
        proxy_pass http://localhost:5000/swagger;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }

    # Health check
    location /health {
        proxy_pass http://localhost:5000/health;
        access_log off;
    }

    # Hangfire
    location /hangfire {
        proxy_pass http://localhost:5000/hangfire;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/tourtravel /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test and reload nginx
sudo nginx -t
sudo systemctl reload nginx

log "Nginx configured"

# Step 16: Configure firewall
log "Step 16: Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

log "Firewall configured"

log "========================================="
log "Setup completed successfully!"
log "========================================="
log ""
log "Services status:"
sudo systemctl status postgresql --no-pager -l
sudo systemctl status tourtravel-backend --no-pager -l
sudo systemctl status nginx --no-pager -l
log ""
log "Access your application:"
log "  Frontend: http://31.97.220.52"
log "  Backend API: http://31.97.220.52/api"
log "  Swagger: http://31.97.220.52/swagger"
log "  Health: http://31.97.220.52/health"
log ""
log "Useful commands:"
log "  Backend logs: sudo journalctl -u tourtravel-backend -f"
log "  Backend restart: sudo systemctl restart tourtravel-backend"
log "  Nginx logs: sudo tail -f /var/log/nginx/error.log"
log "  PostgreSQL: sudo -u postgres psql tourtravel_db"
log "========================================="

exit 0
