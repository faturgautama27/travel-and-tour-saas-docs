# Company Settings - Requirements & Design Document

**Project**: Tour & Travel ERP SaaS  
**Date**: March 18, 2026  
**Status**: Requirements Analysis - Ready for Implementation

---

## 📋 EXECUTIVE SUMMARY

### Problem Statement
- Supplier and Agency entities **DO NOT have bank account fields**
- No menu/page to view company registration data
- No way to edit bank account information
- Bank account needed for payment disbursement (supplier) and refunds (agency)

### Solution
Create **Company Settings** page for both Agency and Supplier with:
- View company registration data (read-only)
- View uploaded documents and verification status
- Edit bank account information
- View verification status badge

---

## 🔍 CURRENT STATE ANALYSIS

### Backend Entities

**Supplier Entity** - Missing Bank Fields:
```csharp
public class Supplier
{
    // Existing fields
    public string CompanyName { get; set; }
    public string Email { get; set; }
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public string? BusinessLicenseNumber { get; set; }
    public string? TaxId { get; set; }
    
    // ❌ NO BANK ACCOUNT FIELDS
}
```

**Agency Entity** - Missing Bank Fields:
```csharp
public class Agency
{
    // Existing fields
    public string CompanyName { get; set; }
    public string Email { get; set; }
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public string? BusinessLicenseNumber { get; set; }
    public string? TaxId { get; set; }
    
    // ❌ NO BANK ACCOUNT FIELDS
}
```

### Backend API

**ProfileController** - Skeleton Exists:
- ✅ Endpoint exists: `GET /api/profile/company`
- ✅ Endpoint exists: `PUT /api/profile/company`
- ❌ Query handler NOT implemented: `GetCompanyProfileQuery`
- ❌ Command handler NOT implemented: `UpdateCompanyProfileCommand`
- ❌ DTOs NOT found: `CompanyProfileDto`, `UpdateCompanyProfileDto`

### Frontend

**Routes** - Company Settings NOT Found:
- ❌ No route: `/agency/settings/company`
- ❌ No route: `/supplier/settings/company`
- ⚠️ Placeholder routes exist: `/agency/settings/users`, `/agency/settings/roles`, `/agency/settings/subscription`

**Components** - NOT Found:
- ❌ No component for company settings
- ❌ No service for company profile API

---

## 🎯 REQUIREMENTS

### Functional Requirements

**FR-1: View Company Information**
- User can view company registration data (read-only)
- Display: Company name, email, phone, address, business type, license number, tax ID
- Display: Registration date, verification status

**FR-2: View Documents**
- User can view all uploaded documents
- Display: Document type, file name, upload date, verification status
- Action: Download document

**FR-3: Edit Bank Account**
- User can add/edit bank account information
- Fields: Bank name, bank code, account number, account holder name, branch
- Validation: Account number format, required fields
- Save: Update entity with new bank info

**FR-4: View Verification Status**
- Display verification status badge (pending, verified, rejected)
- Display verified date and verified by (if applicable)
- Display rejection reason (if rejected)

### Non-Functional Requirements

**NFR-1: Security**
- Only company owner or admin can access company settings
- Bank account information encrypted at rest
- Audit log for bank account changes

**NFR-2: Usability**
- Single page with tabs/sections
- Clear labels and help text
- Validation messages for bank account form
- Success/error notifications

**NFR-3: Performance**
- Page load < 2 seconds
- Bank account update < 1 second

---

## 📐 DATABASE SCHEMA CHANGES

### Supplier Entity - Add Bank Account Fields

```sql
ALTER TABLE suppliers
ADD COLUMN bank_name VARCHAR(100),
ADD COLUMN bank_code VARCHAR(20),
ADD COLUMN bank_account_number VARCHAR(50),
ADD COLUMN bank_account_name VARCHAR(255),
ADD COLUMN bank_branch VARCHAR(255);

CREATE INDEX idx_suppliers_bank_account ON suppliers(bank_account_number);
```

### Agency Entity - Add Bank Account Fields

```sql
ALTER TABLE agencies
ADD COLUMN bank_name VARCHAR(100),
ADD COLUMN bank_code VARCHAR(20),
ADD COLUMN bank_account_number VARCHAR(50),
ADD COLUMN bank_account_name VARCHAR(255),
ADD COLUMN bank_branch VARCHAR(255);

CREATE INDEX idx_agencies_bank_account ON agencies(bank_account_number);
```

### Bank Account Audit Log (Optional)

