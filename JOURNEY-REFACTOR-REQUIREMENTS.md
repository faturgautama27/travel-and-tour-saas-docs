# Journey Refactor - Requirements & Design Document

**Project**: Tour & Travel ERP SaaS  
**Date**: March 18, 2026  
**Status**: Requirements Analysis - Ready for Discussion

---

## 📋 EXECUTIVE SUMMARY

### Current State Problems
1. **Package vs Journey Confusion**: Two separate entities causing user confusion
2. **Itinerary Separation**: Itinerary builder is separate from package/journey creation
3. **Service Selection**: Complex flow for selecting services from marketplace/inventory
4. **Publish Validation**: No validation for availability before publishing

### Proposed Solution
**MERGE Package + Journey + Itinerary → Single "Journey" Entity**

- Deprecate Package entity (frontend & backend)
- Journey becomes the primary entity for tour planning
- Itinerary builder integrated into journey creation
- Unified service selection from marketplace + inventory
- Publish validation requires availability records

---

## 🔍 CURRENT IMPLEMENTATION ANALYSIS

### 1. PROCUREMENT FROM MARKETPLACE ✅

**Status**: **ALREADY WELL IMPLEMENTED**

**Flow**:
```
Marketplace Browse → Add to Cart → Create PO → Supplier Approves → Becomes Agency Inventory
```

**Components**:
- Frontend: `MarketplaceComponent`, `CartReviewComponent`, `PurchaseOrderListComponent`
- Backend: `PurchaseOrder`, `POItem`, `AgencyService` entities

**Entities**:
- `PurchaseOrder`: PO from agency to supplier
- `POItem`: Individual service items in PO with quantity tracking
- `AgencyService`: Inventory created from approved PO items

**Key Features**:
- Service browsing with filters (type, supplier, price, etc.)
- Cart management
- PO creation and tracking
- Inventory management with quota tracking (total, used, available, reserved, sold)

**Verification**: ✅ **NO CHANGES NEEDED** - Procurement flow is solid

---

### 2. PACKAGE ENTITY (Current)

**Entity Structure**:
```csharp
public class Package
{
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public string PackageCode { get; set; }
    public string PackageType { get; set; } // umrah, hajj, halal_tour, general_tour, custom
    public string Name { get; set; }
    public string? Description { get; set; }
    public int DurationDays { get; set; }
    public decimal BaseCost { get; set; }
    public string? MarkupType { get; set; }
    public decimal? MarkupValue { get; set; }
    public decimal SellingPrice { get; set; }
    public string Visibility { get; set; } = "public";
    public string Status { get; set; } = "draft";
    
    // Relations
    public ICollection<PackageService> PackageServices { get; set; }
    public ICollection<Journey> Journeys { get; set; }
    public Itinerary? Itinerary { get; set; }
}
```

**PackageService** (Junction Table):
- Links Package to SupplierService or AgencyService
- Tracks quantity and cost

**Frontend**: `PackageFormComponent`, `PackageListComponent`

**Issues**:
- ❌ Separate from Journey causes confusion
- ❌ Itinerary is linked to Package, not Journey
- ❌ Service selection is basic (no date-based filtering)

---

### 3. JOURNEY ENTITY (Current)

**Entity Structure**:
```csharp
public class Journey
{
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public Guid PackageId { get; set; } // ← Depends on Package
    public string JourneyCode { get; set; }
    public DateTime DepartureDate { get; set; }
    public DateTime ReturnDate { get; set; }
    public int TotalQuota { get; set; }
    public int ConfirmedPax { get; set; }
    public int AvailableQuota { get; set; }
    public string Status { get; set; } // draft, pending_confirmation, published, etc.
    
    // Relations
    public Package Package { get; set; }
    public ICollection<JourneyService> JourneyServices { get; set; }
}
```

**JourneyService**:
- Links Journey to services
- Tracks confirmation status, booking status, execution status

**Frontend**: `JourneyFormComponent`, `JourneyListComponent`

**Issues**:
- ❌ Depends on Package (must create package first)
- ❌ No itinerary builder in journey form
- ❌ Service selection happens at package level, not journey level

---

### 4. ITINERARY ENTITY (Current)

**Entity Structure**:
```csharp
public class Itinerary
{
    public Guid Id { get; set; }
    public Guid PackageId { get; set; } // ← Linked to Package
    
    public ICollection<ItineraryDay> ItineraryDays { get; set; }
}

public class ItineraryDay
{
    public Guid Id { get; set; }
    public Guid ItineraryId { get; set; }
    public int DayNumber { get; set; }
    public string Title { get; set; }
    public string? Description { get; set; }
    
    public ICollection<ItineraryActivity> ItineraryActivities { get; set; }
}

public class ItineraryActivity
{
    public Guid Id { get; set; }
    public Guid DayId { get; set; }
    public TimeSpan? Time { get; set; }
    public string? Location { get; set; }
    public string Activity { get; set; }
    public string? Description { get; set; }
    public string? MealType { get; set; }
}
```

**Frontend**: `ItineraryBuilderComponent`, `ItineraryDayFormComponent`, `ItineraryActivityFormComponent`

**Issues**:
- ❌ Linked to Package, not Journey
- ❌ Activities don't link to actual services
- ❌ No service selection in activity form

---

## 🎯 NEW DESIGN: UNIFIED JOURNEY SYSTEM

### Core Concept

**Journey = Package + Itinerary + Service Selection**

One entity to rule them all:
- Basic info (name, dates, quota, package type)
- Itinerary builder (activities with service selection)
- Pricing calculation
- Publish workflow

---

## 📐 NEW ENTITY STRUCTURE

### Journey (Refactored)

```csharp
public class Journey
{
    // Identity
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public string JourneyCode { get; set; }
    
    // Basic Information (from old Package)
    public string Name { get; set; } // "Paket Umroh 10 Hari Awal November"
    public string? Description { get; set; }
    public string PackageType { get; set; } // umrah, hajj, halal_tour, general_tour, custom
    
    // Schedule
    public DateTime StartDateEstimated { get; set; }
    public int DurationDays { get; set; } // Calculated from activities
    public int Quota { get; set; }
    
    // Pricing (from old Package)
    public decimal BaseCost { get; set; } // Auto-calculated from activities
    public string? MarkupType { get; set; } // percentage, fixed
    public decimal? MarkupValue { get; set; }
    public decimal SellingPrice { get; set; } // Auto-calculated
    
    // Status
    public string Status { get; set; } = "draft"; // draft, published, inactive
    public DateTime? PublishedAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation
    public Agency Agency { get; set; }
    public ICollection<JourneyActivity> JourneyActivities { get; set; }
    public ICollection<Booking> Bookings { get; set; }
}
```

### JourneyActivity (NEW - Replaces ItineraryActivity + Links to Services)

```csharp
public class JourneyActivity
{
    public Guid Id { get; set; }
    public Guid JourneyId { get; set; }
    public int ActivityNumber { get; set; } // Sequence: 1, 2, 3...
    
    // Activity Details
    public DateTime Date { get; set; } // Actual date
    public string Type { get; set; } // hotel, flight, visa, transport, guide, insurance, catering, handling
    public string? Description { get; set; }
    
    // Service Selection (OPTIONAL - activity can exist without service)
    public Guid? SupplierServiceId { get; set; }
    public Guid? AgencyServiceId { get; set; }
    public string? SourceType { get; set; } // supplier, agency
    
    // Date Range (for hotel, transport, guide, catering)
    // These are filled in ACTIVITY FORM before opening service selection modal
    public DateTime? CheckInDate { get; set; }
    public DateTime? CheckOutDate { get; set; }
    
    // Flight-specific (auto-filled from selected service)
    public DateTime? EstimatedTimeDeparture { get; set; }
    public DateTime? EstimatedTimeArrival { get; set; }
    
    // Pricing (quantity ALWAYS equals journey.quota)
    public int Quantity { get; set; } // = Journey.Quota (fixed, no override)
    public decimal? UnitCost { get; set; }
    public decimal? TotalCost { get; set; } // = UnitCost × Quantity
    
    // Payment Tracking (NEW)
    public string PaymentStatus { get; set; } = "unpaid"; // unpaid, paid, reserved
    public Guid? PaymentId { get; set; } // Link to Payment record
    public DateTime? PaidAt { get; set; }
    
    // Availability Tracking (NEW)
    public bool IsServiceAvailable { get; set; } = true; // Check if service still available
    public DateTime? AvailabilityCheckedAt { get; set; }
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation
    public Journey Journey { get; set; }
    public SupplierService? SupplierService { get; set; }
    public AgencyService? AgencyService { get; set; }
    public Payment? Payment { get; set; }
}
```

