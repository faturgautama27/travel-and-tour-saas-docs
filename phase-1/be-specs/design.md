# Design Document

## Overview

This design document specifies the architecture and implementation details for the Tour & Travel ERP SaaS backend API (Phase 1 MVP). The system is built using .NET 8 with Clean Architecture principles, implementing CQRS pattern with MediatR, and using PostgreSQL 16 with Row-Level Security for multi-tenant data isolation.

### System Goals

- Provide secure, multi-tenant RESTful APIs for travel agency operations
- Ensure complete data isolation between agencies using PostgreSQL RLS
- Support four user roles: Platform Admin, Agency Staff, Supplier, and Traveler
- Enable suppliers to offer services and agencies to create packages
- Facilitate booking workflow with approval process and quota management
- Maintain high code quality through Clean Architecture and CQRS patterns

### Technology Stack

- **Runtime**: .NET 8 (C# 12)
- **Web Framework**: ASP.NET Core 8
- **Database**: PostgreSQL 16
- **ORM**: Entity Framework Core 8
- **CQRS**: MediatR 12
- **Validation**: FluentValidation 11
- **Authentication**: JWT Bearer tokens
- **Password Hashing**: BCrypt.Net-Next
- **API Documentation**: Swashbuckle (Swagger/OpenAPI)
- **Logging**: Serilog
- **Testing**: xUnit, Testcontainers
- **Containerization**: Docker, Docker Compose

## Architecture

### Clean Architecture Layers

The system follows Clean Architecture with four distinct layers:

```
┌─────────────────────────────────────────────────────────┐
│                      API Layer                          │
│  Controllers, Middleware, Filters, Startup             │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  Application Layer                      │
│  CQRS Commands/Queries, DTOs, Validators, Interfaces   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   Domain Layer                          │
│  Entities, Value Objects, Domain Interfaces            │
└─────────────────────────────────────────────────────────┘
                          ↑
┌─────────────────────────────────────────────────────────┐
│                Infrastructure Layer                     │
│  EF Core, Repositories, External Services              │
└─────────────────────────────────────────────────────────┘
```


#### 1. Domain Layer

The Domain layer contains core business entities and domain logic. It has no dependencies on other layers.

**Entities:**
- User (id, email, passwordHash, userType, fullName, agencyId, supplierId)
- Agency (id, agencyCode, companyName, subscriptionPlan, isActive, commissionRate)
- Supplier (id, supplierCode, companyName, status, businessType)
- SupplierService (id, supplierId, serviceCode, serviceType, name, basePrice, serviceDetails)
- Package (id, agencyId, packageCode, packageType, name, durationDays, baseCost, sellingPrice)
- PackageService (id, packageId, supplierServiceId, quantity, unitCost, totalCost)
- PackageDeparture (id, packageId, departureCode, departureDate, totalQuota, availableQuota)
- Booking (id, agencyId, packageId, packageDepartureId, bookingReference, bookingStatus, totalAmount)
- Traveler (id, bookingId, travelerNumber, fullName, gender, dateOfBirth, passportNumber, mahramTravelerNumber)

**Domain Interfaces:**
- IRepository<T> (generic repository pattern)
- IUnitOfWork (transaction management)

#### 2. Application Layer

The Application layer contains business logic orchestration using CQRS pattern. It depends only on the Domain layer.

**CQRS Structure:**
- Commands: Write operations (Create, Update, Delete)
- Queries: Read operations (Get, List, Search)
- Handlers: MediatR handlers for each command/query
- DTOs: Data Transfer Objects for API requests/responses
- Validators: FluentValidation validators for input validation

**Key Commands:**
- Authentication: LoginCommand, RegisterCommand, RefreshTokenCommand
- Agencies: CreateAgencyCommand, UpdateAgencyCommand, UpdateAgencyStatusCommand
- Suppliers: ApproveSupplierCommand, RejectSupplierCommand
- Services: CreateServiceCommand, UpdateServiceCommand, PublishServiceCommand
- Packages: CreatePackageCommand, UpdatePackageCommand, PublishPackageCommand
- Departures: CreateDepartureCommand, UpdateDepartureCommand
- Bookings: CreateBookingCommand, ApproveBookingCommand, RejectBookingCommand, CancelBookingCommand

**Key Queries:**
- GetAgenciesQuery, GetAgencyByIdQuery
- GetSuppliersQuery, GetSupplierByIdQuery
- GetServicesQuery, GetServiceByIdQuery
- GetPackagesQuery, GetPackageByIdQuery
- GetBookingsQuery, GetBookingByIdQuery
- GetDashboardStatsQuery (per role)

#### 3. Infrastructure Layer

The Infrastructure layer implements interfaces defined in Domain and Application layers. It depends on Domain layer.

**Components:**
- DbContext: EF Core database context with entity configurations
- Repositories: Concrete implementations of IRepository<T>
- UnitOfWork: Transaction management implementation
- External Services: Email, SMS, payment gateway (Phase 2+)

**EF Core Configuration:**
- Fluent API for entity configurations
- Value converters for enums and JSON columns
- Index definitions for performance
- RLS policy configuration

#### 4. API Layer

The API layer exposes HTTP endpoints and handles cross-cutting concerns. It depends on Application layer.

**Components:**
- Controllers: RESTful API endpoints organized by feature
- Middleware: Authentication, tenant context, exception handling, logging
- Filters: Authorization, validation
- Startup: Dependency injection, service configuration

### CQRS Pattern with MediatR

All business operations follow CQRS pattern:

**Command Flow:**
```
Controller → Command → CommandHandler → Repository → Database
```

**Query Flow:**
```
Controller → Query → QueryHandler → Repository → Database
```

**Benefits:**
- Clear separation of read and write operations
- Easier to test and maintain
- Supports different optimization strategies for reads vs writes
- Enables future scaling (separate read/write databases)

### Multi-Tenancy Architecture

**Tenant Identification:**
1. JWT token contains agencyId claim for Agency Staff users
2. X-Tenant-ID header provides explicit tenant context
3. Middleware extracts tenant context and stores in HttpContext

**Data Isolation:**
1. PostgreSQL Row-Level Security (RLS) policies enforce tenant boundaries
2. Session variable `app.current_agency_id` set before each query
3. RLS policies filter queries automatically at database level
4. Platform Admins bypass RLS to view all data

**RLS Policy Example:**
```sql
CREATE POLICY packages_agency_isolation ON packages
  FOR ALL
  USING (
    agency_id = current_setting('app.current_agency_id', true)::UUID
    OR current_setting('app.current_user_type', true) = 'platform_admin'
  );
```

## Components and Interfaces

### Authentication Service

**Interface:**
```csharp
public interface IAuthenticationService
{
    Task<AuthenticationResult> LoginAsync(string email, string password);
    Task<AuthenticationResult> RegisterAsync(RegisterDto dto);
    Task<AuthenticationResult> RefreshTokenAsync(string refreshToken);
    Task<bool> ValidateTokenAsync(string token);
}
```

**Implementation:**
- Validates credentials against database
- Generates JWT token with claims (userId, email, userType, agencyId, supplierId)
- Uses BCrypt for password hashing and verification
- Implements refresh token rotation for security

**JWT Token Structure:**
```json
{
  "sub": "user-uuid",
  "email": "user@example.com",
  "userType": "agency_staff",
  "agencyId": "agency-uuid",
  "supplierId": null,
  "exp": 1234567890,
  "iat": 1234567890
}
```

### Tenant Context Middleware

**Purpose:** Extract and validate tenant context from JWT or headers

**Flow:**
1. Extract JWT token from Authorization header
2. Validate token signature and expiration
3. Extract user claims (userId, userType, agencyId, supplierId)
4. Check for X-Tenant-ID header (Agency Staff only)
5. Validate X-Tenant-ID matches JWT agencyId claim
6. Store tenant context in HttpContext.Items
7. Set PostgreSQL session variables before query execution

**Implementation:**
```csharp
public class TenantContextMiddleware
{
    public async Task InvokeAsync(HttpContext context, IDbContext dbContext)
    {
        var tenantId = ExtractTenantId(context);
        var userType = ExtractUserType(context);
        
        if (tenantId.HasValue)
        {
            await dbContext.SetTenantContextAsync(tenantId.Value, userType);
        }
        
        await _next(context);
    }
}
```

### Repository Pattern

**Generic Repository Interface:**
```csharp
public interface IRepository<T> where T : class
{
    Task<T> GetByIdAsync(Guid id);
    Task<IEnumerable<T>> GetAllAsync();
    Task<PagedResult<T>> GetPagedAsync(int page, int pageSize);
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(Guid id);
    Task<bool> ExistsAsync(Guid id);
}
```

**Specific Repositories:**
- IAgencyRepository: Additional methods for agency-specific queries
- ISupplierRepository: Additional methods for supplier approval workflow
- IPackageRepository: Additional methods for package search and filtering
- IBookingRepository: Additional methods for booking workflow and quota management

### Validation Pipeline

**FluentValidation Integration:**
- Each command/query has a corresponding validator
- Validators run automatically before handler execution
- Validation errors return 400 Bad Request with field-specific messages

**Example Validator:**
```csharp
public class CreatePackageCommandValidator : AbstractValidator<CreatePackageCommand>
{
    public CreatePackageCommandValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(255);
        RuleFor(x => x.PackageType).IsInEnum();
        RuleFor(x => x.DurationDays).GreaterThan(0);
        RuleFor(x => x.SellingPrice).GreaterThanOrEqualTo(x => x.BaseCost);
        RuleFor(x => x.Services).NotEmpty();
    }
}
```

### Exception Handling Middleware

**Purpose:** Catch and handle all exceptions globally

**Exception Types:**
- ValidationException → 400 Bad Request
- UnauthorizedException → 401 Unauthorized
- ForbiddenException → 403 Forbidden
- NotFoundException → 404 Not Found
- ConflictException → 409 Conflict
- Exception → 500 Internal Server Error

**Response Format:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  }
}
```

### Logging Service

**Serilog Configuration:**
- Structured logging with JSON output
- Log levels: Debug, Information, Warning, Error, Critical
- Enrichers: Request ID, User ID, Tenant ID, Timestamp
- Sinks: Console, File, Database (optional)

**Logged Information:**
- All HTTP requests (method, path, status, duration)
- All database queries (SQL, parameters, duration)
- All exceptions (type, message, stack trace)
- Authentication events (login, logout, token refresh)
- Business events (booking created, package published)


## Data Models

### Database Schema

#### Users Table

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('platform_admin', 'agency_staff', 'supplier', 'customer')),
  full_name VARCHAR(255) NOT NULL,
  phone VARCHAR(50),
  agency_id UUID REFERENCES agencies(id) ON DELETE SET NULL,
  supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_agency ON users(agency_id);
CREATE INDEX idx_users_supplier ON users(supplier_id);
CREATE INDEX idx_users_type ON users(user_type);
```

