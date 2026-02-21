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

#### Subscription and Commission Entities

**SubscriptionPlan**
- Properties: Id, PlanCode, PlanName, Description, MonthlyFee, AnnualFee, MaxUsers, MaxBookingsPerMonth, Features, IsActive
- Methods: Activate(), Deactivate(), UpdatePricing()
- Relationships: HasMany AgencySubscriptions

**AgencySubscription**
- Properties: Id, AgencyId, PlanId, Status, StartDate, EndDate, BillingCycle, NextBillingDate, AutoRenew
- Methods: Activate(), Suspend(), Cancel(), Renew(), CalculateNextBillingDate()
- Relationships: BelongsTo Agency, BelongsTo SubscriptionPlan

**CommissionConfig**
- Properties: Id, ConfigName, TransactionType, CommissionType, CommissionValue, MinTransactionAmount, MaxCommissionAmount, IsActive, EffectiveFrom, EffectiveTo
- Methods: Activate(), Deactivate(), CalculateCommission(), IsEffectiveForDate()
- Relationships: HasMany CommissionTransactions

**CommissionTransaction**
- Properties: Id, AgencyId, TransactionType, TransactionReferenceId, TransactionAmount, CommissionConfigId, CommissionAmount, CommissionPercentage, Status, TransactionDate, CollectedAt, Notes
- Methods: Collect(), Waive(), CalculateCommission()
- Relationships: BelongsTo Agency, BelongsTo CommissionConfig

**RevenueMetric**
- Properties: Id, MetricDate, TotalSubscriptionRevenue, TotalCommissionRevenue, TotalBookingCommissions, TotalMarketplaceCommissions, ActiveAgenciesCount, NewAgenciesCount, ChurnedAgenciesCount, TotalBookingsCount, TotalMarketplaceTransactionsCount
- Methods: Calculate(), Aggregate()
- Relationships: None (aggregate data)

#### B2B Marketplace Entities

**AgencyService**
- Properties: Id, AgencyId, POId, ServiceType, Name, Description, Specifications, CostPrice, ResellerPrice, MarkupPercentage, TotalQuota, UsedQuota, AvailableQuota, ReservedQuota, SoldQuota, IsPublished
- Methods: Publish(), Unpublish(), ReserveQuota(), ReleaseQuota(), TransferQuota()
- Relationships: BelongsTo Agency, BelongsTo PurchaseOrder, HasMany AgencyOrders

**AgencyOrder**
- Properties: Id, OrderNumber, BuyerAgencyId, SellerAgencyId, AgencyServiceId, Quantity, UnitPrice, TotalPrice, Status, Notes, RejectionReason
- Methods: Approve(), Reject(), Cancel()
- Relationships: BelongsTo Agency (Buyer), BelongsTo Agency (Seller), BelongsTo AgencyService

#### Subscription and Commission Entities

**SubscriptionPlan**
- Properties: Id, PlanName, PlanType, Description, MonthlyPrice, AnnualPrice, Features, IsActive, DisplayOrder
- Methods: Activate(), Deactivate(), UpdateFeatures()
- Relationships: HasMany AgencySubscriptions

**AgencySubscription**
- Properties: Id, AgencyId, PlanId, StartDate, EndDate, BillingCycle, NextBillingDate, Status, AutoRenew, CancelledAt, CancellationReason
- Methods: Cancel(), Renew(), Suspend(), Reactivate()
- Relationships: BelongsTo Agency, BelongsTo SubscriptionPlan

**CommissionConfig**
- Properties: Id, AgencyId, ServiceType, CommissionType, CommissionValue, EffectiveFrom, EffectiveUntil, IsActive, Notes
- Methods: Activate(), Deactivate(), ValidateDateRange(), CalculateCommission()
- Relationships: BelongsTo Agency (nullable for global configs), HasMany CommissionTransactions

**CommissionTransaction**
- Properties: Id, TransactionType, ReferenceId, AgencyId, CommissionConfigId, BaseAmount, CommissionRate, CommissionAmount, Status, CollectedAt, PaymentReference, Notes
- Methods: MarkAsCollected(), Waive(), Refund()
- Relationships: BelongsTo Agency, BelongsTo CommissionConfig

**RevenueMetric**
- Properties: Id, AgencyId, MetricDate, TotalBookings, TotalRevenue, TotalCommission, MarketplaceOrders, MarketplaceRevenue, ActivePackages, ActiveJourneys
- Methods: UpdateMetrics(), CalculateTotals()
- Relationships: BelongsTo Agency


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

**Subscription Commands**
- CreateSubscriptionPlanCommand → CreateSubscriptionPlanCommandHandler
- UpdateSubscriptionPlanCommand → UpdateSubscriptionPlanCommandHandler
- ActivateSubscriptionPlanCommand → ActivateSubscriptionPlanCommandHandler
- AssignAgencySubscriptionCommand → AssignAgencySubscriptionCommandHandler
- CancelAgencySubscriptionCommand → CancelAgencySubscriptionCommandHandler

**Commission Commands**
- CreateCommissionConfigCommand → CreateCommissionConfigCommandHandler
- UpdateCommissionConfigCommand → UpdateCommissionConfigCommandHandler
- RecordCommissionTransactionCommand → RecordCommissionTransactionCommandHandler
- CollectCommissionCommand → CollectCommissionCommandHandler


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

**Subscription Queries**
- GetSubscriptionPlansQuery → GetSubscriptionPlansQueryHandler
- GetSubscriptionPlanByIdQuery → GetSubscriptionPlanByIdQueryHandler
- GetAgencySubscriptionsQuery → GetAgencySubscriptionsQueryHandler
- GetAgencySubscriptionByIdQuery → GetAgencySubscriptionByIdQueryHandler

