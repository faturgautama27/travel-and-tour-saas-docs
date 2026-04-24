# Tour & Travel ERP SaaS - Development Timeline

**Project:** Multi-Tenant Tour & Travel Agency ERP Platform  
**Phase:** Phase 1 - MVP Demo  
**Duration:** 11 weeks (77 days)  
**Start Date:** February 16, 2026  
**Demo Date:** May 3, 2026  
**Version:** 3.0 (Revised)  
**Last Updated:** February 14, 2026

---

## 📅 Timeline Overview

```
Week 1-2  ████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  Foundation & Backend Core
Week 3    ░░░░░░░░████░░░░░░░░░░░░░░░░░░░░░░░░░░  Platform Admin & Supplier Portal
Week 4    ░░░░░░░░░░░░████░░░░░░░░░░░░░░░░░░░░░░  Supplier Services & Purchase Order
Week 5    ░░░░░░░░░░░░░░░░████░░░░░░░░░░░░░░░░░░  Package Management & Booking
Week 6    ░░░░░░░░░░░░░░░░░░░░████░░░░░░░░░░░░░░  Document & Task Management
Week 7    ░░░░░░░░░░░░░░░░░░░░░░░░████░░░░░░░░░░  Pre-Departure Notification & Payment
Week 8    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░████░░░░░░  Itinerary & Supplier Bills
Week 9    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████░░  B2B Marketplace & Profitability
Week 10   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██  Integration Testing & Bug Fixes
Week 11   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  Demo Preparation & Rehearsal
          ████████████████████████████████████████
          Feb 16                            May 3
```

---

## 🎯 Resource Allocation

### Team Composition
- **2 Backend Developers** (.NET 8) - Full-time
- **2 Frontend Developers** (Angular 20) - Full-time
- **1 QA Engineer** - Full-time (Week 9-11)
- **1 Project Manager** - Part-time (coordination)

### Work Distribution

**Backend Dev 1:**
- Foundation, Auth, Multi-tenancy
- Supplier Portal, PO Workflow
- Document Management
- Pre-Departure Notification

**Backend Dev 2:**
- Platform Admin
- Package Management, Booking
- Task Management
- Payment Tracking
- B2B Marketplace

**Frontend Dev 1:**
- Foundation, Layout, Auth
- Platform Admin Portal
- Supplier Portal
- Agency Package & Booking

**Frontend Dev 2:**
- Customer/Traveler Management
- Document & Task Management
- Payment & Itinerary
- B2B Marketplace (Agency A & B)

---

## Week-by-Week Breakdown

### **WEEK 1-2: Foundation & Backend Core** (Feb 16 - Mar 1)

**Goal:** Setup project infrastructure & core backend

#### Backend Tasks
- [ ] Project setup (.NET 8 + PostgreSQL 16)
- [ ] Database schema design (all 24+ tables)
- [ ] Database migration scripts
- [ ] Authentication & Authorization (JWT)
- [ ] Multi-tenancy setup (RLS policies)
- [ ] User management API
- [ ] Role-based access control (RBAC)
- [ ] Master data seeding (locations, service types, document types)
- [ ] API documentation (Swagger)
- [ ] Unit tests setup

#### Frontend Tasks
- [ ] Project setup (Angular 20 + PrimeNG 20 + TailwindCSS 4)
- [ ] Authentication module (login, logout, token management)
- [ ] Layout components (header, sidebar, footer)
- [ ] Routing setup (lazy loading)
- [ ] HTTP interceptor (auth token, error handling)
- [ ] State management setup (NgRx)
- [ ] Shared components (button, input, table, modal)
- [ ] Theme configuration (colors, fonts)

#### Deliverables
- ✅ Project infrastructure ready
- ✅ Authentication working
- ✅ Database schema created
- ✅ Basic UI layout

---

### **WEEK 3: Platform Admin & Supplier Portal** (Mar 2 - Mar 8)