```sql
CREATE TABLE bank_account_changes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type VARCHAR(20) NOT NULL, -- supplier, agency
    entity_id UUID NOT NULL,
    changed_by UUID NOT NULL REFERENCES users(id),
    old_bank_name VARCHAR(100),
    old_bank_account_number VARCHAR(50),
    new_bank_name VARCHAR(100),
    new_bank_account_number VARCHAR(50),
    change_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bank_account_changes_entity ON bank_account_changes(entity_type, entity_id);
```

---

## 🎨 FRONTEND DESIGN

### Company Settings Page Layout

**Location**: 
- Agency: `/agency/settings/company`
- Supplier: `/supplier/settings/company`

**Page Structure**:
```
┌─────────────────────────────────────────────────────────────┐
│ Company Settings                                            │
│                                                             │
│ [Tab: Company Info] [Tab: Documents] [Tab: Bank Account]  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ TAB 1: COMPANY INFORMATION (Read-only)                      │
│                                                             │
│ ┌─ Basic Information ──────────────────────────────────┐  │
│ │ Company Name: PT Berkah Travel Indonesia             │  │
│ │ Email: info@berkahtravel.com                         │  │
│ │ Phone: +62 21 1234 5678                              │  │
│ │ Address: Jl. Sudirman No. 123, Jakarta Pusat         │  │
│ │ City: Jakarta                                         │  │
│ │ Province: DKI Jakarta                                 │  │
│ │ Postal Code: 10220                                    │  │
│ │ Country: Indonesia                                    │  │
│ └───────────────────────────────────────────────────────┘  │
│                                                             │
│ ┌─ Business Information ───────────────────────────────┐  │
│ │ Business Type: PPIU                                   │  │
│ │ Business License: 123/PPIU/2024                       │  │
│ │ Tax ID (NPWP): 01.234.567.8-901.000                  │  │
│ │ KBLI: 79111 (Travel Agency)                          │  │
│ │ Owner Name: Bapak Ahmad Hidayat                       │  │
│ └───────────────────────────────────────────────────────┘  │
│                                                             │
│ ┌─ Registration & Verification ────────────────────────┐  │
│ │ Registration Date: 15 January 2026                    │  │
│ │ Verification Status: [VERIFIED] ✅                    │  │
│ │ Verified At: 20 January 2026                          │  │
│ │ Verified By: Platform Admin                           │  │
│ └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ TAB 2: DOCUMENTS                                            │
│                                                             │
│ ┌─ Uploaded Documents ─────────────────────────────────┐  │
│ │                                                       │  │
│ │ Document 1: Business License (SIUP)                  │  │
│ │ ├─ File: siup-berkah-travel.pdf                      │  │
│ │ ├─ Uploaded: 15 January 2026                         │  │
│ │ ├─ Status: [VERIFIED] ✅                             │  │
│ │ └─ Actions: [Download]                               │  │
│ │                                                       │  │
│ │ Document 2: Tax ID (NPWP)                            │  │
│ │ ├─ File: npwp-berkah-travel.pdf                      │  │
│ │ ├─ Uploaded: 15 January 2026                         │  │
│ │ ├─ Status: [VERIFIED] ✅                             │  │
│ │ └─ Actions: [Download]                               │  │
│ │                                                       │  │
│ │ Document 3: PPIU License                             │  │
│ │ ├─ File: ppiu-license.pdf                            │  │
│ │ ├─ Uploaded: 15 January 2026                         │  │
│ │ ├─ Status: [VERIFIED] ✅                             │  │
│ │ └─ Actions: [Download]                               │  │
│ └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ TAB 3: BANK ACCOUNT (Editable)                             │
│                                                             │
│ ┌─ Bank Account Information ───────────────────────────┐  │
│ │                                                       │  │
│ │ Bank Name: [BCA - Bank Central Asia ▼]              │  │
│ │ Bank Code: [014] (auto-filled)                       │  │
│ │ Account Number: [1234567890]                         │  │
│ │ Account Holder Name: [PT Berkah Travel Indonesia]    │  │
│ │ Branch: [Jakarta Sudirman]                           │  │
│ │                                                       │  │
│ │ [Cancel] [Save Changes]                              │  │
│ └───────────────────────────────────────────────────────┘  │
│                                                             │
│ ℹ️ Bank account is used for payment disbursement          │
│    Please ensure the information is accurate                │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔌 API ENDPOINTS

### Get Company Profile

```
GET /api/profile/company

