# Self-Registration with KYC Verification - Design Document

## Overview

This document extends the main design document with specifications for Self-Registration and KYC (Know Your Customer) Verification features for both Agencies and Suppliers. This feature enables entities to register themselves and upload required documents for platform admin verification before gaining full access to the platform.

### Key Features

1. **Agency Self-Registration**: Public registration form for travel agencies
2. **Enhanced Supplier Self-Registration**: Extended with service type selection
3. **Document Management**: Upload, verify, and manage KYC documents
4. **MinIO Integration**: S3-compatible object storage for documents
5. **Verification Workflow**: Multi-step approval process with re-submission capability
6. **Access Control**: Limited access until verification is complete

### Architecture Integration

This feature integrates with existing Clean Architecture layers:
- **API Layer**: New controllers for registration and document management
- **Application Layer**: New commands/queries for KYC workflow
- **Domain Layer**: Extended entities with verification status
- **Infrastructure Layer**: MinIO file storage service

---

## Database Schema Changes

### Modified Tables

#### agencies (ALTER TABLE)

```sql
-- Add KYC verification fields
ALTER TABLE agencies 
    ADD COLUMN IF NOT EXISTS business_type VARCHAR(100) DEFAULT 'Individual',
    ADD COLUMN IF NOT EXISTS business_license_number VARCHAR(100),
    ADD COLUMN IF NOT EXISTS tax_id VARCHAR(100),
    ADD COLUMN IF NOT EXISTS verification_status VARCHAR(50) DEFAULT 'pending_documents',
    ADD COLUMN IF NOT EXISTS verification_attempts INT DEFAULT 0,
    ADD COLUMN IF NOT EXISTS max_verification_attempts INT DEFAULT 3,
    ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
    ADD COLUMN IF NOT EXISTS verified_at TIMESTAMP,
    ADD COLUMN IF NOT EXISTS verified_by UUID REFERENCES users(id),
    ADD COLUMN IF NOT EXISTS owner_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS country VARCHAR(100) DEFAULT 'Indonesia';

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_agencies_verification_status ON agencies(verification_status);
CREATE INDEX IF NOT EXISTS idx_agencies_business_license ON agencies(business_license_number);
CREATE INDEX IF NOT EXISTS idx_agencies_tax_id ON agencies(tax_id);

-- Add unique constraints (nullable, so only enforced when not null)
ALTER TABLE agencies ADD CONSTRAINT uq_agencies_business_license UNIQUE (business_license_number);
ALTER TABLE agencies ADD CONSTRAINT uq_agencies_tax_id UNIQUE (tax_id);
```

**New Fields:**
- business_type: Type of business entity (PT, CV, Individual, etc.)
- business_license_number: NIB or business license number
- tax_id: NPWP (tax identification number)
- verification_status: Current verification status (pending_documents, awaiting_approval, verified, rejected)
- verification_attempts: Number of times entity has been rejected and re-submitted
- max_verification_attempts: Maximum allowed re-submission attempts (default: 3)
- rejection_reason: Reason for rejection (if rejected)
- verified_at: Timestamp when entity was verified
- verified_by: Platform admin who verified the entity
- owner_name: Name of business owner
- country: Country of business operation


#### suppliers (ALTER TABLE)

```sql
-- Add KYC verification fields
ALTER TABLE suppliers 
    ADD COLUMN IF NOT EXISTS verification_status VARCHAR(50) DEFAULT 'pending_documents',
    ADD COLUMN IF NOT EXISTS verification_attempts INT DEFAULT 0,
    ADD COLUMN IF NOT EXISTS max_verification_attempts INT DEFAULT 3,
    ADD COLUMN IF NOT EXISTS owner_name VARCHAR(255),
    ADD COLUMN IF NOT EXISTS service_types TEXT[] DEFAULT '{}';

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_suppliers_verification_status ON suppliers(verification_status);
CREATE INDEX IF NOT EXISTS idx_suppliers_service_types ON suppliers USING GIN(service_types);
```

**New Fields:**
- verification_status: Current verification status (same as agencies)
- verification_attempts: Number of re-submission attempts
- max_verification_attempts: Maximum allowed attempts (default: 3)
- owner_name: Name of business owner
- service_types: Array of service types supplier will provide (hotel, flight, visa, etc.)

**Note:** `status` field (existing) remains for active/suspended state, while `verification_status` tracks KYC verification state.

---

### New Tables

#### document_requirements

Stores configuration for which documents are required for each entity type and service type.

```sql
CREATE TABLE IF NOT EXISTS document_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- 'agency' or 'supplier'
    service_type VARCHAR(50), -- NULL for general, or specific service type
    document_type VARCHAR(100) NOT NULL, -- 'ktp', 'npwp', 'nib', 'hotel_license', etc.
    document_category VARCHAR(50) NOT NULL, -- 'identity', 'business_legal', 'operational', 'service_specific'
    document_label VARCHAR(255) NOT NULL, -- Display name for UI
    document_description TEXT, -- Help text for users
    is_mandatory BOOLEAN DEFAULT true,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_doc_requirements_entity ON document_requirements(entity_type, service_type);
CREATE INDEX idx_doc_requirements_active ON document_requirements(is_active);
```

**Purpose:** Defines which documents are required for verification. Platform admin can configure this.

**Example Records:**
- entity_type='agency', service_type=NULL, document_type='ktp', is_mandatory=true
- entity_type='supplier', service_type='hotel', document_type='hotel_license', is_mandatory=true


#### entity_documents

Stores metadata for uploaded documents. Actual files are stored in MinIO.