**Key Features**:
- ✅ 1 Activity = 1 Service (or no service)
- ✅ Quantity fixed to journey quota
- ✅ Date pickers in activity form (not modal)
- ✅ Flight times auto-filled from service
- ✅ Payment status tracking
- ✅ Availability checking

---

## 🎨 NEW FRONTEND FLOW

### Journey Creation Form (Redesigned)

**Section 1: Basic Information**
```typescript
{
  journey_title: string;        // "Paket Umroh 10 Hari Awal November"
  start_date_estimated: Date;   // 15 March 2026
  quota: number;                // 20
  package_type: string;         // umrah, hajj, halal_tour, general_tour, custom
}
```

**Section 2: Itinerary Builder** (Integrated)
- Button: "Add Activity"
- Form Array with activities
- Each activity has:
  - Date (calendar)
  - Type (dropdown: hotel, flight, visa, etc.)
  - Description (textarea)
  - **Select Services** (modal dialog)

**Section 3: Pricing Information**
```typescript
{
  base_price_estimation: number;  // Auto-calculated from activities
  markup_type: string;            // percentage, fixed
  markup_value: number;           // 20 (%)
  selling_price_estimation: number; // Auto-calculated
}
```

---

## 🔌 API ENDPOINTS (NEW)

### Journey Management

**Create Journey**:
```
POST /api/journeys
Body: {
  name: string,
  description?: string,
  package_type: string,
  start_date_estimated: Date,
  quota: number,
  markup_type?: string,
  markup_value?: number
}
Response: JourneyDto
```

**Update Journey**:
```
PUT /api/journeys/{id}
Body: Same as Create (partial update)
Response: JourneyDto
```

**Get Journey with Activities**:
```
GET /api/journeys/{id}
Response: {
  ...JourneyDto,
  activities: JourneyActivityDto[]
}
```

**Publish Journey**:
```
POST /api/journeys/{id}/publish
Response: {
  success: boolean,
  message: string,
  validation_errors?: string[]
}
```

---

### Journey Activity Management

**Add Activity**:
```
POST /api/journeys/{journeyId}/activities
Body: {
  date: Date,
  type: string,
  description?: string,
  supplier_service_id?: Guid,
  agency_service_id?: Guid,
  source_type?: string,
  check_in_date?: Date,
  check_out_date?: Date,
  estimated_time_departure?: DateTime,
  estimated_time_arrival?: DateTime
}
Response: JourneyActivityDto
```

**Update Activity**:
```
PUT /api/journeys/{journeyId}/activities/{activityId}
Body: Same as Add (partial update)
Response: JourneyActivityDto
```

**Delete Activity**:
```
DELETE /api/journeys/{journeyId}/activities/{activityId}
Response: 204 No Content
```

**Reorder Activities**:
```
PUT /api/journeys/{journeyId}/activities/reorder
Body: {
  activity_ids: Guid[] // Ordered array
}
Response: JourneyActivityDto[]
```

---

### Service Selection (NEW)

**Get Available Services for Activity**:
```
GET /api/journeys/available-services
Query Params:
  - type: string (required)
  - date: Date (required)
  - check_in_date?: Date (for hotel, transport, guide, catering)
  - check_out_date?: Date (for hotel, transport, guide, catering)
  - page: number (default 1)
  - page_size: number (default 20)
  
Response: {
  services: AvailableServiceDto[],
  total: number,
  page: number,
  page_size: number
}

AvailableServiceDto: {
  id: Guid,
  source_type: 'supplier' | 'agency',
  service_type: string,
  service_name: string,
  service_details: object, // Parsed JSON
  unit_cost: number,
  total_cost: number, // For date range
  available_quantity?: number, // For inventory
  supplier_name?: string,
  currency: string
}
```

**Logic**:
1. Query SupplierService (published, matching type)
2. Filter by SupplierServiceAvailability (if dates provided)
3. Calculate price from availability/seasonal/base
4. UNION with AgencyService (matching type, available quota > 0)
5. Sort by price or name
6. Paginate results

---

## 📐 DTO STRUCTURES (NEW)

### JourneyDto

```csharp
public class JourneyDto
{
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public string JourneyCode { get; set; }
    
    // Basic Information
    public string Name { get; set; }
    public string? Description { get; set; }
    public string PackageType { get; set; }
    
    // Schedule
    public DateTime StartDateEstimated { get; set; }
    public DateTime EndDateEstimated { get; set; }
    public int DurationDays { get; set; }
    public int Quota { get; set; }
    public int ConfirmedPax { get; set; }
    public int AvailableQuota { get; set; }
    
    // Pricing
    public decimal BaseCost { get; set; }
    public string? MarkupType { get; set; }
    public decimal? MarkupValue { get; set; }
    public decimal SellingPrice { get; set; }
    
    // Metadata
    public string Visibility { get; set; }
    public string Status { get; set; }
    public DateTime? PublishedAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Activities (optional, included in detail endpoint)
    public List<JourneyActivityDto>? Activities { get; set; }
}
```

### JourneyActivityDto

```csharp
public class JourneyActivityDto
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
    public string? ServiceName { get; set; } // Denormalized for display
    
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
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

### CreateJourneyRequest

```csharp
public class CreateJourneyRequest
{
    public string Name { get; set; }
    public string? Description { get; set; }
    public string PackageType { get; set; }
    public DateTime StartDateEstimated { get; set; }
    public int Quota { get; set; }
    public string? MarkupType { get; set; }
    public decimal? MarkupValue { get; set; }
    
    // Activities can be added separately after journey creation
    // Or included here for single-request creation
    public List<CreateJourneyActivityRequest>? Activities { get; set; }
}
```

### CreateJourneyActivityRequest

```csharp
public class CreateJourneyActivityRequest
{
    public DateTime Date { get; set; }
    public string Type { get; set; }
    public string? Description { get; set; }
    public Guid? SupplierServiceId { get; set; }
    public Guid? AgencyServiceId { get; set; }
    public string? SourceType { get; set; }
    public DateTime? CheckInDate { get; set; }
    public DateTime? CheckOutDate { get; set; }
    public DateTime? EstimatedTimeDeparture { get; set; }
    public DateTime? EstimatedTimeArrival { get; set; }
}
```

---

## 🎯 BUSINESS LOGIC

### Auto-Calculations

**1. Activity Quantity**:
```csharp
// When activity is created/updated
activity.Quantity = journey.Quota;
activity.TotalCost = activity.UnitCost * activity.Quantity;
```

**2. Journey Base Cost**:
```csharp
// When activity is added/updated/deleted
journey.BaseCost = journey.Activities
    .Where(a => a.TotalCost.HasValue)
    .Sum(a => a.TotalCost.Value);
