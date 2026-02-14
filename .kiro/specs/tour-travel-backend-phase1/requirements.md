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

1. WHEN a Supplier registers, THE System SHALL create a supplier record with status 'pending'
2. THE System SHALL generate a unique supplier_code
3. WHEN Platform_Admin approves a supplier, THE System SHALL update status to 'active' and record approved_at timestamp
4. WHEN Platform_Admin rejects a supplier, THE System SHALL update status to 'rejected'
5. THE System SHALL only allow active suppliers to publish services

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

### Requirement 6: Subscription Plan Management

**User Story:** As a Platform_Admin, I want to create and manage subscription plans, so that I can offer different pricing tiers to agencies.

#### Acceptance Criteria

1. WHEN Platform_Admin creates a subscription plan, THE System SHALL validate that plan_name, monthly_price, and annual_price are provided
2. THE System SHALL support plan_name values: basic, pro, enterprise, custom
3. THE System SHALL validate that monthly_price and annual_price are greater than zero
4. THE System SHALL store features as a JSON array of feature codes
5. THE System SHALL allow Platform_Admin to activate or deactivate subscription plans
6. THE System SHALL prevent deletion of subscription plans that are currently assigned to agencies

### Requirement 7: Commission Configuration Management

**User Story:** As a Platform_Admin, I want to configure commission rates for B2B marketplace transactions, so that the platform can generate revenue from agency-to-agency sales.

#### Acceptance Criteria

1. WHEN Platform_Admin updates commission configuration, THE System SHALL validate that commission_type is either 'percentage' or 'fixed'
2. WHEN commission_type is 'percentage', THE System SHALL validate that commission_rate is between 0 and 100
3. WHEN commission_type is 'fixed', THE System SHALL validate that commission_rate is greater than zero
4. THE System SHALL record commission configuration history with effective_date and changed_by
5. WHEN querying current commission rate, THE System SHALL return the configuration with the most recent effective_date
6. THE System SHALL calculate commission amount for B2B marketplace transactions based on current commission configuration

### Requirement 8: Agency Subscription Assignment

**User Story:** As a Platform_Admin, I want to assign and manage subscription plans for agencies, so that I can control their access to features and billing.

#### Acceptance Criteria

1. WHEN Platform_Admin assigns a subscription to an agency, THE System SHALL require plan_id, billing_cycle, and subscription_start_date
2. THE System SHALL support billing_cycle values: monthly, annual
3. WHEN billing_cycle is 'monthly', THE System SHALL calculate subscription_end_date as subscription_start_date + 30 days
4. WHEN billing_cycle is 'annual', THE System SHALL calculate subscription_end_date as subscription_start_date + 365 days
5. THE System SHALL set subscription_status to 'active' when subscription_start_date <= current_date < subscription_end_date
6. THE System SHALL set subscription_status to 'expired' when current_date >= subscription_end_date
7. THE System SHALL allow Platform_Admin to upgrade or downgrade agency subscription plans

### Requirement 9: Revenue Tracking and Reporting

**User Story:** As a Platform_Admin, I want to track revenue from subscriptions and commissions, so that I can monitor platform financial performance.

#### Acceptance Criteria

1. THE System SHALL calculate total subscription revenue as sum of all active agency subscriptions
2. THE System SHALL calculate Monthly Recurring Revenue (MRR) from monthly subscriptions
3. THE System SHALL calculate Annual Recurring Revenue (ARR) from annual subscriptions
4. THE System SHALL track commission revenue from approved B2B marketplace transactions
5. THE System SHALL provide revenue breakdown by subscription plan (basic, pro, enterprise, custom)
6. THE System SHALL provide commission revenue trend data for the last 12 months
7. THE System SHALL identify top 10 revenue-generating agencies with subscription_revenue, commission_revenue, and total_revenue

### Requirement 10: Seasonal Pricing Management

**User Story:** As a Supplier, I want to set seasonal prices for specific date ranges, so that I can charge different prices during high seasons.

#### Acceptance Criteria

1. WHEN a Supplier creates a seasonal price, THE System SHALL validate that end_date is greater than or equal to start_date
2. THE System SHALL validate that seasonal_price is greater than zero
3. WHEN querying price for a specific date, THE System SHALL return seasonal_price if the date falls within an active seasonal price range
4. WHEN no seasonal price exists for a date, THE System SHALL return the base_price
5. IF multiple seasonal prices overlap for a date, THE System SHALL return the most recently created seasonal price

