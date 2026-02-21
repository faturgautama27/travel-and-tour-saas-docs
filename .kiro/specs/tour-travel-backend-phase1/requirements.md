# Requirements Document

## Introduction

This document specifies the requirements for Phase 1 MVP of a Multi-Tenant Tour & Travel Agency ERP SaaS Platform. The system enables travel agencies to manage their complete operations from supplier procurement to customer departure, including B2B marketplace functionality for agency-to-agency reselling.

## Glossary

- **Platform_Admin**: Administrator who manages the platform, onboards agencies, and approves suppliers
- **Agency**: Travel agency tenant using the platform for ERP operations
- **Supplier**: Service provider offering 8 types of services (Hotel, Flight, Visa, Transport, Guide, Insurance, Catering, Handling)
- **Package**: Reusable travel package template without specific dates
- **Journey**: Actual trip instance with specific departure and return dates
- **Purchase_Order**: Order from agency to supplier for services
- **Booking**: Customer reservation for a specific journey
- **Traveler**: Individual person traveling in a booking
- **Mahram**: Male guardian required for female Muslim travelers in Umrah/Hajj packages
- **RLS**: Row-Level Security for multi-tenant data isolation
- **Seasonal_Price**: Date-based price variation overriding base price
- **Document_Checklist**: Auto-generated list of required documents per booking
- **Task_Checklist**: Auto-generated list of tasks per booking
- **H_Minus_N**: Days before departure (e.g., H-30 means 30 days before departure)
- **B2B_Marketplace**: Platform where Agency A sells excess inventory to Agency B
- **Agency_Service**: Service published by Agency A to marketplace for reselling
- **Agency_Order**: Order from Agency B to Agency A for marketplace services

## Requirements

### Requirement 1: Multi-Tenant System with Row-Level Security

**User Story:** As a Platform_Admin, I want complete data isolation between agencies, so that each agency's data remains private and secure.

#### Acceptance Criteria

1. WHEN a user authenticates, THE System SHALL set the tenant context from the JWT token
2. THE System SHALL enforce Row-Level Security policies on all tenant-scoped tables
3. WHEN an agency user queries data, THE System SHALL return only data belonging to their agency
4. THE System SHALL prevent cross-tenant data access through API endpoints
5. WHEN Platform_Admin queries data, THE System SHALL allow access to all agencies' data

### Requirement 2: Authentication and Authorization

**User Story:** As a user, I want secure authentication with role-based access control, so that only authorized users can access specific features.

#### Acceptance Criteria

1. WHEN a user provides valid credentials, THE System SHALL generate a JWT token with user information and tenant context
2. THE System SHALL hash passwords using BCrypt with salt rounds of 12
3. THE System SHALL support three user types: platform_admin, agency_staff, and supplier_staff
4. WHEN a JWT token expires after 24 hours, THE System SHALL require re-authentication or token refresh
5. THE System SHALL validate user permissions based on user_type for all protected endpoints

### Requirement 3: Platform Admin Agency Management

**User Story:** As a Platform_Admin, I want to onboard and manage travel agencies, so that new agencies can use the platform.

#### Acceptance Criteria

1. WHEN Platform_Admin creates an agency, THE System SHALL generate a unique agency_code
2. THE System SHALL validate that company_name and email are provided
3. WHEN an agency is created, THE System SHALL set is_active to true by default
4. THE System SHALL allow Platform_Admin to activate or deactivate agencies
5. THE System SHALL prevent deletion of agencies that have existing bookings

### Requirement 4: Supplier Registration and Approval

**User Story:** As a Supplier, I want to register on the platform and get approved, so that I can offer services to agencies.

#### Acceptance Criteria

1. WHEN a Supplier registers via public registration form, THE System SHALL create a supplier record with status 'pending'
2. THE System SHALL generate a unique supplier_code in format SUP-YYMMDD-XXX
3. THE System SHALL require company_name, business_type, email, phone, and business_license_number
4. THE System SHALL validate email format and uniqueness across all suppliers
5. THE System SHALL validate phone format
6. THE System SHALL hash the password using BCrypt with salt rounds of 12
7. THE System SHALL validate password requirements (minimum 8 characters, at least 1 uppercase, 1 lowercase, 1 number)
8. THE System SHALL create a user account with user_type 'supplier_staff' linked to the supplier
9. WHEN Platform_Admin approves a supplier, THE System SHALL update status to 'active' and record approved_at timestamp and approved_by user
10. WHEN Platform_Admin rejects a supplier, THE System SHALL update status to 'rejected' and record rejection_reason
11. THE System SHALL only allow active suppliers to publish services
12. THE System SHALL send email notification to supplier when registration is submitted, approved, or rejected

### Requirement 5: Supplier Service Management with Type-Specific Fields

**User Story:** As a Supplier, I want to create and manage services with type-specific fields, so that agencies can view detailed service information.

#### Acceptance Criteria

1. THE System SHALL support 8 service types: hotel, flight, visa, transport, guide, insurance, catering, handling
2. WHEN a Supplier creates a hotel service, THE System SHALL require hotel_name, hotel_star_rating, room_type, and meal_plan
3. WHEN a Supplier creates a flight service, THE System SHALL require airline, flight_class, departure_airport, and arrival_airport
4. WHEN a Supplier creates a visa service, THE System SHALL require visa_type, processing_days, validity_days, and entry_type
5. THE System SHALL generate a unique service_code in format SVC-{SUPPLIER_CODE}-{SEQUENCE}
6. THE System SHALL validate that base_price is greater than zero
7. WHEN a Supplier publishes a service, THE System SHALL set status to 'published' and record published_at timestamp

### Requirement 6: Seasonal Pricing Management

**User Story:** As a Supplier, I want to set seasonal prices for specific date ranges, so that I can charge different prices during high seasons.

#### Acceptance Criteria

1. WHEN a Supplier creates a seasonal price, THE System SHALL validate that end_date is greater than or equal to start_date
2. THE System SHALL validate that seasonal_price is greater than zero
3. WHEN querying price for a specific date, THE System SHALL return seasonal_price if the date falls within an active seasonal price range
4. WHEN no seasonal price exists for a date, THE System SHALL return the base_price
5. IF multiple seasonal prices overlap for a date, THE System SHALL return the most recently created seasonal price