```

**3. Journey Selling Price**:
```csharp
// When base cost or markup changes
if (journey.MarkupType == "percentage")
{
    journey.SellingPrice = journey.BaseCost * (1 + journey.MarkupValue / 100);
}
else if (journey.MarkupType == "fixed")
{
    journey.SellingPrice = journey.BaseCost + journey.MarkupValue;
}
else
{
    journey.SellingPrice = journey.BaseCost;
}
```

**4. Journey Duration**:
```csharp
// When activities are added/updated
if (journey.Activities.Any())
{
    var minDate = journey.Activities.Min(a => a.Date);
    var maxDate = journey.Activities.Max(a => a.Date);
    journey.DurationDays = (maxDate - minDate).Days + 1;
    journey.EndDateEstimated = maxDate;
}
```

### Validation Rules

**Journey Validation**:
- Name: Required, min 3 chars
- PackageType: Required, must be valid type
- StartDateEstimated: Required, cannot be in past
- Quota: Required, min 1
- MarkupValue: If provided, must be >= 0
- SellingPrice: Must be >= BaseCost

**Activity Validation**:
- Date: Required, must be >= journey.StartDateEstimated
- Type: Required, must be valid service type
- Service Selection: If type requires service, must have supplier_service_id OR agency_service_id
- Check-in/out: If type is hotel/transport/guide/catering, check_out_date must be > check_in_date
- Quantity: Must equal journey.Quota (enforced automatically)

**Publish Validation**:
```csharp
public bool CanPublish(Journey journey)
{
    // Must have at least 1 activity
    if (!journey.Activities.Any())
        return false;
    
    // All service-based activities must have service selected
    var serviceTypes = new[] { "hotel", "flight", "visa", "transport", "guide", "insurance", "catering", "handling" };
    var serviceActivities = journey.Activities.Where(a => serviceTypes.Contains(a.Type));
    
    foreach (var activity in serviceActivities)
    {
        if (activity.SupplierServiceId == null && activity.AgencyServiceId == null)
            return false; // Service required but not selected
    }
    
    return true;
}
```

---

## 🎯 SERVICE SELECTION FLOW (DETAILED)

### Activity Form Layout

**For ALL Activity Types**:
```
Activity [1]                                    [Remove]
┌─────────────────────────────────────────────────────┐
│ Date: [15 Maret 2026]                              │
│ Type: [Flight ▼]                                   │
│ Description: [Flight to Jeddah]                    │
│                                                     │
│ [Conditional Fields Based on Type - See below]     │
│                                                     │
│ [Select Services] ← Opens modal                    │
│                                                     │
│ [Selected Service Display - If service selected]   │
└─────────────────────────────────────────────────────┘
```

### Conditional Fields by Type

**Group A: Hotel, Transport, Guide, Catering**
```
Activity Form Shows:
├─ Date: [Calendar]
├─ Type: [Dropdown]
├─ Description: [Textarea]
├─ Check-in Date: [Calendar] ← REQUIRED before select services
├─ Check-out Date: [Calendar] ← REQUIRED before select services
└─ [Select Services] ← Disabled until dates filled

When "Select Services" clicked:
→ Modal receives: type, check_in_date, check_out_date
→ Modal filters services by type and date range
→ User selects service
→ Modal closes
→ Activity form shows selected service info
```

**Group B: Flight**
```
Activity Form Shows:
├─ Date: [Calendar]
├─ Type: [Dropdown]
├─ Description: [Textarea]
└─ [Select Services] ← No date pickers above

When "Select Services" clicked:
→ Modal receives: type, activity_date
→ Modal shows flight services
→ User selects service
→ Modal closes
→ Activity form AUTO-FILLS:
   ├─ Estimated Time Departure: [15 March 2026 10:00 AM]
   └─ Estimated Time Arrival: [15 March 2026 19:00 PM]
   (These fields shown BELOW select services button)
```

**Group C: Visa, Insurance, Handling**
```
Activity Form Shows:
├─ Date: [Calendar]
├─ Type: [Dropdown]
├─ Description: [Textarea]
└─ [Select Services] ← No extra fields

When "Select Services" clicked:
→ Modal receives: type, activity_date
→ Modal shows services filtered by type
→ User selects service
→ Modal closes
→ Activity form shows selected service info
```

### Service Selection Modal Structure

**Modal Header**:
```
Select Service - [Hotel]
[Search: ___________] [🔍]
```

**Modal Body** (for Group A - with dates):
```
Showing services available from 15 Mar - 20 Mar

[Service Card 1]
┌─────────────────────────────────────────┐
│ Hotel Grand Makkah 5 Star - Deluxe Twin│
│ [Supplier: Makkah Hotels Ltd]          │
│                                         │
│ Details:                                │
│ • Property: Hotel Grand Makkah          │
│ • Star Rating: 5 Stars                  │
│ • Room Type: Deluxe                     │
│ • Bed Configuration: Twin Bed           │
│                                         │
│ Price: Rp 2.500.000 / room / night     │
│ Total: Rp 12.500.000 (5 nights)        │
│                                         │
│ [Select This Service]                   │
└─────────────────────────────────────────┘

[Service Card 2]
┌─────────────────────────────────────────┐
│ Hotel Al Shohada 4 Star - Superior     │
│ [Your Inventory - 15 rooms available]  │
│                                         │
│ Details:                                │
│ • Property: Hotel Al Shohada            │
│ • Star Rating: 4 Stars                  │
│ • Room Type: Superior                   │
│                                         │
│ Price: Rp 2.000.000 / room / night     │
│ Total: Rp 10.000.000 (5 nights)        │
│                                         │
│ [Select This Service]                   │
└─────────────────────────────────────────┘

[Load More...] (Pagination)
```

**Modal Footer**:
```
[Cancel]
```

### Service Details Display Format

**Parse from service_details JSON**:
```typescript
// For Hotel
{
  propertyName: "Hotel Grand Makkah",
  starRating: 5,
  roomType: "Deluxe",
  bedConfiguration: "Twin Bed",
  mealPlan: "Breakfast Included"
}

// For Flight
{
  airline: "Garuda Indonesia",
  flightClass: "Business",
  departureAirport: "CGK",
  arrivalAirport: "JED",
  estimatedDuration: "9h 30m"
}

// For Transport
{
  vehicleType: "Bus",
  brand: "Mercedes-Benz",
  model: "Sprinter",
  capacity: "45 passengers"
}
```

Display as bullet points in service card.

---

## 🗄️ DATABASE CHANGES (FINALIZED)

### STEP 1: DATA CLEANUP (FRESH START)

```sql
-- Delete all journey/package related data
TRUNCATE TABLE journey_services CASCADE;
TRUNCATE TABLE journeys CASCADE;
TRUNCATE TABLE package_services CASCADE;
TRUNCATE TABLE packages CASCADE;
TRUNCATE TABLE itinerary_activities CASCADE;
TRUNCATE TABLE itinerary_days CASCADE;
TRUNCATE TABLE itineraries CASCADE;

-- Delete procurement/inventory data
TRUNCATE TABLE agency_services CASCADE;
TRUNCATE TABLE po_items CASCADE;
TRUNCATE TABLE purchase_orders CASCADE;

-- Keep: suppliers, supplier_services, agencies, users, bookings, etc.
```

### STEP 2: DROP OLD TABLES

```sql
-- Drop Package system completely
DROP TABLE IF EXISTS package_services CASCADE;
DROP TABLE IF EXISTS packages CASCADE;

-- Drop old Itinerary system completely
DROP TABLE IF EXISTS itinerary_activities CASCADE;
DROP TABLE IF EXISTS itinerary_days CASCADE;
DROP TABLE IF EXISTS itineraries CASCADE;

-- Drop old JourneyService (replaced by JourneyActivity)
DROP TABLE IF EXISTS journey_services CASCADE;
```

### STEP 3: REFACTOR JOURNEY TABLE

```sql
-- Add Package fields to Journey
ALTER TABLE journeys
ADD COLUMN name VARCHAR(255) NOT NULL DEFAULT '',
ADD COLUMN description TEXT,
ADD COLUMN package_type VARCHAR(50) NOT NULL DEFAULT 'custom',
ADD COLUMN duration_days INT NOT NULL DEFAULT 1,
ADD COLUMN base_cost DECIMAL(18,2) NOT NULL DEFAULT 0,
ADD COLUMN markup_type VARCHAR(20),
ADD COLUMN markup_value DECIMAL(18,2),
ADD COLUMN selling_price DECIMAL(18,2) NOT NULL DEFAULT 0,
ADD COLUMN visibility VARCHAR(20) NOT NULL DEFAULT 'public';

-- Remove package dependency
ALTER TABLE journeys DROP COLUMN IF EXISTS package_id;