### Requirement 11: Purchase Order Creation and Workflow

**User Story:** As an Agency staff member, I want to create purchase orders to suppliers, so that I can procure services for my packages.

#### Acceptance Criteria

1. WHEN an Agency creates a purchase order, THE System SHALL generate a unique po_number in format PO-YYMMDD-XXX
2. THE System SHALL require at least one service item in the purchase order
3. THE System SHALL calculate total_amount as the sum of all po_items total_price
4. WHEN a purchase order is created, THE System SHALL set status to 'pending'
5. THE System SHALL send notification to the supplier when a purchase order is created

### Requirement 12: Purchase Order Approval by Supplier

**User Story:** As a Supplier, I want to approve or reject purchase orders, so that I can confirm service availability to agencies.

#### Acceptance Criteria

1. WHEN a Supplier approves a purchase order, THE System SHALL update status to 'approved' and record approved_at timestamp and approved_by user
2. WHEN a Supplier rejects a purchase order, THE System SHALL update status to 'rejected', record rejected_at timestamp, and require rejection_reason
3. THE System SHALL prevent modification of purchase orders after approval or rejection
4. THE System SHALL send notification to the agency when a purchase order is approved or rejected
5. THE System SHALL allow purchase order deletion only when status is 'pending'

### Requirement 13: Package Management as Templates

**User Story:** As an Agency staff member, I want to create reusable package templates without specific dates, so that I can use them for multiple journeys.

#### Acceptance Criteria

1. WHEN an Agency creates a package, THE System SHALL generate a unique package_code in format PKG-{AGENCY_CODE}-{SEQUENCE}
2. THE System SHALL support package types: umrah, hajj, halal_tour, general_tour, custom
3. THE System SHALL require name, duration_days, base_cost, and selling_price
4. THE System SHALL validate that selling_price is greater than or equal to base_cost
5. THE System SHALL NOT include departure_date or return_date fields in packages
6. THE System SHALL allow packages to reference services from approved purchase orders

### Requirement 14: Journey Management with Dates and Quota

**User Story:** As an Agency staff member, I want to create journeys with specific dates and quota management, so that I can manage actual trips.

#### Acceptance Criteria

1. WHEN an Agency creates a journey, THE System SHALL generate a unique journey_code in format JRN-{PACKAGE_CODE}-{YYMMDD}
2. THE System SHALL require departure_date, return_date, and total_quota
3. THE System SHALL initialize confirmed_pax to 0 and available_quota to total_quota
4. THE System SHALL validate that return_date is after departure_date
5. THE System SHALL maintain the invariant: total_quota = confirmed_pax + available_quota

### Requirement 15: Customer Management

**User Story:** As an Agency staff member, I want to manage customer information, so that I can maintain customer relationships and booking history.

#### Acceptance Criteria

1. WHEN an Agency creates a customer, THE System SHALL generate a unique customer_code in format CUST-YYMMDD-XXX
2. THE System SHALL require name and phone
3. THE System SHALL validate that phone is unique within the agency
4. IF email is provided, THE System SHALL validate that email is unique within the agency
5. THE System SHALL automatically update total_bookings, total_spent, and last_booking_date when bookings are created or modified

### Requirement 16: Booking Creation with Staff Input

**User Story:** As an Agency staff member, I want to create bookings manually for customers, so that I can process walk-in, phone, and WhatsApp bookings.

#### Acceptance Criteria

1. WHEN an Agency staff creates a booking, THE System SHALL generate a unique booking_reference in format BKG-YYYY-XXXX
2. THE System SHALL require package_id, journey_id, customer_id, and total_pax
3. THE System SHALL calculate total_amount as package selling_price multiplied by total_pax
4. WHEN a booking is created, THE System SHALL set booking_status to 'pending'
5. THE System SHALL support booking_source values: staff, phone, walk_in, whatsapp

### Requirement 17: Booking Approval and Quota Management

**User Story:** As an Agency staff member, I want to approve bookings to confirm reservations, so that quota is properly managed.

#### Acceptance Criteria