**Entity Configuration:**
```csharp
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        builder.HasKey(u => u.Id);
        
        builder.Property(u => u.Email).IsRequired().HasMaxLength(255);
        builder.Property(u => u.PasswordHash).IsRequired().HasMaxLength(255);
        builder.Property(u => u.UserType).IsRequired().HasConversion<string>();
        builder.Property(u => u.FullName).IsRequired().HasMaxLength(255);
        
        builder.HasOne(u => u.Agency)
               .WithMany()
               .HasForeignKey(u => u.AgencyId)
               .OnDelete(DeleteBehavior.SetNull);
               
        builder.HasOne(u => u.Supplier)
               .WithMany()
               .HasForeignKey(u => u.SupplierId)
               .OnDelete(DeleteBehavior.SetNull);
    }
}
```

#### Agencies Table

```sql
CREATE TABLE agencies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_code VARCHAR(50) UNIQUE NOT NULL,
  company_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  address TEXT,
  subscription_plan VARCHAR(50) NOT NULL CHECK (subscription_plan IN ('basic', 'pro', 'enterprise')),
  commission_rate DECIMAL(5,2),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_agencies_code ON agencies(agency_code);
CREATE INDEX idx_agencies_status ON agencies(is_active);
```

**Code Generation Trigger:**
```sql
CREATE OR REPLACE FUNCTION generate_agency_code()
RETURNS TRIGGER AS $$
DECLARE
    next_number INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(agency_code FROM 5) AS INTEGER)), 0) + 1
    INTO next_number FROM agencies;
    NEW.agency_code := 'AGN-' || LPAD(next_number::TEXT, 3, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_agency_code_trigger
    BEFORE INSERT ON agencies
    FOR EACH ROW
    WHEN (NEW.agency_code IS NULL)
    EXECUTE FUNCTION generate_agency_code();
```

#### Suppliers Table

```sql
CREATE TABLE suppliers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supplier_code VARCHAR(50) UNIQUE NOT NULL,
  company_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(50) NOT NULL,
  business_type VARCHAR(50) CHECK (business_type IN ('hotel', 'airline', 'visa_agent', 'transport', 'guide', 'multi')),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'suspended', 'rejected')),
  verified_at TIMESTAMP,
  verified_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_suppliers_code ON suppliers(supplier_code);
CREATE INDEX idx_suppliers_status ON suppliers(status);
```

#### Supplier Services Table

```sql
CREATE TABLE supplier_services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  supplier_id UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
  service_code VARCHAR(50) UNIQUE NOT NULL,
  service_type VARCHAR(50) NOT NULL CHECK (service_type IN ('hotel', 'flight', 'visa', 'transport', 'guide')),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  service_details JSONB,
  base_price DECIMAL(15,2) NOT NULL CHECK (base_price >= 0),
  currency VARCHAR(3) DEFAULT 'IDR',
  price_unit VARCHAR(50) CHECK (price_unit IN ('per_night', 'per_pax', 'per_trip', 'per_day', 'per_service')),
  visibility VARCHAR(20) DEFAULT 'marketplace' CHECK (visibility IN ('marketplace', 'private')),
  status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  published_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_supplier_services_supplier ON supplier_services(supplier_id);
CREATE INDEX idx_supplier_services_type ON supplier_services(service_type);
CREATE INDEX idx_supplier_services_status ON supplier_services(status, visibility);
CREATE INDEX idx_supplier_services_details ON supplier_services USING gin(service_details);
```

**JSONB Service Details Examples:**

Hotel Service:
```json
{
  "hotel_name": "Elaf Al Mashaer Hotel",
  "star_rating": 5,
  "location": "Mecca",
  "distance_to_haram": "100m",
  "room_types": [
    {
      "type": "quad",
      "capacity": 4,
      "quantity": 80,
      "price_per_night": 500000
    }
  ],
  "amenities": ["wifi", "ac", "breakfast", "prayer_room"]
}
```

Flight Service:
```json
{
  "airline": "Garuda Indonesia",
  "flight_number": "GA123",
  "departure_airport": "CGK",
  "arrival_airport": "JED",
  "departure_time": "10:00",
  "arrival_time": "16:00",
  "aircraft_type": "Boeing 777",
  "class": "economy",
  "baggage_allowance": "30kg"
}
```

#### Packages Table

```sql
CREATE TABLE packages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE CASCADE,
  package_code VARCHAR(50) UNIQUE NOT NULL,
  package_type VARCHAR(50) NOT NULL CHECK (package_type IN ('umrah', 'hajj', 'tour', 'custom')),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  duration_days INTEGER NOT NULL CHECK (duration_days > 0),
  duration_nights INTEGER NOT NULL CHECK (duration_nights >= 0),
  base_cost DECIMAL(15,2) NOT NULL CHECK (base_cost >= 0),
  markup_type VARCHAR(20) DEFAULT 'fixed' CHECK (markup_type IN ('fixed', 'percentage')),
  markup_amount DECIMAL(15,2),
  markup_percentage DECIMAL(5,2),
  selling_price DECIMAL(15,2) NOT NULL CHECK (selling_price >= 0),
  currency VARCHAR(3) DEFAULT 'IDR',
  visibility VARCHAR(20) DEFAULT 'public' CHECK (visibility IN ('public', 'private', 'draft')),
  status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
  published_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_packages_agency ON packages(agency_id);
CREATE INDEX idx_packages_type ON packages(package_type);
CREATE INDEX idx_packages_status ON packages(status, visibility);

-- Row-Level Security
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;

CREATE POLICY packages_agency_isolation ON packages
  FOR ALL
  USING (
    agency_id = current_setting('app.current_agency_id', true)::UUID
    OR current_setting('app.current_user_type', true) = 'platform_admin'
  );
```

#### Package Services Table

```sql
CREATE TABLE package_services (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  package_id UUID NOT NULL REFERENCES packages(id) ON DELETE CASCADE,
  supplier_service_id UUID NOT NULL REFERENCES supplier_services(id) ON DELETE RESTRICT,
  service_type VARCHAR(50) NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit VARCHAR(50),
  unit_cost DECIMAL(15,2) NOT NULL CHECK (unit_cost >= 0),
  total_cost DECIMAL(15,2) NOT NULL CHECK (total_cost >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_package_services_package ON package_services(package_id);
CREATE INDEX idx_package_services_supplier_service ON package_services(supplier_service_id);
```

#### Package Departures Table

```sql
CREATE TABLE package_departures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  package_id UUID NOT NULL REFERENCES packages(id) ON DELETE CASCADE,
  departure_code VARCHAR(50) NOT NULL,
  departure_date DATE NOT NULL,
  return_date DATE NOT NULL,
  total_quota INTEGER NOT NULL CHECK (total_quota > 0),
  available_quota INTEGER NOT NULL CHECK (available_quota >= 0),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_return_after_departure CHECK (return_date > departure_date),
  CONSTRAINT check_quota_valid CHECK (available_quota <= total_quota)
);

CREATE INDEX idx_package_departures_package ON package_departures(package_id);
CREATE INDEX idx_package_departures_date ON package_departures(departure_date);
CREATE UNIQUE INDEX idx_package_departures_code ON package_departures(package_id, departure_code);
```