-- Rename columns for clarity
ALTER TABLE journeys RENAME COLUMN departure_date TO start_date_estimated;
ALTER TABLE journeys RENAME COLUMN return_date TO end_date_estimated;
ALTER TABLE journeys RENAME COLUMN total_quota TO quota;

-- Simplify status (keep only: draft, published, inactive)
-- Remove old statuses: planning, pending_confirmation, partially_confirmed, all_confirmed, upcoming, ongoing, completed, cancelled
```

### STEP 4: CREATE JOURNEY_ACTIVITIES TABLE

```sql
CREATE TABLE journey_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journey_id UUID NOT NULL REFERENCES journeys(id) ON DELETE CASCADE,
    activity_number INT NOT NULL,
    
    -- Activity Details
    date DATE NOT NULL,
    type VARCHAR(50) NOT NULL, -- hotel, flight, visa, transport, guide, insurance, catering, handling
    description TEXT,
    
    -- Service Selection (OPTIONAL - can be NULL for free activities)
    supplier_service_id UUID REFERENCES supplier_services(id) ON DELETE SET NULL,
    agency_service_id UUID REFERENCES agency_services(id) ON DELETE SET NULL,
    source_type VARCHAR(20), -- supplier, agency, null
    
    -- Date Range (for hotel, transport, guide, catering)
    -- Filled in activity form BEFORE opening service selection modal
    check_in_date DATE,
    check_out_date DATE,
    
    -- Flight-specific (auto-filled from selected service)
    estimated_time_departure TIMESTAMP,
    estimated_time_arrival TIMESTAMP,
    
    -- Pricing (quantity ALWAYS = journey.quota, no override)
    quantity INT NOT NULL DEFAULT 1,
    unit_cost DECIMAL(18,2),
    total_cost DECIMAL(18,2), -- = unit_cost × quantity
    
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_journey_activity_number UNIQUE (journey_id, activity_number),
    CONSTRAINT check_service_selection CHECK (
        (supplier_service_id IS NOT NULL AND agency_service_id IS NULL) OR
        (supplier_service_id IS NULL AND agency_service_id IS NOT NULL) OR
        (supplier_service_id IS NULL AND agency_service_id IS NULL)
    )
);

CREATE INDEX idx_journey_activities_journey_id ON journey_activities(journey_id);
CREATE INDEX idx_journey_activities_date ON journey_activities(date);
CREATE INDEX idx_journey_activities_type ON journey_activities(type);
```

**Key Constraints**:
- Unique activity number per journey
- Can have supplier service OR agency service OR no service (free activity)
- Quantity synced with journey quota (enforced in application layer)

---

## 🎨 NEW FRONTEND COMPONENTS

### 1. JourneyFormV2Component (Redesigned)

**Location**: `src/app/features/agency/components/journey-form-v2/`

**Sections**:
1. Basic Information
2. Itinerary Builder (integrated)
3. Pricing Information

**Features**:
- Single form for complete journey creation
- Inline itinerary builder
- Service selection modal with smart filtering
- Auto-calculation of base cost and selling price
- Publish validation

---

### 2. ActivityFormComponent (NEW)

**Location**: `src/app/features/agency/components/activity-form/`

**Fields**:
- Activity Number (auto)
- Date (calendar)
- Type (dropdown)
- Description (textarea)
- Select Services (button → opens modal)
- Conditional fields based on type:
  - Hotel/Transport/Guide/Catering: Check-in/out dates
  - Flight: Departure/arrival times (auto-filled)

---

### 3. ServiceSelectionModalComponent (NEW)

**Location**: `src/app/shared/components/service-selection-modal/`

**Props**:
```typescript
@Input() serviceType: string;
@Input() activityDate: Date;
@Input() checkInDate?: Date;  // For hotel, transport, guide, catering
@Input() checkOutDate?: Date;  // For hotel, transport, guide, catering
@Input() journeyQuota: number; // For quantity calculation
@Output() serviceSelected = new EventEmitter<SelectedService>();
```

**Display Info** (Minimal):
- Service name
- Service details (parsed from service_details JSON)
- Price (calculated from availability/seasonal)
- Source badge ("Supplier X" / "Your Inventory")

**DON'T Display**:
- ❌ Service images (keep modal lightweight)
- ❌ Supplier name (only show in source badge)

**Features**:
- Smart filtering based on service type and dates
- Shows services from:
  - Marketplace (SupplierService with availability)
  - Agency Inventory (AgencyService with available quota)
- Search and filter
- Pagination
- Single selection (not multi-select)

---

## 🔄 USER FLOW (NEW)

### Creating a Journey

**Step 1: Basic Information**
```
Journey Title: "Paket Umroh 10 Hari Awal November"
Start Date: 15 March 2026
Quota: 20
Package Type: Umrah
```

**Step 2: Build Itinerary**

Click "Add Activity" → Opens activity form

**Activity 1: Flight Departure**
```
Date: 15 March 2026
Type: Flight
Description: "Flight to Jeddah"
Select Services: [Click] → Modal opens
  → Shows flight services
  → Select: "Garuda Indonesia Business Class CGK-JED"
  → Auto-fills:
     - Estimated Time Departure: 15 March 2026 10:00 AM
     - Estimated Time Arrival: 15 March 2026 19:00 PM
```

**Activity 2: Hotel Check-in**
```
Date: 15 March 2026
Type: Hotel
Description: "Check-in Hotel Grand Makkah"

[ACTIVITY FORM - User fills these FIRST]
Check-in Date: 15 March 2026
Check-out Date: 20 March 2026

Select Services: [Click] → Modal opens
  → Modal receives check-in/out dates from activity form
  → Shows hotel services available for 15-20 March
  → Select: "Hotel Grand Makkah 5 Star - Deluxe Twin"
  → Service selected, modal closes
  → Activity form now shows selected service info
```

**Activity 3: Transport**
```
Date: 16 March 2026
Type: Transport
Description: "Transport to Masjid Nabawi"

[ACTIVITY FORM - User fills these FIRST]
Check-in Date: 16 March 2026 08:00
Check-out Date: 16 March 2026 18:00

Select Services: [Click] → Modal opens
  → Modal receives dates from activity form
  → Shows transport services
  → Select: "Bus Mercedes 45 Seats"
```

**Activity 4: Free Time** (No Service)
```
Date: 17 March 2026
Type: (none - free activity)
Description: "Free time for shopping"

