# Requirements Document

## Introduction

This document specifies the requirements for Phase 1 MVP of the Tour & Travel Agency ERP SaaS Platform Frontend. The system is built using Angular 20 with standalone components, following the architecture patterns from the ibis-frontend-main project. The frontend provides three distinct portals (Platform Admin, Supplier, and Agency) with comprehensive ERP functionality including procurement, package management, booking operations, document tracking, task management, and B2B marketplace features.

## Glossary

- **Platform_Admin_Portal**: Web interface for platform administrators to manage agencies and suppliers
- **Supplier_Portal**: Web interface for suppliers to manage services and purchase orders
- **Agency_Portal**: Web interface for travel agencies to manage complete ERP operations
- **API_Service**: Service layer connecting to backend REST API endpoints
- **NgRx_Store**: Centralized state management using Redux pattern
- **Standalone_Component**: Angular component without NgModule dependencies
- **Lazy_Loading**: On-demand loading of feature modules via routes
- **RLS_Context**: Row-Level Security context from JWT token for multi-tenant isolation
- **Smart_Component**: Container component managing state and business logic
- **Presentational_Component**: UI component receiving data via inputs and emitting events
- **Feature_Module**: Self-contained module with routes, components, services, and store
- **PrimeNG**: UI component library for Angular
- **TailwindCSS**: Utility-first CSS framework
- **Lucide_Icons**: Modern icon library for Angular
- **JWT_Token**: JSON Web Token for authentication containing user and tenant context
- **Toast_Notification**: Temporary notification message displayed to users
- **Confirmation_Dialog**: Modal dialog requesting user confirmation before actions
- **Loading_State**: UI state indicating data is being fetched or processed
- **Form_Validation**: Client-side validation using Angular Reactive Forms
- **Route_Guard**: Service protecting routes based on authentication and authorization
- **HTTP_Interceptor**: Service intercepting HTTP requests for auth, error handling, and loading states


## Requirements

### Requirement 1: Angular 20 Standalone Components Architecture

**User Story:** As a developer, I want the application built with Angular 20 standalone components, so that the codebase is modern, modular, and maintainable.

#### Acceptance Criteria

1. THE Frontend SHALL use Angular 20 with standalone components (no NgModules except for legacy libraries)
2. THE Frontend SHALL organize code in feature-based folder structure with features, core, shared, store, and layouts directories
3. THE Frontend SHALL use lazy loading for all feature modules via route configuration
4. THE Frontend SHALL import dependencies directly in component metadata using imports array
5. THE Frontend SHALL follow the folder structure pattern from ibis-frontend-main project

### Requirement 2: Multi-Tenant Authentication and Authorization

**User Story:** As a user, I want secure authentication with role-based access control, so that I can access features appropriate to my role.

#### Acceptance Criteria

1. WHEN a user submits valid credentials, THE Frontend SHALL send login request to backend and store JWT token in localStorage
2. THE Frontend SHALL extract user_type, agency_id, and supplier_id from JWT token payload
3. THE Frontend SHALL use AuthGuard to protect all routes except login and registration
4. THE Frontend SHALL use RoleGuard to restrict routes based on user_type (platform_admin, agency_staff, supplier_staff)
5. WHEN JWT token expires, THE Frontend SHALL redirect user to login page and clear stored token

### Requirement 3: HTTP Interceptors for Cross-Cutting Concerns

**User Story:** As a developer, I want HTTP interceptors for authentication, error handling, and loading states, so that these concerns are handled consistently across the application.

#### Acceptance Criteria

1. THE Frontend SHALL use AuthInterceptor to attach JWT token to all outgoing HTTP requests in Authorization header
2. THE Frontend SHALL use ErrorInterceptor to catch HTTP errors and display toast notifications with error messages
3. THE Frontend SHALL use LoadingInterceptor to track pending HTTP requests and display loading spinner
4. THE Frontend SHALL handle 401 Unauthorized responses by redirecting to login page
5. THE Frontend SHALL handle 403 Forbidden responses by displaying permission error message


### Requirement 4: Component Structure and Separation of Concerns

**User Story:** As a developer, I want clear separation between HTML templates and TypeScript logic, so that the codebase is maintainable and follows Angular best practices.

#### Acceptance Criteria