```sql
CREATE TABLE IF NOT EXISTS entity_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(50) NOT NULL, -- 'agency' or 'supplier'
    entity_id UUID NOT NULL, -- agency_id or supplier_id
    document_type VARCHAR(100) NOT NULL,
    document_category VARCHAR(50) NOT NULL,
    is_mandatory BOOLEAN DEFAULT true,
    file_url TEXT, -- Relative path in MinIO (e.g., 'agencies/AGN-001/ktp_abc123.pdf')
    file_name VARCHAR(255),
    file_size BIGINT, -- in bytes
    mime_type VARCHAR(100),
    verification_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'verified', 'rejected'
    rejection_reason TEXT,
    uploaded_at TIMESTAMP,
    verified_at TIMESTAMP,
    verified_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_entity_documents_entity ON entity_documents(entity_type, entity_id);
CREATE INDEX idx_entity_documents_status ON entity_documents(verification_status);
CREATE INDEX idx_entity_documents_type ON entity_documents(document_type);
CREATE INDEX idx_entity_documents_mandatory ON entity_documents(is_mandatory);
```

**Purpose:** Tracks all documents uploaded by agencies and suppliers.

**Polymorphic Relationship:**
- entity_type + entity_id creates a polymorphic relationship to either agencies or suppliers table
- This allows single table to handle documents for both entity types

**File Storage:**
- file_url stores relative path in MinIO (not full URL)
- Full URL is generated on-demand using MinIO presigned URLs


---

## Domain Entities (Extended)

### Agency (Extended)

```csharp
public class Agency
{
    // Existing properties...
    public Guid Id { get; set; }
    public string AgencyCode { get; set; }
    public string CompanyName { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public string Address { get; set; }
    public string City { get; set; }
    public string Province { get; set; }
    public string PostalCode { get; set; }
    public bool IsActive { get; set; }
    
    // NEW: KYC Verification properties
    public string BusinessType { get; set; } // PT, CV, Individual
    public string BusinessLicenseNumber { get; set; }
    public string TaxId { get; set; } // NPWP
    public string VerificationStatus { get; set; } // pending_documents, awaiting_approval, verified, rejected
    public int VerificationAttempts { get; set; }
    public int MaxVerificationAttempts { get; set; }
    public string RejectionReason { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public Guid? VerifiedBy { get; set; }
    public string OwnerName { get; set; }
    public string Country { get; set; }
    
    // Navigation properties
    public User VerifiedByUser { get; set; }
    public ICollection<EntityDocument> Documents { get; set; }
    
    // NEW: Business logic methods
    public bool CanResubmit() => VerificationAttempts < MaxVerificationAttempts;
    public bool IsVerified() => VerificationStatus == "verified";
    public bool IsPendingDocuments() => VerificationStatus == "pending_documents";
    public bool IsAwaitingApproval() => VerificationStatus == "awaiting_approval";
    public bool IsRejected() => VerificationStatus == "rejected";
    
    public void MarkAsAwaitingApproval()
    {
        VerificationStatus = "awaiting_approval";
    }
    
    public void Approve(Guid approvedBy)
    {
        VerificationStatus = "verified";
        VerifiedAt = DateTime.UtcNow;
        VerifiedBy = approvedBy;
        IsActive = true;
    }
    
    public void Reject(string reason, Guid rejectedBy)
    {
        VerificationStatus = "rejected";
        RejectionReason = reason;
        VerificationAttempts++;
        IsActive = false;
    }
    
    public void ResetForResubmission()
    {
        VerificationStatus = "pending_documents";
        RejectionReason = null;
    }
}
```


### Supplier (Extended)

```csharp
public class Supplier
{
    // Existing properties...
    public Guid Id { get; set; }
    public string SupplierCode { get; set; }
    public string CompanyName { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public string Address { get; set; }
    public string City { get; set; }
    public string Province { get; set; }
    public string PostalCode { get; set; }
    public string Country { get; set; }
    public string BusinessType { get; set; }
    public string BusinessLicenseNumber { get; set; }
    public string TaxId { get; set; }
    public string Status { get; set; } // pending, active, rejected, suspended
    public DateTime? ApprovedAt { get; set; }
    public Guid? ApprovedBy { get; set; }
    public string RejectionReason { get; set; }
    
    // NEW: KYC Verification properties
    public string VerificationStatus { get; set; } // pending_documents, awaiting_approval, verified, rejected
    public int VerificationAttempts { get; set; }
    public int MaxVerificationAttempts { get; set; }
    public string OwnerName { get; set; }
    public string[] ServiceTypes { get; set; } // Array: ['hotel', 'transport', 'catering']
    public DateTime? VerifiedAt { get; set; }
    public Guid? VerifiedBy { get; set; }
    
    // Navigation properties
    public User VerifiedByUser { get; set; }
    public ICollection<EntityDocument> Documents { get; set; }
    
    // NEW: Business logic methods
    public bool CanResubmit() => VerificationAttempts < MaxVerificationAttempts;
    public bool IsVerified() => VerificationStatus == "verified";
    public bool IsPendingDocuments() => VerificationStatus == "pending_documents";
    public bool IsAwaitingApproval() => VerificationStatus == "awaiting_approval";
    public bool IsRejected() => VerificationStatus == "rejected";
    
    public void MarkAsAwaitingApproval()
    {
        VerificationStatus = "awaiting_approval";
    }
    
    public void Approve(Guid approvedBy)
    {
        VerificationStatus = "verified";
        VerifiedAt = DateTime.UtcNow;
        VerifiedBy = approvedBy;
        Status = "active";
        ApprovedAt = DateTime.UtcNow;
        ApprovedBy = approvedBy;
    }
    
    public void Reject(string reason, Guid rejectedBy)
    {
        VerificationStatus = "rejected";
        RejectionReason = reason;
        VerificationAttempts++;
        Status = "rejected";
    }
    
    public void ResetForResubmission()
    {
        VerificationStatus = "pending_documents";
        RejectionReason = null;
    }
}
```


### DocumentRequirement (New Entity)

