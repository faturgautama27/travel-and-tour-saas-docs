# Complete Journey to Booking Flow - Analysis & Integration

**Project**: Tour & Travel ERP SaaS  
**Date**: March 18, 2026  
**Status**: ✅ FINALIZED - All Decisions Made, Ready for Implementation

---

## 📋 OVERVIEW

This document analyzes the complete flow from Journey creation to Booking and Task Management, integrating:
1. **Journey Refactor** (NEW design with payment workflow)
2. **Payment & Commission System** (Flexible commission, DP + Pelunasan)
3. **Existing Booking System** (from Phase 1 spec)
4. **Task Management** (auto-generated tasks)

**Key Decisions**:
- ✅ journey_services DEPRECATED - Use journey_activities only
- ✅ DP paid IMMEDIATELY when service selected → Locks availability
- ✅ Commission VERY flexible - Different rates per service type, support percentage/fixed, can charge agency/supplier/both
- ✅ Commission from commission_configs table with priority-based selection
- ✅ Supplier transfer: Hold DP until pelunasan paid, then transfer together

**Related Documents**:
- `PAYMENT-TRACKING-COMPREHENSIVE.md` - Detailed payment tracking (dashboards, queries, notifications)
- `PAYMENT-COMMISSION-SUMMARY.md` - Executive summary with money flow
- `PAYMENT-FLOW-DIAGRAM.md` - Visual diagrams
- `ANSWER-TO-USER-QUESTIONS.md` - Direct answers to user questions (Indonesian)

---

## 🔄 COMPLETE FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: JOURNEY CREATION (NEW DESIGN)                       │
├─────────────────────────────────────────────────────────────┤
│ Agency creates Journey with:                                │
│ • Basic info (name, dates, quota, package type)            │
│ • Activities (with service selection)                       │
│ • Pricing (auto-calculated)                                │
│ Status: DRAFT                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: PAYMENT WORKFLOW (NEW REQUIREMENT)                  │
├─────────────────────────────────────────────────────────────┤
│ Journey Detail Page shows activities with payment status:   │
│ • UNPAID (marketplace) → [Pay Now] [Change Service]        │
│ • PAID (marketplace) → [View Receipt]                       │
│ • RESERVED (inventory) → No action needed                   │
│ • NOT AVAILABLE → [Change Service]                          │
│                                                             │
│ Agency pays for all marketplace services                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 3: PUBLISH JOURNEY                                     │
├─────────────────────────────────────────────────────────────┤
│ Validation:                                                 │
│ ✅ Has at least 1 activity                                  │
│ ✅ All service-based activities have services selected      │
│ ✅ All marketplace services are PAID                        │
│ ✅ All services are AVAILABLE                               │
│                                                             │
│ Status: DRAFT → PUBLISHED                                   │
│ Journey now visible in marketplace for customer booking     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 4: CUSTOMER BOOKING (EXISTING SYSTEM)                  │
├─────────────────────────────────────────────────────────────┤
│ Customer browses published journeys                         │
│ Agency staff creates booking:                               │
│ • Select customer                                           │
│ • Select journey                                            │
│ • Enter total_pax                                           │
│ • Select payment_type (installment/full/flexible)          │
│                                                             │
│ System auto-generates:                                      │
│ • Payment schedules (based on payment_type)                │
│ • Document checklist (per traveler)                        │
│ • Task checklist (after_booking tasks)                     │
│                                                             │
│ Booking Status: PENDING                                     │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 5: BOOKING APPROVAL (EXISTING SYSTEM)                  │
├─────────────────────────────────────────────────────────────┤
│ Agency staff approves booking                               │
│                                                             │
│ System updates:                                             │
│ • Journey: confirmed_pax += total_pax                       │
│ • Journey: available_quota -= total_pax                     │
│ • Booking Status: PENDING → CONFIRMED                       │
│                                                             │
│ System triggers:                                            │
│ • H-30 task generation (30 days before departure)          │
│ • H-7 task generation (7 days before departure)            │
│ • Pre-departure notifications (H-30, H-14, H-7, H-3, H-1)  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 6: OPERATIONS & TASK MANAGEMENT (EXISTING SYSTEM)      │
├─────────────────────────────────────────────────────────────┤
│ Agency staff manages booking tasks:                         │
│ • Document collection (passport, visa, etc.)               │
│ • Document verification                                     │
│ • Task assignment and tracking (Kanban board)              │
│ • Customer payment collection                               │
│ • Pre-departure preparations                                │
│                                                             │
│ Task Types:                                                 │
│ • after_booking: Immediate tasks after booking confirmed   │
│ • h_30: Tasks 30 days before departure                     │
│ • h_7: Tasks 7 days before departure                       │
│                                                             │
│ Task Status: to_do → in_progress → done                    │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ STEP 7: DEPARTURE & COMPLETION (EXISTING SYSTEM)            │
├─────────────────────────────────────────────────────────────┤
│ Booking Status Flow:                                        │
│ confirmed → departed → completed                            │
│                                                             │
│ Agency updates booking status as journey progresses         │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 KEY INSIGHT: TWO SEPARATE PAYMENT SYSTEMS

### Payment System 1: AGENCY → SUPPLIER (Journey Level)
**NEW REQUIREMENT - Journey Refactor**

**Purpose**: Agency pays suppliers for marketplace services BEFORE publishing journey

**Entity**: `payments` table (NEW)
- Links to: `journey_id`, `journey_activity_id`
- Payment for: Marketplace services selected in journey activities
- Timing: BEFORE journey is published
- Status tracked in: `JourneyActivity.payment_status`

**Flow**:
```
Journey created (draft)
    ↓
Select marketplace services in activities
    ↓
Pay for each marketplace service (Pay Now button)
    ↓
All services PAID or RESERVED (inventory)
    ↓
Publish journey
```

---

### Payment System 2: CUSTOMER → AGENCY (Booking Level)
**EXISTING SYSTEM - Phase 1 Spec**

**Purpose**: Customer pays agency for booking the journey

**Entity**: `payment_schedules` + `payment_transactions` tables (EXISTING)
- Links to: `booking_id`
- Payment for: Customer booking the published journey
- Timing: AFTER booking is created
- Payment types: installment (3 payments), full (1 payment), flexible (multiple partial)

**Flow**:
```
Journey published
    ↓
Customer creates booking
    ↓
System auto-generates payment schedules
    ↓
Customer pays according to schedule (DP, Installment 1, Installment 2)
    ↓
Booking confirmed when payment complete
```

---

## 🔍 DETAILED ANALYSIS

### 1. JOURNEY CREATION & PAYMENT (NEW)

**Current Design** (from JOURNEY-REFACTOR-REQUIREMENTS.md):

**JourneyActivity Entity** (NEW):
```csharp
public class JourneyActivity
{
    // ... other fields ...
    
    // Payment Tracking (NEW)
    public string PaymentStatus { get; set; } = "unpaid"; // unpaid, paid, reserved
    public Guid? PaymentId { get; set; }
    public DateTime? PaidAt { get; set; }
    
    // Availability Tracking (NEW)
    public bool IsServiceAvailable { get; set; } = true;
    public DateTime? AvailabilityCheckedAt { get; set; }
}
```

**Payment Entity** (NEW):
```csharp
public class Payment
{
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public Guid JourneyId { get; set; }
    public Guid JourneyActivityId { get; set; }
    
    public string PaymentMethod { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "IDR";
    
    public string PaymentGateway { get; set; } // xendit, midtrans, etc.
    public string? TransactionId { get; set; }
    public string? PaymentUrl { get; set; }
    
    public string Status { get; set; } = "pending"; // pending, processing, success, failed, expired
    public DateTime? PaidAt { get; set; }
    public DateTime? ExpiredAt { get; set; }
    
    public string? ReceiptUrl { get; set; }
    public string? ReceiptNumber { get; set; }
}
```

**Key Points**:
- Payment is at ACTIVITY level (not journey level)
- Each marketplace activity needs separate payment
- Inventory activities don't need payment (status = "reserved")
- Must pay ALL marketplace activities before publishing journey

---

### 2. EXISTING JOURNEY SERVICE TRACKING

**Current Implementation** (from Phase 1 spec):

**JourneyService Entity** (EXISTING):
```csharp
public class JourneyService
{
    public Guid Id { get; set; }
    public Guid JourneyId { get; set; }
    public string ServiceType { get; set; }
    public Guid? SupplierServiceId { get; set; }
    public Guid? AgencyServiceId { get; set; }
    public string SourceType { get; set; }
    
    // Tracking Status (EXISTING)
    public string BookingStatus { get; set; } = "not_booked";
    public string ExecutionStatus { get; set; } = "pending";
    public string PaymentStatus { get; set; } = "unpaid";
    
    public DateTime? BookedAt { get; set; }
    public DateTime? ConfirmedAt { get; set; }
    public DateTime? ExecutedAt { get; set; }
    
    // NEW fields for confirmation workflow
    public int Quantity { get; set; }
    public string ConfirmationStatus { get; set; } = "pending";
    public decimal? EffectivePrice { get; set; }
    public decimal? ConfirmedPrice { get; set; }
}
```

**Purpose**: Track operational status of services in journey
- `booking_status`: not_booked, booked, confirmed, cancelled
- `execution_status`: pending, in_progress, completed, failed
- `payment_status`: unpaid, partially_paid, paid

**Key Points**:
- This is for OPERATIONAL tracking (after journey published)
- Different from JourneyActivity payment (which is for procurement)
- Used by agency staff to monitor service execution

---

### 3. BOOKING CREATION & MANAGEMENT

**Current Implementation** (from Phase 1 spec):

**Booking Entity** (EXISTING):
```csharp
public class Booking
{
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public Guid PackageId { get; set; }
    public Guid JourneyId { get; set; }
    public Guid CustomerId { get; set; }
    public string BookingReference { get; set; }
    public string BookingStatus { get; set; } = "pending";
    public int TotalPax { get; set; }
    public decimal TotalAmount { get; set; }
    public string BookingSource { get; set; } = "staff";
    
    // Relations
    public ICollection<Traveler> Travelers { get; set; }
    public ICollection<BookingDocument> BookingDocuments { get; set; }
    public ICollection<BookingTask> BookingTasks { get; set; }
    public ICollection<PaymentSchedule> PaymentSchedules { get; set; }
}
```

**Booking Flow**:
1. Agency staff creates booking for customer
2. System auto-generates:
   - Payment schedules (based on payment_type)
   - Document checklist (per traveler)
   - Task checklist (after_booking tasks)
3. Booking status = "pending"
4. Agency staff approves booking
5. System updates journey quota
6. Booking status = "confirmed"

**Key Points**:
- Booking is created AFTER journey is published
- Booking references journey (not package anymore after refactor)
- Customer pays agency (not supplier)
- Agency already paid suppliers during journey creation

---

### 4. TASK MANAGEMENT SYSTEM

**Current Implementation** (from Phase 1 spec):

