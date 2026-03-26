# Master Implementation Guide: Complete Tour & Travel System

**Version**: 1.0  
**Date**: March 26, 2026  
**Target**: AI Agents (Sonnet 4.6 → Gemini Flash)  
**Scope**: Supplier Service → Customer Booking (Complete Flow)

---

## 📚 DOCUMENTATION STRUCTURE

This guide is split into modular files for easier navigation:

### 📁 implementation-guide/
```
├── README.md                              ← Start here
├── 00-SYSTEM-FLOW-DIAGRAMS.md            ← Visual flows
├── 01-SUPPLIER-SERVICE-MANAGEMENT.md     ← Phase 1 (Backend + Frontend)
├── 02-SERVICE-AVAILABILITY-SYSTEM.md     ← Phase 2 (Backend + Frontend)
├── 03-AGENCY-PROCUREMENT-CART-PO.md      ← Phase 3 (Backend + Frontend)
├── 04-JOURNEY-REFACTORING.md             ← Phase 4 (Backend + Frontend)
├── 05-JOURNEY-ACTIVITY-MANAGEMENT.md     ← Phase 5 (Backend + Frontend)
├── 06-DYNAMIC-SERVICE-SELECTION.md       ← Phase 6 (Backend + Frontend)
├── 07-JOURNEY-PUBLISHING.md              ← Phase 7 (Backend + Frontend)
├── 08-BOOKING-SYSTEM.md                  ← Phase 8 (Backend + Frontend)
└── 09-TESTING-GUIDE.md                   ← Integration & E2E tests
```

---

## 🎯 QUICK START GUIDE

### For Sonnet 4.6 (Task Creator)

**Your Role**: Read this guide and create detailed task breakdowns for Gemini Flash

**Process**:
1. Read phase file (e.g., `01-SUPPLIER-SERVICE-MANAGEMENT.md`)
2. Break down into atomic tasks
3. Each task should have:
   - Clear objective
   - Exact file path
   - Exact code to write
   - Verification step
4. Create tasks in sequence (Backend → Frontend → Testing)

**Example Task Breakdown**:
```
Task 1.1.1: Create SupplierService Entity
- File: TourTravel.Domain/Entities/SupplierService.cs
- Action: CREATE
- Code: [exact code from guide]
- Verify: File exists and compiles

Task 1.1.2: Create EF Configuration
- File: TourTravel.Infrastructure/Data/Configurations/SupplierServiceConfiguration.cs
- Action: CREATE
- Code: [exact code from guide]
- Verify: File exists and compiles
```

### For Gemini Flash (Task Executor)

**Your Role**: Execute tasks exactly as specified

**Process**:
1. Read task description
2. Navigate to file path
3. Perform action (CREATE/MODIFY/DELETE)
4. Write exact code provided
5. Run verification command
6. Report success/failure

**Rules**:
- ❌ Do NOT modify code unless explicitly told
- ❌ Do NOT skip verification steps
- ❌ Do NOT proceed if previous task failed
- ✅ Follow instructions exactly
- ✅ Report any errors immediately

---

## 📊 IMPLEMENTATION OVERVIEW

### Phase Summary

| Phase | Name | Backend Tasks | Frontend Tasks | Duration |
|-------|------|---------------|----------------|----------|
| 1 | Supplier Service Management | 15 | 12 | 5-7 days |
| 2 | Service Availability System | 8 | 6 | 3-4 days |
| 3 | Agency Procurement | 20 | 15 | 7-10 days |
| 4 | Journey Refactoring | 12 | 8 | 5-7 days |
| 5 | Journey Activity Management | 18 | 14 | 7-10 days |
| 6 | Dynamic Service Selection | 10 | 20 | 10-14 days |
| 7 | Journey Publishing | 6 | 8 | 3-5 days |
| 8 | Booking System | 15 | 12 | 7-10 days |
| **TOTAL** | | **104** | **95** | **47-67 days** |

### Technology Stack

