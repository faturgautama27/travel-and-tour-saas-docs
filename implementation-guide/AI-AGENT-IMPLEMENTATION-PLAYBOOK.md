# AI Agent Implementation Playbook

**Target**: Sonnet 4.6 (Task Creator) → Gemini Flash (Task Executor)  
**Version**: 1.0  
**Date**: March 26, 2026  
**Purpose**: Complete step-by-step guide from Supplier Service to Booking

---

## 🎯 HOW TO USE THIS PLAYBOOK

### For Sonnet 4.6 (You are the Task Creator)

**Your Mission**: Break down each phase into atomic, executable tasks for Gemini Flash.

**Task Format**:
```
Task ID: P1-B-001
Phase: 1 (Supplier Service Management)
Layer: Backend
Action: CREATE
File: TourTravel.Domain/Entities/SupplierService.cs
Description: Create SupplierService entity with all properties
Code: [exact code from playbook]
Verification: File exists, compiles without errors
Dependencies: None
```

**Rules for Task Creation**:
1. Each task = 1 file operation (CREATE/MODIFY/DELETE)
2. Include exact file path
3. Include exact code to write
4. Include verification step
5. List dependencies (which tasks must complete first)
6. Backend tasks before Frontend tasks
7. Number tasks sequentially within each phase

### For Gemini Flash (You are the Task Executor)

**Your Mission**: Execute tasks exactly as specified, no thinking required.

**Execution Steps**:
1. Read task ID and description
2. Check dependencies are completed
3. Navigate to file path
4. Perform action (CREATE/MODIFY/DELETE)
5. Write exact code provided
6. Run verification command
7. Report: SUCCESS or FAILURE with error message
8. If SUCCESS → Move to next task
9. If FAILURE → STOP and report to Sonnet 4.6

**Rules for Execution**:
- ❌ NEVER modify code unless explicitly instructed
- ❌ NEVER skip verification
- ❌ NEVER proceed if previous task failed
- ✅ Follow instructions exactly
- ✅ Report errors immediately with full details

---

## 📊 IMPLEMENTATION ROADMAP

### Phase Overview

| Phase | Name | Backend Files | Frontend Files | Est. Days |
|-------|------|---------------|----------------|-----------|
| 1 | Supplier Service | 21 | 12 | 5-7 |
| 2 | Service Availability | 10 | 6 | 3-4 |
| 3 | Agency Procurement | 31 | 15 | 7-10 |
| 4 | Journey Refactoring | 12 | 8 | 5-7 |
| 5 | Journey Activity | 18 | 14 | 7-10 |
| 6 | Dynamic Service Selection | 10 | 20 | 10-14 |
| 7 | Journey Publishing | 6 | 8 | 3-5 |
| 8 | Booking System | 15 | 12 | 7-10 |
| **TOTAL** | | **123** | **95** | **47-67** |

---

## 🔄 COMPLETE SYSTEM FLOW (Visual Reference)

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPLETE SYSTEM FLOW                          │
└─────────────────────────────────────────────────────────────────┘

SUPPLIER CREATES SERVICE
    ↓
[Phase 1] Create Service (hotel, flight, visa, etc.)
    ├─ Service Type: 8 options
    ├─ Dynamic JSON details (no validation)
    ├─ Base price & location
    └─ Payment terms (optional)
    ↓
[Phase 1] Upload Images (max 5)
    └─ Store in MinIO
    ↓
[Phase 2] Set Availability (per-date)
    ├─ Date range
    ├─ Price override (optional)
    └─ Available: true/false
    ↓
[Phase 1] Publish Service
    └─ Status: draft → published
    ↓
VISIBLE IN MARKETPLACE

═══════════════════════════════════════════════════════════════════

AGENCY PROCURES SERVICES
    ↓
[Phase 3] Browse Marketplace
    ├─ Filter by type, location, price, dates
    └─ View service details
    ↓
[Phase 3] Add to Cart
    └─ Select quantity
    ↓
[Phase 3] Create Purchase Order
    ↓
[Phase 3] Supplier Approves PO
    ↓
SERVICES → AGENCY INVENTORY

═══════════════════════════════════════════════════════════════════

AGENCY CREATES JOURNEY
    ↓