#### Bookings Table

```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  agency_id UUID NOT NULL REFERENCES agencies(id) ON DELETE RESTRICT,
  package_id UUID NOT NULL REFERENCES packages(id) ON DELETE RESTRICT,
  package_departure_id UUID NOT NULL REFERENCES package_departures(id) ON DELETE RESTRICT,
  booking_reference VARCHAR(50) UNIQUE NOT NULL,
  booking_status VARCHAR(20) DEFAULT 'pending' CHECK (booking_status IN ('pending', 'approved', 'rejected', 'cancelled', 'completed')),
  customer_name VARCHAR(255) NOT NULL,
  customer_email VARCHAR(255) NOT NULL,
  customer_phone VARCHAR(50) NOT NULL,
  total_amount DECIMAL(15,2) NOT NULL CHECK (total_amount >= 0),
  traveler_count INTEGER NOT NULL CHECK (traveler_count > 0),
  approved_at TIMESTAMP,
  approved_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by UUID REFERENCES users(id)
);

CREATE INDEX idx_bookings_agency ON bookings(agency_id);
CREATE INDEX idx_bookings_package ON bookings(package_id);
CREATE INDEX idx_bookings_departure ON bookings(package_departure_id);
CREATE INDEX idx_bookings_status ON bookings(booking_status);
CREATE INDEX idx_bookings_reference ON bookings(booking_reference);

-- Row-Level Security
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY bookings_agency_isolation ON bookings
  FOR ALL
  USING (
    agency_id = current_setting('app.current_agency_id', true)::UUID
    OR created_by = current_setting('app.current_user_id', true)::UUID
    OR current_setting('app.current_user_type', true) = 'platform_admin'
  );
```

**Booking Reference Generation:**
```sql
CREATE OR REPLACE FUNCTION generate_booking_reference()
RETURNS TRIGGER AS $$
DECLARE
    date_part VARCHAR(6);
    seq_part VARCHAR(3);
BEGIN
    date_part := TO_CHAR(CURRENT_DATE, 'YYMMDD');
    
    SELECT LPAD((COUNT(*) + 1)::TEXT, 3, '0')
    INTO seq_part
    FROM bookings
    WHERE DATE(created_at) = CURRENT_DATE;
    
    NEW.booking_reference := 'BKG-' || date_part || '-' || seq_part;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_booking_reference_trigger
    BEFORE INSERT ON bookings
    FOR EACH ROW
    WHEN (NEW.booking_reference IS NULL)
    EXECUTE FUNCTION generate_booking_reference();
```

#### Travelers Table

```sql
CREATE TABLE travelers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  traveler_number INTEGER NOT NULL CHECK (traveler_number > 0),
  full_name VARCHAR(255) NOT NULL,
  gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')),
  date_of_birth DATE NOT NULL,
  nationality VARCHAR(100) NOT NULL,
  passport_number VARCHAR(50) NOT NULL,
  passport_expiry_date DATE NOT NULL,
  requires_mahram BOOLEAN DEFAULT false,
  mahram_traveler_number INTEGER,
  mahram_relationship VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT check_mahram_valid CHECK (
    NOT requires_mahram OR (mahram_traveler_number IS NOT NULL AND mahram_relationship IS NOT NULL)
  ),
  CONSTRAINT unique_traveler_per_booking UNIQUE (booking_id, traveler_number)
);

CREATE INDEX idx_travelers_booking ON travelers(booking_id);
CREATE INDEX idx_travelers_passport ON travelers(passport_number);
```

### Entity Relationships

```
users ──┬─→ agencies (agency_id)
        └─→ suppliers (supplier_id)

agencies ──→ packages (agency_id)
         └─→ bookings (agency_id)

suppliers ──→ supplier_services (supplier_id)

packages ──┬─→ package_services (package_id)
           └─→ package_departures (package_id)

package_services ──→ supplier_services (supplier_service_id)

package_departures ──→ bookings (package_departure_id)

bookings ──→ travelers (booking_id)
```

### DTOs (Data Transfer Objects)

**Authentication DTOs:**
```csharp
public record LoginRequest(string Email, string Password);

public record LoginResponse(
    string Token,
    string RefreshToken,
    UserDto User
);

public record UserDto(
    Guid Id,
    string Email,
    string FullName,
    string UserType,
    Guid? AgencyId,
    Guid? SupplierId
);
```

**Package DTOs:**
```csharp
public record CreatePackageRequest(
    string PackageType,
    string Name,
    string Description,
    int DurationDays,
    int DurationNights,
    List<PackageServiceDto> Services,
    string MarkupType,
    decimal? MarkupAmount,
    decimal? MarkupPercentage,
    List<DepartureDto> Departures,
    string Visibility
);

public record PackageServiceDto(
    Guid SupplierServiceId,
    string ServiceType,
    int Quantity,
    string Unit,
    decimal UnitCost
);

public record DepartureDto(
    string DepartureCode,
    DateTime DepartureDate,
    DateTime ReturnDate,
    int TotalQuota
);

public record PackageResponse(
    Guid Id,
    string PackageCode,
    string PackageType,
    string Name,
    string Description,
    int DurationDays,
    int DurationNights,
    decimal BaseCost,
    decimal SellingPrice,
    string Status,
    List<PackageServiceResponse> Services,
    List<DepartureResponse> Departures
);
```

**Booking DTOs:**
```csharp
public record CreateBookingRequest(
    Guid PackageId,
    Guid PackageDepartureId,
    string CustomerName,
    string CustomerEmail,
    string CustomerPhone,
    List<TravelerDto> Travelers
);

public record TravelerDto(
    int TravelerNumber,
    string FullName,
    string Gender,
    DateTime DateOfBirth,
    string Nationality,
    string PassportNumber,
    DateTime PassportExpiryDate,
    bool RequiresMahram,
    int? MahramTravelerNumber,
    string MahramRelationship
);

public record BookingResponse(
    Guid Id,
    string BookingReference,
    string BookingStatus,
    string CustomerName,
    decimal TotalAmount,
    int TravelerCount,
    PackageSummaryDto Package,
    List<TravelerResponse> Travelers
);
```

### API Response Wrapper

All API responses follow a consistent format:

