# Implementation Plan: Backend API Phase 1

## Overview

This implementation plan covers the development of the Tour & Travel ERP SaaS backend API over a 10-week period (Feb 11 - Apr 26, 2026). The API is built with .NET 8 using Clean Architecture, CQRS pattern with MediatR, and PostgreSQL 16 with Row-Level Security for multi-tenancy. The plan is structured to enable parallel development with the frontend and includes comprehensive testing with property-based tests for all correctness properties.

**Timeline**: 10 weeks (Feb 11 - Apr 26, 2026)
**Technology**: .NET 8, PostgreSQL 16, Entity Framework Core 8, MediatR, JWT Authentication
**Architecture**: Clean Architecture with CQRS pattern

## Tasks

### Week 1: Project Setup and Foundation (Feb 11-17)

- [ ] 1. Initialize solution structure and core projects
  - Create .NET 8 solution with Clean Architecture layers
  - Set up projects: Domain, Application, Infrastructure, API
  - Configure project references and dependencies
  - Add NuGet packages: EF Core, MediatR, FluentValidation, Serilog, BCrypt, JWT
  - _Requirements: All_

- [ ] 2. Set up database schema and migrations
  - [ ] 2.1 Create Entity Framework Core DbContext and entity configurations
    - Configure all entities with Fluent API
    - Set up value converters for enums and JSONB
    - Define indexes for performance optimization
    - _Requirements: 16.7, 19.1, 19.2_

  - [ ] 2.2 Create initial database migration
    - Generate migration for all tables
    - Add database triggers for code generation (agency_code, supplier_code, etc.)
    - Add Row-Level Security policies for multi-tenancy
    - _Requirements: 2.1, 2.3, 2.4, 23.1, 23.4_

  - [ ] 2.3 Create seed data script
    - Create sample users for all roles (platform admin, agency staff, supplier, customer)
    - Create sample agencies, suppliers, services, packages, and bookings
    - Implement idempotency check to prevent duplicate data
    - _Requirements: 24.1, 24.2, 24.3_


- [ ] 3. Implement authentication and JWT infrastructure
  - [ ] 3.1 Create authentication service with JWT token generation
    - Implement IAuthenticationService interface
    - Generate JWT tokens with required claims (userId, email, userType, agencyId, supplierId)
    - Implement BCrypt password hashing and verification
    - Implement refresh token functionality
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 1.8_

  - [ ]* 3.2 Write property test for JWT token completeness
    - **Property 1: JWT Token Completeness**
    - **Validates: Requirements 1.1**

  - [ ]* 3.3 Write property test for password hashing security
    - **Property 2: Password Hashing Security**
    - **Validates: Requirements 1.5**

  - [ ]* 3.4 Write property test for authentication round trip
    - **Property 3: Authentication Round Trip**
    - **Validates: Requirements 1.3, 1.8**

  - [ ]* 3.5 Write property test for invalid credentials rejection
    - **Property 4: Invalid Credentials Rejection**
    - **Validates: Requirements 1.2**

- [ ] 4. Checkpoint - Verify database setup and authentication
  - Ensure all migrations apply successfully
  - Ensure seed data creates sample records
  - Ensure JWT token generation works correctly
  - Ask the user if questions arise

### Week 2: Core Infrastructure and Multi-Tenancy (Feb 18-24)

- [ ] 5. Implement CQRS infrastructure with MediatR
  - Set up MediatR pipeline behaviors
  - Create base command and query classes
  - Implement validation pipeline behavior with FluentValidation
  - Create common DTOs and response wrappers (ApiResponse, ApiErrorResponse)
  - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

- [ ] 6. Implement multi-tenancy middleware and RLS
  - [ ] 6.1 Create tenant context middleware
    - Extract tenant ID from JWT token or X-Tenant-ID header
    - Validate tenant context matches JWT claims
    - Set PostgreSQL session variables (app.current_agency_id, app.current_user_type)
    - Store tenant context in HttpContext.Items
    - _Requirements: 1.6, 2.2, 2.4_

  - [ ]* 6.2 Write property test for multi-tenant data isolation
    - **Property 6: Multi-Tenant Data Isolation**
    - **Validates: Requirements 2.1, 2.3**

  - [ ]* 6.3 Write property test for automatic tenant association
    - **Property 7: Automatic Tenant Association**
    - **Validates: Requirements 2.2**

  - [ ]* 6.4 Write property test for platform admin full access
    - **Property 8: Platform Admin Full Access**
    - **Validates: Requirements 2.5**

  - [ ]* 6.5 Write property test for supplier data isolation
    - **Property 9: Supplier Data Isolation**
    - **Validates: Requirements 2.6, 6.4**

