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

- [ ] 1.1 Initialize .NET 8 Web API project with Clean Architecture structure
- [ ] 1.2 Setup solution with 4 projects: Domain, Application, Infrastructure, API
- [ ] 1.3 Configure PostgreSQL 16 connection with Entity Framework Core 8
- [ ] 1.4 Setup Docker and Docker Compose for local development
- [ ] 1.5 Configure Serilog for structured logging
- [ ] 1.6 Setup Swagger/OpenAPI documentation
- [ ] 1.7 Configure CORS policy for frontend integration
- [ ] 1.8 Setup health check endpoint (/health)

### 2. Database Schema & Migrations

- [ ] 2.1 Create all 24+ domain entities with proper relationships
- [ ] 2.2 Create DbContext with entity configurations
- [ ] 2.3 Configure Row-Level Security (RLS) policies for multi-tenancy
- [ ] 2.4 Create initial migration with all tables
- [ ] 2.5 Create database indexes for performance
- [ ] 2.6 Create get_service_price_for_date() database function
- [ ] 2.7 Create seed data for document_types
- [ ] 2.8 Create seed data for task_templates
- [ ] 2.9 Create seed data for notification_templates
- [ ] 2.10 Create development seed data (agencies, suppliers, services)


### 3. Authentication & Authorization (Req 2)

- [ ] 3.1 Implement JWT token generation and validation service
- [ ] 3.2 Implement BCrypt password hashing service
- [ ] 3.3 Create authentication middleware for JWT validation
- [ ] 3.4 Create authorization policies for three user types
- [ ] 3.5 Implement tenant context extraction from JWT
- [ ] 3.6 Create LoginCommand and handler
- [ ] 3.7 Create RegisterCommand and handler
- [ ] 3.8 Create RefreshTokenCommand and handler
- [ ] 3.9 Create authentication API endpoints
- [ ] 3.10 Write unit tests for authentication services

### 4. Multi-Tenancy Implementation (Req 1)

- [ ] 4.1 Implement ITenantContextService interface
- [ ] 4.2 Create middleware to set app.current_agency_id session variable
- [ ] 4.3 Configure RLS policy enforcement in DbContext
- [ ] 4.4 Implement tenant isolation validation
- [ ] 4.5 Write unit tests for multi-tenancy logic
- [ ] 4.6 Test cross-tenant access prevention

### 5. CQRS & MediatR Setup

- [ ] 5.1 Install and configure MediatR package
- [ ] 5.2 Create base Command and Query classes
- [ ] 5.3 Create base CommandHandler and QueryHandler classes
- [ ] 5.4 Install and configure FluentValidation
- [ ] 5.5 Create validation pipeline behavior
- [ ] 5.6 Create logging pipeline behavior
- [ ] 5.7 Create transaction pipeline behavior
- [ ] 5.8 Create exception handling middleware


---

## Week 3: Platform Admin & Supplier Management (Mar 2 - Mar 8)

### 6. Platform Admin - Agency Management (Req 3)

- [ ] 6.1 Create CreateAgencyCommand and handler
- [ ] 6.2 Create UpdateAgencyCommand and handler
- [ ] 6.3 Create ActivateAgencyCommand and handler
- [ ] 6.4 Create GetAgenciesQuery and handler with pagination
- [ ] 6.5 Create GetAgencyByIdQuery and handler
- [ ] 6.6 Create agency DTOs and validators
- [ ] 6.7 Create agency API endpoints
- [ ] 6.8 Write unit tests for agency commands/queries
- [ ] 6.9 Test agency code generation logic

### 7. Supplier Registration & Approval (Req 4)

- [ ] 7.1 Create RegisterSupplierCommand and handler
- [ ] 7.2 Create ApproveSupplierCommand and handler
- [ ] 7.3 Create RejectSupplierCommand and handler
- [ ] 7.4 Create GetSuppliersQuery and handler with filtering
- [ ] 7.5 Create GetSupplierByIdQuery and handler
- [ ] 7.6 Create supplier DTOs and validators
- [ ] 7.7 Create supplier API endpoints
- [ ] 7.8 Write unit tests for supplier commands/queries
- [ ] 7.9 Test supplier code generation logic

### 8. Platform Admin Dashboard

- [ ] 8.1 Create GetPlatformDashboardQuery and handler
- [ ] 8.2 Implement statistics aggregation queries
- [ ] 8.3 Create dashboard DTOs
- [ ] 8.4 Create dashboard API endpoint
- [ ] 8.5 Write unit tests for dashboard query


