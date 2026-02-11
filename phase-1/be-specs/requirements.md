# Requirements Document

## Introduction

This document specifies the requirements for the backend API of a multi-tenant Tour & Travel ERP SaaS platform (Phase 1 MVP). The system enables platform administrators to manage travel agencies, suppliers to offer services, agencies to create packages and manage bookings, and travelers to browse and book travel packages. The backend implements Clean Architecture with CQRS pattern, uses PostgreSQL with Row-Level Security for multi-tenancy, and provides RESTful APIs secured with JWT authentication.

## Glossary

- **API**: The backend RESTful web service built with .NET 8
- **Platform_Admin**: System administrator who manages agencies and suppliers
- **Agency**: Travel agency tenant that creates packages and manages bookings
- **Agency_Staff**: User belonging to an agency with access to agency features
- **Supplier**: Service provider offering hotels, flights, visa services, transport, or guides
- **Traveler**: End customer who browses packages and creates bookings
- **Package**: Travel package created by an agency containing multiple services
- **Service**: Individual service offered by a supplier (hotel, flight, visa, transport, guide)
- **Booking**: Customer reservation for a package departure with traveler details
- **Departure**: Specific date instance of a package with quota management
- **Tenant_Context**: Agency identifier extracted from JWT token or X-Tenant-ID header
- **RLS**: Row-Level Security policies in PostgreSQL ensuring data isolation
- **CQRS**: Command Query Responsibility Segregation pattern using MediatR
- **JWT**: JSON Web Token used for authentication and authorization
- **Mahram**: Male guardian required for female Muslim travelers

## Requirements

### Requirement 1: Authentication and Authorization

**User Story:** As a user, I want to securely authenticate and access only the features permitted for my role, so that the system protects sensitive data and enforces proper access control.

#### Acceptance Criteria

1. WHEN a user submits valid credentials, THE API SHALL generate a JWT token containing user ID, email, user type, agency ID, and supplier ID
2. WHEN a user submits invalid credentials, THE API SHALL return an authentication error and prevent access
3. WHEN a request includes a valid JWT token, THE API SHALL extract user identity and authorize the request
4. WHEN a request includes an expired JWT token, THE API SHALL return an unauthorized error
5. WHEN a user registers, THE API SHALL hash the password using BCrypt before storing
6. WHEN an Agency_Staff makes a request, THE API SHALL extract Tenant_Context from the JWT token or X-Tenant-ID header
7. WHEN a user attempts to access a resource without proper role permissions, THE API SHALL return a forbidden error
8. THE API SHALL support refresh token functionality to obtain new access tokens without re-authentication

### Requirement 2: Multi-Tenancy with Row-Level Security

**User Story:** As a Platform_Admin, I want agencies to be completely isolated from each other, so that no agency can access or modify another agency's data.

#### Acceptance Criteria

1. WHEN an Agency_Staff queries data, THE API SHALL apply RLS policies to return only data belonging to their agency
2. WHEN an Agency_Staff creates data, THE API SHALL automatically associate the data with their agency ID
3. WHEN an Agency_Staff attempts to access another agency's data, THE RLS SHALL prevent the query from returning results
4. THE API SHALL set the PostgreSQL session variable for current agency ID before executing tenant-scoped queries
5. WHEN a Platform_Admin queries data, THE API SHALL bypass RLS policies to view all agencies' data
6. WHEN a Supplier queries data, THE API SHALL apply RLS policies to return only data belonging to their supplier ID

### Requirement 3: Platform Admin - Agency Management

**User Story:** As a Platform_Admin, I want to create and manage travel agencies, so that I can onboard new tenants and control their access to the platform.

#### Acceptance Criteria

1. WHEN a Platform_Admin creates an agency, THE API SHALL generate a unique agency code and store agency details
2. WHEN a Platform_Admin creates an agency, THE API SHALL validate that company name and email are provided
3. WHEN a Platform_Admin lists agencies, THE API SHALL return all agencies with pagination support
4. WHEN a Platform_Admin filters agencies by status, THE API SHALL return only agencies matching the filter criteria
5. WHEN a Platform_Admin updates an agency, THE API SHALL validate the changes and update the agency record
6. WHEN a Platform_Admin changes an agency status, THE API SHALL update the is_active flag and prevent agency staff from accessing the system if suspended
7. WHEN a Platform_Admin deletes an agency, THE API SHALL cascade delete all related data or prevent deletion if bookings exist

### Requirement 4: Platform Admin - Supplier Approval

**User Story:** As a Platform_Admin, I want to approve or reject supplier registrations, so that only verified service providers can offer services on the platform.

#### Acceptance Criteria