**Commission Queries**
- GetCommissionConfigsQuery → GetCommissionConfigsQueryHandler
- GetCommissionConfigByIdQuery → GetCommissionConfigByIdQueryHandler
- GetCommissionTransactionsQuery → GetCommissionTransactionsQueryHandler
- GetCommissionTransactionByIdQuery → GetCommissionTransactionByIdQueryHandler
- GetRevenueMetricsQuery → GetRevenueMetricsQueryHandler


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

The system uses PostgreSQL 16 with 29+ tables organized into logical groups:

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
14. Subscription & Commission Tables (5): subscription_plans, agency_subscriptions, commission_configs, commission_transactions, revenue_metrics

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
- business_license_number: VARCHAR(100) UNIQUE NOT NULL
- tax_id: VARCHAR(100) UNIQUE NOT NULL
- city: VARCHAR(100)
- province: VARCHAR(100)
- postal_code: VARCHAR(20)
- country: VARCHAR(100) DEFAULT 'Indonesia'
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


### Subscription and Commission Tables

**subscription_plans**
- id: UUID (PK)
- plan_code: VARCHAR(50) UNIQUE NOT NULL
- plan_name: VARCHAR(100) NOT NULL
- description: TEXT
- monthly_fee: DECIMAL(15,2) NOT NULL
- annual_fee: DECIMAL(15,2) NOT NULL
- max_users: INTEGER
- max_bookings_per_month: INTEGER
- features: JSONB (list of included features)
- is_active: BOOLEAN DEFAULT true
- created_at, updated_at: TIMESTAMP

**agency_subscriptions**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- plan_id: UUID (FK → subscription_plans) NOT NULL
- status: VARCHAR(50) DEFAULT 'active' (active, suspended, cancelled, expired)
- start_date: DATE NOT NULL
- end_date: DATE
- billing_cycle: VARCHAR(50) NOT NULL (monthly, annual)
- next_billing_date: DATE NOT NULL
- auto_renew: BOOLEAN DEFAULT true
- created_at, updated_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**commission_configs**
- id: UUID (PK)
- config_name: VARCHAR(100) NOT NULL
- transaction_type: VARCHAR(50) NOT NULL (booking, marketplace_sale, marketplace_purchase)
- commission_type: VARCHAR(50) NOT NULL (percentage, fixed)
- commission_value: DECIMAL(15,2) NOT NULL
- min_transaction_amount: DECIMAL(15,2)
- max_commission_amount: DECIMAL(15,2)
- is_active: BOOLEAN DEFAULT true
- effective_from: DATE NOT NULL
- effective_to: DATE
- created_at, updated_at: TIMESTAMP

**commission_transactions**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- transaction_type: VARCHAR(50) NOT NULL
- transaction_reference_id: UUID NOT NULL (booking_id or agency_order_id)
- transaction_amount: DECIMAL(15,2) NOT NULL
- commission_config_id: UUID (FK → commission_configs) NOT NULL
- commission_amount: DECIMAL(15,2) NOT NULL
- commission_percentage: DECIMAL(5,2)
- status: VARCHAR(50) DEFAULT 'pending' (pending, collected, waived)
- transaction_date: DATE NOT NULL
- collected_at: TIMESTAMP
- notes: TEXT
- created_at: TIMESTAMP
- RLS Policy: agency_id = current_setting('app.current_agency_id')::UUID

**revenue_metrics**
- id: UUID (PK)
- metric_date: DATE NOT NULL
- total_subscription_revenue: DECIMAL(15,2) DEFAULT 0
- total_commission_revenue: DECIMAL(15,2) DEFAULT 0
- total_booking_commissions: DECIMAL(15,2) DEFAULT 0
- total_marketplace_commissions: DECIMAL(15,2) DEFAULT 0
- active_agencies_count: INTEGER DEFAULT 0
- new_agencies_count: INTEGER DEFAULT 0
- churned_agencies_count: INTEGER DEFAULT 0
- total_bookings_count: INTEGER DEFAULT 0
- total_marketplace_transactions_count: INTEGER DEFAULT 0
- created_at: TIMESTAMP
- UNIQUE: metric_date

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

### Subscription and Commission Tables

**subscription_plans**
- id: UUID (PK)
- plan_name: VARCHAR(100) UNIQUE NOT NULL
- plan_type: VARCHAR(50) NOT NULL (free, basic, professional, enterprise)
- description: TEXT
- monthly_price: DECIMAL(10,2) NOT NULL
- annual_price: DECIMAL(10,2)
- features: JSONB NOT NULL (max_users, max_bookings_per_month, max_packages, marketplace_access, api_access, custom_branding, priority_support)
- is_active: BOOLEAN DEFAULT true
- display_order: INTEGER DEFAULT 0
- created_at, updated_at: TIMESTAMP

**agency_subscriptions**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- plan_id: UUID (FK → subscription_plans) NOT NULL
- start_date: DATE NOT NULL
- end_date: DATE
- billing_cycle: VARCHAR(50) NOT NULL (monthly, quarterly, annually)
- next_billing_date: DATE
- status: VARCHAR(50) DEFAULT 'active' (active, suspended, cancelled, expired)
- auto_renew: BOOLEAN DEFAULT true
- cancelled_at: TIMESTAMP
- cancellation_reason: TEXT
- created_at, updated_at: TIMESTAMP
- UNIQUE: (agency_id, status) WHERE status = 'active' (only one active subscription per agency)

