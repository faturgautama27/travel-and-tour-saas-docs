# Tour & Travel ERP SaaS - Main Documentation

**Project:** Multi-Tenant Tour & Travel Agency ERP Platform  
**Phase:** Phase 1 - MVP Demo  
**Version:** 3.0 (Revised)  
**Last Updated:** February 14, 2026

---

## 📖 Table of Contents

1. [Introduction](#introduction)
2. [Project Overview](#project-overview)
3. [User Roles](#user-roles)
4. [Core Features](#core-features)
5. [Database Schema](#database-schema)
6. [Business Workflows](#business-workflows)
7. [Technical Architecture](#technical-architecture)
8. [Development Timeline](#development-timeline)
9. [Success Criteria](#success-criteria)
10. [References](#references)

---

## Introduction

This is the main documentation for the Tour & Travel ERP SaaS platform Phase 1 MVP. This document provides a comprehensive overview of the system, combining business and technical perspectives.

### Document Purpose

This main documentation serves as:
- **Single source of truth** for the project
- **Reference guide** for all team members
- **Onboarding material** for new team members
- **Communication tool** between business and technical teams

### How to Use This Document

- **Stakeholders:** Read sections 1-4 for business overview
- **Developers:** Read sections 5-7 for technical details
- **Project Managers:** Read sections 8-9 for planning
- **All Team Members:** Use section 10 for detailed references

### Related Documents

For detailed information, refer to:
- **[EXECUTIVE-SUMMARY.md](./EXECUTIVE-SUMMARY.md)** - Business overview (non-technical)
- **[DEVELOPER-DOCUMENTATION.md](./DEVELOPER-DOCUMENTATION.md)** - Complete technical specs
- **[TIMELINE.md](./TIMELINE.md)** - Week-by-week development plan
- **[README.md](./README.md)** - Documentation hub & navigation

---

## Project Overview

### Vision

Build a comprehensive SaaS ERP platform for travel agencies that focuses on:
1. **B2B Operations** - Supplier management & procurement
2. **Agency ERP** - Complete operational management
3. **B2B Marketplace** - Agency-to-agency reselling

### Value Proposition

**"Complete Agency ERP Solution - From Supplier Procurement to Customer Departure"**

### Key Objectives

1. **Operational Efficiency**
   - Automate document tracking
   - Automate task management
   - Automate pre-departure notifications
   - Centralize customer data

2. **Revenue Optimization**
   - Profitability visibility per booking
   - B2B marketplace for excess inventory
   - Better pricing decisions

3. **Customer Satisfaction**
   - Timely notifications
   - Complete document tracking
   - Professional itinerary
   - Better communication

### Project Timeline

- **Start Date:** February 16, 2026
- **Demo Date:** May 3, 2026
- **Duration:** 11 weeks (77 days)

### Technology Stack

**Backend:**
- .NET 8, PostgreSQL 16, Entity Framework Core 8
- CQRS with MediatR, FluentValidation
- JWT Authentication, Hangfire

**Frontend:**
- Angular 20, PrimeNG 20, TailwindCSS 4
- NgRx for state management
- Standalone components

**Infrastructure:**
- Docker, Docker Compose
- Nginx (reverse proxy)

---

## User Roles

### 1. Platform Administrator
**Responsibilities:**
- Manage travel agencies on platform
- Approve supplier registrations
- Monitor platform statistics
- Manage B2B marketplace (admin view)

**Key Features:**
- Agency onboarding
- Supplier approval
- Platform dashboard
- Marketplace monitoring

### 2. Supplier (Hotel, Flight, Visa, Transport, Guide, Insurance, Catering, Handling)
**Responsibilities:**
- Publish services to platform
- Manage seasonal pricing
- Receive and approve Purchase Orders
- Track business performance

**Key Features:**
- Service management (8 types)
- Seasonal pricing
- PO approval workflow
- Supplier dashboard

### 3. Travel Agency Staff
**Responsibilities:**
- Procurement from suppliers
- Package & journey management
- Customer booking management
- ERP operations (documents, tasks, payments)
- B2B marketplace (buy/sell)

**Key Features:**
- Service catalog browsing
- Purchase Order creation
- Package & journey management
- Booking management (staff-input)
- Customer CRM
- Document tracking
- Task management (Kanban)
- Pre-departure notifications
- Payment tracking
- Itinerary builder
- Supplier bills & payables
- B2B marketplace (seller & buyer)
- Profitability tracking
- Communication log

---

## Core Features

### Foundation Features (Week 1-2)

#### 1. Multi-Tenant System
- Complete data isolation between agencies
- Row-Level Security (RLS) in PostgreSQL
- Tenant context from JWT token

#### 2. Authentication & Authorization
- JWT-based authentication
- Role-based access control (3 roles)
- Password hashing with BCrypt
- Token refresh mechanism

#### 3. Master Data Management
- Locations (cities, countries)
- Service types
- Document types
- Task templates
- Notification templates

### B2B Procurement Features (Week 3-4)

#### 4. Supplier Service Management
- 8 service types: Hotel, Flight, Visa, Transport, Guide, Insurance, Catering, Handling
- Specific fields per service type (not JSONB)
- Service publishing workflow
- Service catalog for agencies

#### 5. Seasonal Pricing
- Date-based price variations
- High season / low season pricing
- Holiday pricing
- Price calculation function

#### 6. Purchase Order Workflow
- PO creation by agency
- PO approval by supplier
- PO status tracking
- PO-to-package linking

### Package & Journey Features (Week 5)

#### 7. Package Management
- Packages as reusable templates (NO dates)
- Package types: Umrah, Hajj, Halal Tour, General Tour, Custom
- Markup calculation (fixed or percentage)
- Package publishing

#### 8. Journey Management
- Journeys as actual trips (WITH dates)
- Quota management (total, confirmed, available)
- Journey status workflow
- Service tracking per journey

#### 9. Booking Management (Staff-Input)
- Manual booking creation by staff
- Customer & traveler management
- Mahram validation for Umrah/Hajj
- Booking status workflow
- Quota management

### Agency ERP Features (Week 6-9)

#### 10. Customer Management (CRM)
- Customer master data
- Customer notes & tags
- Booking history
- Customer statistics

#### 11. Document Management
- Auto-generate document checklist
- Document status tracking
- Document expiry tracking
- Document completion percentage

#### 12. Task Management
- Auto-generate task checklist
- Kanban board (To Do, In Progress, Done)
- Task assignment
- Task templates (After Booking, H-30, H-7)

#### 13. Pre-Departure Notification System
- Automated notifications (H-30, H-14, H-7, H-3, H-1)
- Customizable templates
- Email + In-app notifications
- Notification delivery tracking

#### 14. Payment Tracking
- Payment schedule per booking
- Payment recording (manual)
- Outstanding payment tracking
- Payment reminders

#### 15. Itinerary Builder
- Day-by-day itinerary
- Activity scheduling
- Meal planning
- Itinerary templates
- PDF export

#### 16. Supplier Bills & Payables
- Auto-generate bills from PO
- Payment recording to suppliers
- Outstanding payables tracking

#### 17. Profitability Tracking
- Revenue vs Cost per booking
- Gross profit & margin calculation
- Low/high margin identification

#### 18. Communication Log
- Log customer interactions
- Follow-up reminders
- Communication history

### B2B Marketplace Features (Week 9)

#### 19. Agency Reseller Marketplace

**For Agency A (Seller/Wholesaler):**
- Publish excess inventory to marketplace
- Set reseller price (with markup)
- Hide supplier information from buyers
- Approve/reject orders from other agencies
- Sales report

**For Agency B (Buyer/Retailer):**
- Browse marketplace
- See services from other agencies (supplier name HIDDEN)
- Create orders to other agencies
- Use approved orders for package creation
- Purchase history

**Benefits:**
- Agency A: Maximize inventory utilization
- Agency B: Access inventory without direct supplier relationships
- Platform: Commission from both sides

#### 20. Subscription & Commission Management

**Platform Admin Features:**
- Subscription plan management (create, update, activate/deactivate)
- Assign subscription plans to agencies
- Commission configuration (booking, marketplace transactions)
- Revenue dashboard (subscription + commission revenue)
- Agency subscription tracking
- Commission transaction monitoring

**Subscription Plans:**
- Multiple tiers (Basic, Professional, Enterprise)
- Monthly/Annual billing cycles
- Feature limits (max users, max bookings per month)
- Auto-renewal management

**Commission System:**
- Configurable commission rates (percentage or fixed)
- Transaction types: Bookings, Marketplace sales/purchases
- Min/max transaction amounts
- Effective date ranges
- Commission collection tracking

**Revenue Metrics:**
- Total subscription revenue
- Total commission revenue (bookings + marketplace)
- Active agencies count
- New agencies / Churned agencies
- Transaction volumes

---

## Database Schema

### Overview

The system uses PostgreSQL 16 with 29+ tables organized into logical groups:

1. **Core Tables** (3): users, agencies, suppliers
2. **Service Tables** (2): supplier_services, supplier_service_seasonal_prices
3. **Purchase Order Tables** (2): purchase_orders, po_items
4. **Package Tables** (4): packages, package_services, journeys, journey_services
5. **Customer & Booking Tables** (3): customers, bookings, travelers
6. **Document Tables** (2): document_types, booking_documents
7. **Task Tables** (2): task_templates, booking_tasks
8. **Notification Tables** (3): notification_schedules, notification_templates, notification_logs
9. **Payment Tables** (2): payment_schedules, payment_transactions
10. **Itinerary Tables** (3): itineraries, itinerary_days, itinerary_activities
11. **Supplier Bills Tables** (2): supplier_bills, supplier_payments
12. **Communication Tables** (1): communication_logs
13. **B2B Marketplace Tables** (2): agency_services, agency_orders
14. **Subscription & Commission Tables** (5): subscription_plans, agency_subscriptions, commission_configs, commission_transactions, revenue_metrics

**Total: 29+ tables**

### Key Schema Changes from v2

#### 1. supplier_services (MODIFIED)
**Old:** Used JSONB `service_details` for all service-specific fields  
**New:** Specific fields per service type for better queryability

**Added fields:**
- Flight: airline, flight_class, departure_airport, arrival_airport, etc.
- Hotel: hotel_name, hotel_star_rating, room_type, distance_to_haram, etc.
- Visa: visa_type, processing_days, validity_days, entry_type, etc.
- Transport: vehicle_type, vehicle_capacity, driver_included, etc.
- Guide: guide_language (JSONB array), guide_specialization, etc.
- Insurance: insurance_type, coverage_amount, age_limit, etc.
- Catering: meal_type, cuisine_type, halal_certified, etc.
- Handling: handling_type, service_location, service_duration, etc.

**Kept:** `service_details` JSONB for non-critical additional info only

#### 2. packages (MODIFIED)
**Old:** Had departure_date, return_date  
**New:** Removed date fields (packages are templates)

**Rationale:** Packages should be reusable templates. Actual trip dates go in `journeys` table.

#### 3. bookings (MODIFIED)
**Old:** Referenced package_departure_id  
**New:** References journey_id and customer_id

**Added fields:**
- journey_id (instead of package_departure_id)
- customer_id (link to customers table)
- booking_source (staff, phone, walk_in, whatsapp)

For complete database schema with all tables, see [DEVELOPER-DOCUMENTATION.md](./DEVELOPER-DOCUMENTATION.md#database-schema).

---

## Business Workflows

### 1. Supplier Onboarding & Service Creation

```
Supplier Registration
    ↓
Platform Admin Approval
    ↓
Supplier Creates Services (8 types)
    ↓
Supplier Sets Seasonal Pricing (optional)
    ↓
Supplier Publishes Services
    ↓
Services Visible in Agency Catalog
```

### 2. Agency Procurement & Package Creation

```
Agency Browses Service Catalog
    ↓
Agency Creates Purchase Order (PO)
    ↓
Supplier Receives PO Notification
    ↓
Supplier Approves/Rejects PO
    ↓
[If Approved]
    ↓
Agency Creates Package from Approved PO
    ↓
Agency Creates Journey (with specific dates)
    ↓
Agency Publishes Package
```

### 3. Booking Creation & Management (Staff-Input)

```
Customer Walks In / Calls / WhatsApp
    ↓
Staff Searches/Creates Customer
    ↓
Staff Selects Package & Journey
    ↓
Staff Adds Travelers (with mahram validation)
    ↓
System Auto-Generates:
    - Document Checklist
    - Task Checklist (After Booking)
    - Payment Schedule
    ↓
Booking Created (Status: Pending)
    ↓
Staff Approves Booking
    ↓
Booking Confirmed (Quota Decremented)
```

### 4. Document & Task Management

```
Booking Confirmed
    ↓
Document Checklist Auto-Generated
    ↓
Staff Collects Documents from Customer
    ↓
Staff Updates Document Status
    ↓
Staff Verifies Documents
    ↓
Document Completion: 100%
    ↓
[Parallel]
Task Checklist Auto-Generated
    ↓
Staff Completes Tasks (Kanban Board)
    ↓
H-30: Auto-Generate H-30 Tasks
    ↓
H-7: Auto-Generate H-7 Tasks
    ↓
All Tasks Completed
```

### 5. Pre-Departure Notification Flow

```
Booking Confirmed
    ↓
System Checks Daily (09:00 AM)
    ↓
If Departure Date - Today = Trigger Days
    ↓
Create Notification Log
    ↓
Send Notification (Email + In-app)
    ↓
[If Failed]
    ↓
Retry up to 3 times (1 hour interval)
    ↓
[If Still Failed]
    ↓
Mark as Failed Permanently
```

**Notification Schedule:**
- H-30: Final payment reminder
- H-14: Document check
- H-7: Pre-departure briefing
- H-3: Final confirmation
- H-1: Departure reminder

### 6. Payment Tracking Flow

```
Booking Confirmed
    ↓
Payment Schedule Auto-Generated:
    - DP (40%) - Due: Booking Date + 3 days
    - Installment 1 (30%) - Due: Departure - 60 days
    - Installment 2 (30%) - Due: Departure - 30 days
    ↓
Customer Makes Payment
    ↓
Staff Records Payment
    ↓
Payment Schedule Updated
    ↓
[If Overdue]
    ↓
System Highlights Overdue Payment
    ↓
Staff Sends Payment Reminder
```

### 7. B2B Marketplace Flow

**Agency A (Seller) Flow:**
```
Agency A Creates PO (100 rooms)
    ↓
Supplier Approves PO
    ↓
Agency A Uses 80 rooms for own package
    ↓
Agency A Publishes 20 rooms to Marketplace
    - Set Reseller Price (with markup)
    - Supplier Name HIDDEN
    ↓
Service Visible in Marketplace
    ↓
Agency B Creates Order (10 rooms)
    ↓
Quota Reserved (Available: 20 → 10)
    ↓
Agency A Receives Order Notification
    ↓
Agency A Approves Order
    ↓
Quota Transferred (Sold: 0 → 10)
    ↓
Agency B Can Use in Package
```

**Agency B (Buyer) Flow:**
```
Agency B Browses Marketplace
    ↓
Agency B Finds "Hotel Makkah 5-star"
    - From: Agency A
    - Supplier: HIDDEN
    - Price: $130/room
    - Available: 20 rooms
    ↓
Agency B Creates Order (10 rooms)
    ↓
Order Status: Pending
    ↓
[Wait for Agency A Approval]
    ↓
Order Approved
    ↓
Agency B Creates Package using Approved Order
    ↓
Agency B Creates Booking
```

**Auto-Reject Logic:**
- If no response in 24 hours → Auto-reject
- Quota released back to available

**Auto-Unpublish Logic:**
- If available quota = 0 → Auto-unpublish

---

## Technical Architecture

### Clean Architecture Layers

```
API Layer (Controllers, Middleware)
    ↓
Application Layer (CQRS Commands/Queries)
    ↓
Domain Layer (Entities, Business Logic)
    ↑
Infrastructure Layer (EF Core, External Services)
```

### Multi-Tenancy Strategy

**Row-Level Security (RLS):**
- Each agency is a tenant
- RLS policies filter data automatically
- Session variable: `app.current_agency_id`
- Complete data isolation

### CQRS Pattern

**Commands (Write):**
- CreateBookingCommand
- ApproveBookingCommand
- UpdateDocumentStatusCommand
- etc.

**Queries (Read):**
- GetBookingsQuery
- GetBookingByIdQuery
- GetDocumentsQuery
- etc.

### API Endpoints

**Total: 80+ endpoints**

Categories:
- Authentication (5 endpoints)
- Platform Admin (15 endpoints)
- Supplier (20 endpoints)
- Agency Core (25 endpoints)
- Agency ERP (40+ endpoints)
- B2B Marketplace (15 endpoints)

For complete API documentation, see [DEVELOPER-DOCUMENTATION.md](./DEVELOPER-DOCUMENTATION.md#api-endpoints).

### Background Jobs (Hangfire)

1. **Daily Notification Job** - Send pre-departure notifications (09:00 AM)
2. **Notification Retry Job** - Retry failed notifications (hourly)
3. **H-30 Tasks Job** - Generate H-30 tasks (08:00 AM)
4. **H-7 Tasks Job** - Generate H-7 tasks (08:00 AM)
5. **Auto-Reject Orders Job** - Reject pending orders > 24h (hourly)
6. **Auto-Unpublish Services Job** - Unpublish zero quota services (10:00 AM)

---

## Development Timeline

### Overview

**Duration:** 11 weeks (77 days)  
**Start:** February 16, 2026  
**Demo:** May 3, 2026

### Week-by-Week Summary

| Week | Focus | Deliverables |
|------|-------|--------------|
| 1-2 | Foundation & Backend Core | Auth, DB schema, Basic UI |
| 3 | Platform Admin & Supplier Portal | Agency onboarding, Supplier registration |
| 4 | Supplier Services & PO | Service management, PO workflow |
| 5 | Package & Booking | Package creation, Booking management |
| 6 | Document & Task | Document tracking, Task Kanban |
| 7 | Notification & Payment | Pre-departure notifications, Payment tracking |
| 8 | Itinerary & Bills | Itinerary builder, Supplier bills |
| 9 | B2B Marketplace & Profitability | Agency reseller, Profitability tracking |
| 10 | Testing & Bug Fixes | E2E testing, Bug fixes |
| 11 | Demo Preparation | Demo rehearsal, Final polish |

For detailed week-by-week breakdown, see [TIMELINE.md](./TIMELINE.md).

---

## Success Criteria

### Must Have (Demo Blockers)

- ✅ Platform admin can onboard agencies
- ✅ Suppliers can create services (8 types)
- ✅ Seasonal pricing working
- ✅ Purchase Order workflow complete
- ✅ Agency can create packages & journeys
- ✅ Staff can create bookings manually
- ✅ Customer management working
- ✅ Document checklist auto-generated
- ✅ Task checklist auto-generated
- ✅ Pre-departure notifications working (H-7, H-1 minimum)
- ✅ Payment tracking working
- ✅ Itinerary builder working
- ✅ B2B marketplace working (Agency A ↔ Agency B)
- ✅ Supplier name HIDDEN in marketplace
- ✅ Quota management working
- ✅ Profitability tracking working
- ✅ All dashboards showing correct data
- ✅ System stable (no critical bugs)

### Nice to Have (Can be Phase 2)

- 💎 All notification schedules (H-30, H-14, H-3)
- 💎 Email sending (can use in-app only)
- 💎 PDF exports (can show preview)
- 💎 Communication log
- 💎 Advanced profitability reports

### Explicitly Excluded (Phase 2-4)

- ❌ Traveler self-service portal (Phase 4)
- ❌ Payment gateway integration (Phase 2)
- ❌ Document file upload (Phase 2)
- ❌ Real email sending (Phase 2)
- ❌ Invoice/receipt PDF (Phase 2)

---

## References

### Detailed Documentation

1. **[EXECUTIVE-SUMMARY.md](./EXECUTIVE-SUMMARY.md)**
   - Business overview (non-technical)
   - For stakeholders, management

2. **[DEVELOPER-DOCUMENTATION.md](./DEVELOPER-DOCUMENTATION.md)**
   - Complete technical specifications
   - Database schema (all 24+ tables)
   - API endpoints (all 80+ endpoints)
   - Business rules
   - Frontend components (150+)
   - Background jobs (6 jobs)
   - Development setup
   - Testing strategy
   - Deployment guide

3. **[TIMELINE.md](./TIMELINE.md)**
   - Week-by-week development plan
   - Resource allocation
   - Tasks & deliverables
   - Milestones & checkpoints
   - Risks & mitigation

4. **[README.md](./README.md)**
   - Documentation hub
   - Quick start guide
   - Navigation

### Phase 1 Specifications

- `phase-1/PHASE-1-MVP-CHECKLIST.md`
- `phase-1/PHASE-1-FEATURES-RECAP.md`
- `phase-1/PHASE-1-REVISED-SCOPE-BREAKDOWN.md`
- `phase-1/be-specs/requirements.md` (40 requirements)
- `phase-1/be-specs/design.md` (25+ tables, 100+ endpoints)
- `phase-1/fe-specs/requirements.md` (30 requirements)
- `phase-1/fe-specs/design.md` (150+ components)

---

## Appendix

### Glossary

- **Agency:** Travel agency tenant
- **Supplier:** Service provider (hotel, flight, etc.)
- **Package:** Reusable travel package template (NO dates)
- **Journey:** Actual trip instance with specific dates
- **PO:** Purchase Order from agency to supplier
- **RLS:** Row-Level Security for multi-tenancy
- **CQRS:** Command Query Responsibility Segregation
- **Mahram:** Male guardian for female Muslim travelers
- **H-30, H-7, H-1:** Days before departure (e.g., H-7 = 7 days before)

### Acronyms

- **ERP:** Enterprise Resource Planning
- **SaaS:** Software as a Service
- **CRM:** Customer Relationship Management
- **B2B:** Business-to-Business
- **B2C:** Business-to-Consumer
- **JWT:** JSON Web Token
- **API:** Application Programming Interface
- **UI:** User Interface
- **UX:** User Experience

---

**END OF MAIN DOCUMENTATION**

**Version:** 3.0  
**Status:** ✅ Complete  
**Last Updated:** February 14, 2026  
**Demo Date:** May 3, 2026 🎯