```csharp
public class DocumentRequirement
{
    public Guid Id { get; set; }
    public string EntityType { get; set; } // 'agency' or 'supplier'
    public string ServiceType { get; set; } // NULL for general, or specific service type
    public string DocumentType { get; set; } // 'ktp', 'npwp', 'nib', etc.
    public string DocumentCategory { get; set; } // 'identity', 'business_legal', 'operational', 'service_specific'
    public string DocumentLabel { get; set; } // Display name
    public string DocumentDescription { get; set; } // Help text
    public bool IsMandatory { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

### EntityDocument (New Entity)

```csharp
public class EntityDocument
{
    public Guid Id { get; set; }
    public string EntityType { get; set; } // 'agency' or 'supplier'
    public Guid EntityId { get; set; } // agency_id or supplier_id
    public string DocumentType { get; set; }
    public string DocumentCategory { get; set; }
    public bool IsMandatory { get; set; }
    public string FileUrl { get; set; } // Relative path in MinIO
    public string FileName { get; set; }
    public long FileSize { get; set; }
    public string MimeType { get; set; }
    public string VerificationStatus { get; set; } // 'pending', 'verified', 'rejected'
    public string RejectionReason { get; set; }
    public DateTime? UploadedAt { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public Guid? VerifiedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation properties
    public User VerifiedByUser { get; set; }
    
    // Business logic methods
    public bool IsVerified() => VerificationStatus == "verified";
    public bool IsRejected() => VerificationStatus == "rejected";
    public bool IsPending() => VerificationStatus == "pending";
    
    public void Verify(Guid verifiedBy)
    {
        VerificationStatus = "verified";
        VerifiedAt = DateTime.UtcNow;
        VerifiedBy = verifiedBy;
        RejectionReason = null;
    }
    
    public void Reject(string reason, Guid rejectedBy)
    {
        VerificationStatus = "rejected";
        RejectionReason = reason;
        VerifiedAt = DateTime.UtcNow;
        VerifiedBy = rejectedBy;
    }
}
```

---

## Infrastructure Services

### IFileStorageService Interface

```csharp
public interface IFileStorageService
{
    Task<FileUploadResult> UploadAsync(IFormFile file, string folder, string customFileName = null);
    Task<Stream> DownloadAsync(string filePath);
    Task<bool> DeleteAsync(string filePath);
    Task<bool> ExistsAsync(string filePath);
    string GetFileUrl(string filePath);
}

public class FileUploadResult
{
    public string FileName { get; set; }
    public string FilePath { get; set; } // Relative path for DB storage
    public string FileUrl { get; set; } // Full presigned URL for access
    public long FileSize { get; set; }
    public string MimeType { get; set; }
}
```


### MinIOFileStorageService Implementation

```csharp
public class MinIOFileStorageService : IFileStorageService
{
    private readonly IMinioClient _minioClient;
    private readonly string _bucketName;
    private readonly long _maxFileSize;
    private readonly string[] _allowedExtensions;
    private readonly ILogger<MinIOFileStorageService> _logger;

    public MinIOFileStorageService(
        IConfiguration config,
        ILogger<MinIOFileStorageService> logger)
    {
        var endpoint = config["FileStorage:Endpoint"];
        var accessKey = config["FileStorage:AccessKey"];
        var secretKey = config["FileStorage:SecretKey"];
        var useSSL = bool.Parse(config["FileStorage:UseSSL"] ?? "false");
        
        _bucketName = config["FileStorage:BucketName"];
        _maxFileSize = long.Parse(config["FileStorage:MaxFileSizeMB"]) * 1024 * 1024;
        _allowedExtensions = config.GetSection("FileStorage:AllowedExtensions").Get<string[]>();
        _logger = logger;

        _minioClient = new MinioClient()
            .WithEndpoint(endpoint)
            .WithCredentials(accessKey, secretKey)
            .WithSSL(useSSL)
            .Build();

        EnsureBucketExistsAsync().Wait();
    }

    private async Task EnsureBucketExistsAsync()
    {
        var beArgs = new BucketExistsArgs().WithBucket(_bucketName);
        bool found = await _minioClient.BucketExistsAsync(beArgs);
        
        if (!found)
        {
            var mbArgs = new MakeBucketArgs().WithBucket(_bucketName);
            await _minioClient.MakeBucketAsync(mbArgs);
            _logger.LogInformation("Created MinIO bucket: {BucketName}", _bucketName);
        }
    }

    public async Task<FileUploadResult> UploadAsync(IFormFile file, string folder, string customFileName = null)
    {
        // Validation
        if (file.Length > _maxFileSize)
            throw new InvalidOperationException($"File size exceeds {_maxFileSize / 1024 / 1024}MB limit");

        var extension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!_allowedExtensions.Contains(extension))
            throw new InvalidOperationException($"File type {extension} is not allowed");

        // Generate object name
        var fileName = customFileName ?? $"{Guid.NewGuid()}{extension}";
        var objectName = $"{folder}/{fileName}";

        // Upload to MinIO
        using (var stream = file.OpenReadStream())
        {
            var putArgs = new PutObjectArgs()
                .WithBucket(_bucketName)
                .WithObject(objectName)
                .WithStreamData(stream)
                .WithObjectSize(file.Length)
                .WithContentType(file.ContentType);

            await _minioClient.PutObjectAsync(putArgs);
        }

        _logger.LogInformation("Uploaded file to MinIO: {ObjectName}", objectName);

        return new FileUploadResult
        {
            FileName = fileName,
            FilePath = objectName,
            FileUrl = GetFileUrl(objectName),
            FileSize = file.Length,
            MimeType = file.ContentType
        };
    }

    public async Task<Stream> DownloadAsync(string filePath)
    {
        var memoryStream = new MemoryStream();
        
        var getArgs = new GetObjectArgs()
            .WithBucket(_bucketName)
            .WithObject(filePath)
            .WithCallbackStream(stream => stream.CopyTo(memoryStream));

        await _minioClient.GetObjectAsync(getArgs);
        
        memoryStream.Position = 0;
        return memoryStream;
    }