**commission_configs**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) (NULL for global configs)
- service_type: VARCHAR(50) NOT NULL (hotel, flight, visa, transport, guide, insurance, catering, handling, package, marketplace)
- commission_type: VARCHAR(50) NOT NULL (percentage, fixed)
- commission_value: DECIMAL(10,2) NOT NULL
- effective_from: DATE NOT NULL
- effective_until: DATE
- is_active: BOOLEAN DEFAULT true
- notes: TEXT
- created_by: UUID (FK → users) NOT NULL
- created_at, updated_at: TIMESTAMP
- CONSTRAINT: (commission_type = 'percentage' AND commission_value BETWEEN 0 AND 100) OR (commission_type = 'fixed' AND commission_value > 0)

**commission_transactions**
- id: UUID (PK)
- transaction_type: VARCHAR(50) NOT NULL (booking, marketplace_order, purchase_order)
- reference_id: UUID NOT NULL (booking_id, agency_order_id, or po_id)
- agency_id: UUID (FK → agencies) NOT NULL
- commission_config_id: UUID (FK → commission_configs)
- base_amount: DECIMAL(15,2) NOT NULL
- commission_rate: DECIMAL(10,2) NOT NULL
- commission_amount: DECIMAL(15,2) NOT NULL
- status: VARCHAR(50) DEFAULT 'pending' (pending, collected, waived, refunded)
- collected_at: TIMESTAMP
- payment_reference: VARCHAR(100)
- notes: TEXT
- created_at, updated_at: TIMESTAMP
- INDEX: (agency_id, transaction_type, status)
- INDEX: (reference_id, transaction_type)

**revenue_metrics**
- id: UUID (PK)
- agency_id: UUID (FK → agencies) NOT NULL
- metric_date: DATE NOT NULL
- total_bookings: INTEGER DEFAULT 0
- total_revenue: DECIMAL(15,2) DEFAULT 0
- total_commission: DECIMAL(15,2) DEFAULT 0
- marketplace_orders: INTEGER DEFAULT 0
- marketplace_revenue: DECIMAL(15,2) DEFAULT 0
- active_packages: INTEGER DEFAULT 0
- active_journeys: INTEGER DEFAULT 0
- created_at, updated_at: TIMESTAMP
- UNIQUE: (agency_id, metric_date)


### Database Functions

**get_service_price_for_date(service_id UUID, date DATE) RETURNS DECIMAL(15,2)**
- Check for active seasonal price for the given date
- If found, return seasonal_price
- Otherwise, return base_price from supplier_services

### Database Indexes

All foreign keys are indexed. Additional indexes:
- users: email, agency_id, supplier_id
- agencies: agency_code, is_active
- suppliers: supplier_code, status, business_license_number, tax_id, email
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
- subscription_plans: plan_type, is_active
- agency_subscriptions: agency_id, plan_id, status, next_billing_date
- commission_configs: agency_id, service_type, is_active, effective_from, effective_until
- commission_transactions: agency_id, transaction_type, status, reference_id
- revenue_metrics: agency_id, metric_date


## API Endpoints

This section defines all REST API endpoints organized by functional area.

### Authentication Endpoints

**POST /api/auth/login**
- Description: User login with email and password
- Request: { email, password }
- Response: { token, user, agency/supplier }
- Auth: Public

**POST /api/auth/register/supplier**
- Description: Public supplier self-registration
- Request: { company_name, business_type, email, phone, password, business_license_number, tax_id, address, city, province, postal_code, country }
- Response: { supplier_id, supplier_code, status: 'pending' }
- Auth: Public

**POST /api/auth/refresh**
- Description: Refresh JWT token
- Request: { refresh_token }
- Response: { token }
- Auth: Authenticated

### Platform Admin - Agency Management

**GET /api/admin/agencies**
- Description: List all agencies with pagination and filters
- Query: page, page_size, is_active, search
- Response: { agencies[], total, page, page_size }
- Auth: Platform Admin

**GET /api/admin/agencies/{id}**
- Description: Get agency details by ID
- Response: { agency }
- Auth: Platform Admin

**POST /api/admin/agencies**
- Description: Create new agency
- Request: { company_name, email, phone, address, city, province, postal_code }
- Response: { agency_id, agency_code }
- Auth: Platform Admin

**PUT /api/admin/agencies/{id}**
- Description: Update agency details
- Request: { company_name, email, phone, address, city, province, postal_code }
- Response: { agency }
- Auth: Platform Admin

**PATCH /api/admin/agencies/{id}/activate**
- Description: Activate agency
- Response: { agency }
- Auth: Platform Admin

**PATCH /api/admin/agencies/{id}/deactivate**
- Description: Deactivate agency
- Response: { agency }
- Auth: Platform Admin

### Platform Admin - Supplier Management

**GET /api/admin/suppliers**
- Description: List all suppliers with pagination and filters
- Query: page, page_size, status, search
- Response: { suppliers[], total, page, page_size }
- Auth: Platform Admin

**GET /api/admin/suppliers/{id}**
- Description: Get supplier details by ID
- Response: { supplier }
- Auth: Platform Admin

**PATCH /api/admin/suppliers/{id}/approve**
- Description: Approve pending supplier
- Response: { supplier }
- Auth: Platform Admin

**PATCH /api/admin/suppliers/{id}/reject**
- Description: Reject pending supplier
- Request: { rejection_reason }
- Response: { supplier }
- Auth: Platform Admin

### Platform Admin - Subscription Plans