---

## Week 4: Supplier Services & Purchase Orders (Mar 9 - Mar 15)

### 9. Supplier Service Management (Req 5)

- [ ] 9.1 Create CreateSupplierServiceCommand and handler
- [ ] 9.2 Create UpdateSupplierServiceCommand and handler
- [ ] 9.3 Create PublishSupplierServiceCommand and handler
- [ ] 9.4 Create GetSupplierServicesQuery and handler
- [ ] 9.5 Create GetSupplierServiceByIdQuery and handler
- [ ] 9.6 Implement service code generation (SVC-{SUPPLIER_CODE}-{SEQ})
- [ ] 9.7 Create service DTOs and validators for all 8 types
- [ ] 9.8 Create service API endpoints
- [ ] 9.9 Write unit tests for service commands/queries
- [ ] 9.10 Test type-specific field validation

### 10. Seasonal Pricing (Req 6)

- [ ] 10.1 Create CreateSeasonalPriceCommand and handler
- [ ] 10.2 Create UpdateSeasonalPriceCommand and handler
- [ ] 10.3 Create DeleteSeasonalPriceCommand and handler
- [ ] 10.4 Create GetSeasonalPricesQuery and handler
- [ ] 10.5 Implement GetServicePriceForDateQuery using database function
- [ ] 10.6 Create seasonal price DTOs and validators
- [ ] 10.7 Create seasonal price API endpoints
- [ ] 10.8 Write unit tests for seasonal pricing logic
- [ ] 10.9 Test date range overlap handling

### 11. Purchase Order Creation (Req 7)

- [ ] 11.1 Create CreatePurchaseOrderCommand and handler
- [ ] 11.2 Implement PO number generation (PO-YYMMDD-XXX)
- [ ] 11.3 Implement total amount calculation
- [ ] 11.4 Create GetPurchaseOrdersQuery and handler with filtering
- [ ] 11.5 Create GetPurchaseOrderByIdQuery and handler
- [ ] 11.6 Create PO DTOs and validators
- [ ] 11.7 Create PO API endpoints
- [ ] 11.8 Write unit tests for PO commands/queries
- [ ] 11.9 Test PO item validation

### 12. Purchase Order Approval (Req 8)

- [ ] 12.1 Create ApprovePurchaseOrderCommand and handler
- [ ] 12.2 Create RejectPurchaseOrderCommand and handler
- [ ] 12.3 Implement status workflow validation
- [ ] 12.4 Create notification service for PO status changes
- [ ] 12.5 Write unit tests for PO approval workflow
- [ ] 12.6 Test rejection reason requirement


---

## Week 5: Package, Journey & Booking Management (Mar 16 - Mar 22)

### 13. Package Management (Req 9)

- [ ] 13.1 Create CreatePackageCommand and handler
- [ ] 13.2 Create UpdatePackageCommand and handler
- [ ] 13.3 Create PublishPackageCommand and handler
- [ ] 13.4 Implement package code generation (PKG-{AGENCY_CODE}-{SEQ})
- [ ] 13.5 Implement pricing calculation (base cost + markup)
- [ ] 13.6 Create GetPackagesQuery and handler with filtering
- [ ] 13.7 Create GetPackageByIdQuery and handler
- [ ] 13.8 Create package DTOs and validators
- [ ] 13.9 Create package API endpoints
- [ ] 13.10 Write unit tests for package commands/queries
- [ ] 13.11 Test package-PO linking validation

### 14. Journey Management (Req 10)

- [ ] 14.1 Create CreateJourneyCommand and handler
- [ ] 14.2 Create UpdateJourneyCommand and handler
- [ ] 14.3 Implement journey code generation (JRN-{PKG_CODE}-{YYMMDD})
- [ ] 14.4 Implement quota management logic
- [ ] 14.5 Create GetJourneysQuery and handler
- [ ] 14.6 Create GetJourneyByIdQuery and handler
- [ ] 14.7 Create journey DTOs and validators
- [ ] 14.8 Create journey API endpoints
- [ ] 14.9 Write unit tests for journey commands/queries
- [ ] 14.10 Test quota invariant (total = confirmed + available)

### 15. Customer Management (Req 11)

