# Implementation Tasks

## Overview

This document outlines the implementation tasks for Phase 1 MVP backend based on the requirements and design documents. Tasks are organized by feature module and prioritized for an 11-week development timeline.

**Timeline:** 11 weeks (Feb 16 - May 3, 2026)
**Team:** 2 Backend Developers (.NET 8)

## Task Organization

Tasks are grouped by:
1. Foundation & Infrastructure
2. Core Features (Platform Admin, Supplier, Agency)
3. ERP Features (Documents, Tasks, Notifications, Payments, Itinerary)
4. B2B Marketplace
5. Testing & Deployment

---

## Week 1-2: Foundation & Infrastructure (Feb 16 - Mar 1)

### 1. Project Setup

- [x] 1.1 Initialize .NET 8 Web API project with Clean Architecture structure
- [x] 1.2 Setup solution with 4 projects: Domain, Application, Infrastructure, API
- [x] 1.3 Configure PostgreSQL 16 connection with Entity Framework Core 8
- [x] 1.4 Setup Docker and Docker Compose for local development
- [x] 1.5 Configure Serilog for structured logging
- [x] 1.6 Setup Swagger/OpenAPI documentation
- [x] 1.7 Configure CORS policy for frontend integration
- [x] 1.8 Setup health check endpoint (/health)

### 2. Database Schema & Migrations

- [x] 2.1 Create all 29+ domain entities with proper relationships
- [x] 2.2 Create DbContext with entity configurations
- [x] 2.3 Configure Row-Level Security (RLS) policies for multi-tenancy
- [x] 2.4 Create initial migration with all tables (including subscription_plans, agency_subscriptions, commission_configs, commission_transactions, revenue_metrics)
- [x] 2.5 Create database indexes for performance (including new subscription & commission tables)
- [x] 2.6 Create get_service_price_for_date() database function
- [x] 2.7 Create seed data for document_types
- [x] 2.8 Create seed data for task_templates
- [x] 2.9 Create seed data for notification_templates
- [x] 2.10 Create seed data for subscription_plans (free, basic, professional, enterprise)
- [x] 2.11 Create development seed data (agencies, suppliers, services)


### 3. Authentication & Authorization (Req 2)

- [x] 3.1 Implement JWT token generation and validation service
  - _Requirements: 2.1, 2.4_

- [x] 3.2 Implement BCrypt password hashing service
  - _Requirements: 2.2_

- [x] 3.3 Create authentication middleware for JWT validation
  - _Requirements: 2.1, 2.4, 2.5_

- [x] 3.4 Create authorization policies for three user types
  - _Requirements: 2.3, 2.5_

- [x] 3.5 Implement tenant context extraction from JWT
  - _Requirements: 2.1_

- [x] 3.6 Create LoginCommand and handler
  - _Requirements: 2.1_

- [x] 3.7 Create RegisterCommand and handler
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 3.8 Create RefreshTokenCommand and handler
  - _Requirements: 2.4_

- [x] 3.9 Create authentication API endpoints
  - _Requirements: 2.1, 2.5_

- [ ]* 3.10 Write unit tests for authentication services
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

### 4. Multi-Tenancy Implementation (Req 1)

- [x] 4.1 Implement ITenantContextService interface
  - _Requirements: 1.1_

- [x] 4.2 Create middleware to set app.current_agency_id session variable
  - _Requirements: 1.1, 1.2_

- [x] 4.3 Configure RLS policy enforcement in DbContext
  - _Requirements: 1.2, 1.3_

- [x] 4.4 Implement tenant isolation validation
  - _Requirements: 1.3, 1.4_

- [ ]* 4.5 Write unit tests for multi-tenancy logic
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ]* 4.6 Test cross-tenant access prevention
  - _Requirements: 1.4_

### 4A. Standardized API Response Format (Req 46)

- [x] 4A.1 Configure JSON serialization to use snake_case naming convention
  - Configure JsonSerializerOptions in Program.cs with PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
  - _Requirements: 46.4, 46.5, 46.6_

- [x] 4A.2 Create ApiResponse<T> generic class for success responses
  - Include properties: success, data, message, timestamp
  - _Requirements: 46.1, 46.7_

- [x] 4A.3 Create PaginatedApiResponse<T> class for paginated responses
  - Include properties: success, data, pagination (page, page_size, total_items, total_pages), message, timestamp
  - _Requirements: 46.3, 46.7_

- [x] 4A.4 Create ApiErrorResponse class for error responses
  - Include properties: success, error (code, message, details), timestamp
  - _Requirements: 46.2, 46.7_

- [x] 4A.5 Create ApiResponseWrapperFilter (IAlwaysRunResultFilter)
  - Automatically wrap all OkObjectResult, CreatedResult, CreatedAtActionResult, NoContentResult
  - Skip wrapping for non-API endpoints (Swagger, Health checks)
  - Skip if already wrapped to avoid double wrapping
  - _Requirements: 46.1, 46.3_

- [x] 4A.6 Register ApiResponseWrapperFilter globally in Program.cs
  - Add to MVC options filters
  - _Requirements: 46.1_

- [x] 4A.7 Create custom exception classes for different error types
  - ValidationException, NotFoundException, UnauthorizedException, ForbiddenException, BusinessRuleViolationException
  - _Requirements: 46.8, 46.9, 46.10, 46.11, 46.12, 46.13_

- [x] 4A.8 Implement GlobalExceptionHandlerMiddleware
  - Handle all exception types and return standardized error responses with appropriate error codes
  - _Requirements: 46.2, 46.8, 46.9, 46.10, 46.11, 46.12, 46.13_

- [x] 4A.9 Register GlobalExceptionHandlerMiddleware in Program.cs
  - _Requirements: 46.2_

- [x] 4A.10 Verify all API responses use snake_case naming and are automatically wrapped
  - Test all endpoints and verify JSON property names are in snake_case format
  - Verify responses are wrapped even when controller just returns Ok(data)
  - _Requirements: 46.1, 46.4, 46.5_

- [ ]* 4A.11 Write unit tests for response wrapper filter
  - Test automatic wrapping for Ok, Created, NoContent results
  - Test skip logic for non-API endpoints
  - _Requirements: 46.1, 46.3_

- [ ]* 4A.12 Write integration tests for error handling middleware
  - _Requirements: 46.8, 46.9, 46.10, 46.11, 46.12, 46.13_

### 5. CQRS & MediatR Setup

- [x] 5.1 Install and configure MediatR package
- [x] 5.2 Create base Command and Query classes
- [x] 5.3 Create base CommandHandler and QueryHandler classes
- [x] 5.4 Install and configure FluentValidation
- [x] 5.5 Create validation pipeline behavior
- [x] 5.6 Create logging pipeline behavior
- [x] 5.7 Create transaction pipeline behavior
- [x] 5.8 Create exception handling middleware


---

## Week 3: Platform Admin & Supplier Management (Mar 2 - Mar 8)

### 6. Platform Admin - Agency Management (Req 3)

- [x] 6.1 Create CreateAgencyCommand and handler
  - Generate unique agency_code
  - Validate company_name and email are provided
  - Set is_active to true by default
  - _Requirements: 3.1, 3.2, 3.3_

- [x] 6.2 Create UpdateAgencyCommand and handler
  - Allow updating company details
  - Validate required fields
  - _Requirements: 3.2_

- [x] 6.3 Create ActivateAgencyCommand and handler
  - Update is_active to true
  - _Requirements: 3.4_

- [x] 6.4 Create GetAgenciesQuery and handler with pagination
  - Support filtering by is_active
  - Support search by company_name
  - Return paginated results
  - _Requirements: 3.1_

- [x] 6.5 Create GetAgencyByIdQuery and handler
  - Return agency details
  - Include subscription information
  - _Requirements: 3.1_

- [x] 6.6 Create agency DTOs and validators
  - CreateAgencyDto with validation rules
  - UpdateAgencyDto with validation rules
  - Validate email format
  - _Requirements: 3.2_

- [x] 6.7 Create agency API endpoints
  - GET /api/admin/agencies
  - GET /api/admin/agencies/{id}
  - POST /api/admin/agencies
  - PUT /api/admin/agencies/{id}
  - PATCH /api/admin/agencies/{id}/activate
  - PATCH /api/admin/agencies/{id}/deactivate
  - _Requirements: 3.1, 3.4_

- [ ]* 6.8 Write unit tests for agency commands/queries
  - Test agency creation with valid data
  - Test validation failures
  - Test activation/deactivation
  - Test deletion prevention when bookings exist
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 6.9 Test agency code generation logic
  - Verify uniqueness of agency_code
  - Test format consistency
  - _Requirements: 3.1_

### 7. Supplier Registration & Approval (Req 4)

- [ ] 7.1 Create RegisterSupplierCommand and handler
  - Implement supplier_code generation (SUP-YYMMDD-XXX)
  - Validate company_name, business_type, email, phone, business_license_number
  - Validate email format and uniqueness
  - Validate phone format
  - Hash password using BCrypt with salt rounds of 12
  - Validate password requirements (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
  - Create user account with user_type 'supplier_staff'
  - Set supplier status to 'pending'
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8_

- [ ] 7.2 Create ApproveSupplierCommand and handler
  - Update status to 'active'
  - Record approved_at timestamp and approved_by user
  - Send email notification to supplier
  - _Requirements: 4.9, 4.12_

- [ ] 7.3 Create RejectSupplierCommand and handler
  - Update status to 'rejected'
  - Require and record rejection_reason
  - Send email notification to supplier
  - _Requirements: 4.10, 4.12_

- [ ] 7.4 Create GetSuppliersQuery and handler with filtering
  - Support filtering by status (pending, active, rejected, suspended)
  - Support pagination
  - _Requirements: 4.1_

- [ ] 7.5 Create GetSupplierByIdQuery and handler
  - Return supplier details with user account info
  - _Requirements: 4.1_

- [ ] 7.6 Create supplier DTOs and validators
  - RegisterSupplierDto with all required fields
  - Validate business_type enum values
  - Validate email and phone formats
  - Validate password strength
  - _Requirements: 4.3, 4.4, 4.5, 4.6, 4.7_

- [ ] 7.7 Create supplier registration API endpoints
  - POST /api/auth/register/supplier (public endpoint)
  - GET /api/admin/suppliers (platform admin only)
  - GET /api/admin/suppliers/{id} (platform admin only)
  - PATCH /api/admin/suppliers/{id}/approve (platform admin only)
  - PATCH /api/admin/suppliers/{id}/reject (platform admin only)
  - _Requirements: 4.1, 4.9, 4.10_

- [ ]* 7.8 Write unit tests for supplier commands/queries
  - Test registration validation
  - Test password hashing
  - Test approval/rejection workflow
  - Test email notification sending
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 4.10, 4.12_

- [ ]* 7.9 Test supplier code generation logic
  - Test uniqueness of supplier_code
  - Test format SUP-YYMMDD-XXX
  - _Requirements: 4.2_

### 8. Platform Admin Dashboard

- [ ] 8.1 Create GetPlatformDashboardQuery and handler
  - Aggregate total agencies count (active and inactive)
  - Aggregate total suppliers count by status
  - Aggregate total services count by type
  - Aggregate total bookings count and revenue
  - Calculate growth metrics (month-over-month)
  - _Requirements: Platform admin needs overview_

- [ ] 8.2 Implement statistics aggregation queries
  - Use efficient SQL queries with GROUP BY
  - Calculate totals, averages, and trends
  - Optimize with proper indexes
  - Cache results for performance
  - _Requirements: Dashboard performance_

- [ ] 8.3 Create dashboard DTOs
  - PlatformDashboardDto with all metrics
  - AgencyStatisticsDto
  - SupplierStatisticsDto
  - BookingStatisticsDto
  - RevenueStatisticsDto
  - _Requirements: Dashboard data structure_

- [ ] 8.4 Create dashboard API endpoint
  - GET /api/admin/dashboard
  - Support date range filtering
  - Return comprehensive statistics
  - _Requirements: Platform admin access_

- [ ]* 8.5 Write unit tests for dashboard query
  - Test statistics calculation accuracy
  - Test date range filtering
  - Test performance with large datasets
  - _Requirements: Dashboard reliability_


---

## Week 4: Supplier Services & Purchase Orders (Mar 9 - Mar 15)

### 9. Supplier Service Management (Req 5)

- [ ] 9.1 Create CreateSupplierServiceCommand and handler
  - Generate unique service_code in format SVC-{SUPPLIER_CODE}-{SEQUENCE}
  - Validate service_type (hotel, flight, visa, transport, guide, insurance, catering, handling)
  - Validate base_price is greater than zero
  - Validate type-specific fields based on service_type
  - Set status to 'draft' by default
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

- [ ] 9.2 Create UpdateSupplierServiceCommand and handler
  - Allow updating service details
  - Validate type-specific fields
  - Prevent updates if service is published
  - _Requirements: 5.1, 5.6_

- [ ] 9.3 Create PublishSupplierServiceCommand and handler
  - Update status to 'published'
  - Record published_at timestamp
  - Validate service has all required fields
  - _Requirements: 5.7_

- [ ] 9.4 Create GetSupplierServicesQuery and handler
  - Support filtering by service_type and status
  - Support pagination
  - Return only supplier's own services
  - _Requirements: 5.1_

- [ ] 9.5 Create GetSupplierServiceByIdQuery and handler
  - Return service details with type-specific fields
  - Include seasonal prices if any
  - _Requirements: 5.1_

- [ ] 9.6 Implement service code generation (SVC-{SUPPLIER_CODE}-{SEQ})
  - Generate sequential number per supplier
  - Ensure uniqueness
  - _Requirements: 5.5_

- [ ] 9.7 Create service DTOs and validators for all 8 types
  - CreateServiceDto with type-specific validation
  - Hotel: hotel_name, hotel_star_rating, room_type, meal_plan
  - Flight: airline, flight_class, departure_airport, arrival_airport
  - Visa: visa_type, processing_days, validity_days, entry_type
  - Transport: vehicle_type, capacity
  - Guide: language, specialization
  - Insurance: coverage_type, coverage_amount
  - Catering: meal_type, cuisine_type
  - Handling: service_scope
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.6_

- [ ] 9.8 Create service API endpoints
  - GET /api/supplier/services
  - GET /api/supplier/services/{id}
  - POST /api/supplier/services
  - PUT /api/supplier/services/{id}
  - PATCH /api/supplier/services/{id}/publish
  - _Requirements: 5.1, 5.7_

- [ ]* 9.9 Write unit tests for service commands/queries
  - Test service creation for all 8 types
  - Test type-specific field validation
  - Test publish workflow
  - Test service code generation
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

- [ ]* 9.10 Test type-specific field validation
  - Test hotel service requires hotel_name, star_rating, room_type, meal_plan
  - Test flight service requires airline, flight_class, airports
  - Test visa service requires visa_type, processing_days, validity_days, entry_type
  - _Requirements: 5.2, 5.3, 5.4_

### 10. Seasonal Pricing (Req 6)

- [ ] 10.1 Create CreateSeasonalPriceCommand and handler
  - Validate end_date >= start_date
  - Validate seasonal_price > 0
  - Link to supplier_service_id
  - Set is_active to true by default
  - _Requirements: 6.1, 6.2_

- [ ] 10.2 Create UpdateSeasonalPriceCommand and handler
  - Allow updating dates and price
  - Validate date range
  - Validate price is positive
  - _Requirements: 6.1, 6.2_

- [ ] 10.3 Create DeleteSeasonalPriceCommand and handler
  - Soft delete or hard delete based on usage
  - _Requirements: 6.1_

- [ ] 10.4 Create GetSeasonalPricesQuery and handler
  - Return all seasonal prices for a service
  - Support filtering by date range
  - _Requirements: 6.1_

- [ ] 10.5 Implement GetServicePriceForDateQuery using database function
  - Query get_service_price_for_date(service_id, date)
  - Return seasonal_price if date falls within active range
  - Return base_price if no seasonal price exists
  - If multiple overlaps, return most recently created
  - _Requirements: 6.3, 6.4, 6.5_

- [ ] 10.6 Create seasonal price DTOs and validators
  - CreateSeasonalPriceDto with date and price validation
  - Validate date range logic
  - Validate price is positive
  - _Requirements: 6.1, 6.2_

- [ ] 10.7 Create seasonal price API endpoints
  - GET /api/supplier/services/{serviceId}/seasonal-prices
  - POST /api/supplier/services/{serviceId}/seasonal-prices
  - PUT /api/supplier/services/{serviceId}/seasonal-prices/{id}
  - DELETE /api/supplier/services/{serviceId}/seasonal-prices/{id}
  - GET /api/supplier/services/{serviceId}/price?date={date}
  - _Requirements: 6.1, 6.3_

- [ ]* 10.8 Write unit tests for seasonal pricing logic
  - Test price query returns seasonal price when in range
  - Test price query returns base price when out of range
  - Test date validation
  - Test overlap handling (most recent wins)
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ]* 10.9 Test date range overlap handling
  - Create multiple overlapping seasonal prices
  - Verify most recently created is returned
  - _Requirements: 6.5_

### 11. Purchase Order Creation (Req 7)

- [ ] 11.1 Create CreatePurchaseOrderCommand and handler
  - Generate unique po_number in format PO-YYMMDD-XXX
  - Validate at least one service item exists
  - Calculate total_amount as sum of all po_items total_price
  - Set status to 'pending'
  - Send notification to supplier
  - _Requirements: 7.1, 7.2, 7.3, 7.4_

- [ ] 11.2 Implement PO number generation (PO-YYMMDD-XXX)
  - Use current date for YYMMDD
  - Generate sequential XXX per day
  - Ensure uniqueness
  - _Requirements: 7.1_

- [ ] 11.3 Implement total amount calculation
  - Sum all po_items total_price
  - Each po_item total_price = quantity × unit_price
  - Update purchase_order total_amount
  - _Requirements: 7.3_

- [ ] 11.4 Create GetPurchaseOrdersQuery and handler with filtering
  - Support filtering by status (pending, approved, rejected)
  - Support filtering by supplier_id
  - Support date range filtering
  - Support pagination
  - Return PO with items
  - _Requirements: 7.1_

- [ ] 11.5 Create GetPurchaseOrderByIdQuery and handler
  - Return PO details with all items
  - Include supplier information
  - Include service details for each item
  - _Requirements: 7.1_

