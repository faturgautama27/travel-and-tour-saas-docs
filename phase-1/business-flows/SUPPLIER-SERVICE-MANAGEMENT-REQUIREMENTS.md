# Supplier Service Management - Requirements & Design Document

**Project**: Tour & Travel ERP SaaS  
**Date**: March 18, 2026  
**Status**: Requirements Finalized - Ready for Implementation

---

## 📋 OVERVIEW

This document outlines the requirements and design decisions for 5 major features in the Supplier Service Management system:

1. **Service Enrich Information** - Dynamic form system with JSON schema
2. **Service Image Upload** - Multi-image upload with MinIO storage
3. **Service Seasonal Pricing** - Date range based pricing adjustments
4. **Service Availability Management** - Per-date availability and pricing
5. **Service Payment Terms** - DP + Pelunasan configuration with platform commission

---

## 🎯 CORE PRINCIPLES

### Service Granularity
**1 Service = 1 Specific Offering**

Examples:
- ✅ "Hotel Grand Makkah 5 Star - Deluxe Room Twin Bed"
- ✅ "Garuda Indonesia Flight CGK-JED - Business Class"
- ✅ "Saudi Arabia Tourist Visa - Single Entry 90 Days"
- ❌ "Hotel Services" (too generic)
- ❌ "Flight Tickets" (too generic)

### Data Storage Strategy
- **Type-specific data**: Stored as JSON in `service_details` field
- **Common data**: Stored in dedicated columns (name, base_price, currency, etc.)
- **Backend**: Generic and flexible, no hardcoded type-specific fields

---

## 1️⃣ FEATURE: SERVICE ENRICH INFORMATION

### Current Status

**Frontend**: ✅ **COMPLETED**
- Dynamic form component: `DynamicServiceFormComponent`
- JSON schema configuration: `service-details-schema.json` (720 lines)
- 8 service types: hotel, flight, visa, transport, guide, insurance, catering, handling
- Field types: text, textarea, number, select, multiselect, checkbox, keyvalue
- Auto-refresh when service type changes
- Data stored as JSON string in `service_details` field

**Backend**: ❌ **NEEDS REFACTORING**

Current Issues:
- Entity `SupplierService` has 20+ hardcoded type-specific fields:
  - Hotel: `HotelName`, `HotelStarRating`, `RoomType`, `MealPlan`
  - Flight: `Airline`, `FlightClass`, `DepartureAirport`, `ArrivalAirport`
  - Visa: `VisaType`, `ProcessingDays`, `ValidityDays`, `EntryType`
  - Transport: `VehicleType`, `Capacity`
  - Guide: `Languages`, `Specialization`
  - Insurance: `CoverageType`, `CoverageAmount`
- DTOs mirror this structure with all hardcoded fields
- `ServiceDetails` JSONB field exists but not properly utilized

### Requirements

**Backend Refactoring**:
1. Remove ALL hardcoded type-specific fields from `SupplierService` Entity
2. Remove hardcoded fields from DTOs:
   - `CreateSupplierServiceDto`
   - `UpdateSupplierServiceDto`
   - `SupplierServiceDto`
3. Keep only these fields in Entity/DTOs:
   - Core: `Id`, `SupplierId`, `ServiceCode`, `ServiceType`, `Name`, `Description`
   - Pricing: `BasePrice`, `Currency`
   - Location: `LocationCity`, `LocationCountry`
   - Metadata: `Visibility`, `Status`, `PublishedAt`, `CreatedAt`, `UpdatedAt`
   - **Dynamic Data**: `ServiceDetails` (JSONB/string)
4. Backend accepts `service_details` as JSON string without validation
5. Frontend handles all type-specific validation via JSON schema

**Benefits**:
- Backend becomes generic and maintainable
- Can add new service types without database migration
- Single source of truth for service structure (JSON schema)
- Reduced code complexity

---

## 2️⃣ FEATURE: SERVICE IMAGE UPLOAD

### Requirements

**Storage**: MinIO (already implemented via `MinIOFileStorageService`)

**Specifications**:
- Max images per service: **5 images**
- Allowed formats: **JPG, PNG, WebP**
- Max file size: Use existing config (default 10MB, configurable)
- No auto-resize or compression
- First image = primary thumbnail
- Upload available AFTER service creation (when service has ID)

**Database**: New Entity `SupplierServiceImage`

```csharp
public class SupplierServiceImage
{
    public Guid Id { get; set; }
    public Guid SupplierServiceId { get; set; }
    public string FilePath { get; set; } // Path in MinIO
    public string FileUrl { get; set; } // Presigned URL
    public string FileName { get; set; }
    public long FileSize { get; set; }
    public string MimeType { get; set; }
    public int DisplayOrder { get; set; } // 1-5
    public bool IsPrimary { get; set; } // First image = true
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation
    public SupplierService SupplierService { get; set; }
}
```

**API Endpoints**:
- `POST /api/supplier-services/{serviceId}/images` - Upload image
- `DELETE /api/supplier-services/{serviceId}/images/{imageId}` - Delete image
- `PUT /api/supplier-services/{serviceId}/images/reorder` - Update display order
- `GET /api/supplier-services/{serviceId}/images` - List images

**Frontend Components**:
- Image upload component with drag & drop
- Image preview grid with reorder capability
- Delete confirmation
- Primary thumbnail indicator
- Progress indicator during upload

**Pattern**: Follow existing `EntityDocument` pattern

---

## 3️⃣ FEATURE: SERVICE SEASONAL PRICING

### Current Status

**Frontend**: ✅ **COMPLETED**
- Component: `SeasonalPriceComponent`
- Form: `SeasonalPriceFormComponent`
- API Service: `SeasonalPriceApiService`
- Features: Create, Update, Delete, List with filters

**Backend**: ✅ **COMPLETED**
- Entity: `SupplierServiceSeasonalPrice`
- Commands: Create, Update, Delete
- Queries: GetByServiceId
- Repository: `ISeasonalPriceRepository`

### Design

**Approach**: Date Range Based
- One record = One seasonal period
- Example: "High Season" from Dec 1, 2026 - Feb 28, 2027 at 5,000,000 IDR

**Entity Structure**:
```csharp
public class SupplierServiceSeasonalPrice
{
    public Guid Id { get; set; }
    public Guid SupplierServiceId { get; set; }
    public string? SeasonName { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public decimal SeasonalPrice { get; set; }
    public bool IsActive { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public Guid CreatedBy { get; set; }
}
```

**Status**: ✅ No changes needed - Already complete

---

## 4️⃣ FEATURE: SERVICE AVAILABILITY MANAGEMENT