- [ ] 7. Implement exception handling and logging
  - [ ] 7.1 Create global exception handling middleware
    - Handle ValidationException, UnauthorizedException, ForbiddenException, NotFoundException, ConflictException
    - Return consistent error responses with trace IDs
    - Log all exceptions with full details
    - _Requirements: 17.1, 17.2, 17.6_

  - [ ] 7.2 Configure Serilog structured logging
    - Set up console and file sinks with JSON formatting
    - Configure log enrichers (request ID, user ID, tenant ID)
    - Implement request logging middleware
    - _Requirements: 17.3, 17.4, 17.5_

  - [ ]* 7.3 Write property test for exception logging completeness
    - **Property 47: Exception Logging Completeness**
    - **Validates: Requirements 17.1, 17.2, 17.6**

  - [ ]* 7.4 Write property test for sensitive data exclusion
    - **Property 49: Sensitive Data Exclusion**
    - **Validates: Requirements 17.6**

- [ ] 8. Implement repository pattern and unit of work
  - Create generic repository implementation
  - Create specific repositories (AgencyRepository, SupplierRepository, PackageRepository, BookingRepository)
  - Implement unit of work for transaction management
  - _Requirements: 19.4_

- [ ] 9. Checkpoint - Verify core infrastructure
  - Ensure CQRS pipeline works with validation
  - Ensure multi-tenancy middleware correctly isolates data
  - Ensure exception handling returns proper error responses
  - Ask the user if questions arise

### Week 3: Platform Admin Module (Feb 25 - Mar 3)

- [ ] 10. Implement agency management commands and queries
  - [ ] 10.1 Create CreateAgencyCommand with handler and validator
    - Generate unique agency code
    - Validate required fields (company name, email)
    - Store agency details in database
    - _Requirements: 3.1, 3.2_

  - [ ] 10.2 Create GetAgenciesQuery with pagination and filtering
    - Support pagination with page and perPage parameters
    - Support filtering by status (is_active)
    - Return agencies with pagination metadata
    - _Requirements: 3.3, 3.4_

  - [ ] 10.3 Create UpdateAgencyCommand and UpdateAgencyStatusCommand
    - Validate changes before updating
    - Update agency status and prevent access if suspended
    - _Requirements: 3.5, 3.6_

  - [ ]* 10.4 Write property test for unique code generation
    - **Property 10: Unique Code Generation**
    - **Validates: Requirements 3.1, 6.1, 9.1, 10.1, 14.1**

  - [ ]* 10.5 Write property test for required field validation
    - **Property 11: Required Field Validation**
    - **Validates: Requirements 3.2, 6.2, 9.2, 10.2, 14.2, 14.3, 16.6**

  - [ ]* 10.6 Write property test for agency status enforcement
    - **Property 16: Agency Status Enforcement**
    - **Validates: Requirements 3.6**

- [ ] 11. Implement supplier approval workflow
  - [ ] 11.1 Create ApproveSupplierCommand and RejectSupplierCommand
    - Update supplier status to "active" or "rejected"
    - Record approval timestamp and approver
    - _Requirements: 4.3, 4.4_

  - [ ] 11.2 Create GetSuppliersQuery with filtering by approval status
    - Support filtering by status (pending, active, rejected)
    - Return suppliers with pagination
    - _Requirements: 4.2_

  - [ ]* 11.3 Write property test for supplier approval workflow
    - **Property 17: Supplier Approval Workflow**
    - **Validates: Requirements 4.1, 4.3**

  - [ ]* 11.4 Write property test for supplier status enforcement
    - **Property 18: Supplier Status Enforcement**
    - **Validates: Requirements 4.4, 4.5**