    public async Task<bool> DeleteAsync(string filePath)
    {
        try
        {
            var removeArgs = new RemoveObjectArgs()
                .WithBucket(_bucketName)
                .WithObject(filePath);

            await _minioClient.RemoveObjectAsync(removeArgs);
            _logger.LogInformation("Deleted file from MinIO: {FilePath}", filePath);
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to delete file from MinIO: {FilePath}", filePath);
            return false;
        }
    }

    public async Task<bool> ExistsAsync(string filePath)
    {
        try
        {
            var statArgs = new StatObjectArgs()
                .WithBucket(_bucketName)
                .WithObject(filePath);

            await _minioClient.StatObjectAsync(statArgs);
            return true;
        }
        catch
        {
            return false;
        }
    }

    public string GetFileUrl(string filePath)
    {
        // Generate presigned URL (valid for 7 days)
        var presignedArgs = new PresignedGetObjectArgs()
            .WithBucket(_bucketName)
            .WithObject(filePath)
            .WithExpiry(60 * 60 * 24 * 7); // 7 days

        return _minioClient.PresignedGetObjectAsync(presignedArgs).Result;
    }
}
```

**Configuration (appsettings.json):**
```json
{
  "FileStorage": {
    "StorageType": "MinIO",
    "Endpoint": "localhost:9000",
    "AccessKey": "YOUR_ACCESS_KEY",
    "SecretKey": "YOUR_SECRET_KEY",
    "BucketName": "tour-travel-documents",
    "UseSSL": false,
    "Region": "us-east-1",
    "MaxFileSizeMB": 10,
    "AllowedExtensions": [".pdf", ".jpg", ".jpeg", ".png", ".doc", ".docx"]
  }
}
```

**Service Registration (Program.cs):**
```csharp
builder.Services.AddSingleton<IFileStorageService, MinIOFileStorageService>();
```

---

## Application Layer

### Commands

#### RegisterAgencyCommand

```csharp
public class RegisterAgencyCommand : IRequest<RegisterAgencyResponse>
{
    public string CompanyName { get; set; }
    public string OwnerName { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public string BusinessType { get; set; } // PT, CV, Individual
    public string Password { get; set; }
    public string ConfirmPassword { get; set; }
}

public class RegisterAgencyResponse
{
    public Guid AgencyId { get; set; }
    public string AgencyCode { get; set; }
    public string Message { get; set; }
    public string RedirectUrl { get; set; } // URL to document upload page
}
```


#### RegisterSupplierCommand (Enhanced)

```csharp
public class RegisterSupplierCommand : IRequest<RegisterSupplierResponse>
{
    public string CompanyName { get; set; }
    public string OwnerName { get; set; }
    public string Email { get; set; }
    public string Phone { get; set; }
    public string BusinessType { get; set; }
    public string[] ServiceTypes { get; set; } // ['hotel', 'transport', 'catering']
    public string Password { get; set; }
    public string ConfirmPassword { get; set; }
    public string Address { get; set; }
    public string City { get; set; }
    public string Province { get; set; }
    public string PostalCode { get; set; }
    public string Country { get; set; }
}

public class RegisterSupplierResponse
{
    public Guid SupplierId { get; set; }
    public string SupplierCode { get; set; }
    public string Message { get; set; }
    public string RedirectUrl { get; set; }
}
```

#### UploadDocumentCommand

```csharp
public class UploadDocumentCommand : IRequest<UploadDocumentResponse>
{
    public IFormFile File { get; set; }
    public string EntityType { get; set; } // 'agency' or 'supplier'
    public Guid EntityId { get; set; }
    public string DocumentType { get; set; }
}

public class UploadDocumentResponse
{
    public Guid DocumentId { get; set; }
    public string FileUrl { get; set; }
    public string Message { get; set; }
}
```

#### VerifyDocumentCommand

```csharp
public class VerifyDocumentCommand : IRequest<Unit>
{
    public Guid DocumentId { get; set; }
    public Guid VerifiedBy { get; set; }
}
```

#### RejectDocumentCommand

```csharp
public class RejectDocumentCommand : IRequest<Unit>
{
    public Guid DocumentId { get; set; }
    public string RejectionReason { get; set; }
    public Guid RejectedBy { get; set; }
}
```

#### ApproveEntityCommand

```csharp
public class ApproveEntityCommand : IRequest<Unit>
{
    public string EntityType { get; set; }
    public Guid EntityId { get; set; }
    public Guid ApprovedBy { get; set; }
}
```

#### RejectEntityCommand

```csharp
public class RejectEntityCommand : IRequest<Unit>
{
    public string EntityType { get; set; }
    public Guid EntityId { get; set; }
    public string RejectionReason { get; set; }
    public Guid RejectedBy { get; set; }
}
```

### Queries

#### GetDocumentProgressQuery

```csharp
public class GetDocumentProgressQuery : IRequest<DocumentProgressResponse>
{
    public string EntityType { get; set; }
    public Guid EntityId { get; set; }
}

public class DocumentProgressResponse
{
    public int TotalMandatoryDocuments { get; set; }
    public int UploadedDocuments { get; set; }
    public int VerifiedDocuments { get; set; }
    public int RejectedDocuments { get; set; }
    public decimal CompletionPercentage { get; set; }
    public string VerificationStatus { get; set; }
    public int VerificationAttempts { get; set; }
    public int MaxVerificationAttempts { get; set; }
    public bool CanResubmit { get; set; }
}
```

#### GetVerificationQueueQuery

```csharp
public class GetVerificationQueueQuery : IRequest<PagedResult<VerificationQueueItem>>
{
    public string EntityType { get; set; } // Filter by entity type
    public string VerificationStatus { get; set; } // Filter by status
    public DateTime? FromDate { get; set; }
    public DateTime? ToDate { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 20;
}

public class VerificationQueueItem
{
    public Guid EntityId { get; set; }
    public string EntityType { get; set; }
    public string EntityCode { get; set; }
    public string CompanyName { get; set; }
    public string OwnerName { get; set; }
    public string Email { get; set; }
    public string VerificationStatus { get; set; }
    public int DocumentsUploaded { get; set; }
    public int DocumentsVerified { get; set; }
    public int DocumentsRejected { get; set; }
    public DateTime CreatedAt { get; set; }
}
```

#### GetEntityDocumentsQuery

```csharp
public class GetEntityDocumentsQuery : IRequest<List<EntityDocumentDto>>
{
    public string EntityType { get; set; }
    public Guid EntityId { get; set; }
}

public class EntityDocumentDto
{
    public Guid Id { get; set; }
    public string DocumentType { get; set; }
    public string DocumentLabel { get; set; }
    public string DocumentCategory { get; set; }
    public bool IsMandatory { get; set; }
    public string FileName { get; set; }
    public long FileSize { get; set; }
    public string FileUrl { get; set; }
    public string VerificationStatus { get; set; }
    public string RejectionReason { get; set; }
    public DateTime? UploadedAt { get; set; }
    public DateTime? VerifiedAt { get; set; }
}
```

---

## API Endpoints

### Public Endpoints (No Authentication)

#### POST /api/auth/register/agency
Register new agency.

**Request:**
```json
{
  "company_name": "Makkah Travel Indonesia",
  "owner_name": "Ahmad Hidayat",
  "email": "info@makkahtravel.com",
  "phone": "+628123456789",
  "business_type": "PT",
  "password": "SecurePass123!",
  "confirm_password": "SecurePass123!"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "agency_id": "uuid",
    "agency_code": "AGN-260221-001",
    "message": "Registration successful. Please upload required documents.",
    "redirect_url": "/documents/upload"
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### POST /api/auth/register/supplier
Register new supplier with service types.

**Request:**
```json
{
  "company_name": "Grand Hotel Makkah",
  "owner_name": "Abdullah Rahman",
  "email": "info@grandhotel.com",
  "phone": "+966123456789",
  "business_type": "PT",
  "service_types": ["hotel", "catering"],
  "password": "SecurePass123!",
  "confirm_password": "SecurePass123!",
  "address": "King Fahd Road",
  "city": "Makkah",
  "province": "Makkah Province",
  "postal_code": "12345",
  "country": "Saudi Arabia"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "supplier_id": "uuid",
    "supplier_code": "SUP-260221-001",
    "message": "Registration successful. Please upload required documents.",
    "redirect_url": "/documents/upload"
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```


### Agency/Supplier Endpoints (Authenticated)

#### POST /api/documents/upload
Upload document for KYC verification.

**Headers:**
```
Authorization: Bearer {jwt_token}
Content-Type: multipart/form-data
```

**Request (Form Data):**
```
file: [binary file]
document_type: "ktp"
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "document_id": "uuid",
    "file_url": "https://minio.example.com/presigned-url",
    "message": "Document uploaded successfully"
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### GET /api/documents
Get list of documents for current user's entity.

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "document_type": "ktp",
      "document_label": "KTP Pemilik/Direktur",
      "document_category": "identity",
      "is_mandatory": true,
      "file_name": "ktp_abc123.pdf",
      "file_size": 1024000,
      "file_url": "https://minio.example.com/presigned-url",
      "verification_status": "verified",
      "rejection_reason": null,
      "uploaded_at": "2026-02-21T10:00:00Z",
      "verified_at": "2026-02-21T11:00:00Z"
    }
  ],
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### GET /api/documents/progress
Get document upload progress and verification status.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "total_mandatory_documents": 10,
    "uploaded_documents": 8,
    "verified_documents": 5,
    "rejected_documents": 2,
    "completion_percentage": 80.0,
    "verification_status": "awaiting_approval",
    "verification_attempts": 1,
    "max_verification_attempts": 3,
    "can_resubmit": true
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### GET /api/documents/{id}/download
Download document file.

**Response (200 OK):**
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="ktp_abc123.pdf"
[binary file content]
```

#### DELETE /api/documents/{id}
Delete document (only if status is pending or rejected).

**Response (204 No Content)**

### Platform Admin Endpoints (Authenticated, Admin Only)

#### GET /api/admin/verification-queue
Get list of entities awaiting verification.

**Query Parameters:**
- entity_type: 'agency' | 'supplier' (optional)
- verification_status: 'pending_documents' | 'awaiting_approval' | 'verified' | 'rejected' (optional)
- from_date: ISO 8601 date (optional)
- to_date: ISO 8601 date (optional)
- page: integer (default: 1)
- page_size: integer (default: 20)

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "entity_id": "uuid",
      "entity_type": "agency",
      "entity_code": "AGN-260221-001",
      "company_name": "Makkah Travel Indonesia",
      "owner_name": "Ahmad Hidayat",
      "email": "info@makkahtravel.com",
      "verification_status": "awaiting_approval",
      "documents_uploaded": 10,
      "documents_verified": 0,
      "documents_rejected": 0,
      "created_at": "2026-02-21T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total_items": 50,
    "total_pages": 3
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### GET /api/admin/verification/{entity_type}/{entity_id}
Get entity details with all documents for verification.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "entity": {
      "id": "uuid",
      "entity_type": "agency",
      "entity_code": "AGN-260221-001",
      "company_name": "Makkah Travel Indonesia",
      "owner_name": "Ahmad Hidayat",
      "email": "info@makkahtravel.com",
      "phone": "+628123456789",
      "business_type": "PT",
      "address": "Jl. Sudirman No. 123",
      "city": "Jakarta",
      "verification_status": "awaiting_approval",
      "verification_attempts": 0,
      "created_at": "2026-02-21T10:00:00Z"
    },
    "documents": [
      {
        "id": "uuid",
        "document_type": "ktp",
        "document_label": "KTP Pemilik/Direktur",
        "document_category": "identity",
        "is_mandatory": true,
        "file_name": "ktp_abc123.pdf",
        "file_size": 1024000,
        "file_url": "https://minio.example.com/presigned-url",
        "verification_status": "pending",
        "uploaded_at": "2026-02-21T10:00:00Z"
      }
    ]
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### PUT /api/admin/documents/{id}/verify
Verify a document.

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Document verified successfully",
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### PUT /api/admin/documents/{id}/reject
Reject a document with reason.

**Request:**
```json
{
  "rejection_reason": "Document is not clear. Please upload a clearer image."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Document rejected",
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### POST /api/admin/verification/{entity_type}/{entity_id}/approve
Approve entity after all mandatory documents are verified.

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Entity approved successfully. Notification sent to entity.",
  "timestamp": "2026-02-21T10:00:00Z"
}
```

**Error Response (400 Bad Request) - If not all mandatory documents verified:**
```json
{
  "success": false,
  "error": {
    "code": "BUSINESS_RULE_VIOLATION",
    "message": "Cannot approve entity. Not all mandatory documents are verified.",
    "details": [
      {
        "field": "documents",
        "message": "2 mandatory documents are still pending verification"
      }
    ]
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### POST /api/admin/verification/{entity_type}/{entity_id}/reject
Reject entity with reason.

**Request:**
```json
{
  "rejection_reason": "Business license number is invalid. Please provide valid NIB."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Entity rejected. Notification sent to entity.",
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### GET /api/admin/document-requirements
Get list of document requirements configuration.

**Query Parameters:**
- entity_type: 'agency' | 'supplier' (optional)
- service_type: service type (optional)
- is_active: boolean (optional)

**Response (200 OK):**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "entity_type": "agency",
      "service_type": null,
      "document_type": "ktp",
      "document_category": "identity",
      "document_label": "KTP Pemilik/Direktur",
      "document_description": "Upload KTP pemilik atau direktur perusahaan",
      "is_mandatory": true,
      "display_order": 1,
      "is_active": true
    }
  ],
  "timestamp": "2026-02-21T10:00:00Z"
}
```

#### POST /api/admin/document-requirements
Create new document requirement.

**Request:**
```json
{
  "entity_type": "supplier",
  "service_type": "hotel",
  "document_type": "hotel_license",
  "document_category": "service_specific",
  "document_label": "Izin Usaha Perhotelan",
  "document_description": "Upload izin usaha perhotelan dari Dinas Pariwisata",
  "is_mandatory": true,
  "display_order": 10
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "message": "Document requirement created successfully"
  },
  "timestamp": "2026-02-21T10:00:00Z"
}
```

---

## Middleware & Authorization

### VerificationStatusMiddleware

Checks verification status and restricts access for unverified entities.

```csharp
public class VerificationStatusMiddleware
{
    private readonly RequestDelegate _next;