```csharp
public record ApiResponse<T>(
    bool Success,
    T Data,
    string Message = null,
    PaginationMeta Meta = null
);

public record ApiErrorResponse(
    bool Success,
    ErrorDetails Error
);

public record ErrorDetails(
    string Code,
    string Message,
    List<ValidationError> Details = null
);

public record ValidationError(
    string Field,
    string Message
);

public record PaginationMeta(
    int Page,
    int PerPage,
    int Total,
    int TotalPages
);
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: JWT Token Completeness

*For any* valid user credentials, when authentication succeeds, the generated JWT token should contain all required claims: user ID, email, user type, agency ID (if applicable), and supplier ID (if applicable).

**Validates: Requirements 1.1**

### Property 2: Password Hashing Security

*For any* user registration, the stored password hash should be a valid BCrypt hash and should never equal the plaintext password.

**Validates: Requirements 1.5**

### Property 3: Authentication Round Trip

*For any* valid JWT token, the token should be accepted by the authentication middleware, and the extracted user identity should match the original user who was authenticated.

**Validates: Requirements 1.3, 1.8**

### Property 4: Invalid Credentials Rejection

*For any* invalid credentials (wrong password, non-existent email, or malformed input), the authentication attempt should fail with an appropriate error and no token should be generated.

**Validates: Requirements 1.2**

### Property 5: Role-Based Authorization

*For any* user attempting to access an endpoint, if the user's role does not have permission for that endpoint, the request should be rejected with a 403 Forbidden error.

**Validates: Requirements 1.7**

### Property 6: Multi-Tenant Data Isolation

*For any* two different agencies A and B, when agency A's staff queries data, the results should contain only data belonging to agency A and should never contain data belonging to agency B.

**Validates: Requirements 2.1, 2.3**

### Property 7: Automatic Tenant Association

*For any* agency staff user creating data (packages, bookings, etc.), the created record should automatically have its agency_id set to the user's agency, without requiring explicit specification.

**Validates: Requirements 2.2**

### Property 8: Platform Admin Full Access

*For any* platform admin user querying data, the results should include data from all agencies, bypassing Row-Level Security policies.

**Validates: Requirements 2.5**

### Property 9: Supplier Data Isolation

*For any* supplier user querying their services, the results should contain only services belonging to that supplier and should never contain services from other suppliers.

**Validates: Requirements 2.6, 6.4**

### Property 10: Unique Code Generation

*For any* entity requiring a generated code (agencies, suppliers, services, packages, departures, bookings), each generated code should be unique within its entity type, and the generation should be deterministic and sequential.

**Validates: Requirements 3.1, 6.1, 9.1, 10.1, 14.1**

### Property 11: Required Field Validation

*For any* create or update request, if required fields are missing or empty, the request should be rejected with a 400 Bad Request error containing field-specific validation messages.

**Validates: Requirements 3.2, 6.2, 9.2, 10.2, 14.2, 14.3, 16.6**

### Property 12: Pagination Correctness

*For any* list endpoint with pagination parameters (page, per_page), the response should contain exactly per_page items (or fewer on the last page), and the pagination metadata should correctly reflect page, per_page, total, and total_pages.

**Validates: Requirements 3.3, 8.5, 13.7, 15.3, 19.3**

### Property 13: Filter Correctness

*For any* list endpoint with filter parameters (status, type, etc.), all returned items should match the filter criteria, and no items matching the criteria should be excluded.

**Validates: Requirements 3.4, 4.2, 8.2, 11.2, 13.2**

### Property 14: Search Correctness

*For any* search query on a list endpoint, all returned items should have names or descriptions containing the search term (case-insensitive), and no matching items should be excluded.

**Validates: Requirements 8.3, 11.3, 13.3**

### Property 15: Sorting Correctness

*For any* list endpoint with sort parameters, the returned items should be ordered according to the specified sort field and direction, with consistent ordering for items with equal sort values.

**Validates: Requirements 13.5**

### Property 16: Agency Status Enforcement

*For any* agency with is_active set to false, all agency staff users belonging to that agency should be unable to authenticate or access any agency-scoped endpoints.

**Validates: Requirements 3.6**

### Property 17: Supplier Approval Workflow

*For any* supplier registration, the initial status should be "pending", and only after platform admin approval should the status change to "active" with a recorded approval timestamp.

**Validates: Requirements 4.1, 4.3**

### Property 18: Supplier Status Enforcement

*For any* supplier with status "pending" or "rejected", the supplier should be able to create draft services but should be unable to publish services to the marketplace.

**Validates: Requirements 4.4, 4.5**

### Property 19: Dashboard Aggregation Correctness

*For any* dashboard statistics request, the returned counts should exactly match the count of records in the database meeting the specified criteria (e.g., active agencies, pending bookings, published packages).

**Validates: Requirements 5.1, 5.2, 5.3, 7.1, 7.2, 12.1, 12.2, 12.3, 12.4**

### Property 20: JSONB Serialization Round Trip

*For any* service with service_details stored as JSONB, serializing the details to JSON, storing in the database, and then deserializing should produce an equivalent object with all fields preserved.

**Validates: Requirements 6.3, 8.4**

### Property 21: Service Visibility Workflow

*For any* service, when published, the status should change to "published" and the service should appear in agency browse results; when unpublished, the status should change to "draft" and the service should not appear in browse results.

**Validates: Requirements 6.6, 6.7, 8.1**

### Property 22: Package Pricing Calculation

*For any* package, the base_cost should equal the sum of all package_services total_cost values, and the selling_price should equal base_cost plus markup (either fixed amount or percentage-based).

**Validates: Requirements 9.5, 9.6**

### Property 23: Package Pricing Constraint

*For any* package, the selling_price should always be greater than or equal to the base_cost.

**Validates: Requirements 9.3**

### Property 24: Package Service Relationship

*For any* package with N services added, there should be exactly N package_services records linking the package to the supplier services.

**Validates: Requirements 9.4**

### Property 25: Package Visibility Workflow

*For any* package, when published with visibility "public", the package should appear in traveler browse results; when visibility is "private" or "draft", the package should not appear in traveler browse results.

**Validates: Requirements 9.9, 13.1**

### Property 26: Departure Quota Initialization

*For any* newly created departure, the available_quota should equal the total_quota.

**Validates: Requirements 10.3**

### Property 27: Departure Quota Invariant

*For any* departure at any point in time, the available_quota should always be less than or equal to total_quota, and should always be greater than or equal to zero.

**Validates: Requirements 10.6**

### Property 28: Booking Approval Quota Decrement

*For any* booking approval, the associated departure's available_quota should decrease by the booking's traveler_count.

**Validates: Requirements 10.4, 11.5**

### Property 29: Booking Cancellation Quota Increment

*For any* booking cancellation, the associated departure's available_quota should increase by the booking's traveler_count.

**Validates: Requirements 10.5, 11.7**

### Property 30: Quota Management Round Trip

*For any* departure, if a booking is approved (decrementing quota) and then cancelled (incrementing quota), the available_quota should return to its original value.

**Validates: Requirements 10.4, 10.5**

### Property 31: Insufficient Quota Prevention

*For any* booking approval or creation attempt, if the departure's available_quota is less than the booking's traveler_count, the operation should be rejected with a validation error.

**Validates: Requirements 11.9, 14.4**

### Property 32: Booking Status Workflow

*For any* traveler-created booking, the initial status should be "pending"; after agency approval, the status should be "approved"; after agency rejection, the status should be "rejected"; and status transitions should follow valid state machine rules.

**Validates: Requirements 11.5, 11.6, 14.6**

### Property 33: Manual Booking Auto-Approval

*For any* booking created by agency staff (manual booking), the booking status should be immediately set to "approved" and the departure quota should be decremented without requiring separate approval.

**Validates: Requirements 11.8**

### Property 34: Booking Rejection Quota Preservation

*For any* booking rejection, the departure's available_quota should remain unchanged (no decrement should occur).

**Validates: Requirements 11.6**

### Property 35: Booking Amount Calculation

*For any* booking, the total_amount should equal the package's selling_price multiplied by the traveler_count.

**Validates: Requirements 14.7**

### Property 36: Traveler Record Completeness

*For any* booking with N travelers specified in the request, exactly N traveler records should be created in the database, each with a unique traveler_number from 1 to N.

**Validates: Requirements 14.5**

### Property 37: Mahram Relationship Validation

*For any* female traveler with requires_mahram set to true, the mahram_traveler_number should reference a valid male traveler in the same booking, and the mahram_relationship should be specified.

**Validates: Requirements 14.8, 14.9**

### Property 38: Referential Integrity Protection

*For any* entity with dependent records (agency with bookings, package with confirmed bookings, service in published packages, departure with confirmed bookings), deletion attempts should be rejected with a conflict error.

**Validates: Requirements 3.7, 6.8, 9.10, 10.7**

### Property 39: Email Format Validation

*For any* request containing an email field, if the email does not match a valid email format (contains @, valid domain, etc.), the request should be rejected with a validation error.

**Validates: Requirements 16.3**

### Property 40: Numeric Range Validation

*For any* request containing numeric fields (prices, quantities, quotas), if the values are negative or exceed reasonable bounds, the request should be rejected with a validation error.

**Validates: Requirements 16.4**

### Property 41: Date Range Validation

*For any* request containing date ranges (departure_date and return_date), the return_date should be after the departure_date, and both dates should be valid dates.

**Validates: Requirements 16.5**

### Property 42: Foreign Key Validation

*For any* request creating a relationship (package referencing services, booking referencing package and departure), all foreign key references should exist in the database before the record is created.

**Validates: Requirements 16.7**

### Property 43: API Response Format Consistency

*For any* API request, successful responses should have success=true with a data object, and failed responses should have success=false with an error object containing code, message, and optional details.

**Validates: Requirements 18.1, 18.2**

### Property 44: HTTP Status Code Correctness

*For any* API response, the HTTP status code should match the response type: 200/201 for success, 400 for validation errors, 401 for authentication errors, 403 for authorization errors, 404 for not found, 409 for conflicts, 500 for server errors.

**Validates: Requirements 18.4**

### Property 45: Pagination Metadata Presence

*For any* list endpoint response, the response should include pagination metadata with page, per_page, total, and total_pages fields.

**Validates: Requirements 18.3**

### Property 46: JSON Content Type

*For any* API response, the Content-Type header should be "application/json".

**Validates: Requirements 18.5**

### Property 47: Exception Logging Completeness

*For any* unhandled exception, the exception details (type, message, stack trace) should be logged, and the response should return a 500 status with a generic error message that does not expose sensitive information.

**Validates: Requirements 17.1, 17.2, 17.6**

### Property 48: Request Logging Completeness

*For any* incoming HTTP request, the log should contain timestamp, user ID (if authenticated), HTTP method, endpoint path, and response status code.

**Validates: Requirements 17.3**

### Property 49: Sensitive Data Exclusion

*For any* log entry or error response, sensitive information (passwords, password hashes, JWT tokens, credit card numbers) should never appear in plaintext.

**Validates: Requirements 17.6**

### Property 50: Seed Data Idempotency

*For any* seed data execution, running the seed script multiple times should not create duplicate records; existing records should be detected and skipped.

**Validates: Requirements 24.3**

## API Endpoints Specification

### Base URL

```
Production: https://api.tourtravel.com/v1
Development: http://localhost:8080/v1
```

### Authentication

All endpoints except `/auth/login` and `/auth/register` require JWT authentication.

**Authorization Header:**
```
Authorization: Bearer {jwt_token}
```

**Tenant Context Header (Agency Staff only):**
```
X-Tenant-ID: {agency_id}
```

### Endpoint Categories

#### 1. Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/auth/login` | User login | No |
| POST | `/auth/register` | User registration | No |
| POST | `/auth/refresh-token` | Refresh access token | No |
| POST | `/auth/logout` | User logout | Yes |
| GET | `/auth/me` | Get current user info | Yes |