1. WHEN an Agency staff approves a booking, THE System SHALL update booking_status to 'confirmed' and record approved_at timestamp
2. WHEN a booking is confirmed, THE System SHALL decrement journey available_quota by booking total_pax
3. WHEN a booking is confirmed, THE System SHALL increment journey confirmed_pax by booking total_pax
4. THE System SHALL prevent booking approval if journey available_quota is less than booking total_pax
5. WHEN a booking is cancelled, THE System SHALL increment journey available_quota and decrement confirmed_pax by booking total_pax

### Requirement 18: Traveler Management with Mahram Validation

**User Story:** As an Agency staff member, I want to add travelers to bookings with mahram validation, so that Umrah/Hajj bookings comply with religious requirements.

#### Acceptance Criteria

1. WHEN adding a traveler to a booking, THE System SHALL require full_name, gender, and date_of_birth
2. WHEN the package type is 'umrah' or 'hajj', THE System SHALL validate mahram requirements for female travelers
3. IF a female traveler is older than 12 years, THE System SHALL require a mahram_traveler_number referencing a male traveler in the same booking
4. THE System SHALL validate that the referenced mahram traveler exists and is male
5. THE System SHALL assign sequential traveler_number starting from 1 within each booking

### Requirement 19: Document Checklist Auto-Generation

**User Story:** As an Agency staff member, I want document checklists to be automatically generated when bookings are confirmed, so that I can track required documents.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE System SHALL auto-generate document records based on package type
2. THE System SHALL create document records for each traveler based on document_types required_for_package_types
3. WHEN documents are auto-generated, THE System SHALL set status to 'not_submitted'
4. THE System SHALL calculate document completion percentage as (verified documents / total required documents) × 100
5. THE System SHALL identify expiring documents where expiry_date is less than 30 days from today

### Requirement 20: Document Status Tracking and Validation

**User Story:** As an Agency staff member, I want to track document submission and verification, so that I can ensure all required documents are collected before departure.

#### Acceptance Criteria

1. THE System SHALL support document status values: not_submitted, submitted, verified, rejected, expired
2. WHEN a document is submitted, THE System SHALL allow staff to update status to 'submitted' and record document_number and expiry_date
3. WHEN a document is verified, THE System SHALL record verified_by user and verified_at timestamp
4. WHEN a document is rejected, THE System SHALL require rejection_reason
5. FOR passport documents, THE System SHALL validate that expiry_date is more than 6 months after journey departure_date
6. FOR visa documents, THE System SHALL validate that expiry_date is after journey departure_date

### Requirement 21: Task Checklist Auto-Generation

**User Story:** As an Agency staff member, I want task checklists to be automatically generated for bookings, so that I can track operational tasks.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE System SHALL auto-generate tasks from task_templates with trigger_stage 'after_booking'
2. THE System SHALL calculate due_date as booking creation date plus template due_days_offset
3. WHEN tasks are auto-generated, THE System SHALL set status to 'to_do'
4. THE System SHALL support task status values: to_do, in_progress, done
5. THE System SHALL calculate task completion percentage as (completed tasks / total tasks) × 100

### Requirement 22: H-30 and H-7 Task Auto-Generation

**User Story:** As an Agency staff member, I want tasks to be automatically generated at H-30 and H-7 before departure, so that critical pre-departure tasks are not missed.

#### Acceptance Criteria

1. WHEN the system runs the H-30 task generation job, THE System SHALL identify bookings where departure_date equals today plus 30 days
2. FOR each identified booking, THE System SHALL generate tasks from task_templates with trigger_stage 'h_30'
3. WHEN the system runs the H-7 task generation job, THE System SHALL identify bookings where departure_date equals today plus 7 days
4. FOR each identified booking, THE System SHALL generate tasks from task_templates with trigger_stage 'h_7'
5. THE System SHALL run H-30 and H-7 task generation jobs daily at 08:00 AM

### Requirement 23: Task Management with Kanban Board

**User Story:** As an Agency staff member, I want to manage tasks using a Kanban board, so that I can visualize task progress.

#### Acceptance Criteria

1. THE System SHALL support task assignment to users
2. WHEN a task status is updated to 'done', THE System SHALL record completed_at timestamp and completed_by user
3. THE System SHALL identify overdue tasks where due_date is less than today and status is not 'done'
4. THE System SHALL allow filtering tasks by status, assigned user, and due date
5. THE System SHALL allow creation of custom tasks that are not from templates