**GET /api/admin/subscription-plans**
- Description: List all subscription plans
- Query: is_active
- Response: { plans[] }
- Auth: Platform Admin

**GET /api/admin/subscription-plans/{id}**
- Description: Get subscription plan details
- Response: { plan }
- Auth: Platform Admin

**POST /api/admin/subscription-plans**
- Description: Create new subscription plan
- Request: { plan_name, plan_type, description, monthly_price, annual_price, features }
- Response: { plan_id }
- Auth: Platform Admin

**PUT /api/admin/subscription-plans/{id}**
- Description: Update subscription plan
- Request: { plan_name, description, monthly_price, annual_price, features }
- Response: { plan }
- Auth: Platform Admin

**PATCH /api/admin/subscription-plans/{id}/activate**
- Description: Activate subscription plan
- Response: { plan }
- Auth: Platform Admin

**PATCH /api/admin/subscription-plans/{id}/deactivate**
- Description: Deactivate subscription plan
- Response: { plan }
- Auth: Platform Admin

### Platform Admin - Agency Subscriptions

**GET /api/admin/agency-subscriptions**
- Description: List all agency subscriptions
- Query: agency_id, status, page, page_size
- Response: { subscriptions[], total }
- Auth: Platform Admin

**POST /api/admin/agency-subscriptions**
- Description: Assign subscription to agency
- Request: { agency_id, plan_id, start_date, billing_cycle }
- Response: { subscription_id }
- Auth: Platform Admin

**PATCH /api/admin/agency-subscriptions/{id}/cancel**
- Description: Cancel agency subscription
- Request: { cancellation_reason }
- Response: { subscription }
- Auth: Platform Admin

**PATCH /api/admin/agency-subscriptions/{id}/suspend**
- Description: Suspend agency subscription
- Response: { subscription }
- Auth: Platform Admin

### Platform Admin - Commission Configuration

**GET /api/admin/commission-configs**
- Description: List all commission configurations
- Query: agency_id, service_type, is_active
- Response: { configs[] }
- Auth: Platform Admin

**GET /api/admin/commission-configs/{id}**
- Description: Get commission config details
- Response: { config }
- Auth: Platform Admin

**POST /api/admin/commission-configs**
- Description: Create commission configuration
- Request: { agency_id, service_type, commission_type, commission_value, effective_from, effective_until }
- Response: { config_id }
- Auth: Platform Admin

**PUT /api/admin/commission-configs/{id}**
- Description: Update commission configuration
- Request: { commission_type, commission_value, effective_from, effective_until }
- Response: { config }
- Auth: Platform Admin

**PATCH /api/admin/commission-configs/{id}/activate**
- Description: Activate commission config
- Response: { config }
- Auth: Platform Admin

**PATCH /api/admin/commission-configs/{id}/deactivate**
- Description: Deactivate commission config
- Response: { config }
- Auth: Platform Admin

### Platform Admin - Commission Transactions

**GET /api/admin/commission-transactions**
- Description: List all commission transactions
- Query: agency_id, transaction_type, status, date_from, date_to, page, page_size
- Response: { transactions[], total, total_commission }
- Auth: Platform Admin

**GET /api/admin/commission-transactions/{id}**
- Description: Get commission transaction details
- Response: { transaction }
- Auth: Platform Admin

**PATCH /api/admin/commission-transactions/{id}/collect**
- Description: Mark commission as collected
- Request: { payment_reference }
- Response: { transaction }
- Auth: Platform Admin

**PATCH /api/admin/commission-transactions/{id}/waive**
- Description: Waive commission
- Request: { notes }
- Response: { transaction }
- Auth: Platform Admin

### Platform Admin - Revenue Metrics

**GET /api/admin/revenue-metrics**
- Description: Get revenue metrics dashboard
- Query: date_from, date_to, agency_id
- Response: { metrics[], total_revenue, total_commission, total_bookings }
- Auth: Platform Admin

**GET /api/admin/revenue-metrics/summary**
- Description: Get revenue summary by date range
- Query: date_from, date_to
- Response: { daily_metrics[], monthly_summary, top_agencies[] }
- Auth: Platform Admin

**GET /api/admin/revenue-metrics/agencies/{agency_id}**
- Description: Get revenue metrics for specific agency
- Query: date_from, date_to
- Response: { metrics[], trends }
- Auth: Platform Admin

### Supplier Services

**GET /api/supplier/services**
- Description: List supplier's own services
- Query: service_type, status, page, page_size
- Response: { services[], total }
- Auth: Supplier Staff

**GET /api/supplier/services/{id}**
- Description: Get service details
- Response: { service }
- Auth: Supplier Staff

**POST /api/supplier/services**
- Description: Create new service
- Request: { service_type, name, description, base_price, currency, location_city, location_country, type_specific_fields }
- Response: { service_id, service_code }
- Auth: Supplier Staff

**PUT /api/supplier/services/{id}**
- Description: Update service
- Request: { name, description, base_price, type_specific_fields }
- Response: { service }
- Auth: Supplier Staff

**PATCH /api/supplier/services/{id}/publish**
- Description: Publish service to marketplace
- Response: { service }
- Auth: Supplier Staff

### Purchase Orders

**GET /api/purchase-orders**
- Description: List purchase orders
- Query: status, supplier_id, page, page_size
- Response: { purchase_orders[], total }
- Auth: Agency Staff

**GET /api/purchase-orders/{id}**
- Description: Get purchase order details
- Response: { purchase_order, items[] }
- Auth: Agency Staff, Supplier Staff

**POST /api/purchase-orders**
- Description: Create purchase order
- Request: { supplier_id, items[], notes }
- Response: { po_id, po_number }
- Auth: Agency Staff