#### 2. Platform Admin Endpoints

**Agencies:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/admin/agencies` | List all agencies | Platform Admin |
| POST | `/admin/agencies` | Create new agency | Platform Admin |
| GET | `/admin/agencies/{id}` | Get agency details | Platform Admin |
| PUT | `/admin/agencies/{id}` | Update agency | Platform Admin |
| DELETE | `/admin/agencies/{id}` | Delete agency | Platform Admin |
| PATCH | `/admin/agencies/{id}/status` | Update agency status | Platform Admin |

**Suppliers:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/admin/suppliers` | List all suppliers | Platform Admin |
| GET | `/admin/suppliers/{id}` | Get supplier details | Platform Admin |
| PATCH | `/admin/suppliers/{id}/approve` | Approve supplier | Platform Admin |
| PATCH | `/admin/suppliers/{id}/reject` | Reject supplier | Platform Admin |

**Dashboard:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/admin/dashboard/stats` | Get platform statistics | Platform Admin |

#### 3. Supplier Endpoints

**Services:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/supplier/services` | List my services | Supplier |
| POST | `/supplier/services` | Create new service | Supplier |
| GET | `/supplier/services/{id}` | Get service details | Supplier |
| PUT | `/supplier/services/{id}` | Update service | Supplier |
| DELETE | `/supplier/services/{id}` | Delete service | Supplier |
| PATCH | `/supplier/services/{id}/publish` | Publish service | Supplier |
| PATCH | `/supplier/services/{id}/unpublish` | Unpublish service | Supplier |

**Dashboard:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/supplier/dashboard/stats` | Get supplier statistics | Supplier |

#### 4. Agency Endpoints

**Packages:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/packages` | List my packages | Agency Staff |
| POST | `/packages` | Create new package | Agency Staff |
| GET | `/packages/{id}` | Get package details | Agency Staff |
| PUT | `/packages/{id}` | Update package | Agency Staff |
| DELETE | `/packages/{id}` | Delete package | Agency Staff |
| PATCH | `/packages/{id}/publish` | Publish package | Agency Staff |
| PATCH | `/packages/{id}/unpublish` | Unpublish package | Agency Staff |

**Package Departures:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/packages/{id}/departures` | List package departures | Agency Staff |
| POST | `/packages/{id}/departures` | Create departure | Agency Staff |
| GET | `/packages/{id}/departures/{departureId}` | Get departure details | Agency Staff |
| PUT | `/packages/{id}/departures/{departureId}` | Update departure | Agency Staff |
| DELETE | `/packages/{id}/departures/{departureId}` | Delete departure | Agency Staff |

**Bookings:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/bookings` | List all bookings | Agency Staff |
| POST | `/bookings` | Create manual booking | Agency Staff |
| GET | `/bookings/{id}` | Get booking details | Agency Staff |
| PATCH | `/bookings/{id}/approve` | Approve booking | Agency Staff |
| PATCH | `/bookings/{id}/reject` | Reject booking | Agency Staff |
| PATCH | `/bookings/{id}/cancel` | Cancel booking | Agency Staff |
| GET | `/bookings/pending-approval` | List pending bookings | Agency Staff |

**Supplier Services (Browse):**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/supplier-services` | Browse marketplace services | Agency Staff |
| GET | `/supplier-services/{id}` | Get service details | Agency Staff |

**Dashboard:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/dashboard/stats` | Get agency statistics | Agency Staff |

#### 5. Traveler Endpoints

**Browse Packages:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/traveler/packages` | Browse public packages | Customer |
| GET | `/traveler/packages/{id}` | Get package details | Customer |
| GET | `/traveler/packages/search` | Search packages | Customer |

**My Bookings:**

| Method | Endpoint | Description | Role Required |
|--------|----------|-------------|---------------|
| GET | `/traveler/my-bookings` | List my bookings | Customer |
| POST | `/traveler/my-bookings` | Create new booking | Customer |
| GET | `/traveler/my-bookings/{id}` | Get booking details | Customer |

#### 6. Health Check

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/health` | API health check | No |

### Request/Response Examples

#### Login

**Request:**
```http
POST /v1/auth/login
Content-Type: application/json

{
  "email": "agency@example.com",
  "password": "SecurePassword123!"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh-token-string",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "email": "agency@example.com",
      "fullName": "John Doe",
      "userType": "agency_staff",
      "agencyId": "660e8400-e29b-41d4-a716-446655440000",
      "supplierId": null
    }
  }
}
```

#### Create Package

**Request:**
```http
POST /v1/packages
Authorization: Bearer {token}
X-Tenant-ID: 660e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
  "packageType": "umrah",
  "name": "Umrah Premium March 2026",
  "description": "15 days premium Umrah package with 5-star hotels",
  "durationDays": 15,
  "durationNights": 14,
  "services": [
    {
      "supplierServiceId": "770e8400-e29b-41d4-a716-446655440000",
      "serviceType": "hotel",
      "quantity": 14,
      "unit": "nights",
      "unitCost": 500000
    },
    {
      "supplierServiceId": "880e8400-e29b-41d4-a716-446655440000",
      "serviceType": "flight",
      "quantity": 1,
      "unit": "pax",
      "unitCost": 10000000
    }
  ],
  "markupType": "fixed",
  "markupAmount": 4750000,
  "departures": [
    {
      "departureCode": "MAR15",
      "departureDate": "2026-03-15",
      "returnDate": "2026-03-29",
      "totalQuota": 40
    }
  ],
  "visibility": "public"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "990e8400-e29b-41d4-a716-446655440000",
    "packageCode": "PKG-001",
    "packageType": "umrah",
    "name": "Umrah Premium March 2026",
    "description": "15 days premium Umrah package with 5-star hotels",
    "durationDays": 15,
    "durationNights": 14,
    "baseCost": 17000000,
    "sellingPrice": 21750000,
    "currency": "IDR",
    "status": "draft",
    "visibility": "public",
    "services": [
      {
        "id": "aa0e8400-e29b-41d4-a716-446655440000",
        "serviceType": "hotel",
        "serviceName": "Elaf Al Mashaer Hotel",
        "quantity": 14,
        "unit": "nights",
        "unitCost": 500000,
        "totalCost": 7000000
      },
      {
        "id": "bb0e8400-e29b-41d4-a716-446655440000",
        "serviceType": "flight",
        "serviceName": "Garuda Indonesia CGK-JED",
        "quantity": 1,
        "unit": "pax",
        "unitCost": 10000000,
        "totalCost": 10000000
      }
    ],
    "departures": [
      {
        "id": "cc0e8400-e29b-41d4-a716-446655440000",
        "departureCode": "MAR15",
        "departureDate": "2026-03-15",
        "returnDate": "2026-03-29",
        "totalQuota": 40,
        "availableQuota": 40
      }
    ],
    "createdAt": "2026-02-11T10:00:00Z",
    "updatedAt": "2026-02-11T10:00:00Z"
  },
  "message": "Package created successfully"
}
```

#### Create Booking (Traveler)

**Request:**
```http
POST /v1/traveler/my-bookings
Authorization: Bearer {token}
Content-Type: application/json

{
  "packageId": "990e8400-e29b-41d4-a716-446655440000",
  "packageDepartureId": "cc0e8400-e29b-41d4-a716-446655440000",
  "customerName": "Ahmad Yani",
  "customerEmail": "ahmad@email.com",
  "customerPhone": "+628123456789",
  "travelers": [
    {
      "travelerNumber": 1,
      "fullName": "Ahmad Yani",
      "gender": "male",
      "dateOfBirth": "1980-05-15",
      "nationality": "Indonesian",
      "passportNumber": "A1234567",
      "passportExpiryDate": "2028-12-31",
      "requiresMahram": false
    },
    {
      "travelerNumber": 2,
      "fullName": "Siti Aisyah",
      "gender": "female",
      "dateOfBirth": "1985-03-20",
      "nationality": "Indonesian",
      "passportNumber": "A7654321",
      "passportExpiryDate": "2029-06-30",
      "requiresMahram": true,
      "mahramTravelerNumber": 1,
      "mahramRelationship": "husband"
    }
  ]
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "data": {
    "id": "dd0e8400-e29b-41d4-a716-446655440000",
    "bookingReference": "BKG-260211-001",
    "bookingStatus": "pending",
    "customerName": "Ahmad Yani",
    "customerEmail": "ahmad@email.com",
    "customerPhone": "+628123456789",
    "totalAmount": 43500000,
    "travelerCount": 2,
    "package": {
      "id": "990e8400-e29b-41d4-a716-446655440000",
      "packageCode": "PKG-001",
      "name": "Umrah Premium March 2026",
      "packageType": "umrah"
    },
    "departure": {
      "id": "cc0e8400-e29b-41d4-a716-446655440000",
      "departureCode": "MAR15",
      "departureDate": "2026-03-15",
      "returnDate": "2026-03-29"
    },
    "travelers": [
      {
        "travelerNumber": 1,
        "fullName": "Ahmad Yani",
        "gender": "male",
        "passportNumber": "A1234567"
      },
      {
        "travelerNumber": 2,
        "fullName": "Siti Aisyah",
        "gender": "female",
        "passportNumber": "A7654321",
        "mahramTravelerNumber": 1,
        "mahramRelationship": "husband"
      }
    ],
    "createdAt": "2026-02-11T11:30:00Z"
  },
  "message": "Booking created successfully. Waiting for agency approval."
}
```