### Requirement 7: Purchase Order Creation and Workflow

**User Story:** As an Agency staff member, I want to create purchase orders to suppliers, so that I can procure services for my packages.

#### Acceptance Criteria

1. WHEN an Agency creates a purchase order, THE System SHALL generate a unique po_number in format PO-YYMMDD-XXX
2. THE System SHALL require at least one service item in the purchase order
3. THE System SHALL calculate total_amount as the sum of all po_items total_price
4. WHEN a purchase order is created, THE System SHALL set status to 'pending'
5. THE System SHALL send notification to the supplier when a purchase order is created

### Requirement 8: Purchase Order Approval by Supplier

**User Story:** As a Supplier, I want to approve or reject purchase orders, so that I can confirm service availability to agencies.

#### Acceptance Criteria

1. WHEN a Supplier approves a purchase order, THE System SHALL update status to 'approved' and record approved_at timestamp and approved_by user
2. WHEN a Supplier rejects a purchase order, THE System SHALL update status to 'rejected', record rejected_at timestamp, and require rejection_reason
3. THE System SHALL prevent modification of purchase orders after approval or rejection
4. THE System SHALL send notification to the agency when a purchase order is approved or rejected
5. THE System SHALL allow purchase order deletion only when status is 'pending'

### Requirement 9: Package Management with Service Selection

**User Story:** As an Agency staff member, I want to create reusable package templates with service selection from my inventory, so that I can use them for multiple journeys.

#### Acceptance Criteria

1. WHEN an Agency creates a package, THE System SHALL generate a unique package_code in format PKG-{AGENCY_CODE}-{SEQUENCE}
2. THE System SHALL support package types: umrah, hajj, halal_tour, general_tour, custom
3. THE System SHALL require name, duration_days, markup_type, markup_value, and selling_price
4. THE System SHALL validate that selling_price is greater than or equal to base_cost
5. THE System SHALL NOT include departure_date or return_date fields in packages
6. THE System SHALL allow agencies to select services from two sources:
   - Approved purchase order items (po_items from approved purchase_orders)
   - Agency services (agency_services purchased from B2B marketplace)
7. WHEN services are added to a package, THE System SHALL save them to package_services table with fields: package_id, supplier_service_id (if from PO), agency_service_id (if from marketplace), source_type, quantity, unit_cost, total_cost
8. THE System SHALL calculate base_cost automatically as sum of all package_services total_cost (quantity × unit_cost)
9. WHEN markup_type is 'percentage', THE System SHALL calculate selling_price as base_cost × (1 + markup_value/100)
10. WHEN markup_type is 'fixed', THE System SHALL calculate selling_price as base_cost + markup_value
11. THE System SHALL provide API endpoint GET /api/packages/available-services to return combined list of po_items and agency_services

### Requirement 10: Journey Management with Service Tracking

**User Story:** As an Agency staff member, I want to create journeys with specific dates, quota management, and service tracking, so that I can manage actual trips and monitor operational progress.

#### Acceptance Criteria

1. WHEN an Agency creates a journey, THE System SHALL generate a unique journey_code in format JRN-{PACKAGE_CODE}-{YYMMDD}
2. THE System SHALL require departure_date, return_date, and total_quota
3. THE System SHALL initialize confirmed_pax to 0 and available_quota to total_quota
4. THE System SHALL validate that return_date is after departure_date
5. THE System SHALL maintain the invariant: total_quota = confirmed_pax + available_quota
6. WHEN a journey is created, THE System SHALL automatically copy all services from package_services to journey_services table
7. THE System SHALL initialize journey_services with default tracking status:
   - booking_status: not_booked
   - execution_status: pending
   - payment_status: unpaid
8. THE System SHALL provide API endpoint GET /api/journeys/{id}/services to return journey services with tracking status
9. THE System SHALL provide API endpoint PATCH /api/journeys/{id}/services/{serviceId}/status to update service tracking status
10. WHEN booking_status is updated to 'booked', THE System SHALL set booked_at timestamp
11. WHEN booking_status is updated to 'confirmed', THE System SHALL set confirmed_at timestamp
12. WHEN execution_status is updated to 'completed', THE System SHALL set executed_at timestamp
13. THE System SHALL support booking_status values: not_booked, booked, confirmed, cancelled
14. THE System SHALL support execution_status values: pending, in_progress, completed, failed
15. THE System SHALL support payment_status values: unpaid, partially_paid, paid

### Requirement 11: Customer Management

**User Story:** As an Agency staff member, I want to manage customer information, so that I can maintain customer relationships and booking history.

#### Acceptance Criteria

1. WHEN an Agency creates a customer, THE System SHALL generate a unique customer_code in format CUST-YYMMDD-XXX
2. THE System SHALL require name and phone
3. THE System SHALL validate that phone is unique within the agency
4. IF email is provided, THE System SHALL validate that email is unique within the agency
5. THE System SHALL automatically update total_bookings, total_spent, and last_booking_date when bookings are created or modified

### Requirement 12: Booking Creation with Staff Input

**User Story:** As an Agency staff member, I want to create bookings manually for customers, so that I can process walk-in, phone, and WhatsApp bookings.

#### Acceptance Criteria

1. WHEN an Agency staff creates a booking, THE System SHALL generate a unique booking_reference in format BKG-YYYY-XXXX
2. THE System SHALL require package_id, journey_id, customer_id, and total_pax
3. THE System SHALL calculate total_amount as package selling_price multiplied by total_pax
4. WHEN a booking is created, THE System SHALL set booking_status to 'pending'
5. THE System SHALL support booking_source values: staff, phone, walk_in, whatsapp

### Requirement 13: Booking Approval and Quota Management

**User Story:** As an Agency staff member, I want to approve bookings to confirm reservations, so that quota is properly managed.

#### Acceptance Criteria

1. WHEN an Agency staff approves a booking, THE System SHALL update booking_status to 'confirmed' and record approved_at timestamp
2. WHEN a booking is confirmed, THE System SHALL decrement journey available_quota by booking total_pax
3. WHEN a booking is confirmed, THE System SHALL increment journey confirmed_pax by booking total_pax
4. THE System SHALL prevent booking approval if journey available_quota is less than booking total_pax
5. WHEN a booking is cancelled, THE System SHALL increment journey available_quota and decrement confirmed_pax by booking total_pax