Response: {
  "success": true,
  "data": {
    "entity_type": "agency" | "supplier",
    "entity_id": "uuid",
    
    // Basic Information
    "company_name": "PT Berkah Travel Indonesia",
    "email": "info@berkahtravel.com",
    "phone": "+62 21 1234 5678",
    "address": "Jl. Sudirman No. 123",
    "city": "Jakarta",
    "province": "DKI Jakarta",
    "postal_code": "10220",
    "country": "Indonesia",
    
    // Business Information
    "business_type": "PPIU",
    "business_license_number": "123/PPIU/2024",
    "tax_id": "01.234.567.8-901.000",
    "kbli": "79111",
    "owner_name": "Bapak Ahmad Hidayat",
    
    // Bank Account
    "bank_name": "BCA - Bank Central Asia",
    "bank_code": "014",
    "bank_account_number": "1234567890",
    "bank_account_name": "PT Berkah Travel Indonesia",
    "bank_branch": "Jakarta Sudirman",
    
    // Verification
    "verification_status": "verified",
    "verified_at": "2026-01-20T10:00:00Z",
    "verified_by_name": "Platform Admin",
    "rejection_reason": null,
    
    // Metadata
    "created_at": "2026-01-15T08:00:00Z",
    "updated_at": "2026-01-20T10:00:00Z",
    
    // Documents
    "documents": [
      {
        "id": "uuid",
        "document_type": "business_license",
        "file_name": "siup-berkah-travel.pdf",
        "file_url": "https://...",
        "uploaded_at": "2026-01-15T08:30:00Z",
        "verification_status": "verified"
      }
    ]
  }
}
```

### Update Company Profile

```
PUT /api/profile/company

Request Body: {
  "bank_name": "BCA - Bank Central Asia",
  "bank_code": "014",
  "bank_account_number": "1234567890",
  "bank_account_name": "PT Berkah Travel Indonesia",
  "bank_branch": "Jakarta Sudirman"
}

Response: {
  "success": true,
  "message": "Bank account updated successfully",
  "data": { ... } // Updated company profile
}
```

**Note**: Only bank account fields are editable. Other company info is read-only (set during registration).

---

## 💡 DESIGN DECISIONS

### Decision 1: What Fields Are Editable?

**DECISION**: Only bank account fields are editable

**Rationale**:
- Company registration data should not change (legal entity)
- If company info needs update, should go through re-verification
- Bank account can change (bank migration, account closure, etc.)
- Simpler implementation and security

**Editable Fields**:
- ✅ Bank Name
- ✅ Bank Code
- ✅ Bank Account Number
- ✅ Bank Account Holder Name
- ✅ Bank Branch

**Read-Only Fields**:
- ❌ Company Name
- ❌ Email
- ❌ Phone
- ❌ Address
- ❌ Business License Number
- ❌ Tax ID
- ❌ Business Type

### Decision 2: Bank Account Required?

**DECISION**: Optional during registration, required before receiving payments

**Rationale**:
- Allow registration without bank account (faster onboarding)
- Supplier can add bank account later before publishing services
- Agency can add bank account later before receiving refunds
- Validation at payment disbursement time

**Validation Points**:
- Supplier: Before first payment disbursement
- Agency: Before first refund processing
- Show warning if bank account not set

### Decision 3: Bank Code Auto-Fill?

**DECISION**: Yes, auto-fill from bank name selection

**Implementation**:
- Frontend has bank list with codes
- User selects bank name from dropdown
- Bank code auto-filled (read-only)
- Example: "BCA - Bank Central Asia" → Code: "014"

**Bank List** (Indonesia):
```typescript
const INDONESIAN_BANKS = [
  { name: 'BCA - Bank Central Asia', code: '014' },
  { name: 'Mandiri', code: '008' },
  { name: 'BNI - Bank Negara Indonesia', code: '009' },
  { name: 'BRI - Bank Rakyat Indonesia', code: '002' },
  { name: 'CIMB Niaga', code: '022' },
  { name: 'Permata Bank', code: '013' },
  { name: 'Danamon', code: '011' },
  { name: 'BTN - Bank Tabungan Negara', code: '200' },
  { name: 'Syariah Mandiri', code: '451' },
  { name: 'BCA Syariah', code: '536' }
];
```

### Decision 4: Audit Log for Bank Changes?

**DECISION**: Yes, log all bank account changes

**Rationale**:
- Security requirement (track who changed bank account)
- Fraud prevention (detect suspicious changes)
- Compliance requirement (financial audit trail)

**Implementation**:
- Create `bank_account_changes` table
- Log old and new values
- Log user who made change
- Log timestamp

---

## 🎨 FRONTEND COMPONENTS

### 1. CompanySettingsComponent (Main Page)

**Location**: 
- Agency: `src/app/features/agency/pages/company-settings/`
- Supplier: `src/app/features/supplier/pages/company-settings/`

**Features**:
- Tab navigation (Company Info, Documents, Bank Account)
- Load company profile on init
- Handle tab switching
- Show loading state

**Code Structure**:
```typescript
@Component({
  selector: 'app-company-settings',
  templateUrl: './company-settings.component.html',
  styleUrls: ['./company-settings.component.scss']
})
export class CompanySettingsComponent implements OnInit {
  activeTab: 'info' | 'documents' | 'bank' = 'info';
  companyProfile: CompanyProfile | null = null;
  loading = false;
  