- [ ] 12. Implement platform admin dashboard statistics
  - [ ] 12.1 Create GetDashboardStatsQuery for platform admin
    - Return count of active agencies
    - Return count of suppliers by status
    - Return total count of bookings
    - Use efficient database aggregation queries
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

  - [ ]* 12.2 Write property test for dashboard aggregation correctness
    - **Property 19: Dashboard Aggregation Correctness**
    - **Validates: Requirements 5.1, 5.2, 5.3, 7.1, 7.2, 12.1, 12.2, 12.3, 12.4**

- [ ] 13. Create platform admin API controllers
  - Create AgenciesController with CRUD endpoints
  - Create SuppliersController with approval endpoints
  - Create AdminDashboardController with statistics endpoint
  - Add authorization filters for platform admin role
  - _Requirements: 1.7_

- [ ] 14. Checkpoint - Verify platform admin module
  - Ensure agency CRUD operations work correctly
  - Ensure supplier approval workflow functions properly
  - Ensure dashboard statistics return accurate counts
  - Ask the user if questions arise


### Week 4: Supplier Module (Mar 4-10)

- [ ] 15. Implement supplier service management commands
  - [ ] 15.1 Create CreateServiceCommand with handler and validator
    - Generate unique service code
    - Validate service type, name, and base price
    - Store service-specific details in JSONB field
    - _Requirements: 6.1, 6.2, 6.3_

  - [ ] 15.2 Create UpdateServiceCommand with validation
    - Validate changes before updating
    - Update service record in database
    - _Requirements: 6.5_

  - [ ] 15.3 Create PublishServiceCommand and UnpublishServiceCommand
    - Update service status to "published" or "draft"
    - Record published_at timestamp
    - Make service visible/hidden to agencies
    - _Requirements: 6.6, 6.7_

  - [ ] 15.4 Create DeleteServiceCommand with constraint checking
    - Prevent deletion if service is included in published packages
    - Return conflict error if deletion not allowed
    - _Requirements: 6.8_

  - [ ]* 15.5 Write property test for JSONB serialization round trip
    - **Property 20: JSONB Serialization Round Trip**
    - **Validates: Requirements 6.3, 8.4**

  - [ ]* 15.6 Write property test for service visibility workflow
    - **Property 21: Service Visibility Workflow**
    - **Validates: Requirements 6.6, 6.7, 8.1**

- [ ] 16. Implement supplier service queries
  - [ ] 16.1 Create GetServicesQuery for supplier (my services)
    - Return only services belonging to authenticated supplier
    - Support pagination and filtering by status
    - _Requirements: 6.4_

  - [ ] 16.2 Create GetServiceByIdQuery with authorization
    - Verify supplier owns the service
    - Return complete service details including JSONB
    - _Requirements: 6.4_

- [ ] 17. Implement supplier dashboard statistics
  - Create GetSupplierDashboardStatsQuery
  - Return count of services by status
  - Return count of services in active packages
  - _Requirements: 7.1, 7.2, 7.3_

- [ ] 18. Create supplier API controllers
  - Create SupplierServicesController with CRUD endpoints
  - Create SupplierDashboardController with statistics endpoint
  - Add authorization filters for supplier role
  - _Requirements: 1.7_

- [ ] 19. Checkpoint - Verify supplier module
  - Ensure service CRUD operations work correctly
  - Ensure publish/unpublish workflow functions properly
  - Ensure supplier can only access their own services
  - Ask the user if questions arise

### Week 5: Agency Module - Package Management (Mar 11-17)