### Requirement 14: Traveler Management with Mahram Validation

**User Story:** As an Agency staff member, I want to add travelers to bookings with mahram validation, so that Umrah/Hajj bookings comply with religious requirements.

#### Acceptance Criteria

1. WHEN adding a traveler to a booking, THE System SHALL require full_name, gender, and date_of_birth
2. WHEN the package type is 'umrah' or 'hajj', THE System SHALL validate mahram requirements for female travelers
3. IF a female traveler is older than 12 years, THE System SHALL require a mahram_traveler_number referencing a male traveler in the same booking
4. THE System SHALL validate that the referenced mahram traveler exists and is male
5. THE System SHALL assign sequential traveler_number starting from 1 within each booking

### Requirement 15: Document Checklist Auto-Generation

**User Story:** As an Agency staff member, I want document checklists to be automatically generated when bookings are confirmed, so that I can track required documents.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE System SHALL auto-generate document records based on package type
2. THE System SHALL create document records for each traveler based on document_types required_for_package_types
3. WHEN documents are auto-generated, THE System SHALL set status to 'not_submitted'
4. THE System SHALL calculate document completion percentage as (verified documents / total required documents) × 100
5. THE System SHALL identify expiring documents where expiry_date is less than 30 days from today

### Requirement 16: Document Status Tracking and Validation

**User Story:** As an Agency staff member, I want to track document submission and verification, so that I can ensure all required documents are collected before departure.

#### Acceptance Criteria

1. THE System SHALL support document status values: not_submitted, submitted, verified, rejected, expired
2. WHEN a document is submitted, THE System SHALL allow staff to update status to 'submitted' and record document_number and expiry_date
3. WHEN a document is verified, THE System SHALL record verified_by user and verified_at timestamp
4. WHEN a document is rejected, THE System SHALL require rejection_reason
5. FOR passport documents, THE System SHALL validate that expiry_date is more than 6 months after journey departure_date
6. FOR visa documents, THE System SHALL validate that expiry_date is after journey departure_date

### Requirement 17: Task Checklist Auto-Generation

**User Story:** As an Agency staff member, I want task checklists to be automatically generated for bookings, so that I can track operational tasks.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE System SHALL auto-generate tasks from task_templates with trigger_stage 'after_booking'
2. THE System SHALL calculate due_date as booking creation date plus template due_days_offset
3. WHEN tasks are auto-generated, THE System SHALL set status to 'to_do'
4. THE System SHALL support task status values: to_do, in_progress, done
5. THE System SHALL calculate task completion percentage as (completed tasks / total tasks) × 100

### Requirement 18: H-30 and H-7 Task Auto-Generation

**User Story:** As an Agency staff member, I want tasks to be automatically generated at H-30 and H-7 before departure, so that critical pre-departure tasks are not missed.

#### Acceptance Criteria

1. WHEN the system runs the H-30 task generation job, THE System SHALL identify bookings where departure_date equals today plus 30 days
2. FOR each identified booking, THE System SHALL generate tasks from task_templates with trigger_stage 'h_30'
3. WHEN the system runs the H-7 task generation job, THE System SHALL identify bookings where departure_date equals today plus 7 days
4. FOR each identified booking, THE System SHALL generate tasks from task_templates with trigger_stage 'h_7'
5. THE System SHALL run H-30 and H-7 task generation jobs daily at 08:00 AM

### Requirement 19: Task Management with Kanban Board

**User Story:** As an Agency staff member, I want to manage tasks using a Kanban board, so that I can visualize task progress.

#### Acceptance Criteria

1. THE System SHALL support task assignment to users
2. WHEN a task status is updated to 'done', THE System SHALL record completed_at timestamp and completed_by user
3. THE System SHALL identify overdue tasks where due_date is less than today and status is not 'done'
4. THE System SHALL allow filtering tasks by status, assigned user, and due date
5. THE System SHALL allow creation of custom tasks that are not from templates

### Requirement 20: Pre-Departure Notification Scheduling

**User Story:** As an Agency staff member, I want to configure automated pre-departure notifications, so that customers receive timely reminders.

#### Acceptance Criteria

1. THE System SHALL support notification schedules with trigger_days_before values: 30, 14, 7, 3, 1
2. WHEN an Agency creates a notification schedule, THE System SHALL require name, trigger_days_before, and template_id
3. THE System SHALL allow agencies to enable or disable notification schedules
4. THE System SHALL support notification templates with customizable subject and body
5. THE System SHALL support template variables including customer_name, package_name, departure_date, and booking_reference

### Requirement 21: Daily Notification Job Execution

**User Story:** As an Agency staff member, I want notifications to be sent automatically based on schedules, so that customers receive timely information.

#### Acceptance Criteria

1. THE System SHALL run the daily notification job at 09:00 AM
2. FOR each confirmed booking, THE System SHALL calculate days_before_departure as departure_date minus today
3. WHEN days_before_departure matches a notification schedule trigger_days_before, THE System SHALL create a notification log
4. THE System SHALL replace template variables with actual booking data
5. THE System SHALL send notifications via email and in-app channels

### Requirement 22: Notification Retry Mechanism

**User Story:** As an Agency staff member, I want failed notifications to be retried automatically, so that delivery issues are handled gracefully.

#### Acceptance Criteria

1. WHEN a notification fails to send, THE System SHALL set status to 'failed' and record error_message
2. THE System SHALL run the notification retry job every hour
3. THE System SHALL retry failed notifications up to 3 times with 1-hour intervals
4. WHEN a notification is successfully sent after retry, THE System SHALL update status to 'sent' and record sent_at timestamp
5. WHEN retry_count reaches 3 and notification still fails, THE System SHALL set status to 'failed_permanently'

### Requirement 23: Payment Schedule Auto-Generation