### Overview

**Purpose**: Manage per-date availability and pricing for services

**Key Difference from Seasonal Pricing**:
- Seasonal Pricing: Date RANGE (1 record for period)
- Availability: PER-DATE (1 record per date)

### Requirements

**Database**: New Entity `SupplierServiceAvailability`

```csharp
public class SupplierServiceAvailability
{
    public Guid Id { get; set; }
    public Guid SupplierServiceId { get; set; }
    public DateOnly Date { get; set; } // Single date
    public decimal Price { get; set; }
    public bool IsAvailable { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation
    public SupplierService SupplierService { get; set; }
}
```

**Unique Constraint**: (SupplierServiceId, Date) - One record per service per date

### User Flow

**1. Create Availability (Bulk)**:
```
Frontend Form:
- Start Date: 1 March 2026
- End Date: 10 March 2026
- Base Price: 2,000,000 IDR

Backend Processing:
- Generate 10 individual records (1 per date)
- Each record: date, price=2,000,000, is_available=true

Result:
- 10 records created in SupplierServiceAvailability table
```

**2. Display in Calendar**:
- Custom calendar component (like Google Calendar)
- Show events for dates with availability
- Color coding: Available (green), Unavailable (red), No data (gray)
- Click date to view/edit details

**3. Edit Individual Date**:
- Click on date in calendar
- Edit form: Price, Is Available
- Update single record

**4. Bulk Edit**:
- Select date range
- Update price and/or availability
- Option C: Update existing records + Create new records for missing dates

### Price Calculation Logic

**Priority Order** (Highest to Lowest):
1. **Seasonal Price** (from `SupplierServiceSeasonalPrice`)
2. **Availability Price** (from `SupplierServiceAvailability`)
3. **Base Price** (from `SupplierService`)

**Example Calculation**:
```
Service: Hotel Grand Makkah
- Base Price: 2,000,000 IDR

Date: March 1, 2026
- Availability Price: 2,500,000 IDR
- Seasonal Price (High Season Mar 1-31): 3,500,000 IDR
- Final Price: 3,500,000 IDR ✅ (seasonal overrides)

Date: March 15, 2026
- Availability Price: 2,200,000 IDR
- No Seasonal Price
- Final Price: 2,200,000 IDR ✅ (availability used)

Date: April 1, 2026
- No Availability record
- No Seasonal Price
- Final Price: 2,000,000 IDR ✅ (base price used)
```

### Default Availability

**Option A**: No availability by default
- Service created with status = "draft"
- Must manually add availability via form
- Cannot publish without availability records

### Publish Validation

**Service List Frontend**:
- Add "Publish" button for draft services
- Validation before publish:
  - ✅ Has at least 1 availability record
  - ✅ Service details completed
  - ✅ Has at least 1 image (optional but recommended)
- Show validation errors if requirements not met
- Status changes: draft → published

**Status Flow**:
```
draft → published → inactive
  ↑         ↓
  └─────────┘ (can unpublish back to draft)
```

### API Endpoints

**Availability Management**:
- `POST /api/supplier-services/{serviceId}/availability/bulk` - Create bulk availability
- `GET /api/supplier-services/{serviceId}/availability` - List availability (with date range filter)
- `PUT /api/supplier-services/{serviceId}/availability/{date}` - Update single date
- `PUT /api/supplier-services/{serviceId}/availability/bulk-update` - Update date range
- `DELETE /api/supplier-services/{serviceId}/availability/{date}` - Delete single date
- `GET /api/supplier-services/{serviceId}/availability/calendar` - Get calendar view data

**Service Publishing**:
- `POST /api/supplier-services/{serviceId}/publish` - Publish service (with validation)
- `POST /api/supplier-services/{serviceId}/unpublish` - Unpublish service

### Frontend Components

**1. Availability Management Component**:
- Accessible from service detail page
- Bulk create form (date range + price)
- Custom calendar view
- Edit modal for individual dates
- Bulk edit functionality

**2. Custom Calendar Component**:
- Month view with date grid
- Event indicators on dates with availability
- Color coding: Available (green), Unavailable (red), No data (gray)
- Click to view/edit date details
- Navigation: Previous/Next month
- Price display on hover or in cell

**3. Service List Enhancements**:
- "Publish" button for draft services
- Validation modal showing requirements:
  - ✅ Has availability records
  - ✅ Service details completed
  - ⚠️ Has images (recommended)
- Status badge with color coding

---

## 5️⃣ FEATURE: SERVICE PAYMENT TERMS & PLATFORM COMMISSION

### Overview

**Purpose**: Allow suppliers to configure payment terms (DP + Pelunasan) and platform to earn commission from transactions

**Business Model**:
- Supplier sets payment terms for their service
- Agency pays in installments (DP + Full Payment)
- Platform takes commission from each payment
- Commission deducted automatically before transferring to supplier

### Requirements

**Payment Terms Configuration**:
- Supplier can enable/disable payment terms per service
- If disabled: Full payment required immediately
- If enabled: DP + Full Payment with configurable terms

**Payment Terms Fields**:
1. **payment_terms_enabled**: Boolean (default: false)
2. **down_payment_percentage**: Decimal (e.g., 30 = 30% DP)
3. **down_payment_due_days**: Integer (e.g., 3 = DP due 3 days after booking)
4. **full_payment_due_days**: Integer (e.g., 7 = Full payment due H-7)
5. **platform_commission_percentage**: Decimal (e.g., 5 = 5% commission)

### Database Schema

**SupplierService (Add Payment Terms Fields)**:

```sql
ALTER TABLE supplier_services
ADD COLUMN payment_terms_enabled BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN down_payment_percentage DECIMAL(5,2), -- e.g., 30.00 for 30%
ADD COLUMN full_payment_due_days INTEGER; -- e.g., 7 = H-7 (7 days before departure)

-- Constraints
ALTER TABLE supplier_services
ADD CONSTRAINT check_down_payment_percentage 
    CHECK (down_payment_percentage IS NULL OR (down_payment_percentage >= 10 AND down_payment_percentage <= 90)),
ADD CONSTRAINT check_payment_terms_consistency
    CHECK (
        (payment_terms_enabled = false) OR
        (payment_terms_enabled = true AND down_payment_percentage IS NOT NULL 
         AND full_payment_due_days IS NOT NULL)
    );
```

**Key Points**:
- DP paid **immediately** when agency selects service (locks availability)
- Full payment due X days before departure (configurable per service)
- DP percentage between 10-90%
- Platform commission retrieved from `commission_configs` table (not stored in service)

### Payment Terms Examples