#### Approve Booking (Agency)

**Request:**
```http
PATCH /v1/bookings/dd0e8400-e29b-41d4-a716-446655440000/approve
Authorization: Bearer {token}
X-Tenant-ID: 660e8400-e29b-41d4-a716-446655440000
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "dd0e8400-e29b-41d4-a716-446655440000",
    "bookingReference": "BKG-260211-001",
    "bookingStatus": "approved",
    "approvedAt": "2026-02-11T12:00:00Z",
    "approvedBy": "550e8400-e29b-41d4-a716-446655440000"
  },
  "message": "Booking approved successfully. Quota has been decremented."
}
```

### Query Parameters

#### Pagination

All list endpoints support pagination:

```
GET /packages?page=1&perPage=20
```

**Parameters:**
- `page` (integer, default: 1): Page number
- `perPage` (integer, default: 20, max: 100): Items per page

**Response includes pagination metadata:**
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "page": 1,
    "perPage": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

#### Filtering

```
GET /bookings?status=pending&dateFrom=2026-02-01&dateTo=2026-02-28
```

**Common filter parameters:**
- `status`: Filter by status (varies by entity)
- `type`: Filter by type (package_type, service_type, etc.)
- `dateFrom`: Filter by date range start
- `dateTo`: Filter by date range end

#### Searching

```
GET /packages?search=umrah
```

**Search parameter:**
- `search`: Search term (searches name, description, code fields)

#### Sorting

```
GET /packages?sortBy=createdAt&sortOrder=desc
```

**Sort parameters:**
- `sortBy`: Field to sort by (createdAt, name, price, etc.)
- `sortOrder`: Sort direction (asc, desc)

### Error Responses

#### Validation Error (400)

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more validation errors occurred",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      },
      {
        "field": "sellingPrice",
        "message": "Selling price must be greater than or equal to base cost"
      }
    ]
  },
  "traceId": "abc123-def456"
}
```

#### Unauthorized (401)

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token"
  },
  "traceId": "xyz789-uvw012"
}
```

#### Forbidden (403)

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to access this resource"
  },
  "traceId": "mno345-pqr678"
}
```

#### Not Found (404)

```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Package with ID '990e8400-e29b-41d4-a716-446655440000' not found"
  },
  "traceId": "stu901-vwx234"
}
```

#### Conflict (409)

```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_QUOTA",
    "message": "Cannot approve booking: insufficient quota available",
    "details": [
      {
        "field": "availableQuota",
        "message": "Available: 5, Requested: 10"
      }
    ]
  },
  "traceId": "yza567-bcd890"
}
```

#### Internal Server Error (500)

```json
{
  "success": false,
  "error": {
    "code": "INTERNAL_ERROR",
    "message": "An unexpected error occurred. Please contact support with trace ID."
  },
  "traceId": "efg123-hij456"
}
```

### Rate Limiting

**Rate limits (per user):**
- Authentication endpoints: 5 requests per minute
- Read endpoints (GET): 100 requests per minute
- Write endpoints (POST, PUT, PATCH, DELETE): 30 requests per minute

**Rate limit headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1644580800
```

**Rate limit exceeded response (429):**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "retryAfter": 60
  }
}
```
## Error Handling

### Exception Handling Strategy

The API implements a global exception handling middleware that catches all exceptions and converts them to appropriate HTTP responses.

**Exception Types and HTTP Status Codes:**

| Exception Type | HTTP Status | Error Code | Description |
|---------------|-------------|------------|-------------|
| ValidationException | 400 | VALIDATION_ERROR | Input validation failed |
| UnauthorizedException | 401 | UNAUTHORIZED | Authentication required or token invalid |
| ForbiddenException | 403 | FORBIDDEN | User lacks permission for resource |
| NotFoundException | 404 | NOT_FOUND | Requested resource does not exist |
| ConflictException | 409 | CONFLICT | Resource conflict (duplicate, constraint violation) |
| BusinessRuleException | 422 | BUSINESS_RULE_VIOLATION | Business logic constraint violated |
| Exception (unhandled) | 500 | INTERNAL_ERROR | Unexpected server error |

### Error Response Format

All error responses follow a consistent structure:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [
      {
        "field": "field_name",
        "message": "Field-specific error message"
      }
    ]
  },
  "traceId": "unique-trace-id-for-debugging"
}
```

### Validation Error Example

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more validation errors occurred",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      },
      {
        "field": "selling_price",
        "message": "Selling price must be greater than or equal to base cost"
      }
    ]
  },
  "traceId": "abc123-def456"
}
```

### Business Rule Violation Example

```json
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_QUOTA",
    "message": "Cannot approve booking: insufficient quota available",
    "details": [
      {
        "field": "available_quota",
        "message": "Available quota: 5, Requested: 10"
      }
    ]
  },
  "traceId": "xyz789-uvw012"
}
```

### Exception Handling Middleware Implementation

```csharp
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (ValidationException ex)
        {
            await HandleValidationException(context, ex);
        }
        catch (UnauthorizedException ex)
        {
            await HandleUnauthorizedException(context, ex);
        }
        catch (ForbiddenException ex)
        {
            await HandleForbiddenException(context, ex);
        }
        catch (NotFoundException ex)
        {
            await HandleNotFoundException(context, ex);
        }
        catch (ConflictException ex)
        {
            await HandleConflictException(context, ex);
        }
        catch (BusinessRuleException ex)
        {
            await HandleBusinessRuleException(context, ex);
        }
        catch (Exception ex)
        {
            await HandleUnhandledException(context, ex);
        }
    }

    private async Task HandleUnhandledException(HttpContext context, Exception ex)
    {
        var traceId = Guid.NewGuid().ToString();
        
        _logger.LogError(ex, "Unhandled exception occurred. TraceId: {TraceId}", traceId);
        
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = "INTERNAL_ERROR",
                Message = "An unexpected error occurred. Please contact support with trace ID.",
            },
            TraceId = traceId
        };
        
        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }
}
```

### Logging Strategy

**Structured Logging with Serilog:**

```csharp
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "TourTravelAPI")
    .Enrich.WithMachineName()
    .WriteTo.Console(new JsonFormatter())
    .WriteTo.File(
        new JsonFormatter(),
        "logs/api-.log",
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 30
    )
    .CreateLogger();
```

**Log Levels:**

- **Debug**: Detailed diagnostic information (development only)
- **Information**: General application flow (requests, responses, business events)
- **Warning**: Unexpected but recoverable situations (validation failures, quota warnings)
- **Error**: Errors that prevent operation completion (exceptions, database errors)
- **Critical**: Critical failures requiring immediate attention (database unavailable, configuration errors)

**Logged Information:**

1. **HTTP Requests**: Method, path, query parameters, user ID, tenant ID, duration, status code
2. **Database Queries**: SQL statement, parameters, duration, row count
3. **Authentication Events**: Login attempts, token generation, token validation failures
4. **Business Events**: Booking created, package published, supplier approved
5. **Exceptions**: Type, message, stack trace, inner exceptions, trace ID

**Sensitive Data Protection:**

- Passwords and password hashes are never logged
- JWT tokens are logged only as truncated values (first 10 characters)
- Credit card numbers and personal identification numbers are masked
- Email addresses and phone numbers are partially masked in production logs

## Testing Strategy

### Testing Approach

The system implements a comprehensive testing strategy combining unit tests, property-based tests, integration tests, and end-to-end tests.

**Testing Pyramid:**

```
         /\
        /E2E\          ← Few, high-value end-to-end tests
       /------\
      /  Integ \       ← Integration tests with Testcontainers
     /----------\
    / Unit + PBT \     ← Many unit and property-based tests
   /--------------\
```

### Unit Testing

**Framework**: xUnit with FluentAssertions

**Scope**: Individual components in isolation

**Coverage Areas:**
- Command and query handlers
- Validators (FluentValidation)
- Domain entities and value objects
- Repository implementations
- Service classes
- Middleware components

**Example Unit Test:**

```csharp
public class CreatePackageCommandHandlerTests
{
    [Fact]
    public async Task Handle_ValidCommand_CreatesPackage()
    {
        // Arrange
        var mockRepo = new Mock<IPackageRepository>();
        var mockUnitOfWork = new Mock<IUnitOfWork>();
        var handler = new CreatePackageCommandHandler(mockRepo.Object, mockUnitOfWork.Object);
        
        var command = new CreatePackageCommand
        {
            PackageType = "umrah",
            Name = "Test Package",
            DurationDays = 15,
            BaseCost = 20000000,
            SellingPrice = 25000000
        };
        
        // Act
        var result = await handler.Handle(command, CancellationToken.None);
        
        // Assert
        result.Should().NotBeNull();
        result.PackageCode.Should().StartWith("PKG-");
        mockRepo.Verify(r => r.AddAsync(It.IsAny<Package>()), Times.Once);
        mockUnitOfWork.Verify(u => u.SaveChangesAsync(), Times.Once);
    }
    