1. THE Frontend SHALL separate component logic (TypeScript) from templates (HTML) and styles (SCSS)
2. THE Frontend SHALL use separate files for component.ts, component.html, and component.scss
3. THE Frontend SHALL keep business logic in TypeScript files and presentation logic in HTML templates
4. THE Frontend SHALL use Angular signals for reactive state management in components
5. THE Frontend SHALL follow smart/presentational component pattern where appropriate

### Requirement 5: PrimeNG Component Styling Standards

**User Story:** As a developer, I want consistent styling for PrimeNG components, so that the UI has a uniform appearance.

#### Acceptance Criteria

1. THE Frontend SHALL use class="p-inputtext-sm" for all input and textarea elements
2. THE Frontend SHALL use size="small" attribute for all PrimeNG form components (p-dropdown, p-calendar, p-multiselect, etc.)
3. THE Frontend SHALL use styleClass="p-datatable-sm" for all p-table components
4. THE Frontend SHALL use size="small" for all p-button components unless explicitly requiring larger size
5. THE Frontend SHALL follow PrimeNG 20 component API and styling conventions

### Requirement 6: NgRx Store for State Management

**User Story:** As a developer, I want centralized state management using NgRx, so that application state is predictable and debuggable.

#### Acceptance Criteria

1. THE Frontend SHALL use NgRx store for managing application state
2. THE Frontend SHALL organize store by feature with actions, reducer, effects, selectors, and state files
3. THE Frontend SHALL use NgRx effects for side effects like HTTP requests
4. THE Frontend SHALL use selectors for deriving state in components
5. THE Frontend SHALL dispatch actions from components and handle state updates in reducers

### Requirement 7: PrimeNG UI Components and TailwindCSS Styling

**User Story:** As a developer, I want to use PrimeNG components and TailwindCSS for consistent UI, so that the application has a professional appearance.

#### Acceptance Criteria

1. THE Frontend SHALL use PrimeNG 20 components for UI elements (Table, Dialog, Calendar, Dropdown, Button, etc.)
2. THE Frontend SHALL use TailwindCSS 4 for utility-first styling
3. THE Frontend SHALL use Lucide Angular for icons
4. THE Frontend SHALL implement responsive design with mobile-first approach
5. THE Frontend SHALL use consistent color scheme and spacing throughout the application

### Requirement 8: Platform Admin Portal - Agency Management

**User Story:** As a Platform_Admin, I want to manage travel agencies, so that I can onboard new agencies and control their access.

#### Acceptance Criteria

1. WHEN Platform_Admin views agency list, THE Frontend SHALL display table with agency_code, company_name, email, subscription_plan, and is_active status
2. THE Frontend SHALL provide create agency form with fields: company_name, email, phone, address, city, province, postal_code
3. THE Frontend SHALL allow Platform_Admin to activate or deactivate agencies using toggle button
4. THE Frontend SHALL display confirmation dialog before deactivating an agency
5. THE Frontend SHALL show toast notification after successful agency creation or update


### Requirement 8: Platform Admin Portal - Supplier Approval

**User Story:** As a Platform_Admin, I want to approve or reject supplier registrations, so that only verified suppliers can offer services.

#### Acceptance Criteria

1. WHEN Platform_Admin views supplier list, THE Frontend SHALL display table with supplier_code, company_name, email, business_type, and status
2. THE Frontend SHALL filter suppliers by status (pending, active, rejected, suspended)
3. THE Frontend SHALL provide approve button for pending suppliers that updates status to active
4. THE Frontend SHALL provide reject button that opens dialog requiring rejection_reason
5. THE Frontend SHALL show toast notification after successful supplier approval or rejection

### Requirement 9: Platform Admin Portal - Dashboard

**User Story:** As a Platform_Admin, I want to view platform metrics on a dashboard, so that I can monitor platform health.

#### Acceptance Criteria

1. THE Frontend SHALL display total count of active agencies
2. THE Frontend SHALL display total count of active suppliers
3. THE Frontend SHALL display total count of pending supplier approvals
4. THE Frontend SHALL display chart showing agency registrations over time
5. THE Frontend SHALL display list of recent agency registrations

### Requirement 10: Platform Admin Portal - Subscription Plan Management

**User Story:** As a Platform_Admin, I want to create and manage subscription plans, so that I can offer different pricing tiers to agencies.

#### Acceptance Criteria

