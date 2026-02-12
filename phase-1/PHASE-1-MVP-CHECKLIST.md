# Phase 1 MVP - Development Checklist

**Start Date:** February 16, 2026

**Target Demo:** April 26, 2026 (10 weeks)

**Demo Scope:** User dapat booking transaksi + Supplier dapat create service + Purchase Order workflow

---

## Week 1-2: Foundation & Backend Core

### Database Setup
- [ ] PostgreSQL 16 installation & configuration
- [ ] Create all database tables (Phase 1 core tables)
- [ ] Setup Row-Level Security (RLS) policies
- [ ] Seed master data (countries, cities, currencies)
- [ ] Create database indexes

### Backend API (.NET 8)
- [ ] Project structure setup (Clean Architecture)
- [ ] Configure Entity Framework Core
- [ ] Implement authentication (JWT)
- [ ] Implement authorization (role-based)
- [ ] Setup MediatR for CQRS
- [ ] Create base API response models
- [ ] Setup middleware (tenant context, exception handling)

### Core API Endpoints
- [ ] Auth endpoints (login, register, logout, refresh)
- [ ] User management endpoints
- [ ] Agency CRUD endpoints (platform admin)
- [ ] Supplier CRUD endpoints

---

## Week 3-4: Supplier & Package Management

### Supplier Portal Backend
- [ ] Supplier registration endpoint
- [ ] Supplier service CRUD endpoints
- [ ] Service publish/unpublish endpoints
- [ ] Supplier dashboard stats endpoint

### Agency Portal Backend
- [ ] Browse supplier services endpoint
- [ ] Package CRUD endpoints
- [ ] Package departure CRUD endpoints
- [ ] Package publish/unpublish endpoints
- [ ] Agency dashboard stats endpoint

### Frontend Setup (Angular)
- [ ] Angular project setup (reuse existing if possible)
- [ ] Configure routing (lazy loading)
- [ ] Setup authentication guards
- [ ] Setup HTTP interceptors (auth, tenant)
- [ ] Create shared components (header, sidebar, table, etc)
- [ ] Create layouts (admin, agency, supplier, traveler)

### Supplier Portal Frontend
- [ ] Login page
- [ ] Dashboard page
- [ ] Service list page
- [ ] Service create/edit form
- [ ] Service detail page

### Agency Portal Frontend
- [ ] Login page
- [ ] Dashboard page
- [ ] Browse supplier services page
- [ ] Package list page
- [ ] Package create form (multi-step)
- [ ] Package detail page

---

## Week 5-6: Purchase Orders & Booking Flow

### Purchase Order Backend
- [ ] Purchase orders table creation
- [ ] PO items table creation
- [ ] Create PO endpoint (Agency)
- [ ] List POs endpoint (Agency & Supplier)
- [ ] Get PO detail endpoint
- [ ] Approve PO endpoint (Supplier)
- [ ] Reject PO endpoint (Supplier)
- [ ] PO validation logic

### Purchase Order Frontend (Agency)
- [ ] PO list page
- [ ] PO create form
- [ ] PO detail page
- [ ] Link to package creation from approved PO

### Purchase Order Frontend (Supplier)
- [ ] PO list page (with pending section)
- [ ] PO detail page
- [ ] Approve/reject actions

### Package Creation Update
- [ ] Update package creation to support PO linking
- [ ] Pre-fill services from approved PO
- [ ] Display PO code in package details

### Traveler Portal Backend
- [ ] Browse packages endpoint (with search/filter)
- [ ] Package detail endpoint
- [ ] Create booking endpoint
- [ ] My bookings list endpoint
- [ ] Booking detail endpoint

### Agency Booking Backend
- [ ] Booking list endpoint (with filters)
- [ ] Pending bookings endpoint
- [ ] Approve booking endpoint
- [ ] Reject booking endpoint
- [ ] Create booking endpoint (staff manual)

### Traveler Portal Frontend
- [ ] Home page (featured packages)
- [ ] Package search/browse page
- [ ] Package detail page
- [ ] Booking form (multi-step)
- [ ] My bookings page
- [ ] Booking detail page

### Agency Booking Frontend
- [ ] Booking list page
- [ ] Pending approval page
- [ ] Booking detail page
- [ ] Approve/reject actions
- [ ] Manual booking form

---

## Week 7-8: Dashboard & UI Polish

### Platform Admin Frontend
- [ ] Login page
- [ ] Dashboard page (stats)
- [ ] Agency list page
- [ ] Agency create form
- [ ] Supplier list page
- [ ] Supplier approval page