**Backend**:
- ASP.NET Core 8.0
- PostgreSQL 15+ (JSONB support)
- Entity Framework Core 8.0
- MediatR (CQRS)
- FluentValidation
- MinIO (object storage)
- Hangfire (background jobs)

**Frontend**:
- Angular 17+
- TypeScript 5+
- RxJS 7+
- Angular Material / PrimeNG
- TailwindCSS
- Chart.js (for dashboards)

---

## 🔄 COMPLETE SYSTEM FLOW

### 1. Supplier Creates Service

```
Supplier Portal
    ↓
Create Service Form
    ├─ Service Type (8 options)
    ├─ Basic Info (name, price, location)
    ├─ Service Details (JSON - no validation)
    └─ Payment Terms (optional)
    ↓
Save as Draft
    ↓
Upload Images (max 5)
    ↓
Set Availability (date ranges)
    ↓
Publish Service
    ↓
Visible in Marketplace
```

### 2. Agency Procures Services

```
Agency Portal
    ↓
Browse Marketplace
    ├─ Filter by type, location, price
    └─ View service details
    ↓
Add to Cart
    ├─ Select quantity
    └─ Review cart
    ↓
Create Purchase Order
    ↓
Supplier Approves PO
    ↓
Services → Agency Inventory
```

### 3. Agency Creates Journey

```
Agency Portal
    ↓
Create Journey
    ├─ Basic Info (name, dates, quota, type)
    ├─ Build Itinerary:
    │   ├─ Add Activity 1 (Flight)
    │   │   └─ Select service → Auto-fill times
    │   ├─ Add Activity 2 (Hotel)
    │   │   ├─ Fill check-in/out dates FIRST
    │   │   └─ Select service (filtered by dates)
    │   ├─ Add Activity 3 (Transport)
    │   │   ├─ Fill check-in/out dates FIRST
    │   │   └─ Select service
    │   └─ Add Activity N...
    ├─ Review Pricing:
    │   ├─ Base Cost (auto-calculated)
    │   ├─ Markup (percentage or fixed)
    │   └─ Selling Price (auto-calculated)
    └─ Save as Draft
    ↓
Publish Journey
    ├─ Validation:
    │   ├─ Has activities
    │   ├─ All services selected
    │   └─ All services available
    └─ Status: draft → published
    ↓
Visible to Customers
```

### 4. Customer Books Journey

```
Customer Portal
    ↓
Browse Published Journeys
    ↓
View Journey Details
    ├─ Itinerary
    ├─ Pricing
    └─ Availability
    ↓
Create Booking
    ├─ Select PAX count
    ├─ Fill traveler details
    └─ Choose payment plan
    ↓
Complete Payment
    ↓
Booking Confirmed
```

---

## 🎨 KEY FEATURES EXPLAINED

### Dynamic Service Selection (The Core Innovation)

This is the most complex feature. Services are selected differently based on activity type:

#### GROUP A: Hotel, Transport, Guide, Catering
**Behavior**: Date range required BEFORE service selection

**Flow**:
1. User fills activity form
2. User fills check-in date
3. User fills check-out date
4. "Select Services" button becomes ENABLED
5. User clicks button
6. Modal opens with API call:
   ```
   GET /api/journeys/available-services
   ?type=hotel
   &check_in_date=2026-03-15
   &check_out_date=2026-03-20
   ```
7. Backend filters services by:
   - Type = hotel
   - Has availability for ALL dates in range
   - is_available = true for ALL dates
8. Shows services with total price for date range
9. User selects service
10. Modal closes
11. Activity form shows selected service

**Why**: Hotels need date ranges to check availability and calculate total cost.

#### GROUP B: Flight
**Behavior**: Auto-fill departure/arrival times AFTER selection

**Flow**:
1. User fills activity form
2. "Select Services" button is ENABLED immediately
3. User clicks button
4. Modal opens with API call:
   ```
   GET /api/journeys/available-services
   ?type=flight
   &date=2026-03-15
   ```
5. Shows flight services
6. User selects service
7. Modal closes
8. Activity form AUTO-FILLS (read-only):
   - Estimated Time Departure (from service_details JSON)
   - Estimated Time Arrival (from service_details JSON)