**BookingTask Entity** (EXISTING):
```csharp
public class BookingTask
{
    public Guid Id { get; set; }
    public Guid BookingId { get; set; }
    public Guid? TaskTemplateId { get; set; }
    public string Title { get; set; }
    public string? Description { get; set; }
    public string Status { get; set; } = "to_do";
    public string Priority { get; set; } = "normal";
    public Guid? AssignedTo { get; set; }
    public DateTime? DueDate { get; set; }
    public DateTime? CompletedAt { get; set; }
    public bool IsCustom { get; set; } = false;
}
```

**Task Generation Triggers**:
1. **after_booking**: When booking is confirmed
2. **h_30**: 30 days before departure (background job)
3. **h_7**: 7 days before departure (background job)

**Task Examples**:
- Collect passport copies
- Submit visa applications
- Confirm hotel bookings with supplier
- Prepare travel documents
- Conduct pre-departure briefing
- Arrange airport pickup

**Key Points**:
- Tasks are at BOOKING level (not journey level)
- Auto-generated from templates
- Can create custom tasks manually
- Kanban board view (to_do, in_progress, done)

---

## 🔀 INTEGRATION POINTS & CONFLICTS

### CONFLICT 1: Package vs Journey

**OLD DESIGN** (Phase 1 spec):
```
Package (template) → Journey (instance) → Booking
```

**NEW DESIGN** (Journey refactor):
```
Journey (standalone) → Booking
```

**Resolution Needed**:
- ❓ Booking entity still references `package_id` - Should we remove this? Yes, remove it.
- ❓ Should Booking reference only `journey_id`? Yes, you're right.
- ❓ What happens to existing booking flow that expects package? There is no existing booking yet.

**Recommendation**:
```csharp
// Update Booking entity
public class Booking
{
    // REMOVE: public Guid PackageId { get; set; }
    // KEEP: public Guid JourneyId { get; set; }
    
    // Journey already contains all package info (name, type, pricing)
}
```

---

### CONFLICT 2: JourneyService vs JourneyActivity

**DECISION**: ✅ **DEPRECATE journey_services table - Use ONLY journey_activities**

**Rationale**:
- journey_services was designed for old Package → Journey flow
- With new unified Journey design, journey_activities handles EVERYTHING:
  - Itinerary building
  - Service selection
  - Payment tracking (DP + Pelunasan)
  - Operational status tracking
- No need for duplication or auto-copy mechanism

**Single Table Approach**:
```
journey_activities (UNIFIED)
├─ Purpose: Itinerary + Payment + Operational tracking
├─ Created: During journey creation
├─ Payment: Agency → Supplier (DP immediately, Pelunasan before H-X)
├─ Tracking: booking_status, execution_status, payment_status
└─ Single source of truth
```

**Migration Plan**:
```sql
-- Drop deprecated table
DROP TABLE IF EXISTS journey_services CASCADE;

-- journey_activities handles everything now
```

---

### CONFLICT 3: Payment Status Confusion

**DECISION**: ✅ **TWO SEPARATE payment contexts (journey_services DEPRECATED)**

**Payment Context 1: Agency → Supplier (Journey Level)**
- Entity: `JourneyActivity.payment_status`
- Purpose: Track if agency paid supplier for service
- Values: unpaid, dp_paid, fully_paid, reserved
- When: During journey creation (BEFORE publish)
- Payment timing:
  - DP: Paid IMMEDIATELY when service selected → Locks availability
  - Pelunasan: Paid before H-X (X = full_payment_due_days from service config)

**Payment Context 2: Customer → Agency (Booking Level)**
- Entity: `PaymentSchedule.status`
- Purpose: Track customer payment to agency
- Values: pending, partially_paid, paid, overdue
- When: After booking created (AFTER journey published)
- Payment timing: According to payment_type (installment/full/flexible)

**NO MORE journey_services.payment_status** - Table deprecated

---

## 🎯 PROPOSED UNIFIED FLOW

### Phase 1: Journey Creation & Procurement Payment

**Step 1.1: Create Journey (Draft)**
```
Agency creates journey:
├─ Basic info (name, dates, quota, type)
├─ Activities with service selection
└─ Status: DRAFT

Database:
├─ journeys table: 1 record
└─ journey_activities table: N records
```

**Step 1.2: Pay for Marketplace Services**
```
For each activity with marketplace service:
├─ Click [Pay Now]
├─ Payment gateway integration
├─ Create payment record
└─ Update activity.procurement_payment_status = "paid"

Database:
└─ payments table: N records (one per marketplace activity)
```

**Step 1.3: Publish Journey**
```
Validation:
├─ ✅ Has activities
├─ ✅ All services selected
├─ ✅ All marketplace services PAID
└─ ✅ All services AVAILABLE

Action:
├─ Update journey.status = "published"
├─ Auto-copy journey_activities → journey_services
└─ Journey visible in marketplace

Database:
├─ journeys: status updated
└─ journey_services table: N records (copied from activities)
```

---

### Phase 2: Customer Booking & Payment

**Step 2.1: Create Booking**
```
Agency staff creates booking:
├─ Select customer
├─ Select published journey
├─ Enter total_pax
├─ Select payment_type (installment/full/flexible)
└─ Status: PENDING

System auto-generates:
├─ Payment schedules (based on payment_type)
├─ Document checklist (per traveler)
└─ Task checklist (after_booking tasks)

Database:
├─ bookings: 1 record
├─ payment_schedules: 1-3 records
├─ booking_documents: N records
└─ booking_tasks: N records
```

**Step 2.2: Customer Pays Agency**
```
Customer pays according to schedule:
├─ DP (40%) - Due: Booking date + 3 days
├─ Installment 1 (30%) - Due: H-60
└─ Installment 2 (30%) - Due: H-30

Database:
├─ payment_transactions: N records
└─ payment_schedules: status updated
```

**Step 2.3: Approve Booking**
```
Agency staff approves booking:
├─ Update booking.status = "confirmed"
├─ Update journey.confirmed_pax += total_pax
└─ Update journey.available_quota -= total_pax

Database:
└─ bookings, journeys: updated
```

---

### Phase 3: Operations & Task Management

**Step 3.1: Task Execution**
```
Agency staff manages tasks:
├─ Collect documents (passport, visa, etc.)
├─ Verify documents
├─ Assign tasks to team members
├─ Update task status (to_do → in_progress → done)
└─ Monitor task completion percentage

Database:
├─ booking_tasks: status updated
└─ booking_documents: status updated
```

**Step 3.2: H-30 Tasks Auto-Generation**
```
Background job (daily 08:00 AM):
├─ Find bookings where departure_date = today + 30 days
├─ Generate tasks from templates (trigger_stage = 'h_30')
└─ Calculate due_date from template.due_days_offset

Database:
└─ booking_tasks: new records created
```

**Step 3.3: H-7 Tasks Auto-Generation**
```
Background job (daily 08:00 AM):
├─ Find bookings where departure_date = today + 7 days
├─ Generate tasks from templates (trigger_stage = 'h_7')
└─ Calculate due_date from template.due_days_offset

Database:
└─ booking_tasks: new records created
```

**Step 3.4: Service Tracking**
```
Agency staff updates journey_services:
├─ booking_status: not_booked → booked → confirmed
├─ execution_status: pending → in_progress → completed
└─ operational_payment_status: unpaid → paid

Database:
└─ journey_services: status updated
```

---

## ❓ CRITICAL QUESTIONS & DECISIONS NEEDED

### Question 1: JourneyService vs JourneyActivity Relationship

**DECISION**: ✅ **Use ONLY journey_activities (Deprecate journey_services)**

**Rationale**:
- journey_services was designed for old Package-based flow
- New unified Journey design makes it redundant
- journey_activities can handle both itinerary AND operational tracking
- Simpler data model, single source of truth

**Implementation**:
```
Journey Creation:
├─ Create journey_activities (itinerary + payment + tracking)
└─ Pay for marketplace activities (DP immediately)

Journey Published:
└─ journey_activities.status = "published"

Booking Created:
└─ Staff updates journey_activities tracking fields
    ├─ booking_status: not_booked → booked → confirmed
    ├─ execution_status: pending → in_progress → completed
    └─ operational_payment_status: Track service execution payment
```

**Migration**:
```sql
DROP TABLE IF EXISTS journey_services CASCADE;
```

---

### Question 2: Booking Entity - Remove package_id?

**DECISION**: ✅ **Remove package_id (Clean Slate Approach)**

**Rationale**:
- Package entity is being deleted
- Journey now contains all package info
- Clean slate migration (no old data to preserve)

**Implementation**:
```csharp
public class Booking
{
    // REMOVE: public Guid PackageId { get; set; }
    public Guid JourneyId { get; set; } // Journey has all package info
}
```

**Migration**:
```sql
ALTER TABLE bookings DROP COLUMN IF EXISTS package_id;
```

---

### Question 3: Payment Flow - Agency → Supplier

**DECISION**: ✅ **Pay IMMEDIATELY during journey creation (No supplier bills)**

**Rationale** (from user clarification):
- DP paid IMMEDIATELY when agency selects service → Locks availability
- Pelunasan paid before H-X (X = full_payment_due_days from service config)
- No deferred payment via supplier bills
- Simpler flow, clear payment status

**Implementation**:
```
Journey Creation:
├─ Select marketplace service
├─ Click [Pay DP Now] (if payment terms enabled)
│   ├─ Payment gateway integration
│   ├─ DP paid immediately
│   ├─ Availability LOCKED
│   └─ Status: "dp_paid"
├─ OR Click [Pay Now] (if no payment terms)
│   ├─ Full payment immediately
│   └─ Status: "fully_paid"
└─ Publish journey (validation: all marketplace services paid)

Before Departure:
├─ System shows pelunasan due dates
├─ Agency pays pelunasan before H-X
└─ Status: "fully_paid"
```

**NO supplier bills needed** - Direct payment via gateway

---

### Question 4: Commission Configuration - Who Pays?

**DECISION**: ✅ **FLEXIBLE - Support all 3 models (Default: Agency only)**

**From Pak Habibi's Requirements**:
- Commission must be VERY flexible
- Different rates per service type (Hotel 4.76%, Flight 5.30%, Visa 3.49%)
- Support percentage AND fixed amount
- Can charge agency, supplier, or BOTH (Gojek model)
- Platform admin configures per service type or per supplier

**Implementation**: Enhanced CommissionConfig entity with:
- `service_type` - Filter by service type (hotel, flight, visa, etc.)
- `supplier_id` - Filter by specific supplier (NULL = all)
- `charged_to` - agency, supplier, both
- `agency_commission_type` + `agency_commission_value`
- `supplier_commission_type` + `supplier_commission_value`
- `priority` - Higher priority = applied first

**Default Configuration** (Recommended):
```
Hotel: 4.76% from agency
Flight: 5.30% from agency
Visa: 3.49% from agency
Transport: 4.00% from agency
Guide: 5.00% from agency
Insurance: 3.50% from agency
Catering: 4.50% from agency
Handling: 5.00% from agency
```