### Dashboard Implementation
- [ ] Platform admin dashboard (total agencies, suppliers, bookings)
- [ ] Agency dashboard (pending bookings, revenue mock)
- [ ] Supplier dashboard (total services, booking requests)
- [ ] Traveler dashboard (my bookings summary)

### UI/UX Refinement
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Loading states
- [ ] Error handling & messages
- [ ] Success notifications
- [ ] Form validation
- [ ] Consistent styling
- [ ] Accessibility basics

---

## Week 9: Integration & Testing

### Integration Testing
- [ ] End-to-end flow testing (happy path)
  - Platform admin creates agency
  - Supplier creates service
  - Agency creates PO to supplier
  - Supplier approves PO
  - Agency creates package from approved PO
  - Customer creates booking
  - Agency approves booking
- [ ] Cross-browser testing (Chrome, Firefox, Safari)
- [ ] Responsive testing (mobile, tablet)
- [ ] API testing (Postman/Swagger)

### Bug Fixes
- [ ] Fix critical bugs
- [ ] Fix UI/UX issues
- [ ] Performance optimization
- [ ] Security review

### Demo Data Preparation
- [ ] Create demo agencies (3-5)
- [ ] Create demo suppliers (5-10)
- [ ] Create demo services (20-30)
- [ ] Create demo packages (10-15)
- [ ] Create demo bookings (5-10)

---

## Week 10: Demo Preparation

### Demo Script
- [ ] Write demo script (step-by-step)
- [ ] Prepare demo accounts (admin, agency, supplier, customer)
- [ ] Prepare demo data (clean & realistic)
- [ ] Create backup demo database

### Rehearsal
- [ ] Rehearsal 1 (internal team)
- [ ] Rehearsal 2 (with feedback)
- [ ] Rehearsal 3 (final run)

### Presentation Materials
- [ ] Demo slides (optional)
- [ ] Feature highlights document
- [ ] Roadmap presentation (Phase 2, 3, 4)
- [ ] Q&A preparation

### Deployment
- [ ] Deploy to demo server
- [ ] Test on demo server
- [ ] Prepare fallback (local demo if server fails)

---

## Phase 1 Features Summary

### ✅ Included (MVP Demo)

**Authentication & Authorization:**
- Multi-role login (Platform Admin, Agency, Supplier, Traveler)
- JWT-based authentication
- Role-based access control

**Platform Admin:**
- Agency onboarding (basic info)
- Supplier approval
- Basic dashboard

**Supplier Portal:**
- Service creation (Hotel, Flight, Visa, Transport, Guide)
- Service management (CRUD)
- Marketplace publishing
- Basic dashboard

**Agency Portal:**
- Browse supplier services
- Package creation (basic)
- Package management (CRUD)
- Booking management
- Approve/reject bookings
- Manual booking (staff)
- Basic dashboard

**Traveler Portal:**
- Browse packages
- Package detail
- Create booking
- My bookings
- Booking detail

**Database:**
- Core tables (users, agencies, suppliers, services, packages, bookings, travelers)
- Row-Level Security (RLS)
- Basic indexes

---

### ❌ Excluded (Phase 2+)

**Payment:**
- Payment gateway integration
- Payment processing
- Installment payment
- Invoice generation
- Receipt generation

**Documents:**
- File upload
- Document validation
- Document approval
- Passport OCR

**Email:**
- Email notifications
- Email templates

**Advanced Features:**
- Pricing tiers
- Itinerary builder
- Task management
- CRM
- Reporting
- Settlement
- Audit trail

---

## Technical Debt (Acceptable for Demo)

- Hardcoded master data (currencies, locations)
- No caching (direct DB queries)
- Minimal validation
- No email service
- No file storage service
- Mock payment status
- No unit tests (focus on integration tests)

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Timeline too tight | Cut scope aggressively, focus on happy path only |
| Team size insufficient | Reuse existing components, use scaffolding tools |
| Requirement creep | Freeze scope after documentation approved |
| Integration complexity | Mock external services for demo |
| Bug on demo day | Prepare backup demo data, rehearse 3x |

---

## Success Criteria

- ✅ Demo runs smoothly without errors
- ✅ Happy path booking flow complete (supplier → agency → customer → approve)
- ✅ All 4 user roles can login and access their dashboards
- ✅ Data persists in PostgreSQL
- ✅ Responsive UI (desktop & tablet)
- ✅ Client is satisfied with progress

---

## Post-Demo Next Steps

1. Gather feedback from demo
2. Prioritize Phase 2 features
3. Start Phase 2 development (payment integration)
4. Onboard pilot customers (3-5 agencies)