[No Select Services button]
[No pricing - this is free activity]
```

**Step 3: Review Pricing**
```
Activity 1 (Flight): Rp 3.000.000 × 20 = Rp 60.000.000
Activity 2 (Hotel): Rp 2.500.000 × 20 = Rp 50.000.000
Activity 3 (Transport): Rp 5.000.000 × 20 = Rp 100.000.000
Activity 4 (Free Time): Rp 0
---
Base Price Estimation: Rp 210.000.000 (auto-calculated, can be edited)
Markup Type: Percentage
Markup Value: 20%
Selling Price Estimation: Rp 252.000.000 (auto-calculated)
```

**Step 4: Save as Draft**
- Journey saved with status = "draft"
- **REDIRECT to Journey Detail page** (NOT back to list)
- Journey Detail shows itinerary with payment status

**Step 5: Payment Workflow** (for services not in inventory)
- Journey Detail page shows itinerary builder
- Each activity shows:
  - Service info (read-only labels)
  - Payment status badge
  - Action buttons based on status

**Activity Payment States**:

**State 1: UNPAID** (service from marketplace, not paid yet)
```
Activity 1: Flight to Jeddah
Service: Garuda Indonesia Business Class CGK-JED
Source: Supplier (Garuda Indonesia)
Status: [UNPAID - Red Badge]
Actions: [Pay Now] [Change Service]
```

**State 2: NOT AVAILABLE** (service booked by other agency)
```
Activity 2: Hotel Grand Makkah
Service: Hotel Grand Makkah 5 Star - Deluxe Twin
Source: Supplier (Makkah Hotels)
Status: [NOT AVAILABLE - Orange Badge]
Actions: [Change Service] (only this button)
```

**State 3: PAID** (payment completed)
```
Activity 3: Transport Bus
Service: Bus Mercedes 45 Seats
Source: Supplier (Transport Co)
Status: [PAID - Green Badge]
Actions: [View Payment Receipt]
```

**State 4: FROM INVENTORY** (using agency's own inventory)
```
Activity 4: Guide Service
Service: Arabic-English Guide
Source: Your Inventory
Status: [RESERVED - Blue Badge]
Actions: (no buttons needed, already owned)
```

**Step 6: Publish** (when all services paid/reserved)
- All activities must be PAID or FROM INVENTORY
- Click "Publish" button
- Validation:
  - ✅ Has at least 1 activity
  - ✅ All service-based activities have services selected
  - ✅ All marketplace services are PAID
- If valid → Status = "published"
- Now visible in marketplace for booking

---

## 🎯 KEY IMPROVEMENTS

### 1. Simplified Mental Model
- ❌ Old: Create Package → Add Services → Create Journey → Build Itinerary
- ✅ New: Create Journey (all-in-one)

### 2. Date-Aware Service Selection
- Services filtered by availability dates
- Real-time price calculation based on dates
- Shows only available services

### 3. Integrated Itinerary
- Build itinerary while creating journey
- Activities directly linked to services
- No separate itinerary management

### 4. Smart Validation
- Cannot publish without activities
- Cannot publish without service selection
- Clear validation messages

---

## 📊 DATA MIGRATION STRATEGY

### Phase 1: Add New Columns to Journey
- Add Package fields to Journey table
- Keep Package table for backward compatibility

### Phase 2: Create JourneyActivity Table
- New table for activities
- Migrate data from Itinerary → JourneyActivity (if needed)

### Phase 3: Deprecate Package
- Mark Package as obsolete in code
- Add deprecation warnings
- Existing packages still work (read-only)

### Phase 4: Clean Up (Future)
- After all agencies migrated
- Drop Package, Itinerary tables
- Remove deprecated code

---

## ✅ DESIGN DECISIONS (FINALIZED)

### 1. Data Migration Strategy
**DECISION**: **CLEAN SLATE** - Delete all existing data
- Drop all Package records
- Drop all Journey records
- Drop all PO and Inventory records
- Fresh start with new structure
- No migration scripts needed

### 2. Activity-Service Relationship
**DECISION**: **1 Activity = 1 Service OR No Service**
- Each activity can have max 1 service
- Activity can exist without service (e.g., free time, prayer time)
- For multiple services, create multiple activities

### 3. Service Selection Date Pickers
**DECISION**: **Option B - Date Pickers in Activity Form**
- Check-in/out dates shown in activity form (BEFORE clicking select services)
- User fills dates first → Then clicks "Select Services"
- Modal shows services filtered by those dates
- Applies to: hotel, transport, guide, catering

### 4. Activity Quantity
**DECISION**: **Fixed Quantity = Journey Quota**
- Activity quantity ALWAYS equals journey quota
- No manual override per activity
- Simplifies calculation and inventory management
- Example: Journey quota = 20 → All activities quantity = 20

### 5. Base Cost Calculation
**DECISION**: **Auto-Calculate with Manual Override**
- Auto: SUM(activity.unit_cost × activity.quantity)
- User can manually edit base_cost if needed
- Selling price recalculates when base_cost changes

### 6. Journey Images
**DECISION**: **No Journey Images**
- Journey doesn't need separate images
- Service images are sufficient
- Reduces complexity

### 7. Publish Validation
**DECISION**: **Payment-Based Validation**
- ✅ MUST: Has at least 1 activity
- ✅ MUST: All service-based activities have services selected
- ✅ MUST: All marketplace services are PAID (payment_status = 'paid')
- ✅ MUST: All services are AVAILABLE (is_service_available = true)
- ✅ ALLOW: Inventory services (payment_status = 'reserved', no payment needed)
- ❌ NOT REQUIRED: Journey images

**Payment Status Types**:
- `unpaid`: Service from marketplace, not paid yet
- `paid`: Service from marketplace, payment completed
- `reserved`: Service from agency inventory (no payment needed)

### 8. Service Selection Modal Display
**DECISION**: **Minimal Info Display**
- Show: Service name, price, source badge, service details
- DON'T show: Service images, supplier name
- Keep it simple and fast

---

## 🎯 TECHNICAL DECISIONS (FINALIZED)

### 1. Package Table Handling
**DECISION**: **DELETE COMPLETELY**
- Drop Package table and all related data
- Drop PackageService junction table
- Remove Package from codebase
- Clean slate approach

### 2. Itinerary Table Handling
**DECISION**: **DELETE COMPLETELY**
- Drop Itinerary, ItineraryDay, ItineraryActivity tables
- Replace with JourneyActivity table
- Simpler structure, better performance

### 3. Frontend Route Changes
**OLD** (Deprecated):
- `/agency/packages/*` - Remove completely
- `/agency/journeys/create` - Old journey form

**NEW**:
- `/agency/journeys` - Journey list
- `/agency/journeys/create` - New unified journey form
- `/agency/journeys/:id` - Journey detail
- `/agency/journeys/:id/edit` - Edit journey

### 4. API Endpoint Changes
**REMOVE**:
- `POST /api/packages` - Delete
- `GET /api/packages` - Delete
- All package-related endpoints

**UPDATE**:
- `POST /api/journeys` - No longer requires package_id
- Journey becomes standalone entity

### 5. Data Cleanup
**DECISION**: **Fresh Start**
- Truncate tables: packages, package_services, journeys, journey_services
- Truncate tables: purchase_orders, po_items, agency_services
- Truncate tables: itineraries, itinerary_days, itinerary_activities
- Keep: suppliers, supplier_services, agencies, users
- Reason: Clean implementation without legacy data constraints

---

## 📱 WIREFRAME ANALYSIS

### From Your Wireframe

**Basic Information Section**: ✅ Clear
- Journey Title
- Start Date, Quota (side by side)
- Package Type (button group)

**Itinerary Builder Section**: ✅ Good approach
- "Add Activity" button
- Form array for activities
- Each activity shows:
  - Activity number
  - Date, Type
  - Description
  - Select Services (with modal)
  - Conditional fields (check-in/out or departure/arrival)

**Pricing Information Section**: ✅ Standard
- Base Price Estimation (auto)
- Markup Type, Markup Value
- Selling Price Estimation (auto)

**Improvements Suggested**:
1. Add "Remove Activity" button per activity
2. Add drag-to-reorder for activities
3. Show activity cost breakdown
4. Add validation indicators per activity
5. Show total activities count

---

## 🚀 IMPLEMENTATION PHASES (UPDATED)

### Phase 1: Database Cleanup & Refactoring
**Goal**: Clean slate and prepare new structure

**Tasks**:
1. Backup existing data (if needed for reference)
2. Truncate all journey/package/procurement data
3. Drop Package, Itinerary, JourneyService tables
4. Refactor Journey table (add Package fields)
5. Create JourneyActivity table
6. Update Entity Framework models

**Duration**: 2-3 days

---

### Phase 2: Backend API Refactoring
**Goal**: Update Journey API to be standalone

**Tasks**:
1. Update Journey entity and DTOs
2. Create JourneyActivity entity and DTOs
3. Remove Package controllers and services
4. Update Journey commands (Create, Update)
5. Create JourneyActivity commands (Add, Update, Delete, Reorder)
6. Update queries to include activities
7. Add publish validation logic

**Duration**: 5-7 days

---

### Phase 3: Service Selection Modal
**Goal**: Build smart service selection with date filtering

**Tasks**:
1. Create ServiceSelectionModalComponent
2. Implement 3 variants:
   - Date range variant (hotel, transport, guide, catering)
   - Flight variant (with time display)
   - Simple variant (visa, insurance, handling)
3. Integrate with SupplierServiceAvailability API
4. Show marketplace + inventory union
5. Display minimal service info (name, details, price, source)
6. Add search and pagination

**Duration**: 5-7 days

---

### Phase 4: Journey Form V2
**Goal**: Build unified journey creation form

**Tasks**:
1. Create JourneyFormV2Component
2. Basic Information section
3. Itinerary Builder section (form array)
4. Activity form with conditional fields:
   - Date picker
   - Type dropdown
   - Description
   - Check-in/out dates (for Group A types)
   - Select Services button
5. Connect service selection modal
6. Auto-calculate pricing (base cost, selling price)
7. Allow manual override of base cost
8. Add/remove/reorder activities
9. Form validation

**Duration**: 7-10 days

---

### Phase 5: Journey List & Publish
**Goal**: Update journey list and add publish workflow

**Tasks**:
1. Update JourneyListComponent
2. Remove Package references
3. Add "Publish" button for draft journeys
4. Create publish validation
5. Update journey detail view
6. Add activity list display
7. Update journey status management

**Duration**: 3-5 days

---

### Phase 6: Frontend Cleanup
**Goal**: Remove Package components and routes

**Tasks**:
1. Delete PackageFormComponent
2. Delete PackageListComponent
3. Remove package routes
4. Update navigation menu
5. Update breadcrumbs
6. Remove package store/state
7. Clean up unused imports

**Duration**: 2-3 days

---

## 🎯 TOTAL ESTIMATED EFFORT (UPDATED)

- **Backend**: 7-10 days
- **Frontend**: 17-25 days
- **Testing**: 3-5 days
- **Total**: 27-40 days (5-8 weeks)

**Reduced from original estimate** because:
- No migration scripts needed (clean slate)
- No backward compatibility required
- Simpler validation (no availability check)
- No journey images feature

---

## ⚠️ RISKS & MITIGATION (UPDATED)

### Risk 1: Data Loss
**Risk**: All existing data will be deleted
**Mitigation**: 
- ✅ ACCEPTED - Fresh start approach
- Create backup SQL dump before cleanup (for reference only)
- Document the cleanup process
- No rollback plan needed (clean slate decision)

### Risk 2: Service Availability Not Ready
**Risk**: SupplierServiceAvailability feature not implemented yet
**Mitigation**:
- Implement Supplier Service features FIRST (Phase 1-4 from previous doc)
- Journey refactor depends on availability system
- Test availability API thoroughly before journey integration

### Risk 3: Service Selection Complexity
**Risk**: Date-based filtering too complex, performance issues
**Mitigation**:
- Efficient database queries with indexes
- Pagination in modal (20 items per page)
- Cache availability data on frontend
- Fallback: If no availability data, show all services

### Risk 4: Quantity Sync Issues
**Risk**: Activity quantity out of sync with journey quota
**Mitigation**:
- Enforce in application layer (not just database)
- Auto-update all activity quantities when journey quota changes
- Add database trigger to sync quantities
- Validation before save

---

## 📋 DEPENDENCIES & PREREQUISITES

### Must Complete BEFORE Journey Refactor:

1. ✅ **Supplier Service Enrich Information** (Backend refactoring)
   - Remove hardcoded fields from SupplierService
   - Use service_details JSON field

2. ✅ **Supplier Service Availability Management**
   - Create SupplierServiceAvailability table
   - Implement availability API endpoints
   - Frontend availability management component

3. ✅ **Supplier Service Image Upload**
   - Create SupplierServiceImage table
   - Implement image upload API
   - Frontend image management component

**Reason**: Journey service selection depends on these features

---

## 📋 IMPLEMENTATION ORDER

### CORRECT ORDER:
```
1. Supplier Service Backend Refactoring (1-2 weeks)
2. Supplier Service Availability System (2-3 weeks)
3. Supplier Service Image Upload (1-2 weeks)
4. Journey Refactor (5-8 weeks)
---
TOTAL: 9-15 weeks
```

### WRONG ORDER (Don't do this):
```
❌ Journey Refactor first → Service selection won't work
❌ Skip availability system → Can't filter by dates
❌ Parallel implementation → Integration nightmare
```

---

## 📋 NEXT STEPS (FINALIZED)

### Immediate Actions:

1. ✅ **Review Documents** - Confirm all requirements correct
2. ✅ **Create Specs** - Break down into implementable tasks

### Implementation Sequence:

**PHASE A: Supplier Service Features** (Prerequisites)
1. Spec: Backend Refactoring (Remove hardcoded fields)
2. Spec: Service Availability Management
3. Spec: Service Image Upload
4. Spec: Service Publishing Workflow

**PHASE B: Journey Refactor** (Main Work)
5. Spec: Database Cleanup & Journey Refactoring
6. Spec: Backend Journey API Refactoring
7. Spec: Service Selection Modal Component
8. Spec: Journey Form V2 Component
9. Spec: Journey List & Publish Workflow
10. Spec: Frontend Cleanup (Remove Package)

### Timeline:
- Phase A: 4-7 weeks
- Phase B: 5-8 weeks
- **Total**: 9-15 weeks

---

## 📝 FINAL NOTES

### What We Achieved:
- ✅ Analyzed current Package/Journey/Itinerary structure
- ✅ Identified problems and confusion points
- ✅ Designed unified Journey system
- ✅ Finalized all technical decisions
- ✅ Created implementation roadmap

### What's Clear:
- Clean slate approach (delete all data)
- 1 Activity = 1 Service (or no service)
- Quantity fixed to journey quota
- Date pickers in activity form (Option B)
- Auto-calculate pricing with manual override
- No journey images
- Minimal publish validation
- Service modal shows minimal info

### Ready for Specs:
- All requirements documented
- All decisions finalized
- Dependencies identified
- Implementation order clear

---

**Document Version**: 2.0 (Finalized)  
**Last Updated**: March 18, 2026  
**Author**: Kiro AI Assistant  
**Reviewed By**: Fatur Gautama  
**Status**: ✅ APPROVED - Ready for Spec Creation


---

## 💳 PAYMENT WORKFLOW (NEW REQUIREMENT)

### Overview

**Problem**: Agency selects services from marketplace (not inventory) → Need to pay supplier

**Solution**: Integrated payment workflow in journey detail page

---

### Payment States & Actions

**State Machine**:
```
UNPAID → (Pay Now) → PAID → (View Receipt)
   ↓
(Change Service) → Select new service → UNPAID
```

### Activity Payment Status

**1. UNPAID** (Marketplace service, not paid)
- Badge: Red "UNPAID"
- Buttons: [Pay Now] [Change Service]
- Action: Pay Now → Opens payment dialog

**2. PAID** (Payment completed)
- Badge: Green "PAID"
- Buttons: [View Payment Receipt]
- Action: View Receipt → Opens receipt modal/PDF

**3. RESERVED** (From inventory)
- Badge: Blue "RESERVED"
- Buttons: (none needed)
- Info: "Using your inventory"

**4. NOT AVAILABLE** (Service booked by others)
- Badge: Orange "NOT AVAILABLE"
- Buttons: [Change Service] (only this)
- Action: Change Service → Opens service selection modal

---

### Journey Detail Page Layout

**After Journey Created** (Redirect here, not to list):

```
┌─────────────────────────────────────────────────────┐
│ Journey Detail: Paket Umroh 10 Hari Awal November  │
│ Status: [DRAFT]                                     │
│                                                     │
│ [Edit Journey] [Publish Journey]                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Basic Information (Read-only labels)                │
│ • Journey Title: Paket Umroh 10 Hari Awal November │
│ • Start Date: 15 March 2026                        │
│ • Quota: 20 pax                                    │
│ • Package Type: Umrah                              │
│ • Base Cost: Rp 210.000.000                        │
│ • Selling Price: Rp 252.000.000                    │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Itinerary Builder                                   │
│                                                     │
│ Activity 1 - 15 March 2026                         │
│ ├─ Type: Flight                                    │
│ ├─ Description: Flight to Jeddah                   │
│ ├─ Service: Garuda Indonesia Business CGK-JED     │
│ ├─ Source: Supplier (Garuda Indonesia)            │
│ ├─ Departure: 15 Mar 2026 10:00 AM                │
│ ├─ Arrival: 15 Mar 2026 19:00 PM                  │
│ ├─ Cost: Rp 3.000.000 × 20 = Rp 60.000.000       │
│ ├─ Status: [UNPAID]                               │
│ └─ Actions: [Pay Now] [Change Service]            │
│                                                     │
│ Activity 2 - 15 March 2026                         │
│ ├─ Type: Hotel                                     │
│ ├─ Description: Check-in Hotel Grand Makkah       │
│ ├─ Service: Hotel Grand Makkah 5 Star             │
│ ├─ Source: Your Inventory                         │
│ ├─ Check-in: 15 Mar 2026                          │
│ ├─ Check-out: 20 Mar 2026                         │
│ ├─ Cost: Rp 2.500.000 × 20 = Rp 50.000.000       │
│ ├─ Status: [RESERVED]                             │
│ └─ Actions: (none - using inventory)              │
│                                                     │
│ Activity 3 - 16 March 2026                         │
│ ├─ Type: Transport                                 │
│ ├─ Description: Transport to Masjid Nabawi        │
│ ├─ Service: Bus Mercedes 45 Seats                 │
│ ├─ Source: Supplier (Transport Co)                │
│ ├─ Status: [NOT AVAILABLE]                        │
│ └─ Actions: [Change Service]                      │
└─────────────────────────────────────────────────────┘

[Back to List]
```

---

### Payment Dialog (Pay Now)

**Triggered by**: Click "Pay Now" button on unpaid activity

**Dialog Content**:
```
┌─────────────────────────────────────────┐
│ Payment for Activity                    │
│                                         │
│ Service: Garuda Indonesia Business      │
│ Quantity: 20 seats                      │
│ Unit Price: Rp 3.000.000               │
│ Total Amount: Rp 60.000.000            │
│                                         │
│ Payment Method:                         │
│ ○ Bank Transfer                         │
│ ○ Credit Card                           │
│ ○ Virtual Account                       │
│                                         │
│ [Cancel] [Proceed to Payment]          │
└─────────────────────────────────────────┘
```

**After Payment**:
- Payment gateway integration (Midtrans, Xendit, etc.)
- Payment record created
- Activity payment_status → "paid"
- Activity payment_id → payment record ID
- Activity paid_at → timestamp
- Redirect back to journey detail
- Show success notification

---

### Change Service Dialog

**Triggered by**: Click "Change Service" button

**Dialog Content**:
- Same as service selection modal during creation
- Filtered by activity type and dates
- Shows available services only
- Select new service → Update activity
- If new service from marketplace → payment_status = "unpaid"
- If new service from inventory → payment_status = "reserved"

---

### View Payment Receipt

**Triggered by**: Click "View Payment Receipt" button on paid activity

**Options**:
- A: Open modal with payment details
- B: Download PDF receipt
- C: Redirect to payment detail page

**Receipt Content**:
- Payment ID
- Date & Time
- Service details
- Amount paid
- Payment method
- Transaction ID
- Status

---

## 🔄 JOURNEY STATUS FLOW (UPDATED)

### Status Definitions

**draft**: Journey created, activities being configured, payments pending
**published**: All services paid/reserved, visible in marketplace for booking
**inactive**: Journey unpublished or deactivated

### Status Transitions

```
CREATE JOURNEY
    ↓
status = "draft"
    ↓
ADD ACTIVITIES
    ↓
SELECT SERVICES
    ↓
PAY FOR MARKETPLACE SERVICES ← NEW STEP
    ↓
(All services PAID or RESERVED)
    ↓
PUBLISH
    ↓
status = "published"
    ↓
VISIBLE IN MARKETPLACE
    ↓
UNPUBLISH or DEACTIVATE
    ↓
status = "inactive"
```

### Publish Validation (Updated)

```csharp
public class PublishJourneyValidator
{
    public ValidationResult Validate(Journey journey)
    {
        var errors = new List<string>();
        
        // Check has activities
        if (!journey.Activities.Any())
        {
            errors.Add("Journey must have at least 1 activity");
        }
        
        // Check all service-based activities have services
        var serviceTypes = new[] { "hotel", "flight", "visa", "transport", "guide", "insurance", "catering", "handling" };
        var serviceActivities = journey.Activities.Where(a => serviceTypes.Contains(a.Type));
        
        foreach (var activity in serviceActivities)
        {
            if (activity.SupplierServiceId == null && activity.AgencyServiceId == null)
            {
                errors.Add($"Activity {activity.ActivityNumber} requires a service");
            }
        }
        
        // Check all marketplace services are paid
        var marketplaceActivities = journey.Activities
            .Where(a => a.SourceType == "supplier" && a.SupplierServiceId != null);
        
        foreach (var activity in marketplaceActivities)
        {
            if (activity.PaymentStatus != "paid")
            {
                errors.Add($"Activity {activity.ActivityNumber} payment is pending");
            }
        }
        
        // Check all services are available
        var unavailableActivities = journey.Activities
            .Where(a => !a.IsServiceAvailable && (a.SupplierServiceId != null || a.AgencyServiceId != null));
        
        if (unavailableActivities.Any())
        {
            errors.Add("Some services are no longer available. Please change services.");
        }
        
        return new ValidationResult
        {
            IsValid = !errors.Any(),
            Errors = errors
        };
    }
}
```

---

## 💳 PAYMENT ENTITY (NEW)

### Payment Table

```sql
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    journey_id UUID NOT NULL REFERENCES journeys(id),
    journey_activity_id UUID NOT NULL REFERENCES journey_activities(id),
    
    -- Payment Details
    payment_method VARCHAR(50) NOT NULL, -- bank_transfer, credit_card, virtual_account, etc.
    amount DECIMAL(18,2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'IDR',
    
    -- Payment Gateway
    payment_gateway VARCHAR(50), -- midtrans, xendit, etc.
    transaction_id VARCHAR(255), -- From payment gateway
    payment_url TEXT, -- Payment page URL
    
    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- pending, processing, success, failed, expired
    
    -- Timestamps
    paid_at TIMESTAMP,
    expired_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    -- Receipt
    receipt_url TEXT,
    receipt_number VARCHAR(100),
    
    CONSTRAINT unique_activity_payment UNIQUE (journey_activity_id)
);

CREATE INDEX idx_payments_agency_id ON payments(agency_id);
CREATE INDEX idx_payments_journey_id ON payments(journey_id);
CREATE INDEX idx_payments_status ON payments(status);
```

**Constraint**: One payment per activity (can't pay twice)

---

## 🔌 PAYMENT API ENDPOINTS (NEW)

### Create Payment

```
POST /api/journeys/{journeyId}/activities/{activityId}/payment
Body: {
  payment_method: string,
  payment_gateway: string
}
Response: {
  payment_id: Guid,
  payment_url: string, // Redirect to payment gateway
  amount: number,
  expired_at: DateTime
}
```

### Check Payment Status

```
GET /api/payments/{paymentId}/status
Response: {
  payment_id: Guid,
  status: string,
  paid_at?: DateTime,
  transaction_id?: string
}
```

### Payment Webhook (From Gateway)

```
POST /api/payments/webhook/{gateway}
Body: (Gateway-specific payload)
Response: 200 OK

Logic:
1. Verify webhook signature
2. Extract payment status
3. Update Payment record
4. Update JourneyActivity.payment_status
5. Send notification to agency
```

### Get Payment Receipt

```
GET /api/payments/{paymentId}/receipt
Response: PDF file or receipt data
```

---

## 🎯 PAYMENT GATEWAY INTEGRATION

### Supported Gateways (To Discuss)

**Options**:
1. **Midtrans** (Popular in Indonesia)
2. **Xendit** (Good for B2B)
3. **Stripe** (International)
4. **Manual Transfer** (Bank transfer with proof upload)

**Question**: Which payment gateway do you want to use?

### Payment Flow

**1. Agency clicks "Pay Now"**:
```
Frontend → POST /api/journeys/{id}/activities/{id}/payment
Backend → Create Payment record (status = pending)
Backend → Call Payment Gateway API
Backend → Return payment_url
Frontend → Redirect to payment_url (gateway page)
```

**2. User completes payment on gateway**:
```
Gateway → Webhook to Backend
Backend → Verify webhook
Backend → Update Payment (status = success)
Backend → Update JourneyActivity (payment_status = paid)
Backend → Send notification to agency
```

**3. User returns to app**:
```
Frontend → Check payment status
Frontend → Show success message
Frontend → Update activity display (show PAID badge)
```

---

## 🎨 JOURNEY DETAIL PAGE COMPONENTS

### 1. JourneyDetailComponent (Updated)

**Location**: `src/app/features/agency/components/journey-detail/`

**Sections**:
1. Journey Header (title, status, actions)
2. Basic Information (read-only)
3. Itinerary Builder (with payment actions)
4. Pricing Summary

**Actions** (based on status):
- Draft: [Edit Journey] [Publish Journey]
- Published: [Unpublish] [View Bookings]
- Inactive: [Reactivate]

---

### 2. ActivityPaymentActionsComponent (NEW)

**Location**: `src/app/features/agency/components/activity-payment-actions/`

**Props**:
```typescript
@Input() activity: JourneyActivity;
@Output() payNow = new EventEmitter<void>();
@Output() changeService = new EventEmitter<void>();
@Output() viewReceipt = new EventEmitter<void>();
```

**Render Logic**:
```typescript
// If from inventory
if (activity.source_type === 'agency') {
  return <Badge severity="info">RESERVED</Badge>;
}

// If service not available
if (!activity.is_service_available) {
  return (
    <>
      <Badge severity="warning">NOT AVAILABLE</Badge>
      <Button onClick={changeService}>Change Service</Button>
    </>
  );
}

// If unpaid
if (activity.payment_status === 'unpaid') {
  return (
    <>
      <Badge severity="danger">UNPAID</Badge>
      <Button onClick={payNow}>Pay Now</Button>
      <Button onClick={changeService}>Change Service</Button>
    </>
  );
}

// If paid
if (activity.payment_status === 'paid') {
  return (
    <>
      <Badge severity="success">PAID</Badge>
      <Button onClick={viewReceipt}>View Payment Receipt</Button>
    </>
  );
}
```

---

### 3. PaymentDialogComponent (NEW)

**Location**: `src/app/shared/components/payment-dialog/`

**Props**:
```typescript
@Input() activity: JourneyActivity;
@Input() journeyId: string;
@Output() paymentCompleted = new EventEmitter<Payment>();
```

**Features**:
- Display service and amount
- Payment method selection
- Integration with payment gateway
- Redirect to gateway page
- Handle return from gateway
- Show payment status

---

### 4. PaymentReceiptModalComponent (NEW)

**Location**: `src/app/shared/components/payment-receipt-modal/`

**Props**:
```typescript
@Input() paymentId: string;
```

**Features**:
- Display payment details
- Show transaction ID
- Download PDF receipt
- Print receipt

---

## 🔄 AVAILABILITY CHECKING

### Background Job (Backend)

**Purpose**: Check if services are still available

**Logic**:
```csharp
public class CheckServiceAvailabilityJob
{
    public async Task Execute()
    {
        // Get all draft journeys with unpaid activities
        var draftJourneys = await _journeyRepository
            .GetDraftJourneysWithUnpaidActivities();
        
        foreach (var journey in draftJourneys)
        {
            foreach (var activity in journey.Activities)
            {
                if (activity.SupplierServiceId != null)
                {
                    // Check if service still available for dates
                    var isAvailable = await _availabilityService
                        .CheckAvailability(
                            activity.SupplierServiceId.Value,
                            activity.CheckInDate ?? activity.Date,
                            activity.CheckOutDate ?? activity.Date
                        );
                    
                    if (activity.IsServiceAvailable != isAvailable)
                    {
                        activity.IsServiceAvailable = isAvailable;
                        activity.AvailabilityCheckedAt = DateTime.UtcNow;
                        
                        // Send notification if became unavailable
                        if (!isAvailable)
                        {
                            await _notificationService.NotifyServiceUnavailable(
                                journey.AgencyId,
                                journey.Id,
                                activity.Id
                            );
                        }
                    }
                }
            }
        }
        
        await _journeyRepository.SaveChangesAsync();
    }
}
```

**Schedule**: Run every 1 hour using Hangfire

---

## 📋 UPDATED IMPLEMENTATION PHASES

### Phase 1: Database Cleanup & Refactoring
(Same as before)

### Phase 2: Backend API Refactoring
(Same as before)

### Phase 3: Payment System Integration
**Goal**: Integrate payment gateway for service payments

**NEW TASKS**:
1. Create Payment entity and table
2. Choose payment gateway (Midtrans/Xendit/Stripe)
3. Implement payment gateway service
4. Create payment commands (Create, Verify, Cancel)
5. Create payment queries (GetById, GetByJourney)
6. Implement webhook handler
7. Add payment status to JourneyActivity
8. Create availability checking background job

**Duration**: 5-7 days

---

### Phase 4: Service Selection Modal
(Same as before)

### Phase 5: Journey Form V2
(Same as before)

### Phase 6: Journey Detail & Payment UI
**Goal**: Build journey detail page with payment workflow

**NEW TASKS**:
1. Create/Update JourneyDetailComponent
2. Create ActivityPaymentActionsComponent
3. Create PaymentDialogComponent
4. Create PaymentReceiptModalComponent
5. Implement payment flow (Pay Now → Gateway → Webhook → Update UI)
6. Implement change service flow
7. Add availability status indicators
8. Add payment status badges

**Duration**: 5-7 days

---

### Phase 7: Journey List & Publish
(Updated with payment validation)

### Phase 8: Frontend Cleanup
(Same as before)

---

## 🎯 TOTAL ESTIMATED EFFORT (FINAL)

- **Backend**: 12-17 days (added payment system)
- **Frontend**: 22-32 days (added payment UI)
- **Testing**: 5-7 days
- **Total**: 39-56 days (8-11 weeks)

---

## 💬 PAYMENT GATEWAY DISCUSSION NEEDED

### Questions:

1. **Which Payment Gateway?**
   - Midtrans (popular, good docs, Indonesia-focused)
   - Xendit (B2B friendly, good API)
   - Stripe (international, best developer experience)
   - Manual Transfer (simplest, no integration needed)

2. **Payment Methods to Support?**
   - Bank Transfer (BCA, Mandiri, BNI, etc.)
   - Credit/Debit Card
   - Virtual Account
   - E-Wallet (GoPay, OVO, Dana)
   - QRIS

3. **Payment Expiry?**
   - How long before payment expires? (24 hours, 48 hours, 7 days?)
   - What happens when payment expires? (Activity reset to unpaid, allow retry)

4. **Payment to Supplier?**
   - Does agency pay directly to supplier?
   - Or agency pays to platform, platform pays supplier later?
   - Commission/fee structure?

5. **Refund Policy?**
   - Can agency cancel paid activity and get refund?
   - Refund to wallet or original payment method?
   - Refund processing time?

6. **Payment Receipt?**
   - Auto-generate PDF receipt?
   - Email receipt to agency?
   - Store receipt in database or file storage?

---

## 📝 SUMMARY

### What's New in This Update:

✅ **Payment Workflow**:
- Activities have payment status (unpaid, paid, reserved)
- Pay Now button for marketplace services
- Payment dialog with gateway integration
- Payment receipt viewing

✅ **Journey Detail Page**:
- Redirect to detail after creation (not list)
- Itinerary builder in view mode
- Payment action buttons per activity
- Availability status indicators

✅ **Change Service**:
- Can change service if not available
- Can change service if unpaid
- Cannot change if already paid (must refund first)

✅ **Publish Validation**:
- Must have activities
- Must have services selected
- Must have all marketplace services PAID
- Must have all services AVAILABLE

### Ready for Discussion:
- Payment gateway selection
- Payment methods
- Payment expiry and refund policy
- Payment to supplier flow

---

**Document Version**: 3.0 (Payment Workflow Added)  
**Last Updated**: March 18, 2026  
**Author**: Kiro AI Assistant  
**Status**: 🔄 Awaiting Payment Gateway Discussion