[Phase 4-5] Create Journey + Build Itinerary
    ├─ Basic Info (name, dates, quota, type)
    └─ Add Activities:
        │
        ├─ Activity 1: Flight
        │   ├─ Date: [Calendar]
        │   ├─ Type: flight
        │   ├─ [Select Services] ◄─ GROUP B
        │   └─ AUTO-FILL: departure/arrival times
        │
        ├─ Activity 2: Hotel
        │   ├─ Date: [Calendar]
        │   ├─ Type: hotel
        │   ├─ Check-in Date: [Calendar] ◄─ REQUIRED FIRST
        │   ├─ Check-out Date: [Calendar] ◄─ REQUIRED FIRST
        │   └─ [Select Services] ◄─ GROUP A (filtered by dates)
        │
        ├─ Activity 3: Transport
        │   ├─ Date: [Calendar]
        │   ├─ Type: transport
        │   ├─ Check-in Date: [Calendar] ◄─ REQUIRED FIRST
        │   ├─ Check-out Date: [Calendar] ◄─ REQUIRED FIRST
        │   └─ [Select Services] ◄─ GROUP A (filtered by dates)
        │
        └─ Activity N: Visa
            ├─ Date: [Calendar]
            ├─ Type: visa
            └─ [Select Services] ◄─ GROUP C (simple)
    ↓
[Phase 5] Review Pricing
    ├─ Base Cost (auto-calculated from activities)
    ├─ Markup (percentage or fixed)
    └─ Selling Price (auto-calculated)
    ↓
[Phase 7] Publish Journey
    ├─ Validation:
    │   ├─ Has activities
    │   ├─ All services selected
    │   └─ All services available
    └─ Status: draft → published
    ↓
VISIBLE TO CUSTOMERS

═══════════════════════════════════════════════════════════════════

CUSTOMER BOOKS JOURNEY
    ↓
[Phase 8] Browse Published Journeys
    ↓
[Phase 8] View Journey Details
    ├─ Itinerary
    ├─ Pricing
    └─ Availability
    ↓
[Phase 8] Create Booking
    ├─ Select PAX count
    ├─ Fill traveler details
    └─ Choose payment plan
    ↓
[Phase 8] Complete Payment
    ↓