**Example 1: Hotel Service with Payment Terms (DP + Pelunasan)**
```
Service: Hotel Grand Makkah 5 Star - Deluxe Twin
Base Price: Rp 2,500,000 per night
Payment Terms Enabled: Yes
DP Percentage: 30%
Full Payment Due: H-7 (7 days before check-in)
Platform Commission: 5%

Agency books for 5 nights × 20 pax:
Total: Rp 2,500,000 × 5 × 20 = Rp 250,000,000

Payment Flow:
├─ STEP 1: Pay DP (Immediately)
│   ├─ Amount: Rp 75,000,000 (30%)
│   ├─ Platform commission: Rp 3,750,000 (5%)
│   ├─ To Supplier: Rp 71,250,000
│   ├─ Activity Status: "dp_paid"
│   └─ Availability: LOCKED for this agency
│
└─ STEP 2: Pay Pelunasan (Before H-7)
    ├─ Amount: Rp 175,000,000 (70%)
    ├─ Due: 7 days before check-in date
    ├─ Platform commission: Rp 8,750,000 (5%)
    ├─ To Supplier: Rp 166,250,000
    └─ Activity Status: "fully_paid"

Total Platform Commission: Rp 12,500,000 (5% of Rp 250,000,000)
```

**Example 2: Flight Service without Payment Terms (Full Payment)**
```
Service: Garuda Indonesia Business CGK-JED
Base Price: Rp 15,000,000 per seat
Payment Terms Enabled: No
Platform Commission: 5%

Agency books 20 seats:
Total: Rp 15,000,000 × 20 = Rp 300,000,000

Payment Flow:
└─ STEP 1: Pay Full (Immediately)
    ├─ Amount: Rp 300,000,000 (100%)
    ├─ Platform commission: Rp 15,000,000 (5%)
    ├─ To Supplier: Rp 285,000,000
    └─ Activity Status: "fully_paid"
```

### Payment Flow with Commission

**Step 1: Agency Pays via Payment Gateway**
```
Agency clicks [Pay Now]
    ↓
Payment Gateway (Xendit/Midtrans)
    ↓
Total Amount: Rp 75,000,000 (DP)
    ↓
Payment Success
```

**Step 2: Platform Receives Payment**
```
Payment Gateway → Platform Account
    ↓
Total Received: Rp 75,000,000
    ↓
Calculate Commission: Rp 75,000,000 × 5% = Rp 3,750,000
    ↓
Calculate Supplier Amount: Rp 75,000,000 - Rp 3,750,000 = Rp 71,250,000
```

**Step 3: Platform Transfers to Supplier**
```
Platform → Supplier Account
    ↓
Amount Transferred: Rp 71,250,000
    ↓
Platform Keeps: Rp 3,750,000 (commission)
```

**Step 4: Record Transaction**
```
Database Records:
├─ payments table:
│   ├─ amount: Rp 75,000,000
│   ├─ commission_amount: Rp 3,750,000
│   ├─ supplier_amount: Rp 71,250,000
│   └─ status: success
│
└─ commission_transactions table:
    ├─ transaction_type: 'journey_activity_payment'
    ├─ base_amount: Rp 75,000,000
    ├─ commission_rate: 5%
    ├─ commission_amount: Rp 3,750,000
    └─ status: collected
```

### Entity Updates

**SupplierService (Add Payment Terms)**:
```csharp
public class SupplierService
{
    // ... existing fields ...
    
    // Payment Terms (NEW)
    public bool PaymentTermsEnabled { get; set; } = false;
    public decimal? DownPaymentPercentage { get; set; } // 30 = 30%
    public int? DownPaymentDueDays { get; set; } // 3 = 3 days after booking
    public int? FullPaymentDueDays { get; set; } // 7 = H-7 (7 days before departure)
    public decimal PlatformCommissionPercentage { get; set; } = 5.00m; // 5 = 5%
    
    // Business Logic
    public bool RequiresDownPayment() => PaymentTermsEnabled;
    
    public decimal CalculateDownPaymentAmount(decimal totalAmount)
    {
        if (!PaymentTermsEnabled || !DownPaymentPercentage.HasValue)
            return totalAmount; // Full payment
            
        return totalAmount * (DownPaymentPercentage.Value / 100);
    }
    
    public decimal CalculateFullPaymentAmount(decimal totalAmount)
    {
        if (!PaymentTermsEnabled || !DownPaymentPercentage.HasValue)
            return 0; // Already paid in full
            
        return totalAmount * ((100 - DownPaymentPercentage.Value) / 100);
    }
    
    public decimal CalculatePlatformCommission(decimal amount)
    {
        return amount * (PlatformCommissionPercentage / 100);
    }
    
    public decimal CalculateSupplierAmount(decimal amount)
    {
        return amount - CalculatePlatformCommission(amount);
    }
}
```

### Payment Entity (Updated)

```csharp
public class Payment
{
    public Guid Id { get; set; }
    public Guid AgencyId { get; set; }
    public Guid JourneyId { get; set; }
    public Guid JourneyActivityId { get; set; }
    public Guid SupplierServiceId { get; set; } // Link to service for commission
    
    // Payment Details
    public string PaymentType { get; set; } // down_payment, full_payment
    public decimal Amount { get; set; } // Total amount paid by agency
    public string Currency { get; set; } = "IDR";
    
    // Commission Breakdown (NEW)
    public decimal CommissionPercentage { get; set; } // From service config
    public decimal CommissionAmount { get; set; } // Calculated commission
    public decimal SupplierAmount { get; set; } // Amount to transfer to supplier
    
    // Payment Gateway
    public string PaymentGateway { get; set; }
    public string? TransactionId { get; set; }
    public string? PaymentUrl { get; set; }
    
    // Status
    public string Status { get; set; } = "pending";
    public DateTime? PaidAt { get; set; }
    public DateTime? ExpiredAt { get; set; }
    
    // Supplier Transfer (NEW)
    public string SupplierTransferStatus { get; set; } = "pending"; // pending, transferred, failed
    public DateTime? TransferredToSupplierAt { get; set; }
    public string? TransferReferenceNumber { get; set; }
    
    // Receipt
    public string? ReceiptUrl { get; set; }
    public string? ReceiptNumber { get; set; }
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```
### Frontend: Payment Terms Configuration

**Service Form - Payment Terms Section**:
```
┌─────────────────────────────────────────────────────┐
│ Payment Terms Configuration                         │
│                                                     │
│ ☐ Enable Payment Terms (DP + Pelunasan)           │
│                                                     │
│ [If enabled, show these fields:]                   │
│                                                     │
│ Down Payment (DP):                                 │
│ • Percentage: [30] %                               │
│ • Payment: Immediately when agency books           │
│                                                     │
│ Full Payment (Pelunasan):                          │
│ • Due: [7] days before departure (H-7)            │
│                                                     │
│ [Preview Payment Schedule]                         │
└─────────────────────────────────────────────────────┘
```