**Goal:** Platform admin can onboard agencies, suppliers can register

#### Backend Tasks
- [ ] Agency management API (CRUD)
- [ ] Supplier registration API
- [ ] Supplier profile API
- [ ] Platform admin dashboard API (stats)

#### Frontend Tasks
- [ ] Platform Admin portal:
  - [ ] Agency list & form
  - [ ] Agency onboarding wizard
  - [ ] Dashboard (agencies, suppliers, bookings stats)
- [ ] Supplier portal:
  - [ ] Registration form
  - [ ] Profile management
  - [ ] Dashboard (services, POs stats)

#### Deliverables
- ✅ Platform admin can onboard agencies
- ✅ Suppliers can register

---

### **WEEK 4: Supplier Services & Purchase Order** (Mar 9 - Mar 15)

**Goal:** Suppliers can create services, agencies can create PO

#### Backend Tasks
- [ ] Supplier service API (CRUD) - with specific fields per service type
- [ ] Seasonal pricing API (date-based pricing)
- [ ] Service catalog API (browse, search, filter)
- [ ] Purchase Order API (create, list, detail)
- [ ] PO approval API (approve, reject)
- [ ] PO notification system

#### Frontend Tasks
- [ ] Supplier portal:
  - [ ] Service list & form (Hotel, Flight, Visa, Transport, Guide, Insurance, Catering, Handling)
  - [ ] Service detail page
  - [ ] Seasonal pricing management
  - [ ] Incoming PO list
  - [ ] PO approval page
- [ ] Agency portal:
  - [ ] Service catalog (browse, search, filter)
  - [ ] PO creation form
  - [ ] PO list & detail

#### Deliverables
- ✅ Suppliers can create services (8 types)
- ✅ Seasonal pricing working
- ✅ Agencies can create PO
- ✅ Suppliers can approve/reject PO

---

### **WEEK 5: Package Management & Booking (Staff Input)** (Mar 16 - Mar 22)

**Goal:** Agencies can create packages & journeys, staff can create bookings

#### Backend Tasks
- [ ] Package API (CRUD)
- [ ] Package pricing API (markup calculation)
- [ ] Package-PO linking API
- [ ] Journey API (CRUD) - actual trips with dates
- [ ] Journey service tracking API
- [ ] Booking API (create, list, detail, update, cancel)
- [ ] Booking status workflow API
- [ ] Customer API (CRUD, search)
- [ ] Traveler API (CRUD)

#### Frontend Tasks
- [ ] Agency portal:
  - [ ] Package list & form
  - [ ] Package creation from PO
  - [ ] Package pricing configuration
  - [ ] Journey management (create, list, detail)
  - [ ] Booking list (table with filters)
  - [ ] Booking form (multi-step: package → journey → customer → travelers → review)
  - [ ] Booking detail page
  - [ ] Customer search & select
  - [ ] Customer form (create/edit)
  - [ ] Traveler form (add/edit with mahram)

#### Deliverables
- ✅ Agencies can create packages from approved PO
- ✅ Agencies can create journeys with specific dates
- ✅ Staff can create bookings manually
- ✅ Customer management working

---

### **WEEK 6: Document Management & Task Management** (Mar 23 - Mar 29)

**Goal:** Document tracking and task automation per booking

#### Backend Tasks
- [ ] Document types master data
- [ ] Booking documents API (checklist, status update)
- [ ] Document verification API
- [ ] Document dashboard API
- [ ] Task templates master data
- [ ] Booking tasks API (auto-generation, CRUD)
- [ ] Task status update API
- [ ] Task assignment API
- [ ] Task dashboard API

#### Frontend Tasks
- [ ] Agency portal:
  - [ ] Document checklist component (per booking)
  - [ ] Document status update
  - [ ] Document verification form
  - [ ] Document dashboard (incomplete, expiring)
  - [ ] Task board (Kanban: To Do, In Progress, Done)
  - [ ] Task list (per booking)
  - [ ] Task form (create custom task)
  - [ ] Task assignment
  - [ ] My tasks page