BOOKING CONFIRMED
```

---

## 🎨 DYNAMIC SERVICE SELECTION (Core Feature)

This is THE most important feature. Services are selected differently based on activity type.

### GROUP A: Hotel, Transport, Guide, Catering

**Rule**: User MUST fill check-in/out dates BEFORE selecting services.

**Behavior**:
1. Activity form shows: Date, Type, Description
2. When Type = "hotel" | "transport" | "guide" | "catering":
   - Show: Check-in Date field
   - Show: Check-out Date field
   - "Select Services" button = DISABLED
3. User fills check-in date
4. User fills check-out date
5. "Select Services" button = ENABLED
6. User clicks button
7. Modal opens
8. API call:
   ```
   GET /api/journeys/available-services
   ?type=hotel
   &check_in_date=2026-03-15
   &check_out_date=2026-03-20
   ```
9. Backend filters:
   - SupplierServices WHERE type=hotel AND status=published
   - JOIN ServiceAvailability
   - WHERE date BETWEEN check_in AND check_out
   - AND is_available = true FOR ALL dates
   - Calculate total price = SUM(price per night)
10. Show results in modal
11. User selects service
12. Modal closes
13. Activity form shows selected service info

**Why**: Hotels need date ranges to check room availability and calculate total cost.

---

### GROUP B: Flight

**Rule**: Auto-fill departure/arrival times AFTER service selection.

**Behavior**:
1. Activity form shows: Date, Type, Description
2. When Type = "flight":
   - NO extra fields shown
   - "Select Services" button = ENABLED immediately
3. User clicks button
4. Modal opens
5. API call:
   ```
   GET /api/journeys/available-services
   ?type=flight
   &date=2026-03-15
   ```
6. Backend filters:
   - SupplierServices WHERE type=flight AND status=published
7. Show results in modal
8. User selects service
9. Modal closes
10. Activity form AUTO-FILLS (read-only):
    - Estimated Time Departure (from service_details.estimated_time_departure)
    - Estimated Time Arrival (from service_details.estimated_time_arrival)
11. These fields appear BELOW the "Select Services" button
12. User CANNOT edit these fields

**Why**: Flights have fixed schedules that should be displayed, not edited by user.

---

### GROUP C: Visa, Insurance, Handling

**Rule**: Simple selection, no extra fields.

**Behavior**:
1. Activity form shows: Date, Type, Description
2. When Type = "visa" | "insurance" | "handling":
   - NO extra fields shown
   - "Select Services" button = ENABLED immediately
3. User clicks button
4. Modal opens
5. API call:
   ```
   GET /api/journeys/available-services
   ?type=visa
   &date=2026-03-15
   ```
6. Backend filters:
   - SupplierServices WHERE type=visa AND status=published
7. Show results in modal
8. User selects service
9. Modal closes
10. Activity form shows selected service info

**Why**: These services don't need date ranges or time details.

---

## 📋 DETAILED TASK BREAKDOWN

### PHASE 1: SUPPLIER SERVICE MANAGEMENT

#### Backend Tasks (21 files)

**Task P1-B-001**: Create SupplierService Entity
- File: `TourTravel.Domain/Entities/SupplierService.cs`
- Action: CREATE
- Dependencies: None

**Task P1-B-002**: Create SupplierServiceImage Entity
- File: `TourTravel.Domain/Entities/SupplierServiceImage.cs`
- Action: CREATE
- Dependencies: P1-B-001

**Task P1-B-003**: Create SupplierService EF Configuration
- File: `TourTravel.Infrastructure/Data/Configurations/SupplierServiceConfiguration.cs`
- Action: CREATE
- Dependencies: P1-B-001

**Task P1-B-004**: Create SupplierServiceImage EF Configuration
- File: `TourTravel.Infrastructure/Data/Configurations/SupplierServiceImageConfiguration.cs`
- Action: CREATE
- Dependencies: P1-B-002

**Task P1-B-005**: Register Configurations in DbContext
- File: `TourTravel.Infrastructure/Data/ApplicationDbContext.cs`
- Action: MODIFY
- Dependencies: P1-B-003, P1-B-004

**Task P1-B-006**: Create Migration
- Command: `dotnet ef migrations add AddSupplierServiceEntities`
- Dependencies: P1-B-005

**Task P1-B-007**: Apply Migration
- Command: `dotnet ef database update`
- Dependencies: P1-B-006

**Task P1-B-008**: Create CreateSupplierServiceCommand
- File: `TourTravel.Application/Commands/SupplierService/CreateSupplierServiceCommand.cs`
- Action: CREATE
- Dependencies: P1-B-001

**Task P1-B-009**: Create CreateSupplierServiceCommandHandler
- File: `TourTravel.Application/Commands/SupplierService/CreateSupplierServiceCommandHandler.cs`
- Action: CREATE
- Dependencies: P1-B-008

**Task P1-B-010**: Create CreateSupplierServiceCommandValidator
- File: `TourTravel.Application/Commands/SupplierService/CreateSupplierServiceCommandValidator.cs`
- Action: CREATE
- Dependencies: P1-B-008

**Task P1-B-011**: Create UpdateSupplierServiceCommand
- File: `TourTravel.Application/Commands/SupplierService/UpdateSupplierServiceCommand.cs`
- Action: CREATE
- Dependencies: P1-B-001

**Task P1-B-012**: Create UpdateSupplierServiceCommandHandler
- File: `TourTravel.Application/Commands/SupplierService/UpdateSupplierServiceCommandHandler.cs`
- Action: CREATE
- Dependencies: P1-B-011

**Task P1-B-013**: Create PublishSupplierServiceCommand
- File: `TourTravel.Application/Commands/SupplierService/PublishSupplierServiceCommand.cs`
- Action: CREATE
- Dependencies: P1-B-001

**Task P1-B-014**: Create PublishSupplierServiceCommandHandler
- File: `TourTravel.Application/Commands/SupplierService/PublishSupplierServiceCommandHandler.cs`
- Action: CREATE
- Dependencies: P1-B-013

**Task P1-B-015**: Create UploadSupplierServiceImageCommand
- File: `TourTravel.Application/Commands/SupplierService/UploadSupplierServiceImageCommand.cs`
- Action: CREATE
- Dependencies: P1-B-002

**Task P1-B-016**: Create UploadSupplierServiceImageCommandHandler
- File: `TourTravel.Application/Commands/SupplierService/UploadSupplierServiceImageCommandHandler.cs`
- Action: CREATE
- Dependencies: P1-B-015

**Task P1-B-017**: Create GetSupplierServiceQuery
- File: `TourTravel.Application/Queries/SupplierService/GetSupplierServiceQuery.cs`
- Action: CREATE
- Dependencies: P1-B-001

**Task P1-B-018**: Create GetSupplierServiceQueryHandler
- File: `TourTravel.Application/Queries/SupplierService/GetSupplierServiceQueryHandler.cs`
- Action: CREATE
- Dependencies: P1-B-017

**Task P1-B-019**: Create SupplierServiceDto
- File: `TourTravel.Application/DTOs/SupplierServiceDto.cs`
- Action: CREATE
- Dependencies: P1-B-001

**Task P1-B-020**: Create MinIOService
- File: `TourTravel.Infrastructure/Services/MinIOService.cs`
- Action: CREATE
- Dependencies: None

**Task P1-B-021**: Create SupplierServicesController
- File: `TourTravel.API/Controllers/SupplierServicesController.cs`
- Action: CREATE
- Dependencies: P1-B-009, P1-B-012, P1-B-014, P1-B-016, P1-B-018

---

#### Frontend Tasks (12 files)

**Task P1-F-001**: Create Supplier Service Module
- File: `src/app/features/supplier/services/supplier-service.module.ts`
- Action: CREATE
- Dependencies: All P1-B tasks completed

**Task P1-F-002**: Create Service Form Component TS
- File: `src/app/features/supplier/services/components/service-form/service-form.component.ts`
- Action: CREATE
- Dependencies: P1-F-001

**Task P1-F-003**: Create Service Form Component HTML
- File: `src/app/features/supplier/services/components/service-form/service-form.component.html`
- Action: CREATE
- Dependencies: P1-F-002

**Task P1-F-004**: Create Service List Component TS
- File: `src/app/features/supplier/services/components/service-list/service-list.component.ts`
- Action: CREATE
- Dependencies: P1-F-001

**Task P1-F-005**: Create Service List Component HTML
- File: `src/app/features/supplier/services/components/service-list/service-list.component.html`
- Action: CREATE
- Dependencies: P1-F-004

**Task P1-F-006**: Create Service Detail Component TS
- File: `src/app/features/supplier/services/components/service-detail/service-detail.component.ts`
- Action: CREATE
- Dependencies: P1-F-001

**Task P1-F-007**: Create Service Detail Component HTML
- File: `src/app/features/supplier/services/components/service-detail/service-detail.component.html`
- Action: CREATE
- Dependencies: P1-F-006

**Task P1-F-008**: Create Image Upload Component TS
- File: `src/app/features/supplier/services/components/image-upload/image-upload.component.ts`
- Action: CREATE
- Dependencies: P1-F-001

**Task P1-F-009**: Create Image Upload Component HTML
- File: `src/app/features/supplier/services/components/image-upload/image-upload.component.html`
- Action: CREATE
- Dependencies: P1-F-008

**Task P1-F-010**: Create JSON Editor Component TS
- File: `src/app/features/supplier/services/components/json-editor/json-editor.component.ts`
- Action: CREATE
- Dependencies: P1-F-001

**Task P1-F-011**: Create JSON Editor Component HTML
- File: `src/app/features/supplier/services/components/json-editor/json-editor.component.html`
- Action: CREATE
- Dependencies: P1-F-010

**Task P1-F-012**: Create Supplier Service API Service
- File: `src/app/features/supplier/services/services/supplier-service-api.service.ts`
- Action: CREATE
- Dependencies: P1-F-001

---

## 📁 COMPLETE FILE REFERENCE

### All Files to Create (218 total)

This playbook references detailed implementation in:
- `COMPLETE-PHASES-GUIDE.md` - Phases 1-3 details
- `JOURNEY-SYSTEM-PHASES-4-8.md` - Phases 4-8 details
- `implementation-guide/00-SYSTEM-FLOW-DIAGRAMS.md` - Visual flows

---

## ✅ VERIFICATION CHECKLIST

After each phase, verify:

### Phase 1 Verification
- [ ] All 21 backend files created
- [ ] All 12 frontend files created
- [ ] Migration applied successfully
- [ ] Can create service via API
- [ ] Can upload images
- [ ] Can publish service
- [ ] Service visible in database

### Phase 2 Verification
- [ ] All 10 backend files created
- [ ] All 6 frontend files created
- [ ] Can create availability records
- [ ] Can query availability by date range
- [ ] Calendar displays correctly

### Phase 3 Verification
- [ ] All 31 backend files created
- [ ] All 15 frontend files created
- [ ] Can browse marketplace
- [ ] Can add to cart
- [ ] Can create PO
- [ ] Supplier can approve PO
- [ ] Services appear in inventory

### Phase 4 Verification
- [ ] Old tables dropped
- [ ] Journey table modified
- [ ] journey_activities table created
- [ ] All 12 backend files updated
- [ ] All 8 frontend files updated
- [ ] Old modules removed

### Phase 5 Verification
- [ ] All 18 backend files created
- [ ] All 14 frontend files created
- [ ] Can add activities
- [ ] Can update activities
- [ ] Can delete activities
- [ ] Can reorder activities
- [ ] Auto-calculations work

### Phase 6 Verification
- [ ] All 10 backend files created
- [ ] All 20 frontend files created
- [ ] GROUP A behavior works (date range required)
- [ ] GROUP B behavior works (auto-fill times)
- [ ] GROUP C behavior works (simple)
- [ ] Service filtering by dates works

### Phase 7 Verification
- [ ] All 6 backend files created
- [ ] All 8 frontend files created
- [ ] Can publish journey
- [ ] Validation works
- [ ] Status updates correctly

### Phase 8 Verification
- [ ] All 15 backend files created
- [ ] All 12 frontend files created
- [ ] Can create booking
- [ ] Quota management works
- [ ] Payment integration works

---

## 🚀 EXECUTION COMMAND

**For Sonnet 4.6**: 
```
Read this playbook → Create task list → Send to Gemini Flash
```

**For Gemini Flash**:
```
Receive task → Execute → Verify → Report → Next task
```

---

**END OF PLAYBOOK**