    public VerificationStatusMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, ICurrentUserService currentUser)
    {
        // Skip for public endpoints
        if (context.Request.Path.StartsWithSegments("/api/auth") ||
            context.Request.Path.StartsWithSegments("/api/documents"))
        {
            await _next(context);
            return;
        }

        // Skip for platform admin
        if (currentUser.GetUserType() == "platform_admin")
        {
            await _next(context);
            return;
        }

        // Check verification status for agency/supplier
        var verificationStatus = currentUser.GetVerificationStatus();
        
        if (verificationStatus != "verified")
        {
            context.Response.StatusCode = 403;
            await context.Response.WriteAsJsonAsync(new
            {
                success = false,
                error = new
                {
                    code = "VERIFICATION_REQUIRED",
                    message = "Your account is not verified. Please complete document verification.",
                    details = new[]
                    {
                        new { field = "verification_status", message = verificationStatus }
                    }
                },
                timestamp = DateTime.UtcNow
            });
            return;
        }

        await _next(context);
    }
}
```

**Registration (Program.cs):**
```csharp
app.UseMiddleware<VerificationStatusMiddleware>();
```

---

## Email Notification Templates

### Registration Success Email

**Subject:** Registration Successful - Upload Documents

**Body:**
```
Dear {owner_name},

Thank you for registering with Tour & Travel ERP Platform!