- [ ] 15.1 Create CreateCustomerCommand and handler
- [ ] 15.2 Create UpdateCustomerCommand and handler
- [ ] 15.3 Implement customer code generation (CUST-YYMMDD-XXX)
- [ ] 15.4 Implement customer statistics auto-update
- [ ] 15.5 Create GetCustomersQuery and handler with search
- [ ] 15.6 Create GetCustomerByIdQuery and handler
- [ ] 15.7 Create customer DTOs and validators
- [ ] 15.8 Create customer API endpoints
- [ ] 15.9 Write unit tests for customer commands/queries
- [ ] 15.10 Test phone/email uniqueness validation

### 16. Booking Creation (Req 12)

- [ ] 16.1 Create CreateBookingCommand and handler
- [ ] 16.2 Implement booking reference generation (BKG-YYYY-XXXX)
- [ ] 16.3 Implement total amount calculation
- [ ] 16.4 Create GetBookingsQuery and handler with filtering
- [ ] 16.5 Create GetBookingByIdQuery and handler
- [ ] 16.6 Create booking DTOs and validators
- [ ] 16.7 Create booking API endpoints
- [ ] 16.8 Write unit tests for booking commands/queries

### 17. Booking Approval & Quota (Req 13)

- [ ] 17.1 Create ApproveBookingCommand and handler
- [ ] 17.2 Create CancelBookingCommand and handler
- [ ] 17.3 Implement quota decrement on approval
- [ ] 17.4 Implement quota increment on cancellation
- [ ] 17.5 Implement quota validation before approval
- [ ] 17.6 Write unit tests for booking approval workflow
- [ ] 17.7 Test quota management edge cases

### 18. Traveler Management (Req 14)

- [ ] 18.1 Create AddTravelerCommand and handler
- [ ] 18.2 Create UpdateTravelerCommand and handler
- [ ] 18.3 Implement mahram validation logic
- [ ] 18.4 Implement traveler number auto-assignment
- [ ] 18.5 Create traveler DTOs and validators
- [ ] 18.6 Create traveler API endpoints
- [ ] 18.7 Write unit tests for traveler commands
- [ ] 18.8 Test mahram validation for Umrah/Hajj packages


---

## Week 6: Document & Task Management (Mar 23 - Mar 29)

### 19. Document Checklist Auto-Generation (Req 15)

- [ ] 19.1 Implement document auto-generation on booking confirmation
- [ ] 19.2 Create GetBookingDocumentsQuery and handler
- [ ] 19.3 Implement document completion percentage calculation
- [ ] 19.4 Create GetIncompleteDocumentsQuery and handler
- [ ] 19.5 Create GetExpiringDocumentsQuery and handler
- [ ] 19.6 Create document DTOs
- [ ] 19.7 Create document query API endpoints
- [ ] 19.8 Write unit tests for document auto-generation
- [ ] 19.9 Test document type filtering by package type

### 20. Document Status Tracking (Req 16)

- [ ] 20.1 Create UpdateDocumentStatusCommand and handler
- [ ] 20.2 Create VerifyDocumentCommand and handler
- [ ] 20.3 Implement passport expiry validation (6 months rule)
- [ ] 20.4 Implement visa expiry validation
- [ ] 20.5 Create document DTOs and validators
- [ ] 20.6 Create document update API endpoints
- [ ] 20.7 Write unit tests for document commands
- [ ] 20.8 Test expiry validation logic

### 21. Task Checklist Auto-Generation (Req 17)

- [ ] 21.1 Implement task auto-generation on booking confirmation
- [ ] 21.2 Implement due date calculation from template offset
- [ ] 21.3 Create GetTasksQuery and handler with filtering
- [ ] 21.4 Create GetBookingTasksQuery and handler
- [ ] 21.5 Implement task completion percentage calculation
- [ ] 21.6 Create task DTOs
- [ ] 21.7 Create task query API endpoints
- [ ] 21.8 Write unit tests for task auto-generation
- [ ] 21.9 Test task template filtering by trigger stage

### 22. Task Management (Req 19)

- [ ] 22.1 Create CreateTaskCommand and handler (custom tasks)
- [ ] 22.2 Create UpdateTaskStatusCommand and handler
- [ ] 22.3 Create AssignTaskCommand and handler
- [ ] 22.4 Create CompleteTaskCommand and handler
- [ ] 22.5 Create GetMyTasksQuery and handler
- [ ] 22.6 Create GetOverdueTasksQuery and handler
- [ ] 22.7 Create task DTOs and validators
- [ ] 22.8 Create task management API endpoints
- [ ] 22.9 Write unit tests for task commands
- [ ] 22.10 Test task assignment validation


