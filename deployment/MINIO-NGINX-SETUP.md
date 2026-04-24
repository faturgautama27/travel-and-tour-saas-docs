# MinIO Nginx Reverse Proxy Setup - Presigned URL Fix

**Problem:** Presigned URLs redirect ke MinIO Console instead of serving the file  
**Cause:** Nginx routing misconfiguration - API requests going to console port (9001) instead of API port (9000)  
**Solution:** Separate Nginx configs for API and Console

---

## Setup Nginx for MinIO API & Console

### Step 1: Install Nginx

```bash
sudo apt update
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

### Step 2: Create Nginx Config for MinIO API (File Serving)

```bash
sudo nano /etc/nginx/sites-available/minio-api
```

Add this configuration:

```nginx
# MinIO API - For file serving and presigned URLs
upstream minio_api {
    server 127.0.0.1:9000;
}

server {
    listen 80;
    listen [::]:80;
    server_name miniodev.jourva.com;

    # Redirect HTTP to HTTPS (optional, for production)
    # return 301 https://$server_name$request_uri;

    # Increase upload size limit
    client_max_body_size 100M;

    # Proxy settings
    location / {
        proxy_pass http://minio_api;
        proxy_http_version 1.1;
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $server_name;
        
        # Connection settings
        proxy_set_header Connection "";
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        
        # Buffering
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
```

### Step 3: Create Nginx Config for MinIO Console

```bash
sudo nano /etc/nginx/sites-available/minio-console
```

Add this configuration:

```nginx
# MinIO Console - For web UI management
upstream minio_console {
    server 127.0.0.1:9001;
}

server {
    listen 80;
    listen [::]:80;
    server_name minio-console.jourva.com;

    # Redirect HTTP to HTTPS (optional, for production)
    # return 301 https://$server_name$request_uri;

    location / {
        proxy_pass http://minio_console;
        proxy_http_version 1.1;
        
        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeouts
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
    }
}
```

### Step 4: Enable Nginx Sites

```bash
# Enable API site
sudo ln -s /etc/nginx/sites-available/minio-api /etc/nginx/sites-enabled/

# Enable Console site
sudo ln -s /etc/nginx/sites-available/minio-console /etc/nginx/sites-enabled/

# Remove default site
sudo rm /etc/nginx/sites-enabled/default

# Test Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 5: Update DNS Records

Add these DNS records to your domain:

```
miniodev.jourva.com    A    YOUR_SERVER_IP
minio-console.jourva.com    A    YOUR_SERVER_IP
```

Or if using local testing:

```bash
# Add to /etc/hosts (local machine)
YOUR_SERVER_IP    miniodev.jourva.com
YOUR_SERVER_IP    minio-console.jourva.com
```

### Step 6: Test Presigned URLs

```bash
# Test API endpoint (should serve file, not redirect)
curl -I "https://miniodev.jourva.com/supplier-service-images/services/1cf8a861-9857-4480-9489-5c16a025670d/be56a95e-f034-4565-9bff-52ad3968ae90.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&..."

# Expected response: 200 OK (file served)
# NOT: 301/302 redirect to console

# Test Console (should show login page)
curl -I "https://minio-console.jourva.com"
# Expected response: 200 OK (console page)
```

---

## Setup HTTPS with Let's Encrypt (Production)

### Step 1: Install Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
```

### Step 2: Get SSL Certificate for API

```bash
sudo certbot certonly --nginx -d miniodev.jourva.com
```

### Step 3: Get SSL Certificate for Console

```bash
sudo certbot certonly --nginx -d minio-console.jourva.com
```

### Step 4: Update Nginx Config for HTTPS (API)

```bash
sudo nano /etc/nginx/sites-available/minio-api
```

Replace with:

```nginx
upstream minio_api {
    server 127.0.0.1:9000;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name miniodev.jourva.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name miniodev.jourva.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/miniodev.jourva.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/miniodev.jourva.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Increase upload size limit
    client_max_body_size 100M;

    location / {
        proxy_pass http://minio_api;
        proxy_http_version 1.1;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $server_name;
        
        proxy_set_header Connection "";
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
```

### Step 5: Update Nginx Config for HTTPS (Console)

```bash
sudo nano /etc/nginx/sites-available/minio-console
```

Replace with:

```nginx
upstream minio_console {
    server 127.0.0.1:9001;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name minio-console.jourva.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name minio-console.jourva.com;

    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/minio-console.jourva.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/minio-console.jourva.com/privkey.pem;

    # SSL configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    location / {
        proxy_pass http://minio_console;
        proxy_http_version 1.1;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
    }
}
```

### Step 6: Reload Nginx

```bash
sudo nginx -t
sudo systemctl reload nginx
```

### Step 7: Auto-Renew SSL Certificates

```bash
# Test renewal
sudo certbot renew --dry-run

# Certificates auto-renew via cron (already set up by certbot)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

---

## Troubleshooting

### Issue 1: Presigned URL Still Redirects to Console

**Check Nginx logs:**
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

**Verify Nginx config:**
```bash
sudo nginx -t
```

**Check if MinIO API is running:**
```bash
sudo systemctl status minio
curl http://localhost:9000
```

### Issue 2: CORS Errors

Add CORS headers to Nginx:

```nginx
location / {
    # ... existing config ...
    
    # CORS headers
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Content-Type, Authorization, X-Amz-*' always;
    
    if ($request_method = 'OPTIONS') {
        return 204;
    }
}
```

### Issue 3: Large File Upload Fails

Increase timeouts and buffer sizes:

```nginx
# In http block of /etc/nginx/nginx.conf
http {
    # ... existing config ...
    
    # Increase limits
    client_max_body_size 1G;
    proxy_connect_timeout 600s;
    proxy_send_timeout 600s;
    proxy_read_timeout 600s;
    
    # Disable buffering for large files
    proxy_buffering off;
    proxy_request_buffering off;
}
```

### Issue 4: SSL Certificate Issues

```bash
# Check certificate status
sudo certbot certificates

# Renew specific certificate
sudo certbot renew --cert-name miniodev.jourva.com

# Force renewal
sudo certbot renew --force-renewal
```

---

## Firewall Configuration

```bash
# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow 443/tcp

# Allow MinIO API (internal only)
sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 9000

# Allow MinIO Console (internal only)
sudo ufw allow from 127.0.0.1 to 127.0.0.1 port 9001

# Reload firewall
sudo ufw reload
```

---

## Verify Setup

```bash
# Test API endpoint
curl -I https://miniodev.jourva.com/bucket-name/object-name

# Test Console
curl -I https://minio-console.jourva.com

# Test presigned URL
curl -I "https://miniodev.jourva.com/supplier-service-images/services/1cf8a861-9857-4480-9489-5c16a025670d/be56a95e-f034-4565-9bff-52ad3968ae90.png?X-Amz-Algorithm=..."

# Should return 200 OK, not redirect
```

---

## Summary

| Component | URL | Port | Purpose |
|-----------|-----|------|---------|
| MinIO API | https://miniodev.jourva.com | 443 → 9000 | File serving, presigned URLs |
| MinIO Console | https://minio-console.jourva.com | 443 → 9001 | Web UI management |
| MinIO API (internal) | http://127.0.0.1:9000 | 9000 | Backend direct access |
| MinIO Console (internal) | http://127.0.0.1:9001 | 9001 | Local management |

---

**Document Version:** 1.0  
**Last Updated:** March 30, 2026