**User Story:** As an Agency staff member, I want payment schedules to be automatically generated for bookings, so that I can track customer payments.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE System SHALL auto-generate 3 payment schedules: DP (40%), Installment 1 (30%), Installment 2 (30%)
2. THE System SHALL calculate DP due_date as booking creation date plus 3 days
3. THE System SHALL calculate Installment 1 due_date as departure_date minus 60 days
4. THE System SHALL calculate Installment 2 due_date as departure_date minus 30 days
5. THE System SHALL calculate each installment amount as booking total_amount multiplied by the percentage

### Requirement 24: Payment Recording and Tracking

**User Story:** As an Agency staff member, I want to record customer payments, so that I can track payment status.

#### Acceptance Criteria

1. WHEN staff records a payment, THE System SHALL create a payment_transaction record
2. THE System SHALL update payment_schedule paid_amount by adding the transaction amount
3. WHEN paid_amount equals the schedule amount, THE System SHALL update status to 'paid' and record paid_date
4. WHEN paid_amount is greater than zero but less than amount, THE System SHALL update status to 'partially_paid'
5. THE System SHALL identify overdue payments where due_date is less than today and status is 'pending'

### Requirement 25: Itinerary Builder

**User Story:** As an Agency staff member, I want to build day-by-day itineraries for packages, so that customers can see detailed trip plans.

#### Acceptance Criteria

1. THE System SHALL allow one itinerary per package
2. WHEN creating an itinerary, THE System SHALL allow adding multiple itinerary days with sequential day_number
3. FOR each itinerary day, THE System SHALL require title and allow optional description
4. THE System SHALL allow adding multiple activities per day with time, location, activity description, and meal_type
5. THE System SHALL support meal_type values: breakfast, lunch, dinner, snack, none

### Requirement 26: Supplier Bill Auto-Generation

**User Story:** As an Agency staff member, I want supplier bills to be automatically generated from approved purchase orders, so that I can track payables.

#### Acceptance Criteria

1. WHEN a purchase order is approved, THE System SHALL auto-generate a supplier_bill record
2. THE System SHALL generate a unique bill_number in format BILL-YYMMDD-XXX
3. THE System SHALL set bill_date to the purchase order approval date
4. THE System SHALL calculate due_date as bill_date plus 30 days
5. THE System SHALL set total_amount equal to purchase order total_amount

### Requirement 27: Supplier Payment Recording

**User Story:** As an Agency staff member, I want to record payments to suppliers, so that I can track payables status.

#### Acceptance Criteria

1. WHEN staff records a supplier payment, THE System SHALL create a supplier_payment record
2. THE System SHALL update supplier_bill paid_amount by adding the payment amount
3. WHEN paid_amount equals total_amount, THE System SHALL update status to 'paid'
4. WHEN paid_amount is greater than zero but less than total_amount, THE System SHALL update status to 'partially_paid'
5. THE System SHALL identify overdue bills where due_date is less than today and status is 'unpaid'

### Requirement 28: Communication Log

**User Story:** As an Agency staff member, I want to log customer communications, so that I can track interaction history and follow-ups.

#### Acceptance Criteria

1. WHEN staff creates a communication log, THE System SHALL require customer_id, communication_type, and notes
2. THE System SHALL support communication_type values: call, email, whatsapp, meeting, other
3. THE System SHALL allow linking communication logs to specific bookings
4. WHEN follow_up_required is true, THE System SHALL require follow_up_date
5. THE System SHALL allow marking follow-ups as done by setting follow_up_done to true

### Requirement 29: B2B Marketplace - Agency Service Publishing

**User Story:** As an Agency A staff member, I want to publish excess inventory to the marketplace, so that other agencies can purchase from me.

#### Acceptance Criteria

1. WHEN Agency A publishes a service to marketplace, THE System SHALL create an agency_service record linked to an approved purchase_order
2. THE System SHALL require reseller_price to be greater than cost_price with minimum 5% markup
3. THE System SHALL calculate markup_percentage as ((reseller_price - cost_price) / cost_price) × 100
4. THE System SHALL initialize available_quota equal to total_quota
5. WHEN is_published is set to true, THE System SHALL record published_at timestamp

### Requirement 30: B2B Marketplace - Service Browsing with Hidden Supplier

**User Story:** As an Agency B staff member, I want to browse marketplace services without seeing supplier names, so that I can purchase from other agencies.

#### Acceptance Criteria

1. WHEN Agency B browses the marketplace, THE System SHALL return only published agency_services where agency_id is not Agency B
2. THE System SHALL NOT expose supplier_id or supplier name in marketplace API responses
3. THE System SHALL display the seller agency name (Agency A) but hide the original supplier
4. THE System SHALL show available_quota for each service
5. THE System SHALL prevent agencies from viewing their own published services in the marketplace

### Requirement 31: B2B Marketplace - Agency Order Creation

**User Story:** As an Agency B staff member, I want to create orders to other agencies, so that I can purchase marketplace services.

#### Acceptance Criteria

1. WHEN Agency B creates an order, THE System SHALL generate a unique order_number in format AO-YYMMDD-XXX
2. THE System SHALL validate that order quantity is less than or equal to agency_service available_quota
3. WHEN an order is created, THE System SHALL set status to 'pending'
4. THE System SHALL reserve quota by incrementing agency_service reserved_quota and decrementing available_quota by order quantity
5. THE System SHALL send notification to Agency A when an order is created

### Requirement 32: B2B Marketplace - Order Approval Workflow

**User Story:** As an Agency A staff member, I want to approve or reject orders from other agencies, so that I can control my inventory sales.

#### Acceptance Criteria

1. WHEN Agency A approves an order, THE System SHALL update status to 'approved' and record approved_at timestamp
2. WHEN an order is approved, THE System SHALL transfer quota from reserved_quota to sold_quota
3. WHEN Agency A rejects an order, THE System SHALL update status to 'rejected' and require rejection_reason
4. WHEN an order is rejected, THE System SHALL release quota by decrementing reserved_quota and incrementing available_quota
5. THE System SHALL send notification to Agency B when an order is approved or rejected

### Requirement 33: B2B Marketplace - Auto-Reject Pending Orders

**User Story:** As an Agency B staff member, I want pending orders to be automatically rejected after 24 hours, so that my quota is not locked indefinitely.

#### Acceptance Criteria