**PATCH /api/purchase-orders/{id}/approve**
- Description: Approve purchase order (Supplier)
- Response: { purchase_order }
- Auth: Supplier Staff

**PATCH /api/purchase-orders/{id}/reject**
- Description: Reject purchase order (Supplier)
- Request: { rejection_reason }
- Response: { purchase_order }
- Auth: Supplier Staff

### Packages

**GET /api/packages**
- Description: List packages
- Query: package_type, status, page, page_size
- Response: { packages[], total }
- Auth: Agency Staff

**GET /api/packages/{id}**
- Description: Get package details
- Response: { package, services[], itinerary }
- Auth: Agency Staff

**GET /api/packages/available-services**
- Description: Get available services for package creation (from approved POs and marketplace)
- Response: { supplier_services[], agency_services[] }
- Auth: Agency Staff

**POST /api/packages**
- Description: Create package
- Request: { package_type, name, description, duration_days, services[], markup_type, markup_value }
- Response: { package_id, package_code }
- Auth: Agency Staff

**PUT /api/packages/{id}**
- Description: Update package
- Request: { name, description, services[], markup_type, markup_value }
- Response: { package }
- Auth: Agency Staff

### Journeys

**GET /api/journeys**
- Description: List journeys
- Query: package_id, status, departure_date_from, departure_date_to, page, page_size
- Response: { journeys[], total }
- Auth: Agency Staff

**GET /api/journeys/{id}**
- Description: Get journey details
- Response: { journey, package, bookings[] }
- Auth: Agency Staff

**GET /api/journeys/{id}/services**
- Description: Get journey services with tracking status
- Response: { services[] }
- Auth: Agency Staff

**POST /api/journeys**
- Description: Create journey
- Request: { package_id, departure_date, return_date, total_quota, notes }
- Response: { journey_id, journey_code }
- Auth: Agency Staff

**PATCH /api/journeys/{id}/services/{serviceId}/status**
- Description: Update journey service tracking status
- Request: { booking_status, execution_status, payment_status, issue_notes }
- Response: { service }
- Auth: Agency Staff

### Bookings

**GET /api/bookings**
- Description: List bookings
- Query: status, journey_id, customer_id, page, page_size
- Response: { bookings[], total }
- Auth: Agency Staff

**GET /api/bookings/{id}**
- Description: Get booking details
- Response: { booking, travelers[], documents[], tasks[], payment_schedules[] }
- Auth: Agency Staff

**POST /api/bookings**
- Description: Create booking
- Request: { package_id, journey_id, customer_id, total_pax, booking_source, notes }
- Response: { booking_id, booking_reference }
- Auth: Agency Staff

**PATCH /api/bookings/{id}/approve**
- Description: Approve booking
- Response: { booking }
- Auth: Agency Staff

**PATCH /api/bookings/{id}/cancel**
- Description: Cancel booking
- Request: { cancellation_reason }
- Response: { booking }
- Auth: Agency Staff

### Documents

**GET /api/bookings/{bookingId}/documents**
- Description: Get booking documents
- Response: { documents[] }
- Auth: Agency Staff

**PATCH /api/bookings/{bookingId}/documents/{id}/status**
- Description: Update document status
- Request: { status, document_number, expiry_date, rejection_reason }
- Response: { document }
- Auth: Agency Staff

### B2B Marketplace

**GET /api/marketplace/services**
- Description: Browse marketplace services (excludes own agency)
- Query: service_type, page, page_size
- Response: { services[] }
- Auth: Agency Staff

**GET /api/agency-services**
- Description: List own agency services
- Query: is_published, page, page_size
- Response: { services[] }
- Auth: Agency Staff

**POST /api/agency-services**
- Description: Publish service to marketplace
- Request: { po_id, service_type, name, description, cost_price, reseller_price, total_quota }
- Response: { service_id }
- Auth: Agency Staff

**POST /api/agency-orders**
- Description: Create order to another agency
- Request: { agency_service_id, quantity, notes }
- Response: { order_id, order_number }
- Auth: Agency Staff

**PATCH /api/agency-orders/{id}/approve**
- Description: Approve agency order (Seller)
- Response: { order }
- Auth: Agency Staff

**PATCH /api/agency-orders/{id}/reject**
- Description: Reject agency order (Seller)
- Request: { rejection_reason }
- Response: { order }
- Auth: Agency Staff


---

## API Response Format Standards

**Validates: Requirement 46**

This section defines the standardized response format for all API endpoints, ensuring consistency and following REST API best practices with snake_case naming convention.

### JSON Naming Convention

All API requests and responses MUST use **snake_case** naming convention for JSON properties:

**Configuration in Program.cs:**
```csharp
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
        options.JsonSerializerOptions.DictionaryKeyPolicy = JsonNamingPolicy.SnakeCaseLower;
    });
```

**Example Transformation:**
- C# Property: `UserId` → JSON Property: `user_id`
- C# Property: `FullName` → JSON Property: `full_name`
- C# Property: `CreatedAt` → JSON Property: `created_at`

### Success Response Structure

All successful API responses MUST follow this structure:

```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful",
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Response Wrapper Class:**
```csharp
public class ApiResponse<T>
{
    public bool Success { get; set; } = true;
    public T Data { get; set; }
    public string Message { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}
```

**Example - Login Success:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user_id": "0e465e23-5b4f-40bf-a0d8-3449d0598cef",
    "email": "superadmin@dev.test",
    "full_name": "Superadmin",
    "user_type": "platform_admin",
    "agency_id": null,
    "supplier_id": null
  },
  "message": "Login successful",
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Example - Create Agency Success:**
```json
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "agency_code": "AGN-240219-001",
    "company_name": "Travel Agency ABC",
    "email": "contact@travelabc.com",
    "phone": "+62812345678",
    "is_active": true,
    "created_at": "2024-02-19T10:30:00Z"
  },
  "message": "Agency created successfully",
  "timestamp": "2024-02-19T10:30:00Z"
}
```

### Error Response Structure

All error responses MUST follow this structure:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": []
  },
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Error Response Class:**
```csharp
public class ApiErrorResponse
{
    public bool Success { get; set; } = false;
    public ErrorDetails Error { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

public class ErrorDetails
{
    public string Code { get; set; }
    public string Message { get; set; }
    public List<object> Details { get; set; } = new();
}
```

### Error Codes

**Standard Error Codes:**

| HTTP Status | Error Code | Description |
|------------|------------|-------------|
| 400 | VALIDATION_ERROR | Request validation failed |
| 401 | UNAUTHORIZED | Authentication required or token invalid |
| 403 | FORBIDDEN | User lacks required permissions |
| 404 | NOT_FOUND | Requested resource not found |
| 409 | CONFLICT | Resource conflict (e.g., duplicate email) |
| 422 | BUSINESS_RULE_VIOLATION | Business rule validation failed |
| 500 | INTERNAL_SERVER_ERROR | Unexpected server error |

**Example - Validation Error:**
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
      },
      {
        "field": "company_name",
        "message": "Company name must be at least 3 characters"
      }
    ]
  },
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Example - Not Found Error:**
```json
{
  "success": false,
  "error": {
    "code": "NOT_FOUND",
    "message": "Agency with ID 'a1b2c3d4-e5f6-7890-abcd-ef1234567890' not found",
    "details": []
  },
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Example - Unauthorized Error:**
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Invalid or expired token",
    "details": []
  },
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Example - Forbidden Error:**
```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to access this resource",
    "details": []
  },
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Example - Business Rule Violation:**
```json
{
  "success": false,
  "error": {
    "code": "BUSINESS_RULE_VIOLATION",
    "message": "Cannot approve booking: insufficient quota",
    "details": [
      {
        "field": "available_quota",
        "current_value": 5,
        "required_value": 10
      }
    ]
  },
  "timestamp": "2024-02-19T10:30:00Z"
}
```

### Paginated Response Structure

For endpoints returning lists with pagination:

```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total_items": 100,
    "total_pages": 5
  },
  "message": "Data retrieved successfully",
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Paginated Response Class:**
```csharp
public class PaginatedApiResponse<T>
{
    public bool Success { get; set; } = true;
    public List<T> Data { get; set; }
    public PaginationMetadata Pagination { get; set; }
    public string Message { get; set; }
    public DateTime Timestamp { get; set; } = DateTime.UtcNow;
}

public class PaginationMetadata
{
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalItems { get; set; }
    public int TotalPages { get; set; }
}
```

**Example - Paginated Agencies List:**
```json
{
  "success": true,
  "data": [
    {
      "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "agency_code": "AGN-240219-001",
      "company_name": "Travel Agency ABC",
      "email": "contact@travelabc.com",
      "is_active": true,
      "created_at": "2024-02-19T10:30:00Z"
    },
    {
      "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "agency_code": "AGN-240219-002",
      "company_name": "Travel Agency XYZ",
      "email": "info@travelxyz.com",
      "is_active": true,
      "created_at": "2024-02-19T11:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total_items": 45,
    "total_pages": 3
  },
  "message": "Agencies retrieved successfully",
  "timestamp": "2024-02-19T12:00:00Z"
}
```

### Implementation Guidelines

**IMPORTANT: Automatic Response Wrapping**

To ensure ALL controllers automatically return standardized responses without manual wrapping, we use **IAlwaysRunResultFilter** that intercepts and wraps all responses.

**1. Create ApiResponseWrapperFilter:**

```csharp
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

public class ApiResponseWrapperFilter : IAlwaysRunResultFilter
{
    public void OnResultExecuting(ResultExecutingContext context)
    {
        // Skip wrapping for non-API endpoints (e.g., Swagger, Health checks)
        if (!context.HttpContext.Request.Path.StartsWithSegments("/api"))
        {
            return;
        }

        // Skip if already wrapped (to avoid double wrapping)
        if (context.Result is ObjectResult objectResult && 
            objectResult.Value?.GetType().Name.Contains("ApiResponse") == true)
        {
            return;
        }

        // Wrap OkObjectResult (200)
        if (context.Result is OkObjectResult okResult)
        {
            var wrappedResponse = new ApiResponse<object>
            {
                Success = true,
                Data = okResult.Value,
                Message = "Operation successful",
                Timestamp = DateTime.UtcNow
            };
            context.Result = new OkObjectResult(wrappedResponse);
        }
        // Wrap CreatedResult (201)
        else if (context.Result is CreatedResult createdResult)
        {
            var wrappedResponse = new ApiResponse<object>
            {
                Success = true,
                Data = createdResult.Value,
                Message = "Resource created successfully",
                Timestamp = DateTime.UtcNow
            };
            context.Result = new ObjectResult(wrappedResponse) { StatusCode = 201 };
        }
        // Wrap CreatedAtActionResult (201)
        else if (context.Result is CreatedAtActionResult createdAtActionResult)
        {
            var wrappedResponse = new ApiResponse<object>
            {
                Success = true,
                Data = createdAtActionResult.Value,
                Message = "Resource created successfully",
                Timestamp = DateTime.UtcNow
            };
            context.Result = new ObjectResult(wrappedResponse) { StatusCode = 201 };
        }
        // Wrap NoContentResult (204) - return success with null data
        else if (context.Result is NoContentResult)
        {
            var wrappedResponse = new ApiResponse<object>
            {
                Success = true,
                Data = null,
                Message = "Operation successful",
                Timestamp = DateTime.UtcNow
            };
            context.Result = new OkObjectResult(wrappedResponse);
        }
    }

    public void OnResultExecuted(ResultExecutedContext context)
    {
        // No action needed after execution
    }
}
```

**2. Register Filter Globally in Program.cs:**

```csharp
builder.Services.AddControllers(options =>
{
    // Add global filter to wrap all API responses
    options.Filters.Add<ApiResponseWrapperFilter>();
})
.AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
    options.JsonSerializerOptions.DictionaryKeyPolicy = JsonNamingPolicy.SnakeCaseLower;
});
```

**3. Controller Usage (Simple & Clean):**

```csharp
[ApiController]
[Route("api/admin/agencies")]
public class AgencyController : ControllerBase
{
    private readonly IMediator _mediator;

    public AgencyController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetAgencies([FromQuery] GetAgenciesQuery query)
    {
        var result = await _mediator.Send(query);
        
        // Simple return - Filter will automatically wrap this
        return Ok(new 
        {
            Agencies = result.Agencies,
            Pagination = new 
            {
                Page = query.Page,
                PageSize = query.PageSize,
                TotalItems = result.TotalCount,
                TotalPages = (int)Math.Ceiling(result.TotalCount / (double)query.PageSize)
            }
        });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetAgencyById(Guid id)
    {
        var result = await _mediator.Send(new GetAgencyByIdQuery { Id = id });
        
        // Simple return - Filter will automatically wrap this
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateAgency([FromBody] CreateAgencyCommand command)
    {
        var result = await _mediator.Send(command);
        
        // Simple return - Filter will automatically wrap this
        return Created($"/api/admin/agencies/{result.Id}", result);
    }

    [HttpPatch("{id}/activate")]
    public async Task<IActionResult> ActivateAgency(Guid id)
    {
        var result = await _mediator.Send(new ActivateAgencyCommand { Id = id });
        
        // Simple return - Filter will automatically wrap this
        return Ok(result);
    }
}
```

**Result - All responses automatically wrapped:**

```json
// GET /api/admin/agencies
{
  "success": true,
  "data": {
    "agencies": [...],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total_items": 45,
      "total_pages": 3
    }
  },
  "message": "Operation successful",
  "timestamp": "2024-02-19T12:00:00Z"
}

// POST /api/admin/agencies
{
  "success": true,
  "data": {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "agency_code": "AGN-240219-001",
    "company_name": "Travel Agency ABC",
    ...
  },
  "message": "Resource created successfully",
  "timestamp": "2024-02-19T10:30:00Z"
}
```

**Benefits:**
- ✅ **Zero manual wrapping** - Controllers just return `Ok(data)` or `Created(uri, data)`
- ✅ **Consistent format** - All responses automatically follow the same structure
- ✅ **Future-proof** - New controllers automatically get standardized responses
- ✅ **Clean code** - No repetitive wrapping code in every action
- ✅ **Maintainable** - Change format in one place (filter) affects all endpoints

### Implementation Guidelines (Continued)

**1. Controller Response Helpers (Optional - For Custom Messages):**

Create extension methods for consistent response formatting:

```csharp
public static class ControllerExtensions
{
    public static IActionResult OkResponse<T>(this ControllerBase controller, T data, string message = "Operation successful")
    {
        var response = new ApiResponse<T>
        {
            Success = true,
            Data = data,
            Message = message,
            Timestamp = DateTime.UtcNow
        };
        return controller.Ok(response);
    }

    public static IActionResult CreatedResponse<T>(this ControllerBase controller, T data, string message = "Resource created successfully")
    {
        var response = new ApiResponse<T>
        {
            Success = true,
            Data = data,
            Message = message,
            Timestamp = DateTime.UtcNow
        };
        return controller.StatusCode(201, response);
    }

    public static IActionResult ErrorResponse(this ControllerBase controller, int statusCode, string errorCode, string message, List<object> details = null)
    {
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = errorCode,
                Message = message,
                Details = details ?? new List<object>()
            },
            Timestamp = DateTime.UtcNow
        };
        return controller.StatusCode(statusCode, response);
    }

    public static IActionResult PaginatedResponse<T>(this ControllerBase controller, List<T> data, int page, int pageSize, int totalItems, string message = "Data retrieved successfully")
    {
        var response = new PaginatedApiResponse<T>
        {
            Success = true,
            Data = data,
            Pagination = new PaginationMetadata
            {
                Page = page,
                PageSize = pageSize,
                TotalItems = totalItems,
                TotalPages = (int)Math.Ceiling(totalItems / (double)pageSize)
            },
            Message = message,
            Timestamp = DateTime.UtcNow
        };
        return controller.Ok(response);
    }
}
```

**2. Global Exception Handler Middleware:**

```csharp
public class GlobalExceptionHandlerMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<GlobalExceptionHandlerMiddleware> _logger;

    public GlobalExceptionHandlerMiddleware(RequestDelegate next, ILogger<GlobalExceptionHandlerMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

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
        catch (NotFoundException ex)
        {
            await HandleNotFoundException(context, ex);
        }
        catch (UnauthorizedException ex)
        {
            await HandleUnauthorizedException(context, ex);
        }
        catch (ForbiddenException ex)
        {
            await HandleForbiddenException(context, ex);
        }
        catch (BusinessRuleViolationException ex)
        {
            await HandleBusinessRuleViolationException(context, ex);
        }
        catch (Exception ex)
        {
            await HandleGenericException(context, ex);
        }
    }

    private async Task HandleValidationException(HttpContext context, ValidationException ex)
    {
        _logger.LogWarning(ex, "Validation error occurred");
        
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = "VALIDATION_ERROR",
                Message = "Validation failed",
                Details = ex.Errors.Select(e => new { field = e.PropertyName, message = e.ErrorMessage }).ToList<object>()
            },
            Timestamp = DateTime.UtcNow
        };

        context.Response.StatusCode = 400;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }

    private async Task HandleNotFoundException(HttpContext context, NotFoundException ex)
    {
        _logger.LogWarning(ex, "Resource not found");
        
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = "NOT_FOUND",
                Message = ex.Message,
                Details = new List<object>()
            },
            Timestamp = DateTime.UtcNow
        };

        context.Response.StatusCode = 404;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }

    private async Task HandleUnauthorizedException(HttpContext context, UnauthorizedException ex)
    {
        _logger.LogWarning(ex, "Unauthorized access attempt");
        
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = "UNAUTHORIZED",
                Message = ex.Message,
                Details = new List<object>()
            },
            Timestamp = DateTime.UtcNow
        };

        context.Response.StatusCode = 401;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }

    private async Task HandleForbiddenException(HttpContext context, ForbiddenException ex)
    {
        _logger.LogWarning(ex, "Forbidden access attempt");
        
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = "FORBIDDEN",
                Message = ex.Message,
                Details = new List<object>()
            },
            Timestamp = DateTime.UtcNow
        };

        context.Response.StatusCode = 403;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }

    private async Task HandleBusinessRuleViolationException(HttpContext context, BusinessRuleViolationException ex)
    {
        _logger.LogWarning(ex, "Business rule violation");
        
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = "BUSINESS_RULE_VIOLATION",
                Message = ex.Message,
                Details = ex.Details ?? new List<object>()
            },
            Timestamp = DateTime.UtcNow
        };

        context.Response.StatusCode = 422;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }

    private async Task HandleGenericException(HttpContext context, Exception ex)
    {
        _logger.LogError(ex, "An unexpected error occurred");
        
        var response = new ApiErrorResponse
        {
            Success = false,
            Error = new ErrorDetails
            {
                Code = "INTERNAL_SERVER_ERROR",
                Message = "An unexpected error occurred. Please try again later.",
                Details = new List<object>()
            },
            Timestamp = DateTime.UtcNow
        };

        context.Response.StatusCode = 500;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(response);
    }
}
```

**3. Register Middleware in Program.cs:**

```csharp
// Add JSON options for snake_case
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower;
        options.JsonSerializerOptions.DictionaryKeyPolicy = JsonNamingPolicy.SnakeCaseLower;
    });

// Register middleware
app.UseMiddleware<GlobalExceptionHandlerMiddleware>();
```

**4. Example Controller Usage:**

```csharp
[ApiController]
[Route("api/admin/agencies")]
public class AgencyController : ControllerBase
{
    private readonly IMediator _mediator;

    public AgencyController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet]
    public async Task<IActionResult> GetAgencies([FromQuery] GetAgenciesQuery query)
    {
        var result = await _mediator.Send(query);
        return this.PaginatedResponse(
            result.Agencies,
            query.Page,
            query.PageSize,
            result.TotalCount,
            "Agencies retrieved successfully"
        );
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetAgencyById(Guid id)
    {
        var result = await _mediator.Send(new GetAgencyByIdQuery { Id = id });
        return this.OkResponse(result, "Agency retrieved successfully");
    }

    [HttpPost]
    public async Task<IActionResult> CreateAgency([FromBody] CreateAgencyCommand command)
    {
        var result = await _mediator.Send(command);
        return this.CreatedResponse(result, "Agency created successfully");
    }

    [HttpPatch("{id}/activate")]
    public async Task<IActionResult> ActivateAgency(Guid id)
    {
        var result = await _mediator.Send(new ActivateAgencyCommand { Id = id });
        return this.OkResponse(result, "Agency activated successfully");
    }
}
```

### Benefits of Standardized Response Format

1. **Consistency:** All endpoints follow the same response structure
2. **Predictability:** Frontend developers know exactly what to expect
3. **Error Handling:** Structured error responses make error handling easier
4. **Debugging:** Timestamps help with debugging and logging
5. **API Standards:** Follows REST API best practices with snake_case naming
6. **Type Safety:** Frontend can create TypeScript interfaces matching the response structure
7. **Pagination:** Consistent pagination metadata across all list endpoints


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


---

## Self-Registration with KYC Verification

**Note:** Complete design specifications for Self-Registration and KYC Verification features are documented in a separate file due to the extensive nature of this feature.

**See:** [design-self-registration-kyc.md](./design-self-registration-kyc.md)

This feature includes:
- Agency and Supplier self-registration
- MinIO file storage integration
- Document upload and verification workflow
- Platform admin verification interface
- Access control based on verification status
- Email notifications
- Re-submission capability with attempt limits

**Key Components:**
- 2 modified tables (agencies, suppliers)
- 2 new tables (document_requirements, entity_documents)
- MinIO integration for document storage
- 6 new commands + 3 new queries
- 15+ new API endpoints
- Verification status middleware
- 7 correctness properties for testing