- [ ] 20. Implement package management commands
  - [ ] 20.1 Create CreatePackageCommand with handler and validator
    - Generate unique package code
    - Validate package type, name, duration, and pricing
    - Validate selling price >= base cost
    - Create package_services records for all services
    - Calculate base cost from service costs
    - Apply markup (fixed or percentage) to calculate selling price
    - Associate package with authenticated agency
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [ ]* 20.2 Write property test for package pricing calculation
    - **Property 22: Package Pricing Calculation**
    - **Validates: Requirements 9.5, 9.6**

  - [ ]* 20.3 Write property test for package pricing constraint
    - **Property 23: Package Pricing Constraint**
    - **Validates: Requirements 9.3**

  - [ ]* 20.4 Write property test for package service relationship
    - **Property 24: Package Service Relationship**
    - **Validates: Requirements 9.4**

  - [ ] 20.5 Create UpdatePackageCommand with validation
    - Validate changes before updating
    - Recalculate pricing if services or markup changed
    - _Requirements: 9.8_

  - [ ] 20.6 Create PublishPackageCommand with visibility control
    - Update package status to "published"
    - Set visibility to "public" or "private"
    - Record published_at timestamp
    - _Requirements: 9.9_

  - [ ] 20.7 Create DeletePackageCommand with constraint checking
    - Prevent deletion if package has confirmed bookings
    - Return conflict error if deletion not allowed
    - _Requirements: 9.10_

  - [ ]* 20.8 Write property test for package visibility workflow
    - **Property 25: Package Visibility Workflow**
    - **Validates: Requirements 9.9, 13.1**

  - [ ]* 20.9 Write property test for referential integrity protection
    - **Property 38: Referential Integrity Protection**
    - **Validates: Requirements 3.7, 6.8, 9.10, 10.7**

- [ ] 21. Implement package queries
  - [ ] 21.1 Create GetPackagesQuery for agency (my packages)
    - Return only packages belonging to authenticated agency
    - Support pagination, filtering by type and status
    - Apply RLS policies automatically
    - _Requirements: 9.7_

  - [ ] 21.2 Create GetPackageByIdQuery with authorization
    - Verify agency owns the package
    - Return complete package details including services and departures
    - _Requirements: 9.7_

- [ ] 22. Implement agency browse supplier services
  - [ ] 22.1 Create GetMarketplaceServicesQuery
    - Return only published services with visibility "marketplace"
    - Support filtering by service type
    - Support searching by name
    - Support pagination
    - _Requirements: 8.1, 8.2, 8.3, 8.5_

  - [ ] 22.2 Create GetMarketplaceServiceByIdQuery
    - Return complete service details including JSONB
    - _Requirements: 8.4_

  - [ ]* 22.3 Write property test for pagination correctness
    - **Property 12: Pagination Correctness**
    - **Validates: Requirements 3.3, 8.5, 13.7, 15.3, 19.3**

  - [ ]* 22.4 Write property test for filter correctness
    - **Property 13: Filter Correctness**
    - **Validates: Requirements 3.4, 4.2, 8.2, 11.2, 13.2**

  - [ ]* 22.5 Write property test for search correctness
    - **Property 14: Search Correctness**
    - **Validates: Requirements 8.3, 11.3, 13.3**

- [ ] 23. Create package API controllers
  - Create PackagesController with CRUD endpoints
  - Create SupplierServicesController (agency view) for browsing marketplace
  - Add authorization filters for agency staff role
  - Add tenant context validation
  - _Requirements: 1.6, 1.7_

- [ ] 24. Checkpoint - Verify package management
  - Ensure package CRUD operations work correctly
  - Ensure pricing calculations are accurate
  - Ensure agencies can only access their own packages
  - Ensure agencies can browse marketplace services
  - Ask the user if questions arise


### Week 6: Agency Module - Booking Management (Mar 18-24)

- [ ] 25. Implement package departure management
  - [ ] 25.1 Create CreateDepartureCommand with handler and validator
    - Generate unique departure code
    - Validate departure date, return date, and total quota
    - Initialize available quota equal to total quota
    - Associate departure with package
    - _Requirements: 10.1, 10.2, 10.3_

  - [ ] 25.2 Create UpdateDepartureCommand with quota validation
    - Validate available quota does not exceed total quota
    - Prevent invalid quota updates
    - _Requirements: 10.6_

  - [ ] 25.3 Create DeleteDepartureCommand with constraint checking
    - Prevent deletion if departure has confirmed bookings
    - Return conflict error if deletion not allowed
    - _Requirements: 10.7_

  - [ ]* 25.4 Write property test for departure quota initialization
    - **Property 26: Departure Quota Initialization**
    - **Validates: Requirements 10.3**

  - [ ]* 25.5 Write property test for departure quota invariant
    - **Property 27: Departure Quota Invariant**
    - **Validates: Requirements 10.6**