1. WHEN a Supplier registers, THE API SHALL create a supplier record with status "pending"
2. WHEN a Platform_Admin lists suppliers, THE API SHALL return all suppliers with filtering by approval status
3. WHEN a Platform_Admin approves a supplier, THE API SHALL update the supplier status to "active" and record the approval timestamp
4. WHEN a Platform_Admin rejects a supplier, THE API SHALL update the supplier status to "rejected" and prevent the supplier from accessing the system
5. WHEN a Supplier with "pending" status attempts to create services, THE API SHALL allow draft creation but prevent publishing

### Requirement 5: Platform Admin - Dashboard Statistics

**User Story:** As a Platform_Admin, I want to view system-wide statistics, so that I can monitor platform health and growth.

#### Acceptance Criteria

1. WHEN a Platform_Admin requests dashboard statistics, THE API SHALL return total count of active agencies
2. WHEN a Platform_Admin requests dashboard statistics, THE API SHALL return total count of suppliers by status
3. WHEN a Platform_Admin requests dashboard statistics, THE API SHALL return total count of bookings
4. THE API SHALL calculate dashboard statistics efficiently using database aggregation queries

### Requirement 6: Supplier - Service Management

**User Story:** As a Supplier, I want to create and manage services, so that agencies can include my offerings in their packages.

#### Acceptance Criteria

1. WHEN a Supplier creates a service, THE API SHALL generate a unique service code and store service details
2. WHEN a Supplier creates a service, THE API SHALL validate that service type, name, and base price are provided
3. WHEN a Supplier creates a service, THE API SHALL store service-specific details in a JSONB field for flexibility
4. WHEN a Supplier lists their services, THE API SHALL return only services belonging to that supplier
5. WHEN a Supplier updates a service, THE API SHALL validate the changes and update the service record
6. WHEN a Supplier publishes a service, THE API SHALL update the status to "published" and make it visible to agencies
7. WHEN a Supplier unpublishes a service, THE API SHALL update the status to "draft" and hide it from agencies
8. WHEN a Supplier deletes a service, THE API SHALL prevent deletion if the service is included in any published package
9. THE API SHALL support service types: hotel, flight, visa, transport, guide

### Requirement 7: Supplier - Dashboard Statistics

**User Story:** As a Supplier, I want to view my service statistics, so that I can track my offerings and performance.

#### Acceptance Criteria

1. WHEN a Supplier requests dashboard statistics, THE API SHALL return total count of their services by status
2. WHEN a Supplier requests dashboard statistics, THE API SHALL return count of services included in active packages
3. THE API SHALL calculate supplier statistics efficiently using database aggregation queries

### Requirement 8: Agency - Browse Supplier Services

**User Story:** As an Agency_Staff, I want to browse available supplier services, so that I can select services to include in my packages.

#### Acceptance Criteria

1. WHEN an Agency_Staff browses services, THE API SHALL return only published services with visibility "marketplace"
2. WHEN an Agency_Staff filters services by type, THE API SHALL return only services matching the specified type
3. WHEN an Agency_Staff searches services by name, THE API SHALL return services with names matching the search query
4. WHEN an Agency_Staff views service details, THE API SHALL return complete service information including JSONB details
5. THE API SHALL support pagination for service listing endpoints

### Requirement 9: Agency - Package Management

**User Story:** As an Agency_Staff, I want to create and manage travel packages, so that I can offer curated travel experiences to customers.

#### Acceptance Criteria

1. WHEN an Agency_Staff creates a package, THE API SHALL generate a unique package code and associate it with their agency
2. WHEN an Agency_Staff creates a package, THE API SHALL validate that package type, name, duration, and pricing are provided
3. WHEN an Agency_Staff creates a package, THE API SHALL validate that selling price is greater than or equal to base cost
4. WHEN an Agency_Staff adds services to a package, THE API SHALL create package_services records linking the package to supplier services
5. WHEN an Agency_Staff calculates package pricing, THE API SHALL sum all service costs to determine base cost
6. WHEN an Agency_Staff applies markup, THE API SHALL calculate selling price based on markup type (fixed or percentage)
7. WHEN an Agency_Staff lists packages, THE API SHALL return only packages belonging to their agency
8. WHEN an Agency_Staff updates a package, THE API SHALL validate the changes and update the package record
9. WHEN an Agency_Staff publishes a package, THE API SHALL update the status to "published" and make it visible to travelers
10. WHEN an Agency_Staff deletes a package, THE API SHALL prevent deletion if the package has confirmed bookings

### Requirement 10: Agency - Package Departures Management

**User Story:** As an Agency_Staff, I want to manage package departures with quota tracking, so that I can control availability and prevent overbooking.

#### Acceptance Criteria

