#!/bin/bash

# Tour & Travel ERP - Dev Server Setup Script
# Server: 31.97.220.52
# Branch: dev
# 
# Usage: 
# 1. Upload this script to server
# 2. chmod +x setup-dev-server.sh
# 3. ./setup-dev-server.sh

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO:${NC} $1"
}

# Banner
echo ""
echo "========================================="
echo "  Tour & Travel ERP - Dev Server Setup  "
echo "========================================="
echo ""

# Step 1: Update system
log "Step 1: Updating system..."
apt update && apt upgrade -y

# Step 2: Install essential tools
log "Step 2: Installing essential tools..."
apt install -y git curl wget nano htop net-tools ufw

# Step 3: Install Docker
log "Step 3: Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
else
    info "Docker already installed"
fi

# Install Docker Compose plugin
apt install -y docker-compose-plugin

# Verify Docker
docker --version
docker compose version

# Step 4: Install Node.js 20
log "Step 4: Installing Node.js 20..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
else
    info "Node.js already installed"
fi

node --version
npm --version

# Step 5: Install .NET SDK 8 (for migrations)
log "Step 5: Installing .NET SDK 8..."
if ! command -v dotnet &> /dev/null; then
    wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
    chmod +x dotnet-install.sh
    ./dotnet-install.sh --channel 8.0
    rm dotnet-install.sh
    
    # Add to PATH
    export PATH="$HOME/.dotnet:$PATH"
    echo 'export PATH="$HOME/.dotnet:$PATH"' >> ~/.bashrc
else
    info ".NET SDK already installed"
fi

dotnet --version

# Step 6: Setup GitHub authentication
log "Step 6: Setting up GitHub authentication..."
echo ""
echo "========================================="
echo "  GitHub Authentication Required"
echo "========================================="
echo ""
echo "Choose authentication method:"
echo "1) Personal Access Token (Recommended)"
echo "2) SSH Key"
echo ""
read -p "Enter choice [1-2]: " auth_choice

if [ "$auth_choice" == "1" ]; then
    echo ""
    echo "Generate Personal Access Token:"
    echo "1. Go to: https://github.com/settings/tokens"
    echo "2. Click 'Generate new token (classic)'"
    echo "3. Select scope: 'repo' (full control)"
    echo "4. Generate and copy token"
    echo ""
    read -p "Enter your GitHub Personal Access Token: " github_token
    read -p "Enter your GitHub username: " github_username
    
    # Setup credential helper
    git config --global credential.helper store
    
    AUTH_METHOD="token"
    BACKEND_REPO="https://${github_token}@github.com/JourvaInternasionalProject/jourva-backend-erp-saas.git"
    FRONTEND_REPO="https://${github_token}@github.com/JourvaInternasionalProject/jourva-erp-frontend.git"
    
elif [ "$auth_choice" == "2" ]; then
    # Generate SSH key
    ssh-keygen -t ed25519 -C "server@tourtravel-dev" -f ~/.ssh/github_deploy -N ""
    
    echo ""
    echo "========================================="
    echo "  Add this SSH key to GitHub:"
    echo "========================================="
    cat ~/.ssh/github_deploy.pub
    echo ""
    echo "1. Copy the key above"
    echo "2. Go to: https://github.com/settings/keys"
    echo "3. Click 'New SSH key'"
    echo "4. Paste and save"
    echo ""
    read -p "Press Enter after adding SSH key to GitHub..."
    
    # Configure SSH
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github_deploy
    
    AUTH_METHOD="ssh"
    BACKEND_REPO="git@github.com:JourvaInternasionalProject/jourva-backend-erp-saas.git"
    FRONTEND_REPO="git@github.com:JourvaInternasionalProject/jourva-erp-frontend.git"
else
    error "Invalid choice"
    exit 1
fi

# Step 7: Create project directory
log "Step 7: Creating project directory..."
mkdir -p /opt/tourtravel
cd /opt/tourtravel

# Create subdirectories
mkdir -p nginx postgres-data backup/postgres backup/frontend scripts logs

# Step 8: Clone repositories
log "Step 8: Cloning repositories..."