**Why**: Flights have fixed schedules that should be displayed, not edited.

#### GROUP C: Visa, Insurance, Handling
**Behavior**: Simple selection, no extra fields

**Flow**:
1. User fills activity form
2. "Select Services" button is ENABLED immediately
3. User clicks button
4. Modal opens with API call:
   ```
   GET /api/journeys/available-services
   ?type=visa
   &date=2026-03-15
   ```
5. Shows services
6. User selects service
7. Modal closes
8. Activity form shows selected service

**Why**: These services don't need date ranges or time details.

---

## 📋 IMPLEMENTATION CHECKLIST

Use this to track overall progress:

### Phase 1: Supplier Service Management
- [ ] Backend: Entities (SupplierService, SupplierServiceImage)
- [ ] Backend: EF Configurations
- [ ] Backend: Migration
- [ ] Backend: Commands (Create, Update, Delete, Publish)
- [ ] Backend: Queries (GetById, GetList)
- [ ] Backend: DTOs
- [ ] Backend: Validators
- [ ] Backend: Controllers
- [ ] Backend: MinIO Service (image upload)
- [ ] Frontend: Service Module
- [ ] Frontend: Service Form Component
- [ ] Frontend: Service List Component
- [ ] Frontend: Service Detail Component
- [ ] Frontend: Image Upload Component
- [ ] Frontend: JSON Editor Component
- [ ] Testing: Unit tests
- [ ] Testing: Integration tests
- [ ] Testing: E2E tests

### Phase 2: Service Availability System
- [ ] Backend: ServiceAvailability Entity
- [ ] Backend: EF Configuration
- [ ] Backend: Migration
- [ ] Backend: Bulk Create Command
- [ ] Backend: Update Command
- [ ] Backend: Query Handler
- [ ] Backend: Controller endpoints
- [ ] Frontend: Availability Calendar Component
- [ ] Frontend: Bulk Create Form
- [ ] Frontend: Date Range Picker
- [ ] Testing: Bulk creation
- [ ] Testing: Date filtering

### Phase 3: Agency Procurement
- [ ] Backend: Cart & CartItem Entities
- [ ] Backend: PurchaseOrder & POItem Entities
- [ ] Backend: AgencyService Entity
- [ ] Backend: EF Configurations
- [ ] Backend: Migrations
- [ ] Backend: Cart Commands (Add, Update, Remove, Clear)
- [ ] Backend: PO Commands (Create, Approve, Reject)
- [ ] Backend: Marketplace Query (with filters)
- [ ] Backend: Controllers
- [ ] Frontend: Marketplace Component
- [ ] Frontend: Service Card Component
- [ ] Frontend: Cart Component
- [ ] Frontend: PO List Component
- [ ] Frontend: PO Detail Component
- [ ] Testing: Complete procurement flow

### Phase 4: Journey Refactoring
- [ ] Database: Backup existing data
- [ ] Database: Clean old data (TRUNCATE)
- [ ] Database: Drop old tables (packages, itineraries)
- [ ] Database: Modify Journey table (ADD columns)
- [ ] Database: Create journey_activities table
- [ ] Backend: Update Journey Entity
- [ ] Backend: Create JourneyActivity Entity
- [ ] Backend: Update EF Configurations
- [ ] Backend: Migration
- [ ] Backend: Update DbContext
- [ ] Testing: Database structure verification

### Phase 5: Journey Activity Management
- [ ] Backend: AddJourneyActivityCommand
- [ ] Backend: UpdateJourneyActivityCommand
- [ ] Backend: DeleteJourneyActivityCommand
- [ ] Backend: ReorderActivitiesCommand
- [ ] Backend: Auto-calculation logic (costs, duration)
- [ ] Backend: Validators
- [ ] Backend: Controllers
- [ ] Frontend: Journey Form Component (redesigned)
- [ ] Frontend: Activity Form Component
- [ ] Frontend: Activity List Component
- [ ] Frontend: Drag-and-drop reordering
- [ ] Frontend: Auto-calculation display
- [ ] Testing: CRUD operations
- [ ] Testing: Auto-calculations