1. THE System SHALL run the auto-reject orders job every hour
2. THE System SHALL identify pending orders where created_at is more than 24 hours ago
3. FOR each identified order, THE System SHALL update status to 'rejected' and set rejection_reason to 'Auto-rejected: No response within 24 hours'
4. THE System SHALL release reserved quota back to available_quota
5. THE System SHALL send notification to the buyer agency when an order is auto-rejected

### Requirement 34: B2B Marketplace - Auto-Unpublish Zero Quota Services

**User Story:** As an Agency A staff member, I want services to be automatically unpublished when quota reaches zero, so that buyers cannot order unavailable services.

#### Acceptance Criteria

1. THE System SHALL run the auto-unpublish services job daily at 10:00 AM
2. THE System SHALL identify published agency_services where available_quota equals zero
3. FOR each identified service, THE System SHALL set is_published to false
4. THE System SHALL allow manual republishing when quota becomes available again
5. THE System SHALL maintain the invariant: total_quota = used_quota + available_quota + reserved_quota + sold_quota

### Requirement 35: Profitability Tracking - Revenue and Cost Calculation

**User Story:** As an Agency staff member, I want to track booking profitability, so that I can identify high and low margin bookings.

#### Acceptance Criteria

1. THE System SHALL calculate booking revenue as package selling_price multiplied by total_pax
2. THE System SHALL calculate booking cost as the sum of all service costs from purchase orders and agency orders
3. THE System SHALL calculate gross_profit as revenue minus cost
4. THE System SHALL calculate gross_margin_percentage as (gross_profit / revenue) × 100
5. THE System SHALL identify low margin bookings where gross_margin_percentage is less than 10%

### Requirement 36: Profitability Dashboard

**User Story:** As an Agency staff member, I want to view profitability metrics on a dashboard, so that I can make informed pricing decisions.

#### Acceptance Criteria

1. THE System SHALL display total revenue, total cost, and total profit for a selected date range
2. THE System SHALL display average margin percentage across all bookings
3. THE System SHALL list top 10 most profitable bookings
4. THE System SHALL list bookings with margins below 10% as low margin warnings
5. THE System SHALL allow filtering profitability data by package type and date range

### Requirement 37: Background Job Scheduling

**User Story:** As a system administrator, I want background jobs to run automatically on schedule, so that automated tasks are executed reliably.

#### Acceptance Criteria

1. THE System SHALL use Hangfire for background job scheduling
2. THE System SHALL schedule the daily notification job to run at 09:00 AM
3. THE System SHALL schedule the notification retry job to run every hour
4. THE System SHALL schedule H-30 and H-7 task generation jobs to run daily at 08:00 AM
5. THE System SHALL schedule the auto-reject orders job to run every hour
6. THE System SHALL schedule the auto-unpublish services job to run daily at 10:00 AM

### Requirement 38: API Authentication and Authorization

**User Story:** As a developer, I want all API endpoints to be protected with authentication and authorization, so that only authorized users can access resources.

#### Acceptance Criteria

1. THE System SHALL require a valid JWT token in the Authorization header for all protected endpoints
2. THE System SHALL extract tenant_id from the JWT token and set the database session variable
3. THE System SHALL validate user permissions based on user_type for role-specific endpoints
4. THE System SHALL return 401 Unauthorized when JWT token is missing or invalid
5. THE System SHALL return 403 Forbidden when user lacks required permissions

### Requirement 39: API Error Handling and Validation

**User Story:** As a developer, I want consistent error handling and validation across all API endpoints, so that clients receive clear error messages.

#### Acceptance Criteria

1. THE System SHALL use FluentValidation for request validation
2. WHEN validation fails, THE System SHALL return 400 Bad Request with detailed validation errors
3. WHEN a resource is not found, THE System SHALL return 404 Not Found
4. WHEN a business rule is violated, THE System SHALL return 422 Unprocessable Entity with error details
5. WHEN an unexpected error occurs, THE System SHALL return 500 Internal Server Error and log the error

### Requirement 40: Database Migration and Seeding

**User Story:** As a developer, I want database migrations and seed data, so that the database schema and initial data are set up correctly.

#### Acceptance Criteria

1. THE System SHALL use Entity Framework Core migrations for database schema management
2. THE System SHALL create all 24+ tables with proper indexes and foreign key constraints
3. THE System SHALL enable Row-Level Security policies on tenant-scoped tables
4. THE System SHALL seed initial data for document_types with required_for_package_types
5. THE System SHALL seed initial data for task_templates with trigger stages: after_booking, h_30, h_7

### Requirement 41: Subscription Plan Management

**User Story:** As a Platform_Admin, I want to manage subscription plans with different features and pricing tiers, so that agencies can subscribe to plans that fit their needs.

#### Acceptance Criteria

1. WHEN Platform_Admin creates a subscription plan, THE System SHALL require plan_name, plan_type, monthly_price, and features
2. THE System SHALL support plan_type values: free, basic, professional, enterprise
3. THE System SHALL store features as JSONB with configurable limits (max_users, max_bookings_per_month, max_packages, marketplace_access, api_access, custom_branding)
4. THE System SHALL allow Platform_Admin to activate or deactivate subscription plans
5. THE System SHALL prevent deletion of subscription plans that have active agency subscriptions

### Requirement 42: Agency Subscription Assignment

**User Story:** As a Platform_Admin, I want to assign subscription plans to agencies, so that agencies have access to features based on their subscription.

#### Acceptance Criteria

1. WHEN Platform_Admin assigns a subscription to an agency, THE System SHALL create an agency_subscription record with agency_id, plan_id, start_date, and billing_cycle
2. THE System SHALL support billing_cycle values: monthly, quarterly, annually
3. THE System SHALL calculate next_billing_date based on start_date and billing_cycle
4. THE System SHALL set status to 'active' by default
5. THE System SHALL support status values: active, suspended, cancelled, expired
6. THE System SHALL allow only one active subscription per agency at a time
7. WHEN a subscription is cancelled, THE System SHALL record cancelled_at timestamp and cancellation_reason

### Requirement 43: Commission Configuration

**User Story:** As a Platform_Admin, I want to configure commission rates for different service types and agencies, so that the platform can earn revenue from transactions.

#### Acceptance Criteria