#### Deliverables
- ✅ Document tracking per booking
- ✅ Task auto-generation per booking
- ✅ Task board (Kanban)

---

### **WEEK 7: Pre-Departure Notification & Payment Tracking** (Mar 30 - Apr 5)

**Goal:** Automated notifications and payment tracking

#### Backend Tasks
- [ ] Notification schedules API (CRUD)
- [ ] Notification templates API (CRUD)
- [ ] Notification sending service (email + in-app)
- [ ] Notification logs API
- [ ] Notification dashboard API
- [ ] Background job: Daily notification sender
- [ ] Background job: Notification retry
- [ ] Payment schedule API (CRUD)
- [ ] Payment recording API
- [ ] Payment dashboard API
- [ ] Outstanding payments API

#### Frontend Tasks
- [ ] Agency portal:
  - [ ] Notification schedule management
  - [ ] Notification template editor
  - [ ] Notification history (per booking)
  - [ ] Notification dashboard
  - [ ] Manual notification trigger
  - [ ] Payment schedule component (per booking)
  - [ ] Payment recording form
  - [ ] Payment history
  - [ ] Outstanding payments list
  - [ ] Payment dashboard

#### Deliverables
- ✅ Automated pre-departure notifications (H-30, H-14, H-7, H-3, H-1)
- ✅ Payment tracking per booking
- ✅ Outstanding payments monitoring

---

### **WEEK 8: Itinerary Builder & Supplier Bills** (Apr 6 - Apr 12)

**Goal:** Itinerary creation and supplier payables tracking

#### Backend Tasks
- [ ] Itinerary API (CRUD)
- [ ] Itinerary days API (CRUD)
- [ ] Itinerary activities API (CRUD)
- [ ] Itinerary templates API
- [ ] Itinerary PDF export API
- [ ] Itinerary share link API
- [ ] Supplier bills API (auto-generation from PO)
- [ ] Supplier payment API (record payment)
- [ ] Supplier payables dashboard API

#### Frontend Tasks
- [ ] Agency portal:
  - [ ] Itinerary builder (day-by-day)
  - [ ] Itinerary activity form
  - [ ] Itinerary template selector
  - [ ] Itinerary preview
  - [ ] Itinerary PDF export
  - [ ] Supplier bill list
  - [ ] Supplier bill detail
  - [ ] Supplier payment form
  - [ ] Outstanding payables list
  - [ ] Payables dashboard

#### Deliverables
- ✅ Itinerary builder working
- ✅ Itinerary PDF export
- ✅ Supplier bills tracking
- ✅ Supplier payment recording

---

### **WEEK 9: B2B Marketplace & Profitability** (Apr 13 - Apr 19)

**Goal:** Agency-to-agency reselling and profitability tracking

#### Backend Tasks
- [ ] Agency services API (publish from PO)
- [ ] Agency orders API (order flow)
- [ ] Marketplace API (browse, search, filter)
- [ ] Order approval workflow API
- [ ] Quota management logic
- [ ] Supplier name hiding logic
- [ ] Sales report API (Agency A)
- [ ] Purchase history API (Agency B)
- [ ] Profitability calculation API (per booking, per package)
- [ ] Profitability dashboard API
- [ ] Background job: Auto-reject pending orders (24 hours)
- [ ] Background job: Auto-unpublish zero quota services

#### Frontend Tasks
- [ ] Agency portal - Seller (Agency A):
  - [ ] Publish service form (from PO)
  - [ ] My published services list
  - [ ] Incoming orders list
  - [ ] Order approval component
  - [ ] Sales report
- [ ] Agency portal - Buyer (Agency B):
  - [ ] Marketplace browse (filter, search)
  - [ ] Marketplace service detail (supplier hidden)
  - [ ] Create order form
  - [ ] My orders list
  - [ ] Order detail
  - [ ] Purchase history