- [ ] 11.6 Create PO DTOs and validators
  - CreatePurchaseOrderDto with items array
  - POItemDto with service_id, quantity, unit_price validation
  - Validate quantity > 0
  - Validate unit_price > 0
  - Validate at least one item exists
  - _Requirements: 7.2, 7.3_

- [ ] 11.7 Create PO API endpoints
  - GET /api/purchase-orders
  - GET /api/purchase-orders/{id}
  - POST /api/purchase-orders
  - _Requirements: 7.1, 7.5_

- [ ]* 11.8 Write unit tests for PO commands/queries
  - Test PO creation with valid items
  - Test total amount calculation
  - Test validation failures (no items, invalid quantities)
  - Test notification sending
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ]* 11.9 Test PO item validation
  - Test quantity must be positive
  - Test unit_price must be positive
  - Test at least one item required
  - _Requirements: 7.2_

### 12. Purchase Order Approval (Req 8)

- [ ] 12.1 Create ApprovePurchaseOrderCommand and handler
  - Update status to 'approved'
  - Record approved_at timestamp
  - Record approved_by user ID
  - Prevent modification after approval
  - Send notification to agency
  - Trigger supplier bill auto-generation (Req 26)
  - _Requirements: 8.1, 8.3, 8.4_

- [ ] 12.2 Create RejectPurchaseOrderCommand and handler
  - Update status to 'rejected'
  - Record rejected_at timestamp
  - Record rejected_by user ID
  - Require rejection_reason (mandatory field)
  - Prevent modification after rejection
  - Send notification to agency with reason
  - _Requirements: 8.2, 8.3, 8.4_

- [ ] 12.3 Implement status workflow validation
  - Only 'pending' POs can be approved or rejected
  - Approved POs cannot be modified or deleted
  - Rejected POs cannot be modified or deleted
  - Validate status transitions
  - _Requirements: 8.3, 8.5_

- [ ] 12.4 Create notification service for PO status changes
  - Send email notification on approval
  - Send in-app notification on approval
  - Send email notification on rejection with reason
  - Send in-app notification on rejection with reason
  - Include PO details in notifications
  - _Requirements: 8.4_

- [ ]* 12.5 Write unit tests for PO approval workflow
  - Test approval updates status and timestamps correctly
  - Test rejection requires reason
  - Test notifications are sent
  - Test modification prevention after approval
  - Test modification prevention after rejection
  - Test deletion prevention
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ]* 12.6 Test rejection reason requirement
  - Test rejection fails without reason
  - Test rejection succeeds with valid reason
  - Test reason is stored correctly
  - _Requirements: 8.2_


---

## Week 5: Package, Journey & Booking Management (Mar 16 - Mar 22)

### 13. Package Management with Service Selection (Req 9)

- [ ] 13.1 Create CreatePackageCommand and handler
  - Implement package code generation (PKG-{AGENCY_CODE}-{SEQ})
  - Validate name, duration_days, markup_type, markup_value, selling_price
  - Validate selling_price >= base_cost
  - Accept selected services from two sources: po_items and agency_services
  - Save selected services to package_services table
  - Calculate base_cost as sum of all package_services total_cost
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.7, 9.8_

- [ ] 13.2 Create UpdatePackageCommand and handler
  - Allow updating package details and services
  - Recalculate base_cost when services change
  - Recalculate selling_price based on markup
  - _Requirements: 9.3, 9.8, 9.9, 9.10_

- [ ] 13.3 Create PublishPackageCommand and handler
  - Update package status to 'published'
  - Validate package has at least one service
  - _Requirements: 9.4_

- [ ] 13.4 Implement pricing calculation logic
  - When markup_type is 'percentage': selling_price = base_cost × (1 + markup_value/100)
  - When markup_type is 'fixed': selling_price = base_cost + markup_value
  - _Requirements: 9.9, 9.10_

- [ ] 13.5 Create GetAvailableServicesQuery and handler
  - Return combined list of:
    - po_items from approved purchase_orders
    - agency_services purchased from B2B marketplace
  - Include service details, unit_cost, and source_type
  - _Requirements: 9.6, 9.11_

- [ ] 13.6 Create GetPackagesQuery and handler with filtering
  - Support filtering by package_type and status
  - Support pagination
  - Include package_services in response
  - _Requirements: 9.1, 9.2_

- [ ] 13.7 Create GetPackageByIdQuery and handler
  - Return package with all package_services
  - Include service details from both sources
  - _Requirements: 9.1, 9.7_

- [ ] 13.8 Create package DTOs and validators
  - CreatePackageDto with service selection
  - PackageServiceDto with source_type, quantity, unit_cost
  - Validate markup_type enum values
  - Validate selling_price >= base_cost
  - _Requirements: 9.2, 9.3, 9.4, 9.7_

- [ ] 13.9 Create package API endpoints
  - POST /api/packages
  - PUT /api/packages/{id}
  - PATCH /api/packages/{id}/publish
  - GET /api/packages
  - GET /api/packages/{id}
  - GET /api/packages/available-services
  - _Requirements: 9.1, 9.11_

- [ ]* 13.10 Write unit tests for package commands/queries
  - Test package creation with services from both sources
  - Test base_cost calculation
  - Test selling_price calculation for both markup types
  - Test service selection validation
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.6, 9.7, 9.8, 9.9, 9.10, 9.11_

- [ ]* 13.11 Test package-service linking validation
  - Test source_type validation (supplier vs agency)
  - Test quantity validation
  - Test unit_cost validation
  - _Requirements: 9.7_

### 14. Journey Management with Service Tracking (Req 10)

- [ ] 14.1 Create CreateJourneyCommand and handler
  - Implement journey code generation (JRN-{PKG_CODE}-{YYMMDD})
  - Validate departure_date, return_date, total_quota
  - Validate return_date > departure_date
  - Initialize confirmed_pax to 0 and available_quota to total_quota
  - Auto-copy all services from package_services to journey_services
  - Initialize journey_services with default tracking status:
    - booking_status: not_booked
    - execution_status: pending
    - payment_status: unpaid
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_

- [ ] 14.2 Create UpdateJourneyCommand and handler
  - Allow updating journey details (dates, quota)
  - Maintain quota invariant: total = confirmed + available
  - _Requirements: 10.4, 10.5_

- [ ] 14.3 Create GetJourneyServicesQuery and handler
  - Return all journey_services with tracking status
  - Include service details from supplier_services or agency_services
  - _Requirements: 10.8_

- [ ] 14.4 Create UpdateJourneyServiceStatusCommand and handler
  - Update booking_status, execution_status, payment_status
  - Auto-set timestamps:
    - booked_at when booking_status changes to 'booked'
    - confirmed_at when booking_status changes to 'confirmed'
    - executed_at when execution_status changes to 'completed'
  - Allow updating issue_notes
  - _Requirements: 10.9, 10.10, 10.11, 10.12_

- [ ] 14.5 Implement quota management logic
  - Maintain invariant: total_quota = confirmed_pax + available_quota
  - Update quota when bookings are confirmed or cancelled
  - _Requirements: 10.5_

- [ ] 14.6 Create GetJourneysQuery and handler
  - Support filtering by package_id, status, date range
  - Support pagination
  - Include package details in response
  - _Requirements: 10.1, 10.2_

- [ ] 14.7 Create GetJourneyByIdQuery and handler
  - Return journey with package details
  - Include quota information
  - _Requirements: 10.1, 10.3_

- [ ] 14.8 Create journey DTOs and validators
  - CreateJourneyDto with date and quota fields
  - JourneyServiceDto with tracking status fields
  - UpdateServiceStatusDto with status enums and notes
  - Validate date range (return_date > departure_date)
  - Validate status enum values
  - _Requirements: 10.2, 10.3, 10.4, 10.13, 10.14, 10.15_

- [ ] 14.9 Create journey API endpoints
  - POST /api/journeys
  - PUT /api/journeys/{id}
  - GET /api/journeys
  - GET /api/journeys/{id}
  - GET /api/journeys/{id}/services
  - PATCH /api/journeys/{id}/services/{serviceId}/status
  - _Requirements: 10.1, 10.8, 10.9_

- [ ]* 14.10 Write unit tests for journey commands/queries
  - Test journey creation with service auto-copy
  - Test quota management logic
  - Test service status updates with auto-timestamps
  - Test date validation
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 10.10, 10.11, 10.12, 10.13, 10.14, 10.15_

- [ ]* 14.11 Test quota invariant (total = confirmed + available)
  - Test quota updates on booking confirmation
  - Test quota updates on booking cancellation
  - Test quota validation on booking approval
  - _Requirements: 10.5_

### 15. Customer Management (Req 11)

- [ ] 15.1 Create CreateCustomerCommand and handler
  - Generate unique customer_code in format CUST-YYMMDD-XXX
  - Validate name and phone are provided (required)
  - Validate phone is unique within agency
  - Validate email is unique within agency (if provided)
  - Initialize total_bookings to 0
  - Initialize total_spent to 0
  - _Requirements: 11.1, 11.2_

- [ ] 15.2 Create UpdateCustomerCommand and handler
  - Allow updating customer details
  - Validate phone uniqueness within agency
  - Validate email uniqueness within agency
  - Preserve statistics (total_bookings, total_spent)
  - _Requirements: 11.2_

- [ ] 15.3 Implement customer code generation (CUST-YYMMDD-XXX)
  - Use current date for YYMMDD
  - Generate sequential XXX per day
  - Ensure uniqueness
  - _Requirements: 11.1_

- [ ] 15.4 Implement customer statistics auto-update
  - Update total_bookings when booking is created
  - Update total_spent when booking amount changes
  - Update last_booking_date to most recent booking
  - Trigger on booking creation and modification
  - _Requirements: 11.5_

- [ ] 15.5 Create GetCustomersQuery and handler with search
  - Support search by name, email, phone
  - Support filtering by tags
  - Support pagination
  - Return customer with booking statistics
  - _Requirements: 11.1_

- [ ] 15.6 Create GetCustomerByIdQuery and handler
  - Return customer details
  - Include booking history
  - Include communication logs
  - _Requirements: 11.1_

- [ ] 15.7 Create customer DTOs and validators
  - CreateCustomerDto with required fields
  - UpdateCustomerDto with validation
  - Validate phone format
  - Validate email format (if provided)
  - Validate phone uniqueness within agency
  - Validate email uniqueness within agency
  - _Requirements: 11.2, 11.3, 11.4_

- [ ] 15.8 Create customer API endpoints
  - GET /api/customers
  - GET /api/customers/{id}
  - POST /api/customers
  - PUT /api/customers/{id}
  - _Requirements: 11.1_

- [ ]* 15.9 Write unit tests for customer commands/queries
  - Test customer creation with valid data
  - Test customer code generation
  - Test statistics auto-update
  - Test search functionality
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ]* 15.10 Test phone/email uniqueness validation
  - Test phone uniqueness within same agency
  - Test email uniqueness within same agency
  - Test phone can be same across different agencies
  - Test email can be same across different agencies
  - _Requirements: 11.3, 11.4_

### 16. Booking Creation (Req 12)

- [ ] 16.1 Create CreateBookingCommand and handler
  - Generate unique booking_reference in format BKG-YYYY-XXXX
  - Validate package_id, journey_id, customer_id, total_pax are provided
  - Calculate total_amount as package selling_price × total_pax
  - Set booking_status to 'pending'
  - Set booking_source (staff, phone, walk_in, whatsapp)
  - _Requirements: 12.1, 12.2, 12.3, 12.4_

- [ ] 16.2 Implement booking reference generation (BKG-YYYY-XXXX)
  - Use current year for YYYY
  - Generate sequential XXXX per year
  - Ensure uniqueness
  - _Requirements: 12.1_

- [ ] 16.3 Implement total amount calculation
  - Get package selling_price
  - Multiply by total_pax
  - Store in booking total_amount
  - _Requirements: 12.3_

- [ ] 16.4 Create GetBookingsQuery and handler with filtering
  - Support filtering by status, journey_id, customer_id
  - Support date range filtering
  - Support pagination
  - Return booking with package, journey, customer details
  - _Requirements: 12.1_

- [ ] 16.5 Create GetBookingByIdQuery and handler
  - Return booking details
  - Include package and journey information
  - Include customer information
  - Include travelers list
  - Include documents list
  - Include tasks list
  - Include payment schedules
  - _Requirements: 12.1_

- [ ] 16.6 Create booking DTOs and validators
  - CreateBookingDto with required fields
  - Validate package_id exists
  - Validate journey_id exists and belongs to package
  - Validate customer_id exists
  - Validate total_pax > 0
  - Validate booking_source enum values
  - _Requirements: 12.2, 12.5_

- [ ] 16.7 Create booking API endpoints
  - GET /api/bookings
  - GET /api/bookings/{id}
  - POST /api/bookings
  - _Requirements: 12.1, 12.4_

- [ ]* 16.8 Write unit tests for booking commands/queries
  - Test booking creation with valid data
  - Test booking reference generation
  - Test total amount calculation
  - Test validation failures
  - Test booking_source values
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

### 17. Booking Approval & Quota (Req 13)

- [ ] 17.1 Create ApproveBookingCommand and handler
  - Update booking_status to 'confirmed'
  - Record approved_at timestamp
  - Record approved_by user ID
  - Decrement journey available_quota by booking total_pax
  - Increment journey confirmed_pax by booking total_pax
  - Validate available_quota >= total_pax before approval
  - Trigger document checklist auto-generation (Req 15)
  - Trigger task checklist auto-generation (Req 17)
  - Trigger payment schedule auto-generation (Req 23)
  - _Requirements: 13.1, 13.2, 13.3, 13.4_

- [ ] 17.2 Create CancelBookingCommand and handler
  - Update booking_status to 'cancelled'
  - Record cancelled_at timestamp
  - Record cancelled_by user ID
  - Require cancellation_reason
  - Increment journey available_quota by booking total_pax
  - Decrement journey confirmed_pax by booking total_pax
  - _Requirements: 13.5_

- [ ] 17.3 Implement quota decrement on approval
  - Validate journey available_quota >= booking total_pax
  - Decrement journey.available_quota
  - Increment journey.confirmed_pax
  - Maintain invariant: total_quota = confirmed_pax + available_quota
  - Use database transaction for atomicity
  - _Requirements: 13.2, 13.3_

- [ ] 17.4 Implement quota increment on cancellation
  - Increment journey.available_quota by booking total_pax
  - Decrement journey.confirmed_pax by booking total_pax
  - Maintain invariant: total_quota = confirmed_pax + available_quota
  - Use database transaction for atomicity
  - _Requirements: 13.5_

- [ ] 17.5 Implement quota validation before approval
  - Check journey.available_quota >= booking.total_pax
  - Return error if insufficient quota
  - Prevent approval if quota insufficient
  - _Requirements: 13.4_

- [ ]* 17.6 Write unit tests for booking approval workflow
  - Test approval updates status and timestamps
  - Test quota decrement on approval
  - Test quota increment on cancellation
  - Test approval fails when insufficient quota
  - Test invariant maintained after operations
  - Test document/task/payment auto-generation triggered
  - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

- [ ]* 17.7 Test quota management edge cases
  - Test concurrent booking approvals
  - Test quota exactly equals total_pax
  - Test quota less than total_pax (should fail)
  - Test multiple cancellations restore quota correctly
  - Test invariant always holds
  - _Requirements: 13.2, 13.3, 13.4, 13.5_

### 18. Traveler Management (Req 14)

- [ ] 18.1 Create AddTravelerCommand and handler
  - Validate full_name, gender, date_of_birth are provided
  - Assign sequential traveler_number starting from 1
  - Validate mahram requirements for Umrah/Hajj packages
  - For female travelers > 12 years in Umrah/Hajj: require mahram_traveler_number
  - Validate mahram_traveler_number references existing male traveler
  - _Requirements: 14.1, 14.5_

- [ ] 18.2 Create UpdateTravelerCommand and handler
  - Allow updating traveler details
  - Re-validate mahram requirements if gender/age changes
  - Preserve traveler_number
  - _Requirements: 14.1_

- [ ] 18.3 Implement mahram validation logic
  - Check if package type is 'umrah' or 'hajj'
  - Calculate traveler age from date_of_birth
  - If female AND age > 12: require mahram_traveler_number
  - Validate mahram_traveler_number references existing traveler in same booking
  - Validate referenced traveler is male
  - _Requirements: 14.2, 14.3, 14.4_

- [ ] 18.4 Implement traveler number auto-assignment
  - Query max traveler_number for booking
  - Assign next sequential number (max + 1)
  - Start from 1 if no travelers exist
  - Ensure uniqueness within booking
  - _Requirements: 14.5_

- [ ] 18.5 Create traveler DTOs and validators
  - AddTravelerDto with required fields
  - UpdateTravelerDto with validation
  - Validate gender enum values (male, female)
  - Validate date_of_birth is in the past
  - Validate mahram_traveler_number if required
  - _Requirements: 14.1, 14.3_

- [ ] 18.6 Create traveler API endpoints
  - GET /api/bookings/{bookingId}/travelers
  - GET /api/bookings/{bookingId}/travelers/{id}
  - POST /api/bookings/{bookingId}/travelers
  - PUT /api/bookings/{bookingId}/travelers/{id}
  - DELETE /api/bookings/{bookingId}/travelers/{id}
  - _Requirements: 14.1_

- [ ]* 18.7 Write unit tests for traveler commands
  - Test traveler creation with valid data
  - Test traveler_number auto-assignment
  - Test mahram validation for Umrah packages
  - Test mahram validation for Hajj packages
  - Test mahram validation NOT required for other package types
  - Test female > 12 requires mahram
  - Test female <= 12 does NOT require mahram
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_

- [ ]* 18.8 Test mahram validation for Umrah/Hajj packages
  - Test female traveler > 12 without mahram fails
  - Test female traveler > 12 with valid mahram succeeds
  - Test mahram must be male
  - Test mahram must exist in same booking
  - Test male travelers don't need mahram
  - Test female travelers <= 12 don't need mahram
  - _Requirements: 14.2, 14.3, 14.4_


---

## Week 6: Document & Task Management (Mar 23 - Mar 29)