1. WHEN Platform_Admin creates a commission config, THE System SHALL require service_type, commission_type, and commission_value
2. THE System SHALL support service_type values: hotel, flight, visa, transport, guide, insurance, catering, handling, package, marketplace
3. THE System SHALL support commission_type values: percentage, fixed
4. WHEN commission_type is 'percentage', THE System SHALL validate that commission_value is between 0 and 100
5. WHEN commission_type is 'fixed', THE System SHALL validate that commission_value is greater than zero
6. THE System SHALL allow agency-specific commission configs by setting agency_id (NULL for global configs)
7. THE System SHALL prioritize agency-specific configs over global configs when calculating commissions
8. THE System SHALL allow Platform_Admin to set effective_from and effective_until dates for commission configs

### Requirement 44: Commission Transaction Recording

**User Story:** As a Platform_Admin, I want to automatically record commission transactions for bookings and marketplace orders, so that platform revenue is tracked accurately.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE System SHALL calculate commission based on applicable commission config
2. WHEN an agency order is approved in marketplace, THE System SHALL calculate commission based on marketplace commission config
3. THE System SHALL create a commission_transaction record with transaction_type, reference_id, agency_id, base_amount, commission_rate, commission_amount, and status
4. THE System SHALL support transaction_type values: booking, marketplace_order, purchase_order
5. THE System SHALL set status to 'pending' by default
6. THE System SHALL support status values: pending, collected, waived, refunded
7. WHEN commission is collected, THE System SHALL record collected_at timestamp and payment_reference
8. THE System SHALL calculate total commission per agency for reporting purposes

### Requirement 45: Supplier Self-Registration

**User Story:** As a Supplier, I want to register on the platform via a public registration form, so that I can offer services to agencies without Platform_Admin manual creation.

#### Acceptance Criteria

1. THE System SHALL provide a public endpoint POST /api/auth/register/supplier for supplier self-registration
2. WHEN a Supplier submits registration, THE System SHALL require company_name, business_type, email, phone, password, business_license_number, tax_id, address, city, province, postal_code, and country
3. THE System SHALL validate that email is unique across all suppliers
4. THE System SHALL validate that business_license_number is unique across all suppliers
5. THE System SHALL validate that tax_id is unique across all suppliers
6. THE System SHALL hash the password using BCrypt with salt rounds of 12
7. THE System SHALL validate password requirements (minimum 8 characters, at least 1 uppercase, 1 lowercase, 1 number)
8. THE System SHALL create a supplier record with status 'pending' and generate a unique supplier_code
9. THE System SHALL create a user account with user_type 'supplier_staff' linked to the supplier
10. THE System SHALL send email notification to supplier confirming registration submission
11. THE System SHALL send email notification to Platform_Admin for approval review
12. THE System SHALL NOT require authentication for the supplier registration endpoint

### Requirement 46: Standardized API Response Format

**User Story:** As a frontend developer, I want all API responses to follow a consistent format with snake_case naming convention, so that response handling is predictable and follows REST API best practices.

#### Acceptance Criteria

1. THE System SHALL return all successful responses with the structure: { "success": true, "data": {...}, "message": string, "timestamp": ISO8601 }
2. THE System SHALL return all error responses with the structure: { "success": false, "error": { "code": string, "message": string, "details": array }, "timestamp": ISO8601 }
3. THE System SHALL return paginated responses with the structure: { "success": true, "data": [...], "pagination": { "page": number, "page_size": number, "total_items": number, "total_pages": number }, "timestamp": ISO8601 }
4. THE System SHALL use snake_case naming convention for all JSON property names in API responses
5. THE System SHALL use snake_case naming convention for all JSON property names in API request bodies
6. THE System SHALL configure JSON serialization to automatically convert C# PascalCase properties to snake_case JSON properties
7. THE System SHALL include a timestamp in ISO 8601 format (UTC) in all API responses
8. WHEN validation fails, THE System SHALL return error code "VALIDATION_ERROR" with details array containing field-specific errors
9. WHEN a resource is not found, THE System SHALL return error code "NOT_FOUND" with appropriate message
10. WHEN authentication fails, THE System SHALL return error code "UNAUTHORIZED" with appropriate message
11. WHEN authorization fails, THE System SHALL return error code "FORBIDDEN" with appropriate message
12. WHEN a business rule is violated, THE System SHALL return error code "BUSINESS_RULE_VIOLATION" with appropriate message
13. WHEN an unexpected error occurs, THE System SHALL return error code "INTERNAL_SERVER_ERROR" with generic message (without exposing internal details)


---

## Self-Registration with KYC Verification Requirements

### Requirement 47: Agency Self-Registration

**User Story:** As an Agency owner, I want to register on the platform via a public registration form, so that I can use the platform for my travel agency operations.

#### Acceptance Criteria

1. THE System SHALL provide a public endpoint POST /api/auth/register/agency for agency self-registration
2. WHEN an Agency submits registration, THE System SHALL require company_name, owner_name, email, phone, business_type, password, and confirm_password
3. THE System SHALL validate that email is unique across all agencies
4. THE System SHALL validate that password matches confirm_password
5. THE System SHALL hash the password using BCrypt with salt rounds of 12
6. THE System SHALL validate password requirements (minimum 8 characters, at least 1 uppercase, 1 lowercase, 1 number)
7. THE System SHALL create an agency record with verification_status 'pending_documents' and is_active false
8. THE System SHALL generate a unique agency_code in format AGN-YYMMDD-XXX
9. THE System SHALL create a user account with user_type 'agency_staff' linked to the agency
10. THE System SHALL send email notification to agency confirming registration submission
11. THE System SHALL send email notification to Platform_Admin for review
12. THE System SHALL NOT require authentication for the agency registration endpoint
13. WHEN registration is successful, THE System SHALL return agency_id and redirect URL to document upload page

### Requirement 48: Enhanced Supplier Self-Registration with Service Types

**User Story:** As a Supplier, I want to specify which service types I will provide during registration, so that the system can generate appropriate document requirements.

#### Acceptance Criteria