### Requirement 24: Pre-Departure Notification Scheduling

**User Story:** As an Agency staff member, I want to configure automated pre-departure notifications, so that customers receive timely reminders.

#### Acceptance Criteria

1. THE System SHALL support notification schedules with trigger_days_before values: 30, 14, 7, 3, 1
2. WHEN an Agency creates a notification schedule, THE System SHALL require name, trigger_days_before, and template_id
3. THE System SHALL allow agencies to enable or disable notification schedules
4. THE System SHALL support notification templates with customizable subject and body
5. THE System SHALL support template variables including customer_name, package_name, departure_date, and booking_reference

### Requirement 25: Daily Notification Job Execution

**User Story:** As an Agency staff member, I want notifications to be sent automatically based on schedules, so that customers receive timely information.

#### Acceptance Criteria

1. THE System SHALL run the daily notification job at 09:00 AM
2. FOR each confirmed booking, THE System SHALL calculate days_before_departure as departure_date minus today
3. WHEN days_before_departure matches a notification schedule trigger_days_before, THE System SHALL create a notification log
4. THE System SHALL replace template variables with actual booking data
5. THE System SHALL send notifications via email and in-app channels

### Requirement 26: Notification Retry Mechanism

**User Story:** As an Agency staff member, I want failed notifications to be retried automatically, so that delivery issues are handled gracefully.

#### Acceptance Criteria

1. WHEN a notification fails to send, THE System SHALL set status to 'failed' and record error_message
2. THE System SHALL run the notification retry job every hour
3. THE System SHALL retry failed notifications up to 3 times with 1-hour intervals
4. WHEN a notification is successfully sent after retry, THE System SHALL update status to 'sent' and record sent_at timestamp
5. WHEN retry_count reaches 3 and notification still fails, THE System SHALL set status to 'failed_permanently'

### Requirement 27: Payment Schedule Auto-Generation

**User Story:** As an Agency staff member, I want payment schedules to be automatically generated for bookings, so that I can track customer payments.

#### Acceptance Criteria

1. WHEN a booking is confirmed, THE System SHALL auto-generate 3 payment schedules: DP (40%), Installment 1 (30%), Installment 2 (30%)
2. THE System SHALL calculate DP due_date as booking creation date plus 3 days
3. THE System SHALL calculate Installment 1 due_date as departure_date minus 60 days
4. THE System SHALL calculate Installment 2 due_date as departure_date minus 30 days
5. THE System SHALL calculate each installment amount as booking total_amount multiplied by the percentage

### Requirement 28: Payment Recording and Tracking

**User Story:** As an Agency staff member, I want to record customer payments, so that I can track payment status.

#### Acceptance Criteria

1. WHEN staff records a payment, THE System SHALL create a payment_transaction record
2. THE System SHALL update payment_schedule paid_amount by adding the transaction amount
3. WHEN paid_amount equals the schedule amount, THE System SHALL update status to 'paid' and record paid_date
4. WHEN paid_amount is greater than zero but less than amount, THE System SHALL update status to 'partially_paid'
5. THE System SHALL identify overdue payments where due_date is less than today and status is 'pending'

### Requirement 29: Itinerary Builder

**User Story:** As an Agency staff member, I want to build day-by-day itineraries for packages, so that customers can see detailed trip plans.

#### Acceptance Criteria

1. THE System SHALL allow one itinerary per package
2. WHEN creating an itinerary, THE System SHALL allow adding multiple itinerary days with sequential day_number
3. FOR each itinerary day, THE System SHALL require title and allow optional description
4. THE System SHALL allow adding multiple activities per day with time, location, activity description, and meal_type
5. THE System SHALL support meal_type values: breakfast, lunch, dinner, snack, none

### Requirement 30: Supplier Bill Auto-Generation

**User Story:** As an Agency staff member, I want supplier bills to be automatically generated from approved purchase orders, so that I can track payables.

#### Acceptance Criteria

1. WHEN a purchase order is approved, THE System SHALL auto-generate a supplier_bill record
2. THE System SHALL generate a unique bill_number in format BILL-YYMMDD-XXX
3. THE System SHALL set bill_date to the purchase order approval date
4. THE System SHALL calculate due_date as bill_date plus 30 days
5. THE System SHALL set total_amount equal to purchase order total_amount