---

## Week 7: Notifications & Payments (Mar 30 - Apr 5)

### 23. Notification Scheduling (Req 20)

- [ ] 23.1 Create CreateNotificationScheduleCommand and handler
- [ ] 23.2 Create UpdateNotificationScheduleCommand and handler
- [ ] 23.3 Create GetNotificationSchedulesQuery and handler
- [ ] 23.4 Create GetNotificationTemplatesQuery and handler
- [ ] 23.5 Implement template variable replacement logic
- [ ] 23.6 Create notification DTOs and validators
- [ ] 23.7 Create notification schedule API endpoints
- [ ] 23.8 Write unit tests for notification commands
- [ ] 23.9 Test template rendering with variables

### 24. Daily Notification Job (Req 21)

- [ ] 24.1 Install and configure Hangfire
- [ ] 24.2 Create DailyNotificationJob class
- [ ] 24.3 Implement days_before_departure calculation
- [ ] 24.4 Implement notification log creation
- [ ] 24.5 Implement email sending service (mock for Phase 1)
- [ ] 24.6 Implement in-app notification service
- [ ] 24.7 Schedule job to run daily at 09:00 AM
- [ ] 24.8 Create job logging
- [ ] 24.9 Write unit tests for notification job
- [ ] 24.10 Test notification trigger matching

### 25. Notification Retry Mechanism (Req 22)

- [ ] 25.1 Create NotificationRetryJob class
- [ ] 25.2 Implement retry logic with 3-attempt limit
- [ ] 25.3 Implement error message recording
- [ ] 25.4 Schedule job to run hourly
- [ ] 25.5 Create GetNotificationLogsQuery and handler
- [ ] 25.6 Create notification log API endpoints
- [ ] 25.7 Write unit tests for retry job
- [ ] 25.8 Test retry count increment

### 26. Payment Schedule Auto-Generation (Req 23)

- [ ] 26.1 Implement payment schedule auto-generation on booking confirmation
- [ ] 26.2 Implement DP due date calculation (booking date + 3 days)
- [ ] 26.3 Implement Installment 1 due date (departure - 60 days)
- [ ] 26.4 Implement Installment 2 due date (departure - 30 days)
- [ ] 26.5 Implement installment amount calculation (40%, 30%, 30%)
- [ ] 26.6 Create GetPaymentSchedulesQuery and handler
- [ ] 26.7 Create payment schedule DTOs
- [ ] 26.8 Write unit tests for payment schedule generation
- [ ] 26.9 Test due date calculations

### 27. Payment Recording (Req 24)

- [ ] 27.1 Create RecordPaymentCommand and handler
- [ ] 27.2 Implement paid_amount update logic
- [ ] 27.3 Implement payment status calculation
- [ ] 27.4 Create GetOutstandingPaymentsQuery and handler
- [ ] 27.5 Create GetOverduePaymentsQuery and handler
- [ ] 27.6 Create payment DTOs and validators
- [ ] 27.7 Create payment API endpoints
- [ ] 27.8 Write unit tests for payment commands
- [ ] 27.9 Test payment status transitions


---

## Week 8: Itinerary, Supplier Bills & Communication (Apr 6 - Apr 12)

### 28. Itinerary Builder (Req 25)

- [ ] 28.1 Create CreateItineraryCommand and handler
- [ ] 28.2 Create AddItineraryDayCommand and handler
- [ ] 28.3 Create UpdateItineraryDayCommand and handler
- [ ] 28.4 Create DeleteItineraryDayCommand and handler
- [ ] 28.5 Create AddItineraryActivityCommand and handler
- [ ] 28.6 Create UpdateItineraryActivityCommand and handler
- [ ] 28.7 Create DeleteItineraryActivityCommand and handler
- [ ] 28.8 Create GetItineraryByPackageIdQuery and handler
- [ ] 28.9 Create itinerary DTOs and validators
- [ ] 28.10 Create itinerary API endpoints
- [ ] 28.11 Write unit tests for itinerary commands
- [ ] 28.12 Test one-itinerary-per-package constraint

### 29. Supplier Bill Auto-Generation (Req 26)