1. WHEN Platform_Admin views subscription plans, THE Frontend SHALL display table with plan_name, monthly_price, annual_price, max_users, max_bookings_per_month, features, and is_active status
2. THE Frontend SHALL provide create subscription plan form with fields: plan_name, description, monthly_price, annual_price, max_users, max_bookings_per_month, features
3. THE Frontend SHALL support plan_name values: basic, pro, enterprise, custom
4. THE Frontend SHALL allow Platform_Admin to activate or deactivate subscription plans using toggle button
5. THE Frontend SHALL display features as a multi-select checklist (e.g., B2B Marketplace, Advanced Reports, API Access, Priority Support)
6. THE Frontend SHALL show toast notification after successful subscription plan creation or update

### Requirement 11: Platform Admin Portal - Commission Configuration

**User Story:** As a Platform_Admin, I want to configure commission rates for B2B marketplace transactions, so that the platform can generate revenue from agency-to-agency sales.

#### Acceptance Criteria

1. WHEN Platform_Admin views commission settings, THE Frontend SHALL display current commission_type (percentage or fixed) and commission_rate
2. THE Frontend SHALL provide edit commission form with fields: commission_type, commission_rate, effective_date
3. WHEN commission_type is percentage, THE Frontend SHALL validate that commission_rate is between 0 and 100
4. WHEN commission_type is fixed, THE Frontend SHALL validate that commission_rate is greater than zero
5. THE Frontend SHALL display commission history table showing previous rates with effective_date and changed_by
6. THE Frontend SHALL show confirmation dialog before updating commission settings
7. THE Frontend SHALL show toast notification after successful commission configuration update

### Requirement 12: Platform Admin Portal - Agency Subscription Assignment

**User Story:** As a Platform_Admin, I want to assign and manage subscription plans for agencies, so that I can control their access to features.

#### Acceptance Criteria

1. WHEN Platform_Admin views agency detail, THE Frontend SHALL display current subscription plan, subscription_start_date, subscription_end_date, and subscription_status
2. THE Frontend SHALL provide assign subscription button that opens dialog with fields: plan_id, billing_cycle (monthly or annual), subscription_start_date
3. THE Frontend SHALL calculate subscription_end_date based on billing_cycle (30 days for monthly, 365 days for annual)
4. THE Frontend SHALL display subscription status badge with colors: active (green), expired (red), trial (blue), suspended (yellow)
5. THE Frontend SHALL provide upgrade/downgrade plan button that opens plan selection dialog
6. THE Frontend SHALL show confirmation dialog before changing subscription plan
7. THE Frontend SHALL show toast notification after successful subscription assignment or change

### Requirement 13: Platform Admin Portal - Revenue Dashboard

**User Story:** As a Platform_Admin, I want to view revenue metrics from subscriptions and commissions, so that I can monitor platform financial performance.

#### Acceptance Criteria

1. WHEN Platform_Admin views revenue dashboard, THE Frontend SHALL display total subscription revenue (monthly recurring revenue)
2. THE Frontend SHALL display total commission revenue from B2B marketplace transactions
3. THE Frontend SHALL display total revenue (subscription + commission)
4. THE Frontend SHALL display revenue breakdown chart by subscription plan (basic, pro, enterprise)
5. THE Frontend SHALL display commission revenue trend chart over time (last 12 months)
6. THE Frontend SHALL display table of top 10 revenue-generating agencies with agency_name, subscription_plan, subscription_revenue, commission_revenue, and total_revenue
7. THE Frontend SHALL allow filtering revenue data by date range (this month, last month, last 3 months, last 6 months, last year, custom range)

### Requirement 14: Supplier Portal - Service Catalog Management

**User Story:** As a Supplier, I want to create and manage my service catalog, so that agencies can browse and purchase my services.

#### Acceptance Criteria

1. WHEN Supplier views service list, THE Frontend SHALL display table with service_code, service_type, name, base_price, and status
2. THE Frontend SHALL provide create service form with fields: service_type, name, description, base_price, currency, location_city, location_country
3. WHEN service_type is hotel, THE Frontend SHALL show additional fields: hotel_name, hotel_star_rating, room_type, meal_plan
4. WHEN service_type is flight, THE Frontend SHALL show additional fields: airline, flight_class, departure_airport, arrival_airport
5. WHEN service_type is visa, THE Frontend SHALL show additional fields: visa_type, processing_days, validity_days, entry_type
6. THE Frontend SHALL allow Supplier to publish services using publish button
7. THE Frontend SHALL show toast notification after successful service creation or update