Platform admin can create supplier-specific configs with higher priority to override defaults.

---

### Question 5: Payment Gateway Configuration

**From appsettings.json**:
```json
"Xendit": {
  "ApiKey": "your-xendit-api-key",
  "WebhookToken": "your-webhook-verification-token",
  "CallbackUrl": "https://your-domain.com/api/payments/webhook/xendit",
  "SuccessRedirectUrl": "https://your-domain.com/payments/success",
  "FailureRedirectUrl": "https://your-domain.com/payments/failure"
}
```

**❓ QUESTIONS**:
1. Do you already have Xendit account? Or should we use different gateway?
2. What payment methods to support?
   - Bank Transfer (Virtual Account)
   - Credit Card
   - E-Wallet (OVO, GoPay, Dana)
   - QRIS
3. Payment expiry time? (e.g., 24 hours, 48 hours)
4. Refund policy? Can agency cancel payment after paid?
5. Commission handling? Platform takes % from each transaction?

---

### Question 6: Supplier Bill vs Direct Payment

**Current Confusion**:
- NEW design suggests: Pay immediately during journey creation
- EXISTING spec says: Generate supplier bills after journey created (due at H-7)

**Clarification Needed**:

**Scenario A: Immediate Payment** (NEW design assumption)
```
Journey Creation:
├─ Select service → [Pay Now] → Payment gateway
├─ Payment completed immediately
└─ No supplier bills needed

Pros: Simple, clear payment status
Cons: Agency pays upfront (cash flow impact)
```

**Scenario B: Deferred Payment** (EXISTING spec)
```
Journey Creation:
├─ Select service → Mark as selected
└─ Status: DRAFT

Journey Published:
├─ Auto-generate supplier_bills
└─ Due: H-7 (7 days before departure)

Agency Payment:
├─ View supplier bills
├─ Pay via bank transfer or gateway
└─ Record payment

Pros: Better cash flow, batch payments
Cons: More complex, need bill management
```

**❓ QUESTION**: Should agency pay immediately or later via supplier bills?

**My Strong Recommendation**: **Scenario B (Deferred Payment)** because:
1. Aligns with existing supplier bill system (already implemented) 
2. Better for agency cash flow (pay closer to departure)
3. Can batch multiple services to same supplier
4. Matches travel industry practice (pay suppliers at H-7 or H-14)
5. Reduces payment gateway fees (fewer transactions)

---

## 💡 RECOMMENDED REVISED FLOW

Based on analysis of existing Phase 1 spec and new journey refactor requirements, here's my recommendation:

### REVISED: Journey Creation Flow

**Step 1: Create Journey (Draft)**
```
Agency creates journey:
├─ Basic info (name, dates, quota, type)
├─ Activities with service selection
│   ├─ Marketplace services: Mark as selected (NO immediate payment)
│   └─ Inventory services: Mark as reserved
└─ Status: DRAFT

Database:
├─ journeys: 1 record
└─ journey_activities: N records
```

**Step 2: Publish Journey (Simplified Validation)**
```
Validation:
├─ ✅ Has at least 1 activity
├─ ✅ All service-based activities have services selected
└─ ✅ All services are AVAILABLE

Action:
├─ Update journey.status = "published"
├─ Auto-copy journey_activities → journey_services
├─ Auto-generate supplier_bills (grouped by supplier)
│   ├─ Bill date: Today
│   ├─ Due date: H-7 (7 days before departure)
│   └─ Amount: Sum of services from that supplier
└─ Journey visible in marketplace

Database:
├─ journeys: status = "published"
├─ journey_services: N records (copied)
└─ supplier_bills: N records (one per supplier)
```

**Key Changes from NEW design**:
- ❌ Remove immediate payment requirement during journey creation
- ❌ Remove payment_status validation before publish
- ✅ Keep simple validation (has activities, services selected, available)
- ✅ Use existing supplier bill system for payment
- ✅ Agency pays suppliers later (at H-7 or before)

---

### REVISED: Journey Detail Page

**After Journey Created**:
```
┌─────────────────────────────────────────────────────────────┐
│ Journey Detail: Paket Umroh 10 Hari Awal November          │
│ Status: [DRAFT]                                             │
│                                                             │
│ [Edit Journey] [Publish Journey]                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Itinerary Builder                                           │
│                                                             │
│ Activity 1 - 15 March 2026                                 │
│ ├─ Type: Flight                                            │
│ ├─ Service: Garuda Indonesia Business CGK-JED             │
│ ├─ Source: Supplier (Garuda Indonesia)                    │
│ ├─ Cost: Rp 3.000.000 × 20 = Rp 60.000.000               │
│ └─ Status: [SELECTED] ← Simple badge, no payment buttons  │
│                                                             │
│ Activity 2 - 15 March 2026                                 │
│ ├─ Type: Hotel                                             │
│ ├─ Service: Hotel Grand Makkah 5 Star                     │
│ ├─ Source: Your Inventory                                 │
│ ├─ Cost: Rp 2.500.000 × 20 = Rp 50.000.000               │
│ └─ Status: [RESERVED] ← From inventory                    │
└─────────────────────────────────────────────────────────────┘

[Publish Journey] ← Simple validation, no payment check
```

**After Journey Published**:
```
┌─────────────────────────────────────────────────────────────┐
│ Journey Detail: Paket Umroh 10 Hari Awal November          │
│ Status: [PUBLISHED]                                         │
│                                                             │
│ [View Supplier Bills] [View Bookings] [Unpublish]         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Supplier Bills (Auto-generated)                            │
│                                                             │
│ Bill #1 - Garuda Indonesia                                 │
│ ├─ Amount: Rp 60.000.000                                   │
│ ├─ Due Date: 8 March 2026 (H-7)                           │
│ ├─ Status: [UNPAID]                                        │
│ └─ Actions: [Record Payment]                               │
│                                                             │
│ Bill #2 - Makkah Hotels Ltd                                │
│ ├─ Amount: Rp 50.000.000                                   │
│ ├─ Due Date: 8 March 2026 (H-7)                           │
│ ├─ Status: [UNPAID]                                        │
│ └─ Actions: [Record Payment]                               │
└─────────────────────────────────────────────────────────────┘
```

**Benefits**:
- Simpler journey creation (no payment during creation)
- Uses existing supplier bill system
- Better cash flow for agency
- Batch payments to same supplier
- Payment closer to departure date

---

## 🎯 REVISED ENTITIES & RELATIONSHIPS

### JourneyActivity (NEW - Simplified)

```csharp
public class JourneyActivity
{
    public Guid Id { get; set; }
    public Guid JourneyId { get; set; }
    public int ActivityNumber { get; set; }
    
    // Activity Details
    public DateTime Date { get; set; }
    public string Type { get; set; }
    public string? Description { get; set; }
    
    // Service Selection
    public Guid? SupplierServiceId { get; set; }
    public Guid? AgencyServiceId { get; set; }
    public string? SourceType { get; set; }
    
    // Date Range
    public DateTime? CheckInDate { get; set; }
    public DateTime? CheckOutDate { get; set; }
    
    // Flight-specific
    public DateTime? EstimatedTimeDeparture { get; set; }
    public DateTime? EstimatedTimeArrival { get; set; }
    
    // Pricing
    public int Quantity { get; set; }
    public decimal? UnitCost { get; set; }
    public decimal? TotalCost { get; set; }
    
    // REMOVED: payment_status, payment_id, paid_at
    // REMOVED: is_service_available, availability_checked_at
    // Reason: Use supplier bill system instead
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

---

### JourneyService (EXISTING - Keep as is)

```csharp
public class JourneyService
{
    public Guid Id { get; set; }
    public Guid JourneyId { get; set; }
    public string ServiceType { get; set; }
    public Guid? SupplierServiceId { get; set; }
    public Guid? AgencyServiceId { get; set; }
    public string SourceType { get; set; }
    
    // Operational Tracking
    public string BookingStatus { get; set; } = "not_booked";
    public string ExecutionStatus { get; set; } = "pending";
    public string PaymentStatus { get; set; } = "unpaid";
    
    public DateTime? BookedAt { get; set; }
    public DateTime? ConfirmedAt { get; set; }
    public DateTime? ExecutedAt { get; set; }
    
    // Confirmation workflow
    public int Quantity { get; set; }
    public string ConfirmationStatus { get; set; } = "pending";
    public decimal? EffectivePrice { get; set; }
    public decimal? ConfirmedPrice { get; set; }
}
```

**Purpose**: Operational tracking AFTER journey published

---

### SupplierBill (EXISTING - Keep as is)

```csharp
public class SupplierBill
{
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public Guid SupplierId { get; set; }
    public Guid? POId { get; set; }
    public Guid? JourneyId { get; set; } // Link to journey
    public string BillNumber { get; set; }
    public DateTime BillDate { get; set; }
    public DateTime DueDate { get; set; } // H-7
    public decimal TotalAmount { get; set; }
    public decimal PaidAmount { get; set; }
    public string Status { get; set; } = "unpaid";
}
```

**Purpose**: Track agency payables to suppliers

---

## 🔄 REVISED COMPLETE FLOW

### Phase 1: Journey Creation (Simplified)

```
1. Agency creates journey (draft)
   ├─ Fill basic info
   ├─ Build itinerary with activities
   ├─ Select services (marketplace or inventory)
   └─ Save as draft

2. Agency publishes journey
   ├─ Validation: has activities, services selected, available
   ├─ Status: draft → published
   ├─ Auto-copy: journey_activities → journey_services
   ├─ Auto-generate: supplier_bills (due at H-7)
   └─ Journey visible in marketplace

3. Agency views supplier bills
   ├─ Navigate to Supplier Bills page
   ├─ See all bills grouped by supplier
   ├─ Filter by journey, due date, status
   └─ Pay before H-7 deadline
```

---

### Phase 2: Customer Booking

```
4. Customer browses published journeys
   └─ See journey details, itinerary, pricing

5. Agency staff creates booking
   ├─ Select customer
   ├─ Select journey
   ├─ Enter total_pax
   ├─ Select payment_type (installment/full/flexible)
   └─ Status: pending

6. System auto-generates
   ├─ Payment schedules (customer → agency)
   ├─ Document checklist (per traveler)
   └─ Task checklist (after_booking tasks)

7. Agency staff approves booking
   ├─ Update journey quota
   ├─ Status: pending → confirmed
   └─ Trigger H-30 and H-7 task generation
```

---

### Phase 3: Operations Management

```
8. Agency staff manages tasks
   ├─ Collect documents
   ├─ Verify documents
   ├─ Assign tasks to team
   ├─ Update task status
   └─ Monitor completion

9. Agency staff tracks journey services
   ├─ Update booking_status (not_booked → booked → confirmed)
   ├─ Update execution_status (pending → in_progress → completed)
   └─ Update payment_status (operational tracking)

10. Agency pays suppliers
    ├─ View supplier bills (due at H-7)
    ├─ Record payment (bank transfer or gateway)
    └─ Update bill status

