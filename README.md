# Tour & Travel ERP SaaS - Documentation

Complete documentation untuk deployment dan CI/CD setup.

---

## 📚 Documentation Index

### 1. Infrastructure & Planning

**[INFRASTRUCTURE-SPECS.md](./INFRASTRUCTURE-SPECS.md)**
- Server specifications untuk production
- Traffic estimation & capacity planning
- Cost breakdown (DigitalOcean Singapore)
- Monitoring & backup strategy

### 2. Initial Deployment

**[DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)**
- Complete Docker-based deployment guide
- Database setup & configuration
- Nginx setup (with optional SSL)
- Backup automation

**[QUICK-REFERENCE.md](./QUICK-REFERENCE.md)**
- Quick commands reference
- Common troubleshooting steps

### 3. Development Server Setup

**[SETUP-DEV-SERVER.md](./SETUP-DEV-SERVER.md)** ⭐ START HERE
- Complete step-by-step setup untuk dev server (31.97.220.52)
- Git repository cloning (dev branch)
- Docker setup
- Initial deployment
- SSH keys untuk GitHub Actions

### 4. CI/CD - Development Branch

**[CI-CD-BACKEND-DEV.md](./CI-CD-BACKEND-DEV.md)**
- Auto-deployment untuk backend dev branch
- GitHub Actions setup
- Zero downtime deployment
- Troubleshooting guide

**[CI-CD-FRONTEND-DEV.md](./CI-CD-FRONTEND-DEV.md)**
- Auto-deployment untuk frontend dev branch
- GitHub Actions setup
- Atomic swap deployment
- Troubleshooting guide

### 5. CI/CD - Production Branch (Future)

**[CI-CD-BACKEND.md](./CI-CD-BACKEND.md)**
- Template untuk production backend deployment
- Blue-green deployment strategy

**[CI-CD-FRONTEND.md](./CI-CD-FRONTEND.md)**
- Template untuk production frontend deployment
- Atomic swap strategy

**[CI-CD-SETUP.md](./CI-CD-SETUP.md)**
- Original combined CI/CD guide (reference)

### 6. Deployment Scripts

**[deployment-scripts/](./deployment-scripts/)**
- `deploy-backend-dev.sh` - Backend dev deployment script
- `deploy-frontend-dev.sh` - Frontend dev deployment script
- `deploy-backend.sh` - Backend production template
- `deploy-frontend.sh` - Frontend production template
- `backend-workflow.yml` - GitHub Actions workflow template (backend)
- `frontend-workflow.yml` - GitHub Actions workflow template (frontend)

---

## 🚀 Quick Start Guide

### For Development Server (31.97.220.52)

1. **Initial Setup**
   - Follow: [SETUP-DEV-SERVER.md](./SETUP-DEV-SERVER.md)
   - Time: 30-45 minutes
   - Result: Server ready dengan backend & frontend running

2. **Setup CI/CD for Backend**
   - Follow: [CI-CD-BACKEND-DEV.md](./CI-CD-BACKEND-DEV.md)
   - Time: 10-15 minutes
   - Result: Auto-deploy saat push ke `dev` branch

3. **Setup CI/CD for Frontend**
   - Follow: [CI-CD-FRONTEND-DEV.md](./CI-CD-FRONTEND-DEV.md)
   - Time: 10-15 minutes
   - Result: Auto-deploy saat push ke `dev` branch

### For Production Server (Future)

1. **Initial Setup**
   - Follow: [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)
   - Adapt untuk production server
   - Use `main` branch instead of `dev`

2. **Setup CI/CD**
   - Follow: [CI-CD-BACKEND.md](./CI-CD-BACKEND.md)
   - Follow: [CI-CD-FRONTEND.md](./CI-CD-FRONTEND.md)
   - Use `main` branch

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Development Server                    │
│                     31.97.220.52                         │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   Nginx     │  │   Backend    │  │  PostgreSQL   │  │
│  │   (Port 80) │──│   (Port 5000)│──│  (Port 5432)  │  │
│  │             │  │   .NET 8     │  │   v16         │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
│         │                                                │
│         └─── Serves: Frontend (Angular 20)              │
│                                                           │
└─────────────────────────────────────────────────────────┘
                          │
                          │ Auto-deploy via GitHub Actions
                          │
        ┌─────────────────┴─────────────────┐
        │                                     │
┌───────▼────────┐                  ┌────────▼───────┐
│  Backend Repo  │                  │ Frontend Repo  │
│  (dev branch)  │                  │  (dev branch)  │
└────────────────┘                  └────────────────┘
```

---

## 📊 Deployment Flow

### Backend Deployment (Blue-Green)

```
Push to dev → GitHub Actions → SSH to Server → Pull Code
    → Backup DB → Build Docker → Start New Container (port 5001)
    → Health Check → Gradual Traffic Shift (10% old, 90% new)
    → Monitor 30s → Stop Old → Rename New → 100% New
    → ✅ Complete (Zero Downtime)
```

### Frontend Deployment (Atomic Swap)

```
Push to dev → GitHub Actions → SSH to Server → Pull Code
    → npm ci → npm build → Backup Current → Atomic Swap
    → Reload Nginx → Cleanup → ✅ Complete (Zero Downtime)
```

---

## 🔑 Key Information

### Development Server
- **IP:** 31.97.220.52
- **User:** root
- **Password:** SshJourva1@@
- **Branch:** dev

### Repositories
- **Backend:** https://github.com/JourvaInternasionalProject/jourva-backend-erp-saas.git
- **Frontend:** https://github.com/JourvaInternasionalProject/jourva-erp-frontend.git

### Ports
- **HTTP:** 80 (Nginx)
- **Backend:** 5000 (internal)
- **PostgreSQL:** 5432 (internal)

### Directories
- **Project Root:** `/opt/tourtravel`
- **Backend:** `/opt/tourtravel/backend`
- **Frontend:** `/opt/tourtravel/frontend`
- **Scripts:** `/opt/tourtravel/scripts`
- **Backups:** `/opt/tourtravel/backup`
- **Logs:** `/var/log/tourtravel-*-deploy.log`

---

## 🛠️ Common Commands

```bash
# SSH to dev server
ssh root@31.97.220.52

# Check all containers
docker ps

# Check logs
docker compose logs -f

# Restart services
docker compose restart

# Check backend health
curl http://31.97.220.52/health

# Check frontend
curl http://31.97.220.52/

# View deployment logs
tail -f /var/log/tourtravel-backend-dev-deploy.log
tail -f /var/log/tourtravel-frontend-dev-deploy.log
```

---

## 📞 Support & Troubleshooting

Each guide includes detailed troubleshooting sections:
- SSH connection issues
- Git pull failures
- Docker build errors
- Health check failures
- Nginx reload issues

Check the specific guide for detailed solutions.

---

## 🎯 Next Steps

1. ✅ Complete dev server setup
2. ✅ Setup CI/CD for dev branch
3. ⏳ Test auto-deployment
4. ⏳ Setup production server (when ready)
5. ⏳ Setup CI/CD for main branch
6. ⏳ Configure domain & SSL

---

**Last Updated:** February 14, 2026  
**Status:** Development Server Ready  
**Production:** Not yet configured