  constructor(
    private companyProfileService: CompanyProfileService,
    private messageService: MessageService
  ) {}
  
  async ngOnInit() {
    await this.loadCompanyProfile();
  }
  
  async loadCompanyProfile() {
    this.loading = true;
    try {
      this.companyProfile = await this.companyProfileService.getProfile();
    } catch (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Error',
        detail: 'Failed to load company profile'
      });
    } finally {
      this.loading = false;
    }
  }
}
```

---

### 2. CompanyInfoTabComponent (Read-only Display)

**Features**:
- Display company registration data
- Display verification status badge
- Grouped sections (Basic, Business, Registration)

**Template**:
```html
<div class="company-info-tab">
  <div class="info-section">
    <h3>Basic Information</h3>
    <div class="info-grid">
      <div class="info-item">
        <label>Company Name</label>
        <span>{{ profile.company_name }}</span>
      </div>
      <div class="info-item">
        <label>Email</label>
        <span>{{ profile.email }}</span>
      </div>
      <!-- More fields -->
    </div>
  </div>
  
  <div class="info-section">
    <h3>Verification Status</h3>
    <p-tag 
      [value]="profile.verification_status" 
      [severity]="getStatusSeverity(profile.verification_status)">
    </p-tag>
    <p *ngIf="profile.verified_at">
      Verified on {{ profile.verified_at | date }}
    </p>
  </div>
</div>
```

---

### 3. DocumentsTabComponent (Document List)

**Features**:
- Display uploaded documents
- Show verification status per document
- Download action

**Template**:
```html
<div class="documents-tab">
  <p-table [value]="profile.documents">
    <ng-template pTemplate="header">
      <tr>
        <th>Document Type</th>
        <th>File Name</th>
        <th>Uploaded Date</th>
        <th>Status</th>
        <th>Actions</th>
      </tr>
    </ng-template>
    <ng-template pTemplate="body" let-doc>
      <tr>
        <td>{{ doc.document_type | titlecase }}</td>
        <td>{{ doc.file_name }}</td>
        <td>{{ doc.uploaded_at | date }}</td>
        <td>
          <p-tag 
            [value]="doc.verification_status" 
            [severity]="getDocStatusSeverity(doc.verification_status)">
          </p-tag>
        </td>
        <td>
          <button 
            pButton 
            icon="pi pi-download" 
            class="p-button-text"
            (click)="downloadDocument(doc)">
          </button>
        </td>
      </tr>
    </ng-template>
  </p-table>
</div>
```

---

### 4. BankAccountTabComponent (Editable Form)

**Features**:
- Form for bank account information
- Bank name dropdown with auto-fill code
- Validation (required fields, account number format)
- Save button with loading state

**Template**:
```html
<div class="bank-account-tab">
  <form [formGroup]="bankForm" (ngSubmit)="onSubmit()">
    <div class="form-grid">
      <div class="field">
        <label for="bankName">Bank Name *</label>
        <p-dropdown
          id="bankName"
          formControlName="bank_name"
          [options]="bankList"
          optionLabel="name"
          optionValue="name"
          placeholder="Select bank"
          (onChange)="onBankSelected($event)">
        </p-dropdown>
        <small class="p-error" *ngIf="bankForm.get('bank_name')?.invalid && bankForm.get('bank_name')?.touched">
          Bank name is required
        </small>
      </div>
      
      <div class="field">
        <label for="bankCode">Bank Code</label>
        <input 
          pInputText 
          id="bankCode" 
          formControlName="bank_code"
          readonly>
      </div>
      
      <div class="field">
        <label for="accountNumber">Account Number *</label>
        <input 
          pInputText 
          id="accountNumber" 
          formControlName="bank_account_number"
          placeholder="Enter account number">
        <small class="p-error" *ngIf="bankForm.get('bank_account_number')?.invalid && bankForm.get('bank_account_number')?.touched">
          Account number is required
        </small>
      </div>
      
      <div class="field">
        <label for="accountName">Account Holder Name *</label>
        <input 
          pInputText 
          id="accountName" 
          formControlName="bank_account_name"
          placeholder="Enter account holder name">
      </div>
      
      <div class="field">
        <label for="branch">Branch</label>
        <input 
          pInputText 
          id="branch" 
          formControlName="bank_branch"
          placeholder="Enter branch name">
      </div>
    </div>
    
    <div class="form-actions">
      <button 
        pButton 
        type="button" 
        label="Cancel" 
        class="p-button-text"
        (click)="onCancel()">
      </button>
      <button 
        pButton 
        type="submit" 
        label="Save Changes"
        [loading]="saving"
        [disabled]="bankForm.invalid || !bankForm.dirty">
      </button>
    </div>
  </form>
  
  <p-message 
    severity="info" 
    text="Bank account information is used for payment disbursement. Please ensure accuracy.">
  </p-message>
