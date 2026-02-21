# MinIO Setup Guide - Non-Docker Installation

**Project:** Tour & Travel ERP SaaS  
**Purpose:** Document storage for KYC verification (Agency & Supplier registration)  
**Environment:** Development Server (Ubuntu/Linux without Docker)  
**Last Updated:** February 21, 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation Steps](#installation-steps)
4. [Configuration](#configuration)
5. [Running MinIO as System Service](#running-minio-as-system-service)
6. [Testing MinIO](#testing-minio)
7. [Backend Integration](#backend-integration)
8. [Security Considerations](#security-considerations)
9. [Backup & Maintenance](#backup--maintenance)
10. [Troubleshooting](#troubleshooting)

---

## Overview

MinIO is an S3-compatible object storage system that we'll use to store KYC documents (KTP, NPWP, business licenses, etc.) for agency and supplier registration.

### Why MinIO?

- ✅ S3-compatible API (easy migration to AWS S3 later)
- ✅ Self-hosted and free
- ✅ Production-ready and scalable
- ✅ Built-in web console for management
- ✅ High performance

### Architecture

```
┌─────────────────┐
│  Angular App    │
│   (Frontend)    │
└────────┬────────┘
         │ HTTP Upload
         ▼
┌─────────────────┐
│  .NET Backend   │
│   (API Layer)   │
└────────┬────────┘
         │ MinIO SDK
         ▼
┌─────────────────┐
│     MinIO       │
│  Object Storage │
└─────────────────┘
```

---

## Prerequisites

### System Requirements

- **OS:** Ubuntu 20.04+ / Debian 10+ / CentOS 8+ / RHEL 8+
- **RAM:** Minimum 2GB (4GB recommended)
- **Disk:** Minimum 10GB free space (depends on document volume)
- **CPU:** 2 cores minimum

### Software Requirements

- `wget` or `curl` (for downloading MinIO)
- `systemd` (for running as service)
- User with sudo privileges

---

## Installation Steps

### Step 1: Download MinIO Binary

```bash
# Create directory for MinIO
sudo mkdir -p /opt/minio/bin
sudo mkdir -p /opt/minio/data

# Download MinIO server binary
cd /opt/minio/bin
sudo wget https://dl.min.io/server/minio/release/linux-amd64/minio

# Make it executable
sudo chmod +x minio

# Verify installation
./minio --version
```

**Expected output:**
```
minio version RELEASE.2024-XX-XXTXX-XX-XXZ
```

### Step 2: Create MinIO User

For security, run MinIO as a dedicated user (not root):

```bash
# Create minio user and group
sudo useradd -r -s /sbin/nologin minio

# Set ownership
sudo chown -R minio:minio /opt/minio
```

### Step 3: Create MinIO Configuration

```bash
# Create environment file
sudo nano /etc/default/minio
```

Add the following content:

```bash
# MinIO Configuration
# Root credentials (change these!)
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123!@#

# Data directory
MINIO_VOLUMES="/opt/minio/data"

# Console address (web UI)
MINIO_OPTS="--console-address :9001"

# Server address
MINIO_ADDRESS=":9000"

# Optional: Set region
MINIO_REGION_NAME="us-east-1"
```

**Important:** Change `MINIO_ROOT_USER` and `MINIO_ROOT_PASSWORD` to secure values!

```bash
# Set proper permissions
sudo chmod 600 /etc/default/minio
```

---

## Configuration

### Step 4: Create Systemd Service

```bash
# Create service file
sudo nano /etc/systemd/system/minio.service
```

Add the following content:

```ini
[Unit]
Description=MinIO Object Storage
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/opt/minio/bin/minio

[Service]
Type=notify

WorkingDirectory=/opt/minio

User=minio
Group=minio
ProtectProc=invisible

EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/opt/minio/bin/minio server $MINIO_OPTS $MINIO_VOLUMES

# MinIO RELEASE.2023-05-04T21-44-30Z adds support for Type=notify (https://www.freedesktop.org/software/systemd/man/systemd.service.html#Type=)
# This may improve systemctl setups where other services use `After=minio.server`
# Uncomment the line to enable the functionality
# Type=notify

# Let systemd restart this service always
Restart=always

# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536

# Specifies the maximum number of threads this process can create
TasksMax=infinity

# Disable timeout logic and wait until process is stopped
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
```

### Step 5: Enable and Start MinIO Service

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable MinIO to start on boot
sudo systemctl enable minio

# Start MinIO service
sudo systemctl start minio

# Check status
sudo systemctl status minio
```

**Expected output:**
```
● minio.service - MinIO Object Storage
     Loaded: loaded (/etc/systemd/system/minio.service; enabled)
     Active: active (running) since ...
```

### Step 6: Configure Firewall (if applicable)

```bash
# Allow MinIO API port (9000)
sudo ufw allow 9000/tcp

# Allow MinIO Console port (9001)
sudo ufw allow 9001/tcp

# Reload firewall
sudo ufw reload
```

---

## Running MinIO as System Service

### Service Management Commands

```bash
# Start MinIO
sudo systemctl start minio

# Stop MinIO
sudo systemctl stop minio

# Restart MinIO
sudo systemctl restart minio

# Check status
sudo systemctl status minio

# View logs
sudo journalctl -u minio -f

# View last 100 lines of logs
sudo journalctl -u minio -n 100
```

---

## Testing MinIO

### Step 7: Access MinIO Console

1. Open browser and navigate to: `http://YOUR_SERVER_IP:9001`
2. Login with credentials from `/etc/default/minio`:
   - Username: `minioadmin`
   - Password: `minioadmin123!@#`

### Step 8: Create Bucket via Console

1. Click "Buckets" in left sidebar
2. Click "Create Bucket"
3. Enter bucket name: `tour-travel-documents`
4. Click "Create Bucket"

### Step 9: Create Access Keys (for Backend)

1. Click "Access Keys" in left sidebar
2. Click "Create access key"
3. Copy the generated:
   - Access Key
   - Secret Key
4. Save these credentials securely (you'll need them for backend configuration)

**Alternative: Create bucket via MinIO Client (mc)**

```bash
# Download MinIO Client
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

# Configure mc
mc alias set local http://localhost:9000 minioadmin minioadmin123!@#

# Create bucket
mc mb local/tour-travel-documents

# Set public read policy (optional, for testing)
mc anonymous set download local/tour-travel-documents

# List buckets
mc ls local
```

---

## Backend Integration

### Step 10: Install MinIO SDK in .NET Backend

```bash
# Navigate to backend project
cd /path/to/tour-travel-backend

# Install Minio NuGet package
dotnet add package Minio --version 6.0.3
```

### Step 11: Update appsettings.json

```json
{
  "FileStorage": {
    "StorageType": "MinIO",
    "Endpoint": "localhost:9000",
    "AccessKey": "YOUR_ACCESS_KEY_HERE",
    "SecretKey": "YOUR_SECRET_KEY_HERE",
    "BucketName": "tour-travel-documents",
    "UseSSL": false,
    "Region": "us-east-1",
    "MaxFileSizeMB": 10,
    "AllowedExtensions": [".pdf", ".jpg", ".jpeg", ".png", ".doc", ".docx"]
  }
}
```

### Step 12: Update appsettings.Production.json (for production)

```json
{
  "FileStorage": {
    "StorageType": "MinIO",
    "Endpoint": "YOUR_PRODUCTION_SERVER_IP:9000",
    "AccessKey": "YOUR_PRODUCTION_ACCESS_KEY",
    "SecretKey": "YOUR_PRODUCTION_SECRET_KEY",
    "BucketName": "tour-travel-documents",
    "UseSSL": true,
    "Region": "us-east-1",
    "MaxFileSizeMB": 10,
    "AllowedExtensions": [".pdf", ".jpg", ".jpeg", ".png", ".doc", ".docx"]
  }
}
```

### Step 13: Implement MinIO Service in Backend

See the implementation code in the spec document: `self-registration-kyc-verification/design.md`

The implementation includes:
- `IFileStorageService` interface
- `MinIOFileStorageService` implementation
- Service registration in `Program.cs`
- API endpoints for upload/download/delete

---

## Security Considerations

### 1. Change Default Credentials

**CRITICAL:** Never use default credentials in production!

```bash
# Edit MinIO config
sudo nano /etc/default/minio

# Change these values:
MINIO_ROOT_USER=your_secure_username
MINIO_ROOT_PASSWORD=your_very_secure_password_min_8_chars
```

### 2. Enable HTTPS (Production)

For production, use reverse proxy (Nginx) with SSL:

```nginx
# /etc/nginx/sites-available/minio
server {
    listen 443 ssl http2;
    server_name minio.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/minio.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/minio.yourdomain.com/privkey.pem;

    # MinIO Console
    location / {
        proxy_pass http://localhost:9001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

server {
    listen 443 ssl http2;
    server_name minio-api.yourdomain.com;

    ssl_certificate /etc/letsencrypt/live/minio-api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/minio-api.yourdomain.com/privkey.pem;

    # MinIO API
    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Increase timeouts for large file uploads
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        send_timeout 300;
    }
}
```

### 3. Restrict Network Access

```bash
# Only allow access from backend server IP
sudo ufw allow from BACKEND_SERVER_IP to any port 9000
sudo ufw allow from BACKEND_SERVER_IP to any port 9001

# Or use iptables
sudo iptables -A INPUT -p tcp -s BACKEND_SERVER_IP --dport 9000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 9000 -j DROP
```

### 4. Set Bucket Policies

```bash
# Private bucket (recommended for KYC documents)
mc anonymous set none local/tour-travel-documents

# Or set custom policy
cat > /tmp/policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["*"]},
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::tour-travel-documents/public/*"]
    }
  ]
}
EOF

mc anonymous set-json /tmp/policy.json local/tour-travel-documents
```

---

## Backup & Maintenance

### Backup Strategy

#### Option 1: File System Backup

```bash
# Create backup script
sudo nano /opt/minio/backup.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backup/minio"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="minio_backup_$DATE.tar.gz"

# Create backup directory
mkdir -p $BACKUP_DIR

# Stop MinIO (optional, for consistent backup)
# sudo systemctl stop minio

# Backup data directory
tar -czf $BACKUP_DIR/$BACKUP_FILE /opt/minio/data

# Start MinIO
# sudo systemctl start minio

# Keep only last 7 backups
find $BACKUP_DIR -name "minio_backup_*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_FILE"
```

```bash
# Make executable
sudo chmod +x /opt/minio/backup.sh

# Add to crontab (daily at 2 AM)
sudo crontab -e
```

Add line:
```
0 2 * * * /opt/minio/backup.sh >> /var/log/minio_backup.log 2>&1
```

#### Option 2: MinIO Mirror (mc mirror)

```bash
# Mirror to another MinIO instance or S3
mc mirror local/tour-travel-documents remote/tour-travel-documents-backup

# Add to cron for automated backup
0 3 * * * /usr/local/bin/mc mirror local/tour-travel-documents remote/tour-travel-documents-backup
```

### Monitoring

```bash
# Check disk usage
df -h /opt/minio/data

# Check MinIO logs
sudo journalctl -u minio -f

# Check service status
sudo systemctl status minio

# Monitor MinIO metrics (via Console)
# Navigate to: http://YOUR_SERVER_IP:9001/metrics
```

---

## Troubleshooting

### Issue 1: MinIO Service Won't Start

```bash
# Check logs
sudo journalctl -u minio -n 50

# Common causes:
# 1. Port already in use
sudo netstat -tulpn | grep 9000
sudo netstat -tulpn | grep 9001

# 2. Permission issues
sudo chown -R minio:minio /opt/minio

# 3. Invalid configuration
sudo cat /etc/default/minio
```

### Issue 2: Cannot Access MinIO Console

```bash
# Check if MinIO is running
sudo systemctl status minio

# Check firewall
sudo ufw status

# Check if port is listening
sudo netstat -tulpn | grep 9001

# Try accessing locally first
curl http://localhost:9001
```

### Issue 3: Backend Cannot Connect to MinIO

```bash
# Test connection from backend server
telnet MINIO_SERVER_IP 9000

# Check MinIO logs for connection attempts
sudo journalctl -u minio -f

# Verify credentials
mc alias set test http://MINIO_SERVER_IP:9000 ACCESS_KEY SECRET_KEY
mc ls test
```

### Issue 4: Upload Fails with "Access Denied"

```bash
# Check bucket policy
mc anonymous get local/tour-travel-documents

# Check access key permissions
# Recreate access key in MinIO Console with proper permissions
```

### Issue 5: Disk Space Full

```bash
# Check disk usage
df -h /opt/minio/data

# Find large files
du -sh /opt/minio/data/*

# Clean up old backups or unused files
# Or expand disk space
```

---

## Quick Reference

### Important Paths

- **Binary:** `/opt/minio/bin/minio`
- **Data:** `/opt/minio/data`
- **Config:** `/etc/default/minio`
- **Service:** `/etc/systemd/system/minio.service`
- **Logs:** `sudo journalctl -u minio`

### Important URLs

- **API Endpoint:** `http://YOUR_SERVER_IP:9000`
- **Console:** `http://YOUR_SERVER_IP:9001`

### Important Commands

```bash
# Service management
sudo systemctl start|stop|restart|status minio

# View logs
sudo journalctl -u minio -f

# MinIO Client
mc alias set local http://localhost:9000 ACCESS_KEY SECRET_KEY
mc ls local
mc mb local/bucket-name
mc cp file.pdf local/bucket-name/
```

---

## Next Steps

After completing MinIO setup:

1. ✅ Test upload/download via MinIO Console
2. ✅ Create access keys for backend
3. ✅ Update backend `appsettings.json`
4. ✅ Implement `MinIOFileStorageService` in backend
5. ✅ Test file upload via API endpoint
6. ✅ Proceed with Self-Registration feature implementation

---

## Support & Resources

- **MinIO Documentation:** https://min.io/docs/minio/linux/index.html
- **MinIO Client Guide:** https://min.io/docs/minio/linux/reference/minio-mc.html
- **MinIO .NET SDK:** https://github.com/minio/minio-dotnet

---

**Document Version:** 1.0  
**Last Updated:** February 21, 2026  
**Maintained By:** Development Team