if [ ! -d "backend" ]; then
    git clone -b dev $BACKEND_REPO backend
    log "Backend cloned"
else
    warning "Backend directory already exists, skipping clone"
fi

if [ ! -d "frontend" ]; then
    git clone -b dev $FRONTEND_REPO frontend
    log "Frontend cloned"
else
    warning "Frontend directory already exists, skipping clone"
fi

# Step 9: Create .env file
log "Step 9: Creating .env file..."

if [ ! -f ".env" ]; then
    cat > .env << 'EOF'
# Database
POSTGRES_DB=tourtravel
POSTGRES_USER=app_user
POSTGRES_PASSWORD=ChangeThisToStrongPassword123!

# Backend
ASPNETCORE_ENVIRONMENT=Development
JWT_SECRET=YourSuperSecretJWTKeyMinimum64CharactersLongForSecurity123456
JWT_EXPIRY_MINUTES=60
JWT_REFRESH_EXPIRY_DAYS=7

# Connection String
DB_CONNECTION_STRING=Host=postgres;Port=5432;Database=tourtravel;Username=app_user;Password=ChangeThisToStrongPassword123!;Pooling=true;MinPoolSize=10;MaxPoolSize=100

# Hangfire
HANGFIRE_DASHBOARD_PASSWORD=ChangeThisPassword123!

# Server
SERVER_IP=31.97.220.52
ENVIRONMENT=development
BRANCH=dev
EOF
    log ".env file created"
    warning "IMPORTANT: Edit /opt/tourtravel/.env and change passwords!"
else
    warning ".env file already exists, skipping"
fi

# Step 10: Create nginx config
log "Step 10: Creating nginx configuration..."

mkdir -p nginx