</div>
```

**Component Logic**:
```typescript
export class BankAccountTabComponent implements OnInit {
  bankForm: FormGroup;
  bankList = INDONESIAN_BANKS;
  saving = false;
  
  @Input() profile: CompanyProfile;
  @Output() profileUpdated = new EventEmitter<CompanyProfile>();
  
  constructor(
    private fb: FormBuilder,
    private companyProfileService: CompanyProfileService,
    private messageService: MessageService
  ) {
    this.bankForm = this.fb.group({
      bank_name: ['', Validators.required],
      bank_code: [''],
      bank_account_number: ['', [Validators.required, Validators.pattern(/^\d{10,20}$/)]],
      bank_account_name: ['', Validators.required],
      bank_branch: ['']
    });
  }
  
  ngOnInit() {
    if (this.profile) {
      this.bankForm.patchValue({
        bank_name: this.profile.bank_name,
        bank_code: this.profile.bank_code,
        bank_account_number: this.profile.bank_account_number,
        bank_account_name: this.profile.bank_account_name,
        bank_branch: this.profile.bank_branch
      });
    }
  }
  
  onBankSelected(event: any) {
    const selectedBank = this.bankList.find(b => b.name === event.value);
    if (selectedBank) {
      this.bankForm.patchValue({ bank_code: selectedBank.code });
    }
  }
  
  async onSubmit() {
    if (this.bankForm.invalid) return;
    
    this.saving = true;
    try {
      const updated = await this.companyProfileService.updateBankAccount(
        this.bankForm.value
      );
      
      this.messageService.add({
        severity: 'success',
        summary: 'Success',
        detail: 'Bank account updated successfully'
      });
      
      this.profileUpdated.emit(updated);
      this.bankForm.markAsPristine();
    } catch (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Error',
        detail: 'Failed to update bank account'
      });
    } finally {
      this.saving = false;
    }
  }
  
  onCancel() {
    this.bankForm.reset(this.profile);
  }
}
```

---

### 5. CompanyProfileService (API Service)

**Location**: `src/app/shared/services/company-profile.service.ts`

```typescript
@Injectable({
  providedIn: 'root'
})
export class CompanyProfileService {
  private apiUrl = '/api/profile/company';
  
  constructor(private http: HttpClient) {}
  
  getProfile(): Promise<CompanyProfile> {
    return firstValueFrom(
      this.http.get<ApiResponse<CompanyProfile>>(this.apiUrl)
        .pipe(map(response => response.data))
    );
  }
  
  updateBankAccount(data: UpdateBankAccountDto): Promise<CompanyProfile> {
    return firstValueFrom(
      this.http.put<ApiResponse<CompanyProfile>>(this.apiUrl, data)
        .pipe(map(response => response.data))
    );
  }
}
```

---

## 🔧 BACKEND IMPLEMENTATION

### DTOs

**CompanyProfileDto**:
```csharp
public class CompanyProfileDto
{
    public string EntityType { get; set; } // "agency" or "supplier"
    public Guid EntityId { get; set; }
    
    // Basic Information
    public string CompanyName { get; set; }
    public string Email { get; set; }
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public string? City { get; set; }
    public string? Province { get; set; }
    public string? PostalCode { get; set; }
    public string Country { get; set; }
    
    // Business Information
    public string? BusinessType { get; set; }
    public string? BusinessLicenseNumber { get; set; }
    public string? TaxId { get; set; }
    public string? KBLI { get; set; }
    public string? OwnerName { get; set; }
    
    // Bank Account
    public string? BankName { get; set; }
    public string? BankCode { get; set; }
    public string? BankAccountNumber { get; set; }
    public string? BankAccountName { get; set; }
    public string? BankBranch { get; set; }
    
    // Verification
    public string VerificationStatus { get; set; }
    public DateTime? VerifiedAt { get; set; }
    public string? VerifiedByName { get; set; }
    public string? RejectionReason { get; set; }
    