### 19. Document Checklist Auto-Generation (Req 15)

- [ ] 19.1 Implement document auto-generation on booking confirmation
  - Trigger on booking status change to 'confirmed'
  - Query document_types filtered by package type
  - For each traveler in booking, create document records for required types
  - Set initial status to 'not_submitted'
  - Link documents to booking_id and traveler_id
  - _Requirements: 15.1, 15.2, 15.3_

- [ ] 19.2 Create GetBookingDocumentsQuery and handler
  - Accept booking_id as parameter
  - Return all documents grouped by traveler
  - Include document_type details
  - Include status and verification info
  - Support filtering by status
  - _Requirements: 15.1_

- [ ] 19.3 Implement document completion percentage calculation
  - Count total required documents for booking
  - Count verified documents (status = 'verified')
  - Calculate percentage: (verified / total) × 100
  - Return as integer percentage
  - _Requirements: 15.4_

- [ ] 19.4 Create GetIncompleteDocumentsQuery and handler
  - Filter documents where status NOT IN ('verified')
  - Support filtering by booking_id
  - Support filtering by traveler_id
  - Return documents with traveler and booking info
  - _Requirements: 15.4_

- [ ] 19.5 Create GetExpiringDocumentsQuery and handler
  - Filter documents where expiry_date < today + 30 days
  - Filter documents where expiry_date IS NOT NULL
  - Exclude expired documents (expiry_date < today)
  - Return documents with days_until_expiry calculated
  - Support pagination
  - _Requirements: 15.5_

- [ ] 19.6 Create document DTOs
  - DocumentDto with all fields
  - DocumentCompletionDto with percentage
  - ExpiringDocumentDto with days_until_expiry
  - Validate status enum values
  - _Requirements: 15.1, 15.4, 15.5_

- [ ] 19.7 Create document query API endpoints
  - GET /api/bookings/{bookingId}/documents
  - GET /api/bookings/{bookingId}/documents/completion
  - GET /api/documents/incomplete
  - GET /api/documents/expiring
  - _Requirements: 15.1, 15.4, 15.5_

- [ ]* 19.8 Write unit tests for document auto-generation
  - Test documents created for all travelers
  - Test only required document types for package type
  - Test initial status is 'not_submitted'
  - Test completion percentage calculation
  - _Requirements: 15.1, 15.2, 15.3, 15.4_

- [ ]* 19.9 Test document type filtering by package type
  - Test umrah package generates umrah-specific documents
  - Test hajj package generates hajj-specific documents
  - Test general_tour generates standard documents
  - _Requirements: 15.2_

### 20. Document Status Tracking (Req 16)

- [ ] 20.1 Create UpdateDocumentStatusCommand and handler
  - Accept document_id, status, document_number, expiry_date, rejection_reason
  - Validate status enum values (not_submitted, submitted, verified, rejected, expired)
  - When status = 'submitted': require document_number
  - When status = 'rejected': require rejection_reason
  - Update status and record timestamps
  - _Requirements: 16.1, 16.2, 16.4_

- [ ] 20.2 Create VerifyDocumentCommand and handler
  - Update status to 'verified'
  - Record verified_by user ID from JWT
  - Record verified_at timestamp
  - Validate document has document_number and expiry_date
  - Trigger expiry validation based on document type
  - _Requirements: 16.3_

- [ ] 20.3 Implement passport expiry validation (6 months rule)
  - Get journey departure_date from booking
  - Calculate minimum_expiry_date = departure_date + 6 months
  - Validate expiry_date >= minimum_expiry_date
  - Return error if validation fails
  - Apply only to passport document types
  - _Requirements: 16.5_

- [ ] 20.4 Implement visa expiry validation
  - Get journey departure_date from booking
  - Validate expiry_date > departure_date
  - Return error if validation fails
  - Apply only to visa document types
  - _Requirements: 16.6_

- [ ] 20.5 Create document DTOs and validators
  - UpdateDocumentStatusDto with status and optional fields
  - VerifyDocumentDto with verification fields
  - Validate status transitions
  - Validate document_number format
  - Validate expiry_date is in the future
  - _Requirements: 16.1, 16.2, 16.3, 16.4_

- [ ] 20.6 Create document update API endpoints
  - PATCH /api/documents/{id}/status
  - PATCH /api/documents/{id}/verify
  - PATCH /api/documents/{id}/reject
  - _Requirements: 16.2, 16.3, 16.4_

- [ ]* 20.7 Write unit tests for document commands
  - Test status update with valid data
  - Test verification workflow
  - Test rejection requires reason
  - Test passport expiry validation
  - Test visa expiry validation
  - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.6_

- [ ]* 20.8 Test expiry validation logic
  - Test passport must be valid 6 months after departure
  - Test visa must be valid on departure date
  - Test validation only applies to relevant document types
  - Test error messages are clear
  - _Requirements: 16.5, 16.6_

### 21. Task Checklist Auto-Generation (Req 17)

- [ ] 21.1 Implement task auto-generation on booking confirmation
  - Trigger on booking status change to 'confirmed'
  - Query task_templates where trigger_stage = 'after_booking'
  - For each template, create task record
  - Calculate due_date = booking.created_at + template.due_days_offset
  - Set initial status to 'to_do'
  - Link tasks to booking_id
  - Copy template title and description
  - _Requirements: 17.1, 17.2, 17.3_

- [ ] 21.2 Implement due date calculation from template offset
  - Get booking created_at timestamp
  - Add template due_days_offset (can be positive or negative)
  - Store calculated due_date
  - Handle edge cases (weekends, holidays if needed)
  - _Requirements: 17.2_

- [ ] 21.3 Create GetTasksQuery and handler with filtering
  - Support filtering by status (to_do, in_progress, done)
  - Support filtering by assigned_to user ID
  - Support filtering by due_date range
  - Support filtering by booking_id
  - Support pagination
  - Return tasks with booking and assignee info
  - _Requirements: 19.4_

- [ ] 21.4 Create GetBookingTasksQuery and handler
  - Accept booking_id as parameter
  - Return all tasks for the booking
  - Include template information
  - Include assignee information
  - Order by due_date ascending
  - _Requirements: 17.1_

- [ ] 21.5 Implement task completion percentage calculation
  - Count total tasks for booking
  - Count completed tasks (status = 'done')
  - Calculate percentage: (completed / total) × 100
  - Return as integer percentage
  - _Requirements: 17.5_

- [ ] 21.6 Create task DTOs
  - TaskDto with all fields
  - TaskCompletionDto with percentage
  - Validate status enum values (to_do, in_progress, done)
  - Validate trigger_stage enum values
  - _Requirements: 17.3, 17.4_

- [ ] 21.7 Create task query API endpoints
  - GET /api/tasks
  - GET /api/bookings/{bookingId}/tasks
  - GET /api/bookings/{bookingId}/tasks/completion
  - _Requirements: 17.1, 17.5_

- [ ]* 21.8 Write unit tests for task auto-generation
  - Test tasks created from templates
  - Test due_date calculation accuracy
  - Test initial status is 'to_do'
  - Test completion percentage calculation
  - Test only after_booking templates are used
  - _Requirements: 17.1, 17.2, 17.3, 17.5_

- [ ]* 21.9 Test task template filtering by trigger stage
  - Test after_booking templates trigger on confirmation
  - Test h_30 templates do NOT trigger on confirmation
  - Test h_7 templates do NOT trigger on confirmation
  - _Requirements: 17.1_

### 22. Task Management (Req 19)

- [ ] 22.1 Create CreateTaskCommand and handler (custom tasks)
  - Accept booking_id, title, description, due_date, assigned_to
  - Set status to 'to_do' by default
  - Set is_custom to true (to distinguish from template tasks)
  - Validate booking_id exists
  - Validate assigned_to user exists (if provided)
  - _Requirements: 19.5_

- [ ] 22.2 Create UpdateTaskStatusCommand and handler
  - Accept task_id and new status
  - Validate status enum values (to_do, in_progress, done)
  - Allow status transitions: to_do → in_progress → done
  - Allow backward transitions for corrections
  - Update updated_at timestamp
  - _Requirements: 19.2_

- [ ] 22.3 Create AssignTaskCommand and handler
  - Accept task_id and assigned_to user ID
  - Validate user exists and belongs to same agency
  - Update assigned_to field
  - Record assignment timestamp
  - Send notification to assigned user
  - _Requirements: 19.1_

- [ ] 22.4 Create CompleteTaskCommand and handler
  - Update status to 'done'
  - Record completed_at timestamp
  - Record completed_by user ID from JWT
  - Validate task is not already completed
  - Update task completion percentage for booking
  - _Requirements: 19.2_

- [ ] 22.5 Create GetMyTasksQuery and handler
  - Filter tasks where assigned_to = current user ID
  - Support filtering by status
  - Support filtering by due_date range
  - Order by due_date ascending
  - Include booking information
  - Support pagination
  - _Requirements: 19.1, 19.4_

- [ ] 22.6 Create GetOverdueTasksQuery and handler
  - Filter tasks where due_date < today
  - Filter tasks where status != 'done'
  - Support filtering by assigned_to
  - Support filtering by booking_id
  - Order by due_date ascending (oldest first)
  - Include booking and assignee info
  - _Requirements: 19.3_

- [ ] 22.7 Create task DTOs and validators
  - CreateTaskDto with required fields
  - UpdateTaskStatusDto with status validation
  - AssignTaskDto with user validation
  - Validate due_date is not in the past (for new tasks)
  - Validate status transitions
  - _Requirements: 19.1, 19.2, 19.5_

- [ ] 22.8 Create task management API endpoints
  - POST /api/tasks (create custom task)
  - PATCH /api/tasks/{id}/status
  - PATCH /api/tasks/{id}/assign
  - PATCH /api/tasks/{id}/complete
  - GET /api/tasks/my-tasks
  - GET /api/tasks/overdue
  - _Requirements: 19.1, 19.2, 19.3, 19.5_

- [ ]* 22.9 Write unit tests for task commands
  - Test custom task creation
  - Test status updates
  - Test task assignment
  - Test task completion with timestamps
  - Test overdue task identification
  - _Requirements: 19.1, 19.2, 19.3, 19.5_

- [ ]* 22.10 Test task assignment validation
  - Test user must exist
  - Test user must belong to same agency
  - Test notification is sent to assigned user
  - _Requirements: 19.1_


---

## Week 7: Notifications & Payments (Mar 30 - Apr 5)

### 23. Notification Scheduling (Req 20)

- [ ] 23.1 Create CreateNotificationScheduleCommand and handler
  - Accept name, trigger_days_before, template_id, is_active
  - Validate trigger_days_before values (30, 14, 7, 3, 1)
  - Validate template_id exists
  - Set is_active to true by default
  - Link to agency_id from JWT
  - _Requirements: 20.1, 20.2, 20.3_

- [ ] 23.2 Create UpdateNotificationScheduleCommand and handler
  - Allow updating name, trigger_days_before, template_id, is_active
  - Validate trigger_days_before values
  - Validate template_id exists
  - _Requirements: 20.2, 20.3_

- [ ] 23.3 Create GetNotificationSchedulesQuery and handler
  - Filter by agency_id from JWT
  - Support filtering by is_active
  - Include template details in response
  - Order by trigger_days_before descending
  - _Requirements: 20.1, 20.2_

- [ ] 23.4 Create GetNotificationTemplatesQuery and handler
  - Return all available templates
  - Include template variables list
  - Support filtering by template type
  - _Requirements: 20.4_

- [ ] 23.5 Implement template variable replacement logic
  - Support variables: {{customer_name}}, {{package_name}}, {{departure_date}}, {{booking_reference}}
  - Replace variables in both subject and body
  - Get values from booking and related entities
  - Handle missing values gracefully (use empty string or default)
  - _Requirements: 20.5_

- [ ] 23.6 Create notification DTOs and validators
  - CreateNotificationScheduleDto with required fields
  - UpdateNotificationScheduleDto with validation
  - NotificationTemplateDto with variables list
  - Validate trigger_days_before enum values
  - _Requirements: 20.1, 20.2, 20.5_

- [ ] 23.7 Create notification schedule API endpoints
  - GET /api/notification-schedules
  - GET /api/notification-schedules/{id}
  - POST /api/notification-schedules
  - PUT /api/notification-schedules/{id}
  - GET /api/notification-templates
  - _Requirements: 20.1, 20.4_

- [ ]* 23.8 Write unit tests for notification commands
  - Test schedule creation with valid data
  - Test trigger_days_before validation
  - Test template variable replacement
  - Test is_active toggle
  - _Requirements: 20.1, 20.2, 20.3, 20.5_

- [ ]* 23.9 Test template rendering with variables
  - Test all supported variables are replaced
  - Test missing variables don't break rendering
  - Test special characters in values are handled
  - _Requirements: 20.5_

### 24. Daily Notification Job (Req 21)

- [ ] 24.1 Install and configure Hangfire
  - Add Hangfire NuGet packages
  - Configure Hangfire with PostgreSQL storage
  - Setup Hangfire dashboard at /hangfire
  - Configure authentication for dashboard
  - _Requirements: 37.1_

- [ ] 24.2 Create DailyNotificationJob class
  - Implement IJob interface or use Hangfire method
  - Inject required services (DbContext, NotificationService)
  - Implement job execution logic
  - Add error handling and logging
  - _Requirements: 21.1, 37.2_

- [ ] 24.3 Implement days_before_departure calculation
  - For each confirmed booking, get journey.departure_date
  - Calculate days_before = departure_date - today
  - Match against notification schedules trigger_days_before
  - Only process bookings where match exists
  - _Requirements: 21.2_

- [ ] 24.4 Implement notification log creation
  - For each matched booking and schedule
  - Create notification_log record
  - Set status to 'pending'
  - Store rendered subject and body (with variables replaced)
  - Link to booking_id, schedule_id, customer_id
  - _Requirements: 21.3, 21.4_

- [ ] 24.5 Implement email sending service (mock for Phase 1)
  - Create IEmailService interface
  - Implement mock EmailService that logs to console
  - Accept recipient, subject, body parameters
  - Return success/failure status
  - Log email details for debugging
  - _Requirements: 21.5_