1. THE System SHALL extend existing Supplier registration (Requirement 45) to include service_types field
2. WHEN a Supplier submits registration, THE System SHALL require at least one service_type from: hotel, flight, visa, transport, guide, insurance, catering, handling
3. THE System SHALL allow Supplier to select multiple service_types during registration
4. THE System SHALL store service_types as an array in suppliers table
5. THE System SHALL validate that all selected service_types are valid enum values
6. THE System SHALL use service_types to determine which document requirements to generate
7. THE System SHALL update verification_status to 'pending_documents' (new field)
8. THE System SHALL set verification_attempts to 0 and max_verification_attempts to 3

### Requirement 49: MinIO File Storage Integration

**User Story:** As a developer, I want to integrate MinIO for document storage, so that KYC documents are stored securely and scalably.

#### Acceptance Criteria

1. THE System SHALL use MinIO SDK for .NET to interact with MinIO object storage
2. THE System SHALL read MinIO configuration from appsettings.json including: Endpoint, AccessKey, SecretKey, BucketName, UseSSL, Region
3. THE System SHALL create bucket 'tour-travel-documents' if it does not exist on application startup
4. THE System SHALL organize files in folder structure: {entity_type}/{entity_id}/{document_type}_{timestamp}.{extension}
5. THE System SHALL support file upload with maximum size of 10MB (configurable)
6. THE System SHALL validate file extensions: .pdf, .jpg, .jpeg, .png, .doc, .docx
7. THE System SHALL generate unique filenames using GUID to prevent collisions
8. THE System SHALL return presigned URLs valid for 7 days for file download
9. THE System SHALL implement IFileStorageService interface with methods: UploadAsync, DownloadAsync, DeleteAsync, ExistsAsync, GetFileUrl
10. THE System SHALL handle MinIO connection errors gracefully and return appropriate error messages
11. THE System SHALL log all file operations (upload, download, delete) for audit purposes

### Requirement 50: Document Requirements Configuration

**User Story:** As a Platform_Admin, I want to configure which documents are required for each entity type and service type, so that the system can auto-generate document checklists.

#### Acceptance Criteria

1. THE System SHALL provide a document_requirements table to store document configuration
2. THE System SHALL support entity_type values: 'agency', 'supplier'
3. THE System SHALL support service_type values: null (for general docs), 'hotel', 'flight', 'visa', 'transport', 'guide', 'insurance', 'catering', 'handling'
4. THE System SHALL support document_category values: 'identity', 'business_legal', 'operational', 'service_specific'
5. THE System SHALL allow Platform_Admin to mark documents as mandatory or optional
6. THE System SHALL provide seeder data for standard Indonesian business documents:
   - General: KTP, NPWP, NIB, Akta Pendirian, SK Kemenkumham, SKDU, Bank Statement
   - Hotel: Hotel License, TDUP, Hotel Rating Certificate
   - Flight: IATA/TIDS, Flight License, BSP Certificate
   - Visa: Visa Processing License, Embassy Partnership Letter
   - Transport: Transport License, STNK, KIR, Vehicle Insurance
   - Guide: Tour Guide License, HPI Membership, Language Certificate
   - Insurance: Insurance License (OJK), AAJI Certificate, Insurance Partnership
   - Catering: PIRT/BPOM, Halal Certificate, Hygiene Certificate, Catering License
   - Handling: Ground Handling License, Airport Partnership, Handling Certificate
7. THE System SHALL allow Platform_Admin to activate/deactivate document requirements
8. THE System SHALL provide API endpoint GET /api/admin/document-requirements to list all requirements
9. THE System SHALL provide API endpoint POST /api/admin/document-requirements to create new requirement
10. THE System SHALL provide API endpoint PUT /api/admin/document-requirements/{id} to update requirement

### Requirement 51: Entity Document Management

**User Story:** As an Agency or Supplier, I want to upload required documents for KYC verification, so that I can get approved to use the platform.

#### Acceptance Criteria

1. THE System SHALL provide entity_documents table to store document metadata
2. WHEN an Agency or Supplier completes registration, THE System SHALL auto-generate document checklist based on document_requirements
3. THE System SHALL create entity_documents records with verification_status 'pending' for all mandatory documents
4. THE System SHALL support document upload via POST /api/documents/upload endpoint
5. WHEN a document is uploaded, THE System SHALL validate entity ownership (user must own the entity)
6. THE System SHALL validate file size does not exceed MaxFileSizeMB configuration
7. THE System SHALL validate file extension is in AllowedExtensions configuration
8. THE System SHALL upload file to MinIO using IFileStorageService
9. THE System SHALL save document metadata to entity_documents table including: file_url, file_name, file_size, mime_type, uploaded_at
10. THE System SHALL allow re-upload of rejected documents (replaces existing file)
11. THE System SHALL provide GET /api/documents endpoint to list documents for current user's entity
12. THE System SHALL provide GET /api/documents/{id}/download endpoint to download document
13. THE System SHALL provide DELETE /api/documents/{id} endpoint to delete document (only if verification_status is 'pending' or 'rejected')
14. THE System SHALL track document completion percentage: (verified_count / mandatory_count) * 100

### Requirement 52: Document Verification Workflow

**User Story:** As a Platform_Admin, I want to verify uploaded documents and approve or reject entities, so that only legitimate businesses can use the platform.

#### Acceptance Criteria

1. THE System SHALL provide GET /api/admin/verification-queue endpoint to list entities awaiting verification
2. THE System SHALL support filtering by entity_type, verification_status, and date_range
3. THE System SHALL provide GET /api/admin/verification/{entity_type}/{entity_id} endpoint to view entity details and documents
4. THE System SHALL allow Platform_Admin to verify individual documents via PUT /api/admin/documents/{id}/verify
5. THE System SHALL allow Platform_Admin to reject individual documents via PUT /api/admin/documents/{id}/reject with rejection_reason
6. WHEN a document is verified, THE System SHALL update verification_status to 'verified', set verified_at timestamp, and record verified_by user_id
7. WHEN a document is rejected, THE System SHALL update verification_status to 'rejected' and save rejection_reason
8. THE System SHALL allow Platform_Admin to approve entire entity via POST /api/admin/verification/{entity_type}/{entity_id}/approve
9. WHEN an entity is approved, THE System SHALL:
   - Verify all mandatory documents are in 'verified' status
   - Update entity verification_status to 'verified'
   - Set verified_at timestamp and verified_by user_id
   - For agencies: set is_active to true
   - For suppliers: set status to 'active'
   - Send email notification to entity