- [ ] 29.1 Implement supplier bill auto-generation on PO approval
- [ ] 29.2 Implement bill number generation (BILL-YYMMDD-XXX)
- [ ] 29.3 Implement due date calculation (bill date + 30 days)
- [ ] 29.4 Create GetSupplierBillsQuery and handler
- [ ] 29.5 Create GetOutstandingPayablesQuery and handler
- [ ] 29.6 Create supplier bill DTOs
- [ ] 29.7 Create supplier bill query API endpoints
- [ ] 29.8 Write unit tests for bill auto-generation
- [ ] 29.9 Test bill amount equals PO amount

### 30. Supplier Payment Recording (Req 27)

- [ ] 30.1 Create RecordSupplierPaymentCommand and handler
- [ ] 30.2 Implement paid_amount update logic
- [ ] 30.3 Implement bill status calculation
- [ ] 30.4 Create supplier payment DTOs and validators
- [ ] 30.5 Create supplier payment API endpoints
- [ ] 30.6 Write unit tests for supplier payment commands
- [ ] 30.7 Test payment status transitions

### 31. Communication Log (Req 28)

- [ ] 31.1 Create CreateCommunicationLogCommand and handler
- [ ] 31.2 Create UpdateCommunicationLogCommand and handler
- [ ] 31.3 Create GetCommunicationLogsQuery and handler
- [ ] 31.4 Create GetFollowUpsQuery and handler
- [ ] 31.5 Create communication log DTOs and validators
- [ ] 31.6 Create communication log API endpoints
- [ ] 31.7 Write unit tests for communication commands
- [ ] 31.8 Test follow-up date validation

### 32. H-30 and H-7 Task Generation Jobs (Req 18)

- [ ] 32.1 Create GenerateH30TasksJob class
- [ ] 32.2 Create GenerateH7TasksJob class
- [ ] 32.3 Implement booking identification logic (departure date matching)
- [ ] 32.4 Implement task generation from templates
- [ ] 32.5 Schedule both jobs to run daily at 08:00 AM
- [ ] 32.6 Create job logging
- [ ] 32.7 Write unit tests for task generation jobs
- [ ] 32.8 Test task generation for correct bookings


---

## Week 9: B2B Marketplace & Profitability (Apr 13 - Apr 19)

### 33. Agency Service Publishing (Req 29)

- [ ] 33.1 Create PublishAgencyServiceCommand and handler
- [ ] 33.2 Implement markup percentage calculation
- [ ] 33.3 Implement quota initialization logic
- [ ] 33.4 Implement 5% minimum markup validation
- [ ] 33.5 Create UpdateAgencyServiceCommand and handler
- [ ] 33.6 Create UnpublishAgencyServiceCommand and handler
- [ ] 33.7 Create GetAgencyServicesQuery and handler
- [ ] 33.8 Create agency service DTOs and validators
- [ ] 33.9 Create agency service API endpoints
- [ ] 33.10 Write unit tests for agency service commands
- [ ] 33.11 Test supplier name hiding logic

### 34. Marketplace Browsing (Req 30)

- [ ] 34.1 Create GetMarketplaceServicesQuery and handler
- [ ] 34.2 Implement supplier name hiding in query results
- [ ] 34.3 Implement filtering by service type, location, price
- [ ] 34.4 Implement search functionality
- [ ] 34.5 Implement pagination
- [ ] 34.6 Create GetMarketplaceServiceByIdQuery and handler
- [ ] 34.7 Create marketplace DTOs
- [ ] 34.8 Create marketplace API endpoints
- [ ] 34.9 Write unit tests for marketplace queries
- [ ] 34.10 Test own-agency exclusion logic

### 35. Agency Order Creation (Req 31)

- [ ] 35.1 Create CreateAgencyOrderCommand and handler
- [ ] 35.2 Implement order number generation (AO-YYMMDD-XXX)
- [ ] 35.3 Implement quota reservation logic
- [ ] 35.4 Implement quantity validation against available quota
- [ ] 35.5 Create GetAgencyOrdersQuery and handler (buyer view)
- [ ] 35.6 Create GetAgencyOrderByIdQuery and handler
- [ ] 35.7 Create CancelAgencyOrderCommand and handler
- [ ] 35.8 Implement quota release on cancellation
- [ ] 35.9 Create agency order DTOs and validators
- [ ] 35.10 Create agency order API endpoints
- [ ] 35.11 Write unit tests for agency order commands
- [ ] 35.12 Test quota reservation/release logic

### 36. Agency Order Approval (Req 32)