### Requirement 15: Supplier Portal - Seasonal Pricing

**User Story:** As a Supplier, I want to set seasonal prices for date ranges, so that I can charge different prices during high seasons.

#### Acceptance Criteria

1. WHEN Supplier views service detail, THE Frontend SHALL display list of seasonal prices with season_name, start_date, end_date, and seasonal_price
2. THE Frontend SHALL provide add seasonal price form with fields: season_name, start_date, end_date, seasonal_price
3. THE Frontend SHALL validate that end_date is greater than or equal to start_date
4. THE Frontend SHALL validate that seasonal_price is greater than zero
5. THE Frontend SHALL show toast notification after successful seasonal price creation


### Requirement 16: Supplier Portal - Purchase Order Management

**User Story:** As a Supplier, I want to view and manage purchase orders from agencies, so that I can approve or reject service requests.

#### Acceptance Criteria

1. WHEN Supplier views purchase order list, THE Frontend SHALL display table with po_number, agency_name, total_amount, status, and created_at
2. THE Frontend SHALL filter purchase orders by status (pending, approved, rejected)
3. WHEN Supplier views purchase order detail, THE Frontend SHALL display all po_items with service details, quantity, unit_price, and total_price
4. THE Frontend SHALL provide approve button for pending purchase orders
5. THE Frontend SHALL provide reject button that opens dialog requiring rejection_reason
6. THE Frontend SHALL show confirmation dialog before approving or rejecting purchase orders
7. THE Frontend SHALL show toast notification after successful purchase order approval or rejection

### Requirement 17: Agency Portal - Supplier Browsing and Procurement

**User Story:** As an Agency staff member, I want to browse suppliers and create purchase orders, so that I can procure services for my packages.

#### Acceptance Criteria

1. WHEN Agency staff views supplier list, THE Frontend SHALL display table with supplier_code, company_name, business_type, and view services button
2. WHEN Agency staff views supplier services, THE Frontend SHALL display table with service_code, service_type, name, base_price, and add to cart button
3. THE Frontend SHALL maintain shopping cart state for selected services
4. THE Frontend SHALL provide create purchase order form that includes all cart items
5. THE Frontend SHALL calculate total_amount as sum of all po_items total_price
6. THE Frontend SHALL show toast notification after successful purchase order creation

### Requirement 18: Agency Portal - Package Management

**User Story:** As an Agency staff member, I want to create and manage package templates, so that I can reuse them for multiple journeys.

#### Acceptance Criteria

1. WHEN Agency staff views package list, THE Frontend SHALL display table with package_code, package_type, name, duration_days, selling_price, and status
2. THE Frontend SHALL provide create package form with fields: package_type, name, description, duration_days, base_cost, markup_type, markup_value, selling_price
3. THE Frontend SHALL support package_type values: umrah, hajj, halal_tour, general_tour, custom
4. THE Frontend SHALL validate that selling_price is greater than or equal to base_cost
5. THE Frontend SHALL allow adding services from approved purchase orders to packages
6. THE Frontend SHALL calculate base_cost as sum of all package_services total_cost
7. THE Frontend SHALL show toast notification after successful package creation or update

### Requirement 19: Agency Portal - Journey Management

**User Story:** As an Agency staff member, I want to create journeys with specific dates and quota, so that I can manage actual trips.

#### Acceptance Criteria

1. WHEN Agency staff views journey list, THE Frontend SHALL display table with journey_code, package_name, departure_date, return_date, total_quota, confirmed_pax, available_quota, and status
2. THE Frontend SHALL provide create journey form with fields: package_id, departure_date, return_date, total_quota
3. THE Frontend SHALL validate that return_date is after departure_date
4. THE Frontend SHALL display quota information: total_quota, confirmed_pax, available_quota
5. THE Frontend SHALL show toast notification after successful journey creation or update


### Requirement 20: Agency Portal - Customer Management

**User Story:** As an Agency staff member, I want to manage customer information, so that I can maintain customer relationships and booking history.

#### Acceptance Criteria

1. WHEN Agency staff views customer list, THE Frontend SHALL display table with customer_code, name, email, phone, total_bookings, total_spent, and last_booking_date
2. THE Frontend SHALL provide create customer form with fields: name, email, phone, address, city, province, postal_code, country
3. THE Frontend SHALL validate that phone is unique within the agency
4. IF email is provided, THE Frontend SHALL validate that email is unique within the agency
5. THE Frontend SHALL show customer booking history when viewing customer detail
6. THE Frontend SHALL show toast notification after successful customer creation or update

