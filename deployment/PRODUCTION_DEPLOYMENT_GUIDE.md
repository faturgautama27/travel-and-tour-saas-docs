# Production Deployment Guide

Panduan lengkap untuk setup dan deployment production Tour & Travel SaaS Platform.

## 📋 Overview

**Environment:**
- **Dev**: `dev.jourva.com` (frontend) + `apidev.jourva.com` (backend)
- **Production**: `jourva.com` (frontend) + `api.jourva.com` (backend)

**Server:** 31.97.220.52 (shared untuk dev dan prod)

**Database:**
- Dev: `tourtravel_db`
- Production: `tourtravel_prod_db`

**Shared Services:**
- MinIO: `miniodev.jourva.com`
- Xendit: Development API Key
- Resend: `noreply@jourva.com`

---

## 🚀 Initial Setup (One-time)

### 1. Backend Production Setup

Jalankan script setup di server:

```bash
# Copy script ke server
scp travel-and-tour-backend/scripts/setup-production.sh root@31.97.220.52:/tmp/

# SSH ke server
ssh root@31.97.220.52

# Jalankan setup script
cd /tmp
chmod +x setup-production.sh
./setup-production.sh
```

Script ini akan:
- ✅ Membuat database `tourtravel_prod_db`
- ✅ Duplicate data dari `tourtravel_db`
- ✅ Membuat folder `/var/www/tourtravel/backend-prod`
- ✅ Membuat `appsettings.Production.json`
- ✅ Membuat systemd service `tourtravel-backend-prod`
- ✅ Membuat nginx config untuk `api.jourva.com`
- ✅ Setup SSL certificate (jika belum ada)

### 2. Frontend Production Setup

```bash
# Copy script ke server
scp tour-and-travel-frontend/scripts/setup-production.sh root@31.97.220.52:/tmp/

# SSH ke server
ssh root@31.97.220.52

# Jalankan setup script
cd /tmp
chmod +x setup-production.sh
./setup-production.sh
```

Script ini akan:
- ✅ Membuat folder `/var/www/jourva.com`
- ✅ Membuat nginx config untuk `jourva.com`
- ✅ Setup SSL certificate (jika belum ada)

### 3. Setup SSL Certificates

Jika SSL belum ada, jalankan di server:

```bash
# Backend SSL
certbot --nginx -d api.jourva.com

# Frontend SSL
certbot --nginx -d jourva.com -d www.jourva.com

# Reload nginx
systemctl reload nginx
```

---

## 📦 Deployment Methods

### Method 1: GitHub Actions (Recommended)

#### Backend Deployment

1. Commit dan push ke branch `main`
2. Create tag dengan format `prod-v*`:

```bash
cd travel-and-tour-backend
git tag prod-v1.0.0
git push origin prod-v1.0.0
```

3. GitHub Actions akan otomatis:
   - Build aplikasi
   - Run database migrations
   - Deploy ke `/var/www/tourtravel/backend-prod/publish`
   - Restart service `tourtravel-backend-prod`

#### Frontend Deployment

1. Commit dan push ke branch `main`
2. Create tag dengan format `prod-v*`:

```bash
cd tour-and-travel-frontend
git tag prod-v1.0.0
git push origin prod-v1.0.0
```

3. GitHub Actions akan otomatis:
   - Build aplikasi dengan production config
   - Deploy ke `/var/www/jourva.com`
   - Reload nginx

### Method 2: Manual Deployment

#### Backend Manual Deployment

```bash
cd travel-and-tour-backend
chmod +x scripts/deploy-manual.sh
./scripts/deploy-manual.sh
```

#### Frontend Manual Deployment

```bash
cd tour-and-travel-frontend
chmod +x scripts/deploy-manual.sh
./scripts/deploy-manual.sh
```

---

## 🔧 Configuration Files

### Backend Production Config

File: `/var/www/tourtravel/backend-prod/appsettings.Production.json`

Key configurations:
- Database: `tourtravel_prod_db`
- Port: `5001`
- Frontend URL: `https://jourva.com`
- Xendit Callback: `https://api.jourva.com/api/payments/webhook/xendit`

### Frontend Production Config

File: `src/environments/environment.prod.ts`

```typescript
export const environment = {
  production: true,
  apiReady: true,
  apiUrl: 'https://api.jourva.com/api',
  mockDelay: 0
};
```

---

## 🔍 Monitoring & Troubleshooting

### Check Backend Status

