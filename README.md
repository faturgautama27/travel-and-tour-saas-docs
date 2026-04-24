# Tour & Travel ERP SaaS — Documentation Hub

**Project**: Multi-Tenant Tour & Travel Agency ERP Platform  
**Tech Stack**: .NET 8 · Angular 20 · PostgreSQL 16 · PrimeNG 20 · TailwindCSS 4  
**Last Updated**: 24 April 2026

---

## � Struktur Dokumentasi

```
tour-and-travel-saas-docs/
├── README.md                    ← Kamu di sini
├── phase-1/                     Phase 1 MVP documentation
│   ├── MAIN-DOCUMENTATION.md    Overview lengkap Phase 1
│   ├── EXECUTIVE-SUMMARY.md     Business overview (non-technical)
│   ├── DEVELOPER-DOCUMENTATION.md  Technical specs lengkap
│   ├── TIMELINE.md              Week-by-week development plan
│   └── business-flows/          Business flow & requirements
│       ├── COMPLETE-JOURNEY-TO-BOOKING-FLOW.md
│       ├── PAYMENT-COMMISSION-SUMMARY.md
│       ├── PAYMENT-FLOW-DIAGRAM.md
│       ├── PAYMENT-TRACKING-COMPREHENSIVE.md
│       ├── SUPPLIER-SERVICE-MANAGEMENT-REQUIREMENTS.md
│       ├── JOURNEY-REFACTOR-REQUIREMENTS.md
│       └── COMPANY-SETTINGS-REQUIREMENTS.md
├── deployment/                  Infrastructure & deployment
│   ├── PRODUCTION_DEPLOYMENT_GUIDE.md
│   ├── SSL_SETUP_GUIDE.md
│   ├── MINIO-SETUP-GUIDE.md
│   ├── MINIO-NGINX-SETUP.md
│   └── MINIO-DIRECTORY-MIGRATION.md
├── implementation-guide/        Step-by-step implementation guides
│   ├── AI-AGENT-IMPLEMENTATION-PLAYBOOK.md
│   ├── MASTER-IMPLEMENTATION-GUIDE.md
│   ├── COMPLETE-IMPLEMENTATION-GUIDE-SUPPLIER-TO-BOOKING.md
│   ├── COMPLETE-PHASES-GUIDE.md
│   ├── JOURNEY-SYSTEM-PHASES-4-8.md
│   ├── 00-SYSTEM-FLOW-DIAGRAMS.md
│   ├── 01-SUPPLIER-SERVICE-MANAGEMENT.md
│   └── DOCUMENTATION-INDEX.md
├── scripts/                     Deployment & setup scripts
│   ├── deploy-native-backend.sh
│   ├── deploy-native-frontend.sh
│   ├── setup-dev-server.sh
│   ├── setup-native-server.sh
│   ├── setup-postgresql-remote.sh
│   └── setup-ssl-subdomain.sh
└── .kiro/specs/                 Kiro spec files
    ├── phase-2-erp-modules/     ← ACTIVE: Phase 2 spec
    │   ├── requirements.md      9 modul, 25+ requirements
    │   ├── design.md            Architecture, entities, properties
    │   ├── tasks.md             27 tasks, ~100 sub-tasks
    │   ├── PHASE_2_SUMMARY.md   Executive summary
    │   └── TRELLO_TASKS.md      Ready to import ke Trello
    ├── tour-travel-backend-phase1/
    ├── tour-travel-frontend-phase1/
    ├── json-based-mock-data/
    └── asana-task-automation/
```

---

## 🚀 Quick Navigation

### Phase 2 (Current — April 2026)
- [Phase 2 Summary](.kiro/specs/phase-2-erp-modules/PHASE_2_SUMMARY.md) — Executive summary 9 modul
- [Phase 2 Requirements](.kiro/specs/phase-2-erp-modules/requirements.md) — Requirements lengkap
- [Phase 2 Design](.kiro/specs/phase-2-erp-modules/design.md) — Technical design + correctness properties
- [Phase 2 Tasks](.kiro/specs/phase-2-erp-modules/tasks.md) — Implementation plan
- [Phase 2 Trello](.kiro/specs/phase-2-erp-modules/TRELLO_TASKS.md) — Trello import-ready

### Phase 1 (Completed — May 2026)
- [Main Documentation](phase-1/MAIN-DOCUMENTATION.md) — Overview lengkap
- [Developer Docs](phase-1/DEVELOPER-DOCUMENTATION.md) — Technical specs
- [Payment & Commission](phase-1/business-flows/PAYMENT-COMMISSION-SUMMARY.md) — Payment system design

### Deployment
- [Production Deployment](deployment/PRODUCTION_DEPLOYMENT_GUIDE.md)
- [SSL Setup](deployment/SSL_SETUP_GUIDE.md)
- [MinIO Setup](deployment/MINIO-SETUP-GUIDE.md)

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│                  Angular 20 SPA                   │
│          PrimeNG 20 · TailwindCSS 4 · NgRx       │
└──────────────────┬───────────────────────────────┘
                   │ HTTPS
┌──────────────────▼───────────────────────────────┐
│              .NET 8 Web API                       │
│     CQRS + MediatR · Clean Architecture           │
│     JWT Auth · FluentValidation · Hangfire         │
└──────┬──────────┬──────────┬──────────┬──────────┘
       │          │          │          │
  PostgreSQL   Xendit/    MinIO     Resend
     16        DOKU      Storage    Email
```

---

## 📞 Repositories

- **Backend**: `travel-and-tour-backend/`
- **Frontend**: `tour-and-travel-frontend/`
- **Docs**: `tour-and-travel-saas-docs/` (this repo)