### Requirement 21: Agency Portal - Booking Creation

**User Story:** As an Agency staff member, I want to create bookings manually for customers, so that I can process walk-in, phone, and WhatsApp bookings.

#### Acceptance Criteria

1. WHEN Agency staff views booking list, THE Frontend SHALL display table with booking_reference, customer_name, package_name, journey_code, total_pax, total_amount, booking_status, and created_at
2. THE Frontend SHALL provide create booking form with fields: package_id, journey_id, customer_id, total_pax, booking_source
3. THE Frontend SHALL support booking_source values: staff, phone, walk_in, whatsapp
4. THE Frontend SHALL calculate total_amount as package selling_price multiplied by total_pax
5. THE Frontend SHALL validate that journey available_quota is greater than or equal to total_pax
6. THE Frontend SHALL show toast notification after successful booking creation

### Requirement 22: Agency Portal - Booking Approval and Management

**User Story:** As an Agency staff member, I want to approve bookings to confirm reservations, so that quota is properly managed.

#### Acceptance Criteria

1. WHEN Agency staff views booking detail, THE Frontend SHALL display booking information, customer details, journey details, and travelers list
2. THE Frontend SHALL provide approve button for pending bookings
3. THE Frontend SHALL show confirmation dialog before approving bookings
4. THE Frontend SHALL provide cancel button that opens dialog requiring cancellation_reason
5. THE Frontend SHALL update journey quota display after booking approval or cancellation
6. THE Frontend SHALL show toast notification after successful booking approval or cancellation

### Requirement 23: Agency Portal - Traveler Management

**User Story:** As an Agency staff member, I want to add travelers to bookings with mahram validation, so that Umrah/Hajj bookings comply with religious requirements.

#### Acceptance Criteria

1. WHEN Agency staff views booking detail, THE Frontend SHALL display list of travelers with traveler_number, full_name, gender, date_of_birth, and passport_number
2. THE Frontend SHALL provide add traveler form with fields: full_name, gender, date_of_birth, nationality, passport_number, passport_expiry
3. WHEN package_type is umrah or hajj AND traveler is female AND age is greater than 12, THE Frontend SHALL require mahram_traveler_number field
4. THE Frontend SHALL validate that mahram_traveler_number references an existing male traveler in the same booking
5. THE Frontend SHALL show toast notification after successful traveler addition


### Requirement 24: Agency Portal - Document Management

**User Story:** As an Agency staff member, I want to track document submission and verification, so that I can ensure all required documents are collected before departure.

#### Acceptance Criteria

1. WHEN Agency staff views booking detail, THE Frontend SHALL display document checklist with document_type, traveler_name, status, document_number, expiry_date, and actions
2. THE Frontend SHALL display document completion percentage calculated as (verified documents / total required documents) × 100
3. THE Frontend SHALL provide update status button for each document with status options: not_submitted, submitted, verified, rejected, expired
4. WHEN updating status to submitted, THE Frontend SHALL show form with fields: document_number, issue_date, expiry_date
5. WHEN updating status to rejected, THE Frontend SHALL require rejection_reason
6. THE Frontend SHALL highlight expiring documents where expiry_date is less than 30 days from today
7. THE Frontend SHALL show toast notification after successful document status update

### Requirement 25: Agency Portal - Task Management with Kanban Board

**User Story:** As an Agency staff member, I want to manage tasks using a Kanban board, so that I can visualize task progress.

#### Acceptance Criteria

1. WHEN Agency staff views booking detail, THE Frontend SHALL display task list with title, status, priority, assigned_to, due_date, and actions
2. THE Frontend SHALL provide Kanban board view with three columns: to_do, in_progress, done
3. THE Frontend SHALL allow drag-and-drop to move tasks between columns
4. THE Frontend SHALL highlight overdue tasks where due_date is less than today and status is not done
5. THE Frontend SHALL provide assign task button that opens dialog with user dropdown
6. THE Frontend SHALL provide add custom task button with fields: title, description, priority, due_date
7. THE Frontend SHALL show toast notification after successful task status update or assignment

### Requirement 26: Agency Portal - Pre-Departure Notification Configuration