- [ ] 26. Implement booking approval workflow
  - [ ] 26.1 Create ApproveBookingCommand with quota management
    - Update booking status to "approved"
    - Decrement departure available quota by traveler count
    - Validate sufficient quota available before approval
    - Record approval timestamp and approver
    - _Requirements: 11.5, 11.9_

  - [ ] 26.2 Create RejectBookingCommand
    - Update booking status to "rejected"
    - Do not affect departure quota
    - _Requirements: 11.6_

  - [ ] 26.3 Create CancelBookingCommand with quota restoration
    - Update booking status to "cancelled"
    - Increment departure available quota by traveler count
    - _Requirements: 11.7_

  - [ ]* 26.4 Write property test for booking approval quota decrement
    - **Property 28: Booking Approval Quota Decrement**
    - **Validates: Requirements 10.4, 11.5**

  - [ ]* 26.5 Write property test for booking cancellation quota increment
    - **Property 29: Booking Cancellation Quota Increment**
    - **Validates: Requirements 10.5, 11.7**

  - [ ]* 26.6 Write property test for quota management round trip
    - **Property 30: Quota Management Round Trip**
    - **Validates: Requirements 10.4, 10.5**

  - [ ]* 26.7 Write property test for insufficient quota prevention
    - **Property 31: Insufficient Quota Prevention**
    - **Validates: Requirements 11.9, 14.4**

  - [ ]* 26.8 Write property test for booking status workflow
    - **Property 32: Booking Status Workflow**
    - **Validates: Requirements 11.5, 11.6, 14.6**

  - [ ]* 26.9 Write property test for booking rejection quota preservation
    - **Property 34: Booking Rejection Quota Preservation**
    - **Validates: Requirements 11.6**

- [ ] 27. Implement booking queries for agency
  - [ ] 27.1 Create GetBookingsQuery with filtering and search
    - Return only bookings belonging to authenticated agency
    - Support filtering by status
    - Support searching by booking reference or customer name
    - Support pagination
    - Apply RLS policies automatically
    - _Requirements: 11.1, 11.2, 11.3_

  - [ ] 27.2 Create GetBookingByIdQuery with authorization
    - Verify agency owns the booking
    - Return complete booking details including traveler list
    - _Requirements: 11.4_

  - [ ] 27.3 Create GetPendingBookingsQuery
    - Return bookings with status "pending" for approval
    - Support pagination
    - _Requirements: 11.2_

- [ ] 28. Implement manual booking creation for agency
  - [ ] 28.1 Create CreateManualBookingCommand
    - Create booking with status "approved" (auto-approve)
    - Decrement departure quota immediately
    - Create traveler records
    - Calculate total amount
    - _Requirements: 11.8_

  - [ ]* 28.2 Write property test for manual booking auto-approval
    - **Property 33: Manual Booking Auto-Approval**
    - **Validates: Requirements 11.8**

- [ ] 29. Implement agency dashboard statistics
  - Create GetAgencyDashboardStatsQuery
  - Return count of pending bookings
  - Return count of confirmed bookings
  - Return count of published packages
  - Return count of upcoming departures
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 30. Create booking API controllers
  - Create BookingsController with approval/rejection/cancellation endpoints
  - Create DeparturesController for package departure management
  - Create AgencyDashboardController with statistics endpoint
  - Add authorization filters for agency staff role
  - Add tenant context validation
  - _Requirements: 1.6, 1.7_

- [ ] 31. Checkpoint - Verify booking management
  - Ensure booking approval/rejection/cancellation work correctly
  - Ensure quota management functions properly
  - Ensure agencies can only access their own bookings
  - Ask the user if questions arise

### Week 7: Traveler Module (Mar 25-31)

- [ ] 32. Implement traveler browse packages
  - [ ] 32.1 Create GetPublicPackagesQuery
    - Return only published packages with visibility "public"
    - Support filtering by package type
    - Support searching by name
    - Support filtering by price range
    - Support sorting by price, date, and name
    - Support pagination
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.7_

  - [ ] 32.2 Create GetPublicPackageByIdQuery
    - Return complete package details including services and available departures
    - Only return published packages
    - _Requirements: 13.6_

  - [ ]* 32.3 Write property test for sorting correctness
    - **Property 15: Sorting Correctness**
    - **Validates: Requirements 13.5**