    [Fact]
    public async Task Handle_SellingPriceLessThanBaseCost_ThrowsValidationException()
    {
        // Arrange
        var handler = new CreatePackageCommandHandler(null, null);
        var command = new CreatePackageCommand
        {
            BaseCost = 25000000,
            SellingPrice = 20000000  // Invalid: less than base cost
        };
        
        // Act & Assert
        await Assert.ThrowsAsync<ValidationException>(() => 
            handler.Handle(command, CancellationToken.None));
    }
}
```

### Property-Based Testing

**Framework**: FsCheck (F# property testing library for .NET)

**Scope**: Universal properties that should hold for all inputs

**Configuration**: Minimum 100 iterations per property test

**Property Test Tagging**: Each test references its design document property

```csharp
// Feature: backend-api-phase1, Property 22: Package Pricing Calculation
[Property(MaxTest = 100)]
public Property PackagePricingCalculation_ShouldEqualSumOfServices()
{
    return Prop.ForAll(
        GeneratePackageWithServices(),
        package =>
        {
            var expectedBaseCost = package.Services.Sum(s => s.TotalCost);
            var expectedSellingPrice = package.MarkupType == "fixed"
                ? expectedBaseCost + package.MarkupAmount
                : expectedBaseCost * (1 + package.MarkupPercentage / 100);
            
            return package.BaseCost == expectedBaseCost &&
                   package.SellingPrice == expectedSellingPrice;
        }
    );
}

// Feature: backend-api-phase1, Property 30: Quota Management Round Trip
[Property(MaxTest = 100)]
public Property QuotaManagement_ApprovalThenCancellation_RestoresOriginalQuota()
{
    return Prop.ForAll(
        GenerateDepartureWithBooking(),
        (departure, booking) =>
        {
            var originalQuota = departure.AvailableQuota;
            
            // Approve booking (decrement quota)
            departure.DecrementQuota(booking.TravelerCount);
            
            // Cancel booking (increment quota)
            departure.IncrementQuota(booking.TravelerCount);
            
            return departure.AvailableQuota == originalQuota;
        }
    );
}

// Feature: backend-api-phase1, Property 37: Mahram Relationship Validation
[Property(MaxTest = 100)]
public Property MahramValidation_FemaleTravelerRequiresMahram_ReferencesValidMaleTraveler()
{
    return Prop.ForAll(
        GenerateBookingWithFemaleTraveler(),
        booking =>
        {
            var femaleTravelers = booking.Travelers.Where(t => 
                t.Gender == "female" && t.RequiresMahram);
            
            return femaleTravelers.All(female =>
            {
                var mahram = booking.Travelers.FirstOrDefault(t => 
                    t.TravelerNumber == female.MahramTravelerNumber);
                
                return mahram != null && 
                       mahram.Gender == "male" &&
                       !string.IsNullOrEmpty(female.MahramRelationship);
            });
        }
    );
}
```

**Generator Examples:**

```csharp
public static Arbitrary<Package> GeneratePackageWithServices()
{
    return Arb.From(
        from serviceCount in Gen.Choose(1, 10)
        from services in Gen.ListOf(serviceCount, GeneratePackageService())
        from markupType in Gen.Elements("fixed", "percentage")
        from markup in Gen.Choose(1000000, 10000000)
        let baseCost = services.Sum(s => s.TotalCost)
        let sellingPrice = markupType == "fixed" 
            ? baseCost + markup 
            : baseCost * (1 + markup / 100m)
        select new Package
        {
            Services = services,
            BaseCost = baseCost,
            MarkupType = markupType,
            MarkupAmount = markupType == "fixed" ? markup : 0,
            MarkupPercentage = markupType == "percentage" ? markup : 0,
            SellingPrice = sellingPrice
        }
    );
}
```

### Integration Testing

**Framework**: xUnit with Testcontainers

**Scope**: Multi-component interactions with real database

**Testcontainers Setup:**

```csharp
public class IntegrationTestBase : IAsyncLifetime
{
    private readonly PostgreSqlContainer _dbContainer;
    protected IServiceProvider ServiceProvider { get; private set; }
    
    public IntegrationTestBase()
    {
        _dbContainer = new PostgreSqlBuilder()
            .WithImage("postgres:16")
            .WithDatabase("tourtravel_test")
            .WithUsername("test")
            .WithPassword("test")
            .Build();
    }
    
    public async Task InitializeAsync()
    {
        await _dbContainer.StartAsync();
        
        var services = new ServiceCollection();
        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(_dbContainer.GetConnectionString()));
        
        // Add application services
        services.AddMediatR(typeof(CreatePackageCommand).Assembly);
        services.AddScoped<IPackageRepository, PackageRepository>();
        // ... other services
        
        ServiceProvider = services.BuildServiceProvider();
        
        // Apply migrations
        using var scope = ServiceProvider.CreateScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await dbContext.Database.MigrateAsync();
    }
    
    public async Task DisposeAsync()
    {
        await _dbContainer.DisposeAsync();
    }
}

public class PackageIntegrationTests : IntegrationTestBase
{
    [Fact]
    public async Task CreatePackage_WithServices_PersistsToDatabase()
    {
        // Arrange
        using var scope = ServiceProvider.CreateScope();
        var mediator = scope.ServiceProvider.GetRequiredService<IMediator>();
        
        var command = new CreatePackageCommand
        {
            PackageType = "umrah",
            Name = "Integration Test Package",
            DurationDays = 15,
            Services = new List<PackageServiceDto>
            {
                new(Guid.NewGuid(), "hotel", 10, "nights", 500000)
            },
            BaseCost = 5000000,
            SellingPrice = 6000000
        };
        
        // Act
        var result = await mediator.Send(command);
        
        // Assert
        var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var package = await dbContext.Packages
            .Include(p => p.Services)
            .FirstOrDefaultAsync(p => p.Id == result.Id);
        
        package.Should().NotBeNull();
        package.Services.Should().HaveCount(1);
    }
}
```

### End-to-End Testing

**Framework**: xUnit with WebApplicationFactory

**Scope**: Full HTTP request/response cycle

**Example E2E Test:**

```csharp
public class BookingE2ETests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly WebApplicationFactory<Program> _factory;
    private readonly HttpClient _client;
    
    public BookingE2ETests(WebApplicationFactory<Program> factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }
    
    [Fact]
    public async Task CreateBooking_ApproveBooking_DecrementsQuota()
    {
        // Arrange: Login as traveler
        var loginResponse = await _client.PostAsJsonAsync("/v1/auth/login", new
        {
            email = "traveler@test.com",
            password = "password123"
        });
        var loginData = await loginResponse.Content.ReadFromJsonAsync<LoginResponse>();
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", loginData.Token);
        
        // Act 1: Create booking
        var createBookingResponse = await _client.PostAsJsonAsync("/v1/traveler/my-bookings", new
        {
            package_id = "test-package-id",
            package_departure_id = "test-departure-id",
            customer_name = "Test Customer",
            customer_email = "customer@test.com",
            customer_phone = "+628123456789",
            travelers = new[]
            {
                new
                {
                    traveler_number = 1,
                    full_name = "Test Traveler",
                    gender = "male",
                    date_of_birth = "1990-01-01",
                    nationality = "Indonesian",
                    passport_number = "A1234567",
                    passport_expiry_date = "2030-12-31"
                }
            }
        });
        
        createBookingResponse.StatusCode.Should().Be(HttpStatusCode.Created);
        var booking = await createBookingResponse.Content.ReadFromJsonAsync<BookingResponse>();
        
        // Act 2: Login as agency staff and approve booking
        var agencyLoginResponse = await _client.PostAsJsonAsync("/v1/auth/login", new
        {
            email = "agency@test.com",
            password = "password123"
        });
        var agencyLoginData = await agencyLoginResponse.Content.ReadFromJsonAsync<LoginResponse>();
        _client.DefaultRequestHeaders.Authorization = 
            new AuthenticationHeaderValue("Bearer", agencyLoginData.Token);
        
        var approveResponse = await _client.PatchAsync(
            $"/v1/bookings/{booking.Id}/approve", null);
        
        // Assert
        approveResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        
        // Verify quota was decremented
        var departureResponse = await _client.GetAsync(
            $"/v1/packages/{booking.Package.Id}/departures");
        var departures = await departureResponse.Content.ReadFromJsonAsync<List<DepartureResponse>>();
        var departure = departures.First(d => d.Id == booking.PackageDepartureId);
        
        departure.AvailableQuota.Should().BeLessThan(departure.TotalQuota);
    }
}
```

### Test Coverage Goals

**Minimum Coverage Targets:**
- Unit Tests: 80% code coverage
- Property Tests: All correctness properties from design document
- Integration Tests: All critical workflows (booking, package creation, quota management)
- E2E Tests: All user journeys (traveler booking, agency approval, supplier service creation)

### Continuous Integration

**CI Pipeline:**
1. Run unit tests (fast feedback)
2. Run property-based tests (100 iterations each)
3. Run integration tests with Testcontainers
4. Run E2E tests
5. Generate code coverage report
6. Fail build if coverage < 80%

**Test Execution Time Targets:**
- Unit tests: < 30 seconds
- Property tests: < 2 minutes
- Integration tests: < 5 minutes
- E2E tests: < 10 minutes
- Total CI pipeline: < 20 minutes

## Docker Configuration

### Dockerfile

The application uses a multi-stage Dockerfile for optimized production builds:

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY ["TourTravel.sln", "./"]
COPY ["src/TourTravel.API/TourTravel.API.csproj", "src/TourTravel.API/"]
COPY ["src/TourTravel.Application/TourTravel.Application.csproj", "src/TourTravel.Application/"]
COPY ["src/TourTravel.Domain/TourTravel.Domain.csproj", "src/TourTravel.Domain/"]
COPY ["src/TourTravel.Infrastructure/TourTravel.Infrastructure.csproj", "src/TourTravel.Infrastructure/"]

# Restore dependencies
RUN dotnet restore "TourTravel.sln"

# Copy source code
COPY . .

# Build application
WORKDIR "/src/src/TourTravel.API"
RUN dotnet build "TourTravel.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "TourTravel.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --ingroup appuser appuser

# Copy published application
COPY --from=publish /app/publish .

# Set ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Entry point
ENTRYPOINT ["dotnet", "TourTravel.API.dll"]
```