**User Story:** As an Agency staff member, I want to configure automated pre-departure notifications, so that customers receive timely reminders.

#### Acceptance Criteria

1. WHEN Agency staff views notification schedules, THE Frontend SHALL display table with name, trigger_days_before, notification_type, template_name, and is_enabled status
2. THE Frontend SHALL provide create notification schedule form with fields: name, trigger_days_before, notification_type, template_id
3. THE Frontend SHALL support trigger_days_before values: 30, 14, 7, 3, 1
4. THE Frontend SHALL allow enabling or disabling notification schedules using toggle button
5. THE Frontend SHALL show toast notification after successful notification schedule creation or update

### Requirement 27: Agency Portal - Notification Template Management

**User Story:** As an Agency staff member, I want to create notification templates with variables, so that I can customize customer communications.

#### Acceptance Criteria

1. WHEN Agency staff views notification templates, THE Frontend SHALL display table with name, subject, and actions
2. THE Frontend SHALL provide create template form with fields: name, subject, body
3. THE Frontend SHALL display available template variables: customer_name, package_name, departure_date, return_date, booking_reference
4. THE Frontend SHALL provide text editor with variable insertion buttons
5. THE Frontend SHALL show template preview with sample data
6. THE Frontend SHALL show toast notification after successful template creation or update


### Requirement 28: Agency Portal - Payment Schedule and Tracking

**User Story:** As an Agency staff member, I want to track customer payment schedules, so that I can monitor payment status.

#### Acceptance Criteria

1. WHEN Agency staff views booking detail, THE Frontend SHALL display payment schedule table with installment_name, due_date, amount, paid_amount, status, and actions
2. THE Frontend SHALL highlight overdue payments where due_date is less than today and status is pending
3. THE Frontend SHALL provide record payment button that opens dialog with fields: amount, payment_method, payment_date, reference_number
4. THE Frontend SHALL update payment schedule status after recording payment (pending, partially_paid, paid)
5. THE Frontend SHALL display total outstanding amount for the booking
6. THE Frontend SHALL show toast notification after successful payment recording

### Requirement 29: Agency Portal - Itinerary Builder

**User Story:** As an Agency staff member, I want to build day-by-day itineraries for packages, so that customers can see detailed trip plans.

#### Acceptance Criteria

1. WHEN Agency staff views package detail, THE Frontend SHALL display itinerary tab with day-by-day breakdown
2. THE Frontend SHALL provide add day button that creates new itinerary day with fields: day_number, title, description
3. FOR each itinerary day, THE Frontend SHALL provide add activity button with fields: time, location, activity, description, meal_type
4. THE Frontend SHALL support meal_type values: breakfast, lunch, dinner, snack, none
5. THE Frontend SHALL allow reordering days and activities using drag-and-drop
6. THE Frontend SHALL show toast notification after successful itinerary update

### Requirement 30: Agency Portal - Supplier Bills and Payables

**User Story:** As an Agency staff member, I want to track supplier bills and payments, so that I can manage payables.

#### Acceptance Criteria

1. WHEN Agency staff views supplier bills, THE Frontend SHALL display table with bill_number, supplier_name, bill_date, due_date, total_amount, paid_amount, status, and actions
2. THE Frontend SHALL filter bills by status (unpaid, partially_paid, paid)
3. THE Frontend SHALL highlight overdue bills where due_date is less than today and status is unpaid
4. THE Frontend SHALL provide record payment button that opens dialog with fields: amount, payment_method, payment_date, reference_number
5. THE Frontend SHALL display total outstanding payables amount
6. THE Frontend SHALL show toast notification after successful supplier payment recording

### Requirement 31: Agency Portal - Communication Log

**User Story:** As an Agency staff member, I want to log customer communications, so that I can track interaction history and follow-ups.

#### Acceptance Criteria

1. WHEN Agency staff views customer detail, THE Frontend SHALL display communication log table with communication_type, subject, notes, follow_up_date, and follow_up_done status
2. THE Frontend SHALL provide add communication log button with fields: communication_type, subject, notes, follow_up_required, follow_up_date
3. THE Frontend SHALL support communication_type values: call, email, whatsapp, meeting, other
4. THE Frontend SHALL filter communication logs by follow_up_required and follow_up_done
5. THE Frontend SHALL provide mark as done button for follow-ups
6. THE Frontend SHALL show toast notification after successful communication log creation


### Requirement 32: Agency Portal - B2B Marketplace Service Publishing