- [ ] 33. Implement traveler booking creation
  - [ ] 33.1 Create CreateBookingCommand with validation
    - Generate unique booking reference
    - Validate package ID, departure ID, and customer details
    - Validate at least one traveler provided
    - Validate sufficient quota available
    - Create traveler records for each traveler
    - Set booking status to "pending"
    - Calculate total amount (selling price × traveler count)
    - Validate mahram relationship for female travelers
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8, 14.9_

  - [ ]* 33.2 Write property test for booking amount calculation
    - **Property 35: Booking Amount Calculation**
    - **Validates: Requirements 14.7**

  - [ ]* 33.3 Write property test for traveler record completeness
    - **Property 36: Traveler Record Completeness**
    - **Validates: Requirements 14.5**

  - [ ]* 33.4 Write property test for mahram relationship validation
    - **Property 37: Mahram Relationship Validation**
    - **Validates: Requirements 14.8, 14.9**

- [ ] 34. Implement traveler booking queries
  - [ ] 34.1 Create GetMyBookingsQuery
    - Return only bookings created by authenticated traveler
    - Support pagination
    - _Requirements: 15.1, 15.3_

  - [ ] 34.2 Create GetMyBookingByIdQuery
    - Return complete booking details including package and traveler list
    - Verify traveler owns the booking
    - _Requirements: 15.2_

- [ ] 35. Create traveler API controllers
  - Create TravelerPackagesController for browsing public packages
  - Create TravelerBookingsController for creating and viewing bookings
  - Add authorization filters for customer role
  - _Requirements: 1.7_

- [ ] 36. Checkpoint - Verify traveler module
  - Ensure travelers can browse public packages
  - Ensure travelers can create bookings with validation
  - Ensure travelers can only view their own bookings
  - Ask the user if questions arise


### Week 8: API Documentation, Validation, and Bug Fixes (Apr 1-7)

- [ ] 37. Implement comprehensive data validation
  - [ ] 37.1 Create FluentValidation validators for all commands
    - Validate email format for all email fields
    - Validate numeric fields are within acceptable ranges
    - Validate date fields and logical date ranges
    - Validate foreign key references exist
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.7_

  - [ ]* 37.2 Write property test for email format validation
    - **Property 39: Email Format Validation**
    - **Validates: Requirements 16.3**

  - [ ]* 37.3 Write property test for numeric range validation
    - **Property 40: Numeric Range Validation**
    - **Validates: Requirements 16.4**

  - [ ]* 37.4 Write property test for date range validation
    - **Property 41: Date Range Validation**
    - **Validates: Requirements 16.5**

  - [ ]* 37.5 Write property test for foreign key validation
    - **Property 42: Foreign Key Validation**
    - **Validates: Requirements 16.7**

- [ ] 38. Implement API response format consistency
  - [ ] 38.1 Ensure all endpoints return consistent response format
    - Successful responses with success=true and data object
    - Failed responses with success=false and error object
    - Include pagination metadata for list endpoints
    - Use standard HTTP status codes
    - Return JSON content type for all responses
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5_

  - [ ]* 38.2 Write property test for API response format consistency
    - **Property 43: API Response Format Consistency**
    - **Validates: Requirements 18.1, 18.2**

  - [ ]* 38.3 Write property test for HTTP status code correctness
    - **Property 44: HTTP Status Code Correctness**
    - **Validates: Requirements 18.4**

  - [ ]* 38.4 Write property test for pagination metadata presence
    - **Property 45: Pagination Metadata Presence**
    - **Validates: Requirements 18.3**

  - [ ]* 38.5 Write property test for JSON content type
    - **Property 46: JSON Content Type**
    - **Validates: Requirements 18.5**

- [ ] 39. Implement Swagger/OpenAPI documentation
  - [ ] 39.1 Configure Swashbuckle for API documentation
    - Expose Swagger UI at /swagger endpoint
    - Include all endpoints with request/response schemas
    - Document authentication requirements
    - Add example requests and responses
    - Enable interactive testing
    - _Requirements: 21.1, 21.2, 21.3, 21.4, 21.5_

  - [ ] 39.2 Add XML documentation comments to controllers and DTOs
    - Document all public APIs with summary and remarks
    - Document all parameters and return types
    - Include example values for complex types

- [ ] 40. Implement health check endpoint
  - Create health check endpoint at /health
  - Verify database connectivity
  - Return 200 with healthy status on success
  - Return 503 with unhealthy status on failure
  - _Requirements: 22.1, 22.2, 22.3, 22.4_