    // Metadata
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Documents
    public List<EntityDocumentDto> Documents { get; set; }
}
```

**UpdateCompanyProfileDto**:
```csharp
public class UpdateCompanyProfileDto
{
    // Only bank account fields are editable
    public string? BankName { get; set; }
    public string? BankCode { get; set; }
    public string? BankAccountNumber { get; set; }
    public string? BankAccountName { get; set; }
    public string? BankBranch { get; set; }
}
```

---

### Query Handler

**GetCompanyProfileQueryHandler**:
```csharp
public class GetCompanyProfileQuery : IRequest<CompanyProfileDto>
{
    public Guid UserId { get; set; }
}

public class GetCompanyProfileQueryHandler : IRequestHandler<GetCompanyProfileQuery, CompanyProfileDto>
{
    private readonly IUserRepository _userRepository;
    private readonly IAgencyRepository _agencyRepository;
    private readonly ISupplierRepository _supplierRepository;
    private readonly IDocumentRepository _documentRepository;
    private readonly IMapper _mapper;
    
    public async Task<CompanyProfileDto> Handle(GetCompanyProfileQuery request, CancellationToken cancellationToken)
    {
        // Get user to determine entity type
        var user = await _userRepository.GetByIdAsync(request.UserId);
        if (user == null) throw new NotFoundException("User not found");
        
        CompanyProfileDto profile;
        
        if (user.Role == "agency_staff" || user.Role == "agency_owner")
        {
            // Get agency
            var agency = await _agencyRepository.GetByIdAsync(user.AgencyId.Value);
            if (agency == null) throw new NotFoundException("Agency not found");
            
            // Get documents
            var documents = await _documentRepository.GetByEntityAsync("agency", agency.Id);
            
            profile = new CompanyProfileDto
            {
                EntityType = "agency",
                EntityId = agency.Id,
                CompanyName = agency.CompanyName,
                Email = agency.Email,
                Phone = agency.Phone,
                Address = agency.Address,
                City = agency.City,
                Province = agency.Province,
                PostalCode = agency.PostalCode,
                Country = agency.Country,
                BusinessType = agency.BusinessType?.ToString(),
                BusinessLicenseNumber = agency.BusinessLicenseNumber,
                TaxId = agency.TaxId,
                KBLI = agency.KBLI,
                OwnerName = agency.OwnerName,
                BankName = agency.BankName,
                BankCode = agency.BankCode,
                BankAccountNumber = agency.BankAccountNumber,
                BankAccountName = agency.BankAccountName,
                BankBranch = agency.BankBranch,
                VerificationStatus = agency.VerificationStatus,
                VerifiedAt = agency.VerifiedAt,
                VerifiedByName = agency.VerifiedByUser?.FullName,
                RejectionReason = agency.RejectionReason,
                CreatedAt = agency.CreatedAt,
                UpdatedAt = agency.UpdatedAt,
                Documents = _mapper.Map<List<EntityDocumentDto>>(documents)
            };
        }
        else if (user.Role == "supplier_staff" || user.Role == "supplier_owner")
        {
            // Get supplier
            var supplier = await _supplierRepository.GetByIdAsync(user.SupplierId.Value);
            if (supplier == null) throw new NotFoundException("Supplier not found");
            
            // Get documents
            var documents = await _documentRepository.GetByEntityAsync("supplier", supplier.Id);
            
            profile = new CompanyProfileDto
            {
                EntityType = "supplier",
                EntityId = supplier.Id,
                CompanyName = supplier.CompanyName,
                Email = supplier.Email,
                Phone = supplier.Phone,
                Address = supplier.Address,
                City = supplier.City,
                Province = supplier.Province,
                PostalCode = supplier.PostalCode,
                Country = supplier.Country,
                BusinessType = supplier.BusinessType,
                BusinessLicenseNumber = supplier.BusinessLicenseNumber,
                TaxId = supplier.TaxId,
                OwnerName = supplier.OwnerName,
                BankName = supplier.BankName,
                BankCode = supplier.BankCode,
                BankAccountNumber = supplier.BankAccountNumber,
                BankAccountName = supplier.BankAccountName,
                BankBranch = supplier.BankBranch,
                VerificationStatus = supplier.VerificationStatus,
                VerifiedAt = supplier.VerifiedAt,
                VerifiedByName = supplier.VerifiedByUser?.FullName,
                RejectionReason = supplier.RejectionReason,
                CreatedAt = supplier.CreatedAt,
                UpdatedAt = supplier.UpdatedAt,
                Documents = _mapper.Map<List<EntityDocumentDto>>(documents)
            };
        }
        else
        {
            throw new UnauthorizedException("User is not associated with agency or supplier");
        }
        
        return profile;
    }
}
```

---

### Command Handler

**UpdateCompanyProfileCommandHandler**:
```csharp
public class UpdateCompanyProfileCommand : IRequest<CompanyProfileDto>
{
    public Guid UserId { get; set; }
    public UpdateCompanyProfileDto UpdateDto { get; set; }
}

