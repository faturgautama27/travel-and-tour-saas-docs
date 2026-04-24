# SSL Setup Guide

Panduan untuk setup SSL certificate setelah menjalankan setup-production.sh

## 🔧 Situasi Saat Ini

Jika kamu mendapat error seperti ini saat menjalankan `setup-production.sh`:

```
nginx: configuration file /etc/nginx/nginx.conf test failed
cannot load certificate "/etc/letsencrypt/live/api.jourva.com/fullchain.pem"
```

Ini normal karena SSL certificate belum dibuat. Script sudah membuat konfigurasi HTTP-only terlebih dahulu.

## ✅ Solusi

### Option 1: Setup SSL Sekarang (Recommended)

```bash
# 1. Setup SSL untuk backend
certbot --nginx -d api.jourva.com

# 2. Setup SSL untuk frontend
certbot --nginx -d jourva.com -d www.jourva.com

# 3. Certbot akan otomatis update nginx config dan reload
# Tidak perlu manual edit config lagi!
```

### Option 2: Re-run Setup Script

Script sudah diperbaiki untuk handle SSL setup interaktif:

```bash
# Copy updated script ke server
scp travel-and-tour-backend/scripts/setup-production.sh root@31.97.220.52:/tmp/

# SSH dan jalankan ulang
ssh root@31.97.220.52
chmod +x /tmp/setup-production.sh
/tmp/setup-production.sh

# Script akan tanya: "Do you want to setup SSL certificate now? (yes/no)"
# Jawab: yes
```

## 🔍 Verify SSL Installation

```bash
# Check certificate files
ls -la /etc/letsencrypt/live/api.jourva.com/
ls -la /etc/letsencrypt/live/jourva.com/

# Test nginx config
nginx -t

# Reload nginx
systemctl reload nginx

# Test HTTPS
curl -I https://api.jourva.com
curl -I https://jourva.com
```

## 📋 Current Status Check

```bash
# Check nginx config
cat /etc/nginx/sites-available/api.jourva.com

# If you see "listen 80" only (no 443), SSL is not configured yet
# If you see both "listen 80" and "listen 443 ssl", SSL is configured
```

## 🚀 Continue After SSL Setup

Setelah SSL berhasil disetup:

```bash
# 1. Enable and start backend service
systemctl enable tourtravel-backend-prod
systemctl start tourtravel-backend-prod

# 2. Check status
systemctl status tourtravel-backend-prod

# 3. Test backend
curl https://api.jourva.com/health

# 4. Deploy aplikasi
# Via GitHub Actions:
git tag prod-v1.0.0
git push origin prod-v1.0.0

# Or manual:
./scripts/deploy-manual.sh
```

## ⚠️ Important Notes

1. **Domain DNS**: Pastikan domain sudah pointing ke server IP (31.97.220.52)
   ```bash
   # Check DNS
   nslookup api.jourva.com
   nslookup jourva.com
   ```

2. **Port 80 & 443**: Pastikan port terbuka di firewall
   ```bash
   # Check firewall
   ufw status
   
   # Allow if needed
   ufw allow 80/tcp
   ufw allow 443/tcp
   ```

3. **Certbot Auto-renewal**: Certbot otomatis setup cron job untuk renewal
   ```bash
   # Test renewal
   certbot renew --dry-run
   ```

## 🆘 Troubleshooting

### Error: "Domain not pointing to this server"

```bash
# Check DNS
dig api.jourva.com +short
# Should return: 31.97.220.52

# If not, update DNS A record di domain provider
```

### Error: "Port 80 connection refused"

```bash
# Check nginx running
systemctl status nginx

# Start if not running
systemctl start nginx

# Check port
netstat -tulpn | grep :80
```

### Error: "Too many certificates already issued"

Let's Encrypt has rate limits. Wait 1 week or use staging:

```bash
# Use staging for testing
certbot --nginx -d api.jourva.com --staging

# Remove staging cert and get real one
certbot delete --cert-name api.jourva.com
certbot --nginx -d api.jourva.com
```

## 📞 Need Help?

Jika masih ada masalah, check:
1. DNS pointing ke server
2. Firewall allow port 80 & 443
3. Nginx running
4. Domain accessible via HTTP first

Then try certbot again.