### Requirement 31: Supplier Payment Recording

**User Story:** As an Agency staff member, I want to record payments to suppliers, so that I can track payables status.

#### Acceptance Criteria

1. WHEN staff records a supplier payment, THE System SHALL create a supplier_payment record
2. THE System SHALL update supplier_bill paid_amount by adding the payment amount
3. WHEN paid_amount equals total_amount, THE System SHALL update status to 'paid'
4. WHEN paid_amount is greater than zero but less than total_amount, THE System SHALL update status to 'partially_paid'
5. THE System SHALL identify overdue bills where due_date is less than today and status is 'unpaid'

### Requirement 32: Communication Log

**User Story:** As an Agency staff member, I want to log customer communications, so that I can track interaction history and follow-ups.

#### Acceptance Criteria

1. WHEN staff creates a communication log, THE System SHALL require customer_id, communication_type, and notes
2. THE System SHALL support communication_type values: call, email, whatsapp, meeting, other
3. THE System SHALL allow linking communication logs to specific bookings
4. WHEN follow_up_required is true, THE System SHALL require follow_up_date
5. THE System SHALL allow marking follow-ups as done by setting follow_up_done to true

### Requirement 33: B2B Marketplace - Agency Service Publishing

**User Story:** As an Agency A staff member, I want to publish excess inventory to the marketplace, so that other agencies can purchase from me.

#### Acceptance Criteria

1. WHEN Agency A publishes a service to marketplace, THE System SHALL create an agency_service record linked to an approved purchase_order
2. THE System SHALL require reseller_price to be greater than cost_price with minimum 5% markup
3. THE System SHALL calculate markup_percentage as ((reseller_price - cost_price) / cost_price) × 100
4. THE System SHALL initialize available_quota equal to total_quota
5. WHEN is_published is set to true, THE System SHALL record published_at timestamp

### Requirement 34: B2B Marketplace - Service Browsing with Hidden Supplier

**User Story:** As an Agency B staff member, I want to browse marketplace services without seeing supplier names, so that I can purchase from other agencies.

#### Acceptance Criteria

1. WHEN Agency B browses the marketplace, THE System SHALL return only published agency_services where agency_id is not Agency B
2. THE System SHALL NOT expose supplier_id or supplier name in marketplace API responses
3. THE System SHALL display the seller agency name (Agency A) but hide the original supplier
4. THE System SHALL show available_quota for each service
5. THE System SHALL prevent agencies from viewing their own published services in the marketplace

### Requirement 35: B2B Marketplace - Agency Order Creation

**User Story:** As an Agency B staff member, I want to create orders to other agencies, so that I can purchase marketplace services.

#### Acceptance Criteria

1. WHEN Agency B creates an order, THE System SHALL generate a unique order_number in format AO-YYMMDD-XXX
2. THE System SHALL validate that order quantity is less than or equal to agency_service available_quota
3. WHEN an order is created, THE System SHALL set status to 'pending'
4. THE System SHALL reserve quota by incrementing agency_service reserved_quota and decrementing available_quota by order quantity
5. THE System SHALL send notification to Agency A when an order is created

### Requirement 36: B2B Marketplace - Order Approval Workflow

**User Story:** As an Agency A staff member, I want to approve or reject orders from other agencies, so that I can control my inventory sales.

#### Acceptance Criteria

1. WHEN Agency A approves an order, THE System SHALL update status to 'approved' and record approved_at timestamp
2. WHEN an order is approved, THE System SHALL transfer quota from reserved_quota to sold_quota
3. WHEN Agency A rejects an order, THE System SHALL update status to 'rejected' and require rejection_reason
4. WHEN an order is rejected, THE System SHALL release quota by decrementing reserved_quota and incrementing available_quota
5. THE System SHALL send notification to Agency B when an order is approved or rejected

### Requirement 37: B2B Marketplace - Auto-Reject Pending Orders

**User Story:** As an Agency B staff member, I want pending orders to be automatically rejected after 24 hours, so that my quota is not locked indefinitely.

#### Acceptance Criteria

1. THE System SHALL run the auto-reject orders job every hour
2. THE System SHALL identify pending orders where created_at is more than 24 hours ago
3. FOR each identified order, THE System SHALL update status to 'rejected' and set rejection_reason to 'Auto-rejected: No response within 24 hours'
4. THE System SHALL release reserved quota back to available_quota
5. THE System SHALL send notification to the buyer agency when an order is auto-rejected