Your registration has been received successfully.

Company: {company_name}
{Entity} Code: {entity_code}
Email: {email}

Next Steps:
1. Login to your account
2. Upload required documents for verification
3. Wait for admin approval (usually within 1-2 business days)

Upload Documents: {upload_url}

If you have any questions, please contact our support team.

Best regards,
Tour & Travel ERP Platform Team
```

### Documents Submitted Email

**Subject:** Documents Submitted - Verification in Progress

**Body:**
```
Dear {owner_name},

All required documents have been submitted successfully!

Our team will review your documents within 1-2 business days.
You will receive an email notification once the verification is complete.

Thank you for your patience.

Best regards,
Tour & Travel ERP Platform Team
```

### Verification Approved Email

**Subject:** Verification Approved - Welcome to Platform

**Body:**
```
Dear {owner_name},

Congratulations! Your account has been verified and approved.

You can now access all platform features.

Login: {login_url}

Welcome to Tour & Travel ERP Platform!

Best regards,
Tour & Travel ERP Platform Team
```

### Verification Rejected Email

**Subject:** Verification Rejected - Action Required

**Body:**
```
Dear {owner_name},

Unfortunately, your verification has been rejected.

Reason: {rejection_reason}

You can re-submit your documents for verification.
Remaining attempts: {remaining_attempts}

Re-submit Documents: {upload_url}

If you need assistance, please contact our support team.