```bash
# Service status
systemctl status tourtravel-backend-prod

# View logs
journalctl -u tourtravel-backend-prod -f

# Check if running
curl http://localhost:5001/health

# Check from outside
curl https://api.jourva.com/health
```

### Check Frontend Status

```bash
# Nginx status
systemctl status nginx

# Test nginx config
nginx -t

# View nginx logs
tail -f /var/log/nginx/jourva.com.access.log
tail -f /var/log/nginx/jourva.com.error.log

# Check from outside
curl https://jourva.com
```

### Common Issues

#### Backend tidak start

```bash
# Check logs
journalctl -u tourtravel-backend-prod -n 100

# Check port
netstat -tulpn | grep 5001

# Restart service
systemctl restart tourtravel-backend-prod
```

#### Frontend 502 Bad Gateway

```bash
# Check backend is running
systemctl status tourtravel-backend-prod

# Check nginx config
nginx -t

# Reload nginx
systemctl reload nginx
```

#### Database connection error

```bash
# Test database connection
psql -h 31.97.220.52 -U postgres -d tourtravel_prod_db

# Check connection string in appsettings.Production.json
cat /var/www/tourtravel/backend-prod/appsettings.Production.json | grep ConnectionStrings
```

---

## 📊 Service Management

### Backend Service Commands

```bash
# Start
systemctl start tourtravel-backend-prod

# Stop
systemctl stop tourtravel-backend-prod

# Restart
systemctl restart tourtravel-backend-prod

# Enable on boot
systemctl enable tourtravel-backend-prod

# Disable on boot
systemctl disable tourtravel-backend-prod

# View logs
journalctl -u tourtravel-backend-prod -f
```

### Nginx Commands

```bash
# Test config
nginx -t

# Reload (no downtime)
systemctl reload nginx

# Restart
systemctl restart nginx

# Status
systemctl status nginx
```

---

## 🔐 Security Checklist

- ✅ SSL certificates installed and auto-renewing
- ✅ HTTPS redirect enabled
- ✅ Security headers configured
- ✅ Database password secured
- ✅ JWT secret key configured
- ✅ CORS properly configured
- ✅ Firewall rules configured
- ✅ Service running as www-data (not root)

---

## 📝 Versioning Strategy

### Tag Format

- Production: `prod-v1.0.0`, `prod-v1.0.1`, `prod-v2.0.0`
- Dev: Push ke branch `dev` (no tags needed)

### Version Numbering

- **Major** (v1.0.0 → v2.0.0): Breaking changes
- **Minor** (v1.0.0 → v1.1.0): New features
- **Patch** (v1.0.0 → v1.0.1): Bug fixes

### Example Workflow

```bash
# Feature development
git checkout -b feature/new-feature
# ... develop ...
git commit -m "feat: add new feature"
git push origin feature/new-feature

# Merge to main
git checkout main
git merge feature/new-feature
git push origin main

# Deploy to production
git tag prod-v1.1.0
git push origin prod-v1.1.0
```

---

## 🆘 Emergency Procedures

### Rollback Backend

```bash
# Stop current service
systemctl stop tourtravel-backend-prod

# Restore previous version (if backed up)
# Or redeploy previous tag
git checkout prod-v1.0.0
./scripts/deploy-manual.sh

# Start service
systemctl start tourtravel-backend-prod
```

### Rollback Frontend

```bash
# Redeploy previous tag
git checkout prod-v1.0.0
npm run build -- --configuration production
rsync -avz --delete ./dist/tour-travel-app/browser/ root@31.97.220.52:/var/www/jourva.com/
ssh root@31.97.220.52 "systemctl reload nginx"
```

### Database Rollback

```bash
# Restore from backup
pg_restore -h 31.97.220.52 -U postgres -d tourtravel_prod_db backup.dump

# Or run specific migration down
dotnet ef migrations remove --project TourTravel.Infrastructure
```

---

## 📞 Support

Jika ada masalah:

1. Check logs terlebih dahulu
2. Verify service status
3. Check network connectivity
4. Review recent changes
5. Contact team lead

---

## 📚 Additional Resources

- [Backend Architecture](travel-and-tour-backend/.kiro/steering/backend-architecture.md)
- [Frontend Architecture](tour-and-travel-frontend/.kiro/steering/frontend-architecture.md)
- [API Documentation](https://api.jourva.com/swagger)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [.NET Deployment Guide](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/)

---

**Last Updated:** April 2026
**Maintained by:** Development Team