- [ ] Profitability:
  - [ ] Profitability component (per booking)
  - [ ] Profitability dashboard (charts, stats)

#### Deliverables
- ✅ B2B marketplace working (Agency A ↔ Agency B)
- ✅ Supplier name HIDDEN from buyers
- ✅ Quota management working
- ✅ Order approval workflow
- ✅ Profitability tracking working

---

### **WEEK 10: Integration Testing & Bug Fixes** (Apr 20 - Apr 26)

**Goal:** End-to-end testing and bug fixes

#### Tasks
- [ ] End-to-end testing (all workflows)
- [ ] Integration testing (API + Frontend)
- [ ] Cross-browser testing (Chrome, Firefox, Safari, Edge)
- [ ] Responsive testing (desktop, tablet)
- [ ] Performance testing (load time, API response)
- [ ] Security testing (authentication, authorization, RLS)
- [ ] Bug fixes (critical and high priority)
- [ ] Code review
- [ ] Documentation update
- [ ] Demo data preparation

#### Test Scenarios
1. Platform admin onboards agency
2. Supplier registers and creates services (8 types)
3. Supplier creates seasonal pricing
4. Agency creates PO and gets approval
5. Agency creates package from approved PO
6. Agency creates journey with specific dates
7. Agency staff creates booking manually
8. Document checklist auto-generated
9. Tasks auto-generated (After Booking, H-30, H-7)
10. Staff verifies documents
11. Staff completes tasks
12. Staff records payments
13. Pre-departure notifications sent (H-30, H-7, H-1)
14. Staff creates itinerary
15. Agency A publishes service to marketplace
16. Agency B browses marketplace (supplier name hidden)
17. Agency B creates order to Agency A
18. Agency A approves order
19. Quota management working
20. Staff views profitability
21. All dashboards show correct data

#### Deliverables
- ✅ All critical bugs fixed
- ✅ System stable and tested
- ✅ Demo data ready

---

### **WEEK 11: Demo Preparation & Rehearsal** (Apr 27 - May 3)

**Goal:** Demo preparation and final polish

#### Tasks
- [ ] Demo script preparation (detailed flow)
- [ ] Demo data finalization (realistic data)
- [ ] Demo environment setup (staging server)
- [ ] Demo rehearsal #1 (internal team)
- [ ] Feedback incorporation
- [ ] Demo rehearsal #2 (with stakeholders)
- [ ] Final adjustments
- [ ] Demo rehearsal #3 (full run)
- [ ] Presentation materials (slides, handouts)
- [ ] Backup plan (if demo fails)
- [ ] Video recording setup
- [ ] Q&A preparation
- [ ] UI/UX final polish
- [ ] Performance optimization

#### Demo Script (60 minutes)

**Part 1: Introduction (5 min)**
- Platform overview
- Value proposition
- Demo agenda

**Part 2: Platform Admin (5 min)**
- Onboard new agency
- Show platform dashboard

**Part 3: Supplier Portal (10 min)**
- Create services (Hotel, Flight, Visa, Transport, Guide)
- Create seasonal pricing
- Receive PO from agency
- Approve PO

**Part 4: Agency ERP - Package & Booking (15 min)**
- Browse supplier services
- Create PO
- Create package from approved PO
- Create journey with specific dates
- Create booking manually (staff input)
- Show customer CRM

**Part 5: Agency ERP - Operations (15 min)** ⭐ **HIGHLIGHT**
- Document checklist (auto-generated)
- Document verification
- Task board (Kanban)
- Task completion
- Pre-departure notification system (H-30, H-7, H-1)
- Payment tracking
- Itinerary builder

**Part 6: B2B Marketplace (10 min)** ⭐ **NEW**
- Agency A publishes excess inventory
- Agency B browses marketplace (supplier name hidden)
- Agency B creates order
- Agency A approves order
- Quota management