- [ ] 36.1 Create ApproveAgencyOrderCommand and handler
- [ ] 36.2 Create RejectAgencyOrderCommand and handler
- [ ] 36.3 Implement quota transfer on approval (reserved → sold)
- [ ] 36.4 Implement quota release on rejection
- [ ] 36.5 Create GetIncomingAgencyOrdersQuery and handler (seller view)
- [ ] 36.6 Create notification service for order status changes
- [ ] 36.7 Write unit tests for order approval workflow
- [ ] 36.8 Test quota transfer logic

### 37. Auto-Reject Pending Orders Job (Req 33)

- [ ] 37.1 Create AutoRejectPendingOrdersJob class
- [ ] 37.2 Implement 24-hour timeout logic
- [ ] 37.3 Implement quota release on auto-rejection
- [ ] 37.4 Schedule job to run hourly
- [ ] 37.5 Create job logging
- [ ] 37.6 Write unit tests for auto-reject job
- [ ] 37.7 Test notification sending on auto-rejection

### 38. Auto-Unpublish Zero Quota Job (Req 34)

- [ ] 38.1 Create AutoUnpublishZeroQuotaJob class
- [ ] 38.2 Implement zero quota identification logic
- [ ] 38.3 Implement auto-unpublish logic
- [ ] 38.4 Schedule job to run daily at 10:00 AM
- [ ] 38.5 Create job logging
- [ ] 38.6 Write unit tests for auto-unpublish job
- [ ] 38.7 Test quota invariant validation

### 39. Profitability Tracking (Req 35, 36)

- [ ] 39.1 Create GetBookingProfitabilityQuery and handler
- [ ] 39.2 Implement revenue calculation
- [ ] 39.3 Implement cost aggregation from POs and agency orders
- [ ] 39.4 Implement gross profit and margin calculation
- [ ] 39.5 Create GetProfitabilityDashboardQuery and handler
- [ ] 39.6 Implement low/high margin identification
- [ ] 39.7 Create profitability DTOs
- [ ] 39.8 Create profitability API endpoints
- [ ] 39.9 Write unit tests for profitability queries
- [ ] 39.10 Test margin percentage calculations


---

## Week 10: Integration Testing & Bug Fixes (Apr 20 - Apr 26)

### 40. Integration Testing

- [ ] 40.1 Setup integration test project with Testcontainers
- [ ] 40.2 Write integration tests for authentication flow
- [ ] 40.3 Write integration tests for agency management
- [ ] 40.4 Write integration tests for supplier management
- [ ] 40.5 Write integration tests for service and PO workflow
- [ ] 40.6 Write integration tests for package and journey workflow
- [ ] 40.7 Write integration tests for booking workflow
- [ ] 40.8 Write integration tests for document management
- [ ] 40.9 Write integration tests for task management
- [ ] 40.10 Write integration tests for notification system
- [ ] 40.11 Write integration tests for payment tracking
- [ ] 40.12 Write integration tests for B2B marketplace workflow
- [ ] 40.13 Write integration tests for profitability tracking
- [ ] 40.14 Write integration tests for multi-tenancy isolation

### 41. Performance Testing & Optimization

- [ ] 41.1 Run performance tests on list endpoints with large datasets
- [ ] 41.2 Optimize database queries with proper indexes
- [ ] 41.3 Implement query result caching for master data
- [ ] 41.4 Optimize N+1 query problems with eager loading
- [ ] 41.5 Test API response times (target < 500ms)
- [ ] 41.6 Implement database connection pooling optimization
- [ ] 41.7 Test concurrent request handling

### 42. Security Testing

- [ ] 42.1 Test authentication bypass attempts
- [ ] 42.2 Test authorization bypass attempts (cross-tenant access)
- [ ] 42.3 Test SQL injection vulnerabilities
- [ ] 42.4 Test XSS vulnerabilities in API responses
- [ ] 42.5 Verify RLS policies prevent cross-tenant data access
- [ ] 42.6 Test password hashing strength
- [ ] 42.7 Test JWT token expiration and refresh
- [ ] 42.8 Test rate limiting (if implemented)

### 43. Bug Fixes & Code Quality

- [ ] 43.1 Fix all critical bugs identified during testing
- [ ] 43.2 Fix all high-priority bugs
- [ ] 43.3 Code review for all modules
- [ ] 43.4 Refactor code for better maintainability
- [ ] 43.5 Add missing error handling
- [ ] 43.6 Add missing validation
- [ ] 43.7 Improve logging coverage
- [ ] 43.8 Update API documentation (Swagger)
- [ ] 43.9 Add XML comments for all public APIs