11. Customer pays agency
    ├─ Follow payment schedule
    ├─ DP, Installment 1, Installment 2
    └─ Agency records payments

12. Departure & Completion
    ├─ Booking status: confirmed → departed → completed
    └─ Journey completed
```

---

## 💰 PAYMENT & COMMISSION SYSTEM (COMPREHENSIVE ANALYSIS)

### Business Context (from Pak Habibi)

**Key Insights**:
1. Commission varies significantly by service type:
   - Hotel: ~4.76% (margin 20 riyal out of 420 riyal)
   - Flight: ~5.30% (margin IDR 700k out of IDR 13.2M)
   - Visa: ~3.49% (margin $5 out of $143)
2. Margin depends on supplier type (allotment vs regular)
3. Commission can be percentage OR fixed amount
4. Platform can charge BOTH agency AND supplier (like Gojek model)

**Requirement**: Commission config must be EXTREMELY FLEXIBLE

---

## 🎯 COMMISSION CONFIG DESIGN

### Current CommissionConfig Entity (EXISTING)

```csharp
public class CommissionConfig
{
    public Guid Id { get; set; }
    public string ConfigName { get; set; }
    public string TransactionType { get; set; } // booking, marketplace_order
    public string CommissionType { get; set; } // percentage, fixed
    public decimal CommissionValue { get; set; }
    public decimal? MinTransactionAmount { get; set; }
    public decimal? MaxCommissionAmount { get; set; }
    public bool IsActive { get; set; }
    public DateTime? EffectiveFrom { get; set; }
    public DateTime? EffectiveTo { get; set; }
}
```

**Current Limitations**:
- ❌ No service_type filtering
- ❌ No supplier-specific config
- ❌ Can't charge both agency AND supplier
- ❌ Single commission per transaction

---

### PROPOSED: Enhanced CommissionConfig

**Add New Fields**:
```sql
ALTER TABLE commission_configs
ADD COLUMN service_type VARCHAR(50), -- hotel, flight, visa, etc. (NULL = all types)
ADD COLUMN supplier_id UUID REFERENCES suppliers(id), -- NULL = all suppliers
ADD COLUMN charged_to VARCHAR(20) NOT NULL DEFAULT 'agency', -- agency, supplier, both
ADD COLUMN agency_commission_type VARCHAR(20), -- percentage, fixed (if charged_to = agency or both)
ADD COLUMN agency_commission_value DECIMAL(18,2), -- commission from agency
ADD COLUMN supplier_commission_type VARCHAR(20), -- percentage, fixed (if charged_to = supplier or both)
ADD COLUMN supplier_commission_value DECIMAL(18,2), -- commission from supplier
ADD COLUMN priority INT NOT NULL DEFAULT 0; -- Higher priority = applied first

-- Update constraints
ALTER TABLE commission_configs
DROP COLUMN commission_type,
DROP COLUMN commission_value;

-- Add indexes
CREATE INDEX idx_commission_configs_service_type ON commission_configs(service_type);
CREATE INDEX idx_commission_configs_supplier_id ON commission_configs(supplier_id);
CREATE INDEX idx_commission_configs_priority ON commission_configs(priority);
```

**New Structure**:
```csharp
public class CommissionConfig
{
    public Guid Id { get; set; }
    public string ConfigName { get; set; }
    public string TransactionType { get; set; } // journey_activity_payment, booking, marketplace_order
    
    // Filtering (NEW)
    public string? ServiceType { get; set; } // hotel, flight, visa, etc. (NULL = all)
    public Guid? SupplierId { get; set; } // Specific supplier (NULL = all)
    
    // Who pays commission (NEW)
    public string ChargedTo { get; set; } = "agency"; // agency, supplier, both
    
    // Agency Commission (NEW)
    public string? AgencyCommissionType { get; set; } // percentage, fixed
    public decimal? AgencyCommissionValue { get; set; }
    
    // Supplier Commission (NEW)
    public string? SupplierCommissionType { get; set; } // percentage, fixed
    public decimal? SupplierCommissionValue { get; set; }
    
    // Limits
    public decimal? MinTransactionAmount { get; set; }
    public decimal? MaxCommissionAmount { get; set; }
    
    // Priority (NEW)
    public int Priority { get; set; } = 0; // Higher = applied first
    
    // Status
    public bool IsActive { get; set; } = true;
    public DateTime? EffectiveFrom { get; set; }
    public DateTime? EffectiveTo { get; set; }
}
```

---

### Commission Config Examples

**Example 1: Hotel Commission (Service Type Specific)**
```
Config Name: "Hotel Commission - Standard"
Transaction Type: "journey_activity_payment"
Service Type: "hotel"
Supplier ID: NULL (applies to all hotel suppliers)
Charged To: "agency"
Agency Commission Type: "percentage"
Agency Commission Value: 4.76
Priority: 10
Is Active: true
```

**Example 2: Flight Commission (Service Type Specific)**
```
Config Name: "Flight Commission - Standard"
Transaction Type: "journey_activity_payment"
Service Type: "flight"
Supplier ID: NULL (applies to all flight suppliers)
Charged To: "agency"
Agency Commission Type: "percentage"
Agency Commission Value: 5.30
Priority: 10
Is Active: true
```

**Example 3: Visa Commission (Service Type Specific)**
```
Config Name: "Visa Commission - Standard"
Transaction Type: "journey_activity_payment"
Service Type: "visa"
Supplier ID: NULL (applies to all visa suppliers)
Charged To: "agency"
Agency Commission Type: "percentage"
Agency Commission Value: 3.49
Priority: 10
Is Active: true
```

**Example 4: Premium Supplier (Supplier Specific - Higher Priority)**
```
Config Name: "Premium Hotel Supplier - Special Rate"
Transaction Type: "journey_activity_payment"
Service Type: "hotel"
Supplier ID: "abc-123-def" (specific supplier)
Charged To: "both"
Agency Commission Type: "percentage"
Agency Commission Value: 3.00
Supplier Commission Type: "percentage"
Supplier Commission Value: 2.00
Priority: 20 (higher than standard)
Is Active: true
```

**Example 5: Fixed Commission for Small Transactions**
```
Config Name: "Small Transaction Fixed Fee"
Transaction Type: "journey_activity_payment"
Service Type: NULL (all types)
Supplier ID: NULL (all suppliers)
Charged To: "agency"
Agency Commission Type: "fixed"
Agency Commission Value: 50000 (Rp 50,000 flat fee)
Max Transaction Amount: 1000000 (only for transactions < Rp 1M)
Priority: 5 (lower than service-specific)
Is Active: true
```

---

### Commission Selection Logic (Priority-Based)

**Algorithm**:
```csharp
public async Task<CommissionConfig> GetApplicableCommission(
    string transactionType,
    string serviceType,
    Guid supplierId,
    decimal transactionAmount,
    DateTime transactionDate)
{
    // Get all active configs for transaction type
    var configs = await _repository.GetActiveConfigsAsync(
        transactionType: transactionType,
        effectiveDate: transactionDate
    );
    
    // Filter by criteria and sort by priority (descending)
    var applicableConfigs = configs
        .Where(c => 
            // Check min transaction amount
            (!c.MinTransactionAmount.HasValue || transactionAmount >= c.MinTransactionAmount) &&
            // Check service type match
            (c.ServiceType == null || c.ServiceType == serviceType) &&
            // Check supplier match
            (c.SupplierId == null || c.SupplierId == supplierId)
        )
        .OrderByDescending(c => c.Priority)
        .ThenByDescending(c => c.SupplierId != null ? 1 : 0) // Supplier-specific first
        .ThenByDescending(c => c.ServiceType != null ? 1 : 0) // Service-specific second
        .ToList();
    
    // Return highest priority match
    return applicableConfigs.FirstOrDefault() ?? GetDefaultConfig();
}
```

**Priority Matching Examples**:

**Scenario 1: Hotel booking with premium supplier**
```
Transaction: Hotel service, Supplier ABC, Amount Rp 100M

Available Configs:
1. Priority 20: Hotel + Supplier ABC → 3% agency + 2% supplier ✅ SELECTED
2. Priority 10: Hotel + All suppliers → 4.76% agency
3. Priority 5: All types + All suppliers → 5% agency

Result: Use config #1 (highest priority + most specific)
```

**Scenario 2: Flight booking with regular supplier**
```
Transaction: Flight service, Supplier XYZ, Amount Rp 300M

Available Configs:
1. Priority 10: Flight + All suppliers → 5.30% agency ✅ SELECTED
2. Priority 5: All types + All suppliers → 5% agency

Result: Use config #1 (service-specific)
```

**Scenario 3: Small visa transaction**
```
Transaction: Visa service, Supplier DEF, Amount Rp 500K

Available Configs:
1. Priority 10: Visa + All suppliers → 3.49% agency
2. Priority 5: All types + Max 1M → Rp 50,000 fixed ✅ SELECTED

Result: Use config #2 (fixed fee better for small transactions)
```

---

### Commission Calculation with Both Parties

**When charged_to = "both"**:
```
Transaction Amount: Rp 100,000,000

Commission Config:
├─ Charged To: both
├─ Agency Commission: 3% percentage
└─ Supplier Commission: 2% percentage

Calculation:
├─ Agency pays: Rp 100,000,000 + Rp 3,000,000 = Rp 103,000,000
├─ Platform receives: Rp 103,000,000
├─ Platform deducts supplier commission: Rp 100,000,000 × 2% = Rp 2,000,000
├─ Supplier receives: Rp 100,000,000 - Rp 2,000,000 = Rp 98,000,000
└─ Platform total commission: Rp 3,000,000 + Rp 2,000,000 = Rp 5,000,000
```

**When charged_to = "agency"**:
```
Transaction Amount: Rp 100,000,000

Commission Config:
├─ Charged To: agency
└─ Agency Commission: 5% percentage

Calculation:
├─ Agency pays: Rp 100,000,000 + Rp 5,000,000 = Rp 105,000,000
├─ Platform receives: Rp 105,000,000
├─ Supplier receives: Rp 100,000,000
└─ Platform commission: Rp 5,000,000
```

**When charged_to = "supplier"**:
```
Transaction Amount: Rp 100,000,000

Commission Config:
├─ Charged To: supplier
└─ Supplier Commission: 5% percentage