**Part 7: Analytics & Reports (5 min)**
- Profitability tracking
- Comprehensive dashboard
- Reports

#### Deliverables
- ✅ Demo script finalized
- ✅ Demo rehearsed 3x
- ✅ Presentation materials ready
- ✅ **DEMO READY: May 3, 2026** 🎯

---

## 📊 Effort Estimation Summary

### Backend Development

| Module | Effort (days) |
|--------|---------------|
| Foundation & Auth | 8 |
| Platform Admin | 2 |
| Supplier Portal | 3 |
| Supplier Services | 3 |
| Seasonal Pricing | 1 |
| Purchase Order | 3 |
| Package Management | 3 |
| Journey Management | 2 |
| Booking Management | 3 |
| Customer/Traveler Management | 2 |
| Document Management | 3 |
| Task Management | 4 |
| Pre-Departure Notification | 3 |
| Payment Tracking | 2 |
| Itinerary Builder | 2 |
| Supplier Bills & Payables | 3 |
| B2B Marketplace | 4 |
| Profitability Tracking | 2 |
| Dashboards | 3 |
| **Total Backend** | **56 days** |

### Frontend Development

| Module | Effort (days) |
|--------|---------------|
| Foundation & Layout | 8 |
| Platform Admin Portal | 2 |
| Supplier Portal | 4 |
| Agency Package Management | 3 |
| Agency Journey Management | 2 |
| Agency Booking Management | 3 |
| Customer/Traveler Management | 2 |
| Document Management | 3 |
| Task Management | 4 |
| Pre-Departure Notification | 2 |
| Payment Tracking | 2 |
| Itinerary Builder | 3 |
| Supplier Bills & Payables | 2 |
| B2B Marketplace | 4 |
| Profitability Tracking | 2 |
| Dashboards | 3 |
| **Total Frontend** | **49 days** |

### Testing & Demo Preparation

| Activity | Effort (days) |
|----------|---------------|
| Integration Testing | 3 |
| Bug Fixes | 4 |
| Demo Preparation | 5 |
| **Total Testing** | **12 days** |

### **GRAND TOTAL: 117 days**

**With 2 Backend + 2 Frontend Developers:** ~29 days per developer = **~6 weeks** (aggressive)

**With buffer for coordination & reviews:** **11 weeks** ✅

---

## 🚨 Critical Path & Dependencies

### Critical Path (Must Complete in Order)
1. **Week 1-2:** Foundation (blocks everything)
2. **Week 3:** Platform Admin & Supplier Portal (blocks Week 4)
3. **Week 4:** Supplier Services & PO (blocks Week 5)
4. **Week 5:** Package & Booking (blocks Week 6-9)
5. **Week 6-8:** ERP Modules (can be parallel)
6. **Week 9:** B2B Marketplace (depends on Week 4-5)
7. **Week 10:** Testing (depends on all)
8. **Week 11:** Demo Prep (depends on Week 10)

### Parallel Work Opportunities
- **Week 6-8:** Document, Task, Notification, Payment, Itinerary can be developed in parallel
- **Week 9:** B2B Marketplace and Profitability can be parallel
- **Backend & Frontend:** Always parallel

---

## 🎯 Milestones & Checkpoints

### Milestone 1: Foundation Complete (End of Week 2)
- ✅ Authentication working
- ✅ Database schema created
- ✅ Basic UI layout
- **Checkpoint:** Internal demo of login & basic navigation

### Milestone 2: B2B Core Complete (End of Week 4)
- ✅ Supplier can create services
- ✅ Agency can create PO
- ✅ Supplier can approve PO
- **Checkpoint:** Demo PO workflow to stakeholders

### Milestone 3: Booking Flow Complete (End of Week 5)
- ✅ Package & Journey creation
- ✅ Staff can create bookings
- **Checkpoint:** Demo booking creation flow