10. THE System SHALL allow Platform_Admin to reject entire entity via POST /api/admin/verification/{entity_type}/{entity_id}/reject with rejection_reason
11. WHEN an entity is rejected, THE System SHALL:
    - Update entity verification_status to 'rejected'
    - Increment verification_attempts by 1
    - Save rejection_reason
    - Send email notification to entity with rejection details
12. THE System SHALL prevent entity approval if any mandatory document is not verified
13. THE System SHALL prevent entity approval if verification_attempts >= max_verification_attempts

### Requirement 53: Re-submission After Rejection

**User Story:** As an Agency or Supplier, I want to re-submit documents after rejection, so that I can correct issues and get approved.

#### Acceptance Criteria

1. WHEN an entity is rejected, THE System SHALL allow the entity to re-upload rejected documents
2. THE System SHALL display rejection_reason for each rejected document
3. WHEN a rejected document is re-uploaded, THE System SHALL:
   - Delete old file from MinIO
   - Upload new file to MinIO
   - Update entity_documents with new file metadata
   - Reset verification_status to 'pending'
   - Update uploaded_at timestamp
4. WHEN all mandatory documents are re-uploaded, THE System SHALL automatically update entity verification_status to 'awaiting_approval'
5. THE System SHALL send notification to Platform_Admin when entity is ready for re-verification
6. THE System SHALL enforce max_verification_attempts limit (default: 3)
7. WHEN verification_attempts >= max_verification_attempts, THE System SHALL:
   - Block further re-submissions
   - Display message: "Maximum verification attempts reached. Please contact support."
   - Prevent document upload
8. THE System SHALL allow Platform_Admin to reset verification_attempts if needed

### Requirement 54: Verification Status Management

**User Story:** As a user, I want to see my verification status and progress, so that I know what actions are required.

#### Acceptance Criteria

1. THE System SHALL support verification_status values for agencies and suppliers:
   - 'pending_documents': Registration complete, documents not uploaded
   - 'awaiting_approval': All mandatory documents uploaded, waiting for admin review
   - 'verified': Approved by admin, can use platform
   - 'rejected': Rejected by admin, can re-submit
2. THE System SHALL provide GET /api/auth/me endpoint that includes verification_status and verification_attempts
3. THE System SHALL provide GET /api/documents/progress endpoint that returns:
   - total_mandatory_documents
   - uploaded_documents
   - verified_documents
   - rejected_documents
   - completion_percentage
   - verification_status
   - verification_attempts
   - max_verification_attempts
   - can_resubmit (boolean)
4. WHEN an agency/supplier logs in with verification_status 'pending_documents', THE System SHALL redirect to document upload page
5. WHEN an agency/supplier logs in with verification_status 'awaiting_approval', THE System SHALL display "Verification in progress" message
6. WHEN an agency/supplier logs in with verification_status 'rejected', THE System SHALL display rejection_reason and allow re-submission
7. WHEN an agency/supplier logs in with verification_status 'verified', THE System SHALL allow full access to platform features

### Requirement 55: Access Control During Verification

**User Story:** As a Platform_Admin, I want to ensure that unverified entities have limited access, so that only verified businesses can perform critical operations.

#### Acceptance Criteria

1. THE System SHALL allow agencies/suppliers with verification_status 'pending_documents' or 'awaiting_approval' to access only:
   - Profile/Settings page
   - Document upload page
   - Logout functionality
2. THE System SHALL block access to all other features until verification_status is 'verified'
3. THE System SHALL return HTTP 403 Forbidden with error code "VERIFICATION_REQUIRED" when unverified entity attempts to access restricted endpoints
4. THE System SHALL provide middleware to check verification_status on protected endpoints
5. THE System SHALL allow Platform_Admin to access all features regardless of verification status
6. THE System SHALL include verification_status in JWT token claims for efficient authorization checks

### Requirement 56: Email Notifications for Verification Workflow

**User Story:** As an Agency or Supplier, I want to receive email notifications about my verification status, so that I stay informed about the process.

#### Acceptance Criteria

1. THE System SHALL send email notification when agency/supplier registration is successful with subject "Registration Successful - Upload Documents"
2. THE System SHALL send email notification when all documents are uploaded with subject "Documents Submitted - Verification in Progress"
3. THE System SHALL send email notification when entity is approved with subject "Verification Approved - Welcome to Platform"
4. THE System SHALL send email notification when entity is rejected with subject "Verification Rejected - Action Required" including rejection_reason
5. THE System SHALL send email notification to Platform_Admin when new entity registers with subject "New Registration - Review Required"
6. THE System SHALL send email notification to Platform_Admin when entity submits documents with subject "Documents Submitted - Verification Required"
7. THE System SHALL use email templates with proper formatting and branding
8. THE System SHALL include relevant links in emails (e.g., link to document upload page, link to admin verification page)
9. THE System SHALL log all email sending attempts for audit purposes
10. THE System SHALL handle email sending failures gracefully without blocking the main workflow

### Requirement 57: Audit Logging for Verification Actions

**User Story:** As a Platform_Admin, I want to track all verification-related actions, so that I can audit the verification process.

#### Acceptance Criteria

1. THE System SHALL log all document uploads with: entity_type, entity_id, document_type, file_name, uploaded_by, uploaded_at
2. THE System SHALL log all document verifications with: document_id, verified_by, verified_at
3. THE System SHALL log all document rejections with: document_id, rejected_by, rejected_at, rejection_reason
4. THE System SHALL log all entity approvals with: entity_type, entity_id, approved_by, approved_at
5. THE System SHALL log all entity rejections with: entity_type, entity_id, rejected_by, rejected_at, rejection_reason
6. THE System SHALL log all document deletions with: document_id, deleted_by, deleted_at
7. THE System SHALL provide GET /api/admin/audit-logs endpoint to view verification audit logs
8. THE System SHALL support filtering audit logs by entity_type, entity_id, action_type, date_range
9. THE System SHALL retain audit logs for at least 1 year
10. THE System SHALL include audit log entries in database backups