**User Story:** As an Agency A staff member, I want to publish excess inventory to the marketplace, so that other agencies can purchase from me.

#### Acceptance Criteria

1. WHEN Agency A staff views marketplace services, THE Frontend SHALL display table with service_type, name, cost_price, reseller_price, markup_percentage, total_quota, available_quota, and is_published status
2. THE Frontend SHALL provide publish service form with fields: po_id, service_type, name, description, cost_price, reseller_price, total_quota
3. THE Frontend SHALL validate that reseller_price is greater than cost_price with minimum 5% markup
4. THE Frontend SHALL calculate markup_percentage as ((reseller_price - cost_price) / cost_price) × 100
5. THE Frontend SHALL allow publishing or unpublishing services using toggle button
6. THE Frontend SHALL show toast notification after successful service publishing

### Requirement 33: Agency Portal - B2B Marketplace Service Browsing

**User Story:** As an Agency B staff member, I want to browse marketplace services without seeing supplier names, so that I can purchase from other agencies.

#### Acceptance Criteria

1. WHEN Agency B staff views marketplace, THE Frontend SHALL display table with service_type, name, description, reseller_price, available_quota, and seller_agency_name
2. THE Frontend SHALL NOT display supplier information or original cost_price
3. THE Frontend SHALL filter marketplace services by service_type
4. THE Frontend SHALL provide add to cart button for each service
5. THE Frontend SHALL maintain shopping cart state for selected marketplace services
6. THE Frontend SHALL show toast notification when adding services to cart

### Requirement 34: Agency Portal - B2B Marketplace Order Creation

**User Story:** As an Agency B staff member, I want to create orders to other agencies, so that I can purchase marketplace services.

#### Acceptance Criteria

1. WHEN Agency B staff views cart, THE Frontend SHALL display selected services with quantity, unit_price, and total_price
2. THE Frontend SHALL provide create order button that submits all cart items
3. THE Frontend SHALL validate that order quantity is less than or equal to available_quota
4. THE Frontend SHALL calculate total_price as sum of all order items
5. THE Frontend SHALL clear cart after successful order creation
6. THE Frontend SHALL show toast notification after successful order creation

### Requirement 35: Agency Portal - B2B Marketplace Order Management

**User Story:** As an Agency A staff member, I want to approve or reject orders from other agencies, so that I can control my inventory sales.

#### Acceptance Criteria

1. WHEN Agency A staff views incoming orders, THE Frontend SHALL display table with order_number, buyer_agency_name, service_name, quantity, total_price, status, and actions
2. THE Frontend SHALL filter orders by status (pending, approved, rejected)
3. THE Frontend SHALL provide approve button for pending orders
4. THE Frontend SHALL provide reject button that opens dialog requiring rejection_reason
5. THE Frontend SHALL show confirmation dialog before approving or rejecting orders
6. THE Frontend SHALL show toast notification after successful order approval or rejection


### Requirement 36: Agency Portal - Profitability Tracking

**User Story:** As an Agency staff member, I want to track booking profitability, so that I can identify high and low margin bookings.

#### Acceptance Criteria

1. WHEN Agency staff views profitability dashboard, THE Frontend SHALL display total revenue, total cost, total profit, and average margin percentage
2. THE Frontend SHALL display chart showing profit trends over time
3. THE Frontend SHALL display table of top 10 most profitable bookings
4. THE Frontend SHALL display table of low margin bookings (margin less than 10%)
5. THE Frontend SHALL allow filtering profitability data by package_type and date range
6. THE Frontend SHALL display booking detail with revenue, cost, gross_profit, and gross_margin_percentage

### Requirement 37: Shared Components - Data Table

**User Story:** As a developer, I want reusable data table component, so that I can display tabular data consistently across the application.

#### Acceptance Criteria

1. THE Frontend SHALL provide DataTableComponent with inputs: columns, data, loading, paginator, sortable, filterable
2. THE Frontend SHALL support column configuration with field, header, sortable, filterable, and template properties
3. THE Frontend SHALL support pagination with rows per page options: 10, 25, 50, 100
4. THE Frontend SHALL support sorting by clicking column headers
5. THE Frontend SHALL support global search filtering across all columns
6. THE Frontend SHALL emit events: onRowSelect, onRowEdit, onRowDelete

### Requirement 38: Shared Components - Page Header