### Milestone 4: ERP Modules Complete (End of Week 8)
- ✅ Document tracking
- ✅ Task management
- ✅ Notifications
- ✅ Payment tracking
- ✅ Itinerary builder
- **Checkpoint:** Demo complete ERP workflow

### Milestone 5: B2B Marketplace Complete (End of Week 9)
- ✅ Agency A can publish services
- ✅ Agency B can order from Agency A
- **Checkpoint:** Demo B2B marketplace flow

### Milestone 6: System Stable (End of Week 10)
- ✅ All tests passing
- ✅ No critical bugs
- **Checkpoint:** Final QA sign-off

### Milestone 7: Demo Ready (May 3, 2026)
- ✅ Demo rehearsed 3x
- ✅ All materials ready
- **Checkpoint:** DEMO DAY 🎯

---

## 🚨 Risks & Mitigation

### Risk 1: Timeline Too Tight (11 weeks for 19 modules)
**Probability:** Medium  
**Impact:** High  
**Mitigation:**
- Parallel development (2 backend + 2 frontend)
- Daily standup to track progress
- Weekly demo to stakeholders for early feedback
- Descope Tier 2 modules if needed (Communication Log)

### Risk 2: Pre-Departure Notification System Complexity
**Probability:** Medium  
**Impact:** Medium  
**Mitigation:**
- Use simple cron job (not complex queue system)
- Email sending can be mocked (in-app notification only)
- Notification templates can be hardcoded (not dynamic editor)
- Focus on H-7 and H-1 notifications only (skip H-30, H-14, H-3 if needed)

### Risk 3: Task Auto-Generation Logic
**Probability:** Medium  
**Impact:** Medium  
**Mitigation:**
- Use simple task templates (not complex rule engine)
- Auto-generate only on booking creation (not on status change)
- Manual task creation always available as fallback

### Risk 4: B2B Marketplace Quota Management
**Probability:** Low  
**Impact:** High  
**Mitigation:**
- Use database transactions for quota updates
- Implement pessimistic locking
- Thorough testing of concurrent orders

### Risk 5: Scope Creep During Development
**Probability:** High  
**Impact:** High  
**Mitigation:**
- Freeze scope after this document approved
- Change request process (must be approved by both parties)
- Weekly scope review meeting
- Clear "Phase 2" parking lot for new requests

---

## 📞 Communication Plan

### Daily Standup (15 minutes)
- **Time:** 09:00 AM
- **Attendees:** All developers + PM
- **Format:** What did you do yesterday? What will you do today? Any blockers?

### Weekly Demo (30 minutes)
- **Time:** Friday 16:00 PM
- **Attendees:** Team + Stakeholders
- **Format:** Demo completed features, get feedback

### Weekly Planning (1 hour)
- **Time:** Monday 09:00 AM
- **Attendees:** All developers + PM
- **Format:** Review last week, plan this week, adjust timeline if needed

### Bi-Weekly Retrospective (1 hour)
- **Time:** Every other Friday 14:00 PM
- **Attendees:** All team members
- **Format:** What went well? What can be improved? Action items

---

## ✅ Definition of Done

### For Each Feature
- [ ] Code implemented and reviewed
- [ ] Unit tests written and passing
- [ ] Integration tests passing
- [ ] API documentation updated
- [ ] Frontend UI implemented
- [ ] Manual testing completed
- [ ] No critical bugs
- [ ] Deployed to staging environment

### For Each Week
- [ ] All planned features completed
- [ ] Weekly demo conducted
- [ ] Stakeholder feedback incorporated
- [ ] No blocking issues for next week

### For Demo Day
- [ ] All features working end-to-end
- [ ] Demo script finalized
- [ ] Demo rehearsed 3x
- [ ] Demo data realistic and complete
- [ ] Presentation materials ready
- [ ] Backup plan prepared

---

**Status:** ✅ Ready for Team Review & Approval

**Next Action:** Schedule kickoff meeting on February 16, 2026

