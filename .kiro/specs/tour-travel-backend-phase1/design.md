# Design Document

## Overview

This design document specifies the technical architecture for Phase 1 MVP of a Multi-Tenant Tour & Travel Agency ERP SaaS Platform. The system is built using Clean Architecture with CQRS pattern, .NET 8, PostgreSQL 16 with Row-Level Security, and implements comprehensive B2B procurement and marketplace functionality.

### System Architecture

The system follows Clean Architecture with four distinct layers:

1. **API Layer**: Controllers, middleware, filters, authentication
2. **Application Layer**: CQRS commands/queries, DTOs, validators, interfaces
3. **Domain Layer**: Entities, value objects, domain interfaces
4. **Infrastructure Layer**: EF Core, repositories, external services, background jobs

### Technology Stack

- **Backend**: .NET 8 (C# 12), ASP.NET Core 8
- **Database**: PostgreSQL 16 with Row-Level Security (RLS)
- **ORM**: Entity Framework Core 8
- **CQRS**: MediatR 12
- **Validation**: FluentValidation 11
- **Authentication**: JWT Bearer tokens
- **Password Hashing**: BCrypt.Net-Next
- **Background Jobs**: Hangfire
- **API Documentation**: Swashbuckle (Swagger/OpenAPI)

### Multi-Tenancy Strategy

The system implements Row-Level Security (RLS) in PostgreSQL for complete data isolation:
- Each agency is a tenant with unique `agency_id`
- RLS policies automatically filter data per tenant
- Session variable `app.current_agency_id` set from JWT token on each request
- Platform admins can access all agencies' data
- Suppliers and agencies can only access their own data

## Architecture

### Clean Architecture Layers

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
│  EF Core, Repositories, External Services, Jobs        │
└─────────────────────────────────────────────────────────┘
```

### Request Flow

1. HTTP Request → API Controller
2. Controller → MediatR Command/Query
3. MediatR → Command/Query Handler
4. Handler → Domain Entities (via Repository)
5. Domain Entities → Business Logic Execution
6. Repository → EF Core → PostgreSQL (with RLS)
7. Response ← Handler ← MediatR ← Controller

### Authentication Flow

1. User submits credentials to `/api/auth/login`
2. System validates credentials and retrieves user with agency/supplier context
3. System generates JWT token containing: user_id, email, user_type, agency_id/supplier_id
4. Client stores JWT token
5. Client includes JWT in Authorization header for subsequent requests
6. Middleware validates JWT and sets `app.current_agency_id` session variable
7. RLS policies automatically filter queries based on session variable


## Components and Interfaces

### Domain Entities

#### Core Entities

**User**
- Properties: Id, Email, PasswordHash, UserType, FullName, Phone, AgencyId, SupplierId, IsActive
- Methods: ValidatePassword(), UpdateProfile()
- Relationships: BelongsTo Agency, BelongsTo Supplier

**Agency**
- Properties: Id, AgencyCode, CompanyName, Email, Phone, Address, City, Province, PostalCode, SubscriptionPlan, IsActive
- Methods: Activate(), Deactivate(), UpdateDetails()
- Relationships: HasMany Users, HasMany Packages, HasMany Bookings

**Supplier**
- Properties: Id, SupplierCode, CompanyName, Email, Phone, Address, BusinessType, Status, ApprovedAt, ApprovedBy
- Methods: Approve(), Reject(), Suspend()
- Relationships: HasMany Users, HasMany SupplierServices

#### Service Entities

**SupplierService**
- Properties: Id, SupplierId, ServiceCode, ServiceType, Name, Description, BasePrice, Currency, LocationCity, LocationCountry
- Type-specific properties: Airline, HotelName, VisaType, VehicleType, etc.
- Methods: Publish(), Unpublish(), UpdatePrice(), GetPriceForDate()
- Relationships: BelongsTo Supplier, HasMany SeasonalPrices

**SupplierServiceSeasonalPrice**
- Properties: Id, SupplierServiceId, SeasonName, StartDate, EndDate, SeasonalPrice, IsActive
- Methods: Validate(), IsActiveForDate()
- Relationships: BelongsTo SupplierService

#### Purchase Order Entities

**PurchaseOrder**
- Properties: Id, PONumber, AgencyId, SupplierId, Status, TotalAmount, Notes, RejectionReason
- Methods: Approve(), Reject(), CalculateTotal()
- Relationships: BelongsTo Agency, BelongsTo Supplier, HasMany POItems

**POItem**
- Properties: Id, POId, ServiceId, ServiceType, Quantity, UnitPrice, TotalPrice, StartDate, EndDate
- Methods: CalculateTotal()
- Relationships: BelongsTo PurchaseOrder, BelongsTo SupplierService

#### Package and Journey Entities

**Package**
- Properties: Id, AgencyId, PackageCode, PackageType, Name, Description, DurationDays, BaseCost, MarkupType, MarkupValue, SellingPrice, Visibility, Status
- Methods: Publish(), CalculateSellingPrice(), AddService()
- Relationships: BelongsTo Agency, HasMany PackageServices, HasMany Journeys, HasOne Itinerary

**PackageService**
- Properties: Id, PackageId, SupplierServiceId, AgencyServiceId, SourceType, Quantity, UnitCost, TotalCost
- Methods: CalculateCost()
- Relationships: BelongsTo Package, BelongsTo SupplierService, BelongsTo AgencyService

**Journey**
- Properties: Id, AgencyId, PackageId, JourneyCode, DepartureDate, ReturnDate, TotalQuota, ConfirmedPax, AvailableQuota, Status
- Methods: DecrementQuota(), IncrementQuota(), ValidateQuota()
- Relationships: BelongsTo Agency, BelongsTo Package, HasMany Bookings, HasMany JourneyServices

**JourneyService**
- Properties: Id, JourneyId, ServiceType, SupplierServiceId, AgencyServiceId, SourceType, BookingStatus, ExecutionStatus, PaymentStatus
- Methods: UpdateStatus()
- Relationships: BelongsTo Journey

#### Customer and Booking Entities

**Customer**
- Properties: Id, AgencyId, CustomerCode, Name, Email, Phone, Address, City, Province, PostalCode, Country, Notes, Tags, TotalBookings, TotalSpent, LastBookingDate
- Methods: UpdateStatistics(), AddNote(), AddTag()
- Relationships: BelongsTo Agency, HasMany Bookings, HasMany CommunicationLogs

**Booking**
- Properties: Id, AgencyId, PackageId, JourneyId, CustomerId, BookingReference, BookingStatus, TotalPax, TotalAmount, BookingSource, Notes
- Methods: Approve(), Cancel(), CalculateAmount()
- Relationships: BelongsTo Agency, BelongsTo Package, BelongsTo Journey, BelongsTo Customer, HasMany Travelers, HasMany BookingDocuments, HasMany BookingTasks

**Traveler**
- Properties: Id, BookingId, TravelerNumber, FullName, Gender, DateOfBirth, Nationality, PassportNumber, PassportExpiry, MahramTravelerNumber
- Methods: ValidateMahram(), CalculateAge()
- Relationships: BelongsTo Booking

#### Document Management Entities

**DocumentType**
- Properties: Id, Name, RequiredForPackageTypes, Description, ExpiryTrackingEnabled
- Methods: IsRequiredForPackageType()
- Relationships: HasMany BookingDocuments

**BookingDocument**
- Properties: Id, BookingId, TravelerId, DocumentTypeId, Status, DocumentNumber, IssueDate, ExpiryDate, Notes, RejectionReason
- Methods: Submit(), Verify(), Reject(), ValidateExpiry()
- Relationships: BelongsTo Booking, BelongsTo Traveler, BelongsTo DocumentType

#### Task Management Entities

**TaskTemplate**
- Properties: Id, AgencyId, Name, Description, TriggerStage, DueDaysOffset, AssigneeRole, IsActive
- Methods: GenerateTask()
- Relationships: BelongsTo Agency, HasMany BookingTasks

**BookingTask**
- Properties: Id, BookingId, TaskTemplateId, Title, Description, Status, Priority, AssignedTo, DueDate, CompletedAt, CompletedBy, IsCustom
- Methods: Assign(), UpdateStatus(), Complete()
- Relationships: BelongsTo Booking, BelongsTo TaskTemplate, BelongsTo User (AssignedTo)

#### Notification Entities

**NotificationSchedule**
- Properties: Id, AgencyId, Name, TriggerDaysBefore, NotificationType, TemplateId, IsEnabled
- Methods: Enable(), Disable()
- Relationships: BelongsTo Agency, BelongsTo NotificationTemplate

**NotificationTemplate**
- Properties: Id, AgencyId, Name, Subject, Body, Variables
- Methods: RenderWithData()
- Relationships: BelongsTo Agency, HasMany NotificationSchedules

**NotificationLog**
- Properties: Id, BookingId, ScheduleId, RecipientEmail, RecipientPhone, NotificationType, Subject, Body, Status, SentAt, OpenedAt, ErrorMessage, RetryCount
- Methods: MarkAsSent(), MarkAsFailed(), IncrementRetry()
- Relationships: BelongsTo Booking, BelongsTo NotificationSchedule

#### Payment Entities

**PaymentSchedule**
- Properties: Id, BookingId, InstallmentNumber, InstallmentName, DueDate, Amount, Status, PaidAmount, PaidDate, PaymentMethod
- Methods: RecordPayment(), CalculateStatus()
- Relationships: BelongsTo Booking, HasMany PaymentTransactions

**PaymentTransaction**
- Properties: Id, BookingId, ScheduleId, Amount, PaymentMethod, PaymentDate, ReferenceNumber, Notes, RecordedBy
- Methods: Validate()
- Relationships: BelongsTo Booking, BelongsTo PaymentSchedule, BelongsTo User (RecordedBy)

#### Itinerary Entities

**Itinerary**
- Properties: Id, PackageId
- Methods: AddDay(), RemoveDay()
- Relationships: BelongsTo Package, HasMany ItineraryDays

**ItineraryDay**
- Properties: Id, ItineraryId, DayNumber, Title, Description
- Methods: AddActivity(), RemoveActivity()
- Relationships: BelongsTo Itinerary, HasMany ItineraryActivities

**ItineraryActivity**
- Properties: Id, DayId, Time, Location, Activity, Description, MealType
- Methods: Validate()
- Relationships: BelongsTo ItineraryDay

#### Supplier Bills Entities

**SupplierBill**
- Properties: Id, AgencyId, SupplierId, POId, BillNumber, BillDate, DueDate, TotalAmount, PaidAmount, Status, Notes
- Methods: RecordPayment(), CalculateStatus()
- Relationships: BelongsTo Agency, BelongsTo Supplier, BelongsTo PurchaseOrder, HasMany SupplierPayments

**SupplierPayment**
- Properties: Id, BillId, PaymentDate, Amount, PaymentMethod, ReferenceNumber, Notes, RecordedBy
- Methods: Validate()
- Relationships: BelongsTo SupplierBill, BelongsTo User (RecordedBy)

#### Communication Entities

**CommunicationLog**
- Properties: Id, AgencyId, CustomerId, BookingId, CommunicationType, Subject, Notes, FollowUpRequired, FollowUpDate, FollowUpDone, CreatedBy
- Methods: MarkFollowUpDone()
- Relationships: BelongsTo Agency, BelongsTo Customer, BelongsTo Booking, BelongsTo User (CreatedBy)

#### B2B Marketplace Entities

**AgencyService**
- Properties: Id, AgencyId, POId, ServiceType, Name, Description, Specifications, CostPrice, ResellerPrice, MarkupPercentage, TotalQuota, UsedQuota, AvailableQuota, ReservedQuota, SoldQuota, IsPublished
- Methods: Publish(), Unpublish(), ReserveQuota(), ReleaseQuota(), TransferQuota()
- Relationships: BelongsTo Agency, BelongsTo PurchaseOrder, HasMany AgencyOrders

**AgencyOrder**
- Properties: Id, OrderNumber, BuyerAgencyId, SellerAgencyId, AgencyServiceId, Quantity, UnitPrice, TotalPrice, Status, Notes, RejectionReason
- Methods: Approve(), Reject(), Cancel()
- Relationships: BelongsTo Agency (Buyer), BelongsTo Agency (Seller), BelongsTo AgencyService

### Application Layer Interfaces

#### Command Handlers

**Authentication Commands**
- LoginCommand → LoginCommandHandler
- RegisterCommand → RegisterCommandHandler
- RefreshTokenCommand → RefreshTokenCommandHandler

**Agency Commands**
- CreateAgencyCommand → CreateAgencyCommandHandler
- UpdateAgencyCommand → UpdateAgencyCommandHandler
- ActivateAgencyCommand → ActivateAgencyCommandHandler

**Supplier Commands**
- RegisterSupplierCommand → RegisterSupplierCommandHandler
- ApproveSupplierCommand → ApproveSupplierCommandHandler
- RejectSupplierCommand → RejectSupplierCommandHandler

**Service Commands**
- CreateSupplierServiceCommand → CreateSupplierServiceCommandHandler
- UpdateSupplierServiceCommand → UpdateSupplierServiceCommandHandler
- PublishSupplierServiceCommand → PublishSupplierServiceCommandHandler
- CreateSeasonalPriceCommand → CreateSeasonalPriceCommandHandler

**Purchase Order Commands**
- CreatePurchaseOrderCommand → CreatePurchaseOrderCommandHandler
- ApprovePurchaseOrderCommand → ApprovePurchaseOrderCommandHandler
- RejectPurchaseOrderCommand → RejectPurchaseOrderCommandHandler

**Package Commands**
- CreatePackageCommand → CreatePackageCommandHandler
- UpdatePackageCommand → UpdatePackageCommandHandler
- PublishPackageCommand → PublishPackageCommandHandler

**Journey Commands**
- CreateJourneyCommand → CreateJourneyCommandHandler
- UpdateJourneyCommand → UpdateJourneyCommandHandler

**Customer Commands**
- CreateCustomerCommand → CreateCustomerCommandHandler
- UpdateCustomerCommand → UpdateCustomerCommandHandler

**Booking Commands**
- CreateBookingCommand → CreateBookingCommandHandler
- ApproveBookingCommand → ApproveBookingCommandHandler
- CancelBookingCommand → CancelBookingCommandHandler
- AddTravelerCommand → AddTravelerCommandHandler

**Document Commands**
- UpdateDocumentStatusCommand → UpdateDocumentStatusCommandHandler
- VerifyDocumentCommand → VerifyDocumentCommandHandler

**Task Commands**
- CreateTaskCommand → CreateTaskCommandHandler
- UpdateTaskStatusCommand → UpdateTaskStatusCommandHandler
- AssignTaskCommand → AssignTaskCommandHandler

**Notification Commands**
- CreateNotificationScheduleCommand → CreateNotificationScheduleCommandHandler
- SendNotificationCommand → SendNotificationCommandHandler

**Payment Commands**
- RecordPaymentCommand → RecordPaymentCommandHandler

**Itinerary Commands**
- CreateItineraryCommand → CreateItineraryCommandHandler
- AddItineraryDayCommand → AddItineraryDayCommandHandler
- AddItineraryActivityCommand → AddItineraryActivityCommandHandler

**Supplier Bill Commands**
- CreateSupplierBillCommand → CreateSupplierBillCommandHandler
- RecordSupplierPaymentCommand → RecordSupplierPaymentCommandHandler

**Communication Commands**
- CreateCommunicationLogCommand → CreateCommunicationLogCommandHandler

**Marketplace Commands**
- PublishAgencyServiceCommand → PublishAgencyServiceCommandHandler
- CreateAgencyOrderCommand → CreateAgencyOrderCommandHandler
- ApproveAgencyOrderCommand → ApproveAgencyOrderCommandHandler
- RejectAgencyOrderCommand → RejectAgencyOrderCommandHandler

#### Query Handlers

**Agency Queries**
- GetAgenciesQuery → GetAgenciesQueryHandler
- GetAgencyByIdQuery → GetAgencyByIdQueryHandler

**Supplier Queries**
- GetSuppliersQuery → GetSuppliersQueryHandler
- GetSupplierByIdQuery → GetSupplierByIdQueryHandler

**Service Queries**
- GetSupplierServicesQuery → GetSupplierServicesQueryHandler
- GetSupplierServiceByIdQuery → GetSupplierServiceByIdQueryHandler
- GetServicePriceForDateQuery → GetServicePriceForDateQueryHandler

**Purchase Order Queries**
- GetPurchaseOrdersQuery → GetPurchaseOrdersQueryHandler
- GetPurchaseOrderByIdQuery → GetPurchaseOrderByIdQueryHandler

**Package Queries**
- GetPackagesQuery → GetPackagesQueryHandler
- GetPackageByIdQuery → GetPackageByIdQueryHandler

**Journey Queries**
- GetJourneysQuery → GetJourneysQueryHandler
- GetJourneyByIdQuery → GetJourneyByIdQueryHandler

**Customer Queries**
- GetCustomersQuery → GetCustomersQueryHandler
- GetCustomerByIdQuery → GetCustomerByIdQueryHandler

**Booking Queries**
- GetBookingsQuery → GetBookingsQueryHandler
- GetBookingByIdQuery → GetBookingByIdQueryHandler

**Document Queries**
- GetBookingDocumentsQuery → GetBookingDocumentsQueryHandler
- GetIncompleteDocumentsQuery → GetIncompleteDocumentsQueryHandler
- GetExpiringDocumentsQuery → GetExpiringDocumentsQueryHandler

**Task Queries**
- GetTasksQuery → GetTasksQueryHandler
- GetMyTasksQuery → GetMyTasksQueryHandler
- GetOverdueTasksQuery → GetOverdueTasksQueryHandler

**Notification Queries**
- GetNotificationSchedulesQuery → GetNotificationSchedulesQueryHandler
- GetNotificationLogsQuery → GetNotificationLogsQueryHandler

**Payment Queries**
- GetPaymentSchedulesQuery → GetPaymentSchedulesQueryHandler
- GetOutstandingPaymentsQuery → GetOutstandingPaymentsQueryHandler
- GetOverduePaymentsQuery → GetOverduePaymentsQueryHandler

**Itinerary Queries**
- GetItineraryByPackageIdQuery → GetItineraryByPackageIdQueryHandler

**Supplier Bill Queries**
- GetSupplierBillsQuery → GetSupplierBillsQueryHandler
- GetOutstandingPayablesQuery → GetOutstandingPayablesQueryHandler

**Communication Queries**
- GetCommunicationLogsQuery → GetCommunicationLogsQueryHandler
- GetFollowUpsQuery → GetFollowUpsQueryHandler

**Marketplace Queries**
- GetMarketplaceServicesQuery → GetMarketplaceServicesQueryHandler
- GetAgencyServicesQuery → GetAgencyServicesQueryHandler
- GetAgencyOrdersQuery → GetAgencyOrdersQueryHandler

**Profitability Queries**
- GetBookingProfitabilityQuery → GetBookingProfitabilityQueryHandler
- GetProfitabilityDashboardQuery → GetProfitabilityDashboardQueryHandler

### Infrastructure Services

**IAuthenticationService**
- Methods: GenerateJwtToken(), ValidateToken(), HashPassword(), VerifyPassword()

**INotificationService**
- Methods: SendEmail(), SendInAppNotification(), RenderTemplate()

**IBackgroundJobService**
- Methods: ScheduleJob(), EnqueueJob(), RecurringJob()

**IDateTimeProvider**
- Methods: Now(), Today(), UtcNow()

**ICurrentUserService**
- Methods: GetUserId(), GetAgencyId(), GetSupplierId(), GetUserType()


## Data Models

### Database Schema Overview

The system uses PostgreSQL 16 with 24+ tables organized into logical groups:

1. Core Tables (3): users, agencies, suppliers
2. Service Tables (2): supplier_services, supplier_service_seasonal_prices
3. Purchase Order Tables (2): purchase_orders, po_items
4. Package Tables (4): packages, package_services, journeys, journey_services
5. Customer & Booking Tables (3): customers, bookings, travelers
6. Document Tables (2): document_types, booking_documents
7. Task Tables (2): task_templates, booking_tasks
8. Notification Tables (3): notification_schedules, notification_templates, notification_logs
9. Payment Tables (2): payment_schedules, payment_transactions
10. Itinerary Tables (3): itineraries, itinerary_days, itinerary_activities
11. Supplier Bills Tables (2): supplier_bills, supplier_payments
12. Communication Tables (1): communication_logs
13. B2B Marketplace Tables (2): agency_services, agency_orders

### Core Tables

**users**
- id: UUID (PK)
- email: VARCHAR(255) UNIQUE NOT NULL
- password_hash: VARCHAR(255) NOT NULL
- user_type: VARCHAR(50) NOT NULL (platform_admin, agency_staff, supplier_staff)
- full_name: VARCHAR(255) NOT NULL
- phone: VARCHAR(50)
- agency_id: UUID (FK → agencies)
- supplier_id: UUID (FK → suppliers)
- is_active: BOOLEAN DEFAULT true
- created_at, updated_at: TIMESTAMP

**agencies**
- id: UUID (PK)
- agency_code: VARCHAR(50) UNIQUE NOT NULL
- company_name: VARCHAR(255) NOT NULL
- email: VARCHAR(255) NOT NULL
- phone: VARCHAR(50)
- address, city, province, postal_code: TEXT/VARCHAR
- subscription_plan: VARCHAR(50) DEFAULT 'basic'
- is_active: BOOLEAN DEFAULT true
- created_at, updated_at: TIMESTAMP

**suppliers**
- id: UUID (PK)
- supplier_code: VARCHAR(50) UNIQUE NOT NULL
- company_name: VARCHAR(255) NOT NULL
- email: VARCHAR(255) NOT NULL
- phone: VARCHAR(50)
- address: TEXT
- business_type: VARCHAR(100)
- status: VARCHAR(50) DEFAULT 'pending' (pending, active, rejected, suspended)
- approved_at: TIMESTAMP
- approved_by: UUID (FK → users)
- created_at, updated_at: TIMESTAMP


### Service Tables

**supplier_services**
- id: UUID (PK)
- supplier_id: UUID (FK → suppliers) NOT NULL
- service_code: VARCHAR(50) UNIQUE NOT NULL
- service_type: VARCHAR(50) NOT NULL (hotel, flight, visa, transport, guide, insurance, catering, handling)
- name: VARCHAR(255) NOT NULL
- description: TEXT
- base_price: DECIMAL(15,2) NOT NULL
- currency: VARCHAR(3) DEFAULT 'IDR'
- location_city, location_country: VARCHAR(100)
- Type-specific fields (airline, hotel_name, visa_type, vehicle_type, etc.)
- service_details: JSONB (for non-critical additional info)
- visibility: VARCHAR(50) DEFAULT 'marketplace'
- status: VARCHAR(50) DEFAULT 'draft'
- published_at: TIMESTAMP
- created_at, updated_at: TIMESTAMP

**supplier_service_seasonal_prices**
- id: UUID (PK)
- supplier_service_id: UUID (FK → supplier_services) NOT NULL
- season_name: VARCHAR(100)
- start_date: DATE NOT NULL
- end_date: DATE NOT NULL
- seasonal_price: DECIMAL(15,2) NOT NULL
- is_active: BOOLEAN DEFAULT true
- notes: TEXT
- created_at, updated_at: TIMESTAMP
- created_by: UUID (FK → users)
- CONSTRAINT: end_date >= start_date
- CONSTRAINT: seasonal_price > 0

### Purchase Order Tables

**purchase_orders**
- id: UUID (PK)
- po_number: VARCHAR(50) UNIQUE NOT NULL
- agency_id: UUID (FK → agencies) NOT NULL
- supplier_id: UUID (FK → suppliers) NOT NULL
- status: VARCHAR(50) DEFAULT 'pending' (pending, approved, rejected)
- total_amount: DECIMAL(15,2)
- notes: TEXT
- rejection_reason: TEXT
- approved_at, approved_by, rejected_at, rejected_by: TIMESTAMP/UUID
- created_by: UUID (FK → users) NOT NULL
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**po_items**
- id: UUID (PK)
- po_id: UUID (FK → purchase_orders) NOT NULL
- service_id: UUID (FK → supplier_services) NOT NULL
- service_type: VARCHAR(50) NOT NULL
- quantity: INTEGER NOT NULL
- unit_price: DECIMAL(15,2) NOT NULL
- total_price: DECIMAL(15,2) NOT NULL
- start_date, end_date: DATE
- notes: TEXT
- created_at: TIMESTAMP


### Package and Journey Tables

**packages** (Templates - NO dates)
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- package_code: VARCHAR(50) UNIQUE NOT NULL
- package_type: VARCHAR(50) NOT NULL (umrah, hajj, halal_tour, general_tour, custom)
- name: VARCHAR(255) NOT NULL
- description: TEXT
- duration_days: INTEGER NOT NULL
- base_cost: DECIMAL(15,2) NOT NULL
- markup_type: VARCHAR(50)
- markup_value: DECIMAL(15,2)
- selling_price: DECIMAL(15,2) NOT NULL
- visibility: VARCHAR(50) DEFAULT 'public'
- status: VARCHAR(50) DEFAULT 'draft'
- published_at: TIMESTAMP
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**package_services**
- id: UUID (PK)
- package_id: UUID (FK → packages) NOT NULL
- supplier_service_id: UUID (FK → supplier_services)
- agency_service_id: UUID (FK → agency_services)
- source_type: VARCHAR(50) NOT NULL (supplier, agency)
- quantity: INTEGER NOT NULL
- unit_cost: DECIMAL(15,2) NOT NULL
- total_cost: DECIMAL(15,2) NOT NULL
- created_at: TIMESTAMP

**journeys** (Actual trips WITH dates)
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- package_id: UUID (FK → packages) NOT NULL
- journey_code: VARCHAR(50) UNIQUE NOT NULL
- departure_date: DATE NOT NULL
- return_date: DATE NOT NULL
- total_quota: INTEGER NOT NULL
- confirmed_pax: INTEGER DEFAULT 0
- available_quota: INTEGER NOT NULL
- status: VARCHAR(50) DEFAULT 'planning' (planning, confirmed, in_progress, completed, cancelled)
- notes: TEXT
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID
- INVARIANT: total_quota = confirmed_pax + available_quota

**journey_services**
- id: UUID (PK)
- journey_id: UUID (FK → journeys) NOT NULL
- service_type: VARCHAR(50) NOT NULL
- supplier_service_id: UUID (FK → supplier_services)
- agency_service_id: UUID (FK → agency_services)
- source_type: VARCHAR(50) NOT NULL (supplier, agency)
- booking_status: VARCHAR(50) DEFAULT 'not_booked'
- execution_status: VARCHAR(50) DEFAULT 'pending'
- payment_status: VARCHAR(50) DEFAULT 'unpaid'
- booked_at, confirmed_at, executed_at: TIMESTAMP
- issue_notes: TEXT
- created_at, updated_at: TIMESTAMP


### Customer and Booking Tables

**customers**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- customer_code: VARCHAR(50) UNIQUE NOT NULL
- name: VARCHAR(255) NOT NULL
- email: VARCHAR(255)
- phone: VARCHAR(50) NOT NULL
- address, city, province, postal_code: TEXT/VARCHAR
- country: VARCHAR(100) DEFAULT 'Indonesia'
- notes: TEXT
- tags: JSONB
- total_bookings: INTEGER DEFAULT 0
- total_spent: DECIMAL(15,2) DEFAULT 0
- last_booking_date: DATE
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**bookings**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- package_id: UUID (FK → packages) NOT NULL
- journey_id: UUID (FK → journeys) NOT NULL
- customer_id: UUID (FK → customers) NOT NULL
- booking_reference: VARCHAR(50) UNIQUE NOT NULL
- booking_status: VARCHAR(50) DEFAULT 'pending' (pending, confirmed, departed, completed, cancelled)
- total_pax: INTEGER NOT NULL
- total_amount: DECIMAL(15,2) NOT NULL
- booking_source: VARCHAR(50) DEFAULT 'staff' (staff, phone, walk_in, whatsapp)
- notes: TEXT
- approved_at, approved_by: TIMESTAMP/UUID
- cancelled_at, cancelled_by: TIMESTAMP/UUID
- cancellation_reason: TEXT
- created_by: UUID (FK → users) NOT NULL
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**travelers**
- id: UUID (PK)
- booking_id: UUID (FK → bookings) NOT NULL
- traveler_number: INTEGER NOT NULL
- full_name: VARCHAR(255) NOT NULL
- gender: VARCHAR(10) NOT NULL
- date_of_birth: DATE NOT NULL
- nationality: VARCHAR(100) DEFAULT 'Indonesia'
- passport_number: VARCHAR(50)
- passport_expiry: DATE
- mahram_traveler_number: INTEGER
- created_at: TIMESTAMP
- UNIQUE: (booking_id, traveler_number)

### Document Management Tables

**document_types**
- id: UUID (PK)
- name: VARCHAR(100) UNIQUE NOT NULL
- required_for_package_types: JSONB
- description: TEXT
- expiry_tracking_enabled: BOOLEAN DEFAULT false
- created_at: TIMESTAMP

**booking_documents**
- id: UUID (PK)
- booking_id: UUID (FK → bookings) NOT NULL
- traveler_id: UUID (FK → travelers)
- document_type_id: UUID (FK → document_types) NOT NULL
- status: VARCHAR(50) DEFAULT 'not_submitted' (not_submitted, submitted, verified, rejected, expired)
- document_number: VARCHAR(100)
- issue_date, expiry_date: DATE
- notes: TEXT
- rejection_reason: TEXT
- verified_by: UUID (FK → users)
- verified_at: TIMESTAMP
- created_at, updated_at: TIMESTAMP


### Task Management Tables

**task_templates**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) (NULL for system templates)
- name: VARCHAR(255) NOT NULL
- description: TEXT
- trigger_stage: VARCHAR(50) NOT NULL (after_booking, h_30, h_7)
- due_days_offset: INTEGER
- assignee_role: VARCHAR(50)
- is_active: BOOLEAN DEFAULT true
- created_at: TIMESTAMP

**booking_tasks**
- id: UUID (PK)
- booking_id: UUID (FK → bookings) NOT NULL
- task_template_id: UUID (FK → task_templates)
- title: VARCHAR(255) NOT NULL
- description: TEXT
- status: VARCHAR(50) DEFAULT 'to_do' (to_do, in_progress, done)
- priority: VARCHAR(50) DEFAULT 'normal' (low, normal, high, urgent)
- assigned_to: UUID (FK → users)
- due_date: DATE
- completed_at: TIMESTAMP
- completed_by: UUID (FK → users)
- notes: TEXT
- is_custom: BOOLEAN DEFAULT false
- created_at, updated_at: TIMESTAMP

### Notification Tables

**notification_schedules**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- name: VARCHAR(255) NOT NULL
- trigger_days_before: INTEGER NOT NULL (30, 14, 7, 3, 1)
- notification_type: VARCHAR(50) DEFAULT 'email'
- template_id: UUID (FK → notification_templates)
- is_enabled: BOOLEAN DEFAULT true
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**notification_templates**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) (NULL for system templates)
- name: VARCHAR(255) NOT NULL
- subject: VARCHAR(255)
- body: TEXT NOT NULL
- variables: JSONB
- created_at, updated_at: TIMESTAMP

**notification_logs**
- id: UUID (PK)
- booking_id: UUID (FK → bookings) NOT NULL
- schedule_id: UUID (FK → notification_schedules)
- recipient_email: VARCHAR(255)
- recipient_phone: VARCHAR(50)
- notification_type: VARCHAR(50) NOT NULL
- subject: VARCHAR(255)
- body: TEXT
- status: VARCHAR(50) DEFAULT 'pending' (pending, sent, failed, failed_permanently)
- sent_at, opened_at: TIMESTAMP
- error_message: TEXT
- retry_count: INTEGER DEFAULT 0
- created_at: TIMESTAMP


### Payment Tables

**payment_schedules**
- id: UUID (PK)
- booking_id: UUID (FK → bookings) NOT NULL
- installment_number: INTEGER NOT NULL
- installment_name: VARCHAR(100) (DP, Installment 1, Final Payment)
- due_date: DATE NOT NULL
- amount: DECIMAL(15,2) NOT NULL
- status: VARCHAR(50) DEFAULT 'pending' (pending, paid, overdue, partially_paid)
- paid_amount: DECIMAL(15,2) DEFAULT 0
- paid_date: DATE
- payment_method: VARCHAR(50)
- notes: TEXT
- created_at, updated_at: TIMESTAMP
- UNIQUE: (booking_id, installment_number)

**payment_transactions**
- id: UUID (PK)
- booking_id: UUID (FK → bookings) NOT NULL
- schedule_id: UUID (FK → payment_schedules)
- amount: DECIMAL(15,2) NOT NULL
- payment_method: VARCHAR(50) NOT NULL (bank_transfer, cash, credit_card, e_wallet)
- payment_date: DATE NOT NULL
- reference_number: VARCHAR(100)
- notes: TEXT
- recorded_by: UUID (FK → users) NOT NULL
- created_at: TIMESTAMP

### Itinerary Tables

**itineraries**
- id: UUID (PK)
- package_id: UUID (FK → packages) NOT NULL
- created_at, updated_at: TIMESTAMP
- UNIQUE: package_id (one itinerary per package)

**itinerary_days**
- id: UUID (PK)
- itinerary_id: UUID (FK → itineraries) NOT NULL
- day_number: INTEGER NOT NULL
- title: VARCHAR(255) NOT NULL
- description: TEXT
- created_at, updated_at: TIMESTAMP
- UNIQUE: (itinerary_id, day_number)

**itinerary_activities**
- id: UUID (PK)
- day_id: UUID (FK → itinerary_days) NOT NULL
- time: TIME
- location: VARCHAR(255)
- activity: VARCHAR(255) NOT NULL
- description: TEXT
- meal_type: VARCHAR(50) (breakfast, lunch, dinner, snack, none)
- created_at: TIMESTAMP

### Supplier Bills Tables

**supplier_bills**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- supplier_id: UUID (FK → suppliers) NOT NULL
- po_id: UUID (FK → purchase_orders) NOT NULL
- bill_number: VARCHAR(50) UNIQUE NOT NULL
- bill_date: DATE NOT NULL
- due_date: DATE NOT NULL
- total_amount: DECIMAL(15,2) NOT NULL
- paid_amount: DECIMAL(15,2) DEFAULT 0
- status: VARCHAR(50) DEFAULT 'unpaid' (unpaid, partially_paid, paid, overdue)
- notes: TEXT
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**supplier_payments**
- id: UUID (PK)
- bill_id: UUID (FK → supplier_bills) NOT NULL
- payment_date: DATE NOT NULL
- amount: DECIMAL(15,2) NOT NULL
- payment_method: VARCHAR(50) NOT NULL
- reference_number: VARCHAR(100)
- notes: TEXT
- recorded_by: UUID (FK → users) NOT NULL
- created_at: TIMESTAMP


### Communication and Marketplace Tables

**communication_logs**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- customer_id: UUID (FK → customers) NOT NULL
- booking_id: UUID (FK → bookings)
- communication_type: VARCHAR(50) NOT NULL (call, email, whatsapp, meeting, other)
- subject: VARCHAR(255)
- notes: TEXT NOT NULL
- follow_up_required: BOOLEAN DEFAULT false
- follow_up_date: DATE
- follow_up_done: BOOLEAN DEFAULT false
- created_by: UUID (FK → users) NOT NULL
- created_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**agency_services** (B2B Marketplace)
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL (Seller - Agency A)
- po_id: UUID (FK → purchase_orders) NOT NULL
- service_type: VARCHAR(50) NOT NULL
- name: VARCHAR(255) NOT NULL
- description: TEXT
- specifications: JSONB
- cost_price: DECIMAL(15,2) NOT NULL (HIDDEN from buyers)
- reseller_price: DECIMAL(15,2) NOT NULL
- markup_percentage: DECIMAL(5,2)
- total_quota: INTEGER NOT NULL
- used_quota: INTEGER DEFAULT 0
- available_quota: INTEGER NOT NULL
- reserved_quota: INTEGER DEFAULT 0
- sold_quota: INTEGER DEFAULT 0
- is_published: BOOLEAN DEFAULT false
- published_at: TIMESTAMP
- created_at, updated_at: TIMESTAMP
- RLS Policies:
  - Owner: agency_id = current_setting('app.current_agency_id')::UUID
  - Marketplace: is_published = true AND agency_id != current_setting('app.current_agency_id')::UUID
- INVARIANT: total_quota = used_quota + available_quota + reserved_quota + sold_quota

**agency_orders** (B2B Marketplace)
- id: UUID (PK)
- order_number: VARCHAR(50) UNIQUE NOT NULL
- buyer_agency_id: UUID (FK → agencies) NOT NULL (Agency B)
- seller_agency_id: UUID (FK → agencies) NOT NULL (Agency A)
- agency_service_id: UUID (FK → agency_services) NOT NULL
- quantity: INTEGER NOT NULL
- unit_price: DECIMAL(15,2) NOT NULL
- total_price: DECIMAL(15,2) NOT NULL
- status: VARCHAR(50) DEFAULT 'pending' (pending, approved, rejected, cancelled)
- notes: TEXT
- approved_by, approved_at: UUID/TIMESTAMP
- rejection_reason: TEXT
- rejected_by, rejected_at: UUID/TIMESTAMP
- created_by: UUID (FK → users) NOT NULL
- created_at, updated_at: TIMESTAMP
- RLS Policies:
  - Buyer: buyer_agency_id = current_setting('app.current_agency_id')::UUID
  - Seller: seller_agency_id = current_setting('app.current_agency_id')::UUID

### Database Functions

**get_service_price_for_date(service_id UUID, date DATE) RETURNS DECIMAL(15,2)**
- Check for active seasonal price for the given date
- If found, return seasonal_price
- Otherwise, return base_price from supplier_services

### Database Indexes

All foreign keys are indexed. Additional indexes:
- users: email, agency_id, supplier_id
- agencies: agency_code, is_active
- suppliers: supplier_code, status
- supplier_services: supplier_id, service_type, status, airline, hotel_name, visa_type
- purchase_orders: agency_id, supplier_id, status
- packages: agency_id, package_type
- journeys: agency_id, package_id, departure_date
- customers: agency_id, email, phone
- bookings: agency_id, journey_id, customer_id, booking_status
- booking_documents: booking_id, traveler_id, status
- booking_tasks: booking_id, status, assigned_to, due_date
- notification_logs: booking_id, status, sent_at
- payment_schedules: booking_id, status, due_date
- supplier_bills: agency_id, supplier_id, po_id, status
- agency_services: agency_id, po_id, service_type, is_published
- agency_orders: buyer_agency_id, seller_agency_id, agency_service_id, status, order_number


---

## Correctness Properties

This section defines the formal correctness properties that the system must satisfy. These properties will be validated using Property-Based Testing (PBT) to ensure system correctness across all possible inputs.

### 1. Multi-Tenancy Isolation Properties

**Property 1.1: Tenant Data Isolation**
- **Validates: Requirement 1**
- **Property:** For any two different agencies A and B, when agency A queries data, the result set MUST NOT contain any records belonging to agency B
- **Invariant:** ∀ query Q, ∀ agencies A ≠ B: Q(tenant=A) ∩ Q(tenant=B) = ∅
- **Test Strategy:** Generate random agencies and data, verify no cross-tenant leakage

**Property 1.2: Session Variable Consistency**
- **Validates: Requirement 1**
- **Property:** When a request is made with agency_id in JWT token, the database session variable MUST be set to the same agency_id before any query execution
- **Invariant:** JWT.agency_id = session.app.current_agency_id
- **Test Strategy:** Generate random JWT tokens, verify session variable matches

### 2. Authentication Properties

**Property 2.1: Password Hash Irreversibility**
- **Validates: Requirement 2**
- **Property:** Given a password P and its hash H, it MUST be computationally infeasible to derive P from H
- **Invariant:** ∀ password P: Hash(P) ≠ P AND Hash(P) is one-way
- **Test Strategy:** Generate random passwords, verify hashes are different and cannot be reversed

**Property 2.2: JWT Token Expiration**
- **Validates: Requirement 2**
- **Property:** A JWT token MUST be rejected if current time > token.expiry_time
- **Invariant:** ∀ token T: IsValid(T) ⟺ Now() ≤ T.expiry_time
- **Test Strategy:** Generate tokens with various expiry times, verify rejection after expiry

### 3. Quota Management Properties

**Property 3.1: Journey Quota Invariant**
- **Validates: Requirement 10, 13**
- **Property:** For any journey, the total quota MUST always equal the sum of confirmed passengers and available quota
- **Invariant:** ∀ journey J: J.total_quota = J.confirmed_pax + J.available_quota
- **Test Strategy:** Generate random booking operations, verify invariant holds after each operation

**Property 3.2: Quota Non-Negativity**
- **Validates: Requirement 10, 13**
- **Property:** Available quota MUST never be negative
- **Invariant:** ∀ journey J: J.available_quota ≥ 0
- **Test Strategy:** Generate random booking/cancellation sequences, verify quota never goes negative

**Property 3.3: Booking Approval Quota Check**
- **Validates: Requirement 13**
- **Property:** A booking MUST NOT be approved if available quota < booking total_pax
- **Invariant:** ∀ booking B: CanApprove(B) ⟺ B.journey.available_quota ≥ B.total_pax
- **Test Strategy:** Generate bookings with various pax counts, verify approval only when quota sufficient

### 4. Agency Service Quota Properties (B2B Marketplace)

**Property 4.1: Agency Service Quota Invariant**
- **Validates: Requirement 34**
- **Property:** For any agency service, total quota MUST equal the sum of used, available, reserved, and sold quota
- **Invariant:** ∀ service S: S.total_quota = S.used_quota + S.available_quota + S.reserved_quota + S.sold_quota
- **Test Strategy:** Generate random marketplace operations, verify invariant holds

**Property 4.2: Quota Reservation Atomicity**
- **Validates: Requirement 31**
- **Property:** When an order is created, quota reservation MUST be atomic (decrement available, increment reserved)
- **Invariant:** ∀ order O: CreateOrder(O) ⟹ (available_quota' = available_quota - O.quantity) ∧ (reserved_quota' = reserved_quota + O.quantity)
- **Test Strategy:** Generate concurrent order creation, verify no quota inconsistency

**Property 4.3: Quota Transfer on Approval**
- **Validates: Requirement 32**
- **Property:** When an order is approved, quota MUST transfer from reserved to sold atomically
- **Invariant:** ∀ order O: ApproveOrder(O) ⟹ (reserved_quota' = reserved_quota - O.quantity) ∧ (sold_quota' = sold_quota + O.quantity)
- **Test Strategy:** Generate order approval sequences, verify quota transfer correctness

### 5. Pricing Properties

**Property 5.1: Package Pricing Consistency**
- **Validates: Requirement 9**
- **Property:** Package selling price MUST be greater than or equal to base cost
- **Invariant:** ∀ package P: P.selling_price ≥ P.base_cost
- **Test Strategy:** Generate random packages with various markups, verify pricing constraint

**Property 5.2: Seasonal Price Priority**
- **Validates: Requirement 6**
- **Property:** When querying price for a date, if a seasonal price exists for that date, it MUST be returned; otherwise base price MUST be returned
- **Invariant:** ∀ service S, date D: GetPrice(S, D) = SeasonalPrice(S, D) if exists, else S.base_price
- **Test Strategy:** Generate services with overlapping seasonal prices, verify correct price returned

**Property 5.3: Marketplace Markup Minimum**
- **Validates: Requirement 29**
- **Property:** Agency service reseller price MUST be at least 5% higher than cost price
- **Invariant:** ∀ agency_service AS: AS.reseller_price ≥ AS.cost_price × 1.05
- **Test Strategy:** Generate agency services with various prices, verify minimum markup enforced

### 6. Payment Properties

**Property 6.1: Payment Schedule Sum Equals Total**
- **Validates: Requirement 23**
- **Property:** The sum of all payment schedule amounts MUST equal the booking total amount
- **Invariant:** ∀ booking B: Σ(B.payment_schedules.amount) = B.total_amount
- **Test Strategy:** Generate bookings with various amounts, verify payment schedule sum

**Property 6.2: Payment Status Consistency**
- **Validates: Requirement 24**
- **Property:** Payment schedule status MUST be 'paid' if and only if paid_amount equals amount
- **Invariant:** ∀ schedule S: S.status = 'paid' ⟺ S.paid_amount = S.amount
- **Test Strategy:** Generate payment recordings, verify status transitions correctly

**Property 6.3: Payment Transaction Sum**
- **Validates: Requirement 24**
- **Property:** The sum of all payment transactions for a schedule MUST equal the schedule's paid_amount
- **Invariant:** ∀ schedule S: Σ(S.transactions.amount) = S.paid_amount
- **Test Strategy:** Generate multiple payment transactions, verify sum consistency

### 7. Document Management Properties

**Property 7.1: Document Completion Percentage**
- **Validates: Requirement 15**
- **Property:** Document completion percentage MUST equal (verified documents / total required documents) × 100
- **Invariant:** ∀ booking B: B.doc_completion = (Count(B.documents WHERE status='verified') / Count(B.documents)) × 100
- **Test Strategy:** Generate bookings with various document statuses, verify percentage calculation

**Property 7.2: Passport Expiry Validation**
- **Validates: Requirement 16**
- **Property:** Passport expiry date MUST be more than 6 months after journey departure date
- **Invariant:** ∀ passport P, journey J: P.expiry_date > J.departure_date + 180 days
- **Test Strategy:** Generate passports with various expiry dates, verify validation

### 8. Task Management Properties

**Property 8.1: Task Completion Percentage**
- **Validates: Requirement 17**
- **Property:** Task completion percentage MUST equal (completed tasks / total tasks) × 100
- **Invariant:** ∀ booking B: B.task_completion = (Count(B.tasks WHERE status='done') / Count(B.tasks)) × 100
- **Test Strategy:** Generate bookings with various task statuses, verify percentage calculation

**Property 8.2: Task Due Date Calculation**
- **Validates: Requirement 17**
- **Property:** Auto-generated task due date MUST equal booking creation date plus template due_days_offset
- **Invariant:** ∀ task T from template TT: T.due_date = T.booking.created_at + TT.due_days_offset days
- **Test Strategy:** Generate bookings with various creation dates, verify task due dates

### 9. Notification Properties

**Property 9.1: Notification Trigger Matching**
- **Validates: Requirement 21**
- **Property:** A notification MUST be triggered if and only if (departure_date - today) equals schedule trigger_days_before
- **Invariant:** ∀ booking B, schedule S: TriggerNotification(B, S) ⟺ (B.journey.departure_date - Today()) = S.trigger_days_before
- **Test Strategy:** Generate bookings with various departure dates, verify notification triggering

**Property 9.2: Notification Retry Limit**
- **Validates: Requirement 22**
- **Property:** A failed notification MUST be retried at most 3 times
- **Invariant:** ∀ notification N: N.retry_count ≤ 3
- **Test Strategy:** Generate failing notifications, verify retry count never exceeds 3

### 10. Mahram Validation Properties

**Property 10.1: Female Traveler Mahram Requirement**
- **Validates: Requirement 14**
- **Property:** For Umrah/Hajj packages, a female traveler older than 12 MUST have a mahram_traveler_number referencing a male traveler
- **Invariant:** ∀ traveler T in Umrah/Hajj booking: (T.gender = 'female' ∧ T.age > 12) ⟹ ∃ mahram M: M.traveler_number = T.mahram_traveler_number ∧ M.gender = 'male'
- **Test Strategy:** Generate travelers with various ages and genders, verify mahram validation

### 11. Profitability Properties

**Property 11.1: Gross Profit Calculation**
- **Validates: Requirement 35**
- **Property:** Gross profit MUST equal revenue minus cost
- **Invariant:** ∀ booking B: B.gross_profit = B.revenue - B.cost
- **Test Strategy:** Generate bookings with various revenues and costs, verify profit calculation

**Property 11.2: Gross Margin Percentage**
- **Validates: Requirement 35**
- **Property:** Gross margin percentage MUST equal (gross_profit / revenue) × 100
- **Invariant:** ∀ booking B: B.gross_margin_pct = (B.gross_profit / B.revenue) × 100
- **Test Strategy:** Generate bookings with various profit margins, verify percentage calculation

### 12. Order Auto-Rejection Properties

**Property 12.1: Auto-Reject Timeout**
- **Validates: Requirement 33**
- **Property:** A pending order MUST be auto-rejected if created_at is more than 24 hours ago
- **Invariant:** ∀ order O: (O.status = 'pending' ∧ Now() - O.created_at > 24 hours) ⟹ AutoReject(O)
- **Test Strategy:** Generate orders with various creation times, verify auto-rejection after 24 hours

**Property 12.2: Quota Release on Auto-Rejection**
- **Validates: Requirement 33**
- **Property:** When an order is auto-rejected, reserved quota MUST be released back to available quota
- **Invariant:** ∀ order O: AutoReject(O) ⟹ (available_quota' = available_quota + O.quantity) ∧ (reserved_quota' = reserved_quota - O.quantity)
- **Test Strategy:** Generate auto-rejected orders, verify quota release

### 13. Marketplace Visibility Properties

**Property 13.1: Supplier Name Hiding**
- **Validates: Requirement 30**
- **Property:** When browsing marketplace, supplier name MUST NOT be visible to buyers
- **Invariant:** ∀ agency_service AS in marketplace: AS.supplier_id NOT IN Response
- **Test Strategy:** Query marketplace as buyer, verify supplier information not exposed

**Property 13.2: Own Agency Exclusion**
- **Validates: Requirement 30**
- **Property:** An agency MUST NOT see their own published services in marketplace browse results
- **Invariant:** ∀ agency A browsing marketplace: ∀ service S in results: S.agency_id ≠ A.id
- **Test Strategy:** Browse marketplace as various agencies, verify own services excluded

### 14. Date Validation Properties

**Property 14.1: Date Range Validity**
- **Validates: Multiple requirements**
- **Property:** For any date range, end date MUST be greater than or equal to start date
- **Invariant:** ∀ entity E with date range: E.end_date ≥ E.start_date
- **Test Strategy:** Generate entities with various date ranges, verify validation

**Property 14.2: Journey Date Consistency**
- **Validates: Requirement 10**
- **Property:** Journey return date MUST be after departure date
- **Invariant:** ∀ journey J: J.return_date > J.departure_date
- **Test Strategy:** Generate journeys with various dates, verify validation

### Testing Strategy

**Property-Based Testing Framework:** Use a PBT library (e.g., FsCheck for .NET, Hypothesis for Python) to:
1. Generate random valid inputs for each property
2. Execute the property test with generated inputs
3. Verify the property holds for all inputs
4. If property fails, shrink the failing input to minimal counterexample
5. Fix the bug and re-run tests

**Test Coverage Goals:**
- 100% of correctness properties tested
- Minimum 1000 test cases per property
- All edge cases covered (boundary values, empty sets, maximum values)
- Concurrent operations tested for race conditions

---

## Summary

This design document provides:
- Complete database schema with 24+ tables
- Clean Architecture with CQRS pattern
- Domain entities with business logic
- Application layer commands and queries
- Infrastructure services and interfaces
- **14 categories of correctness properties** for property-based testing
- Background jobs for automation
- Multi-tenancy with Row-Level Security

The system is designed to be:
- **Correct:** All operations satisfy formal correctness properties
- **Secure:** Multi-tenant isolation, authentication, authorization
- **Scalable:** Clean architecture, CQRS, proper indexing
- **Maintainable:** Clear separation of concerns, testable design
- **Reliable:** Property-based testing ensures correctness across all inputs


---

## Docker Configuration

This section provides Docker setup for local development, eliminating the need to install PostgreSQL, .NET SDK, or other dependencies locally.

### Docker Compose Setup

**docker-compose.yml**
```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    container_name: tour-travel-db
    environment:
      POSTGRES_DB: tour_travel_db
      POSTGRES_USER: tour_travel_user
      POSTGRES_PASSWORD: tour_travel_pass_dev
      POSTGRES_HOST_AUTH_METHOD: trust
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U tour_travel_user -d tour_travel_db"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - tour-travel-network

  # .NET 8 API
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: tour-travel-api
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - ASPNETCORE_URLS=http://+:5000
      - ConnectionStrings__DefaultConnection=Host=postgres;Port=5432;Database=tour_travel_db;Username=tour_travel_user;Password=tour_travel_pass_dev
      - JwtSettings__Secret=your-super-secret-jwt-key-min-32-chars-for-development
      - JwtSettings__Issuer=TourTravelAPI
      - JwtSettings__Audience=TourTravelClient
      - JwtSettings__ExpiryMinutes=1440
      - Logging__LogLevel__Default=Information
      - Logging__LogLevel__Microsoft.AspNetCore=Warning
    ports:
      - "5000:5000"
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - ./src:/app/src
      - ~/.nuget/packages:/root/.nuget/packages
    networks:
      - tour-travel-network
    restart: unless-stopped

  # Hangfire Dashboard (Optional - for monitoring background jobs)
  hangfire:
    image: postgres:16-alpine
    container_name: tour-travel-hangfire
    environment:
      POSTGRES_DB: tour_travel_hangfire
      POSTGRES_USER: hangfire_user
      POSTGRES_PASSWORD: hangfire_pass_dev
    ports:
      - "5433:5432"
    volumes:
      - hangfire_data:/var/lib/postgresql/data
    networks:
      - tour-travel-network

  # pgAdmin (Optional - for database management UI)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: tour-travel-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@tourtravel.com
      PGADMIN_DEFAULT_PASSWORD: admin
      PGADMIN_CONFIG_SERVER_MODE: 'False'
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    depends_on:
      - postgres
    networks:
      - tour-travel-network

volumes:
  postgres_data:
  hangfire_data:
  pgadmin_data:

networks:
  tour-travel-network:
    driver: bridge
```

### Dockerfile for .NET API

**Dockerfile**
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj files and restore dependencies
COPY ["src/TourTravel.API/TourTravel.API.csproj", "TourTravel.API/"]
COPY ["src/TourTravel.Application/TourTravel.Application.csproj", "TourTravel.Application/"]
COPY ["src/TourTravel.Domain/TourTravel.Domain.csproj", "TourTravel.Domain/"]
COPY ["src/TourTravel.Infrastructure/TourTravel.Infrastructure.csproj", "TourTravel.Infrastructure/"]

RUN dotnet restore "TourTravel.API/TourTravel.API.csproj"

# Copy all source files
COPY src/ .

# Build the application
WORKDIR "/src/TourTravel.API"
RUN dotnet build "TourTravel.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "TourTravel.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install curl for healthcheck
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=publish /app/publish .

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

ENTRYPOINT ["dotnet", "TourTravel.API.dll"]
```

### Development Dockerfile (with hot reload)

**Dockerfile.dev**
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0
WORKDIR /app

# Install dotnet tools
RUN dotnet tool install --global dotnet-ef
ENV PATH="${PATH}:/root/.dotnet/tools"

# Copy csproj files and restore
COPY ["src/TourTravel.API/TourTravel.API.csproj", "TourTravel.API/"]
COPY ["src/TourTravel.Application/TourTravel.Application.csproj", "TourTravel.Application/"]
COPY ["src/TourTravel.Domain/TourTravel.Domain.csproj", "TourTravel.Domain/"]
COPY ["src/TourTravel.Infrastructure/TourTravel.Infrastructure.csproj", "TourTravel.Infrastructure/"]

RUN dotnet restore "TourTravel.API/TourTravel.API.csproj"

# Copy source code
COPY src/ .

WORKDIR /app/TourTravel.API

# Run with hot reload
CMD ["dotnet", "watch", "run", "--urls", "http://0.0.0.0:5000"]
```

### Database Initialization Script

**scripts/init-db.sql**
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable Row-Level Security
ALTER DATABASE tour_travel_db SET row_security = on;

-- Create initial schema (migrations will handle the rest)
-- This is just for initial setup

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE tour_travel_db TO tour_travel_user;
```

### Environment Variables File

**.env.development**
```env
# Database
POSTGRES_DB=tour_travel_db
POSTGRES_USER=tour_travel_user
POSTGRES_PASSWORD=tour_travel_pass_dev
DATABASE_URL=Host=postgres;Port=5432;Database=tour_travel_db;Username=tour_travel_user;Password=tour_travel_pass_dev

# API
ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://+:5000
API_PORT=5000

# JWT
JWT_SECRET=your-super-secret-jwt-key-min-32-chars-for-development
JWT_ISSUER=TourTravelAPI
JWT_AUDIENCE=TourTravelClient
JWT_EXPIRY_MINUTES=1440

# Hangfire
HANGFIRE_DB=tour_travel_hangfire
HANGFIRE_USER=hangfire_user
HANGFIRE_PASSWORD=hangfire_pass_dev

# pgAdmin
PGADMIN_EMAIL=admin@tourtravel.com
PGADMIN_PASSWORD=admin
PGADMIN_PORT=5050

# Logging
LOG_LEVEL=Information
```

### Docker Commands

**Start all services:**
```bash
docker-compose up -d
```

**Start with build:**
```bash
docker-compose up -d --build
```

**View logs:**
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api
docker-compose logs -f postgres
```

**Stop all services:**
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
docker-compose exec postgres psql -U tour_travel_user -d tour_travel_db
```

**Access API container shell:**
```bash
docker-compose exec api bash
```

**Rebuild specific service:**
```bash
docker-compose up -d --build api
```

### Development Workflow

**1. Initial Setup:**
```bash
# Clone repository
git clone <repository-url>
cd tour-travel-backend

# Start services
docker-compose up -d

# Wait for services to be healthy
docker-compose ps

# Run migrations
docker-compose exec api dotnet ef database update

# Seed initial data
docker-compose exec api dotnet run --seed
```

**2. Daily Development:**
```bash
# Start services
docker-compose up -d

# View API logs
docker-compose logs -f api

# Make code changes (hot reload enabled in dev mode)

# Run tests
docker-compose exec api dotnet test

# Stop services when done
docker-compose down
```

**3. Database Management:**
```bash
# Access pgAdmin
# Open browser: http://localhost:5050
# Login: admin@tourtravel.com / admin
# Add server: postgres / tour_travel_user / tour_travel_pass_dev

# Or use CLI
docker-compose exec postgres psql -U tour_travel_user -d tour_travel_db

# Create new migration
docker-compose exec api dotnet ef migrations add MigrationName

# Apply migrations
docker-compose exec api dotnet ef database update

# Rollback migration
docker-compose exec api dotnet ef database update PreviousMigrationName
```

**4. Hangfire Dashboard:**
```bash
# Access Hangfire dashboard
# Open browser: http://localhost:5000/hangfire
# View background jobs, schedules, and execution history
```

### Docker Compose Profiles (Optional)

For different environments, you can use profiles:

**docker-compose.override.yml** (for development)
```yaml
version: '3.8'

services:
  api:
    build:
      dockerfile: Dockerfile.dev
    volumes:
      - ./src:/app/src:cached
      - ~/.nuget/packages:/root/.nuget/packages:cached
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
      - Logging__LogLevel__Default=Debug
```

**docker-compose.prod.yml** (for production)
```yaml
version: '3.8'

services:
  api:
    build:
      dockerfile: Dockerfile
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - Logging__LogLevel__Default=Warning
    restart: always

  postgres:
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}  # Use secrets in production
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: always
```

### Troubleshooting

**Port already in use:**
```bash
# Check what's using the port
lsof -i :5000
lsof -i :5432

# Kill the process or change port in docker-compose.yml
```

**Database connection issues:**
```bash
# Check if postgres is healthy
docker-compose ps

# Check postgres logs
docker-compose logs postgres

# Restart postgres
docker-compose restart postgres
```

**API not starting:**
```bash
# Check API logs
docker-compose logs api

# Rebuild API
docker-compose up -d --build api

# Check if migrations are applied
docker-compose exec api dotnet ef database update
```

**Clean slate (reset everything):**
```bash
# Stop and remove everything
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Start fresh
docker-compose up -d --build
```

### Benefits of Docker Setup

1. **No Local Installation:** No need to install PostgreSQL, .NET SDK, or other dependencies
2. **Consistent Environment:** Same environment for all developers
3. **Easy Setup:** Single command to start everything
4. **Isolated:** Services run in containers, no conflicts with local installations
5. **Easy Cleanup:** Remove everything with one command
6. **Production-like:** Development environment similar to production
7. **Database Management:** pgAdmin included for easy database management
8. **Background Jobs:** Hangfire dashboard for monitoring jobs

### Next Steps

After Docker setup:
1. Start services: `docker-compose up -d`
2. Run migrations: `docker-compose exec api dotnet ef database update`
3. Seed data: `docker-compose exec api dotnet run --seed`
4. Access API: http://localhost:5000
5. Access Swagger: http://localhost:5000/swagger
6. Access pgAdmin: http://localhost:5050
7. Access Hangfire: http://localhost:5000/hangfire