Best regards,
Tour & Travel ERP Platform Team
```

---

## Correctness Properties for KYC Verification

### Property 1: Registration Uniqueness
**Property:** No two agencies can have the same email address.
```
∀ a1, a2 ∈ Agencies: a1.email = a2.email ⇒ a1.id = a2.id
```

### Property 2: Document Upload Authorization
**Property:** Only the entity owner can upload documents for their entity.
```
∀ d ∈ EntityDocuments: d.entity_id = current_user.entity_id
```

### Property 3: Verification Status Progression
**Property:** Verification status must follow valid state transitions.
```
Valid transitions:
- pending_documents → awaiting_approval (when all mandatory docs uploaded)
- awaiting_approval → verified (when admin approves)
- awaiting_approval → rejected (when admin rejects)
- rejected → pending_documents (when entity re-submits)
```

### Property 4: Mandatory Documents Completeness
**Property:** Entity can only be approved if all mandatory documents are verified.
```
∀ e ∈ Entities: e.verification_status = 'verified' ⇒ 
  ∀ d ∈ MandatoryDocuments(e): d.verification_status = 'verified'
```

### Property 5: Re-submission Limit
**Property:** Entity cannot re-submit after reaching max attempts.
```
∀ e ∈ Entities: e.verification_attempts >= e.max_verification_attempts ⇒ 
  CanResubmit(e) = false
```

### Property 6: File Storage Consistency
**Property:** Every uploaded document has a corresponding file in MinIO.
```
∀ d ∈ EntityDocuments: d.file_url ≠ null ⇒ FileExists(MinIO, d.file_url) = true
```

### Property 7: Access Control
**Property:** Unverified entities cannot access restricted endpoints.
```
∀ e ∈ Entities: e.verification_status ≠ 'verified' ⇒ 
  CanAccess(e, RestrictedEndpoints) = false
```

---

## Summary

This design document extends the main backend design with:

1. **Database Schema Changes**: ALTER TABLE for agencies/suppliers + 2 new tables
2. **Domain Entities**: Extended Agency/Supplier + new DocumentRequirement/EntityDocument
3. **Infrastructure Services**: MinIO integration with IFileStorageService
4. **Application Layer**: 6 commands + 3 queries for KYC workflow
5. **API Endpoints**: 15+ new endpoints for registration, document management, and verification
6. **Middleware**: VerificationStatusMiddleware for access control
7. **Email Templates**: 4 notification templates
8. **Correctness Properties**: 7 properties for property-based testing

The design ensures:
- **Secure document storage** with MinIO S3-compatible storage
- **Flexible document requirements** configurable per entity and service type
- **Robust verification workflow** with re-submission capability
- **Proper access control** until verification is complete
- **Audit trail** for all verification actions
- **Scalable architecture** following Clean Architecture principles



---

## Email Service Implementation with Resend

### IEmailService Interface

```csharp
public interface IEmailService
{
    Task SendRegistrationSuccessEmailAsync(string toEmail, string ownerName, string companyName, string entityCode, string uploadUrl);
    Task SendDocumentsSubmittedEmailAsync(string toEmail, string ownerName, string companyName);
    Task SendApprovalEmailAsync(string toEmail, string ownerName, string companyName, string loginUrl);
    Task SendRejectionEmailAsync(string toEmail, string ownerName, string companyName, string rejectionReason, int remainingAttempts, string uploadUrl);
    Task SendAdminNotificationEmailAsync(string adminEmail, string entityType, string companyName, string entityCode, string verificationUrl);
}
```

### ResendEmailService Implementation

```csharp
using Resend;

public class ResendEmailService : IEmailService
{
    private readonly IResend _resend;
    private readonly string _fromEmail;
    private readonly ILogger<ResendEmailService> _logger;

    public ResendEmailService(IConfiguration config, ILogger<ResendEmailService> logger)
    {
        var apiKey = config["Resend:ApiKey"];
        _fromEmail = config["Resend:FromEmail"];
        _resend = ResendClient.Create(apiKey);
        _logger = logger;
    }