Calculation:
├─ Agency pays: Rp 100,000,000
├─ Platform receives: Rp 100,000,000
├─ Platform deducts: Rp 5,000,000
├─ Supplier receives: Rp 95,000,000
└─ Platform commission: Rp 5,000,000
```

---

## 📊 PAYMENT TRACKING - AGENCY SIDE

### Agency Payment Dashboard

**Location**: `/agency/payments` or `/agency/journeys/{id}/payments`

**View 1: Journey Payment Overview**
```
┌─────────────────────────────────────────────────────────────┐
│ Journey: Paket Umroh 10 Hari Awal November                  │
│ Departure: 15 March 2026                                    │
│ Status: DRAFT                                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Payment Summary                                             │
│                                                             │
│ Total Journey Cost: Rp 500,000,000                         │
│ ├─ From Marketplace: Rp 450,000,000                        │
│ └─ From Inventory: Rp 50,000,000 (no payment needed)      │
│                                                             │
│ Payment Status:                                             │
│ ├─ Paid: Rp 150,000,000 (33%)                             │
│ ├─ Pending: Rp 300,000,000 (67%)                          │
│ └─ Progress: [████████░░░░░░░░] 33%                       │
│                                                             │
│ Platform Commission: Rp 22,500,000                         │
│ ├─ Already Paid: Rp 7,500,000                             │
│ └─ Pending: Rp 15,000,000                                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Activity Payment Details                                    │
│                                                             │
│ Activity 1: Flight to Jeddah                               │
│ ├─ Service: Garuda Indonesia Business CGK-JED             │
│ ├─ Total Cost: Rp 300,000,000                             │
│ ├─ Payment Terms: Full payment required                    │
│ ├─ Commission: Rp 15,900,000 (5.30%)                      │
│ ├─ Total You Pay: Rp 315,900,000                          │
│ ├─ Status: [UNPAID]                                        │
│ └─ Actions: [Pay Now Rp 315,900,000]                      │
│                                                             │
│ Activity 2: Hotel Grand Makkah                             │
│ ├─ Service: Hotel Grand Makkah 5 Star                     │
│ ├─ Total Cost: Rp 150,000,000                             │
│ ├─ Payment Terms: DP 30% + Pelunasan 70%                  │
│ ├─ DP Amount: Rp 45,000,000                                │
│ ├─ DP Commission: Rp 2,142,000 (4.76%)                    │
│ ├─ Total DP: Rp 47,142,000                                │
│ ├─ Status: [DP PAID] ✅                                    │
│ ├─ Remaining: Rp 105,000,000 (due H-7: 8 March 2026)     │
│ ├─ Pelunasan Commission: Rp 4,998,000 (4.76%)            │
│ ├─ Total Pelunasan: Rp 109,998,000                        │
│ └─ Actions: [Pay Pelunasan] [View DP Receipt]             │
│                                                             │
│ Activity 3: Guide Service                                  │
│ ├─ Service: Arabic-English Guide                          │
│ ├─ Source: Your Inventory                                 │
│ ├─ Status: [RESERVED]                                      │
│ └─ Actions: (none - using inventory)                      │
└─────────────────────────────────────────────────────────────┘
```

**Key Features**:
- Shows total cost breakdown
- Shows commission per activity (transparent)
- Shows payment status per activity
- Shows due dates for pelunasan
- Clear action buttons

---

### Agency Payment History

**Location**: `/agency/payments/history`

```
┌─────────────────────────────────────────────────────────────┐
│ Payment History                                             │
│                                                             │
│ Filters: [All Journeys ▼] [All Status ▼] [Date Range]     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Payment #PAY-20260318-001                                   │
│ ├─ Date: 18 March 2026 10:30 AM                           │
│ ├─ Journey: Paket Umroh 10 Hari Awal November             │
│ ├─ Activity: Hotel Grand Makkah (DP)                       │
│ ├─ Service Cost: Rp 45,000,000                            │
│ ├─ Platform Commission: Rp 2,142,000 (4.76%)              │
│ ├─ Total Paid: Rp 47,142,000                              │
│ ├─ Payment Method: Virtual Account BCA                     │
│ ├─ Status: [SUCCESS] ✅                                    │
│ └─ Actions: [View Receipt] [Download Invoice]             │
│                                                             │
│ Payment #PAY-20260317-005                                   │
│ ├─ Date: 17 March 2026 14:20 PM                           │
│ ├─ Journey: Paket Halal Tour Turki 12 Hari                │
│ ├─ Activity: Flight Istanbul (Full Payment)                │
│ ├─ Service Cost: Rp 200,000,000                            │
│ ├─ Platform Commission: Rp 10,600,000 (5.30%)             │
│ ├─ Total Paid: Rp 210,600,000                             │
│ ├─ Payment Method: Credit Card                             │
│ ├─ Status: [SUCCESS] ✅                                    │
│ └─ Actions: [View Receipt] [Download Invoice]             │
└─────────────────────────────────────────────────────────────┘
```

---

### Agency Upcoming Payments (Pelunasan Tracker)

**Location**: `/agency/payments/upcoming`

```
┌─────────────────────────────────────────────────────────────┐
│ Upcoming Payments (Pelunasan)                               │
│                                                             │
│ Filters: [Next 7 Days ▼] [All Journeys ▼]                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ⚠️ DUE IN 3 DAYS                                           │
│                                                             │
│ Journey: Paket Umroh 10 Hari Awal November                 │
│ Departure: 15 March 2026                                    │
│                                                             │
│ Activity: Hotel Grand Makkah                                │
│ ├─ DP Paid: Rp 47,142,000 ✅ (18 March 2026)             │
│ ├─ Pelunasan Due: 8 March 2026 (H-7)                      │
│ ├─ Service Cost: Rp 105,000,000                           │
│ ├─ Commission: Rp 4,998,000 (4.76%)                       │
│ ├─ Total to Pay: Rp 109,998,000                           │
│ └─ Actions: [Pay Now] [Request Extension]                 │
│                                                             │
│ Activity: Transport Bus                                     │
│ ├─ DP Paid: Rp 15,714,000 ✅ (18 March 2026)             │
│ ├─ Pelunasan Due: 8 March 2026 (H-7)                      │
│ ├─ Service Cost: Rp 35,000,000                            │
│ ├─ Commission: Rp 1,666,000 (4.76%)                       │
│ ├─ Total to Pay: Rp 36,666,000                            │
│ └─ Actions: [Pay Now]                                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 📅 DUE IN 10 DAYS                                          │
│                                                             │
│ Journey: Paket Halal Tour Turki 12 Hari                    │
│ Departure: 25 March 2026                                    │
│                                                             │
│ Activity: Hotel Istanbul                                    │
│ ├─ DP Paid: Rp 30,000,000 ✅ (15 March 2026)             │
│ ├─ Pelunasan Due: 18 March 2026 (H-7)                     │
│ ├─ Service Cost: Rp 70,000,000                            │
│ ├─ Commission: Rp 3,332,000 (4.76%)                       │
│ ├─ Total to Pay: Rp 73,332,000                            │
│ └─ Actions: [Pay Now]                                      │
└─────────────────────────────────────────────────────────────┘
```

**Features**:
- Shows all upcoming pelunasan payments
- Sorted by due date (urgent first)
- Color coding: Red (overdue), Orange (< 3 days), Yellow (< 7 days)
- Quick pay action
- Notification alerts for due payments

---

## 📊 PAYMENT TRACKING - SUPPLIER SIDE

### Supplier Payment Dashboard

**Location**: `/supplier/payments` or `/supplier/revenue`

**View 1: Revenue Overview**
```
┌─────────────────────────────────────────────────────────────┐
│ Revenue Dashboard                                           │
│                                                             │
│ Period: March 2026                                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Revenue Summary                                             │
│                                                             │
│ Total Bookings: 15 services                                │
│ Gross Revenue: Rp 750,000,000                              │
│ Platform Commission: Rp 35,700,000 (4.76% avg)            │
│ Net Revenue: Rp 714,300,000                                │
│                                                             │
│ Payment Status:                                             │
│ ├─ Received: Rp 400,000,000 (56%)                         │
│ ├─ Pending Transfer: Rp 200,000,000 (28%)                 │
│ └─ Awaiting Payment: Rp 114,300,000 (16%)                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Revenue by Service Type                                     │
│                                                             │
│ Hotel: Rp 450,000,000 (60%)                                │
│ ├─ Commission: Rp 21,420,000 (4.76%)                      │
│ └─ Net: Rp 428,580,000                                     │
│                                                             │
│ Flight: Rp 200,000,000 (27%)                               │
│ ├─ Commission: Rp 10,600,000 (5.30%)                      │
│ └─ Net: Rp 189,400,000                                     │
│                                                             │
│ Transport: Rp 100,000,000 (13%)                            │
│ ├─ Commission: Rp 3,680,000 (3.68%)                       │
│ └─ Net: Rp 96,320,000                                      │
└─────────────────────────────────────────────────────────────┘
```

---

### Supplier Payment Transactions

**Location**: `/supplier/payments/transactions`

```
┌─────────────────────────────────────────────────────────────┐
│ Payment Transactions                                        │
│                                                             │
│ Filters: [All Services ▼] [All Status ▼] [Date Range]     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Payment #PAY-20260318-001 (DP)                             │
│ ├─ Date: 18 March 2026 10:30 AM                           │
│ ├─ Agency: PT Berkah Travel                                │
│ ├─ Journey: Paket Umroh 10 Hari Awal November             │
│ ├─ Service: Hotel Grand Makkah 5 Star                     │
│ ├─ Payment Type: Down Payment (30%)                        │
│ ├─ Service Cost: Rp 45,000,000                            │
│ ├─ Platform Commission: Rp 2,142,000 (4.76%)              │
│ ├─ You Receive: Rp 42,858,000                             │
│ ├─ Transfer Status: [TRANSFERRED] ✅                       │
│ ├─ Transferred At: 18 March 2026 15:00 PM                 │
│ └─ Actions: [View Details] [Download Statement]           │
│                                                             │
│ Payment #PAY-20260318-002 (Pelunasan Pending)              │
│ ├─ Date: (Not paid yet)                                    │
│ ├─ Agency: PT Berkah Travel                                │
│ ├─ Journey: Paket Umroh 10 Hari Awal November             │
│ ├─ Service: Hotel Grand Makkah 5 Star                     │
│ ├─ Payment Type: Full Payment (70%)                        │
│ ├─ Service Cost: Rp 105,000,000                           │
│ ├─ Expected Commission: Rp 4,998,000 (4.76%)              │
│ ├─ You Will Receive: Rp 100,002,000                       │
│ ├─ Due Date: 8 March 2026 (H-7)                           │
│ ├─ Status: [AWAITING PAYMENT] ⏳                          │
│ └─ Days Until Due: 3 days                                  │
└─────────────────────────────────────────────────────────────┘
```

**Key Features**:
- Shows both DP and Pelunasan separately
- Transparent commission display
- Transfer status tracking
- Due date monitoring for pelunasan
- Downloadable statements

---

### Supplier Pending Payments (Awaiting Agency Payment)

**Location**: `/supplier/payments/pending`

```
┌─────────────────────────────────────────────────────────────┐
│ Pending Payments (Awaiting Agency)                         │
│                                                             │
│ Total Pending: Rp 250,000,000                              │
│ Expected Commission Deduction: Rp 11,900,000               │
│ Expected Net: Rp 238,100,000                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ⚠️ OVERDUE (Past H-7)                                      │
│                                                             │
│ Journey: Paket Umroh Februari                               │
│ Agency: PT Amanah Travel                                    │
│ Service: Hotel Madinah Premium                              │
│ ├─ Payment Type: Pelunasan (70%)                           │
│ ├─ Service Cost: Rp 80,000,000                            │
│ ├─ Due Date: 1 March 2026 (H-7)                           │
│ ├─ Days Overdue: 17 days                                   │
│ ├─ Status: [OVERDUE] 🔴                                    │
│ └─ Actions: [Contact Agency] [Report Issue]               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 📅 DUE IN 3 DAYS                                           │
│                                                             │
│ Journey: Paket Umroh 10 Hari Awal November                 │
│ Agency: PT Berkah Travel                                    │
│ Service: Hotel Grand Makkah 5 Star                         │
│ ├─ Payment Type: Pelunasan (70%)                           │
│ ├─ DP Paid: Rp 47,142,000 ✅ (18 March 2026)             │
│ ├─ Service Cost: Rp 105,000,000                           │
│ ├─ Expected Commission: Rp 4,998,000 (4.76%)              │
│ ├─ You Will Receive: Rp 100,002,000                       │
│ ├─ Due Date: 8 March 2026 (H-7)                           │
│ └─ Status: [PENDING] ⏳                                    │
└─────────────────────────────────────────────────────────────┘
```

**Key Features**:
- Shows overdue payments (past H-7)
- Shows upcoming due dates
- Contact agency feature
- Report issue to platform
- Automatic notifications to agency

---

## 💳 PAYMENT ENTITY (UPDATED)

### Payment Table Schema

```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- References
    agency_id UUID NOT NULL REFERENCES agencies(id),
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    journey_id UUID NOT NULL REFERENCES journeys(id),
    journey_activity_id UUID NOT NULL REFERENCES journey_activities(id),
    supplier_service_id UUID NOT NULL REFERENCES supplier_services(id),
    
    -- Payment Details
    payment_type VARCHAR(20) NOT NULL, -- down_payment, full_payment
    service_cost DECIMAL(18,2) NOT NULL, -- Original service cost
    
    -- Commission (from commission_configs)
    commission_config_id UUID REFERENCES commission_configs(id),
    agency_commission_type VARCHAR(20), -- percentage, fixed
    agency_commission_value DECIMAL(18,2),
    agency_commission_amount DECIMAL(18,2) NOT NULL, -- Calculated
    supplier_commission_type VARCHAR(20), -- percentage, fixed (if charged to supplier)
    supplier_commission_value DECIMAL(18,2),
    supplier_commission_amount DECIMAL(18,2) DEFAULT 0, -- Calculated
    total_commission_amount DECIMAL(18,2) NOT NULL, -- agency + supplier commission
    
    -- Payment Amounts
    amount_paid_by_agency DECIMAL(18,2) NOT NULL, -- service_cost + agency_commission
    amount_to_supplier DECIMAL(18,2) NOT NULL, -- service_cost - supplier_commission
    
    currency VARCHAR(10) NOT NULL DEFAULT 'IDR',
    
    -- Payment Gateway
    payment_gateway VARCHAR(50) NOT NULL, -- xendit, midtrans
    payment_method VARCHAR(50) NOT NULL, -- virtual_account, credit_card, ewallet, qris
    bank_code VARCHAR(20), -- BCA, BNI, etc. (for VA)
    transaction_id VARCHAR(255), -- From gateway
    payment_url TEXT, -- Gateway payment page
    
    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, processing, success, failed, expired
    paid_at TIMESTAMP,
    expired_at TIMESTAMP,
    
    -- Supplier Transfer
    supplier_transfer_status VARCHAR(50) DEFAULT 'pending', -- pending, transferred, failed
    transferred_to_supplier_at TIMESTAMP,
    transfer_reference_number VARCHAR(255),
    transfer_notes TEXT,
    
    -- Receipt
    receipt_url TEXT,
    receipt_number VARCHAR(100),
    
    -- Metadata
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT check_payment_type CHECK (payment_type IN ('down_payment', 'full_payment')),
    CONSTRAINT check_amounts_positive CHECK (
        service_cost > 0 AND 
        amount_paid_by_agency > 0 AND 
        amount_to_supplier > 0
    )
);