1. WHEN an Agency_Staff creates a departure, THE API SHALL generate a unique departure code and associate it with the package
2. WHEN an Agency_Staff creates a departure, THE API SHALL validate that departure date, return date, and total quota are provided
3. WHEN an Agency_Staff creates a departure, THE API SHALL initialize available quota equal to total quota
4. WHEN a booking is confirmed, THE API SHALL decrement the available quota by the number of travelers
5. WHEN a booking is cancelled, THE API SHALL increment the available quota by the number of travelers
6. WHEN an Agency_Staff updates a departure, THE API SHALL validate that available quota does not exceed total quota
7. WHEN an Agency_Staff deletes a departure, THE API SHALL prevent deletion if the departure has confirmed bookings

### Requirement 11: Agency - Booking Management

**User Story:** As an Agency_Staff, I want to manage customer bookings, so that I can approve reservations and track sales.

#### Acceptance Criteria

1. WHEN an Agency_Staff lists bookings, THE API SHALL return only bookings belonging to their agency
2. WHEN an Agency_Staff filters bookings by status, THE API SHALL return only bookings matching the filter criteria
3. WHEN an Agency_Staff searches bookings by reference or customer name, THE API SHALL return matching bookings
4. WHEN an Agency_Staff views booking details, THE API SHALL return complete booking information including traveler list
5. WHEN an Agency_Staff approves a booking, THE API SHALL update the booking status to "approved" and decrement departure quota
6. WHEN an Agency_Staff rejects a booking, THE API SHALL update the booking status to "rejected" and not affect departure quota
7. WHEN an Agency_Staff cancels a booking, THE API SHALL update the booking status to "cancelled" and increment departure quota
8. WHEN an Agency_Staff creates a manual booking, THE API SHALL auto-approve the booking and decrement departure quota
9. THE API SHALL prevent booking approval if available quota is insufficient

### Requirement 12: Agency - Dashboard Statistics

**User Story:** As an Agency_Staff, I want to view my agency statistics, so that I can monitor business performance.

#### Acceptance Criteria

1. WHEN an Agency_Staff requests dashboard statistics, THE API SHALL return count of pending bookings
2. WHEN an Agency_Staff requests dashboard statistics, THE API SHALL return count of confirmed bookings
3. WHEN an Agency_Staff requests dashboard statistics, THE API SHALL return count of published packages
4. WHEN an Agency_Staff requests dashboard statistics, THE API SHALL return count of upcoming departures
5. THE API SHALL calculate agency statistics efficiently using database aggregation queries

### Requirement 13: Traveler - Browse Packages

**User Story:** As a Traveler, I want to browse and search available packages, so that I can find travel options that meet my needs.

#### Acceptance Criteria

1. WHEN a Traveler browses packages, THE API SHALL return only published packages with visibility "public"
2. WHEN a Traveler filters packages by type, THE API SHALL return only packages matching the specified type
3. WHEN a Traveler searches packages by name, THE API SHALL return packages with names matching the search query
4. WHEN a Traveler filters packages by price range, THE API SHALL return only packages within the specified price range
5. WHEN a Traveler sorts packages, THE API SHALL support sorting by price, date, and name
6. WHEN a Traveler views package details, THE API SHALL return complete package information including services and available departures
7. THE API SHALL support pagination for package listing endpoints

### Requirement 14: Traveler - Create Booking

**User Story:** As a Traveler, I want to create a booking with multiple travelers, so that I can reserve a package for my group.

#### Acceptance Criteria

1. WHEN a Traveler creates a booking, THE API SHALL generate a unique booking reference
2. WHEN a Traveler creates a booking, THE API SHALL validate that package ID, departure ID, and customer details are provided
3. WHEN a Traveler creates a booking, THE API SHALL validate that at least one traveler is provided
4. WHEN a Traveler creates a booking, THE API SHALL validate that available quota is sufficient for the number of travelers
5. WHEN a Traveler creates a booking, THE API SHALL create traveler records for each traveler in the booking
6. WHEN a Traveler creates a booking, THE API SHALL set the booking status to "pending" awaiting agency approval
7. WHEN a Traveler creates a booking, THE API SHALL calculate total amount by multiplying selling price by number of travelers
8. WHEN a Traveler creates a booking with a female traveler, THE API SHALL validate that mahram relationship is provided if required
9. WHEN a Traveler creates a booking, THE API SHALL validate that mahram traveler number references a valid male traveler in the same booking

### Requirement 15: Traveler - View My Bookings

**User Story:** As a Traveler, I want to view my booking history, so that I can track my reservations and their status.

#### Acceptance Criteria

1. WHEN a Traveler lists their bookings, THE API SHALL return only bookings created by that traveler
2. WHEN a Traveler views booking details, THE API SHALL return complete booking information including package details and traveler list
3. THE API SHALL support pagination for traveler booking list endpoints

### Requirement 16: Data Validation and Integrity

**User Story:** As a developer, I want comprehensive data validation, so that the system maintains data integrity and provides clear error messages.

#### Acceptance Criteria