- [ ] 24.6 Implement in-app notification service
  - Create in_app_notifications table record
  - Link to user_id (customer's user account if exists)
  - Set is_read to false
  - Store notification title and message
  - _Requirements: 21.5_

- [ ] 24.7 Schedule job to run daily at 09:00 AM
  - Use Hangfire RecurringJob.AddOrUpdate
  - Set cron expression for 09:00 AM daily
  - Configure timezone handling
  - _Requirements: 21.1, 37.2_

- [ ] 24.8 Create job logging
  - Log job start and completion
  - Log number of notifications processed
  - Log any errors encountered
  - Track job execution time
  - _Requirements: 21.1_

- [ ]* 24.9 Write unit tests for notification job
  - Test days_before_departure calculation
  - Test notification log creation
  - Test template variable replacement
  - Test job processes correct bookings
  - _Requirements: 21.1, 21.2, 21.3, 21.4, 21.5_

- [ ]* 24.10 Test notification trigger matching
  - Test H-30 notifications trigger 30 days before
  - Test H-7 notifications trigger 7 days before
  - Test no duplicate notifications sent
  - _Requirements: 21.2, 21.3_

### 25. Notification Retry Mechanism (Req 22)

- [ ] 25.1 Create NotificationRetryJob class
  - Implement IJob interface or use Hangfire method
  - Inject required services (DbContext, NotificationService)
  - Query failed notifications for retry
  - Implement retry logic with attempt tracking
  - _Requirements: 22.2, 37.3_

- [ ] 25.2 Implement retry logic with 3-attempt limit
  - Query notification_logs where status = 'failed' AND retry_count < 3
  - For each notification, attempt to resend
  - Increment retry_count on each attempt
  - Update status based on send result
  - _Requirements: 22.2, 22.3_

- [ ] 25.3 Implement error message recording
  - When send fails, capture exception message
  - Store in error_message field
  - Include timestamp of failure
  - Preserve error history across retries
  - _Requirements: 22.1_

- [ ] 25.4 Schedule job to run hourly
  - Use Hangfire RecurringJob.AddOrUpdate
  - Set cron expression for every hour
  - Configure timezone handling
  - _Requirements: 22.2, 37.3_

- [ ] 25.5 Create GetNotificationLogsQuery and handler
  - Support filtering by status (pending, sent, failed, failed_permanently)
  - Support filtering by booking_id
  - Support filtering by date range
  - Include retry_count and error_message
  - Support pagination
  - _Requirements: 22.1, 22.4, 22.5_

- [ ] 25.6 Create notification log API endpoints
  - GET /api/notification-logs
  - GET /api/notification-logs/{id}
  - GET /api/bookings/{bookingId}/notification-logs
  - _Requirements: 22.1_

- [ ]* 25.7 Write unit tests for retry job
  - Test retry logic processes failed notifications
  - Test retry_count increments correctly
  - Test status changes to 'sent' on success
  - Test status changes to 'failed_permanently' after 3 attempts
  - Test error_message is recorded
  - _Requirements: 22.1, 22.2, 22.3, 22.4, 22.5_

- [ ]* 25.8 Test retry count increment
  - Test retry_count starts at 0
  - Test retry_count increments on each failure
  - Test no retry after retry_count reaches 3
  - _Requirements: 22.3_

### 26. Payment Schedule Auto-Generation (Req 23)

- [ ] 26.1 Implement payment schedule auto-generation on booking confirmation
  - Trigger on booking status change to 'confirmed'
  - Create 3 payment schedule records
  - Calculate amounts based on booking total_amount
  - Set initial status to 'pending' for all schedules
  - _Requirements: 23.1_

- [ ] 26.2 Implement DP due date calculation (booking date + 3 days)
  - Get booking created_at date
  - Add 3 days to get DP due_date
  - Set schedule_name to 'DP (Down Payment)'
  - Calculate amount as total_amount × 40%
  - _Requirements: 23.1, 23.2, 23.5_

- [ ] 26.3 Implement Installment 1 due date (departure - 60 days)
  - Get journey departure_date
  - Subtract 60 days to get due_date
  - Set schedule_name to 'Installment 1'
  - Calculate amount as total_amount × 30%
  - _Requirements: 23.1, 23.3, 23.5_

- [ ] 26.4 Implement Installment 2 due date (departure - 30 days)
  - Get journey departure_date
  - Subtract 30 days to get due_date
  - Set schedule_name to 'Installment 2'
  - Calculate amount as total_amount × 30%
  - _Requirements: 23.1, 23.4, 23.5_

- [ ] 26.5 Implement installment amount calculation (40%, 30%, 30%)
  - DP amount = total_amount × 0.40
  - Installment 1 amount = total_amount × 0.30
  - Installment 2 amount = total_amount × 0.30
  - Round amounts to 2 decimal places
  - Ensure sum equals total_amount (handle rounding differences)
  - _Requirements: 23.5_

- [ ] 26.6 Create GetPaymentSchedulesQuery and handler
  - Accept booking_id as parameter
  - Return all payment schedules for booking
  - Include paid_amount and status
  - Order by due_date ascending
  - Calculate outstanding_amount (amount - paid_amount)
  - _Requirements: 23.1_

- [ ] 26.7 Create payment schedule DTOs
  - PaymentScheduleDto with all fields
  - Include outstanding_amount calculated field
  - Validate status enum values (pending, partially_paid, paid)
  - _Requirements: 23.1_

- [ ]* 26.8 Write unit tests for payment schedule generation
  - Test 3 schedules are created
  - Test amounts sum to total_amount
  - Test percentages are correct (40%, 30%, 30%)
  - Test initial status is 'pending'
  - _Requirements: 23.1, 23.5_

- [ ]* 26.9 Test due date calculations
  - Test DP due_date = booking date + 3 days
  - Test Installment 1 due_date = departure - 60 days
  - Test Installment 2 due_date = departure - 30 days
  - _Requirements: 23.2, 23.3, 23.4_

### 27. Payment Recording (Req 24)

- [ ] 27.1 Create RecordPaymentCommand and handler
  - Accept payment_schedule_id, amount, payment_date, payment_method, reference_number
  - Validate amount > 0
  - Validate payment_schedule exists
  - Create payment_transaction record
  - Update payment_schedule paid_amount
  - Recalculate payment_schedule status
  - _Requirements: 24.1, 24.2_

- [ ] 27.2 Implement paid_amount update logic
  - Get current paid_amount from payment_schedule
  - Add new payment amount to paid_amount
  - Update payment_schedule.paid_amount
  - Use database transaction for atomicity
  - _Requirements: 24.2_

- [ ] 27.3 Implement payment status calculation
  - IF paid_amount >= amount: set status to 'paid' and record paid_date
  - ELSE IF paid_amount > 0 AND paid_amount < amount: set status to 'partially_paid'
  - ELSE: keep status as 'pending'
  - Update status automatically after each payment
  - _Requirements: 24.3, 24.4_

- [ ] 27.4 Create GetOutstandingPaymentsQuery and handler
  - Filter payment_schedules where status IN ('pending', 'partially_paid')
  - Calculate outstanding_amount (amount - paid_amount)
  - Support filtering by booking_id
  - Support filtering by customer_id
  - Order by due_date ascending
  - Include booking and customer info
  - _Requirements: 24.4_

- [ ] 27.5 Create GetOverduePaymentsQuery and handler
  - Filter payment_schedules where due_date < today
  - Filter where status IN ('pending', 'partially_paid')
  - Calculate days_overdue (today - due_date)
  - Calculate outstanding_amount
  - Order by days_overdue descending (most overdue first)
  - Include booking and customer info
  - _Requirements: 24.5_

- [ ] 27.6 Create payment DTOs and validators
  - RecordPaymentDto with required fields
  - PaymentTransactionDto with all fields
  - OutstandingPaymentDto with calculated fields
  - OverduePaymentDto with days_overdue
  - Validate amount is positive
  - Validate payment_date is not in future
  - Validate payment_method enum values
  - _Requirements: 24.1, 24.2_

- [ ] 27.7 Create payment API endpoints
  - POST /api/payment-schedules/{id}/payments
  - GET /api/payment-schedules/{id}/transactions
  - GET /api/payments/outstanding
  - GET /api/payments/overdue
  - GET /api/bookings/{bookingId}/payments
  - _Requirements: 24.1, 24.5_

- [ ]* 27.8 Write unit tests for payment commands
  - Test payment recording with valid data
  - Test paid_amount accumulation
  - Test status transitions (pending → partially_paid → paid)
  - Test paid_date is set when fully paid
  - Test overdue payment identification
  - _Requirements: 24.1, 24.2, 24.3, 24.4, 24.5_

- [ ]* 27.9 Test payment status transitions
  - Test status remains 'pending' when paid_amount = 0
  - Test status changes to 'partially_paid' when 0 < paid_amount < amount
  - Test status changes to 'paid' when paid_amount >= amount
  - Test overpayment is allowed (paid_amount > amount)
  - _Requirements: 24.3, 24.4_


---

## Week 8: Itinerary, Supplier Bills & Communication (Apr 6 - Apr 12)

### 28. Itinerary Builder (Req 25)

- [ ] 28.1 Create CreateItineraryCommand and handler
  - Accept package_id
  - Validate package exists and belongs to agency
  - Validate only one itinerary per package
  - Create itinerary record linked to package_id
  - Set created_by from JWT
  - _Requirements: 25.1_

- [ ] 28.2 Create AddItineraryDayCommand and handler
  - Accept itinerary_id, day_number, title, description
  - Validate itinerary exists
  - Assign sequential day_number (auto-increment if not provided)
  - Validate day_number is unique within itinerary
  - Create itinerary_day record
  - _Requirements: 25.2, 25.3_

- [ ] 28.3 Create UpdateItineraryDayCommand and handler
  - Accept itinerary_day_id, title, description
  - Allow updating title and description
  - Preserve day_number (cannot be changed)
  - Validate itinerary_day exists
  - _Requirements: 25.3_

- [ ] 28.4 Create DeleteItineraryDayCommand and handler
  - Accept itinerary_day_id
  - Soft delete or hard delete itinerary_day
  - Cascade delete all activities for that day
  - Optionally reorder remaining days
  - _Requirements: 25.2_

- [ ] 28.5 Create AddItineraryActivityCommand and handler
  - Accept itinerary_day_id, time, location, activity, meal_type
  - Validate itinerary_day exists
  - Validate meal_type enum values (breakfast, lunch, dinner, snack, none)
  - Create itinerary_activity record
  - Order activities by time within day
  - _Requirements: 25.4, 25.5_

- [ ] 28.6 Create UpdateItineraryActivityCommand and handler
  - Accept activity_id, time, location, activity, meal_type
  - Allow updating all activity fields
  - Validate meal_type enum values
  - _Requirements: 25.4, 25.5_

- [ ] 28.7 Create DeleteItineraryActivityCommand and handler
  - Accept activity_id
  - Delete itinerary_activity record
  - _Requirements: 25.4_

- [ ] 28.8 Create GetItineraryByPackageIdQuery and handler
  - Accept package_id
  - Return itinerary with all days and activities
  - Order days by day_number ascending
  - Order activities by time within each day
  - Include package information
  - _Requirements: 25.1, 25.2, 25.4_

- [ ] 28.9 Create itinerary DTOs and validators
  - CreateItineraryDto with package_id
  - ItineraryDayDto with day_number, title, description
  - ItineraryActivityDto with time, location, activity, meal_type
  - Validate meal_type enum values
  - Validate time format (HH:mm)
  - _Requirements: 25.3, 25.4, 25.5_

- [ ] 28.10 Create itinerary API endpoints
  - POST /api/packages/{packageId}/itinerary
  - GET /api/packages/{packageId}/itinerary
  - POST /api/itineraries/{id}/days
  - PUT /api/itinerary-days/{id}
  - DELETE /api/itinerary-days/{id}
  - POST /api/itinerary-days/{id}/activities
  - PUT /api/itinerary-activities/{id}
  - DELETE /api/itinerary-activities/{id}
  - _Requirements: 25.1, 25.2, 25.3, 25.4_

- [ ]* 28.11 Write unit tests for itinerary commands
  - Test itinerary creation
  - Test day creation with sequential numbering
  - Test activity creation with meal types
  - Test day and activity updates
  - Test cascade delete of activities when day is deleted
  - _Requirements: 25.1, 25.2, 25.3, 25.4, 25.5_

- [ ]* 28.12 Test one-itinerary-per-package constraint
  - Test creating second itinerary for same package fails
  - Test error message is clear
  - _Requirements: 25.1_

### 29. Supplier Bill Auto-Generation (Req 26)

- [ ] 29.1 Implement supplier bill auto-generation on PO approval
  - Trigger when purchase_order status changes to 'approved'
  - Create supplier_bill record automatically
  - Link to purchase_order_id and supplier_id
  - Set bill_date to PO approval date
  - Set initial status to 'unpaid'
  - _Requirements: 26.1, 26.3_

- [ ] 29.2 Implement bill number generation (BILL-YYMMDD-XXX)
  - Use current date for YYMMDD
  - Generate sequential XXX per day
  - Ensure uniqueness across all bills
  - Format: BILL-260218-001
  - _Requirements: 26.2_

- [ ] 29.3 Implement due date calculation (bill date + 30 days)
  - Get bill_date (PO approval date)
  - Add 30 days to calculate due_date
  - Store due_date in supplier_bill
  - _Requirements: 26.4_

- [ ] 29.4 Create GetSupplierBillsQuery and handler
  - Support filtering by supplier_id
  - Support filtering by status (unpaid, partially_paid, paid)
  - Support filtering by date range
  - Include purchase_order and supplier info
  - Calculate outstanding_amount (total_amount - paid_amount)
  - Support pagination
  - _Requirements: 26.1_

- [ ] 29.5 Create GetOutstandingPayablesQuery and handler
  - Filter supplier_bills where status IN ('unpaid', 'partially_paid')
  - Calculate outstanding_amount for each bill
  - Support filtering by supplier_id
  - Order by due_date ascending
  - Include supplier information
  - _Requirements: 27.5_

- [ ] 29.6 Create supplier bill DTOs
  - SupplierBillDto with all fields
  - Include outstanding_amount calculated field
  - Include days_until_due or days_overdue
  - Validate status enum values
  - _Requirements: 26.1, 26.5_

- [ ] 29.7 Create supplier bill query API endpoints
  - GET /api/supplier-bills
  - GET /api/supplier-bills/{id}
  - GET /api/suppliers/{supplierId}/bills
  - GET /api/supplier-bills/outstanding
  - _Requirements: 26.1_

- [ ]* 29.8 Write unit tests for bill auto-generation
  - Test bill is created on PO approval
  - Test bill_number generation
  - Test due_date calculation (bill_date + 30 days)
  - Test total_amount equals PO total_amount
  - Test initial status is 'unpaid'
  - _Requirements: 26.1, 26.2, 26.3, 26.4, 26.5_

- [ ]* 29.9 Test bill amount equals PO amount
  - Test supplier_bill.total_amount = purchase_order.total_amount
  - Test amount is copied correctly
  - _Requirements: 26.5_

### 30. Supplier Payment Recording (Req 27)

- [ ] 30.1 Create RecordSupplierPaymentCommand and handler
  - Accept supplier_bill_id, amount, payment_date, payment_method, reference_number
  - Validate amount > 0
  - Validate supplier_bill exists
  - Create supplier_payment record
  - Update supplier_bill paid_amount
  - Recalculate supplier_bill status
  - _Requirements: 27.1, 27.2_

- [ ] 30.2 Implement paid_amount update logic
  - Get current paid_amount from supplier_bill
  - Add new payment amount to paid_amount
  - Update supplier_bill.paid_amount
  - Use database transaction for atomicity
  - _Requirements: 27.2_

- [ ] 30.3 Implement bill status calculation
  - IF paid_amount >= total_amount: set status to 'paid'
  - ELSE IF paid_amount > 0 AND paid_amount < total_amount: set status to 'partially_paid'
  - ELSE: keep status as 'unpaid'
  - Update status automatically after each payment
  - _Requirements: 27.3, 27.4_

- [ ] 30.4 Create supplier payment DTOs and validators
  - RecordSupplierPaymentDto with required fields
  - SupplierPaymentDto with all fields
  - Validate amount is positive
  - Validate payment_date is not in future
  - Validate payment_method enum values (bank_transfer, cash, check, other)
  - _Requirements: 27.1, 27.2_

- [ ] 30.5 Create supplier payment API endpoints
  - POST /api/supplier-bills/{id}/payments
  - GET /api/supplier-bills/{id}/payments
  - GET /api/supplier-payments
  - GET /api/suppliers/{supplierId}/payments
  - _Requirements: 27.1_

- [ ]* 30.6 Write unit tests for supplier payment commands
  - Test payment recording with valid data
  - Test paid_amount accumulation
  - Test status transitions (unpaid → partially_paid → paid)
  - Test overdue bill identification
  - _Requirements: 27.1, 27.2, 27.3, 27.4, 27.5_

- [ ]* 30.7 Test payment status transitions
  - Test status remains 'unpaid' when paid_amount = 0
  - Test status changes to 'partially_paid' when 0 < paid_amount < total_amount
  - Test status changes to 'paid' when paid_amount >= total_amount
  - Test overpayment is allowed
  - _Requirements: 27.3, 27.4_

### 31. Communication Log (Req 28)

- [ ] 31.1 Create CreateCommunicationLogCommand and handler
  - Accept customer_id, communication_type, notes, booking_id (optional), follow_up_required, follow_up_date
  - Validate customer exists and belongs to agency
  - Validate communication_type enum values (call, email, whatsapp, meeting, other)
  - If follow_up_required = true: require follow_up_date
  - Validate follow_up_date is in the future
  - Set created_by from JWT
  - _Requirements: 28.1, 28.2, 28.4_

- [ ] 31.2 Create UpdateCommunicationLogCommand and handler
  - Allow updating notes, follow_up_date, follow_up_done
  - Allow marking follow-up as done
  - Validate follow_up_date if provided
  - _Requirements: 28.5_

- [ ] 31.3 Create GetCommunicationLogsQuery and handler
  - Support filtering by customer_id
  - Support filtering by booking_id
  - Support filtering by communication_type
  - Support filtering by follow_up_required
  - Support filtering by follow_up_done
  - Order by created_at descending (most recent first)
  - Include customer and booking info
  - Support pagination
  - _Requirements: 28.1, 28.3_

- [ ] 31.4 Create GetFollowUpsQuery and handler
  - Filter where follow_up_required = true AND follow_up_done = false
  - Support filtering by follow_up_date range
  - Identify overdue follow-ups (follow_up_date < today)
  - Order by follow_up_date ascending
  - Include customer and booking info
  - _Requirements: 28.4, 28.5_

- [ ] 31.5 Create communication log DTOs and validators
  - CreateCommunicationLogDto with required fields
  - UpdateCommunicationLogDto with optional fields
  - CommunicationLogDto with all fields
  - FollowUpDto with follow-up specific fields
  - Validate communication_type enum values
  - Validate follow_up_date is future date when follow_up_required = true
  - _Requirements: 28.1, 28.2, 28.4_

- [ ] 31.6 Create communication log API endpoints
  - POST /api/communication-logs
  - PUT /api/communication-logs/{id}
  - GET /api/communication-logs
  - GET /api/customers/{customerId}/communication-logs
  - GET /api/bookings/{bookingId}/communication-logs
  - GET /api/communication-logs/follow-ups
  - PATCH /api/communication-logs/{id}/mark-follow-up-done
  - _Requirements: 28.1, 28.3, 28.5_

- [ ]* 31.7 Write unit tests for communication commands
  - Test log creation with valid data
  - Test communication_type validation
  - Test follow-up date validation
  - Test follow-up marking as done
  - Test overdue follow-up identification
  - _Requirements: 28.1, 28.2, 28.3, 28.4, 28.5_

- [ ]* 31.8 Test follow-up date validation
  - Test follow_up_date required when follow_up_required = true
  - Test follow_up_date must be in future
  - Test follow_up_date optional when follow_up_required = false
  - _Requirements: 28.4_

### 32. H-30 and H-7 Task Generation Jobs (Req 18)

- [ ] 32.1 Create GenerateH30TasksJob class
  - Implement IJob interface or use Hangfire method
  - Inject required services (DbContext)
  - Query bookings where departure_date = today + 30 days
  - Filter bookings with status = 'confirmed'
  - Generate tasks from templates with trigger_stage = 'h_30'
  - _Requirements: 18.1, 18.2, 37.4_

- [ ] 32.2 Create GenerateH7TasksJob class
  - Implement IJob interface or use Hangfire method
  - Inject required services (DbContext)
  - Query bookings where departure_date = today + 7 days
  - Filter bookings with status = 'confirmed'
  - Generate tasks from templates with trigger_stage = 'h_7'
  - _Requirements: 18.3, 18.4, 37.4_

- [ ] 32.3 Implement booking identification logic (departure date matching)
  - Calculate target_date = today + N days (30 or 7)
  - Query bookings JOIN journeys WHERE journey.departure_date = target_date
  - Filter WHERE booking.booking_status = 'confirmed'
  - Exclude bookings that already have H-30 or H-7 tasks generated
  - _Requirements: 18.1, 18.3_

- [ ] 32.4 Implement task generation from templates
  - Query task_templates WHERE trigger_stage = 'h_30' or 'h_7'
  - For each template and each identified booking:
    - Create task record
    - Set due_date = departure_date - template.due_days_offset
    - Set status = 'to_do'
    - Copy template title and description
    - Link to booking_id and template_id
  - _Requirements: 18.2, 18.4_

- [ ] 32.5 Schedule both jobs to run daily at 08:00 AM
  - Use Hangfire RecurringJob.AddOrUpdate for H-30 job
  - Use Hangfire RecurringJob.AddOrUpdate for H-7 job
  - Set cron expression for 08:00 AM daily
  - Configure timezone handling
  - _Requirements: 18.5, 37.4_

- [ ] 32.6 Create job logging
  - Log job start and completion
  - Log number of bookings identified
  - Log number of tasks generated
  - Log any errors encountered
  - Track job execution time
  - _Requirements: 18.5_

- [ ]* 32.7 Write unit tests for task generation jobs
  - Test H-30 job identifies correct bookings (30 days before departure)
  - Test H-7 job identifies correct bookings (7 days before departure)
  - Test tasks are generated from correct templates
  - Test due_date calculation is correct
  - Test no duplicate tasks are generated
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

- [ ]* 32.8 Test task generation for correct bookings
  - Test only confirmed bookings are processed
  - Test cancelled bookings are excluded
  - Test pending bookings are excluded
  - Test bookings with wrong departure dates are excluded
  - _Requirements: 18.1, 18.3_


---

## Week 9: B2B Marketplace & Profitability (Apr 13 - Apr 19)

### 33. Agency Service Publishing (Req 29)

- [ ] 33.1 Create PublishAgencyServiceCommand and handler
  - Accept purchase_order_id, reseller_price, total_quota, description
  - Validate purchase_order exists and is approved
  - Validate reseller_price > cost_price (from PO)
  - Validate minimum 5% markup
  - Calculate markup_percentage = ((reseller_price - cost_price) / cost_price) × 100
  - Initialize available_quota = total_quota
  - Set is_published = true
  - Record published_at timestamp
  - _Requirements: 29.1, 29.2, 29.3, 29.4, 29.5_

- [ ] 33.2 Implement markup percentage calculation
  - Get cost_price from purchase_order total_amount
  - Calculate markup_percentage = ((reseller_price - cost_price) / cost_price) × 100
  - Validate markup_percentage >= 5%
  - Store markup_percentage in agency_service
  - _Requirements: 29.2, 29.3_

- [ ] 33.3 Implement quota initialization logic
  - Set total_quota from input
  - Initialize available_quota = total_quota
  - Initialize reserved_quota = 0
  - Initialize sold_quota = 0
  - Initialize used_quota = 0
  - Maintain invariant: total_quota = used_quota + available_quota + reserved_quota + sold_quota
  - _Requirements: 29.4, 34.5_

- [ ] 33.4 Implement 5% minimum markup validation
  - Calculate markup_percentage
  - Validate markup_percentage >= 5.0
  - Return error if markup is less than 5%
  - Provide clear error message
  - _Requirements: 29.2_

- [ ] 33.5 Create UpdateAgencyServiceCommand and handler
  - Allow updating reseller_price, total_quota, description
  - Recalculate markup_percentage if reseller_price changes
  - Validate 5% minimum markup
  - Adjust available_quota if total_quota changes
  - _Requirements: 29.2, 29.3_

- [ ] 33.6 Create UnpublishAgencyServiceCommand and handler
  - Set is_published = false
  - Validate no pending orders exist
  - Prevent unpublishing if reserved_quota > 0
  - _Requirements: 34.4_

- [ ] 33.7 Create GetAgencyServicesQuery and handler
  - Filter by agency_id (seller agency)
  - Support filtering by is_published
  - Include purchase_order and service details
  - Calculate available_quota
  - Support pagination
  - _Requirements: 29.1_

- [ ] 33.8 Create agency service DTOs and validators
  - PublishAgencyServiceDto with required fields
  - AgencyServiceDto with all fields including quota breakdown
  - Validate reseller_price > cost_price
  - Validate total_quota > 0
  - Validate 5% minimum markup
  - _Requirements: 29.1, 29.2, 29.3, 29.4_

- [ ] 33.9 Create agency service API endpoints
  - POST /api/agency-services/publish
  - PUT /api/agency-services/{id}
  - PATCH /api/agency-services/{id}/unpublish
  - GET /api/agency-services (seller's own services)
  - GET /api/agency-services/{id}
  - _Requirements: 29.1, 29.5_

- [ ]* 33.10 Write unit tests for agency service commands
  - Test service publishing with valid data
  - Test 5% minimum markup validation
  - Test markup_percentage calculation
  - Test quota initialization
  - Test unpublish validation
  - _Requirements: 29.1, 29.2, 29.3, 29.4, 29.5_

- [ ]* 33.11 Test supplier name hiding logic
  - Test supplier_id is not exposed in marketplace API
  - Test supplier name is not exposed in marketplace API
  - Test only seller agency name is visible
  - _Requirements: 30.2, 30.3_

### 34. Marketplace Browsing (Req 30)

- [ ] 34.1 Create GetMarketplaceServicesQuery and handler
  - Filter agency_services WHERE is_published = true
  - Exclude services where agency_id = current user's agency (own services)
  - Filter WHERE available_quota > 0
  - Return services WITHOUT supplier_id or supplier name
  - Include seller agency name (Agency A)
  - Include service details and available_quota
  - _Requirements: 30.1, 30.2, 30.3, 30.4, 30.5_

- [ ] 34.2 Implement supplier name hiding in query results
  - Do NOT include supplier_id in response DTO
  - Do NOT include supplier name in response DTO
  - Do NOT join supplier table in query
  - Only expose seller agency information
  - _Requirements: 30.2, 30.3_

- [ ] 34.3 Implement filtering by service type, location, price
  - Support filtering by service_type (from linked supplier_service)
  - Support filtering by location
  - Support price range filtering (min_price, max_price)
  - Support filtering by available_quota > minimum
  - _Requirements: 30.4_

- [ ] 34.4 Implement search functionality
  - Support search by service name/description
  - Support search by location
  - Use case-insensitive search
  - Support partial matching
  - _Requirements: 30.4_

- [ ] 34.5 Implement pagination
  - Support page and page_size parameters
  - Return total count of results
  - Return total pages
  - Default page_size = 20
  - _Requirements: 30.4_

- [ ] 34.6 Create GetMarketplaceServiceByIdQuery and handler
  - Accept agency_service_id
  - Return service details WITHOUT supplier info
  - Include seller agency name
  - Include available_quota
  - Validate service is published
  - _Requirements: 30.1, 30.2, 30.3_

- [ ] 34.7 Create marketplace DTOs
  - MarketplaceServiceDto WITHOUT supplier fields
  - Include seller_agency_id and seller_agency_name
  - Include service_type, description, reseller_price, available_quota
  - Do NOT include cost_price or markup_percentage
  - _Requirements: 30.2, 30.3, 30.4_

- [ ] 34.8 Create marketplace API endpoints
  - GET /api/marketplace/services
  - GET /api/marketplace/services/{id}
  - Support query parameters for filtering and search
  - _Requirements: 30.1, 30.4_

- [ ]* 34.9 Write unit tests for marketplace queries
  - Test supplier info is hidden
  - Test own agency services are excluded
  - Test only published services are returned
  - Test filtering and search work correctly
  - Test pagination works correctly
  - _Requirements: 30.1, 30.2, 30.3, 30.4, 30.5_

- [ ]* 34.10 Test own-agency exclusion logic
  - Test Agency A cannot see their own published services in marketplace
  - Test Agency B can see Agency A's services
  - Test Agency C can see both Agency A and B's services
  - _Requirements: 30.1, 30.5_

### 35. Agency Order Creation (Req 31)

- [ ] 35.1 Create CreateAgencyOrderCommand and handler
  - Accept agency_service_id, quantity, notes
  - Validate agency_service exists and is published
  - Validate quantity <= available_quota
  - Generate unique order_number (AO-YYMMDD-XXX)
  - Calculate total_amount = reseller_price × quantity
  - Set status to 'pending'
  - Reserve quota: increment reserved_quota, decrement available_quota
  - Send notification to seller agency
  - _Requirements: 31.1, 31.2, 31.3, 31.4, 31.5_

- [ ] 35.2 Implement order number generation (AO-YYMMDD-XXX)
  - Use current date for YYMMDD
  - Generate sequential XXX per day
  - Ensure uniqueness across all agency orders
  - Format: AO-260218-001
  - _Requirements: 31.1_

- [ ] 35.3 Implement quota reservation logic
  - Validate quantity <= agency_service.available_quota
  - Increment agency_service.reserved_quota by quantity
  - Decrement agency_service.available_quota by quantity
  - Use database transaction for atomicity
  - Maintain quota invariant
  - _Requirements: 31.4_

- [ ] 35.4 Implement quantity validation against available quota
  - Get agency_service.available_quota
  - Validate quantity > 0
  - Validate quantity <= available_quota
  - Return clear error if insufficient quota
  - _Requirements: 31.2_

- [ ] 35.5 Create GetAgencyOrdersQuery and handler (buyer view)
  - Filter by buyer_agency_id = current agency
  - Support filtering by status (pending, approved, rejected)
  - Support filtering by date range
  - Include agency_service and seller agency info
  - Support pagination
  - _Requirements: 31.1_

- [ ] 35.6 Create GetAgencyOrderByIdQuery and handler
  - Accept order_id
  - Return order details with agency_service info
  - Include seller agency name
  - Validate order belongs to current agency (buyer or seller)
  - _Requirements: 31.1_

- [ ] 35.7 Create CancelAgencyOrderCommand and handler
  - Update status to 'cancelled'
  - Release reserved quota back to available_quota
  - Decrement reserved_quota by order quantity
  - Increment available_quota by order quantity
  - Only allow cancellation if status = 'pending'
  - _Requirements: 32.4_

- [ ] 35.8 Implement quota release on cancellation
  - Get order quantity
  - Decrement agency_service.reserved_quota by quantity
  - Increment agency_service.available_quota by quantity
  - Use database transaction for atomicity
  - _Requirements: 32.4_

- [ ] 35.9 Create agency order DTOs and validators
  - CreateAgencyOrderDto with required fields
  - AgencyOrderDto with all fields
  - Validate quantity > 0
  - Validate quantity <= available_quota
  - _Requirements: 31.1, 31.2_

- [ ] 35.10 Create agency order API endpoints
  - POST /api/agency-orders
  - GET /api/agency-orders (buyer's orders)
  - GET /api/agency-orders/{id}
  - PATCH /api/agency-orders/{id}/cancel
  - _Requirements: 31.1, 31.5_

- [ ]* 35.11 Write unit tests for agency order commands
  - Test order creation with valid data
  - Test order_number generation
  - Test quota reservation on order creation
  - Test quota release on cancellation
  - Test quantity validation
  - Test notification sending
  - _Requirements: 31.1, 31.2, 31.3, 31.4, 31.5_

- [ ]* 35.12 Test quota reservation/release logic
  - Test reserved_quota increments on order creation
  - Test available_quota decrements on order creation
  - Test reserved_quota decrements on cancellation
  - Test available_quota increments on cancellation
  - Test quota invariant is maintained
  - _Requirements: 31.4, 32.4_

### 36. Agency Order Approval (Req 32)

- [ ] 36.1 Create ApproveAgencyOrderCommand and handler
  - Update status to 'approved'
  - Record approved_at timestamp
  - Record approved_by user ID
  - Transfer quota: decrement reserved_quota, increment sold_quota
  - Validate order status is 'pending'
  - Send notification to buyer agency
  - _Requirements: 32.1, 32.2, 32.5_

- [ ] 36.2 Create RejectAgencyOrderCommand and handler
  - Update status to 'rejected'
  - Require rejection_reason
  - Release quota: decrement reserved_quota, increment available_quota
  - Validate order status is 'pending'
  - Send notification to buyer agency with reason
  - _Requirements: 32.3, 32.4, 32.5_

- [ ] 36.3 Implement quota transfer on approval (reserved → sold)
  - Get order quantity
  - Decrement agency_service.reserved_quota by quantity
  - Increment agency_service.sold_quota by quantity
  - Do NOT change available_quota (already decremented on order creation)
  - Use database transaction for atomicity
  - Maintain quota invariant
  - _Requirements: 32.2_

- [ ] 36.4 Implement quota release on rejection
  - Get order quantity
  - Decrement agency_service.reserved_quota by quantity
  - Increment agency_service.available_quota by quantity
  - Use database transaction for atomicity
  - Maintain quota invariant
  - _Requirements: 32.4_

- [ ] 36.5 Create GetIncomingAgencyOrdersQuery and handler (seller view)
  - Filter orders where seller_agency_id = current agency
  - Support filtering by status (pending, approved, rejected)
  - Support filtering by date range
  - Include buyer agency info
  - Support pagination
  - _Requirements: 32.1_

- [ ] 36.6 Create notification service for order status changes
  - Send notification to buyer on approval
  - Send notification to buyer on rejection (include reason)
  - Include order details in notification
  - Support email and in-app notifications
  - _Requirements: 32.5_

- [ ]* 36.7 Write unit tests for order approval workflow
  - Test approval updates status and timestamps
  - Test rejection requires reason
  - Test quota transfer on approval (reserved → sold)
  - Test quota release on rejection (reserved → available)
  - Test notifications are sent
  - Test only pending orders can be approved/rejected
  - _Requirements: 32.1, 32.2, 32.3, 32.4, 32.5_

- [ ]* 36.8 Test quota transfer logic
  - Test reserved_quota decrements on approval
  - Test sold_quota increments on approval
  - Test available_quota unchanged on approval
  - Test reserved_quota decrements on rejection
  - Test available_quota increments on rejection
  - Test quota invariant maintained
  - _Requirements: 32.2, 32.4_

### 37. Auto-Reject Pending Orders Job (Req 33)

- [ ] 37.1 Create AutoRejectPendingOrdersJob class
  - Implement IJob interface or use Hangfire method
  - Inject required services (DbContext, NotificationService)
  - Query pending orders older than 24 hours
  - Auto-reject each order with standard reason
  - Release reserved quota
  - _Requirements: 33.1, 33.2, 37.5_

- [ ] 37.2 Implement 24-hour timeout logic
  - Calculate cutoff_time = now - 24 hours
  - Query agency_orders WHERE status = 'pending' AND created_at < cutoff_time
  - For each order:
    - Update status to 'rejected'
    - Set rejection_reason = 'Auto-rejected: No response within 24 hours'
    - Release quota
    - Send notification to buyer
  - _Requirements: 33.2, 33.3_

- [ ] 37.3 Implement quota release on auto-rejection
  - Get order quantity
  - Decrement agency_service.reserved_quota by quantity
  - Increment agency_service.available_quota by quantity
  - Use database transaction for atomicity
  - Maintain quota invariant
  - _Requirements: 33.4_

- [ ] 37.4 Schedule job to run hourly
  - Use Hangfire RecurringJob.AddOrUpdate
  - Set cron expression for every hour
  - Configure timezone handling
  - _Requirements: 33.1, 37.5_

- [ ] 37.5 Create job logging
  - Log job start and completion
  - Log number of orders auto-rejected
  - Log any errors encountered
  - Track job execution time
  - _Requirements: 33.1_

- [ ]* 37.6 Write unit tests for auto-reject job
  - Test orders older than 24 hours are rejected
  - Test orders newer than 24 hours are NOT rejected
  - Test rejection_reason is set correctly
  - Test quota is released
  - Test notifications are sent
  - _Requirements: 33.1, 33.2, 33.3, 33.4, 33.5_

- [ ]* 37.7 Test notification sending on auto-rejection
  - Test buyer agency receives notification
  - Test notification includes order details
  - Test notification includes rejection reason
  - _Requirements: 33.5_

### 38. Auto-Unpublish Zero Quota Job (Req 34)

- [ ] 38.1 Create AutoUnpublishZeroQuotaJob class
  - Implement IJob interface or use Hangfire method
  - Inject required services (DbContext)
  - Query published services with zero available_quota
  - Auto-unpublish each service
  - _Requirements: 34.1, 34.2, 37.6_

- [ ] 38.2 Implement zero quota identification logic
  - Query agency_services WHERE is_published = true AND available_quota = 0
  - Exclude services with pending orders (reserved_quota > 0)
  - For each service:
    - Set is_published = false
    - Record unpublished_at timestamp
  - _Requirements: 34.2_

- [ ] 38.3 Implement auto-unpublish logic
  - Update is_published to false
  - Do NOT delete the service record
  - Allow manual republishing later when quota becomes available
  - Log unpublish action
  - _Requirements: 34.3_

- [ ] 38.4 Schedule job to run daily at 10:00 AM
  - Use Hangfire RecurringJob.AddOrUpdate
  - Set cron expression for 10:00 AM daily
  - Configure timezone handling
  - _Requirements: 34.1, 37.6_

- [ ] 38.5 Create job logging
  - Log job start and completion
  - Log number of services unpublished
  - Log any errors encountered
  - Track job execution time
  - _Requirements: 34.1_

- [ ]* 38.6 Write unit tests for auto-unpublish job
  - Test services with available_quota = 0 are unpublished
  - Test services with available_quota > 0 are NOT unpublished
  - Test is_published is set to false
  - Test service can be manually republished later
  - _Requirements: 34.1, 34.2, 34.3, 34.4_

- [ ]* 38.7 Test quota invariant validation
  - Test invariant: total_quota = used_quota + available_quota + reserved_quota + sold_quota
  - Test invariant holds after order creation
  - Test invariant holds after order approval
  - Test invariant holds after order rejection
  - Test invariant holds after auto-unpublish
  - _Requirements: 34.5_

### 39. Profitability Tracking (Req 35, 36)

- [ ] 39.1 Create GetBookingProfitabilityQuery and handler
  - Accept booking_id
  - Calculate revenue = package.selling_price × booking.total_pax
  - Calculate cost from package_services (sum of all service costs)
  - Calculate gross_profit = revenue - cost
  - Calculate gross_margin_percentage = (gross_profit / revenue) × 100
  - Return profitability details
  - _Requirements: 35.1, 35.2, 35.3, 35.4_

- [ ] 39.2 Implement revenue calculation
  - Get package selling_price
  - Get booking total_pax
  - Calculate revenue = selling_price × total_pax
  - Store in booking.total_amount (already calculated on booking creation)
  - _Requirements: 35.1_

- [ ] 39.3 Implement cost aggregation from POs and agency orders
  - Get all package_services for the package
  - For each service:
    - If source_type = 'supplier': get cost from po_item.unit_price
    - If source_type = 'agency': get cost from agency_service.cost_price
  - Sum all service costs: total_cost = Σ(quantity × unit_cost)
  - Multiply by booking.total_pax for total booking cost
  - _Requirements: 35.2_

- [ ] 39.4 Implement gross profit and margin calculation
  - Calculate gross_profit = revenue - cost
  - Calculate gross_margin_percentage = (gross_profit / revenue) × 100
  - Round to 2 decimal places
  - Handle edge case where revenue = 0
  - _Requirements: 35.3, 35.4_

- [ ] 39.5 Create GetProfitabilityDashboardQuery and handler
  - Accept date range filter
  - Aggregate total revenue across all bookings
  - Aggregate total cost across all bookings
  - Calculate total gross_profit
  - Calculate average margin percentage
  - Identify top 10 most profitable bookings
  - Identify bookings with margin < 10% (low margin warnings)
  - Support filtering by package_type
  - _Requirements: 36.1, 36.2, 36.3, 36.4, 36.5_

- [ ] 39.6 Implement low/high margin identification
  - Low margin: gross_margin_percentage < 10%
  - High margin: gross_margin_percentage >= 30%
  - Medium margin: 10% <= gross_margin_percentage < 30%
  - Flag bookings accordingly
  - _Requirements: 35.5, 36.4_

- [ ] 39.7 Create profitability DTOs
  - BookingProfitabilityDto with revenue, cost, profit, margin
  - ProfitabilityDashboardDto with aggregated metrics
  - TopProfitableBookingDto for top 10 list
  - LowMarginBookingDto for warnings
  - _Requirements: 35.1, 35.2, 35.3, 35.4, 35.5, 36.1, 36.2, 36.3, 36.4_

- [ ] 39.8 Create profitability API endpoints
  - GET /api/bookings/{id}/profitability
  - GET /api/profitability/dashboard
  - GET /api/profitability/low-margin-bookings
  - GET /api/profitability/top-bookings
  - _Requirements: 35.1, 36.1, 36.3, 36.4_

- [ ]* 39.9 Write unit tests for profitability queries
  - Test revenue calculation accuracy
  - Test cost aggregation from multiple sources
  - Test gross_profit calculation
  - Test margin percentage calculation
  - Test low margin identification (< 10%)
  - Test dashboard aggregations
  - _Requirements: 35.1, 35.2, 35.3, 35.4, 35.5, 36.1, 36.2, 36.3, 36.4, 36.5_

- [ ]* 39.10 Test margin percentage calculations
  - Test margin = 0% when revenue = cost
  - Test margin = 50% when profit = revenue / 2
  - Test margin = 100% when cost = 0
  - Test negative margin when cost > revenue
  - Test low margin flag when margin < 10%
  - _Requirements: 35.4, 35.5_

### 40. Subscription Plan Management (Req 41)

- [ ] 40.1 Create CreateSubscriptionPlanCommand and handler
  - Validate plan_name, plan_type, monthly_price, features
  - Store features as JSONB with configurable limits
  - Set is_active to true by default
  - _Requirements: 41.1, 41.3_

- [ ] 40.2 Create UpdateSubscriptionPlanCommand and handler
  - Allow updating plan details and features
  - Validate feature limits
  - _Requirements: 41.1, 41.3_

- [ ] 40.3 Create ActivateSubscriptionPlanCommand and handler
  - Update is_active to true
  - _Requirements: 41.4_

- [ ] 40.4 Create DeactivateSubscriptionPlanCommand and handler
  - Update is_active to false
  - Prevent deactivation if active subscriptions exist
  - _Requirements: 41.4, 41.5_

- [ ] 40.5 Create GetSubscriptionPlansQuery and handler
  - Support filtering by plan_type and is_active
  - Return all plans with features
  - _Requirements: 41.1_

- [ ] 40.6 Create GetSubscriptionPlanByIdQuery and handler
  - Return plan details with features
  - _Requirements: 41.1_

- [ ] 40.7 Create subscription plan DTOs and validators
  - CreateSubscriptionPlanDto with all fields
  - Validate plan_type enum values (free, basic, professional, enterprise)
  - Validate features JSONB structure
  - _Requirements: 41.2, 41.3_

- [ ] 40.8 Create subscription plan API endpoints
  - GET /api/admin/subscription-plans
  - GET /api/admin/subscription-plans/{id}
  - POST /api/admin/subscription-plans
  - PUT /api/admin/subscription-plans/{id}
  - PATCH /api/admin/subscription-plans/{id}/activate
  - PATCH /api/admin/subscription-plans/{id}/deactivate
  - _Requirements: 41.1_

- [ ]* 40.9 Write unit tests for subscription plan commands/queries
  - Test plan creation with features
  - Test feature validation
  - Test activation/deactivation logic
  - _Requirements: 41.1, 41.2, 41.3, 41.4, 41.5_

### 41. Agency Subscription Assignment (Req 42)

- [ ] 41.1 Create AssignAgencySubscriptionCommand and handler
  - Validate agency_id, plan_id, start_date, billing_cycle
  - Calculate next_billing_date based on billing_cycle
  - Set status to 'active' by default
  - Validate only one active subscription per agency
  - _Requirements: 42.1, 42.2, 42.3, 42.4, 42.6_

- [ ] 41.2 Create CancelAgencySubscriptionCommand and handler
  - Update status to 'cancelled'
  - Record cancelled_at timestamp and cancellation_reason
  - _Requirements: 42.7_

- [ ] 41.3 Create SuspendAgencySubscriptionCommand and handler
  - Update status to 'suspended'
  - _Requirements: 42.5_

- [ ] 41.4 Create ReactivateAgencySubscriptionCommand and handler
  - Update status to 'active'
  - Recalculate next_billing_date
  - _Requirements: 42.4_

- [ ] 41.5 Create GetAgencySubscriptionsQuery and handler
  - Support filtering by agency_id and status
  - Support pagination
  - Include plan details in response
  - _Requirements: 42.1_

- [ ] 41.6 Create GetAgencySubscriptionByIdQuery and handler
  - Return subscription with plan details
  - _Requirements: 42.1_

- [ ] 41.7 Create agency subscription DTOs and validators
  - AssignSubscriptionDto with required fields
  - Validate billing_cycle enum values (monthly, quarterly, annually)
  - Validate status enum values
  - _Requirements: 42.2, 42.5_

- [ ] 41.8 Create agency subscription API endpoints
  - GET /api/admin/agency-subscriptions
  - POST /api/admin/agency-subscriptions
  - PATCH /api/admin/agency-subscriptions/{id}/cancel
  - PATCH /api/admin/agency-subscriptions/{id}/suspend
  - PATCH /api/admin/agency-subscriptions/{id}/reactivate
  - _Requirements: 42.1_

- [ ]* 41.9 Write unit tests for agency subscription commands/queries
  - Test subscription assignment
  - Test next_billing_date calculation
  - Test one-active-subscription-per-agency constraint
  - Test cancellation workflow
  - _Requirements: 42.1, 42.2, 42.3, 42.4, 42.5, 42.6, 42.7_

### 42. Commission Configuration (Req 43)

- [ ] 42.1 Create CreateCommissionConfigCommand and handler
  - Validate service_type, commission_type, commission_value
  - Validate percentage range (0-100) for percentage type
  - Validate positive value for fixed type
  - Allow agency-specific or global configs (agency_id nullable)
  - Set effective_from and effective_until dates
  - _Requirements: 43.1, 43.2, 43.3, 43.4, 43.5, 43.8_

- [ ] 42.2 Create UpdateCommissionConfigCommand and handler
  - Allow updating commission values and dates
  - Validate commission_type and commission_value
  - _Requirements: 43.1, 43.3, 43.4, 43.5_

- [ ] 42.3 Create ActivateCommissionConfigCommand and handler
  - Update is_active to true
  - _Requirements: 43.1_

- [ ] 42.4 Create DeactivateCommissionConfigCommand and handler
  - Update is_active to false
  - _Requirements: 43.1_

- [ ] 42.5 Implement commission calculation logic
  - Prioritize agency-specific configs over global configs
  - Calculate commission based on type (percentage or fixed)
  - Check effective date range
  - _Requirements: 43.7_

- [ ] 42.6 Create GetCommissionConfigsQuery and handler
  - Support filtering by agency_id, service_type, is_active
  - Return configs with priority order
  - _Requirements: 43.1, 43.2_

- [ ] 42.7 Create GetCommissionConfigByIdQuery and handler
  - Return config details
  - _Requirements: 43.1_

- [ ] 42.8 Create commission config DTOs and validators
  - CreateCommissionConfigDto with all fields
  - Validate service_type enum values
  - Validate commission_type enum values
  - Validate commission_value based on type
  - _Requirements: 43.2, 43.3, 43.4, 43.5_

- [ ] 42.9 Create commission config API endpoints
  - GET /api/admin/commission-configs
  - GET /api/admin/commission-configs/{id}
  - POST /api/admin/commission-configs
  - PUT /api/admin/commission-configs/{id}
  - PATCH /api/admin/commission-configs/{id}/activate
  - PATCH /api/admin/commission-configs/{id}/deactivate
  - _Requirements: 43.1_

- [ ]* 42.10 Write unit tests for commission config commands/queries
  - Test commission calculation logic
  - Test agency-specific vs global priority
  - Test percentage and fixed type validation
  - Test effective date range validation
  - _Requirements: 43.1, 43.2, 43.3, 43.4, 43.5, 43.6, 43.7, 43.8_

### 43. Commission Transaction Recording (Req 44)

- [ ] 43.1 Implement auto-commission recording on booking confirmation
  - Calculate commission based on applicable config
  - Create commission_transaction record
  - Set status to 'pending'
  - _Requirements: 44.1, 44.3, 44.6_

- [ ] 43.2 Implement auto-commission recording on agency order approval
  - Calculate commission for marketplace transactions
  - Create commission_transaction record
  - _Requirements: 44.2, 44.3_

- [ ] 43.3 Create CollectCommissionCommand and handler
  - Update status to 'collected'
  - Record collected_at timestamp and payment_reference
  - _Requirements: 44.7_

- [ ] 43.4 Create WaiveCommissionCommand and handler
  - Update status to 'waived'
  - Record notes
  - _Requirements: 44.6_

- [ ] 43.5 Create RefundCommissionCommand and handler
  - Update status to 'refunded'
  - Record notes
  - _Requirements: 44.6_

- [ ] 43.6 Create GetCommissionTransactionsQuery and handler
  - Support filtering by agency_id, transaction_type, status, date range
  - Support pagination
  - Calculate total commission amount
  - _Requirements: 44.8_

- [ ] 43.7 Create GetCommissionTransactionByIdQuery and handler
  - Return transaction details with config info
  - _Requirements: 44.3_

- [ ] 43.8 Create commission transaction DTOs
  - CommissionTransactionDto with all fields
  - Include transaction_type, base_amount, commission_amount
  - _Requirements: 44.3, 44.4, 44.5_

- [ ] 43.9 Create commission transaction API endpoints
  - GET /api/admin/commission-transactions
  - GET /api/admin/commission-transactions/{id}
  - PATCH /api/admin/commission-transactions/{id}/collect
  - PATCH /api/admin/commission-transactions/{id}/waive
  - PATCH /api/admin/commission-transactions/{id}/refund
  - _Requirements: 44.1, 44.2_

- [ ]* 43.10 Write unit tests for commission transaction commands/queries
  - Test auto-recording on booking confirmation
  - Test auto-recording on agency order approval
  - Test commission calculation accuracy
  - Test status transitions
  - _Requirements: 44.1, 44.2, 44.3, 44.4, 44.5, 44.6, 44.7, 44.8_

### 44. Revenue Metrics Tracking

- [ ] 44.1 Create UpdateRevenueMetricsJob class
  - Aggregate daily metrics per agency
  - Calculate total_bookings, total_revenue, total_commission
  - Calculate marketplace_orders and marketplace_revenue
  - Update active_packages and active_journeys counts
  - _Requirements: 44.8_

- [ ] 44.2 Schedule revenue metrics job to run daily at midnight
  - Process previous day's data
  - Create or update revenue_metrics records
  - _Requirements: 44.8_

- [ ] 44.3 Create GetRevenueMetricsQuery and handler
  - Support filtering by agency_id and date range
  - Return daily metrics with trends
  - _Requirements: 44.8_

- [ ] 44.4 Create GetRevenueMetricsSummaryQuery and handler
  - Aggregate metrics by month/quarter/year
  - Calculate growth percentages
  - Identify top agencies by revenue
  - _Requirements: 44.8_

- [ ] 44.5 Create revenue metrics DTOs
  - RevenueMetricDto with all fields
  - RevenueSummaryDto with aggregations
  - _Requirements: 44.8_

- [ ] 44.6 Create revenue metrics API endpoints
  - GET /api/admin/revenue-metrics
  - GET /api/admin/revenue-metrics/summary
  - GET /api/admin/revenue-metrics/agencies/{agency_id}
  - _Requirements: 44.8_

- [ ]* 44.7 Write unit tests for revenue metrics job and queries
  - Test daily aggregation logic
  - Test metric calculations
  - Test trend analysis
  - _Requirements: 44.8_

### 45. Supplier Self-Registration Enhancement (Req 45)

- [ ] 45.1 Update RegisterSupplierCommand to include new fields
  - Add business_license_number validation (unique)
  - Add tax_id validation (unique)
  - Add address fields (city, province, postal_code, country)
  - _Requirements: 45.2, 45.4, 45.5_

- [ ] 45.2 Update supplier DTOs and validators
  - Add all new required fields to RegisterSupplierDto
  - Validate business_license_number uniqueness
  - Validate tax_id uniqueness
  - _Requirements: 45.2, 45.3, 45.4, 45.5_

- [ ] 45.3 Update supplier registration API endpoint
  - Ensure POST /api/auth/register/supplier is public (no auth required)
  - Include all new fields in request
  - _Requirements: 45.1, 45.12_

- [ ] 45.4 Update email notification templates
  - Send confirmation email to supplier on registration
  - Send notification email to Platform_Admin for approval
  - _Requirements: 45.10, 45.11_

- [ ]* 45.5 Write unit tests for enhanced supplier registration
  - Test all field validations
  - Test uniqueness constraints
  - Test email notifications
  - _Requirements: 45.2, 45.3, 45.4, 45.5, 45.6, 45.7, 45.8, 45.9, 45.10, 45.11, 45.12_



---

## Week 10: Integration Testing & Bug Fixes (Apr 20 - Apr 26)

### 46. Integration Testing

- [ ] 46.1 Setup integration test project with Testcontainers
- [ ] 46.2 Write integration tests for authentication flow
- [ ] 46.3 Write integration tests for agency management
- [ ] 46.4 Write integration tests for supplier management
- [ ] 46.5 Write integration tests for service and PO workflow
- [ ] 46.6 Write integration tests for package and journey workflow
- [ ] 46.7 Write integration tests for booking workflow
- [ ] 46.8 Write integration tests for document management
- [ ] 46.9 Write integration tests for task management
- [ ] 46.10 Write integration tests for notification system
- [ ] 46.11 Write integration tests for payment tracking
- [ ] 46.12 Write integration tests for B2B marketplace workflow
- [ ] 46.13 Write integration tests for profitability tracking
- [ ] 46.14 Write integration tests for subscription & commission management
- [ ] 46.15 Write integration tests for multi-tenancy isolation

### 47. Performance Testing & Optimization

- [ ] 47.1 Run performance tests on list endpoints with large datasets
- [ ] 47.2 Optimize database queries with proper indexes
- [ ] 47.3 Implement query result caching for master data
- [ ] 47.4 Optimize N+1 query problems with eager loading
- [ ] 47.5 Test API response times (target < 500ms)
- [ ] 47.6 Implement database connection pooling optimization
- [ ] 47.7 Test concurrent request handling

### 48. Security Testing

- [ ] 48.1 Test authentication bypass attempts
- [ ] 48.2 Test authorization bypass attempts (cross-tenant access)
- [ ] 48.3 Test SQL injection vulnerabilities
- [ ] 48.4 Test XSS vulnerabilities in API responses
- [ ] 48.5 Verify RLS policies prevent cross-tenant data access
- [ ] 48.6 Test password hashing strength
- [ ] 48.7 Test JWT token expiration and refresh
- [ ] 48.8 Test rate limiting (if implemented)

### 49. Bug Fixes & Code Quality

- [ ] 49.1 Fix all critical bugs identified during testing
- [ ] 49.2 Fix all high-priority bugs
- [ ] 49.3 Code review for all modules
- [ ] 49.4 Refactor code for better maintainability
- [ ] 49.5 Add missing error handling
- [ ] 49.6 Add missing validation
- [ ] 49.7 Improve logging coverage
- [ ] 49.8 Update API documentation (Swagger)
- [ ] 49.9 Add XML comments for all public APIs


---

## Week 11: Demo Preparation & Deployment (Apr 27 - May 3)

### 50. Demo Data Preparation

- [ ] 50.1 Create comprehensive seed data script for demo
- [ ] 50.2 Create 2 sample agencies (Agency A - wholesaler, Agency B - retailer)
- [ ] 50.3 Create 3 sample suppliers with services (hotel, flight, visa)
- [ ] 50.4 Create sample POs (approved and pending)
- [ ] 50.5 Create sample packages with different types
- [ ] 50.6 Create sample journeys with various dates
- [ ] 50.7 Create sample bookings with customers and travelers
- [ ] 50.8 Create sample document checklists (various statuses)
- [ ] 50.9 Create sample tasks (completed, in progress, overdue)
- [ ] 50.10 Create sample payment schedules (paid, pending, overdue)
- [ ] 50.11 Create sample itineraries
- [ ] 50.12 Create sample marketplace services (Agency A publishes)
- [ ] 50.13 Create sample agency orders (Agency B orders from Agency A)
- [ ] 50.14 Create sample notification logs
- [ ] 50.15 Create sample subscription plans and agency subscriptions
- [ ] 50.16 Create sample commission configs and transactions
- [ ] 50.17 Verify all demo data is realistic and demonstrates all features

### 51. Documentation & Deployment

- [ ] 51.1 Update README with setup instructions
- [ ] 51.2 Update API documentation with all endpoints
- [ ] 51.3 Create deployment guide for Docker
- [ ] 51.4 Create environment variable documentation
- [ ] 51.5 Create database migration guide
- [ ] 51.6 Test Docker Compose deployment
- [ ] 51.7 Create backup and restore procedures
- [ ] 51.8 Create monitoring and logging guide
- [ ] 51.9 Prepare demo script for backend API testing
- [ ] 51.10 Final code cleanup and formatting

### 52. Demo Rehearsal

- [ ] 52.1 Test complete authentication flow
- [ ] 52.2 Test platform admin workflows
- [ ] 52.3 Test supplier workflows (service creation, PO approval)
- [ ] 52.4 Test agency workflows (package creation, booking)
- [ ] 52.5 Test document and task management
- [ ] 52.6 Test notification system
- [ ] 52.7 Test payment tracking
- [ ] 52.8 Test B2B marketplace (Agency A ↔ Agency B)
- [ ] 52.9 Test profitability tracking
- [ ] 52.10 Test subscription plan management
- [ ] 52.11 Test commission tracking and collection
- [ ] 52.12 Test all dashboards
- [ ] 52.13 Verify no critical bugs
- [ ] 52.14 Prepare demo presentation



---

## Task Summary

### By Module

**Foundation & Infrastructure (Tasks 1-5):** ~50 tasks
- Project setup, database, authentication, multi-tenancy, CQRS

**Platform Admin (Tasks 6-8):** ~20 tasks
- Agency management, supplier approval, dashboard

**Supplier Features (Tasks 9-12):** ~35 tasks
- Service management, seasonal pricing, PO workflow

**Agency Core (Tasks 13-18):** ~60 tasks
- Package, journey, customer, booking, traveler management

**ERP Features (Tasks 19-32):** ~90 tasks
- Documents, tasks, notifications, payments, itinerary, supplier bills, communication

**B2B Marketplace (Tasks 33-39):** ~60 tasks
- Agency services, marketplace, orders, profitability

**Subscription & Commission (Tasks 40-45):** ~70 tasks
- Subscription plans, agency subscriptions, commission configs, commission transactions, revenue metrics, enhanced supplier registration

**Testing & Deployment (Tasks 46-52):** ~65 tasks
- Integration tests, performance, security, bug fixes, demo data

**TOTAL:** ~450 tasks

### By Week

- Week 1-2: Foundation (50 tasks)
- Week 3: Platform Admin (20 tasks)
- Week 4: Supplier Features (35 tasks)
- Week 5: Agency Core (60 tasks)
- Week 6: Document & Task (40 tasks)
- Week 7: Notification & Payment (40 tasks)
- Week 8: Itinerary & Bills (30 tasks)
- Week 9: Marketplace, Profitability & Subscription/Commission (130 tasks)
- Week 10: Testing (40 tasks)
- Week 11: Demo Prep (35 tasks)

### Critical Path

1. **Week 1-2:** Foundation must complete before any feature work
2. **Week 3:** Supplier entity needed for Week 4
3. **Week 4:** PO workflow needed for Week 5 packages
4. **Week 5:** Booking entity needed for Week 6-7 ERP features
5. **Week 6-7:** Document/Task/Notification systems needed for demo
6. **Week 9:** Marketplace AND subscription/commission must be functional for demo
7. **Week 10-11:** Testing and demo prep are critical for May 3 demo

### Success Criteria

**Must Have (Demo Blockers):**
- ✅ All authentication and authorization working
- ✅ Multi-tenancy RLS working (no cross-tenant access)
- ✅ Platform admin can onboard agencies
- ✅ Platform admin can manage subscription plans
- ✅ Platform admin can assign subscriptions to agencies
- ✅ Platform admin can configure commission rates
- ✅ Commission auto-recorded on bookings and marketplace orders
- ✅ Revenue metrics dashboard working
- ✅ Suppliers can self-register via public endpoint
- ✅ Suppliers can create services and approve POs
- ✅ Agencies can create packages from approved POs
- ✅ Agency staff can create bookings manually
- ✅ Document checklist auto-generated
- ✅ Task checklist auto-generated
- ✅ Pre-departure notifications working (H-7, H-1 minimum)
- ✅ Payment tracking working
- ✅ Itinerary builder working
- ✅ B2B marketplace working (Agency A ↔ Agency B)
- ✅ Supplier name HIDDEN in marketplace
- ✅ Quota management working
- ✅ Profitability tracking working
- ✅ All dashboards showing correct data
- ✅ System stable (no critical bugs)

**Nice to Have (Can defer to Phase 2):**
- 💎 All notification schedules (H-30, H-14, H-3)
- 💎 Email sending (can use in-app only)
- 💎 PDF exports
- 💎 Advanced profitability reports
- 💎 Subscription auto-renewal
- 💎 Commission auto-collection

---

## Task Distribution for 2 Backend Developers

### Backend Developer 1 (Senior) - Focus Areas:
- Week 1-2: Project setup, database, authentication, multi-tenancy
- Week 3: Platform admin, supplier management
- Week 4: Supplier services, seasonal pricing
- Week 5: Package, journey management
- Week 6: Document management
- Week 7: Notification system, background jobs
- Week 8: Itinerary builder
- Week 9: B2B marketplace seller side, subscription plan management, commission configuration
- Week 10: Integration testing, performance
- Week 11: Demo preparation

### Backend Developer 2 (Mid-Senior) - Focus Areas:
- Week 1-2: CQRS setup, validation, logging
- Week 3: Supplier dashboard
- Week 4: Purchase order workflow
- Week 5: Customer, booking, traveler management
- Week 6: Task management
- Week 7: Payment tracking
- Week 8: Supplier bills, communication log
- Week 9: B2B marketplace buyer side, profitability, agency subscription assignment, commission transaction recording, revenue metrics
- Week 10: Security testing, bug fixes
- Week 11: Demo data, documentation

---

**Status:** ✅ READY FOR IMPLEMENTATION

**Next Action:** Start Week 1-2 tasks on Feb 16, 2026

**Demo Date:** May 3, 2026 🎯

**Updated:** Feb 18, 2026 - Added subscription & commission management features (Requirements 41-45)



---

## Self-Registration with KYC Verification Tasks

### 53. Database Schema Changes for KYC

- [ ] 53.1 Create migration to ALTER agencies table
  - Add business_type, business_license_number, tax_id
  - Add verification_status, verification_attempts, max_verification_attempts
  - Add rejection_reason, verified_at, verified_by
  - Add owner_name, country
  - Add indexes and unique constraints
  - _Requirements: 47.2, 47.7_

- [ ] 53.2 Create migration to ALTER suppliers table
  - Add verification_status, verification_attempts, max_verification_attempts
  - Add owner_name, service_types (TEXT[] array)
  - Add indexes
  - _Requirements: 48.2, 48.3, 48.4, 48.5_

- [ ] 53.3 Create document_requirements table
  - All fields as per design
  - Indexes on entity_type, service_type, is_active
  - _Requirements: 50.1, 50.2, 50.3, 50.4, 50.5_

- [ ] 53.4 Create entity_documents table
  - All fields as per design
  - Indexes on entity_type, entity_id, verification_status
  - _Requirements: 51.1, 51.2, 51.9_

- [ ] 53.5 Create seed data for document_requirements
  - General documents (KTP, NPWP, NIB, Akta, SK Kemenkumham, SKDU, Bank Statement)
  - Hotel-specific documents (Hotel License, TDUP, Rating Certificate)
  - Flight-specific documents (IATA/TIDS, Flight License, BSP Certificate)
  - Visa-specific documents (Visa License, Embassy Partnership)
  - Transport-specific documents (Transport License, STNK, KIR, Insurance)
  - Guide-specific documents (Guide License, HPI Membership, Language Certificate)
  - Insurance-specific documents (OJK License, AAJI Certificate, Partnership)
  - Catering-specific documents (PIRT/BPOM, Halal Certificate, Hygiene Certificate)
  - Handling-specific documents (Handling License, Airport Partnership, Certificate)
  - _Requirements: 50.6_

- [ ] 53.6 Run migrations on development database
  - Test data integrity after migration
  - Verify existing data is not affected
  - _Requirements: All schema requirements_

### 54. MinIO File Storage Integration

- [ ] 54.1 Install Minio NuGet package (version 6.0.3)
  - _Requirements: 49.1_

- [ ] 54.2 Create IFileStorageService interface
  - Methods: UploadAsync, DownloadAsync, DeleteAsync, ExistsAsync, GetFileUrl
  - FileUploadResult DTO
  - _Requirements: 49.9_

- [ ] 54.3 Implement MinIOFileStorageService
  - Initialize MinIO client with configuration
  - Implement bucket creation on startup
  - Implement file upload with validation
  - Implement file download with presigned URLs
  - Implement file deletion
  - Implement file existence check
  - _Requirements: 49.1, 49.2, 49.3, 49.4, 49.5, 49.6, 49.7, 49.8, 49.9_

- [ ] 54.4 Add MinIO configuration to appsettings.json
  - Endpoint, AccessKey, SecretKey, BucketName
  - UseSSL, Region, MaxFileSizeMB, AllowedExtensions
  - _Requirements: 49.2_

- [ ] 54.5 Register IFileStorageService in DI container
  - AddSingleton<IFileStorageService, MinIOFileStorageService>
  - _Requirements: 49.1_

- [ ] 54.6 Implement file operation logging
  - Log all uploads, downloads, deletes
  - Include entity_type, entity_id, file_name, user_id
  - _Requirements: 49.11_

- [ ] 54.7 Implement error handling for MinIO operations
  - Connection errors
  - Upload failures
  - Download failures
  - Return appropriate error messages
  - _Requirements: 49.10_

- [ ]* 54.8 Write unit tests for MinIOFileStorageService
  - Test upload with valid file
  - Test upload with oversized file
  - Test upload with invalid extension
  - Test download existing file
  - Test download non-existent file
  - Test delete file
  - _Requirements: 49.5, 49.6, 49.7_

### 55. Domain Entities Extension

- [ ] 55.1 Extend Agency entity
  - Add new properties for KYC
  - Add business logic methods: CanResubmit, IsVerified, MarkAsAwaitingApproval, Approve, Reject, ResetForResubmission
  - Add navigation property to EntityDocuments
  - _Requirements: 47.7, 47.8_

- [ ] 55.2 Extend Supplier entity
  - Add new properties for KYC
  - Add business logic methods (same as Agency)
  - Add navigation property to EntityDocuments
  - _Requirements: 48.7, 48.8_

- [ ] 55.3 Create DocumentRequirement entity
  - All properties as per design
  - _Requirements: 50.1, 50.2, 50.3, 50.4, 50.5_

- [ ] 55.4 Create EntityDocument entity
  - All properties as per design
  - Add business logic methods: IsVerified, IsRejected, IsPending, Verify, Reject
  - Add navigation property to User (VerifiedByUser)
  - _Requirements: 51.2, 51.9_

- [ ] 55.5 Update DbContext with new entities
  - Add DbSet for DocumentRequirement
  - Add DbSet for EntityDocument
  - Configure entity relationships
  - _Requirements: All entity requirements_



### 56. Agency Self-Registration (Req 47)

- [ ] 56.1 Create RegisterAgencyCommand and handler
  - Validate company_name, owner_name, email, phone, business_type
  - Validate password matches confirm_password
  - Validate password requirements (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
  - Hash password with BCrypt
  - Generate unique agency_code (AGN-YYMMDD-XXX)
  - Create agency with verification_status='pending_documents', is_active=false
  - Create user account with user_type='agency_staff'
  - _Requirements: 47.2, 47.3, 47.4, 47.5, 47.6, 47.7, 47.8, 47.9_

- [ ] 56.2 Create RegisterAgencyCommandValidator
  - Validate all required fields
  - Validate email format and uniqueness
  - Validate password requirements
  - Validate password confirmation match
  - _Requirements: 47.2, 47.3, 47.4, 47.5, 47.6_

- [ ] 56.3 Auto-generate document checklist after agency registration
  - Query document_requirements WHERE entity_type='agency'
  - Create entity_documents records with verification_status='pending'
  - _Requirements: 51.2, 51.3_

- [ ] 56.4 Send registration success email to agency
  - Use email template with owner_name, company_name, agency_code
  - Include link to document upload page
  - _Requirements: 47.10, 56.1_

- [ ] 56.5 Send notification email to Platform Admin
  - Notify new agency registration
  - Include agency details
  - _Requirements: 47.11_

- [ ] 56.6 Create POST /api/auth/register/agency endpoint
  - Public endpoint (no authentication)
  - Accept RegisterAgencyCommand
  - Return agency_id, agency_code, redirect_url
  - _Requirements: 47.1, 47.12, 47.13_

- [ ]* 56.7 Write unit tests for RegisterAgencyCommand
  - Test successful registration
  - Test duplicate email
  - Test invalid password
  - Test password mismatch
  - _Requirements: 47.2, 47.3, 47.4, 47.5, 47.6_

### 57. Enhanced Supplier Self-Registration (Req 48)

- [ ] 57.1 Extend RegisterSupplierCommand with service_types
  - Add service_types field (array)
  - Validate at least one service_type selected
  - Validate all service_types are valid enum values
  - Store service_types in suppliers table
  - _Requirements: 48.1, 48.2, 48.3, 48.4, 48.5_

- [ ] 57.2 Update RegisterSupplierCommandValidator
  - Validate service_types not empty
  - Validate service_types values (hotel, flight, visa, transport, guide, insurance, catering, handling)
  - _Requirements: 48.2, 48.3, 48.5_

- [ ] 57.3 Auto-generate document checklist based on service_types
  - Query document_requirements WHERE entity_type='supplier' AND (service_type IS NULL OR service_type IN service_types)
  - Create entity_documents records for all matching requirements
  - _Requirements: 48.6, 51.2, 51.3_

- [ ] 57.4 Update supplier registration to set verification_status
  - Set verification_status='pending_documents'
  - Set verification_attempts=0, max_verification_attempts=3
  - _Requirements: 48.7, 48.8_

- [ ] 57.5 Update POST /api/auth/register/supplier endpoint
  - Accept service_types in request body
  - Return supplier_id, supplier_code, redirect_url
  - _Requirements: 48.1, 48.2_

- [ ]* 57.6 Write unit tests for enhanced supplier registration
  - Test registration with single service_type
  - Test registration with multiple service_types
  - Test registration with invalid service_type
  - Test registration with empty service_types
  - Test document checklist generation based on service_types
  - _Requirements: 48.2, 48.3, 48.4, 48.5, 48.6_

### 58. Document Upload & Management (Req 51)

- [ ] 58.1 Create UploadDocumentCommand and handler
  - Validate entity ownership (user must own the entity)
  - Validate file size (max 10MB)
  - Validate file extension (.pdf, .jpg, .jpeg, .png, .doc, .docx)
  - Upload file to MinIO using IFileStorageService
  - Save document metadata to entity_documents table
  - _Requirements: 51.4, 51.5, 51.6, 51.7, 51.8, 51.9_

- [ ] 58.2 Create UploadDocumentCommandValidator
  - Validate file is provided
  - Validate entity_type and entity_id
  - Validate document_type
  - _Requirements: 51.4, 51.5_

- [ ] 58.3 Implement document re-upload logic
  - If document already exists and is rejected, allow re-upload
  - Delete old file from MinIO
  - Upload new file
  - Update entity_documents with new file metadata
  - Reset verification_status to 'pending'
  - _Requirements: 51.10, 53.3, 53.4_

- [ ] 58.4 Create GetEntityDocumentsQuery and handler
  - Get all documents for entity_type + entity_id
  - Include document_label, document_description from document_requirements
  - Generate presigned URLs for file access
  - _Requirements: 51.11_

- [ ] 58.5 Create DownloadDocumentQuery and handler
  - Validate user has access to document
  - Download file from MinIO
  - Return file stream with proper content-type
  - _Requirements: 51.12_

- [ ] 58.6 Create DeleteDocumentCommand and handler
  - Validate user owns the document
  - Validate document status is 'pending' or 'rejected'
  - Delete file from MinIO
  - Delete entity_documents record
  - _Requirements: 51.13_

- [ ] 58.7 Create GetDocumentProgressQuery and handler
  - Calculate total_mandatory_documents
  - Calculate uploaded_documents, verified_documents, rejected_documents
  - Calculate completion_percentage
  - Return verification_status, verification_attempts, can_resubmit
  - _Requirements: 51.14, 54.1, 54.2, 54.3_

- [ ] 58.8 Auto-update entity verification_status when all mandatory docs uploaded
  - When last mandatory document is uploaded, set entity verification_status='awaiting_approval'
  - Send notification to Platform Admin
  - _Requirements: 51.2, 51.3, 54.4_

- [ ] 58.9 Create POST /api/documents/upload endpoint
  - Authenticated endpoint
  - Accept multipart/form-data
  - Return document_id, file_url
  - _Requirements: 51.4_

- [ ] 58.10 Create GET /api/documents endpoint
  - Authenticated endpoint
  - Return list of documents for current user's entity
  - _Requirements: 51.11_

- [ ] 58.11 Create GET /api/documents/progress endpoint
  - Authenticated endpoint
  - Return document progress and verification status
  - _Requirements: 54.3_

- [ ] 58.12 Create GET /api/documents/{id}/download endpoint
  - Authenticated endpoint
  - Return file stream
  - _Requirements: 51.12_

- [ ] 58.13 Create DELETE /api/documents/{id} endpoint
  - Authenticated endpoint
  - Return 204 No Content on success
  - _Requirements: 51.13_

- [ ]* 58.14 Write unit tests for document management
  - Test upload valid document
  - Test upload oversized document
  - Test upload invalid extension
  - Test re-upload rejected document
  - Test delete document
  - Test document progress calculation
  - _Requirements: 51.4, 51.5, 51.6, 51.7, 51.10, 51.14_



### 59. Platform Admin Verification Workflow (Req 52)

- [ ] 59.1 Create GetVerificationQueueQuery and handler
  - Filter by entity_type, verification_status, date_range
  - Support pagination
  - Return list of entities with document counts
  - _Requirements: 52.1, 52.2_

- [ ] 59.2 Create GetEntityVerificationDetailsQuery and handler
  - Get entity details (agency or supplier)
  - Get all documents with verification status
  - Generate presigned URLs for document preview
  - _Requirements: 52.3_

- [ ] 59.3 Create VerifyDocumentCommand and handler
  - Validate user is Platform Admin
  - Update document verification_status='verified'
  - Set verified_at timestamp and verified_by user_id
  - _Requirements: 52.4, 52.6_

- [ ] 59.4 Create RejectDocumentCommand and handler
  - Validate user is Platform Admin
  - Update document verification_status='rejected'
  - Save rejection_reason
  - Set verified_at timestamp and verified_by user_id
  - _Requirements: 52.5, 52.7_

- [ ] 59.5 Create ApproveEntityCommand and handler
  - Validate user is Platform Admin
  - Verify all mandatory documents are 'verified'
  - Update entity verification_status='verified'
  - Set verified_at timestamp and verified_by user_id
  - For agencies: set is_active=true
  - For suppliers: set status='active'
  - Send approval email to entity
  - _Requirements: 52.8, 52.9, 52.12_

- [ ] 59.6 Create RejectEntityCommand and handler
  - Validate user is Platform Admin
  - Update entity verification_status='rejected'
  - Increment verification_attempts
  - Save rejection_reason
  - Send rejection email to entity with details
  - _Requirements: 52.10, 52.11_

- [ ] 59.7 Implement verification_attempts limit check
  - Prevent approval if verification_attempts >= max_verification_attempts
  - Return appropriate error message
  - _Requirements: 52.13, 53.7_

- [ ] 59.8 Create GET /api/admin/verification-queue endpoint
  - Admin-only endpoint
  - Support query parameters for filtering
  - Return paginated results
  - _Requirements: 52.1, 52.2_

- [ ] 59.9 Create GET /api/admin/verification/{entity_type}/{entity_id} endpoint
  - Admin-only endpoint
  - Return entity details and documents
  - _Requirements: 52.3_

- [ ] 59.10 Create PUT /api/admin/documents/{id}/verify endpoint
  - Admin-only endpoint
  - Return success message
  - _Requirements: 52.4, 52.6_

- [ ] 59.11 Create PUT /api/admin/documents/{id}/reject endpoint
  - Admin-only endpoint
  - Accept rejection_reason in request body
  - Return success message
  - _Requirements: 52.5, 52.7_

- [ ] 59.12 Create POST /api/admin/verification/{entity_type}/{entity_id}/approve endpoint
  - Admin-only endpoint
  - Validate all mandatory documents verified
  - Return success message or error
  - _Requirements: 52.8, 52.9, 52.12_

- [ ] 59.13 Create POST /api/admin/verification/{entity_type}/{entity_id}/reject endpoint
  - Admin-only endpoint
  - Accept rejection_reason in request body
  - Return success message
  - _Requirements: 52.10, 52.11_

- [ ]* 59.14 Write unit tests for verification workflow
  - Test verify document
  - Test reject document
  - Test approve entity with all docs verified
  - Test approve entity with pending docs (should fail)
  - Test reject entity
  - Test verification attempts limit
  - _Requirements: 52.4, 52.5, 52.8, 52.9, 52.10, 52.11, 52.12, 52.13_

### 60. Re-submission After Rejection (Req 53)

- [ ] 60.1 Implement re-upload logic for rejected documents
  - Allow re-upload only if document is rejected
  - Delete old file from MinIO
  - Upload new file
  - Reset verification_status to 'pending'
  - _Requirements: 53.1, 53.2, 53.3_

- [ ] 60.2 Auto-update entity status when all docs re-uploaded
  - When all mandatory documents re-uploaded, set verification_status='awaiting_approval'
  - Send notification to Platform Admin
  - _Requirements: 53.4, 53.5_

- [ ] 60.3 Implement max_verification_attempts enforcement
  - Check verification_attempts < max_verification_attempts before allowing re-upload
  - Return error if limit reached
  - Display appropriate message to user
  - _Requirements: 53.6, 53.7_

- [ ] 60.4 Create ResetVerificationAttemptsCommand (Admin only)
  - Allow Platform Admin to reset verification_attempts if needed
  - _Requirements: 53.8_

- [ ] 60.5 Update document upload endpoint to handle re-submission
  - Check if entity can re-submit
  - Block upload if max attempts reached
  - _Requirements: 53.6, 53.7_

- [ ]* 60.6 Write unit tests for re-submission logic
  - Test re-upload rejected document
  - Test block upload when max attempts reached
  - Test auto-update status when all docs re-uploaded
  - Test admin reset verification attempts
  - _Requirements: 53.1, 53.2, 53.3, 53.4, 53.6, 53.7, 53.8_

### 61. Verification Status Management (Req 54)

- [ ] 61.1 Extend GetCurrentUserQuery to include verification_status
  - Return verification_status, verification_attempts, max_verification_attempts
  - _Requirements: 54.2_

- [ ] 61.2 Update JWT token to include verification_status claim
  - Add verification_status to token claims
  - Use for efficient authorization checks
  - _Requirements: 55.6_

- [ ] 61.3 Implement verification status checks in login flow
  - Return verification_status in login response
  - Frontend can redirect based on status
  - _Requirements: 54.4, 54.5, 54.6, 54.7_

- [ ] 61.4 Create GetDocumentProgressQuery (already in task 58.7)
  - Return all progress metrics
  - _Requirements: 54.3_

- [ ]* 61.5 Write unit tests for verification status management
  - Test GetCurrentUserQuery includes verification_status
  - Test JWT token includes verification_status claim
  - Test document progress calculation
  - _Requirements: 54.2, 54.3, 55.6_

### 62. Access Control During Verification (Req 55)

- [ ] 62.1 Create VerificationStatusMiddleware
  - Check verification_status from JWT token
  - Allow access to /api/auth and /api/documents for all
  - Allow full access for platform_admin
  - Block access to other endpoints if verification_status != 'verified'
  - Return 403 Forbidden with error code "VERIFICATION_REQUIRED"
  - _Requirements: 55.1, 55.2, 55.3, 55.4, 55.5_

- [ ] 62.2 Register VerificationStatusMiddleware in pipeline
  - Add after authentication middleware
  - Add before authorization middleware
  - _Requirements: 55.1_

- [ ] 62.3 Create [RequireVerified] authorization attribute (alternative approach)
  - Can be applied to controllers/actions that require verified status
  - _Requirements: 55.1, 55.2, 55.3_

- [ ] 62.4 Update existing endpoints with verification checks
  - Apply verification checks to all restricted endpoints
  - _Requirements: 55.2, 55.3_

- [ ]* 62.5 Write integration tests for access control
  - Test unverified agency cannot access restricted endpoints
  - Test unverified supplier cannot access restricted endpoints
  - Test verified agency can access all endpoints
  - Test platform admin can access all endpoints
  - Test unverified entity can access /api/documents
  - _Requirements: 55.1, 55.2, 55.3, 55.4, 55.5_

### 63. Email Notifications (Req 56)

- [ ] 63.1 Create email templates for verification workflow
  - Registration success template
  - Documents submitted template
  - Verification approved template
  - Verification rejected template
  - _Requirements: 56.1, 56.2, 56.3, 56.4_

- [ ] 63.2 Create IEmailService interface
  - Methods: SendRegistrationSuccessEmail, SendDocumentsSubmittedEmail, SendApprovalEmail, SendRejectionEmail, SendAdminNotificationEmail
  - _Requirements: 56.1, 56.2, 56.3, 56.4, 56.5, 56.6_

- [ ] 63.3 Implement ResendEmailService using Resend API
  - Install Resend NuGet package: `dotnet add package Resend`
  - Configure Resend API key in appsettings.json
  - Use email templates with HTML
  - Include proper formatting and branding
  - Include relevant links (upload page, admin verification page)
  - _Requirements: 56.7, 56.8_

- [ ] 63.4 Implement email sending in registration flow
  - Send to agency/supplier after registration
  - Send to platform admin for review
  - _Requirements: 56.1, 56.5_

- [ ] 63.5 Implement email sending in document submission flow
  - Send to agency/supplier when all docs uploaded
  - Send to platform admin for verification
  - _Requirements: 56.2, 56.6_

- [ ] 63.6 Implement email sending in approval/rejection flow
  - Send to agency/supplier with approval/rejection details
  - Include rejection_reason if rejected
  - _Requirements: 56.3, 56.4_

- [ ] 63.7 Implement email logging
  - Log all email sending attempts
  - Include recipient, subject, status (sent/failed)
  - _Requirements: 56.9_

- [ ] 63.8 Implement graceful error handling for email failures
  - Don't block main workflow if email fails
  - Log error and continue
  - _Requirements: 56.10_

- [ ]* 63.9 Write unit tests for email service
  - Test email template rendering
  - Test email sending (mock SMTP)
  - Test error handling
  - _Requirements: 56.1, 56.2, 56.3, 56.4, 56.9, 56.10_



### 64. Document Requirements Configuration (Req 50)

- [ ] 64.1 Create GetDocumentRequirementsQuery and handler
  - Filter by entity_type, service_type, is_active
  - Return list of document requirements
  - _Requirements: 50.8_

- [ ] 64.2 Create CreateDocumentRequirementCommand and handler
  - Validate all required fields
  - Create new document requirement
  - _Requirements: 50.9_

- [ ] 64.3 Create UpdateDocumentRequirementCommand and handler
  - Validate document requirement exists
  - Update fields
  - _Requirements: 50.10_

- [ ] 64.4 Create GET /api/admin/document-requirements endpoint
  - Admin-only endpoint
  - Support filtering by entity_type, service_type, is_active
  - _Requirements: 50.8_

- [ ] 64.5 Create POST /api/admin/document-requirements endpoint
  - Admin-only endpoint
  - Accept CreateDocumentRequirementCommand
  - _Requirements: 50.9_

- [ ] 64.6 Create PUT /api/admin/document-requirements/{id} endpoint
  - Admin-only endpoint
  - Accept UpdateDocumentRequirementCommand
  - _Requirements: 50.10_

- [ ]* 64.7 Write unit tests for document requirements management
  - Test create document requirement
  - Test update document requirement
  - Test get document requirements with filters
  - _Requirements: 50.8, 50.9, 50.10_

### 65. Audit Logging (Req 57)

- [ ] 65.1 Create audit_logs table (if not exists)
  - Fields: id, entity_type, entity_id, action_type, action_details, performed_by, performed_at
  - Indexes on entity_type, entity_id, action_type, performed_at
  - _Requirements: 57.1, 57.2, 57.3, 57.4, 57.5, 57.6_

- [ ] 65.2 Create IAuditLogService interface
  - Methods: LogDocumentUpload, LogDocumentVerification, LogDocumentRejection, LogEntityApproval, LogEntityRejection, LogDocumentDeletion
  - _Requirements: 57.1, 57.2, 57.3, 57.4, 57.5, 57.6_

- [ ] 65.3 Implement AuditLogService
  - Save audit logs to database
  - Include all required fields
  - _Requirements: 57.1, 57.2, 57.3, 57.4, 57.5, 57.6_

- [ ] 65.4 Integrate audit logging in document upload
  - Log entity_type, entity_id, document_type, file_name, uploaded_by, uploaded_at
  - _Requirements: 57.1_

- [ ] 65.5 Integrate audit logging in document verification
  - Log document_id, verified_by, verified_at
  - _Requirements: 57.2_

- [ ] 65.6 Integrate audit logging in document rejection
  - Log document_id, rejected_by, rejected_at, rejection_reason
  - _Requirements: 57.3_

- [ ] 65.7 Integrate audit logging in entity approval
  - Log entity_type, entity_id, approved_by, approved_at
  - _Requirements: 57.4_

- [ ] 65.8 Integrate audit logging in entity rejection
  - Log entity_type, entity_id, rejected_by, rejected_at, rejection_reason
  - _Requirements: 57.5_

- [ ] 65.9 Integrate audit logging in document deletion
  - Log document_id, deleted_by, deleted_at
  - _Requirements: 57.6_

- [ ] 65.10 Create GetAuditLogsQuery and handler
  - Filter by entity_type, entity_id, action_type, date_range
  - Support pagination
  - _Requirements: 57.7, 57.8_

- [ ] 65.11 Create GET /api/admin/audit-logs endpoint
  - Admin-only endpoint
  - Support filtering and pagination
  - _Requirements: 57.7, 57.8_

- [ ] 65.12 Implement audit log retention policy
  - Keep logs for at least 1 year
  - Include in database backup strategy
  - _Requirements: 57.9, 57.10_

- [ ]* 65.13 Write unit tests for audit logging
  - Test log document upload
  - Test log document verification
  - Test log entity approval
  - Test get audit logs with filters
  - _Requirements: 57.1, 57.2, 57.3, 57.4, 57.5, 57.6, 57.7, 57.8_

### 66. API Response Format Standardization

- [ ] 66.1 Ensure all new endpoints follow standardized response format
  - Success responses: { success: true, data: {...}, message: string, timestamp: ISO8601 }
  - Error responses: { success: false, error: { code: string, message: string, details: array }, timestamp: ISO8601 }
  - Paginated responses: include pagination object
  - _Requirements: 46.1, 46.2, 46.3_

- [ ] 66.2 Use snake_case for all JSON properties
  - Configure JSON serialization
  - Apply to all new DTOs
  - _Requirements: 46.4, 46.5, 46.6_

- [ ] 66.3 Include timestamp in all responses
  - Use ISO 8601 format (UTC)
  - _Requirements: 46.7_

- [ ] 66.4 Use standardized error codes
  - VALIDATION_ERROR, NOT_FOUND, UNAUTHORIZED, FORBIDDEN, BUSINESS_RULE_VIOLATION, INTERNAL_SERVER_ERROR, VERIFICATION_REQUIRED
  - _Requirements: 46.8, 46.9, 46.10, 46.11, 46.12, 46.13_

### 67. Integration Testing

- [ ] 67.1 Setup integration test project
  - Use WebApplicationFactory
  - Use TestContainers for PostgreSQL
  - Use TestContainers for MinIO (or mock)
  - _Requirements: All requirements_

- [ ] 67.2 Write integration tests for agency registration flow
  - Test complete registration flow
  - Test document upload flow
  - Test verification flow
  - Test re-submission flow
  - _Requirements: 47, 51, 52, 53_

- [ ] 67.3 Write integration tests for supplier registration flow
  - Test complete registration flow with service types
  - Test document checklist generation based on service types
  - Test document upload flow
  - Test verification flow
  - _Requirements: 48, 51, 52, 53_

- [ ] 67.4 Write integration tests for platform admin verification
  - Test verification queue
  - Test document verification
  - Test entity approval
  - Test entity rejection
  - _Requirements: 52_

- [ ] 67.5 Write integration tests for access control
  - Test unverified entity cannot access restricted endpoints
  - Test verified entity can access all endpoints
  - Test platform admin can access all endpoints
  - _Requirements: 55_

- [ ] 67.6 Write integration tests for MinIO file operations
  - Test file upload
  - Test file download
  - Test file deletion
  - Test error handling
  - _Requirements: 49, 51_

### 68. Documentation & Deployment

- [ ] 68.1 Update Swagger/OpenAPI documentation
  - Document all new endpoints
  - Include request/response examples
  - Document authentication requirements
  - _Requirements: All API endpoints_

- [ ] 68.2 Update README with MinIO setup instructions
  - Reference MINIO-SETUP-GUIDE.md
  - Include configuration steps
  - _Requirements: 49_

- [ ] 68.3 Update appsettings.json.example
  - Include FileStorage configuration
  - Include example values
  - _Requirements: 49.2_

- [ ] 68.4 Create database migration scripts
  - Include rollback scripts
  - Test on development database
  - _Requirements: 53_

- [ ] 68.5 Update deployment documentation
  - Include MinIO deployment steps
  - Include environment variables
  - Include security considerations
  - _Requirements: 49, Security_

### 69. Performance & Security

- [ ] 69.1 Implement rate limiting for registration endpoints
  - Prevent abuse of public registration endpoints
  - _Requirements: Security_

- [ ] 69.2 Implement file upload rate limiting
  - Prevent abuse of file upload endpoint
  - _Requirements: Security_

- [ ] 69.3 Implement virus scanning for uploaded files (optional)
  - Integrate with antivirus service
  - Scan files before saving to MinIO
  - _Requirements: Security_

- [ ] 69.4 Optimize database queries
  - Add indexes for verification_status
  - Add indexes for entity_documents queries
  - _Requirements: Performance_

- [ ] 69.5 Implement caching for document requirements
  - Cache document requirements configuration
  - Invalidate cache when requirements change
  - _Requirements: Performance_

- [ ] 69.6 Implement file upload progress tracking (optional)
  - Allow frontend to track upload progress
  - Use chunked upload for large files
  - _Requirements: UX_

---

## Task Summary for Self-Registration & KYC

**Total Tasks:** 17 sections (53-69)
**Total Sub-tasks:** ~150 tasks
**Estimated Effort:** 3-4 weeks (2 backend developers)

### Priority Breakdown:

**High Priority (Must Have):**
- Section 53: Database Schema Changes
- Section 54: MinIO Integration
- Section 55: Domain Entities
- Section 56: Agency Registration
- Section 57: Supplier Registration
- Section 58: Document Management
- Section 59: Admin Verification
- Section 62: Access Control

**Medium Priority (Should Have):**
- Section 60: Re-submission Logic
- Section 61: Verification Status
- Section 63: Email Notifications
- Section 64: Document Requirements Config
- Section 65: Audit Logging

**Low Priority (Nice to Have):**
- Section 66: Response Format (already standardized)
- Section 67: Integration Tests
- Section 68: Documentation
- Section 69: Performance & Security enhancements

### Dependencies:

1. Section 53 (Database) must be completed first
2. Section 54 (MinIO) must be completed before Section 58 (Document Upload)
3. Section 55 (Entities) must be completed before Section 56-57 (Registration)
4. Section 56-57 (Registration) must be completed before Section 58 (Document Upload)
5. Section 58 (Document Upload) must be completed before Section 59 (Admin Verification)
6. Section 62 (Access Control) should be completed early to enforce restrictions

### Recommended Implementation Order:

**Week 1:**
- Section 53: Database Schema Changes
- Section 54: MinIO Integration
- Section 55: Domain Entities Extension

**Week 2:**
- Section 56: Agency Self-Registration
- Section 57: Enhanced Supplier Self-Registration
- Section 62: Access Control Middleware

**Week 3:**
- Section 58: Document Upload & Management
- Section 61: Verification Status Management
- Section 64: Document Requirements Configuration

**Week 4:**
- Section 59: Platform Admin Verification Workflow
- Section 60: Re-submission After Rejection
- Section 63: Email Notifications
- Section 65: Audit Logging

**Week 5 (Optional):**
- Section 67: Integration Testing
- Section 68: Documentation
- Section 69: Performance & Security
- Bug fixes and refinements