cat > nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 10M;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    include /etc/nginx/conf.d/*.conf;
}
EOF

cat > nginx/default.conf << 'EOF'
upstream backend_api {
    server backend:5000;
}

server {
    listen 80;
    server_name 31.97.220.52;

    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
        
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    location /api/ {
        proxy_pass http://backend_api/api/;
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

    location /hangfire {
        proxy_pass http://backend_api/hangfire;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /health {
        proxy_pass http://backend_api/health;
        access_log off;
    }
}
EOF

log "Nginx config created"

# Step 11: Create docker-compose.yml
log "Step 11: Creating docker-compose.yml..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: tourtravel-postgres
    restart: always
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: "-E UTF8 --locale=en_US.UTF-8"
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
    ports:
      - "127.0.0.1:5432:5432"
    networks:
      - tourtravel-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: tourtravel-backend
    restart: always
    depends_on:
      postgres:
        condition: service_healthy
    environment:
      ASPNETCORE_ENVIRONMENT: ${ASPNETCORE_ENVIRONMENT}
      ASPNETCORE_URLS: http://+:5000
      ConnectionStrings__DefaultConnection: ${DB_CONNECTION_STRING}
      JWT__Secret: ${JWT_SECRET}
      JWT__ExpiryMinutes: ${JWT_EXPIRY_MINUTES}
      JWT__RefreshExpiryDays: ${JWT_REFRESH_EXPIRY_DAYS}
      Hangfire__DashboardPassword: ${HANGFIRE_DASHBOARD_PASSWORD}
    ports:
      - "127.0.0.1:5000:5000"
    networks:
      - tourtravel-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    image: nginx:alpine
    container_name: tourtravel-nginx
    restart: always
    depends_on:
      - backend
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
      - ./frontend-dist:/usr/share/nginx/html:ro
    networks:
      - tourtravel-network

networks:
  tourtravel-network:
    driver: bridge

volumes:
  postgres-data:
EOF

log "docker-compose.yml created"

# Step 12: Build frontend
log "Step 12: Building frontend..."
cd frontend
npm install
npm run build
cd ..

# Copy dist
cp -r frontend/dist frontend-dist
log "Frontend built and copied to frontend-dist"

# Step 13: Configure firewall
log "Step 13: Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
echo "y" | ufw enable
ufw status

# Step 14: Build and start Docker containers
log "Step 14: Building and starting Docker containers..."
docker compose build backend
docker compose up -d

log "Waiting for containers to start (30 seconds)..."
sleep 30

# Step 15: Run database migrations
log "Step 15: Running database migrations..."
cd backend

# Install EF Core tools
export PATH="$HOME/.dotnet:$PATH"
dotnet tool install --global dotnet-ef || true

# Run migrations
~/.dotnet/tools/dotnet-ef database update || warning "Migration failed, check if backend has migrations"

cd ..

# Step 16: Create deployment scripts
log "Step 16: Creating deployment scripts..."

# Backend deployment script
cat > scripts/deploy-backend-dev.sh << 'EOFSCRIPT'
#!/bin/bash
set -e
PROJECT_DIR="/opt/tourtravel"
BACKEND_DIR="$PROJECT_DIR/backend"
LOG_FILE="/var/log/tourtravel-backend-dev-deploy.log"
BRANCH="dev"

log() { echo -e "\033[0;32m[$(date +'%Y-%m-%d %H:%M:%S')]\033[0m $1" | tee -a $LOG_FILE; }
error() { echo -e "\033[0;31m[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:\033[0m $1" | tee -a $LOG_FILE; }

log "Starting BACKEND DEV deployment..."
cd $BACKEND_DIR
git fetch origin
git checkout $BRANCH
git pull origin $BRANCH || { error "Failed to pull"; exit 1; }

log "Creating database backup..."
BACKUP_FILE="/opt/tourtravel/backup/postgres/pre-backend-dev-deploy_$(date +%Y%m%d_%H%M%S).dump"
docker exec tourtravel-postgres pg_dump -U app_user -Fc tourtravel > $BACKUP_FILE
gzip $BACKUP_FILE

log "Building new backend image..."
cd $PROJECT_DIR
NEW_TAG="backend-dev:$(date +%Y%m%d_%H%M%S)"
docker build -t tourtravel-$NEW_TAG -f backend/Dockerfile backend/ || { error "Build failed"; exit 1; }

log "Starting new backend container..."
docker run -d --name tourtravel-backend-new --network tourtravel-network -p 127.0.0.1:5001:5000 --env-file $PROJECT_DIR/.env -e ASPNETCORE_URLS=http://+:5000 tourtravel-$NEW_TAG

log "Health check..."
sleep 10
for i in {1..30}; do
    if curl -f http://localhost:5001/health > /dev/null 2>&1; then
        log "Health check passed!"
        break
    fi
    [ $i -eq 30 ] && { error "Health check failed"; docker stop tourtravel-backend-new; docker rm tourtravel-backend-new; exit 1; }
    sleep 2
done

log "Stopping old backend..."
docker stop tourtravel-backend || true
docker rm tourtravel-backend || true

log "Promoting new backend..."
docker rename tourtravel-backend-new tourtravel-backend

log "Restarting nginx..."
docker restart tourtravel-nginx

log "Cleanup..."
docker image prune -f

log "Backend DEV deployment completed!"
EOFSCRIPT

# Frontend deployment script
cat > scripts/deploy-frontend-dev.sh << 'EOFSCRIPT'
#!/bin/bash
set -e
PROJECT_DIR="/opt/tourtravel"
FRONTEND_DIR="$PROJECT_DIR/frontend"
LOG_FILE="/var/log/tourtravel-frontend-dev-deploy.log"
BRANCH="dev"

log() { echo -e "\033[0;32m[$(date +'%Y-%m-%d %H:%M:%S')]\033[0m $1" | tee -a $LOG_FILE; }
error() { echo -e "\033[0;31m[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:\033[0m $1" | tee -a $LOG_FILE; }

log "Starting FRONTEND DEV deployment..."
cd $FRONTEND_DIR
git fetch origin
git checkout $BRANCH
git pull origin $BRANCH || { error "Failed to pull"; exit 1; }

log "Installing dependencies..."
npm ci || { error "npm ci failed"; exit 1; }

log "Building frontend..."
npm run build || { error "Build failed"; exit 1; }

log "Backing up current frontend..."
BACKUP_DIR="/opt/tourtravel/backup/frontend"
mkdir -p $BACKUP_DIR
BACKUP_FILE="$BACKUP_DIR/frontend-dev_$(date +%Y%m%d_%H%M%S).tar.gz"
[ -d "/opt/tourtravel/frontend-dist" ] && tar -czf $BACKUP_FILE -C /opt/tourtravel frontend-dist/

log "Deploying new frontend..."
cp -r dist /opt/tourtravel/frontend-dist-new
[ -d "/opt/tourtravel/frontend-dist" ] && mv /opt/tourtravel/frontend-dist /opt/tourtravel/frontend-dist-old
mv /opt/tourtravel/frontend-dist-new /opt/tourtravel/frontend-dist

log "Reloading nginx..."
docker exec tourtravel-nginx nginx -s reload

log "Cleanup..."
[ -d "/opt/tourtravel/frontend-dist-old" ] && rm -rf /opt/tourtravel/frontend-dist-old

log "Frontend DEV deployment completed!"
EOFSCRIPT

chmod +x scripts/deploy-backend-dev.sh
chmod +x scripts/deploy-frontend-dev.sh

log "Deployment scripts created"

# Step 17: Setup SSH keys for GitHub Actions
log "Step 17: Setting up SSH keys for GitHub Actions..."

ssh-keygen -t ed25519 -C "github-actions-backend-dev@jourva" -f ~/.ssh/github_actions_backend_dev -N ""
cat ~/.ssh/github_actions_backend_dev.pub >> ~/.ssh/authorized_keys

ssh-keygen -t ed25519 -C "github-actions-frontend-dev@jourva" -f ~/.ssh/github_actions_frontend_dev -N ""
cat ~/.ssh/github_actions_frontend_dev.pub >> ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

log "SSH keys created"

# Step 18: Verify deployment
log "Step 18: Verifying deployment..."
sleep 5

docker ps
echo ""

# Check backend
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    log "✅ Backend health check: PASSED"
else
    warning "⚠️  Backend health check: FAILED"
fi

# Check frontend
if curl -f http://localhost/ > /dev/null 2>&1; then
    log "✅ Frontend check: PASSED"
else
    warning "⚠️  Frontend check: FAILED"
fi

# Final summary
echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "✅ Docker installed and running"
echo "✅ Node.js 20 installed"
echo "✅ .NET SDK 8 installed"
echo "✅ Repositories cloned (dev branch)"
echo "✅ Frontend built"
echo "✅ Docker containers running"
echo "✅ Database migrations applied"
echo "✅ Firewall configured"
echo "✅ Deployment scripts created"
echo "✅ SSH keys for GitHub Actions created"
echo ""
echo "========================================="
echo "  Important Information"
echo "========================================="
echo ""
echo "Server: http://31.97.220.52"
echo "Backend Health: http://31.97.220.52/health"
echo "Hangfire: http://31.97.220.52/hangfire"
echo ""
echo "Project Directory: /opt/tourtravel"
echo "Deployment Scripts: /opt/tourtravel/scripts/"
echo ""
echo "========================================="
echo "  GitHub Actions SSH Keys"
echo "========================================="
echo ""
echo "Add these private keys to GitHub Secrets:"
echo ""
echo "--- BACKEND PRIVATE KEY (SSH_PRIVATE_KEY_DEV) ---"
cat ~/.ssh/github_actions_backend_dev
echo ""
echo "--- FRONTEND PRIVATE KEY (SSH_PRIVATE_KEY_DEV) ---"
cat ~/.ssh/github_actions_frontend_dev
echo ""
echo "========================================="
echo "  Next Steps"
echo "========================================="
echo ""
echo "1. Edit /opt/tourtravel/.env and change passwords"
echo "2. Add SSH keys to GitHub Secrets (see above)"
echo "3. Setup GitHub Actions workflows"
echo "   - Backend: CI-CD-BACKEND-DEV.md"
echo "   - Frontend: CI-CD-FRONTEND-DEV.md"
echo "4. Test deployment by pushing to dev branch"
echo ""
echo "========================================="
echo ""