### Phase 6: Dynamic Service Selection
- [ ] Backend: GetAvailableServicesQuery
- [ ] Backend: Type-based filtering logic
- [ ] Backend: Date-based filtering logic
- [ ] Backend: Price calculation logic
- [ ] Backend: Controller endpoint
- [ ] Frontend: Service Selection Modal Component
- [ ] Frontend: Group A behavior (date range required)
- [ ] Frontend: Group B behavior (auto-fill times)
- [ ] Frontend: Group C behavior (simple)
- [ ] Frontend: Conditional field display
- [ ] Frontend: Button enable/disable logic
- [ ] Frontend: Service card display
- [ ] Frontend: Search and pagination
- [ ] Testing: All 3 groups
- [ ] Testing: Date filtering
- [ ] Testing: Auto-fill functionality

### Phase 7: Journey Publishing
- [ ] Backend: PublishJourneyCommand
- [ ] Backend: Validation logic (has activities, services selected, available)
- [ ] Backend: Status management
- [ ] Backend: Controller endpoint
- [ ] Frontend: Publish button
- [ ] Frontend: Validation display
- [ ] Frontend: Confirmation dialog
- [ ] Testing: Publish workflow
- [ ] Testing: Validation scenarios

### Phase 8: Booking System
- [ ] Backend: Booking Entity
- [ ] Backend: BookingTraveler Entity
- [ ] Backend: EF Configurations
- [ ] Backend: Migration
- [ ] Backend: CreateBookingCommand
- [ ] Backend: Quota management logic
- [ ] Backend: Payment integration (Xendit)
- [ ] Backend: Controllers
- [ ] Frontend: Journey Browse Component
- [ ] Frontend: Journey Detail Component
- [ ] Frontend: Booking Form Component
- [ ] Frontend: Traveler Details Form
- [ ] Frontend: Payment Component
- [ ] Testing: Complete booking flow
- [ ] Testing: Quota management
- [ ] Testing: Payment integration

---

## 🚀 GETTING STARTED

### Step 1: Read System Flow Diagrams
Open: `implementation-guide/00-SYSTEM-FLOW-DIAGRAMS.md`

This gives you visual understanding of the complete system.

### Step 2: Start with Phase 1
Open: `implementation-guide/01-SUPPLIER-SERVICE-MANAGEMENT.md`

Follow every step in sequence:
1. Backend tasks (entities, configurations, commands, queries, controllers)
2. Frontend tasks (components, services, forms)
3. Testing tasks (unit, integration, E2E)

### Step 3: Verify Before Moving On
After completing Phase 1, verify:
- ✅ All backend files created and compile
- ✅ Migration applied successfully
- ✅ API endpoints work (test with Postman)
- ✅ Frontend components render
- ✅ Can create/read/update/delete services
- ✅ Images upload successfully

### Step 4: Repeat for Each Phase
Complete phases 2-8 in order, verifying each before proceeding.

---

## 📞 SUPPORT & TROUBLESHOOTING

### Common Issues

**Issue**: Migration fails with "column already exists"
**Solution**: Drop the column manually or use `dotnet ef migrations remove` and recreate

**Issue**: Frontend can't connect to backend
**Solution**: Check CORS settings in `Program.cs`, ensure API is running on correct port

**Issue**: Images not uploading
**Solution**: Verify MinIO is running, check connection string, verify bucket exists

**Issue**: Service selection modal shows no results
**Solution**: Check availability records exist, verify date filtering logic, check API response

### Getting Help

1. Check the specific phase documentation
2. Look for "Troubleshooting" section in each phase file
3. Verify all prerequisites are met
4. Check previous phases are completed correctly

---

## 📈 PROGRESS TRACKING

**Current Phase**: _____  
**Completion**: ____%  
**Blockers**: _____  
**Next Steps**: _____  

---

**Document Version**: 1.0  
**Last Updated**: March 26, 2026  
**Maintained By**: Development Team