    public async Task SendRegistrationSuccessEmailAsync(
        string toEmail, 
        string ownerName, 
        string companyName, 
        string entityCode, 
        string uploadUrl)
    {
        try
        {
            var htmlBody = $@"
                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                    <h2>Registration Successful - Upload Documents</h2>
                    <p>Dear {ownerName},</p>
                    <p>Thank you for registering with Tour & Travel ERP Platform!</p>
                    <p>Your registration has been received successfully.</p>
                    <div style='background-color: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px;'>
                        <p><strong>Company:</strong> {companyName}</p>
                        <p><strong>Entity Code:</strong> {entityCode}</p>
                        <p><strong>Email:</strong> {toEmail}</p>
                    </div>
                    <h3>Next Steps:</h3>
                    <ol>
                        <li>Login to your account</li>
                        <li>Upload required documents for verification</li>
                        <li>Wait for admin approval (usually within 1-2 business days)</li>
                    </ol>
                    <p style='margin: 30px 0;'>
                        <a href='{uploadUrl}' style='background-color: #4CAF50; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;'>
                            Upload Documents
                        </a>
                    </p>
                    <p>If you have any questions, please contact our support team.</p>
                    <p>Best regards,<br>Tour & Travel ERP Platform Team</p>
                </div>
            ";

            var message = new EmailMessage
            {
                From = _fromEmail,
                To = toEmail,
                Subject = "Registration Successful - Upload Documents",
                HtmlBody = htmlBody
            };

            var response = await _resend.EmailSendAsync(message);
            
            _logger.LogInformation("Registration success email sent to {Email}. MessageId: {MessageId}", 
                toEmail, response.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send registration success email to {Email}", toEmail);
            // Don't throw - email failure should not block registration
        }
    }

    public async Task SendDocumentsSubmittedEmailAsync(
        string toEmail, 
        string ownerName, 
        string companyName)
    {
        try
        {
            var htmlBody = $@"
                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                    <h2>Documents Submitted - Verification in Progress</h2>
                    <p>Dear {ownerName},</p>
                    <p>All required documents have been submitted successfully!</p>
                    <p>Our team will review your documents within 1-2 business days.</p>
                    <p>You will receive an email notification once the verification is complete.</p>
                    <p>Thank you for your patience.</p>
                    <p>Best regards,<br>Tour & Travel ERP Platform Team</p>
                </div>
            ";

            var message = new EmailMessage
            {
                From = _fromEmail,
                To = toEmail,
                Subject = "Documents Submitted - Verification in Progress",
                HtmlBody = htmlBody
            };

            await _resend.EmailSendAsync(message);
            _logger.LogInformation("Documents submitted email sent to {Email}", toEmail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send documents submitted email to {Email}", toEmail);
        }
    }

    public async Task SendApprovalEmailAsync(
        string toEmail, 
        string ownerName, 
        string companyName, 
        string loginUrl)
    {
        try
        {
            var htmlBody = $@"
                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                    <h2 style='color: #4CAF50;'>Verification Approved - Welcome to Platform</h2>
                    <p>Dear {ownerName},</p>
                    <p><strong>Congratulations!</strong> Your account has been verified and approved.</p>
                    <p>You can now access all platform features.</p>
                    <p style='margin: 30px 0;'>
                        <a href='{loginUrl}' style='background-color: #4CAF50; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;'>
                            Login to Platform
                        </a>
                    </p>
                    <p>Welcome to Tour & Travel ERP Platform!</p>
                    <p>Best regards,<br>Tour & Travel ERP Platform Team</p>
                </div>
            ";

            var message = new EmailMessage
            {
                From = _fromEmail,
                To = toEmail,
                Subject = "Verification Approved - Welcome to Platform",
                HtmlBody = htmlBody
            };

            await _resend.EmailSendAsync(message);
            _logger.LogInformation("Approval email sent to {Email}", toEmail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send approval email to {Email}", toEmail);
        }
    }

    public async Task SendRejectionEmailAsync(
        string toEmail, 
        string ownerName, 
        string companyName, 
        string rejectionReason, 
        int remainingAttempts, 
        string uploadUrl)
    {
        try
        {
            var htmlBody = $@"
                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                    <h2 style='color: #f44336;'>Verification Rejected - Action Required</h2>
                    <p>Dear {ownerName},</p>
                    <p>Unfortunately, your verification has been rejected.</p>
                    <div style='background-color: #fff3cd; padding: 15px; margin: 20px 0; border-left: 4px solid #f44336; border-radius: 4px;'>
                        <p><strong>Reason:</strong></p>
                        <p>{rejectionReason}</p>
                    </div>
                    <p>You can re-submit your documents for verification.</p>
                    <p><strong>Remaining attempts:</strong> {remainingAttempts}</p>
                    <p style='margin: 30px 0;'>
                        <a href='{uploadUrl}' style='background-color: #2196F3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;'>
                            Re-submit Documents
                        </a>
                    </p>
                    <p>If you need assistance, please contact our support team.</p>
                    <p>Best regards,<br>Tour & Travel ERP Platform Team</p>
                </div>
            ";

            var message = new EmailMessage
            {
                From = _fromEmail,
                To = toEmail,
                Subject = "Verification Rejected - Action Required",
                HtmlBody = htmlBody
            };

            await _resend.EmailSendAsync(message);
            _logger.LogInformation("Rejection email sent to {Email}", toEmail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send rejection email to {Email}", toEmail);
        }
    }

    public async Task SendAdminNotificationEmailAsync(
        string adminEmail, 
        string entityType, 
        string companyName, 
        string entityCode, 
        string verificationUrl)
    {
        try
        {
            var htmlBody = $@"
                <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                    <h2>New Registration - Review Required</h2>
                    <p>A new {entityType} has registered and requires verification.</p>
                    <div style='background-color: #f5f5f5; padding: 15px; margin: 20px 0; border-radius: 5px;'>
                        <p><strong>Entity Type:</strong> {entityType}</p>
                        <p><strong>Company:</strong> {companyName}</p>
                        <p><strong>Entity Code:</strong> {entityCode}</p>
                    </div>
                    <p style='margin: 30px 0;'>
                        <a href='{verificationUrl}' style='background-color: #2196F3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block;'>
                            Review Registration
                        </a>
                    </p>
                    <p>Please review and verify the submitted documents.</p>
                    <p>Best regards,<br>Tour & Travel ERP Platform</p>
                </div>
            ";

            var message = new EmailMessage
            {
                From = _fromEmail,
                To = adminEmail,
                Subject = $"New {entityType} Registration - Review Required",
                HtmlBody = htmlBody
            };

            await _resend.EmailSendAsync(message);
            _logger.LogInformation("Admin notification email sent to {Email}", adminEmail);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send admin notification email to {Email}", adminEmail);
        }
    }
}
```

### Configuration (appsettings.json)

```json
{
  "Resend": {
    "ApiKey": "re_MQEZxLqL_8AtcyUXq7rvRqEJv6SaFLSeY",
    "FromEmail": "onboarding@yourdomain.com"
  }
}
```

**Note:** 
- Replace `ApiKey` with your actual Resend API key
- Replace `FromEmail` with your verified domain email (e.g., `noreply@yourdomain.com`)
- For development, you can use Resend's test email: `onboarding@resend.dev`

### Service Registration (Program.cs)

```csharp
builder.Services.AddScoped<IEmailService, ResendEmailService>();
```

### NuGet Package Installation

```bash
dotnet add package Resend
```

### Resend Setup Steps

1. **Sign up for Resend**: https://resend.com
2. **Get API Key**: Dashboard → API Keys → Create API Key
3. **Verify Domain** (for production):
   - Dashboard → Domains → Add Domain
   - Add DNS records (SPF, DKIM, DMARC)
   - Verify domain
4. **Update Configuration**: Add API key to appsettings.json
5. **Test Email**: Send test email to verify setup

### Benefits of Using Resend

1. **Simple API**: Clean, modern API design
2. **Reliable Delivery**: High deliverability rates
3. **Free Tier**: 3,000 emails/month, 100 emails/day
4. **Fast Integration**: Quick setup with NuGet package
5. **Email Templates**: Support for HTML templates
6. **Webhooks**: Track email delivery status
7. **Analytics**: Email open rates, click rates
8. **Developer-Friendly**: Great documentation and SDKs