**Payment Schedule Preview**:
```
Example for Rp 100,000,000 booking:

Commission Rate: 5% (from platform commission_configs)

Payment Schedule:
├─ DP (30%): Rp 30,000,000
│   ├─ Payment: Immediately when agency books
│   ├─ Platform Commission (5%): Rp 1,500,000
│   └─ You Receive: Rp 28,500,000
│
└─ Pelunasan (70%): Rp 70,000,000
    ├─ Due: H-7 (7 days before departure)
    ├─ Platform Commission (5%): Rp 3,500,000
    └─ You Receive: Rp 66,500,000

Total You Receive: Rp 95,000,000
Total Platform Commission: Rp 5,000,000
```al Platform Commission: Rp 5,000,000
```

### Validation Rules

**Payment Terms Validation**:
```csharp
public class PaymentTermsValidator
{
    public ValidationResult Validate(SupplierService service)
    {
        var errors = new List<string>();
        
        if (service.PaymentTermsEnabled)
        {
            // Validate DP percentage
            if (!service.DownPaymentPercentage.HasValue)
                errors.Add("Down payment percentage is required");
            else if (service.DownPaymentPercentage < 10 || service.DownPaymentPercentage > 90)
                errors.Add("Down payment percentage must be between 10% and 90%");
            
            // Validate full payment due days
            if (!service.FullPaymentDueDays.HasValue)
                errors.Add("Full payment due days is required");
            else if (service.FullPaymentDueDays < 1 || service.FullPaymentDueDays > 60)
                errors.Add("Full payment due days must be between 1 and 60 days");
        }
        
        return new ValidationResult
        {
            IsValid = !errors.Any(),
            Errors = errors
        };
    }
}
```

### Commission Calculation Logic

**Get Active Commission Config**:
```csharp
public async Task<CommissionConfig> GetActiveCommissionConfig(string transactionType)
{
    var today = DateTime.UtcNow.Date;
    
    var config = await _commissionConfigRepository
        .GetActiveConfigAsync(
            transactionType: "journey_activity_payment",
            effectiveDate: today
        );
    
    if (config == null)
    {
        // Use default: 5% percentage
        return new CommissionConfig
        {
            CommissionType = "percentage",
            CommissionValue = 5.00m
        };
    }
    
    return config;
}
```

**Calculate Commission**:
```csharp
public decimal CalculateCommission(decimal amount, CommissionConfig config)
{
    if (config.CommissionType == "percentage")
    {
        var commission = amount * (config.CommissionValue / 100);
        
        // Apply max commission cap if configured
        if (config.MaxCommissionAmount.HasValue)
        {
            commission = Math.Min(commission, config.MaxCommissionAmount.Value);
        }
        
        return commission;
    }
    else if (config.CommissionType == "fixed")
    {
        return config.CommissionValue;
    }
    
    return 0;
}
```

### API Endpoints (NEW)

**Payment Terms Management**:
- `PUT /api/supplier-services/{id}/payment-terms` - Update payment terms
- `GET /api/supplier-services/{id}/payment-preview` - Preview payment schedule

### Commission Transaction Tracking

**CommissionTransaction Entity** (Link to existing):
```csharp
public class CommissionTransaction
{
    public Guid Id { get; set; }
    public string TransactionType { get; set; } = "journey_activity_payment";
    public Guid ReferenceId { get; set; } // payment_id
    public Guid AgencyId { get; set; }
    public Guid? SupplierId { get; set; } // NEW: Track supplier
    public Guid? CommissionConfigId { get; set; }
    public decimal BaseAmount { get; set; } // Total payment amount
    public decimal CommissionRate { get; set; } // Percentage
    public decimal CommissionAmount { get; set; } // Calculated commission
    public string Status { get; set; } = "collected";
    public DateTime? CollectedAt { get; set; }
    public string? PaymentReference { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

**Auto-create commission transaction when payment succeeds**:
```csharp
// In Payment Webhook Handler
public async Task HandlePaymentSuccess(Payment payment)
{
    // Update payment status
    payment.Status = "success";
    payment.PaidAt = DateTime.UtcNow;
    
    // Create commission transaction
    var commission = new CommissionTransaction
    {
        TransactionType = "journey_activity_payment",
        ReferenceId = payment.Id,
        AgencyId = payment.AgencyId,
        SupplierId = service.SupplierId,
        BaseAmount = payment.Amount,
        CommissionRate = payment.CommissionPercentage,
        CommissionAmount = payment.CommissionAmount,
        Status = "collected",
        CollectedAt = DateTime.UtcNow
    };
    
    await _commissionRepository.CreateAsync(commission);
    
    // Schedule supplier transfer (background job)
    await _transferService.ScheduleSupplierTransfer(
        payment.Id,
        payment.SupplierAmount,
        service.SupplierId
    );
}
```

### Payment Terms Use Cases

**Use Case 1: Service with Payment Terms**
```
Supplier creates service:
├─ Enable payment terms: Yes
├─ DP: 30% due 3 days after booking
├─ Full: 70% due H-7
└─ Commission: 5%

Agency selects service in journey:
├─ Total: Rp 100,000,000
├─ System calculates:
│   ├─ DP: Rp 30,000,000 (due 3 days after booking)
│   └─ Full: Rp 70,000,000 (due H-7)
└─ Shows payment schedule in journey detail

Agency pays DP:
├─ Amount: Rp 30,000,000
├─ Commission: Rp 1,500,000 (5%)
├─ To Supplier: Rp 28,500,000
└─ Activity status: "dp_paid"

Agency pays Full:
├─ Amount: Rp 70,000,000
├─ Commission: Rp 3,500,000 (5%)
├─ To Supplier: Rp 66,500,000
└─ Activity status: "fully_paid"
```

**Use Case 2: Service without Payment Terms**
```
Supplier creates service:
├─ Enable payment terms: No
└─ Commission: 5%

Agency selects service in journey:
├─ Total: Rp 50,000,000
└─ Must pay full amount immediately

Agency pays:
├─ Amount: Rp 50,000,000
├─ Commission: Rp 2,500,000 (5%)
├─ To Supplier: Rp 47,500,000
└─ Activity status: "fully_paid"
```

### Journey Activity Payment Status (Updated)

**Payment Status Values**:
- `unpaid`: No payment made yet
- `dp_paid`: Down payment completed (if payment terms enabled)
- `fully_paid`: All payments completed
- `reserved`: Using agency inventory (no payment needed)

**Journey Detail Page Display**:
```
Activity 1 - Flight
├─ Service: Garuda Indonesia Business
├─ Total: Rp 300,000,000
├─ Payment Terms: Full payment immediately
├─ Status: [UNPAID]
└─ Actions: [Pay Now Rp 300,000,000]

Activity 2 - Hotel
├─ Service: Hotel Grand Makkah
├─ Total: Rp 250,000,000
├─ Payment Terms: DP 30% + Full 70%
├─ Status: [UNPAID]
└─ Actions: [Pay DP Rp 75,000,000]

Activity 2 - Hotel (After DP paid)
├─ Service: Hotel Grand Makkah
├─ Total: Rp 250,000,000
├─ Payment Terms: DP 30% + Full 70%
├─ Status: [DP PAID] ✅ DP: Rp 75,000,000 paid
├─ Remaining: Rp 175,000,000 (due H-7)
└─ Actions: [Pay Full Rp 175,000,000] [View DP Receipt]

Activity 3 - Guide
├─ Service: Arabic-English Guide
├─ Source: Your Inventory
├─ Status: [RESERVED]
└─ Actions: (none - using inventory)
```

### Publish Validation (Updated)

**Journey Publish Requirements**:
```csharp
public class PublishJourneyValidator
{
    public ValidationResult Validate(Journey journey)
    {
        var errors = new List<string>();
        
        // Check has activities
        if (!journey.Activities.Any())
            errors.Add("Journey must have at least 1 activity");
        
        // Check all service-based activities have services
        var serviceActivities = journey.Activities
            .Where(a => RequiresService(a.Type));
        
        foreach (var activity in serviceActivities)
        {
            if (activity.SupplierServiceId == null && activity.AgencyServiceId == null)
                errors.Add($"Activity {activity.ActivityNumber} requires a service");
        }
        
        // Check marketplace services payment status
        var marketplaceActivities = journey.Activities
            .Where(a => a.SourceType == "supplier");
        
        foreach (var activity in marketplaceActivities)
        {
            var service = await _serviceRepository.GetByIdAsync(activity.SupplierServiceId);
            
            // If payment terms enabled, check DP paid
            if (service.PaymentTermsEnabled)
            {
                if (activity.PaymentStatus != "dp_paid" && activity.PaymentStatus != "fully_paid")
                    errors.Add($"Activity {activity.ActivityNumber}: DP payment required");
            }
            // If no payment terms, check fully paid
            else
            {
                if (activity.PaymentStatus != "fully_paid")
                    errors.Add($"Activity {activity.ActivityNumber}: Full payment required");
            }
        }
        
        return new ValidationResult
        {
            IsValid = !errors.Any(),
            Errors = errors
        };
    }
}
```

**Key Change**: Journey can be published after DP paid (don't need to wait for full payment)

---

## 💳 PAYMENT GATEWAY INTEGRATION

### Xendit Configuration (from appsettings.json)

```json
"Xendit": {
  "ApiKey": "your-xendit-api-key",
  "WebhookToken": "NwoihMvYdeeXiQPpA35h58hSQ76F7xcWaZivkjKq5q9O4bqE",
  "CallbackUrl": "https://your-domain.com/api/payments/webhook/xendit",
  "SuccessRedirectUrl": "https://your-domain.com/payments/success",
  "FailureRedirectUrl": "https://your-domain.com/payments/failure"
}
```

### Payment Methods Support

**Xendit Payment Channels**:
1. **Virtual Account** (Bank Transfer)
   - BCA, BNI, BRI, Mandiri, Permata
   - Valid for 24 hours
2. **E-Wallet**
   - OVO, GoPay, Dana, LinkAja
   - Instant payment
3. **Credit Card**
   - Visa, Mastercard
   - Instant payment
4. **QRIS**
   - Scan QR code
   - Valid for 30 minutes

### Payment Flow with Xendit

**Step 1: Create Payment**
```
POST /api/journeys/{journeyId}/activities/{activityId}/payment
Body: {
  payment_type: "down_payment" | "full_payment",
  payment_method: "virtual_account" | "ewallet" | "credit_card" | "qris",
  bank_code?: "BCA" | "BNI" | "BRI" | "MANDIRI" (for VA)
}

Response: {
  payment_id: Guid,
  payment_url: string, // Xendit invoice URL
  amount: number,
  commission_amount: number,
  supplier_amount: number,
  expired_at: DateTime
}
```

**Step 2: Redirect to Xendit**
```
Frontend redirects to payment_url
    ↓
User completes payment on Xendit page
    ↓
Xendit processes payment
```

**Step 3: Webhook Callback**
```
Xendit → POST /api/payments/webhook/xendit
Body: {
  id: "invoice_id",
  external_id: "payment_id",
  status: "PAID",
  amount: 30000000,
  paid_at: "2026-03-18T10:30:00Z"
}

Backend:
├─ Verify webhook signature
├─ Update payment.status = "success"
├─ Update payment.paid_at
├─ Update journey_activity.payment_status
├─ Create commission_transaction
└─ Schedule supplier transfer
```

**Step 4: Supplier Transfer**
```
Background Job (runs every hour):
├─ Find payments with status="success" and supplier_transfer_status="pending"
├─ For each payment:
│   ├─ Call Xendit Disbursement API
│   ├─ Transfer supplier_amount to supplier bank account
│   ├─ Update supplier_transfer_status = "transferred"
│   └─ Record transfer_reference_number
└─ Send notification to supplier
```

### Commission Reporting

**Platform Revenue Dashboard**:
```
Total Commission Earned: Rp 50,000,000
├─ From Journey Payments: Rp 45,000,000
│   ├─ DP Payments: Rp 20,000,000
│   └─ Full Payments: Rp 25,000,000
└─ From Marketplace Orders: Rp 5,000,000

Commission by Supplier:
├─ Supplier A: Rp 15,000,000 (30%)
├─ Supplier B: Rp 20,000,000 (40%)
└─ Supplier C: Rp 15,000,000 (30%)

Commission by Service Type:
├─ Hotel: Rp 20,000,000 (40%)
├─ Flight: Rp 15,000,000 (30%)
├─ Transport: Rp 10,000,000 (20%)
└─ Others: Rp 5,000,000 (10%)
```

---

## 🎯 TECHNICAL DECISIONS

### Why Payment Terms at Service Level?

**Rationale**:
- Different services have different payment requirements
- Hotels may need DP to hold reservation
- Flights may require full payment immediately
- Flexibility for suppliers to set their own terms
- Matches industry practice

### Why Platform Commission per Service?

**Rationale**:
- Different service types may have different commission rates
- Suppliers can negotiate commission rates
- Transparent commission calculation
- Easy to track and report

### Why Split Payment (DP + Full)?

**Rationale**:
- Better cash flow for agencies
- Reduces risk for suppliers (DP secures booking)
- Standard practice in travel industry
- Flexibility for both parties

---

## 📋 IMPLEMENTATION ORDER (UPDATED)

### CORRECT ORDER:
```
1. Supplier Service Backend Refactoring (1-2 weeks)
   ├─ Remove hardcoded fields
   └─ Add payment terms fields

2. Supplier Service Availability System (2-3 weeks)
   ├─ Create availability entity
   └─ Implement calendar management

3. Supplier Service Image Upload (1-2 weeks)
   ├─ Create image entity
   └─ Implement upload/delete

4. Payment Terms & Commission (1-2 weeks) ← NEW
   ├─ Update payment entity
   ├─ Implement commission calculation
   └─ Integrate with Xendit

5. Journey Refactor (8-11 weeks)
   ├─ Merge package + journey
   ├─ Implement payment workflow
   └─ Integrate with payment terms
---
TOTAL: 13-19 weeks
```

---

## 🚀 NEXT STEPS

1. ✅ **Review payment terms design** - Confirm requirements
2. ✅ **Discuss commission rates** - Platform default commission %
3. ✅ **Discuss payment gateway** - Xendit configuration and setup
4. ⏳ **Create Specs** - Break down into implementable tasks
5. ⏳ **Implementation** - Start with backend refactoring

---

**Document Version**: 2.0 (Added Payment Terms & Commission)  
**Last Updated**: March 18, 2026  
**Author**: Kiro AI Assistant  
**Reviewed By**: Fatur Gautama



### Phase 1: Backend Refactoring (Foundation)
**Goal**: Clean up backend to support dynamic service details

**Tasks**:
1. Remove hardcoded type-specific fields from `SupplierService` Entity
2. Add payment terms fields to `SupplierService` Entity
3. Update DTOs to use only `service_details` JSON field
4. Update Commands/Handlers to work with JSON
5. Update Queries to return `service_details` as string
6. Database migration to drop unused columns and add payment terms columns

**Impact**: Makes backend generic and maintainable

---

### Phase 2: Image Upload System
**Goal**: Enable multi-image upload for services

**Tasks**:
1. Create `SupplierServiceImage` Entity
2. Create Commands: UploadImage, DeleteImage, ReorderImages
3. Create Queries: GetServiceImages
4. Create API endpoints in `SupplierServiceController`
5. Frontend: Image upload component
6. Frontend: Image preview and management UI

**Dependencies**: MinIO already configured

---

### Phase 3: Availability Management System
**Goal**: Enable per-date availability and pricing

**Tasks**:
1. Create `SupplierServiceAvailability` Entity
2. Create Commands: CreateBulkAvailability, UpdateAvailability, DeleteAvailability
3. Create Queries: GetAvailabilityByDateRange, GetCalendarData
4. Create API endpoints
5. Frontend: Availability form component
6. Frontend: Custom calendar component
7. Frontend: Edit availability modal

**Dependencies**: None

---

### Phase 4: Service Publishing Workflow
**Goal**: Add validation and publish functionality

**Tasks**:
1. Create PublishService Command with validation
2. Create UnpublishService Command
3. Update service list frontend
4. Add "Publish" button with validation modal
5. Add status badges and indicators

**Dependencies**: Phase 3 (availability must exist)

---

### Phase 5: Payment Terms & Commission System (NEW)
**Goal**: Enable supplier payment terms configuration and platform commission

**Tasks**:
1. Add payment terms fields to service form
2. Update service creation/edit to include payment terms
3. Implement payment schedule calculation based on terms
4. Implement platform commission calculation
5. Frontend: Payment terms configuration component
6. Frontend: Commission preview display

**Dependencies**: Phase 1 (entity refactoring)

---

## 📊 DATABASE SCHEMA CHANGES

### SupplierService (Refactored)

**REMOVE** these columns:
- `HotelName`, `HotelStarRating`, `RoomType`, `MealPlan`
- `Airline`, `FlightClass`, `DepartureAirport`, `ArrivalAirport`
- `VisaType`, `ProcessingDays`, `ValidityDays`, `EntryType`
- `VehicleType`, `Capacity`
- `Languages`, `Specialization`
- `CoverageType`, `CoverageAmount`

**KEEP** these columns:
- `Id`, `SupplierId`, `ServiceCode`, `ServiceType`, `Name`, `Description`
- `BasePrice`, `Currency`
- `LocationCity`, `LocationCountry`
**ADD** these columns (NEW):
- `PaymentTermsEnabled` (BOOLEAN) - Whether service uses DP + Pelunasan
- `DownPaymentPercentage` (DECIMAL) - DP percentage (e.g., 30 for 30%)
- `FullPaymentDueDays` (INTEGER) - Days before departure to pay pelunasan (e.g., 7 for H-7)

**NOTE**: Platform commission is NOT stored in supplier_services table. Commission is retrieved from `commission_configs` table based on transaction type.
- `PaymentTermsEnabled` (BOOLEAN) - Whether service uses DP + Pelunasan
- `DownPaymentPercentage` (DECIMAL) - DP percentage (e.g., 30 for 30%)
- `FullPaymentDueDays` (INTEGER) - Days before departure to pay pelunasan (e.g., 7 for H-7)
- `PlatformCommissionPercentage` (DECIMAL) - Platform commission % (e.g., 5 for 5%)

### SupplierServiceImage (NEW)

```sql
CREATE TABLE supplier_service_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_service_id UUID NOT NULL REFERENCES supplier_services(id) ON DELETE CASCADE,
    file_path VARCHAR(500) NOT NULL,
    file_url TEXT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_size BIGINT NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    display_order INT NOT NULL DEFAULT 1,
    is_primary BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_service_display_order UNIQUE (supplier_service_id, display_order)
);

CREATE INDEX idx_supplier_service_images_service_id ON supplier_service_images(supplier_service_id);
```

**Constraints**:
- Max 5 images per service (enforced in application layer)
- Only 1 image can be `is_primary = true` per service
- Display order: 1-5

### SupplierServiceAvailability (NEW)

```sql
CREATE TABLE supplier_service_availability (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_service_id UUID NOT NULL REFERENCES supplier_services(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    price DECIMAL(18, 2) NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    
    CONSTRAINT unique_service_date UNIQUE (supplier_service_id, date)
);

CREATE INDEX idx_supplier_service_availability_service_id ON supplier_service_availability(supplier_service_id);
CREATE INDEX idx_supplier_service_availability_date ON supplier_service_availability(date);
CREATE INDEX idx_supplier_service_availability_service_date ON supplier_service_availability(supplier_service_id, date);
```

**Constraints**:
- One record per service per date
- Date must be unique per service

---

## 💰 PRICE CALCULATION LOGIC

### Priority Order (Highest to Lowest)

1. **Seasonal Price** (from `SupplierServiceSeasonalPrice`)
2. **Availability Price** (from `SupplierServiceAvailability`)
3. **Base Price** (from `SupplierService`)

### Calculation Algorithm

```typescript
function calculateFinalPrice(
  serviceId: string,
  date: Date,
  basePrice: number
): number {
  // Start with base price
  let finalPrice = basePrice;
  
  // Check availability price
  const availability = getAvailability(serviceId, date);
  if (availability) {
    finalPrice = availability.price;
  }
  
  // Check seasonal price (OVERRIDES availability)
  const seasonalPrice = getSeasonalPrice(serviceId, date);
  if (seasonalPrice && seasonalPrice.is_active) {
    finalPrice = seasonalPrice.seasonal_price;
  }
  
  return finalPrice;
}
```

### Example Scenarios

**Scenario 1: All prices exist**
- Base Price: 2,000,000 IDR
- Availability (Mar 1): 2,500,000 IDR
- Seasonal (Mar 1-31): 3,500,000 IDR
- **Final**: 3,500,000 IDR ✅

**Scenario 2: Only availability exists**
- Base Price: 2,000,000 IDR
- Availability (Mar 15): 2,200,000 IDR
- No Seasonal Price
- **Final**: 2,200,000 IDR ✅

**Scenario 3: No availability, no seasonal**
- Base Price: 2,000,000 IDR
- No Availability record
- No Seasonal Price
- **Final**: 2,000,000 IDR ✅

**Scenario 4: No availability record**
- Base Price: 2,000,000 IDR
- No Availability record
- Seasonal (Apr 1-30): 2,800,000 IDR
- **Final**: 2,800,000 IDR ✅

---

## 🔄 SERVICE LIFECYCLE & STATUS MANAGEMENT

### Status Flow

```
CREATE SERVICE (status = draft)
    ↓
ADD SERVICE DETAILS (optional)
    ↓
UPLOAD IMAGES (optional)
    ↓
ADD AVAILABILITY (required for publish) ← NEW REQUIREMENT
    ↓
PUBLISH (status = published) ← NEW VALIDATION
    ↓
ACTIVE IN MARKETPLACE
    ↓
UNPUBLISH (status = draft) or DEACTIVATE (status = inactive)
```

### Publish Validation

**Requirements to Publish**:
1. ✅ **MUST HAVE**: At least 1 availability record
2. ✅ **MUST HAVE**: Service details completed (all required fields)
3. ⚠️ **RECOMMENDED**: At least 1 image uploaded

**Validation Logic**:
```csharp
public class PublishServiceCommand : IRequest<PublishServiceResponse>
{
    public Guid ServiceId { get; set; }
    public Guid UserId { get; set; }
}

// In Handler
public async Task<PublishServiceResponse> Handle(...)
{
    var service = await _serviceRepository.GetByIdAsync(request.ServiceId);
    
    // Validation 1: Check availability
    var hasAvailability = await _availabilityRepository
        .HasAvailabilityAsync(request.ServiceId);
    if (!hasAvailability)
    {
        throw new ValidationException("Cannot publish: No availability records found");
    }
    
    // Validation 2: Check service details
    if (string.IsNullOrEmpty(service.ServiceDetails))
    {
        throw new ValidationException("Cannot publish: Service details not completed");
    }
    
    // Warning: Check images (not blocking)
    var imageCount = await _imageRepository
        .CountByServiceIdAsync(request.ServiceId);
    var warnings = new List<string>();
    if (imageCount == 0)
    {
        warnings.Add("No images uploaded - recommended to add at least 1 image");
    }
    
    // Update status
    service.Status = "published";
    service.PublishedAt = DateTime.UtcNow;
    await _serviceRepository.UpdateAsync(service);
    
    return new PublishServiceResponse
    {
        Success = true,
        Warnings = warnings
    };
}
```

### Frontend: Service List Enhancements

**New UI Elements**:
1. **Publish Button** (for draft services):
   - Icon: `pi pi-check-circle`
   - Label: "Publish"
   - Click → Show validation modal

2. **Validation Modal**:
   ```
   Ready to Publish?
   
   Requirements:
   ✅ Service details completed
   ✅ Has 3 availability records
   ⚠️ No images uploaded (recommended)
   
   [Cancel] [Publish Anyway]
   ```

3. **Status Badges**:
   - Draft: Gray badge
   - Published: Green badge
   - Inactive: Red badge

4. **Quick Actions Menu**:
   - Edit Service
   - Manage Images
   - Manage Availability
   - Manage Seasonal Pricing
   - Publish/Unpublish
   - Delete

---

## 🎨 FRONTEND COMPONENTS ARCHITECTURE

### Service Management Pages

```
/supplier/services
├── service-list.component (with publish button)
├── service-form-v2.component (create/edit basic info)
└── service-detail.component (view + manage)
    ├── Tab: Overview
    ├── Tab: Images (NEW)
    ├── Tab: Availability (NEW)
    └── Tab: Seasonal Pricing (existing)
```

### New Components to Create

**1. ServiceImageUploadComponent**
- Location: `src/app/features/supplier/components/service-image-upload/`
- Features: Drag & drop, preview, reorder, delete
- Max 5 images, first = primary

**2. ServiceAvailabilityComponent**
- Location: `src/app/features/supplier/components/service-availability/`
- Features: Bulk create form, calendar view, edit modal

**3. CustomCalendarComponent**
- Location: `src/app/shared/components/custom-calendar/`
- Features: Month view, event display, click to edit
- Reusable for other features

**4. PublishValidationModalComponent**
- Location: `src/app/features/supplier/components/publish-validation-modal/`
- Features: Show validation results, warnings, publish action

---

## 🔌 API ENDPOINTS SUMMARY

### Service Management
- `POST /api/supplier-services` - Create service (status = draft)
- `PUT /api/supplier-services/{id}` - Update service
- `POST /api/supplier-services/{id}/publish` - Publish with validation
- `POST /api/supplier-services/{id}/unpublish` - Unpublish to draft
- `GET /api/supplier-services` - List services
- `GET /api/supplier-services/{id}` - Get service details

### Image Management (NEW)
- `POST /api/supplier-services/{serviceId}/images` - Upload image
- `GET /api/supplier-services/{serviceId}/images` - List images
- `DELETE /api/supplier-services/{serviceId}/images/{imageId}` - Delete image
- `PUT /api/supplier-services/{serviceId}/images/reorder` - Reorder images

### Availability Management (NEW)
- `POST /api/supplier-services/{serviceId}/availability/bulk` - Create bulk
- `GET /api/supplier-services/{serviceId}/availability` - List (with filters)
- `PUT /api/supplier-services/{serviceId}/availability/{date}` - Update single
- `PUT /api/supplier-services/{serviceId}/availability/bulk-update` - Update range
- `DELETE /api/supplier-services/{serviceId}/availability/{date}` - Delete single
- `GET /api/supplier-services/{serviceId}/availability/calendar` - Calendar data

### Seasonal Pricing (EXISTING)
- `POST /api/supplier-services/{serviceId}/seasonal-prices` - Create
- `GET /api/supplier-services/{serviceId}/seasonal-prices` - List
- `PUT /api/supplier-services/{serviceId}/seasonal-prices/{id}` - Update
- `DELETE /api/supplier-services/{serviceId}/seasonal-prices/{id}` - Delete

---

## 🎯 TECHNICAL DECISIONS

### Why Separate Tables?

**SupplierServiceSeasonalPrice vs SupplierServiceAvailability**:
- Different purposes: Seasonal = pricing strategy, Availability = inventory management
- Different granularity: Seasonal = date ranges, Availability = individual dates
- Different update frequency: Seasonal = quarterly/yearly, Availability = daily
- Easier to query and maintain separately

### Why Seasonal Price Overrides Availability?

**Business Logic**:
- Seasonal pricing = strategic pricing decisions (high season, holidays)
- Availability pricing = operational pricing (daily adjustments)
- Strategic decisions should take precedence over operational ones
- Example: High season pricing should apply regardless of daily availability price

### Why Custom Calendar Component?

**Reasons**:
- FullCalendar: Too heavy, overkill for simple date management
- PrimeNG Calendar: Lacks event management features
- Custom: Lightweight, tailored to exact needs, better performance
- Can reuse for other features (booking calendar, etc.)

---

## 🔐 SECURITY & VALIDATION

### Image Upload
- File type validation: JPG, PNG, WebP only
- File size limit: 10MB (configurable)
- Max 5 images per service
- Virus scanning: Consider adding in production

### Availability Management
- Date validation: Cannot create availability for past dates
- Price validation: Must be positive number
- Authorization: Only service owner can manage availability

### Publishing
- Validation: Must have availability before publish
- Authorization: Only service owner can publish
- Audit: Log publish/unpublish actions

---

## 📱 USER EXPERIENCE FLOW

### Creating a New Service

**Step 1: Basic Information**
- Fill service type, name, description
- Set base price and currency
- Add location
- Status automatically set to "draft"
- Save → Service created with ID

**Step 2: Service Details** (Optional but recommended)
- Dynamic form based on service type
- Fill type-specific information
- Save → Updates service_details JSON

**Step 3: Upload Images** (Optional but recommended)
- Upload up to 5 images
- Drag to reorder
- First image = primary thumbnail
- Save → Images stored in MinIO

**Step 4: Set Availability** (REQUIRED for publish)
- Select date range
- Set base price for range
- Generate availability records
- View in calendar
- Edit individual dates if needed
- Save → Availability records created

**Step 5: Seasonal Pricing** (Optional)
- Add seasonal price adjustments
- Define date ranges and prices
- Seasonal prices will override availability prices
- Save → Seasonal pricing records created

**Step 6: Publish**
- Click "Publish" button
- System validates:
  - ✅ Has availability records
  - ✅ Service details completed
  - ⚠️ Has images (warning only)
- If valid → Status changes to "published"
- Service now visible in marketplace

---

## 🧪 TESTING SCENARIOS

### Scenario 1: Create Hotel Service
1. Create service: "Hotel Grand Makkah 5 Star - Deluxe Twin"
2. Fill hotel details: property name, star rating, room type
3. Upload 3 images
4. Set availability: Mar 1-31, 2026 at 2,500,000 IDR
5. Add seasonal: Mar 1-15 (High Season) at 3,500,000 IDR
6. Publish service
7. Verify: Mar 1-15 shows 3,500,000, Mar 16-31 shows 2,500,000

### Scenario 2: Try to Publish Without Availability
1. Create service: "Flight CGK-JED Business Class"
2. Fill flight details
3. Upload 2 images
4. Try to publish → Should FAIL with error
5. Add availability: Apr 1-30, 2026
6. Publish → Should SUCCESS

### Scenario 3: Bulk Edit Availability
1. Service has availability for Mar 1-10
2. Bulk edit: Mar 5-15 with new price
3. Result: Mar 5-10 updated, Mar 11-15 created new
4. Verify in calendar view

---

## 📦 DELIVERABLES

### Backend
1. Migration script to refactor SupplierService table
2. New entities: SupplierServiceImage, SupplierServiceAvailability
3. Commands and Handlers for all operations
4. Queries for data retrieval
5. API endpoints in controllers
6. Unit tests for business logic

### Frontend
1. Updated service form (already done)
2. Image upload component with preview
3. Availability management component
4. Custom calendar component
5. Publish validation modal
6. Updated service list with publish button

### Documentation
1. API documentation (Swagger)
2. User guide for service management
3. Developer guide for extending service types

---

## 🚀 NEXT STEPS

1. **Review this document** - Confirm all requirements are correct
2. **Create Specs** - Break down into implementable tasks
3. **Phase 1**: Backend refactoring (foundation)
4. **Phase 2**: Image upload system
5. **Phase 3**: Availability management
6. **Phase 4**: Publishing workflow

---

## 📝 NOTES & CONSIDERATIONS

### Performance
- Availability records can grow large (365 days × N services)
- Consider pagination for availability list
- Calendar view should load only visible month
- Index on (supplier_service_id, date) for fast queries

### Future Enhancements
- Bulk import availability from CSV
- Copy availability from another service
- Availability templates (e.g., "Weekday pricing", "Weekend pricing")
- Availability history and audit log
- Price analytics and recommendations

### Migration Strategy
- Phase 1 requires data migration for existing services
- Existing type-specific data should be moved to service_details JSON
- Provide migration script to convert old structure to new
- Backward compatibility during transition period

---

**Document Version**: 1.0  
**Last Updated**: March 18, 2026  
**Author**: Kiro AI Assistant  
**Reviewed By**: Fatur Gautama