public class UpdateCompanyProfileCommandHandler : IRequestHandler<UpdateCompanyProfileCommand, CompanyProfileDto>
{
    private readonly IUserRepository _userRepository;
    private readonly IAgencyRepository _agencyRepository;
    private readonly ISupplierRepository _supplierRepository;
    private readonly IBankAccountChangeRepository _auditRepository;
    private readonly IMapper _mapper;
    
    public async Task<CompanyProfileDto> Handle(UpdateCompanyProfileCommand request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId);
        if (user == null) throw new NotFoundException("User not found");
        
        if (user.Role == "agency_staff" || user.Role == "agency_owner")
        {
            var agency = await _agencyRepository.GetByIdAsync(user.AgencyId.Value);
            if (agency == null) throw new NotFoundException("Agency not found");
            
            // Log old values for audit
            var oldBankAccount = new
            {
                agency.BankName,
                agency.BankAccountNumber
            };
            
            // Update bank account fields
            agency.BankName = request.UpdateDto.BankName;
            agency.BankCode = request.UpdateDto.BankCode;
            agency.BankAccountNumber = request.UpdateDto.BankAccountNumber;
            agency.BankAccountName = request.UpdateDto.BankAccountName;
            agency.BankBranch = request.UpdateDto.BankBranch;
            agency.UpdatedAt = DateTime.UtcNow;
            
            await _agencyRepository.UpdateAsync(agency);
            
            // Create audit log
            await _auditRepository.CreateAsync(new BankAccountChange
            {
                EntityType = "agency",
                EntityId = agency.Id,
                ChangedBy = request.UserId,
                OldBankName = oldBankAccount.BankName,
                OldBankAccountNumber = oldBankAccount.BankAccountNumber,
                NewBankName = agency.BankName,
                NewBankAccountNumber = agency.BankAccountNumber
            });
            
            // Return updated profile
            return await new GetCompanyProfileQuery { UserId = request.UserId }
                .Handle(this, cancellationToken);
        }
        else if (user.Role == "supplier_staff" || user.Role == "supplier_owner")
        {
            // Similar logic for supplier
            var supplier = await _supplierRepository.GetByIdAsync(user.SupplierId.Value);
            // ... update supplier bank account ...
        }
        
        throw new UnauthorizedException("User is not associated with agency or supplier");
    }
}
```

---

## 🔐 SECURITY & AUTHORIZATION

### Access Control

**Who Can Access**:
- Agency Owner: Full access to agency company settings
- Agency Staff: Read-only access (cannot edit bank account)
- Supplier Owner: Full access to supplier company settings
- Supplier Staff: Read-only access (cannot edit bank account)

**Authorization Logic**:
```csharp
// In ProfileController
[HttpPut("company")]
[Authorize(Roles = "agency_owner,supplier_owner")]
public async Task<ActionResult> UpdateCompanyProfile(...)
{
    // Only owners can update bank account
}
```

### Data Protection

**Bank Account Encryption** (Optional):
- Encrypt bank account number at rest
- Decrypt when displaying to authorized users
- Use ASP.NET Data Protection API

**Audit Trail**:
- Log all bank account changes
- Include: Who changed, when, old value, new value
- Retention: 7 years (compliance requirement)

---

## 🎯 VALIDATION RULES

### Bank Account Validation

**Frontend Validation**:
```typescript
const bankAccountValidators = {
  bank_name: [Validators.required],
  bank_account_number: [
    Validators.required,
    Validators.pattern(/^\d{10,20}$/), // 10-20 digits
    Validators.minLength(10),
    Validators.maxLength(20)
  ],
  bank_account_name: [
    Validators.required,
    Validators.minLength(3),
    Validators.maxLength(255)
  ],
  bank_branch: [
    Validators.maxLength(255)
  ]
};
```

**Backend Validation**:
```csharp
public class UpdateCompanyProfileValidator : AbstractValidator<UpdateCompanyProfileDto>
{
    public UpdateCompanyProfileValidator()
    {
        When(x => !string.IsNullOrEmpty(x.BankAccountNumber), () =>
        {
            RuleFor(x => x.BankName)
                .NotEmpty()
                .WithMessage("Bank name is required when account number is provided");
            
            RuleFor(x => x.BankAccountNumber)
                .Matches(@"^\d{10,20}$")
                .WithMessage("Account number must be 10-20 digits");
            
            RuleFor(x => x.BankAccountName)
                .NotEmpty()
                .MinimumLength(3)
                .MaximumLength(255)
                .WithMessage("Account holder name is required");
        });
    }
}
```

---

## 📱 USER FLOWS

### Flow 1: View Company Information

```
User logs in as Agency Owner
    ↓