**User Story:** As a developer, I want reusable page header component, so that pages have consistent headers with breadcrumbs and actions.

#### Acceptance Criteria

1. THE Frontend SHALL provide PageHeaderComponent with inputs: title, breadcrumbs, actions
2. THE Frontend SHALL display breadcrumb navigation with home icon and clickable links
3. THE Frontend SHALL display action buttons on the right side of the header
4. THE Frontend SHALL support icon buttons using Lucide icons
5. THE Frontend SHALL be responsive and stack actions vertically on mobile

### Requirement 39: Shared Components - Confirmation Dialog

**User Story:** As a developer, I want reusable confirmation dialog component, so that I can request user confirmation before destructive actions.

#### Acceptance Criteria

1. THE Frontend SHALL provide ConfirmationDialogComponent with inputs: message, header, acceptLabel, rejectLabel
2. THE Frontend SHALL display dialog with message, accept button, and reject button
3. THE Frontend SHALL emit events: onAccept, onReject
4. THE Frontend SHALL close dialog after user clicks accept or reject
5. THE Frontend SHALL support danger variant with red accept button for destructive actions


### Requirement 40: Shared Components - Loading Spinner

**User Story:** As a developer, I want reusable loading spinner component, so that I can indicate loading states consistently.

#### Acceptance Criteria

1. THE Frontend SHALL provide LoadingSpinnerComponent with inputs: size, overlay
2. WHEN overlay is true, THE Frontend SHALL display full-screen overlay with centered spinner
3. WHEN overlay is false, THE Frontend SHALL display inline spinner
4. THE Frontend SHALL support size options: small, medium, large
5. THE Frontend SHALL use PrimeNG ProgressSpinner component

### Requirement 41: Form Validation and Error Display

**User Story:** As a developer, I want consistent form validation and error display, so that users receive clear feedback on input errors.

#### Acceptance Criteria

1. THE Frontend SHALL use Angular Reactive Forms for all forms
2. THE Frontend SHALL display validation errors below form fields in red text
3. THE Frontend SHALL validate required fields and display "This field is required" message
4. THE Frontend SHALL validate email format and display "Invalid email format" message
5. THE Frontend SHALL validate phone format and display "Invalid phone format" message
6. THE Frontend SHALL disable submit button when form is invalid
7. THE Frontend SHALL show toast notification with error message when form submission fails

### Requirement 42: Responsive Design and Mobile Support

**User Story:** As a user, I want the application to work on mobile devices, so that I can access it from anywhere.

#### Acceptance Criteria

1. THE Frontend SHALL use mobile-first responsive design approach
2. THE Frontend SHALL display navigation menu as hamburger icon on mobile devices
3. THE Frontend SHALL stack form fields vertically on mobile devices
4. THE Frontend SHALL make data tables horizontally scrollable on mobile devices
5. THE Frontend SHALL use responsive breakpoints: sm (640px), md (768px), lg (1024px), xl (1280px)

### Requirement 43: Toast Notifications

**User Story:** As a user, I want to receive feedback notifications for my actions, so that I know if operations succeeded or failed.

#### Acceptance Criteria

1. THE Frontend SHALL use PrimeNG Toast component for notifications
2. THE Frontend SHALL display success toast with green background for successful operations
3. THE Frontend SHALL display error toast with red background for failed operations
4. THE Frontend SHALL display warning toast with yellow background for warnings
5. THE Frontend SHALL display info toast with blue background for informational messages
6. THE Frontend SHALL auto-dismiss toasts after 5 seconds
7. THE Frontend SHALL allow manual dismissal by clicking close button

### Requirement 44: Error Handling and User Feedback

**User Story:** As a user, I want clear error messages when operations fail, so that I understand what went wrong.

#### Acceptance Criteria

1. WHEN HTTP request fails with 400 Bad Request, THE Frontend SHALL display validation errors from backend
2. WHEN HTTP request fails with 401 Unauthorized, THE Frontend SHALL redirect to login page
3. WHEN HTTP request fails with 403 Forbidden, THE Frontend SHALL display "You don't have permission to perform this action" message
4. WHEN HTTP request fails with 404 Not Found, THE Frontend SHALL display "Resource not found" message
5. WHEN HTTP request fails with 500 Internal Server Error, THE Frontend SHALL display "An unexpected error occurred. Please try again later" message
6. THE Frontend SHALL log all errors to console for debugging