CREATE INDEX idx_payments_agency_id ON payments(agency_id);
CREATE INDEX idx_payments_supplier_id ON payments(supplier_id);
CREATE INDEX idx_payments_journey_id ON payments(journey_id);
CREATE INDEX idx_payments_activity_id ON payments(journey_activity_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_transfer_status ON payments(supplier_transfer_status);
```

---

### JourneyActivity Payment Status (UPDATED)

```csharp
public class JourneyActivity
{
    // ... other fields ...
    
    // Payment Tracking
    public string PaymentStatus { get; set; } = "unpaid"; // unpaid, dp_paid, fully_paid, reserved
    public Guid? DownPaymentId { get; set; } // Link to DP payment
    public Guid? FullPaymentId { get; set; } // Link to full payment
    public DateTime? DownPaymentPaidAt { get; set; }
    public DateTime? FullPaymentPaidAt { get; set; }
    public DateTime? FullPaymentDueDate { get; set; } // Calculated: departure_date - full_payment_due_days
    
    // Navigation
    public Payment? DownPayment { get; set; }
    public Payment? FullPayment { get; set; }
}
```

**Payment Status Flow**:
```
unpaid → (Pay DP) → dp_paid → (Pay Pelunasan) → fully_paid
   ↓
reserved (if from inventory, skip payment)
```

---

## 🔄 PAYMENT WORKFLOW (DETAILED)

### Scenario 1: Service with DP + Pelunasan

**Service Configuration**:
```
Hotel Grand Makkah 5 Star
├─ Base Price: Rp 2,500,000 per night
├─ Payment Terms Enabled: Yes
├─ DP Percentage: 30%
└─ Full Payment Due: H-7
```

**Step 1: Agency Selects Service in Journey**
```
Activity created:
├─ Service: Hotel Grand Makkah
├─ Check-in: 15 March 2026
├─ Check-out: 20 March 2026
├─ Quantity: 20 rooms
├─ Unit Cost: Rp 2,500,000 × 5 nights = Rp 12,500,000
├─ Total Cost: Rp 12,500,000 × 20 = Rp 250,000,000
└─ Payment Status: "unpaid"
```

**Step 2: Agency Clicks [Pay DP]**
```
System calculates:
├─ Service Cost: Rp 250,000,000
├─ DP Amount (30%): Rp 75,000,000
├─ Get commission config for "hotel" type
├─ Commission: 4.76% percentage
├─ Agency Commission: Rp 75,000,000 × 4.76% = Rp 3,570,000
├─ Total Agency Pays: Rp 75,000,000 + Rp 3,570,000 = Rp 78,570,000
└─ Supplier Receives: Rp 75,000,000 (commission deducted later)

Payment Dialog shows:
┌─────────────────────────────────────────┐
│ Payment - Down Payment (DP)             │
│                                         │
│ Service: Hotel Grand Makkah 5 Star     │
│ Service Cost: Rp 75,000,000            │
│ Platform Commission: Rp 3,570,000      │
│ Total to Pay: Rp 78,570,000            │
│                                         │
│ Payment Method:                         │
│ ○ Virtual Account (BCA, BNI, etc.)    │
│ ○ Credit Card                          │
│ ○ E-Wallet (OVO, GoPay, Dana)         │
│ ○ QRIS                                 │
│                                         │
│ [Cancel] [Proceed to Payment]          │
└─────────────────────────────────────────┘
```

**Step 3: Payment Gateway Processing**
```
Frontend → Backend: POST /api/journeys/{id}/activities/{id}/payment
Backend:
├─ Get commission config for service type "hotel"
├─ Calculate commission amounts
├─ Create payment record (status = "pending")
├─ Call Xendit API to create invoice
├─ Return payment_url

Frontend:
└─ Redirect to Xendit payment page

User completes payment on Xendit:
├─ Select payment method (VA BCA)
├─ Get VA number
├─ Transfer via mobile banking
└─ Payment success

Xendit → Webhook: POST /api/payments/webhook/xendit
Backend:
├─ Verify webhook signature
├─ Update payment.status = "success"
├─ Update payment.paid_at
├─ Update journey_activity.payment_status = "dp_paid"
├─ Update journey_activity.down_payment_id
├─ Calculate full_payment_due_date = check_in_date - 7 days
├─ Update journey_activity.full_payment_due_date
├─ Create commission_transaction record
├─ Schedule supplier transfer (background job)
└─ Send notification to agency & supplier

Database:
├─ payments: status = "success"
├─ journey_activities: payment_status = "dp_paid"
└─ commission_transactions: 1 record created
```

**Step 4: Supplier Transfer (Background Job)**
```
Background Job (runs every hour):
├─ Find payments with status="success" and supplier_transfer_status="pending"
├─ For each payment:
│   ├─ Calculate supplier amount (service_cost - supplier_commission if any)
│   ├─ Call Xendit Disbursement API
│   ├─ Transfer to supplier bank account
│   ├─ Update supplier_transfer_status = "transferred"
│   ├─ Record transfer_reference_number
│   └─ Send notification to supplier
└─ Log all transfers
```

**Step 5: Agency Pays Pelunasan (Before H-7)**
```
System shows reminder:
├─ Due Date: 8 March 2026 (H-7)
├─ Service Cost: Rp 175,000,000 (70%)
├─ Commission: Rp 8,330,000 (4.76%)
└─ Total to Pay: Rp 183,330,000

Agency clicks [Pay Pelunasan]:
├─ Same flow as DP payment
├─ Payment type: "full_payment"
├─ Update journey_activity.payment_status = "fully_paid"
└─ Update journey_activity.full_payment_id

Database:
├─ payments: 2nd record created
├─ journey_activities: payment_status = "fully_paid"
└─ commission_transactions: 2nd record created
```

---

### Scenario 2: Service without Payment Terms (Full Payment)

**Service Configuration**:
```
Garuda Indonesia Business CGK-JED
├─ Base Price: Rp 15,000,000 per seat
├─ Payment Terms Enabled: No
└─ (No DP, full payment required)
```

**Step 1: Agency Selects Service**
```
Activity created:
├─ Service: Garuda Indonesia Business
├─ Quantity: 20 seats
├─ Unit Cost: Rp 15,000,000
├─ Total Cost: Rp 300,000,000
└─ Payment Status: "unpaid"
```

**Step 2: Agency Clicks [Pay Now]**
```
System calculates:
├─ Service Cost: Rp 300,000,000
├─ Get commission config for "flight" type
├─ Commission: 5.30% percentage
├─ Agency Commission: Rp 300,000,000 × 5.30% = Rp 15,900,000
└─ Total Agency Pays: Rp 315,900,000

Payment Dialog shows:
┌─────────────────────────────────────────┐
│ Payment - Full Payment                  │
│                                         │
│ Service: Garuda Indonesia Business      │
│ Service Cost: Rp 300,000,000           │
│ Platform Commission: Rp 15,900,000     │
│ Total to Pay: Rp 315,900,000           │
│                                         │
│ [Payment Method Selection]             │
│                                         │
│ [Cancel] [Proceed to Payment]          │
└─────────────────────────────────────────┘

After payment success:
├─ Update journey_activity.payment_status = "fully_paid"
├─ Update journey_activity.full_payment_id
└─ No pelunasan needed (already fully paid)
```

---

### Scenario 3: Service from Inventory (No Payment)

**Activity Configuration**:
```
Activity created:
├─ Service: Arabic-English Guide
├─ Source: agency (inventory)
├─ Quantity: 20 pax
├─ Unit Cost: Rp 500,000
├─ Total Cost: Rp 10,000,000
└─ Payment Status: "reserved"

No payment needed:
├─ Using agency's own inventory
├─ No payment gateway involved
└─ No commission charged
```

---

## 📋 COMMISSION TRANSACTION TRACKING

### CommissionTransaction Entity (UPDATED)

```csharp
public class CommissionTransaction
{
    public Guid Id { get; set; }
    public string TransactionType { get; set; } = "journey_activity_payment";
    public Guid ReferenceId { get; set; } // payment_id
    
    // Parties
    public Guid AgencyId { get; set; }
    public Guid SupplierId { get; set; }
    
    // Commission Config Used
    public Guid CommissionConfigId { get; set; }
    
    // Transaction Details
    public decimal BaseAmount { get; set; } // Service cost
    
    // Agency Commission
    public string? AgencyCommissionType { get; set; } // percentage, fixed
    public decimal? AgencyCommissionRate { get; set; } // e.g., 4.76
    public decimal AgencyCommissionAmount { get; set; } // Calculated
    
    // Supplier Commission (if charged_to = supplier or both)
    public string? SupplierCommissionType { get; set; }
    public decimal? SupplierCommissionRate { get; set; }
    public decimal SupplierCommissionAmount { get; set; } // Calculated
    
    // Total
    public decimal TotalCommissionAmount { get; set; } // agency + supplier
    
    // Status
    public string Status { get; set; } = "collected";
    public DateTime CollectedAt { get; set; }
    
    // Metadata
    public string? PaymentReference { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    
    // Navigation
    public Agency Agency { get; set; }
    public Supplier Supplier { get; set; }
    public CommissionConfig CommissionConfig { get; set; }
    public Payment Payment { get; set; }
}
```

---

## 🎯 PLATFORM ADMIN - COMMISSION MANAGEMENT

### Commission Config Management Page

**Location**: `/platform-admin/commission-configs`

```
┌─────────────────────────────────────────────────────────────┐
│ Commission Configuration                                    │
│                                                             │
│ [+ Add New Config]                                         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Active Configurations                                       │
│                                                             │
│ Config: Hotel Commission - Standard                         │
│ ├─ Transaction Type: journey_activity_payment              │
│ ├─ Service Type: hotel                                     │
│ ├─ Supplier: All suppliers                                 │
│ ├─ Charged To: agency                                      │
│ ├─ Commission: 4.76% percentage                            │
│ ├─ Priority: 10                                            │
│ ├─ Status: [ACTIVE] ✅                                     │
│ └─ Actions: [Edit] [Deactivate] [View Transactions]       │
│                                                             │
│ Config: Flight Commission - Standard                        │
│ ├─ Transaction Type: journey_activity_payment              │
│ ├─ Service Type: flight                                    │
│ ├─ Supplier: All suppliers                                 │
│ ├─ Charged To: agency                                      │
│ ├─ Commission: 5.30% percentage                            │
│ ├─ Priority: 10                                            │
│ ├─ Status: [ACTIVE] ✅                                     │
│ └─ Actions: [Edit] [Deactivate]                           │
│                                                             │
│ Config: Premium Supplier - Special Rate                     │
│ ├─ Transaction Type: journey_activity_payment              │
│ ├─ Service Type: hotel                                     │
│ ├─ Supplier: PT Makkah Hotels Premium                      │
│ ├─ Charged To: both                                        │
│ ├─ Agency Commission: 3.00% percentage                     │
│ ├─ Supplier Commission: 2.00% percentage                   │
│ ├─ Priority: 20 (overrides standard hotel config)         │
│ ├─ Status: [ACTIVE] ✅                                     │
│ └─ Actions: [Edit] [Deactivate]                           │
└─────────────────────────────────────────────────────────────┘
```

### Commission Config Form

```
┌─────────────────────────────────────────────────────┐
│ Create Commission Configuration                     │
│                                                     │
│ Config Name: [Hotel Commission - Standard]         │
│                                                     │
│ Transaction Type: [journey_activity_payment ▼]     │
│                                                     │
│ Apply To:                                          │
│ • Service Type: [hotel ▼] (or "All Types")        │
│ • Supplier: [All Suppliers ▼] (or select specific)│
│                                                     │
│ Commission Settings:                                │
│ • Charged To: ○ Agency ○ Supplier ○ Both          │
│                                                     │
│ [If Agency or Both:]                               │
│ Agency Commission:                                  │
│ • Type: ○ Percentage ○ Fixed Amount                │
│ • Value: [4.76] %                                  │
│                                                     │
│ [If Supplier or Both:]                             │
│ Supplier Commission:                                │
│ • Type: ○ Percentage ○ Fixed Amount                │
│ • Value: [2.00] %                                  │
│                                                     │
│ Limits (Optional):                                  │
│ • Min Transaction: [Rp 0]                          │
│ • Max Commission: [Rp 0] (0 = no limit)           │
│                                                     │
│ Priority: [10] (higher = applied first)            │
│                                                     │
│ Effective Period:                                   │
│ • From: [1 March 2026]                             │
│ • To: [31 December 2026] (or leave empty)         │
│                                                     │
│ [Cancel] [Save Configuration]                      │
└─────────────────────────────────────────────────────┘
```

---

## 📊 COMMISSION REPORTING

### Platform Admin Revenue Dashboard

**Location**: `/platform-admin/revenue`

```
┌─────────────────────────────────────────────────────────────┐
│ Platform Revenue Dashboard                                  │
│                                                             │
│ Period: March 2026                                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Total Commission Earned                                     │
│                                                             │
│ Rp 125,000,000                                             │
│ ├─ From Agency: Rp 100,000,000 (80%)                      │
│ └─ From Supplier: Rp 25,000,000 (20%)                     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Commission by Service Type                                  │
│                                                             │
│ Hotel (4.76% avg):                                         │
│ ├─ Transactions: 45                                        │
│ ├─ Gross: Rp 1,500,000,000                                │
│ └─ Commission: Rp 71,400,000                               │
│                                                             │
│ Flight (5.30% avg):                                        │
│ ├─ Transactions: 30                                        │
│ ├─ Gross: Rp 900,000,000                                  │
│ └─ Commission: Rp 47,700,000                               │
│                                                             │
│ Visa (3.49% avg):                                          │
│ ├─ Transactions: 50                                        │
│ ├─ Gross: Rp 150,000,000                                  │
│ └─ Commission: Rp 5,235,000                                │
│                                                             │
│ Others:                                                     │
│ ├─ Transactions: 25                                        │
│ ├─ Gross: Rp 200,000,000                                  │
│ └─ Commission: Rp 665,000                                  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Commission by Payment Type                                  │
│                                                             │
│ Down Payment (DP):                                         │
│ ├─ Transactions: 80                                        │
│ ├─ Amount: Rp 800,000,000                                 │
│ └─ Commission: Rp 38,000,000                               │
│                                                             │
│ Full Payment (Pelunasan):                                  │
│ ├─ Transactions: 50                                        │
│ ├─ Amount: Rp 1,200,000,000                               │
│ └─ Commission: Rp 57,000,000                               │
│                                                             │
│ Full Payment (No DP):                                      │
│ ├─ Transactions: 20                                        │
│ ├─ Amount: Rp 750,000,000                                 │
│ └─ Commission: Rp 30,000,000                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔔 NOTIFICATION SYSTEM

### Agency Notifications

**1. Payment Success**
```
Subject: Payment Successful - Hotel Grand Makkah DP

Your down payment has been processed successfully.

Journey: Paket Umroh 10 Hari Awal November
Activity: Hotel Grand Makkah 5 Star
Payment Type: Down Payment (30%)
Amount Paid: Rp 78,570,000
Service Cost: Rp 75,000,000
Platform Fee: Rp 3,570,000

Remaining Payment:
- Pelunasan (70%): Rp 183,330,000
- Due Date: 8 March 2026 (H-7)

[View Payment Receipt] [View Journey]
```

**2. Pelunasan Reminder (H-10, H-7, H-3)**
```
Subject: Payment Reminder - Pelunasan Due in 3 Days

Your full payment is due soon.

Journey: Paket Umroh 10 Hari Awal November
Activity: Hotel Grand Makkah 5 Star
Payment Type: Full Payment (70%)
Amount to Pay: Rp 183,330,000
Due Date: 8 March 2026 (in 3 days)

[Pay Now] [View Details]
```

**3. Payment Overdue**
```
Subject: ⚠️ Payment Overdue - Action Required

Your payment is overdue.

Journey: Paket Umroh 10 Hari Awal November
Activity: Hotel Grand Makkah 5 Star
Payment Type: Full Payment (70%)
Amount: Rp 183,330,000
Due Date: 8 March 2026 (17 days overdue)

Warning: Service may be cancelled if payment not received.

[Pay Now] [Contact Support]
```

---

### Supplier Notifications

**1. DP Payment Received**
```
Subject: Payment Received - Down Payment

You have received a down payment.

Agency: PT Berkah Travel
Journey: Paket Umroh 10 Hari Awal November
Service: Hotel Grand Makkah 5 Star
Payment Type: Down Payment (30%)
Service Cost: Rp 75,000,000
Platform Commission: Rp 0 (charged to agency)
Amount Transferred: Rp 75,000,000
Transfer Date: 18 March 2026 15:00 PM
Transfer Reference: XEN-TRF-20260318-001

Remaining Payment:
- Pelunasan (70%): Rp 175,000,000
- Expected Date: 8 March 2026 (H-7)

[View Transaction] [Download Statement]
```

**2. Pelunasan Pending Reminder**
```
Subject: Pelunasan Payment Due in 3 Days

A full payment is due soon from agency.

Agency: PT Berkah Travel
Journey: Paket Umroh 10 Hari Awal November
Service: Hotel Grand Makkah 5 Star
Payment Type: Full Payment (70%)
Service Cost: Rp 175,000,000
Expected Commission: Rp 0 (charged to agency)
You Will Receive: Rp 175,000,000
Due Date: 8 March 2026 (in 3 days)

[View Details]
```

**3. Pelunasan Payment Received**
```
Subject: Payment Received - Full Payment

You have received the full payment.

Agency: PT Berkah Travel
Journey: Paket Umroh 10 Hari Awal November
Service: Hotel Grand Makkah 5 Star
Payment Type: Full Payment (70%)
Service Cost: Rp 175,000,000
Platform Commission: Rp 0 (charged to agency)
Amount Transferred: Rp 175,000,000
Transfer Date: 7 March 2026 10:00 AM
Transfer Reference: XEN-TRF-20260307-015

Total Received for This Booking:
- DP: Rp 75,000,000
- Pelunasan: Rp 175,000,000
- Total: Rp 250,000,000 ✅

[View Transaction] [Download Statement]
```

---

## ✅ FINALIZED DECISIONS

### Decision 1: Commission - Charged to Agency or Supplier?

**DECISION**: ✅ **Default: Charge Agency Only (Support all 3 options)**

**From Pak Habibi**: "Bisa ada opsi untuk kedua pihak juga oke mas" - System must support charging agency, supplier, or both

**Implementation**:
- Default configs: Charge agency only (simpler for most cases)
- Platform admin can create configs to charge supplier or both
- Priority-based selection (supplier-specific > service-specific > global)

**Default Commission Rates** (from Pak Habibi's data):
```
Hotel: 4.76% from agency (margin 20 riyal out of 420 riyal)
Flight: 5.30% from agency (margin IDR 700k out of IDR 13.2M)
Visa: 3.49% from agency (margin $5 out of $143)
Transport: 4.00% from agency
Guide: 5.00% from agency
Insurance: 3.50% from agency
Catering: 4.50% from agency
Handling: 5.00% from agency
```

**Example - Charge Both (Gojek Model)**:
```
Service Cost: Rp 100,000,000
Agency Commission: 3% = Rp 3,000,000
Supplier Commission: 2% = Rp 2,000,000
Agency Pays: Rp 103,000,000
Supplier Receives: Rp 98,000,000
Platform Earns: Rp 5,000,000
```

---

### Decision 2: Payment Timing - DP vs Pelunasan

**DECISION**: ✅ **DP paid IMMEDIATELY, Pelunasan before H-X**

**From User Clarification**:
- "jika supplier set pakai dp, maka agency harus bayar dp dulu baru statusnya booked"
- "Service supplier tersebut sudah terkunci availibility nya"
- "jika supplier tidak set dp, maka agency harus bayar full baru statusnya PAID"

**Implementation**:
```
Service with Payment Terms:
├─ Agency selects service
├─ Click [Pay DP Now]
├─ DP paid IMMEDIATELY via payment gateway
├─ Availability LOCKED for this agency
├─ Status: "dp_paid"
├─ Pelunasan due date calculated: departure_date - full_payment_due_days
└─ Agency pays pelunasan before H-X → Status: "fully_paid"

Service without Payment Terms:
├─ Agency selects service
├─ Click [Pay Now]
├─ Full payment IMMEDIATELY via payment gateway
└─ Status: "fully_paid"
```

**NO DownPaymentDueDays** - DP always paid immediately when booking

---

### Question 3: Payment Expiry Time

**❓ QUESTION**: Berapa lama payment link valid?

**Options**:
- 24 hours (standard)
- 48 hours
- 72 hours
- Custom per payment type (DP = 24h, Pelunasan = 48h)

**Recommendation**: 24 hours untuk DP, 48 hours untuk Pelunasan

---

### Question 4: Overdue Payment Handling

**❓ QUESTION**: Kalau agency tidak bayar pelunasan sampai H-7, apa yang terjadi?

**Options**:

**A. Auto-cancel booking**
```
H-7 passed, payment not received:
├─ Auto-cancel journey activity
├─ Release availability
├─ Notify agency & supplier
└─ DP tidak di-refund (penalty)
```

**B. Grace period**
```
H-7 passed, payment not received:
├─ Grace period: 3 days
├─ Send urgent notifications
├─ If still not paid after grace → Cancel
└─ DP tidak di-refund
```

**C. Manual handling**
```
H-7 passed, payment not received:
├─ Mark as overdue
├─ Notify platform admin
├─ Platform admin contacts agency
└─ Manual decision (cancel or extend)
```

**Recommendation**: Option B (Grace period 3 days) untuk flexibility

---

### Question 5: Supplier Transfer Timing

**❓ QUESTION**: Kapan platform transfer uang ke supplier?

**Options**:

**A. Immediate (after payment success)**
```
Agency pays → Payment success → Transfer to supplier immediately
Pros: Supplier gets money fast
Cons: Risk if service not executed
```

**B. After service executed**
```
Agency pays → Hold in escrow → Service executed → Transfer to supplier
Pros: Protection for agency
Cons: Supplier waits longer
```

**C. Scheduled (daily/weekly batch)**
```
Agency pays → Hold in platform → Batch transfer every Friday
Pros: Easier reconciliation, lower transfer fees
Cons: Supplier waits for batch schedule
```

**Recommendation**: 
- **DP**: Hold until pelunasan paid (Option B)
- **Pelunasan**: Transfer immediately after payment (Option A)
- Reason: Supplier gets full amount only after both payments complete

---

### Question 6: Failed Payment Handling

**❓ QUESTION**: Kalau payment failed atau expired, apa yang terjadi?

**Options**:

**A. Allow retry unlimited**
```
Payment failed/expired:
├─ Activity stays "unpaid"
├─ Agency can retry anytime
└─ Generate new payment link
```

**B. Limited retries (3x)**
```
Payment failed/expired:
├─ Retry count: 1/3
├─ After 3 failures → Lock activity
└─ Must contact support to unlock
```

**C. Auto-remove service**
```
Payment failed/expired:
├─ Remove service from activity
├─ Release availability
└─ Agency must select new service
```

**Recommendation**: Option A (unlimited retry) untuk flexibility

---

### Decision 3: Payment Expiry Time

**DECISION**: ✅ **24 hours for DP, 48 hours for Pelunasan**

**Rationale**:
- DP: Urgent (locks availability) → 24h expiry
- Pelunasan: Less urgent (already locked) → 48h expiry
- Standard practice in payment gateways

### Decision 4: Overdue Payment Handling

**DECISION**: ✅ **Grace period 3 days, then auto-cancel**

**Implementation**:
```
Pelunasan due date passed:
├─ Grace period: 3 days
├─ Send urgent notifications (daily)
├─ If still not paid after grace period:
│   ├─ Auto-cancel journey activity
│   ├─ Release availability
│   ├─ Notify agency & supplier
│   └─ DP NOT refunded (penalty)
└─ Agency can select new service and pay again
```

### Decision 5: Supplier Transfer Timing

**DECISION**: ✅ **Hold DP until Pelunasan paid, then transfer together**

**Rationale**:
- Protection for agency (in case service not executed)
- Supplier gets full amount at once
- Easier reconciliation

**Implementation**:
```
DP Payment Success:
├─ Platform receives: Rp 78,570,000
├─ Hold in platform account
├─ Status: supplier_transfer_status = "pending"
└─ Wait for pelunasan

Pelunasan Payment Success:
├─ Platform receives: Rp 183,330,000
├─ Calculate total to supplier: Rp 250,000,000
├─ Transfer to supplier: Rp 250,000,000
├─ Update both payments: supplier_transfer_status = "transferred"
└─ Platform keeps commission: Rp 11,900,000
```

**Alternative for No Payment Terms**:
```
Full Payment Success:
├─ Platform receives: Rp 315,900,000
├─ Transfer to supplier immediately: Rp 300,000,000
├─ Platform keeps commission: Rp 15,900,000
└─ Status: supplier_transfer_status = "transferred"
```

### Decision 6: Failed Payment Handling

**DECISION**: ✅ **Unlimited retry with auto-expiry**

**Implementation**:
```
Payment Failed/Expired:
├─ Activity stays "unpaid" or "dp_paid"
├─ Agency can retry anytime
├─ Generate new payment link
├─ No retry limit
└─ Each payment link expires after 24h/48h
```

**No penalty for failed payments** - Only penalty if overdue after grace period

---

## 📋 ALL DECISIONS FINALIZED

**Status**: ✅ **READY FOR IMPLEMENTATION**

1. ✅ Commission: Default agency only, support all 3 options
2. ✅ Commission rates: Hotel 4.76%, Flight 5.30%, Visa 3.49%, etc.
3. ✅ Payment expiry: 24h for DP, 48h for Pelunasan
4. ✅ Overdue handling: 3-day grace period, then auto-cancel
5. ✅ Supplier transfer: Hold DP until pelunasan paid
6. ✅ Failed payment: Unlimited retry
7. ✅ journey_services: DEPRECATED - Use journey_activities only
8. ✅ Booking.package_id: REMOVED - Use journey_id only
9. ✅ Payment timing: Immediate (DP when select, Pelunasan before H-X)

**Skipped** (as per user instruction):
- Refund policy (too complex for now)

---

## 🚀 NEXT STEPS

**Status**: ✅ **ALL DECISIONS FINALIZED - READY FOR IMPLEMENTATION**

### Implementation Order

**Phase 1: Database Schema Updates**
1. ✅ Drop deprecated tables (journey_services, packages, package_services, itineraries)
2. ✅ Update journeys table (add package fields, remove package_id)
3. ✅ Create journey_activities table (with payment tracking fields)
4. ✅ Update bookings table (remove package_id)
5. ✅ Enhance commission_configs table (add service_type, supplier_id, charged_to, priority)
6. ✅ Create payments table (with commission tracking)
7. ✅ Update commission_transactions table (add supplier_id, split agency/supplier commission)

**Phase 2: Backend Implementation**
1. Update Journey entity and DTOs
2. Create JourneyActivity entity and DTOs
3. Update CommissionConfig entity
4. Create Payment entity
5. Implement payment service with commission calculation
6. Implement Xendit integration (invoice creation, webhook handling)
7. Implement supplier transfer service (background job)
8. Update booking flow (remove package dependency)

**Phase 3: Frontend Implementation**
1. Create JourneyFormV2 component (unified form)
2. Create ActivityForm component (with date pickers)
3. Create ServiceSelectionModal component
4. Create PaymentDialog component
5. Update Journey Detail page (show payment status)
6. Create Agency Payment Dashboard
7. Create Supplier Payment Dashboard
8. Create Platform Admin Commission Management

**Phase 4: Testing & Deployment**
1. Test payment flow (DP + Pelunasan)
2. Test commission calculation (all 3 models)
3. Test supplier transfer
4. Test overdue handling
5. Test notification system

---

## 📚 RELATED DOCUMENTS

**Comprehensive Payment Tracking Analysis**:
- See `PAYMENT-TRACKING-COMPREHENSIVE.md` for detailed payment tracking from both agency and supplier perspectives
- Includes: Payment flow lifecycle, dashboard designs, database queries, notifications, edge cases

**Other Requirements**:
- `SUPPLIER-SERVICE-MANAGEMENT-REQUIREMENTS.md` - Service features (enrich info, images, seasonal pricing, availability, payment terms)
- `JOURNEY-REFACTOR-REQUIREMENTS.md` - Journey system refactor (merge Package + Journey + Itinerary)

---

**Document Status**: ✅ **COMPLETE - READY FOR IMPLEMENTATION**  
**All Decisions**: FINALIZED  
**Next Action**: Begin Phase 1 implementation