- [ ] 41. Implement role-based authorization
  - [ ] 41.1 Create authorization policies for each role
    - Platform admin policy
    - Agency staff policy
    - Supplier policy
    - Customer policy
    - _Requirements: 1.7_

  - [ ]* 41.2 Write property test for role-based authorization
    - **Property 5: Role-Based Authorization**
    - **Validates: Requirements 1.7**

- [ ] 42. Bug fixes and refinements
  - Review all endpoints for edge cases
  - Fix any validation issues discovered during testing
  - Optimize database queries for performance
  - Ensure all error messages are clear and helpful
  - _Requirements: All_

- [ ] 43. Checkpoint - Verify API completeness
  - Ensure all endpoints are documented in Swagger
  - Ensure all validation rules are enforced
  - Ensure health check endpoint works correctly
  - Ask the user if questions arise

### Week 9: Property-Based Testing and Integration Testing (Apr 8-14)

- [ ] 44. Set up property-based testing infrastructure
  - [ ] 44.1 Install and configure FsCheck for .NET
    - Add FsCheck NuGet package
    - Configure test project for property-based tests
    - Create custom generators for domain entities
    - _Requirements: All correctness properties_

  - [ ] 44.2 Create generators for all domain entities
    - User generator with valid/invalid credentials
    - Agency generator with various statuses
    - Supplier generator with various statuses
    - Service generator with JSONB details
    - Package generator with services and pricing
    - Departure generator with quota management
    - Booking generator with travelers
    - Traveler generator with mahram relationships

- [ ] 45. Implement remaining property-based tests
  - [ ]* 45.1 Write property test for request logging completeness
    - **Property 48: Request Logging Completeness**
    - **Validates: Requirements 17.3**

  - [ ]* 45.2 Write property test for seed data idempotency
    - **Property 50: Seed Data Idempotency**
    - **Validates: Requirements 24.3**

- [ ] 46. Set up integration testing with Testcontainers
  - [ ] 46.1 Configure Testcontainers for PostgreSQL
    - Create IntegrationTestBase class
    - Start PostgreSQL container before tests
    - Apply migrations to test database
    - Dispose container after tests
    - _Requirements: All_

  - [ ] 46.2 Write integration tests for critical workflows
    - Test package creation with services
    - Test booking creation with travelers
    - Test booking approval with quota decrement
    - Test booking cancellation with quota increment
    - Test multi-tenant data isolation
    - Test RLS policies enforcement

- [ ] 47. Set up end-to-end testing with WebApplicationFactory
  - [ ] 47.1 Create E2E test infrastructure
    - Configure WebApplicationFactory
    - Create test HTTP client
    - Implement authentication helper methods
    - _Requirements: All_

  - [ ] 47.2 Write E2E tests for user journeys
    - Test traveler booking flow (browse → create booking → view booking)
    - Test agency approval flow (view pending → approve → verify quota)
    - Test supplier service flow (create → publish → verify visibility)
    - Test platform admin flow (create agency → approve supplier)

- [ ] 48. Run all tests and verify coverage
  - Execute all unit tests
  - Execute all property-based tests (100 iterations each)
  - Execute all integration tests
  - Execute all E2E tests
  - Generate code coverage report
  - Ensure coverage >= 80%
  - _Requirements: All_

- [ ] 49. Checkpoint - Verify testing completeness
  - Ensure all property tests pass
  - Ensure all integration tests pass
  - Ensure all E2E tests pass
  - Ensure code coverage meets target
  - Ask the user if questions arise

### Week 10: Docker Setup, Deployment, and Documentation (Apr 15-26)