### Requirement 38: B2B Marketplace - Auto-Unpublish Zero Quota Services

**User Story:** As an Agency A staff member, I want services to be automatically unpublished when quota reaches zero, so that buyers cannot order unavailable services.

#### Acceptance Criteria

1. THE System SHALL run the auto-unpublish services job daily at 10:00 AM
2. THE System SHALL identify published agency_services where available_quota equals zero
3. FOR each identified service, THE System SHALL set is_published to false
4. THE System SHALL allow manual republishing when quota becomes available again
5. THE System SHALL maintain the invariant: total_quota = used_quota + available_quota + reserved_quota + sold_quota

### Requirement 39: Profitability Tracking - Revenue and Cost Calculation

**User Story:** As an Agency staff member, I want to track booking profitability, so that I can identify high and low margin bookings.

#### Acceptance Criteria

1. THE System SHALL calculate booking revenue as package selling_price multiplied by total_pax
2. THE System SHALL calculate booking cost as the sum of all service costs from purchase orders and agency orders
3. THE System SHALL calculate gross_profit as revenue minus cost
4. THE System SHALL calculate gross_margin_percentage as (gross_profit / revenue) × 100
5. THE System SHALL identify low margin bookings where gross_margin_percentage is less than 10%

### Requirement 40: Profitability Dashboard

**User Story:** As an Agency staff member, I want to view profitability metrics on a dashboard, so that I can make informed pricing decisions.

#### Acceptance Criteria

1. THE System SHALL display total revenue, total cost, and total profit for a selected date range
2. THE System SHALL display average margin percentage across all bookings
3. THE System SHALL list top 10 most profitable bookings
4. THE System SHALL list bookings with margins below 10% as low margin warnings
5. THE System SHALL allow filtering profitability data by package type and date range

### Requirement 41: Background Job Scheduling

**User Story:** As a system administrator, I want background jobs to run automatically on schedule, so that automated tasks are executed reliably.

#### Acceptance Criteria

1. THE System SHALL use Hangfire for background job scheduling
2. THE System SHALL schedule the daily notification job to run at 09:00 AM
3. THE System SHALL schedule the notification retry job to run every hour
4. THE System SHALL schedule H-30 and H-7 task generation jobs to run daily at 08:00 AM
5. THE System SHALL schedule the auto-reject orders job to run every hour
6. THE System SHALL schedule the auto-unpublish services job to run daily at 10:00 AM

### Requirement 42: API Authentication and Authorization

**User Story:** As a developer, I want all API endpoints to be protected with authentication and authorization, so that only authorized users can access resources.

#### Acceptance Criteria

1. THE System SHALL require a valid JWT token in the Authorization header for all protected endpoints
2. THE System SHALL extract tenant_id from the JWT token and set the database session variable
3. THE System SHALL validate user permissions based on user_type for role-specific endpoints
4. THE System SHALL return 401 Unauthorized when JWT token is missing or invalid
5. THE System SHALL return 403 Forbidden when user lacks required permissions

### Requirement 43: API Error Handling and Validation

**User Story:** As a developer, I want consistent error handling and validation across all API endpoints, so that clients receive clear error messages.

#### Acceptance Criteria

1. THE System SHALL use FluentValidation for request validation
2. WHEN validation fails, THE System SHALL return 400 Bad Request with detailed validation errors
3. WHEN a resource is not found, THE System SHALL return 404 Not Found
4. WHEN a business rule is violated, THE System SHALL return 422 Unprocessable Entity with error details
5. WHEN an unexpected error occurs, THE System SHALL return 500 Internal Server Error and log the error

### Requirement 44: Database Migration and Seeding

**User Story:** As a developer, I want database migrations and seed data, so that the database schema and initial data are set up correctly.

#### Acceptance Criteria

1. THE System SHALL use Entity Framework Core migrations for database schema management
2. THE System SHALL create all 24+ tables with proper indexes and foreign key constraints
3. THE System SHALL enable Row-Level Security policies on tenant-scoped tables
4. THE System SHALL seed initial data for document_types with required_for_package_types
5. THE System SHALL seed initial data for task_templates with trigger stages: after_booking, h_30, h_7