Navigate to Settings → Company Settings
    ↓
System loads company profile
    ↓
Display company info (read-only)
    ↓
User can switch tabs to view documents or bank account
```

### Flow 2: Add Bank Account (First Time)

```
User navigates to Bank Account tab
    ↓
Form shows empty fields
    ↓
User selects bank name from dropdown
    ↓
Bank code auto-filled
    ↓
User enters account number, holder name, branch
    ↓
User clicks [Save Changes]
    ↓
System validates input
    ↓
System updates entity
    ↓
System creates audit log
    ↓
Show success message
    ↓
Form marked as pristine (not dirty)
```

### Flow 3: Update Bank Account

```
User navigates to Bank Account tab
    ↓
Form shows existing bank account data
    ↓
User changes account number
    ↓
Form marked as dirty
    ↓
[Save Changes] button enabled
    ↓
User clicks [Save Changes]
    ↓
System validates input
    ↓
System logs old and new values
    ↓
System updates entity
    ↓
Show success message
```

---

## 🚀 IMPLEMENTATION PHASES

### Phase 1: Backend Foundation (Week 1)

**Tasks**:
1. Add bank account fields to Supplier entity
2. Add bank account fields to Agency entity
3. Create database migration
4. Create CompanyProfileDto
5. Create UpdateCompanyProfileDto
6. Implement GetCompanyProfileQueryHandler
7. Implement UpdateCompanyProfileCommandHandler
8. Update ProfileController (already has skeleton)
9. Add validation
10. Add unit tests

**Duration**: 3-5 days

---

### Phase 2: Frontend Implementation (Week 2)

**Tasks**:
1. Create CompanySettingsComponent (main page)
2. Create CompanyInfoTabComponent (read-only display)
3. Create DocumentsTabComponent (document list)
4. Create BankAccountTabComponent (editable form)
5. Create CompanyProfileService (API service)
6. Add routes to agency.routes.ts and supplier.routes.ts
7. Update navigation menu (add Company Settings link)
8. Add bank list constant
9. Add form validation
10. Add success/error notifications

**Duration**: 3-5 days

---

### Phase 3: Testing & Polish (Week 3)

**Tasks**:
1. Integration testing (backend + frontend)
2. Test bank account validation
3. Test audit logging
4. Test authorization (owner vs staff)
5. UI/UX polish
6. Add loading states
7. Add error handling
8. Documentation

**Duration**: 2-3 days

---

## 🎯 TOTAL ESTIMATED EFFORT

- **Backend**: 3-5 days
- **Frontend**: 3-5 days
- **Testing**: 2-3 days
- **Total**: 8-13 days (1.5-2.5 weeks)

---

## 📋 ACCEPTANCE CRITERIA

### Backend

- [ ] Supplier entity has bank account fields
- [ ] Agency entity has bank account fields
- [ ] Database migration applied successfully
- [ ] GET /api/profile/company returns company profile with bank account
- [ ] PUT /api/profile/company updates bank account successfully
- [ ] Validation works correctly (required fields, format)
- [ ] Audit log created for bank account changes
- [ ] Authorization works (only owners can update)
- [ ] Unit tests pass (>80% coverage)

### Frontend

- [ ] Company Settings page accessible from navigation menu
- [ ] Company Info tab displays all registration data
- [ ] Documents tab displays uploaded documents
- [ ] Bank Account tab shows editable form
- [ ] Bank name dropdown works with auto-fill code
- [ ] Form validation works (required fields, format)
- [ ] Save button disabled when form invalid or pristine
- [ ] Success notification shown after save
- [ ] Error notification shown on failure
- [ ] Loading states work correctly

---

## 📚 RELATED DOCUMENTS

**Payment System**:
- `PAYMENT-TRACKING-COMPREHENSIVE.md` - Payment tracking (needs bank account for disbursement)
- `PAYMENT-COMMISSION-SUMMARY.md` - Commission system
- `COMPLETE-JOURNEY-TO-BOOKING-FLOW.md` - Complete flow

**Supplier Service**:
- `SUPPLIER-SERVICE-MANAGEMENT-REQUIREMENTS.md` - Service features

**Journey System**:
- `JOURNEY-REFACTOR-REQUIREMENTS.md` - Journey refactor design

---

## ✅ STATUS

**Requirements**: FINALIZED  
**Design**: COMPLETE  
**Status**: ✅ **READY FOR SPEC CREATION**

**Next Action**: Create implementation specs in backend and frontend projects

---

**Document Version**: 1.0  
**Last Updated**: 18 March 2026  
**Author**: Kiro AI Assistant