---

## Week 11: Demo Preparation & Deployment (Apr 27 - May 3)

### 44. Demo Data Preparation

- [ ] 44.1 Create comprehensive seed data script for demo
- [ ] 44.2 Create 2 sample agencies (Agency A - wholesaler, Agency B - retailer)
- [ ] 44.3 Create 3 sample suppliers with services (hotel, flight, visa)
- [ ] 44.4 Create sample POs (approved and pending)
- [ ] 44.5 Create sample packages with different types
- [ ] 44.6 Create sample journeys with various dates
- [ ] 44.7 Create sample bookings with customers and travelers
- [ ] 44.8 Create sample document checklists (various statuses)
- [ ] 44.9 Create sample tasks (completed, in progress, overdue)
- [ ] 44.10 Create sample payment schedules (paid, pending, overdue)
- [ ] 44.11 Create sample itineraries
- [ ] 44.12 Create sample marketplace services (Agency A publishes)
- [ ] 44.13 Create sample agency orders (Agency B orders from Agency A)
- [ ] 44.14 Create sample notification logs
- [ ] 44.15 Verify all demo data is realistic and demonstrates all features

### 45. Documentation & Deployment

- [ ] 45.1 Update README with setup instructions
- [ ] 45.2 Update API documentation with all endpoints
- [ ] 45.3 Create deployment guide for Docker
- [ ] 45.4 Create environment variable documentation
- [ ] 45.5 Create database migration guide
- [ ] 45.6 Test Docker Compose deployment
- [ ] 45.7 Create backup and restore procedures
- [ ] 45.8 Create monitoring and logging guide
- [ ] 45.9 Prepare demo script for backend API testing
- [ ] 45.10 Final code cleanup and formatting

### 46. Demo Rehearsal

- [ ] 46.1 Test complete authentication flow
- [ ] 46.2 Test platform admin workflows
- [ ] 46.3 Test supplier workflows (service creation, PO approval)
- [ ] 46.4 Test agency workflows (package creation, booking)
- [ ] 46.5 Test document and task management
- [ ] 46.6 Test notification system
- [ ] 46.7 Test payment tracking
- [ ] 46.8 Test B2B marketplace (Agency A ↔ Agency B)
- [ ] 46.9 Test profitability tracking
- [ ] 46.10 Test all dashboards
- [ ] 46.11 Verify no critical bugs
- [ ] 46.12 Prepare demo presentation


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

**Testing & Deployment (Tasks 40-46):** ~60 tasks
- Integration tests, performance, security, bug fixes, demo data

**TOTAL:** ~375 tasks

### By Week

- Week 1-2: Foundation (50 tasks)
- Week 3: Platform Admin (20 tasks)
- Week 4: Supplier Features (35 tasks)
- Week 5: Agency Core (60 tasks)
- Week 6: Document & Task (40 tasks)
- Week 7: Notification & Payment (40 tasks)
- Week 8: Itinerary & Bills (30 tasks)
- Week 9: Marketplace & Profitability (60 tasks)
- Week 10: Testing (40 tasks)
- Week 11: Demo Prep (30 tasks)

### Critical Path

1. **Week 1-2:** Foundation must complete before any feature work
2. **Week 3:** Supplier entity needed for Week 4
3. **Week 4:** PO workflow needed for Week 5 packages
4. **Week 5:** Booking entity needed for Week 6-7 ERP features
5. **Week 6-7:** Document/Task/Notification systems needed for demo
6. **Week 9:** Marketplace must be functional for demo
7. **Week 10-11:** Testing and demo prep are critical for May 3 demo

### Success Criteria

**Must Have (Demo Blockers):**
- ✅ All authentication and authorization working
- ✅ Multi-tenancy RLS working (no cross-tenant access)
- ✅ Platform admin can onboard agencies
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
- Week 9: B2B marketplace seller side
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
- Week 9: B2B marketplace buyer side, profitability
- Week 10: Security testing, bug fixes
- Week 11: Demo data, documentation

---

**Status:** ✅ READY FOR IMPLEMENTATION

**Next Action:** Start Week 1-2 tasks on Feb 16, 2026

**Demo Date:** May 3, 2026 🎯