1. WHEN a request contains invalid data, THE API SHALL return a validation error with field-specific error messages
2. WHEN a request violates database constraints, THE API SHALL return a conflict error with a descriptive message
3. THE API SHALL validate email format for all email fields
4. THE API SHALL validate that numeric fields contain valid numbers within acceptable ranges
5. THE API SHALL validate that date fields contain valid dates and logical date ranges
6. THE API SHALL validate that required fields are not null or empty
7. THE API SHALL validate foreign key references exist before creating related records

### Requirement 17: Error Handling and Logging

**User Story:** As a developer, I want comprehensive error handling and logging, so that I can diagnose issues and maintain system reliability.

#### Acceptance Criteria

1. WHEN an unhandled exception occurs, THE API SHALL return a 500 error with a generic error message
2. WHEN an unhandled exception occurs, THE API SHALL log the full exception details including stack trace
3. THE API SHALL log all incoming requests with timestamp, user ID, endpoint, and response status
4. THE API SHALL log all database queries for performance monitoring
5. THE API SHALL use structured logging with log levels (Debug, Info, Warning, Error, Critical)
6. THE API SHALL not expose sensitive information in error responses or logs

### Requirement 18: API Response Format

**User Story:** As a frontend developer, I want consistent API response format, so that I can handle responses predictably.

#### Acceptance Criteria

1. WHEN a request succeeds, THE API SHALL return a response with success flag true and data object
2. WHEN a request fails, THE API SHALL return a response with success flag false and error object
3. WHEN a list endpoint returns data, THE API SHALL include pagination metadata with page, per_page, total, and total_pages
4. THE API SHALL use standard HTTP status codes (200, 201, 400, 401, 403, 404, 409, 500)
5. THE API SHALL return JSON content type for all responses

### Requirement 19: Performance and Scalability

**User Story:** As a system administrator, I want the API to perform efficiently under load, so that users experience fast response times.

#### Acceptance Criteria

1. WHEN a list endpoint is called, THE API SHALL use database indexes to optimize query performance
2. WHEN a complex query is executed, THE API SHALL use database joins efficiently to minimize round trips
3. THE API SHALL support pagination with configurable page size to limit result set size
4. THE API SHALL use connection pooling for database connections
5. WHEN a read query is executed, THE API SHALL use read-only database connections where appropriate

### Requirement 20: Docker Deployment

**User Story:** As a DevOps engineer, I want the API to be containerized, so that I can deploy it consistently across environments.

#### Acceptance Criteria

1. THE API SHALL provide a Dockerfile that builds a production-ready container image
2. THE API SHALL provide a Docker Compose file that orchestrates the API and PostgreSQL services
3. WHEN the Docker Compose is started, THE API SHALL connect to the PostgreSQL service using environment variables
4. THE Docker Compose SHALL configure PostgreSQL with persistent volume for data storage
5. THE Docker Compose SHALL configure health checks for both API and database services
6. THE API SHALL expose configuration through environment variables for database connection, JWT secret, and logging level

### Requirement 21: API Documentation

**User Story:** As a frontend developer, I want interactive API documentation, so that I can understand and test endpoints easily.

#### Acceptance Criteria

1. THE API SHALL expose Swagger/OpenAPI documentation at /swagger endpoint
2. THE Swagger documentation SHALL include all endpoints with request/response schemas
3. THE Swagger documentation SHALL include authentication requirements for each endpoint
4. THE Swagger documentation SHALL support interactive testing of endpoints
5. THE Swagger documentation SHALL include example requests and responses

### Requirement 22: Health Check

**User Story:** As a DevOps engineer, I want a health check endpoint, so that I can monitor API availability.

#### Acceptance Criteria

1. THE API SHALL expose a health check endpoint at /health
2. WHEN the health check is called, THE API SHALL verify database connectivity
3. WHEN the health check succeeds, THE API SHALL return 200 status with healthy status
4. WHEN the health check fails, THE API SHALL return 503 status with unhealthy status and error details

### Requirement 23: Database Migrations

**User Story:** As a developer, I want database schema versioning, so that I can manage schema changes safely.

#### Acceptance Criteria

1. THE API SHALL use Entity Framework Core migrations for schema management
2. WHEN the API starts, THE API SHALL apply pending migrations automatically in development environment
3. THE API SHALL provide migration scripts for manual execution in production environment
4. THE API SHALL version migrations with timestamp-based naming

### Requirement 24: Seed Data

**User Story:** As a developer, I want seed data for development and testing, so that I can quickly set up a working environment.

#### Acceptance Criteria

1. THE API SHALL provide a seed data script that creates sample users for all roles
2. THE API SHALL provide a seed data script that creates sample agencies, suppliers, services, packages, and bookings
3. WHEN seed data is executed, THE API SHALL check if data already exists to prevent duplicates
4. THE seed data SHALL use realistic data that demonstrates all system features