### Docker Compose

The `docker-compose.yml` file orchestrates the API and PostgreSQL services:

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    container_name: tourtravel-postgres
    environment:
      POSTGRES_DB: ${DB_NAME:-tourtravel}
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
      POSTGRES_INITDB_ARGS: "--encoding=UTF8 --locale=en_US.UTF-8"
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - tourtravel-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres} -d ${DB_NAME:-tourtravel}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  # API Service
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: tourtravel-api
    environment:
      # Database Configuration
      ConnectionStrings__DefaultConnection: "Host=postgres;Port=5432;Database=${DB_NAME:-tourtravel};Username=${DB_USER:-postgres};Password=${DB_PASSWORD:-postgres}"
      
      # JWT Configuration
      Jwt__Secret: ${JWT_SECRET:-your-super-secret-jwt-key-change-in-production}
      Jwt__Issuer: ${JWT_ISSUER:-https://api.tourtravel.com}
      Jwt__Audience: ${JWT_AUDIENCE:-https://tourtravel.com}
      Jwt__ExpiryMinutes: ${JWT_EXPIRY_MINUTES:-60}
      Jwt__RefreshTokenExpiryDays: ${JWT_REFRESH_EXPIRY_DAYS:-7}
      
      # Application Configuration
      ASPNETCORE_ENVIRONMENT: ${ASPNETCORE_ENVIRONMENT:-Production}
      ASPNETCORE_URLS: http://+:8080
      
      # Logging Configuration
      Logging__LogLevel__Default: ${LOG_LEVEL:-Information}
      Logging__LogLevel__Microsoft: Warning
      Logging__LogLevel__Microsoft.EntityFrameworkCore: Warning
      
      # CORS Configuration
      Cors__AllowedOrigins: ${CORS_ORIGINS:-http://localhost:3000,http://localhost:5173}
      
      # Pagination Configuration
      Pagination__DefaultPageSize: ${DEFAULT_PAGE_SIZE:-20}
      Pagination__MaxPageSize: ${MAX_PAGE_SIZE:-100}
      
      # Feature Flags
      Features__EnableSwagger: ${ENABLE_SWAGGER:-true}
      Features__EnableSeedData: ${ENABLE_SEED_DATA:-false}
      Features__EnableDetailedErrors: ${ENABLE_DETAILED_ERRORS:-false}
    ports:
      - "${API_PORT:-8080}:8080"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - tourtravel-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped
    volumes:
      - api_logs:/app/logs

  # PgAdmin (Optional - for development)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: tourtravel-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@tourtravel.com}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    ports:
      - "${PGADMIN_PORT:-5050}:80"
    depends_on:
      - postgres
    networks:
      - tourtravel-network
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    restart: unless-stopped
    profiles:
      - dev

networks:
  tourtravel-network:
    driver: bridge

volumes:
  postgres_data:
    driver: local
  api_logs:
    driver: local
  pgadmin_data:
    driver: local
```

### Environment Variables

Create a `.env` file for local development:

```env
# Database Configuration
DB_NAME=tourtravel
DB_USER=postgres
DB_PASSWORD=postgres
DB_PORT=5432

# API Configuration
API_PORT=8080
ASPNETCORE_ENVIRONMENT=Development

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters-long
JWT_ISSUER=https://api.tourtravel.com
JWT_AUDIENCE=https://tourtravel.com
JWT_EXPIRY_MINUTES=60
JWT_REFRESH_EXPIRY_DAYS=7

# Logging
LOG_LEVEL=Information

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:5173

# Pagination
DEFAULT_PAGE_SIZE=20
MAX_PAGE_SIZE=100

# Feature Flags
ENABLE_SWAGGER=true
ENABLE_SEED_DATA=true
ENABLE_DETAILED_ERRORS=true

# PgAdmin (Optional)
PGADMIN_EMAIL=admin@tourtravel.com
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050
```

### Database Initialization Script

The `scripts/init-db.sql` file sets up PostgreSQL extensions and initial configuration:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable pg_trgm for text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create custom types
DO $$ BEGIN
    CREATE TYPE user_type AS ENUM ('platform_admin', 'agency_staff', 'supplier', 'customer');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE subscription_plan AS ENUM ('basic', 'pro', 'enterprise');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE supplier_status AS ENUM ('pending', 'active', 'suspended', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE service_type AS ENUM ('hotel', 'flight', 'visa', 'transport', 'guide');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE package_type AS ENUM ('umrah', 'hajj', 'tour', 'custom');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE booking_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled', 'completed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Set default timezone
SET timezone = 'UTC';

-- Configure connection pooling
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
ALTER SYSTEM SET maintenance_work_mem = '64MB';
ALTER SYSTEM SET checkpoint_completion_target = 0.9;
ALTER SYSTEM SET wal_buffers = '16MB';
ALTER SYSTEM SET default_statistics_target = 100;
ALTER SYSTEM SET random_page_cost = 1.1;
ALTER SYSTEM SET effective_io_concurrency = 200;
ALTER SYSTEM SET work_mem = '4MB';
ALTER SYSTEM SET min_wal_size = '1GB';
ALTER SYSTEM SET max_wal_size = '4GB';

-- Reload configuration
SELECT pg_reload_conf();
```

### Docker Commands

**Build and start services:**
```bash
docker-compose up -d
```

**Build with no cache:**
```bash
docker-compose build --no-cache
docker-compose up -d
```

**View logs:**
```bash
# All services
docker-compose logs -f

# API only
docker-compose logs -f api

# PostgreSQL only
docker-compose logs -f postgres
```

**Stop services:**
```bash
docker-compose down
```

**Stop and remove volumes (clean slate):**
```bash
docker-compose down -v
```

**Run database migrations:**
```bash
docker-compose exec api dotnet ef database update
```

**Access PostgreSQL CLI:**
```bash
docker-compose exec postgres psql -U postgres -d tourtravel
```

**Start with PgAdmin (development profile):**
```bash
docker-compose --profile dev up -d
```

### Production Deployment Considerations

**Security:**
- Use Docker secrets for sensitive environment variables
- Run containers as non-root users (already configured)
- Use read-only root filesystem where possible
- Implement network policies to restrict inter-container communication
- Regularly update base images for security patches

**Performance:**
- Use multi-stage builds to minimize image size
- Implement health checks for container orchestration
- Configure resource limits (CPU, memory) in production
- Use connection pooling for database connections
- Enable HTTP/2 and compression

**Monitoring:**
- Integrate with logging aggregation (ELK, Splunk, CloudWatch)
- Set up container metrics collection (Prometheus, Datadog)
- Configure alerting for health check failures
- Monitor database connection pool usage
- Track API response times and error rates

**High Availability:**
- Deploy multiple API container replicas
- Use PostgreSQL replication for database redundancy
- Implement load balancing (Nginx, HAProxy, AWS ALB)
- Configure automatic container restart policies
- Set up database backup and recovery procedures

### Kubernetes Deployment (Optional)

For Kubernetes deployment, convert Docker Compose to Kubernetes manifests:

```bash
# Install kompose
curl -L https://github.com/kubernetes/kompose/releases/download/v1.31.2/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv kompose /usr/local/bin/

# Convert docker-compose.yml to Kubernetes manifests
kompose convert -f docker-compose.yml -o k8s/
```

This generates Kubernetes Deployment, Service, and PersistentVolumeClaim manifests that can be customized for production use.