- [ ] 50. Create Docker configuration
  - [ ] 50.1 Create multi-stage Dockerfile
    - Build stage with .NET SDK
    - Publish stage for optimized build
    - Runtime stage with ASP.NET runtime
    - Configure non-root user for security
    - Add health check configuration
    - _Requirements: 20.1_

  - [ ] 50.2 Create Docker Compose configuration
    - Configure PostgreSQL service with persistent volume
    - Configure API service with environment variables
    - Configure health checks for both services
    - Set up network for inter-service communication
    - Add PgAdmin service for development (optional profile)
    - _Requirements: 20.2, 20.3, 20.4, 20.5_

  - [ ] 50.3 Create database initialization script
    - Enable UUID and pg_trgm extensions
    - Create custom PostgreSQL types (enums)
    - Configure PostgreSQL performance settings
    - _Requirements: 20.3_

  - [ ] 50.4 Create environment variables configuration
    - Database connection settings
    - JWT configuration (secret, issuer, audience, expiry)
    - Logging configuration
    - CORS configuration
    - Pagination configuration
    - Feature flags
    - _Requirements: 20.6_

- [ ] 51. Test Docker deployment
  - [ ] 51.1 Build and start Docker containers
    - Build API Docker image
    - Start PostgreSQL and API containers
    - Verify containers are healthy
    - Verify API can connect to database
    - _Requirements: 20.2, 20.3, 20.5_

  - [ ] 51.2 Test API endpoints in Docker environment
    - Test authentication endpoints
    - Test CRUD operations for all modules
    - Test multi-tenancy isolation
    - Test health check endpoint
    - Verify Swagger documentation is accessible

- [ ] 52. Create deployment documentation
  - [ ] 52.1 Write README.md with setup instructions
    - Prerequisites (Docker, .NET SDK)
    - Local development setup
    - Docker deployment instructions
    - Environment variables documentation
    - API endpoint documentation
    - Testing instructions

  - [ ] 52.2 Write API integration guide for frontend
    - Authentication flow
    - API endpoint reference
    - Request/response examples
    - Error handling guide
    - Multi-tenancy header requirements

  - [ ] 52.3 Write database migration guide
    - How to create new migrations
    - How to apply migrations
    - How to rollback migrations
    - Seed data management

- [ ] 53. Performance optimization
  - [ ] 53.1 Add database indexes for frequently queried fields
    - Review query patterns
    - Add missing indexes
    - Verify index usage with EXPLAIN
    - _Requirements: 19.1_

  - [ ] 53.2 Optimize database queries
    - Use efficient joins to minimize round trips
    - Use read-only connections for queries
    - Implement connection pooling
    - _Requirements: 19.2, 19.4, 19.5_

  - [ ] 53.3 Configure pagination limits
    - Set default page size to 20
    - Set maximum page size to 100
    - _Requirements: 19.3_

- [ ] 54. Security hardening
  - Review all endpoints for authorization
  - Ensure sensitive data is not logged
  - Validate all user inputs
  - Configure CORS properly
  - Use HTTPS in production
  - Rotate JWT secrets regularly
  - _Requirements: 17.6_

- [ ] 55. Final integration testing with frontend
  - Coordinate with frontend team for integration testing
  - Test all API endpoints with frontend application
  - Verify authentication flow works end-to-end
  - Verify multi-tenancy works correctly
  - Fix any integration issues discovered

- [ ] 56. Final checkpoint - Production readiness
  - Ensure all tests pass
  - Ensure Docker deployment works correctly
  - Ensure documentation is complete
  - Ensure performance meets requirements
  - Ensure security measures are in place
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional property-based testing tasks and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation and provide opportunities for user feedback
- Property tests validate universal correctness properties with minimum 100 iterations each
- Integration tests use Testcontainers for real database testing
- E2E tests validate complete user journeys
- The implementation plan is structured to enable parallel development with the frontend
- Multi-tenancy and RLS are critical features that must be thoroughly tested
- All correctness properties from the design document have corresponding property-based tests

## Timeline Summary

| Week | Focus Area | Key Deliverables |
|------|------------|------------------|
| 1 | Foundation | Project setup, database schema, authentication |
| 2 | Infrastructure | CQRS, multi-tenancy, logging, repositories |
| 3 | Platform Admin | Agency management, supplier approval, dashboard |
| 4 | Supplier | Service management, dashboard |
| 5 | Agency - Packages | Package CRUD, pricing, marketplace browsing |
| 6 | Agency - Bookings | Booking approval, quota management, departures |
| 7 | Traveler | Browse packages, create bookings |
| 8 | Polish | Validation, documentation, bug fixes |
| 9 | Testing | Property tests, integration tests, E2E tests |
| 10 | Deployment | Docker, documentation, optimization, production readiness |

