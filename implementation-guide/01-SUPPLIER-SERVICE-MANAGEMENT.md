# Phase 1: Supplier Service Management

## 📋 Overview

### What We're Building
Suppliers can create services with 8 types (hotel, flight, visa, transport, guide, insurance, catering, handling) and store type-specific details as JSON without backend validation.

### Features
- Create service with dynamic JSON details
- Upload up to 5 images per service
- Set payment terms (DP + full payment)
- Publish/unpublish services
- List and filter services

### Success Criteria
- ✅ Supplier can create service with any valid JSON
- ✅ Service code auto-generated and unique
- ✅ Images stored in MinIO
- ✅ Services visible in marketplace when published

---

## 🎨 Flow Diagram

```
[Supplier Portal]
      │
      ├─► Navigate to "My Services"
      │
      ├─► Click "Create Service"
      │
      ├─► Fill Form:
      │   ├─► Service Type: [Dropdown] ◄─── 8 options
      │   ├─► Name: [Text Input]
      │   ├─► Description: [Textarea]
      │   ├─► Base Price: [Number Input]
      │   ├─► Currency: [Dropdown] (default: IDR)
      │   ├─► Location: [City, Country]
      │   └─► Service Details: [JSON Editor]
      │       └─► Dynamic based on type
      │
      ├─► Payment Terms (Optional):
      │   ├─► Enable: [Toggle]
      │   ├─► DP %: [Slider 10-90]
      │   └─► Due Days: [Number 1-60]
      │
      ├─► Click "Save as Draft"
      │   │
      │   └─► POST /api/supplier-services
      │       ├─► Validate input
      │       ├─► Generate service_code
      │       ├─► Save to DB (status: draft)
      │       └─► Return service_id
      │
      ├─► Redirect to Service Detail Page
      │
      ├─► Upload Images:
      │   ├─► Click "Add Image"
      │   ├─► Select file (JPG/PNG/WebP)
      │   ├─► POST /api/supplier-services/{id}/images
      │   ├─► Upload to MinIO
      │   ├─► Save metadata to DB
      │   └─► Display thumbnail
      │
      └─► Click "Publish"
          └─► POST /api/supplier-services/{id}/publish
              ├─► Validate: has name, price, type
              ├─► Update status: draft → published
              └─► Show success message
```

---

## 🔧 BACKEND IMPLEMENTATION

### Step 1.1: Create SupplierService Entity

**File**: `TourTravel.Domain/Entities/SupplierService.cs`

**Action**: CREATE new file

**Code**:
```csharp
namespace TourTravel.Domain.Entities;

public class SupplierService
{
    public Guid Id { get; set; }
    public Guid SupplierId { get; set; }
    public string ServiceCode { get; set; } = string.Empty;
    public string ServiceType { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    
    // Pricing
    public decimal BasePrice { get; set; }
    public string Currency { get; set; } = "IDR";
    
    // Location
    public string? LocationCity { get; set; }
    public string? LocationCountry { get; set; }
    
    // Dynamic Details - NO VALIDATION
    public string? ServiceDetails { get; set; }
    
    // Payment Terms
    public bool PaymentTermsEnabled { get; set; }
    public int? DownPaymentPercentage { get; set; }
    public int? FullPaymentDueDays { get; set; }
    
    // Status
    public string Status { get; set; } = "draft";
    public string Visibility { get; set; } = "public";
    
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation
    public Supplier Supplier { get; set; } = null!;
    public ICollection<SupplierServiceImage> Images { get; set; } = new List<SupplierServiceImage>();
    public ICollection<ServiceAvailability> Availabilities { get; set; } = new List<ServiceAvailability>();
}
```

**Why**: Core entity with JSONB field for flexible type-specific data.

---

### Step 1.2: Create SupplierServiceImage Entity

**File**: `TourTravel.Domain/Entities/SupplierServiceImage.cs`

**Action**: CREATE new file

**Code**:
```csharp
namespace TourTravel.Domain.Entities;

public class SupplierServiceImage
{
    public Guid Id { get; set; }
    public Guid SupplierServiceId { get; set; }
    public string FilePath { get; set; } = string.Empty;
    public string FileUrl { get; set; } = string.Empty;
    public int DisplayOrder { get; set; }
    public bool IsPrimary { get; set; }
    public DateTime CreatedAt { get; set; }
    
    // Navigation
    public SupplierService SupplierService { get; set; } = null!;
}
```

---

### Step 1.3: Create EF Core Configuration

**File**: `TourTravel.Infrastructure/Data/Configurations/SupplierServiceConfiguration.cs`

**Action**: CREATE new file

**Code**:
```csharp
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TourTravel.Domain.Entities;

namespace TourTravel.Infrastructure.Data.Configurations;

public class SupplierServiceConfiguration : IEntityTypeConfiguration<SupplierService>
{
    public void Configure(EntityTypeBuilder<SupplierService> builder)
    {
        builder.ToTable("supplier_services");
        
        builder.HasKey(x => x.Id);
        
        builder.Property(x => x.ServiceCode)
            .HasColumnName("ServiceCode")
            .HasMaxLength(50)
            .IsRequired();
        
        builder.Property(x => x.ServiceType)
            .HasColumnName("ServiceType")
            .HasMaxLength(50)
            .IsRequired();
        
        builder.Property(x => x.ServiceDetails)
            .HasColumnName("ServiceDetails")
            .HasColumnType("jsonb"); // PostgreSQL JSONB
        
        // ... other properties
        
        builder.HasIndex(x => x.ServiceCode)
            .HasDatabaseName("IX_SupplierServices_ServiceCode")
            .IsUnique();
    }
}
```

---

