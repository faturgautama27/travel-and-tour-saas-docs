# Journey System Implementation: Phases 4-8

**Version**: 1.0  
**Date**: March 26, 2026  
**Scope**: Complete Journey System from Refactoring to Booking  
**Focus**: Dynamic Itinerary Builder with Service Selection

---

## 📚 TABLE OF CONTENTS

- [Phase 4: Journey Refactoring](#phase-4-journey-refactoring)
- [Phase 5: Journey Activity Management](#phase-5-journey-activity-management)
- [Phase 6: Dynamic Service Selection](#phase-6-dynamic-service-selection)
- [Phase 7: Journey Publishing](#phase-7-journey-publishing)
- [Phase 8: Booking System](#phase-8-booking-system)

---

# PHASE 4: JOURNEY REFACTORING

## Overview
Merge Package + Journey + Itinerary into single Journey entity. Drop old tables, modify Journey table, create JourneyActivity table.

## Database Changes Flow

```
[Current State]
- packages table (to be dropped)
- package_services table (to be dropped)
- itineraries table (to be dropped)
- itinerary_days table (to be dropped)
- itinerary_activities table (to be dropped)
- journey_services table (to be dropped)
- journeys table (to be modified)

[Target State]
- journeys table (modified with Package fields)
- journey_activities table (new - replaces all itinerary tables)
```

## Backend Tasks Summary
1. Backup database (optional)
2. Clean old data (TRUNCATE)
3. Drop old tables
4. Modify Journey table (ADD columns)
5. Create journey_activities table
6. Update Journey entity
7. Create JourneyActivity entity
8. Update EF configurations
9. Update DbContext

## Frontend Tasks Summary
1. Remove Package module
2. Remove Itinerary module
3. Update Journey module
4. Create new Journey form component
5. Create Activity form component
6. Update routing

## SQL Scripts

### Step 4.1: Clean Old Data

**File**: Create manual SQL script

**SQL**:
```sql
-- Backup (optional)
-- pg_dump -U postgres -d tourtravel > backup_before_refactor.sql

-- Delete all journey/package related data
TRUNCATE TABLE journey_services CASCADE;
TRUNCATE TABLE journeys CASCADE;
TRUNCATE TABLE package_services CASCADE;
TRUNCATE TABLE packages CASCADE;
TRUNCATE TABLE itinerary_activities CASCADE;
TRUNCATE TABLE itinerary_days CASCADE;
TRUNCATE TABLE itineraries CASCADE;

-- Delete procurement/inventory data (fresh start)
TRUNCATE TABLE agency_services CASCADE;
TRUNCATE TABLE po_items CASCADE;
TRUNCATE TABLE purchase_orders CASCADE;
TRUNCATE TABLE cart_items CASCADE;
TRUNCATE TABLE carts CASCADE;
```

**Why**: Clean slate approach - no migration complexity.

---

### Step 4.2: Drop Old Tables

**SQL**:
```sql
-- Drop Package system
DROP TABLE IF EXISTS package_services CASCADE;
DROP TABLE IF EXISTS packages CASCADE;

-- Drop Itinerary system
DROP TABLE IF EXISTS itinerary_activities CASCADE;
DROP TABLE IF EXISTS itinerary_days CASCADE;
DROP TABLE IF EXISTS itineraries CASCADE;

-- Drop old JourneyService
DROP TABLE IF EXISTS journey_services CASCADE;
```

---

### Step 4.3: Modify Journey Table

**SQL**:
```sql
-- Add Package fields
ALTER TABLE journeys
ADD COLUMN "Name" VARCHAR(255) NOT NULL DEFAULT '',
ADD COLUMN "Description" TEXT,
ADD COLUMN "PackageType" VARCHAR(50) NOT NULL DEFAULT 'custom',
ADD COLUMN "DurationDays" INT NOT NULL DEFAULT 1,
ADD COLUMN "BaseCost" DECIMAL(18,2) NOT NULL DEFAULT 0,
ADD COLUMN "MarkupType" VARCHAR(20),
ADD COLUMN "MarkupValue" DECIMAL(18,2),
ADD COLUMN "SellingPrice" DECIMAL(18,2) NOT NULL DEFAULT 0,
ADD COLUMN "Visibility" VARCHAR(20) NOT NULL DEFAULT 'public';

-- Remove package dependency
ALTER TABLE journeys DROP COLUMN IF EXISTS "PackageId";

-- Rename columns
ALTER TABLE journeys RENAME COLUMN "DepartureDate" TO "StartDateEstimated";
ALTER TABLE journeys RENAME COLUMN "ReturnDate" TO "EndDateEstimated";
ALTER TABLE journeys RENAME COLUMN "TotalQuota" TO "Quota";

-- Simplify status
UPDATE journeys SET "Status" = 'draft' 
WHERE "Status" NOT IN ('draft', 'published', 'inactive');
```

---

### Step 4.4: Create JourneyActivity Table

**SQL**:
```sql
CREATE TABLE journey_activities (
    "Id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "JourneyId" UUID NOT NULL REFERENCES journeys("Id") ON DELETE CASCADE,
    "ActivityNumber" INT NOT NULL,
    
    -- Activity Details
    "Date" DATE NOT NULL,
    "Type" VARCHAR(50) NOT NULL,
    "Description" TEXT,
    
    -- Service Selection (OPTIONAL)
    "SupplierServiceId" UUID REFERENCES supplier_services("Id") ON DELETE SET NULL,
    "AgencyServiceId" UUID REFERENCES agency_services("Id") ON DELETE SET NULL,
    "SourceType" VARCHAR(20),
    
    -- Date Range (for hotel, transport, guide, catering)
    "CheckInDate" DATE,
    "CheckOutDate" DATE,
    
    -- Flight-specific
    "EstimatedTimeDeparture" TIMESTAMP,
    "EstimatedTimeArrival" TIMESTAMP,
    
    -- Pricing
    "Quantity" INT NOT NULL DEFAULT 1,
    "UnitCost" DECIMAL(18,2),
    "TotalCost" DECIMAL(18,2),
    
    "CreatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_journey_activity_number UNIQUE ("JourneyId", "ActivityNumber"),
    CONSTRAINT check_service_selection CHECK (
        ("SupplierServiceId" IS NOT NULL AND "AgencyServiceId" IS NULL) OR
        ("SupplierServiceId" IS NULL AND "AgencyServiceId" IS NOT NULL) OR
        ("SupplierServiceId" IS NULL AND "AgencyServiceId" IS NULL)
    )
);

-- Indexes
CREATE INDEX "IX_JourneyActivities_JourneyId" ON journey_activities("JourneyId");
CREATE INDEX "IX_JourneyActivities_Date" ON journey_activities("Date");
CREATE INDEX "IX_JourneyActivities_Type" ON journey_activities("Type");
CREATE INDEX "IX_JourneyActivities_SupplierServiceId" ON journey_activities("SupplierServiceId");
CREATE INDEX "IX_JourneyActivities_AgencyServiceId" ON journey_activities("AgencyServiceId");
```

---

## Backend Entity Updates

### Step 4.5: Update Journey Entity

**File**: `TourTravel.Domain/Entities/Journey.cs`

**Action**: REPLACE entire file

**Code**:
```csharp
namespace TourTravel.Domain.Entities;

public class Journey
{
    // Identity
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public string JourneyCode { get; set; } = string.Empty;
    
    // Basic Information (merged from Package)
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string PackageType { get; set; } = "custom";
    
    // Schedule
    public DateTime StartDateEstimated { get; set; }
    public DateTime? EndDateEstimated { get; set; }
    public int DurationDays { get; set; } = 1;
    public int Quota { get; set; }
    public int ConfirmedPax { get; set; }
    public int AvailableQuota { get; set; }
    
    // Pricing
    public decimal BaseCost { get; set; }
    public string? MarkupType { get; set; }
    public decimal? MarkupValue { get; set; }
    public decimal SellingPrice { get; set; }
    
    // Status
    public string Visibility { get; set; } = "public";
    public string Status { get; set; } = "draft";
    public DateTime? PublishedAt { get; set; }
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation
    public Agency Agency { get; set; } = null!;
    public ICollection<JourneyActivity> JourneyActivities { get; set; } = new List<JourneyActivity>();
    public ICollection<Booking> Bookings { get; set; } = new List<Booking>();
}
```

---

### Step 4.6: Create JourneyActivity Entity

**File**: `TourTravel.Domain/Entities/JourneyActivity.cs`

**Action**: CREATE or REPLACE

**Code**:
```csharp
namespace TourTravel.Domain.Entities;

public class JourneyActivity
{
    public Guid Id { get; set; }
    public Guid JourneyId { get; set; }
    public int ActivityNumber { get; set; }
    
    // Activity Details
    public DateTime Date { get; set; }
    public string Type { get; set; } = string.Empty;
    public string? Description { get; set; }
    
    // Service Selection (OPTIONAL)
    public Guid? SupplierServiceId { get; set; }
    public Guid? AgencyServiceId { get; set; }
    public string? SourceType { get; set; }
    
    // Date Range (for hotel, transport, guide, catering)
    public DateTime? CheckInDate { get; set; }
    public DateTime? CheckOutDate { get; set; }
    
    // Flight-specific
    public DateTime? EstimatedTimeDeparture { get; set; }
    public DateTime? EstimatedTimeArrival { get; set; }
    
    // Pricing
    public int Quantity { get; set; } = 1;
    public decimal? UnitCost { get; set; }
    public decimal? TotalCost { get; set; }
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation
    public Journey Journey { get; set; } = null!;
    public SupplierService? SupplierService { get; set; }
    public AgencyService? AgencyService { get; set; }
}
```

---

## Frontend Cleanup

### Step 4.7: Remove Old Modules

**Action**: DELETE these folders

**Folders to Delete**:
```
src/app/features/agency/packages/
src/app/features/agency/itinerary/
```

**Why**: Package and Itinerary are deprecated.

---

### Step 4.8: Update Routing

**File**: `src/app/features/agency/agency-routing.module.ts`

**Action**: MODIFY - Remove package and itinerary routes

**Remove these routes**:
```typescript
{ path: 'packages', loadChildren: () => import('./packages/packages.module').then(m => m.PackagesModule) },
{ path: 'itinerary', loadChildren: () => import('./itinerary/itinerary.module').then(m => m.ItineraryModule) },
```

---

# PHASE 5: JOURNEY ACTIVITY MANAGEMENT

## Overview
Create, update, delete, and reorder activities within a journey. Auto-calculate costs and duration.

## Flow Diagram

```
[Journey Form]
    │
    ├─► Basic Info Section:
    │   ├─► Name: [Text]
    │   ├─► Start Date: [Calendar]
    │   ├─► Quota: [Number]
    │   └─► Package Type: [Dropdown]
    │
    ├─► Itinerary Builder Section:
    │   │
    │   ├─► [Add Activity] Button
    │   │
    │   ├─► Activity 1:
    │   │   ├─► Date: [Calendar]
    │   │   ├─► Type: [Dropdown] ◄─── Determines behavior
    │   │   ├─► Description: [Textarea]
    │   │   ├─► [Conditional Fields based on type]
    │   │   ├─► [Select Services] Button
    │   │   └─► [Remove] Button
    │   │
    │   ├─► Activity 2: ...
    │   └─► Activity N: ...
    │
    └─► Pricing Section:
        ├─► Base Cost: [Display - Auto]
        ├─► Markup Type: [Dropdown]
        ├─► Markup Value: [Number]
        └─► Selling Price: [Display - Auto]
```

## Backend Tasks Summary
1. Create AddJourneyActivityCommand
2. Create UpdateJourneyActivityCommand
3. Create DeleteJourneyActivityCommand
4. Create ReorderActivitiesCommand
5. Implement auto-calculation logic
6. Create validators
7. Create controllers

## Frontend Tasks Summary
1. Create Journey form component (redesigned)
2. Create Activity form component
3. Create Activity list component
4. Implement drag-and-drop reordering
5. Implement auto-calculation display
6. Create Journey API service

---

