# Implementation Plan: Tour & Travel SaaS Frontend - Phase 1 MVP

## Overview

This implementation plan breaks down the Tour & Travel SaaS Frontend into discrete, incremental coding tasks. The plan follows a bottom-up approach, starting with core infrastructure, then shared components, and finally feature-specific implementations. Each task builds on previous tasks, ensuring no orphaned code.

## Tasks

- [ ] 1. Project Setup and Core Infrastructure
  - Initialize Angular 20 project with standalone components
  - Configure TailwindCSS 4, PrimeNG 20, and Lucide Angular
  - Set up folder structure (core, shared, features, store, layouts)
  - Configure environment files (development, production)
  - Set up routing configuration with lazy loading
  - _Requirements: 1.1, 1.2, 1.3, 7.1, 7.2, 7.3_

- [ ] 2. Core Services and Models
  - [ ] 2.1 Create core models (User, JwtPayload, ApiResponse)
    - Define TypeScript interfaces in core/models/
    - _Requirements: 2.1, 2.2_
  
  - [ ] 2.2 Implement AuthService
    - Create login(), logout(), getToken(), isAuthenticated() methods
    - Implement JWT token decoding
    - Store token in localStorage
    - _Requirements: 2.1, 2.2_
  
  - [ ] 2.3 Implement NotificationService
    - Create success(), error(), warning(), info() methods
    - Integrate with PrimeNG MessageService
    - _Requirements: 39.1, 39.2, 39.3, 39.4, 39.5_
  
  - [ ] 2.4 Implement LoadingService
    - Create show(), hide() methods
    - Manage loading state with BehaviorSubject
    - _Requirements: 3.3_

- [ ] 3. HTTP Interceptors
  - [ ] 3.1 Implement AuthInterceptor
    - Attach JWT token to Authorization header
    - _Requirements: 3.1_
  
  - [ ]* 3.2 Write property test for AuthInterceptor
    - **Property 3: Authorization Header Attachment**
    - **Validates: Requirements 3.1**
  
  - [ ] 3.3 Implement ErrorInterceptor
    - Handle 400, 401, 403, 404, 500 errors
    - Display toast notifications for errors
    - Redirect to login on 401
    - Log errors to console
    - _Requirements: 3.2, 3.4, 3.5, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6_
  
  - [ ]* 3.4 Write property test for ErrorInterceptor
    - **Property 4: HTTP Error Toast Notifications**
    - **Property 17: Error Logging**
    - **Validates: Requirements 3.2, 40.6_
  
  - [ ] 3.5 Implement LoadingInterceptor
    - Track HTTP requests for loading state
    - _Requirements: 3.3_
  
  - [ ]* 3.6 Write property test for LoadingInterceptor
    - **Property 5: Loading State Management**
    - **Validates: Requirements 3.3**

- [ ] 4. Route Guards
  - [ ] 4.1 Implement AuthGuard
    - Check authentication status
    - Redirect to login if not authenticated
    - _Requirements: 2.3_
  
  - [ ]* 4.2 Write unit tests for AuthGuard
    - Test authenticated and unauthenticated scenarios
    - _Requirements: 2.3_
  
  - [ ] 4.3 Implement RoleGuard
    - Check user_type against allowed roles
    - Display permission error if unauthorized
    - _Requirements: 2.4_
  
  - [ ]* 4.4 Write property test for RoleGuard
    - **Property 2: Role-Based Route Access**
    - **Validates: Requirements 2.4**

- [ ] 5. Shared Components
  - [ ] 5.1 Create DataTableComponent
    - Implement with PrimeNG Table
    - Support columns, data, loading, pagination, sorting, filtering
    - Use styleClass="p-datatable-sm"
    - Emit onRowSelect, onRowEdit, onRowDelete events
    - _Requirements: 5.3, 33.1, 33.2, 33.3, 33.4, 33.5, 33.6_
  
  - [ ] 5.2 Create PageHeaderComponent
    - Display title, breadcrumbs, and action buttons
    - Use responsive layout
    - _Requirements: 34.1, 34.2, 34.3, 34.4, 34.5_
  
  - [ ] 5.3 Create ConfirmationDialogComponent
    - Implement with PrimeNG Dialog
    - Support message, header, accept/reject labels, severity
    - Emit onAccept and onReject events
    - _Requirements: 35.1, 35.2, 35.3, 35.4, 35.5_
  
  - [ ] 5.4 Create LoadingSpinnerComponent
    - Implement with PrimeNG ProgressSpinner
    - Support overlay and inline modes
    - _Requirements: 36.1, 36.2, 36.3, 36.4, 36.5_

- [ ] 6. Checkpoint - Core Infrastructure Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 7. Authentication Feature
  - [ ] 7.1 Create auth models and routes
    - Define LoginCredentials, AuthResponse interfaces
    - Configure auth.routes.ts with lazy loading
    - _Requirements: 2.1_
  
  - [ ] 7.2 Create LoginComponent
    - Separate login.component.ts, .html, .scss files
    - Implement reactive form with email and password fields
    - Use class="p-inputtext-sm" for inputs
    - Use size="small" for p-password and p-button
    - Display validation errors below fields
    - Dispatch login action on submit
    - _Requirements: 4.1, 4.2, 4.3, 5.1, 5.2, 5.4, 37.1, 37.2, 37.3, 37.4_
  
  - [ ]* 7.3 Write property tests for form validation
    - **Property 10: Required Field Validation**
    - **Property 11: Email Format Validation**
    - **Property 9: Form Validation Error Display**
    - **Validates: Requirements 37.2, 37.3, 37.4, 37.6**
  
  - [ ] 7.4 Create auth NgRx store
    - Define auth.actions.ts (login, loginSuccess, loginFailure, logout)
    - Define auth.reducer.ts (manage auth state)
    - Define auth.effects.ts (handle login API call)
    - Define auth.selectors.ts (select user, token, loading)
    - Define auth.state.ts (AuthState interface)
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ]* 7.5 Write unit tests for auth store
    - Test actions, reducer, effects, selectors
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 8. Layout Components
  - [ ] 8.1 Create MainLayoutComponent
    - Implement with header, sidebar, and content area
    - Use responsive design
    - Include p-toast for global notifications
    - _Requirements: 38.1, 38.2, 39.1_
  
  - [ ] 8.2 Create HeaderComponent
    - Display search bar, notifications, user menu
    - Use PrimeNG components with size="small"
    - _Requirements: 5.1, 5.2, 5.4_
  
  - [ ] 8.3 Create SidebarComponent
    - Display navigation menu
    - Support collapsible menu
    - Highlight active route
    - Show hamburger icon on mobile
    - _Requirements: 38.2_
  
  - [ ] 8.4 Create AuthLayoutComponent
    - Simple layout for login page
    - _Requirements: 4.1_

- [ ] 9. Platform Admin Portal - Agency Management
  - [ ] 9.1 Create platform-admin models
    - Define Agency, CreateAgencyRequest interfaces
    - _Requirements: 8.1_
  
  - [ ] 9.2 Create AgencyApiService
    - Implement getAll(), getById(), create(), update(), toggleStatus() methods
    - _Requirements: 8.1_
  
  - [ ] 9.3 Create platform-admin NgRx store
    - Define agency actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 9.4 Create AgencyListComponent
    - Display agencies in DataTableComponent
    - Show agency_code, company_name, email, subscription_plan, is_active
    - Use styleClass="p-datatable-sm"
    - Implement toggle status with confirmation dialog
    - _Requirements: 8.1, 8.3, 8.4, 5.3_
  
  - [ ]* 9.5 Write property test for agency operations
    - **Property 6: Successful Operation Feedback**
    - **Validates: Requirements 8.5**
  
  - [ ] 9.6 Create AgencyFormComponent
    - Implement reactive form with company_name, email, phone, address, city, province, postal_code
    - Use class="p-inputtext-sm" for all inputs
    - Use size="small" for all form components
    - Validate required fields and email format
    - _Requirements: 8.2, 5.1, 5.2, 37.1, 37.2, 37.3, 37.4_
  
  - [ ]* 9.7 Write unit tests for AgencyFormComponent
    - Test form validation and submission
    - _Requirements: 8.2, 37.1, 37.2, 37.3, 37.4_

- [ ] 10. Platform Admin Portal - Supplier Approval
  - [ ] 10.1 Create supplier models
    - Define Supplier, SupplierStatus interfaces
    - _Requirements: 9.1_
  
  - [ ] 10.2 Create SupplierApiService
    - Implement getAll(), getById(), approve(), reject() methods
    - _Requirements: 9.1_
  
  - [ ] 10.3 Create supplier NgRx store
    - Define supplier actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 10.4 Create SupplierListComponent
    - Display suppliers in DataTableComponent
    - Filter by status (pending, active, rejected, suspended)
    - Show approve/reject buttons for pending suppliers
    - Use confirmation dialog for approve/reject actions
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [ ]* 10.5 Write unit tests for SupplierListComponent
    - Test filtering and approve/reject actions
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 11. Platform Admin Portal - Dashboard
  - [ ] 11.1 Create DashboardComponent
    - Display total active agencies count
    - Display total active suppliers count
    - Display pending supplier approvals count
    - Display agency registrations chart
    - Display recent agency registrations list
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_
  
  - [ ]* 11.2 Write unit tests for DashboardComponent
    - Test metric display and chart rendering
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [ ] 12. Platform Admin Portal - Subscription Plan Management
  - [ ] 12.1 Create subscription plan models
    - Define SubscriptionPlan, PlanName, AgencySubscription, SubscriptionStatus interfaces
    - _Requirements: 10.1_
  
  - [ ] 12.2 Create SubscriptionPlanApiService
    - Implement getAll(), getById(), create(), update(), toggleStatus() methods
    - _Requirements: 10.1_
  
  - [ ] 12.3 Create subscription plan NgRx store
    - Define subscription plan actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 12.4 Create SubscriptionPlanListComponent
    - Display subscription plans in DataTableComponent
    - Show plan_name, monthly_price, annual_price, max_users, max_bookings_per_month, features, is_active
    - Use styleClass="p-datatable-sm"
    - Implement toggle status with confirmation dialog
    - _Requirements: 10.1, 10.4, 5.3_
  
  - [ ] 12.5 Create SubscriptionPlanFormComponent
    - Implement reactive form with plan_name, description, monthly_price, annual_price, max_users, max_bookings_per_month, features
    - Use p-dropdown with size="small" for plan_name
    - Use p-multiselect with size="small" for features
    - Validate required fields and positive prices
    - _Requirements: 10.2, 10.3, 5.1, 5.2_
  
  - [ ]* 12.6 Write unit tests for SubscriptionPlanFormComponent
    - Test form validation and submission
    - _Requirements: 10.2, 10.3_

- [ ] 13. Platform Admin Portal - Commission Configuration
  - [ ] 21.1 Create commission models
    - Define CommissionConfig, CommissionHistory interfaces
    - _Requirements: 11.1_
  
  - [ ] 21.2 Create CommissionApiService
    - Implement getCurrent(), getHistory(), update() methods
    - _Requirements: 11.1_
  
  - [ ] 21.3 Create commission NgRx store
    - Define commission actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 21.4 Create CommissionConfigComponent
    - Display current commission_type and commission_rate
    - Display commission history table
    - Provide edit commission button
    - _Requirements: 11.1, 11.5_
  
  - [ ] 21.5 Create CommissionConfigFormComponent
    - Implement reactive form with commission_type, commission_rate, effective_date
    - Use p-dropdown with size="small" for commission_type
    - Validate percentage rate (0-100) when type is percentage
    - Validate positive rate when type is fixed
    - Show confirmation dialog before updating
    - _Requirements: 11.2, 11.3, 11.4, 11.6, 5.1, 5.2_
  
  - [ ]* 21.6 Write property tests for commission validation
    - **Property 8: Positive Price Validation** (applied to commission_rate)
    - Test percentage range validation (0-100)
    - **Validates: Requirements 11.3, 11.4**

- [ ] 14. Platform Admin Portal - Agency Subscription Assignment
  - [ ] 38.1 Create AgencySubscriptionComponent (in AgencyDetail)
    - Display current subscription plan, dates, and status
    - Show subscription status badge with colors
    - Provide assign subscription button
    - Provide upgrade/downgrade plan button
    - _Requirements: 12.1, 12.4_
  
  - [ ] 38.2 Create AssignSubscriptionDialogComponent
    - Implement form with plan_id, billing_cycle, subscription_start_date
    - Use p-dropdown with size="small" for plan_id and billing_cycle
    - Use p-calendar with size="small" for subscription_start_date
    - Calculate subscription_end_date based on billing_cycle
    - Show confirmation dialog before assigning
    - _Requirements: 12.2, 12.3, 12.6, 5.1, 5.2_
  
  - [ ]* 38.3 Write unit tests for subscription assignment
    - Test end_date calculation (30 days for monthly, 365 for annual)
    - Test confirmation dialog display
    - _Requirements: 12.3, 12.6_

- [ ] 15. Platform Admin Portal - Revenue Dashboard
  - [ ] 27.1 Create revenue models
    - Define RevenueMetrics, RevenueByPlan, AgencyRevenue, CommissionRevenueTrend interfaces
    - _Requirements: 13.1_
  
  - [ ] 27.2 Create RevenueApiService
    - Implement getMetrics(), getByPlan(), getTopAgencies(), getCommissionTrend() methods
    - _Requirements: 13.1_
  
  - [ ] 27.3 Create revenue NgRx store
    - Define revenue actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 27.4 Create RevenueDashboardComponent
    - Display total subscription revenue, commission revenue, total revenue
    - Display revenue breakdown chart by subscription plan
    - Display commission revenue trend chart (last 12 months)
    - Display top 10 revenue-generating agencies table
    - Provide date range filter
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7_
  
  - [ ]* 27.5 Write unit tests for RevenueDashboardComponent
    - Test metric display and chart rendering
    - Test date range filtering
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7_

- [ ] 16. Checkpoint - Platform Admin Portal Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 17. Supplier Portal - Service Catalog Management
  - [ ] 21.1 Create supplier service models
    - Define SupplierService, ServiceType, SeasonalPrice interfaces
    - _Requirements: 11.1_
  
  - [ ] 21.2 Create ServiceApiService
    - Implement getAll(), getById(), create(), update(), publish() methods
    - _Requirements: 11.1_
  
  - [ ] 21.3 Create service NgRx store
    - Define service actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 21.4 Create ServiceListComponent
    - Display services in DataTableComponent
    - Show service_code, service_type, name, base_price, status
    - Implement publish button
    - _Requirements: 11.1, 11.6_
  
  - [ ] 21.5 Create ServiceFormComponent
    - Implement reactive form with service_type, name, description, base_price, currency, location_city, location_country
    - Show conditional fields based on service_type (hotel, flight, visa)
    - Use class="p-inputtext-sm" for inputs
    - Use size="small" for dropdowns and buttons
    - _Requirements: 11.2, 11.3, 11.4, 11.5, 5.1, 5.2_
  
  - [ ]* 21.6 Write property test for service operations
    - **Property 6: Successful Operation Feedback**
    - **Validates: Requirements 11.7**
  
  - [ ]* 21.7 Write unit tests for ServiceFormComponent
    - Test conditional field display based on service_type
    - _Requirements: 11.3, 11.4, 11.5_

- [ ] 18. Supplier Portal - Seasonal Pricing
  - [ ] 38.1 Create SeasonalPriceComponent
    - Display seasonal prices list for a service
    - Show season_name, start_date, end_date, seasonal_price
    - _Requirements: 12.1_
  
  - [ ] 38.2 Create SeasonalPriceFormComponent
    - Implement reactive form with season_name, start_date, end_date, seasonal_price
    - Use p-calendar with size="small"
    - Validate date range (end_date >= start_date)
    - Validate price > 0
    - _Requirements: 12.2, 12.3, 12.4, 5.1, 5.2_
  
  - [ ]* 38.3 Write property tests for seasonal price validation
    - **Property 7: Date Range Validation**
    - **Property 8: Positive Price Validation**
    - **Validates: Requirements 12.3, 12.4**

- [ ] 19. Supplier Portal - Purchase Order Management
  - [ ] 27.1 Create purchase order models
    - Define PurchaseOrder, POItem, POStatus interfaces
    - _Requirements: 13.1_
  
  - [ ] 27.2 Create PurchaseOrderApiService
    - Implement getAll(), getById(), approve(), reject() methods
    - _Requirements: 13.1_
  
  - [ ] 27.3 Create purchase order NgRx store
    - Define PO actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 27.4 Create PurchaseOrderListComponent
    - Display POs in DataTableComponent
    - Filter by status (pending, approved, rejected)
    - Show po_number, agency_name, total_amount, status, created_at
    - _Requirements: 13.1, 13.2_
  
  - [ ] 27.5 Create PurchaseOrderDetailComponent
    - Display PO header information
    - Display PO items in DataTableComponent
    - Show approve/reject buttons for pending POs
    - Use confirmation dialog for approve/reject
    - _Requirements: 13.3, 13.4, 13.5, 13.6_
  
  - [ ]* 27.6 Write unit tests for PurchaseOrderDetailComponent
    - Test approve/reject actions with confirmation
    - _Requirements: 13.4, 13.5, 13.6, 13.7_

- [ ] 20. Checkpoint - Supplier Portal Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 21. Agency Portal - Procurement (Supplier Browsing & PO Creation)
  - [ ] 21.1 Create SupplierBrowsingComponent
    - Display suppliers in DataTableComponent
    - Show supplier_code, company_name, business_type
    - Provide "View Services" button
    - _Requirements: 14.1_
  
  - [ ] 21.2 Create SupplierServicesComponent
    - Display supplier services in DataTableComponent
    - Show service_code, service_type, name, base_price
    - Provide "Add to Cart" button
    - Maintain cart state in NgRx store
    - _Requirements: 14.2, 14.3_
  
  - [ ] 21.3 Create PurchaseOrderFormComponent
    - Display cart items
    - Calculate total_amount
    - Submit PO with all cart items
    - Clear cart after successful submission
    - _Requirements: 14.4, 14.5_
  
  - [ ]* 21.4 Write unit tests for cart functionality
    - Test add to cart, remove from cart, calculate total
    - _Requirements: 14.3, 14.5_

- [ ] 22. Agency Portal - Package Management
  - [ ] 38.1 Create package models
    - Define Package, PackageService, PackageType interfaces
    - _Requirements: 15.1_
  
  - [ ] 38.2 Create PackageApiService
    - Implement getAll(), getById(), create(), update(), publish() methods
    - _Requirements: 15.1_
  
  - [ ] 38.3 Create package NgRx store
    - Define package actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 38.4 Create PackageListComponent
    - Display packages in DataTableComponent
    - Show package_code, package_type, name, duration_days, selling_price, status
    - _Requirements: 15.1_
  
  - [ ] 38.5 Create PackageFormComponent
    - Implement reactive form with package_type, name, description, duration_days, base_cost, markup_type, markup_value, selling_price
    - Use p-dropdown with size="small" for package_type
    - Validate selling_price >= base_cost
    - Allow adding services from approved POs
    - Calculate base_cost as sum of service costs
    - _Requirements: 15.2, 15.3, 15.4, 15.5, 15.6, 5.1, 5.2_
  
  - [ ]* 38.6 Write property test for package pricing validation
    - **Property 8: Positive Price Validation** (applied to selling_price)
    - Test selling_price >= base_cost validation
    - **Validates: Requirements 15.4**

- [ ] 23. Agency Portal - Journey Management
  - [ ] 27.1 Create journey models
    - Define Journey, JourneyStatus interfaces
    - _Requirements: 16.1_
  
  - [ ] 27.2 Create JourneyApiService
    - Implement getAll(), getById(), create(), update() methods
    - _Requirements: 16.1_
  
  - [ ] 27.3 Create journey NgRx store
    - Define journey actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 27.4 Create JourneyListComponent
    - Display journeys in DataTableComponent
    - Show journey_code, package_name, departure_date, return_date, total_quota, confirmed_pax, available_quota, status
    - _Requirements: 16.1_
  
  - [ ] 27.5 Create JourneyFormComponent
    - Implement reactive form with package_id, departure_date, return_date, total_quota
    - Use p-calendar with size="small" for dates
    - Validate return_date > departure_date
    - Display quota information (total_quota, confirmed_pax, available_quota)
    - _Requirements: 16.2, 16.3, 16.4, 5.1, 5.2_
  
  - [ ]* 27.6 Write property test for journey date validation
    - **Property 7: Date Range Validation** (applied to departure/return dates)
    - **Validates: Requirements 16.3**

- [ ] 24. Agency Portal - Customer Management
  - [ ] 48.1 Create customer models
    - Define Customer interface
    - _Requirements: 17.1_
  
  - [ ] 48.2 Create CustomerApiService
    - Implement getAll(), getById(), create(), update() methods
    - _Requirements: 17.1_
  
  - [ ] 48.3 Create customer NgRx store
    - Define customer actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 48.4 Create CustomerListComponent
    - Display customers in DataTableComponent
    - Show customer_code, name, email, phone, total_bookings, total_spent, last_booking_date
    - _Requirements: 17.1_
  
  - [ ] 48.5 Create CustomerFormComponent
    - Implement reactive form with name, email, phone, address, city, province, postal_code, country
    - Validate phone uniqueness
    - Validate email uniqueness if provided
    - Use class="p-inputtext-sm" for all inputs
    - _Requirements: 17.2, 17.3, 17.4, 5.1, 5.2_
  
  - [ ]* 48.6 Write property tests for customer form validation
    - **Property 10: Required Field Validation** (name, phone)
    - **Property 11: Email Format Validation**
    - **Property 12: Phone Format Validation**
    - **Validates: Requirements 17.2, 17.3, 17.4**

- [ ] 25. Checkpoint - Agency Portal Core Features Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 26. Agency Portal - Booking Management
  - [ ] 38.1 Create booking models
    - Define Booking, BookingStatus, BookingSource, Traveler interfaces
    - _Requirements: 18.1, 20.1_
  
  - [ ] 38.2 Create BookingApiService
    - Implement getAll(), getById(), create(), approve(), cancel() methods
    - _Requirements: 18.1, 19.1_
  
  - [ ] 38.3 Create booking NgRx store
    - Define booking actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 38.4 Create BookingListComponent
    - Display bookings in DataTableComponent
    - Show booking_reference, customer_name, package_name, journey_code, total_pax, total_amount, booking_status, created_at
    - _Requirements: 18.1_
  
  - [ ] 38.5 Create BookingFormComponent
    - Implement reactive form with package_id, journey_id, customer_id, total_pax, booking_source
    - Use p-dropdown with size="small" for dropdowns
    - Calculate total_amount as package selling_price × total_pax
    - Validate journey available_quota >= total_pax
    - _Requirements: 18.2, 18.3, 18.4, 18.5, 5.1, 5.2_
  
  - [ ]* 38.6 Write unit tests for BookingFormComponent
    - Test total_amount calculation
    - Test quota validation
    - _Requirements: 18.4, 18.5_

- [ ] 27. Agency Portal - Booking Detail and Approval
  - [ ] 27.1 Create BookingDetailComponent
    - Display booking information card
    - Display document progress card with progress bar
    - Display task progress card with progress bar
    - Use p-tabView for travelers, documents, tasks, payments tabs
    - _Requirements: 19.1, 19.2_
  
  - [ ] 27.2 Implement booking approval functionality
    - Add approve button with confirmation dialog
    - Add cancel button with cancellation_reason dialog
    - Update journey quota after approval/cancellation
    - _Requirements: 19.2, 19.3, 19.4, 19.5_
  
  - [ ]* 27.3 Write unit tests for booking approval
    - Test approval with confirmation
    - Test cancellation with reason
    - _Requirements: 19.2, 19.3, 19.4, 19.5_

- [ ] 28. Agency Portal - Traveler Management
  - [ ] 48.1 Create TravelerFormComponent
    - Implement reactive form with full_name, gender, date_of_birth, nationality, passport_number, passport_expiry
    - Use p-calendar with size="small" for dates
    - Conditionally show mahram_traveler_number for female travelers in Umrah/Hajj packages
    - Validate mahram references existing male traveler
    - _Requirements: 20.2, 20.3, 20.4, 5.1, 5.2_
  
  - [ ]* 48.2 Write unit tests for mahram validation
    - Test mahram requirement for female travelers > 12 years in Umrah/Hajj
    - Test mahram reference validation
    - _Requirements: 20.3, 20.4_

- [ ] 29. Agency Portal - Document Management
  - [ ] 45.1 Create document models
    - Define BookingDocument, DocumentStatus interfaces
    - _Requirements: 21.1_
  
  - [ ] 45.2 Create DocumentApiService
    - Implement getByBookingId(), updateStatus() methods
    - _Requirements: 21.1_
  
  - [ ] 45.3 Create document NgRx store
    - Define document actions, reducer, effects, selectors, state
    - Include selector for document completion percentage
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 21.2_
  
  - [ ] 45.4 Create DocumentListComponent (in BookingDetail tab)
    - Display documents in DataTableComponent
    - Show document_type, traveler_name, status, document_number, expiry_date
    - Highlight expiring documents (expiry < 30 days)
    - Provide "Update Status" button
    - _Requirements: 21.1, 21.6_
  
  - [ ] 45.5 Create DocumentStatusDialogComponent
    - Show form with status dropdown, document_number, issue_date, expiry_date
    - Require rejection_reason when status is rejected
    - _Requirements: 21.4, 21.5_
  
  - [ ]* 45.6 Write unit tests for document management
    - Test completion percentage calculation
    - Test expiring document highlighting
    - _Requirements: 21.2, 21.6_

- [ ] 30. Agency Portal - Task Management with Kanban Board
  - [ ] 38.1 Create task models
    - Define BookingTask, TaskStatus, TaskPriority interfaces
    - _Requirements: 22.1_
  
  - [ ] 38.2 Create TaskApiService
    - Implement getByBookingId(), updateStatus(), assign(), create() methods
    - _Requirements: 22.1_
  
  - [ ] 38.3 Create task NgRx store
    - Define task actions, reducer, effects, selectors, state
    - Include selector for task completion percentage
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 22.1_
  
  - [ ] 38.4 Create TaskKanbanComponent (in BookingDetail tab)
    - Display three columns: to_do, in_progress, done
    - Implement drag-and-drop between columns
    - Highlight overdue tasks (due_date < today and status != done)
    - Show task cards with title, description, due_date, priority
    - _Requirements: 22.1, 22.2, 22.3, 22.4_
  
  - [ ] 38.5 Create TaskFormComponent
    - Implement form for custom tasks with title, description, priority, due_date
    - Use p-dropdown with size="small" for priority
    - Use p-calendar with size="small" for due_date
    - _Requirements: 22.6, 5.1, 5.2_
  
  - [ ]* 38.6 Write unit tests for task management
    - Test completion percentage calculation
    - Test overdue task identification
    - Test drag-and-drop status update
    - _Requirements: 22.1, 22.3, 22.4_

- [ ] 31. Checkpoint - Agency Portal Booking Features Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 32. Agency Portal - Notification Configuration
  - [ ] 48.1 Create notification models
    - Define NotificationSchedule, NotificationTemplate interfaces
    - _Requirements: 23.1, 24.1_
  
  - [ ] 48.2 Create NotificationApiService
    - Implement schedule and template CRUD methods
    - _Requirements: 23.1, 24.1_
  
  - [ ] 48.3 Create notification NgRx store
    - Define notification actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 48.4 Create NotificationScheduleListComponent
    - Display schedules in DataTableComponent
    - Show name, trigger_days_before, notification_type, template_name, is_enabled
    - Provide toggle for enabling/disabling schedules
    - _Requirements: 23.1, 23.4_
  
  - [ ] 48.5 Create NotificationScheduleFormComponent
    - Implement form with name, trigger_days_before, notification_type, template_id
    - Use p-dropdown with size="small" for dropdowns
    - Support trigger_days_before values: 30, 14, 7, 3, 1
    - _Requirements: 23.2, 23.3, 5.1, 5.2_
  
  - [ ] 48.6 Create NotificationTemplateListComponent
    - Display templates in DataTableComponent
    - Show name, subject
    - _Requirements: 24.1_
  
  - [ ] 48.7 Create NotificationTemplateFormComponent
    - Implement form with name, subject, body
    - Display available variables: customer_name, package_name, departure_date, return_date, booking_reference
    - Provide variable insertion buttons
    - Show template preview with sample data
    - _Requirements: 24.2, 24.3, 24.4, 24.5_
  
  - [ ]* 48.8 Write unit tests for notification components
    - Test schedule enable/disable
    - Test template variable insertion
    - _Requirements: 23.4, 24.4_

- [ ] 33. Agency Portal - Payment Tracking
  - [ ] 45.1 Create payment models
    - Define PaymentSchedule, PaymentTransaction, PaymentStatus, PaymentMethod interfaces
    - _Requirements: 25.1_
  
  - [ ] 45.2 Create PaymentApiService
    - Implement getByBookingId(), recordPayment() methods
    - _Requirements: 25.1_
  
  - [ ] 45.3 Create payment NgRx store
    - Define payment actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 45.4 Create PaymentScheduleComponent (in BookingDetail tab)
    - Display payment schedules in DataTableComponent
    - Show installment_name, due_date, amount, paid_amount, status
    - Highlight overdue payments (due_date < today and status = pending)
    - Display total outstanding amount
    - Provide "Record Payment" button
    - _Requirements: 25.1, 25.2, 25.5_
  
  - [ ] 45.5 Create PaymentRecordDialogComponent
    - Implement form with amount, payment_method, payment_date, reference_number
    - Use p-dropdown with size="small" for payment_method
    - Use p-calendar with size="small" for payment_date
    - Update payment schedule status after recording
    - _Requirements: 25.3, 25.4, 5.1, 5.2_
  
  - [ ]* 45.6 Write unit tests for payment tracking
    - Test overdue payment identification
    - Test outstanding amount calculation
    - Test payment status update logic
    - _Requirements: 25.2, 25.4, 25.5_

- [ ] 34. Agency Portal - Itinerary Builder
  - [ ] 38.1 Create itinerary models
    - Define Itinerary, ItineraryDay, ItineraryActivity, MealType interfaces
    - _Requirements: 26.1_
  
  - [ ] 38.2 Create ItineraryApiService
    - Implement getByPackageId(), addDay(), addActivity(), update() methods
    - _Requirements: 26.1_
  
  - [ ] 38.3 Create itinerary NgRx store
    - Define itinerary actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 38.4 Create ItineraryBuilderComponent (in PackageDetail tab)
    - Display day-by-day breakdown
    - Provide "Add Day" button
    - For each day, show title, description, and activities list
    - Provide "Add Activity" button for each day
    - Support drag-and-drop for reordering days and activities
    - _Requirements: 26.1, 26.2, 26.5_
  
  - [ ] 38.5 Create ItineraryDayFormComponent
    - Implement form with day_number, title, description
    - Use class="p-inputtext-sm" for inputs
    - Use textarea with class="p-inputtext-sm" for description
    - _Requirements: 26.2, 5.1_
  
  - [ ] 38.6 Create ItineraryActivityFormComponent
    - Implement form with time, location, activity, description, meal_type
    - Use p-dropdown with size="small" for meal_type
    - Support meal_type values: breakfast, lunch, dinner, snack, none
    - _Requirements: 26.3, 26.4, 5.1, 5.2_
  
  - [ ]* 38.7 Write unit tests for itinerary builder
    - Test day and activity creation
    - Test drag-and-drop reordering
    - _Requirements: 26.2, 26.3, 26.5_

- [ ] 35. Agency Portal - Supplier Bills and Payables
  - [ ] 47.1 Create supplier bill models
    - Define SupplierBill, SupplierPayment interfaces
    - _Requirements: 27.1_
  
  - [ ] 47.2 Create SupplierBillApiService
    - Implement getAll(), getById(), recordPayment() methods
    - _Requirements: 27.1_
  
  - [ ] 47.3 Create supplier bill NgRx store
    - Define supplier bill actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 47.4 Create SupplierBillListComponent
    - Display bills in DataTableComponent
    - Show bill_number, supplier_name, bill_date, due_date, total_amount, paid_amount, status
    - Filter by status (unpaid, partially_paid, paid)
    - Highlight overdue bills (due_date < today and status = unpaid)
    - Display total outstanding payables
    - Provide "Record Payment" button
    - _Requirements: 27.1, 27.2, 27.3, 27.5_
  
  - [ ] 47.5 Create SupplierPaymentDialogComponent
    - Implement form with amount, payment_method, payment_date, reference_number
    - Use p-dropdown with size="small" for payment_method
    - Use p-calendar with size="small" for payment_date
    - _Requirements: 27.4, 5.1, 5.2_
  
  - [ ]* 47.6 Write unit tests for supplier bill management
    - Test overdue bill identification
    - Test outstanding payables calculation
    - _Requirements: 27.3, 27.5_

- [ ] 36. Agency Portal - Communication Log
  - [ ] 48.1 Create communication log models
    - Define CommunicationLog interface
    - _Requirements: 28.1_
  
  - [ ] 48.2 Create CommunicationLogApiService
    - Implement getByCustomerId(), create(), markFollowUpDone() methods
    - _Requirements: 28.1_
  
  - [ ] 48.3 Create communication log NgRx store
    - Define communication log actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 48.4 Create CommunicationLogComponent (in CustomerDetail)
    - Display logs in DataTableComponent
    - Show communication_type, subject, notes, follow_up_date, follow_up_done
    - Filter by follow_up_required and follow_up_done
    - Provide "Mark as Done" button for follow-ups
    - _Requirements: 28.1, 28.4, 28.5_
  
  - [ ] 48.5 Create CommunicationLogFormComponent
    - Implement form with communication_type, subject, notes, follow_up_required, follow_up_date
    - Use p-dropdown with size="small" for communication_type
    - Use p-calendar with size="small" for follow_up_date
    - Support communication_type values: call, email, whatsapp, meeting, other
    - _Requirements: 28.2, 28.3, 5.1, 5.2_
  
  - [ ]* 48.6 Write unit tests for communication log
    - Test filtering by follow-up status
    - Test mark as done functionality
    - _Requirements: 28.4, 28.5_

- [ ] 33. Checkpoint - Agency Portal Extended Features Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 34. Agency Portal - B2B Marketplace Service Publishing
  - [ ] 38.1 Create marketplace models
    - Define AgencyService, AgencyOrder, AgencyOrderStatus interfaces
    - _Requirements: 29.1, 31.1_
  
  - [ ] 38.2 Create MarketplaceApiService
    - Implement publishService(), unpublishService(), getMarketplaceServices(), createOrder(), approveOrder(), rejectOrder() methods
    - _Requirements: 29.1, 30.1, 31.1_
  
  - [ ] 38.3 Create marketplace NgRx store
    - Define marketplace actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 38.4 Create AgencyServiceListComponent
    - Display agency services in DataTableComponent
    - Show service_type, name, cost_price, reseller_price, markup_percentage, total_quota, available_quota, is_published
    - Provide toggle for publishing/unpublishing
    - _Requirements: 29.1, 29.5_
  
  - [ ] 38.5 Create AgencyServiceFormComponent
    - Implement form with po_id, service_type, name, description, cost_price, reseller_price, total_quota
    - Validate reseller_price > cost_price with minimum 5% markup
    - Calculate markup_percentage automatically
    - Use class="p-inputtext-sm" for inputs
    - Use p-dropdown with size="small" for dropdowns
    - _Requirements: 29.2, 29.3, 29.4, 5.1, 5.2_
  
  - [ ]* 38.6 Write property test for marketplace pricing validation
    - **Property 8: Positive Price Validation** (applied to reseller_price)
    - Test reseller_price > cost_price with 5% minimum markup
    - **Validates: Requirements 29.3**

- [ ] 35. Agency Portal - B2B Marketplace Service Browsing
  - [ ] 47.1 Create MarketplaceBrowseComponent
    - Display marketplace services in DataTableComponent
    - Show service_type, name, description, reseller_price, available_quota, seller_agency_name
    - Do NOT display supplier information or cost_price
    - Filter by service_type
    - Provide "Add to Cart" button
    - Maintain cart state in NgRx store
    - _Requirements: 30.1, 30.2, 30.3, 30.4_
  
  - [ ] 47.2 Create MarketplaceCartComponent
    - Display cart items with quantity, unit_price, total_price
    - Calculate total order amount
    - Validate quantity <= available_quota
    - Provide "Create Order" button
    - Clear cart after successful order creation
    - _Requirements: 31.2, 31.3, 31.4, 31.5_
  
  - [ ]* 47.3 Write unit tests for marketplace cart
    - Test add to cart, remove from cart
    - Test quantity validation against available_quota
    - Test total calculation
    - _Requirements: 31.3, 31.4_

- [ ] 40. Agency Portal - B2B Marketplace Order Management
  - [ ] 48.1 Create IncomingOrderListComponent (for Agency A - seller)
    - Display incoming orders in DataTableComponent
    - Show order_number, buyer_agency_name, service_name, quantity, total_price, status
    - Filter by status (pending, approved, rejected)
    - Provide approve/reject buttons for pending orders
    - Use confirmation dialog for approve/reject
    - _Requirements: 32.1, 32.2, 32.5_
  
  - [ ] 48.2 Create OutgoingOrderListComponent (for Agency B - buyer)
    - Display outgoing orders in DataTableComponent
    - Show order_number, seller_agency_name, service_name, quantity, total_price, status
    - Filter by status
    - _Requirements: 31.1_
  
  - [ ]* 48.3 Write unit tests for order management
    - Test approve/reject with confirmation
    - Test order filtering by status
    - _Requirements: 32.2, 32.5_

- [ ] 41. Agency Portal - Profitability Tracking
  - [ ] 45.1 Create profitability models
    - Define BookingProfitability interface
    - _Requirements: 33.1_
  
  - [ ] 45.2 Create ProfitabilityApiService
    - Implement getDashboard(), getBookingProfitability() methods
    - _Requirements: 33.1_
  
  - [ ] 45.3 Create profitability NgRx store
    - Define profitability actions, reducer, effects, selectors, state
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 45.4 Create ProfitabilityDashboardComponent
    - Display total revenue, total cost, total profit, average margin percentage
    - Display profit trends chart
    - Display top 10 most profitable bookings table
    - Display low margin bookings table (margin < 10%)
    - Provide filters for package_type and date range
    - _Requirements: 33.1, 33.2, 33.3, 33.4, 33.5_
  
  - [ ] 45.5 Create BookingProfitabilityDetailComponent
    - Display booking revenue, cost, gross_profit, gross_margin_percentage
    - Show breakdown of costs (services from POs and agency orders)
    - _Requirements: 33.6_
  
  - [ ]* 45.6 Write unit tests for profitability calculations
    - Test revenue, cost, profit, margin calculations
    - Test low margin identification (< 10%)
    - _Requirements: 33.1, 33.4_

- [ ] 38. Checkpoint - Agency Portal B2B and Profitability Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 43. Responsive Design and Mobile Optimization
  - [ ] 47.1 Implement responsive navigation
    - Display hamburger menu icon on mobile devices
    - Implement collapsible sidebar for mobile
    - _Requirements: 38.2_
  
  - [ ] 47.2 Optimize forms for mobile
    - Stack form fields vertically on mobile devices
    - Ensure touch-friendly input sizes
    - _Requirements: 38.3_
  
  - [ ] 47.3 Optimize tables for mobile
    - Make data tables horizontally scrollable on mobile
    - Consider card view for mobile table display
    - _Requirements: 38.4_
  
  - [ ]* 47.4 Write responsive design tests
    - Test navigation menu display at different breakpoints
    - Test form layout at different breakpoints
    - Test table scrolling on mobile
    - _Requirements: 38.2, 38.3, 38.4_

- [ ] 44. Toast Notification System
  - [ ] 48.1 Configure PrimeNG Toast globally
    - Add p-toast to MainLayoutComponent
    - Configure toast position and styling
    - _Requirements: 39.1_
  
  - [ ] 48.2 Implement toast notification properties
    - Ensure success toasts use green background (severity: success)
    - Ensure error toasts use red background (severity: error)
    - Ensure warning toasts use yellow background (severity: warning)
    - Ensure info toasts use blue background (severity: info)
    - Configure auto-dismiss after 5 seconds (life: 5000)
    - Enable manual dismissal with close button
    - _Requirements: 39.2, 39.3, 39.4, 39.5, 39.6, 39.7_
  
  - [ ]* 48.3 Write property tests for toast notifications
    - **Property 14: Toast Notification Severity**
    - **Property 15: Toast Auto-Dismissal**
    - **Property 16: Toast Manual Dismissal**
    - **Validates: Requirements 39.2, 39.3, 39.4, 39.5, 39.6, 39.7**

- [ ] 45. Form Validation System
  - [ ] 45.1 Create validation utility functions
    - Implement email format validator
    - Implement phone format validator
    - Implement date range validator
    - Implement positive number validator
    - _Requirements: 37.4, 37.5, 11.3, 11.4_
  
  - [ ] 45.2 Create form error display component
    - Display validation errors below form fields in red text
    - Show appropriate error messages for each validation type
    - _Requirements: 37.2, 37.3, 37.4, 37.5_
  
  - [ ] 45.3 Implement form submit button state management
    - Disable submit button when form is invalid
    - Enable submit button when form is valid
    - _Requirements: 37.6_
  
  - [ ]* 45.4 Write property tests for form validation
    - **Property 9: Form Validation Error Display**
    - **Property 10: Required Field Validation**
    - **Property 11: Email Format Validation**
    - **Property 12: Phone Format Validation**
    - **Property 13: Form Submission Error Feedback**
    - **Validates: Requirements 37.2, 37.3, 37.4, 37.5, 37.6, 37.7**

- [ ] 46. Error Handling and Logging
  - [ ] 46.1 Implement GlobalErrorHandler
    - Catch runtime errors
    - Display user-friendly error messages
    - Log technical details to console
    - _Requirements: 40.6_
  
  - [ ] 46.2 Enhance ErrorInterceptor with comprehensive error mapping
    - Map 400 Bad Request to validation errors
    - Map 401 Unauthorized to login redirect
    - Map 403 Forbidden to permission error
    - Map 404 Not Found to resource not found error
    - Map 500 Internal Server Error to generic error
    - Log all errors to console
    - _Requirements: 40.1, 40.2, 40.3, 40.4, 40.5, 40.6_
  
  - [ ]* 46.3 Write property test for error logging
    - **Property 17: Error Logging**
    - **Validates: Requirements 40.6**

- [ ] 47. Integration and Wiring
  - [ ] 47.1 Configure root NgRx store
    - Register all feature stores (auth, platform-admin, supplier, agency)
    - Configure store devtools for development
    - _Requirements: 6.1_
  
  - [ ] 47.2 Configure app routing
    - Set up root routes with lazy loading
    - Apply AuthGuard to protected routes
    - Apply RoleGuard to role-specific routes
    - Configure route redirects
    - _Requirements: 1.3, 2.3, 2.4_
  
  - [ ] 47.3 Configure HTTP interceptors
    - Register AuthInterceptor, ErrorInterceptor, LoadingInterceptor in app.config.ts
    - Ensure correct interceptor order
    - _Requirements: 3.1, 3.2, 3.3_
  
  - [ ] 47.4 Configure global providers
    - Register NotificationService, LoadingService, AuthService
    - Configure PrimeNG MessageService
    - Configure GlobalErrorHandler
    - _Requirements: 39.1, 40.6_
  
  - [ ]* 47.5 Write integration tests
    - Test complete authentication flow
    - Test complete booking creation flow
    - Test error handling across features
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 18.1, 18.2_

- [ ] 44. Final Checkpoint - Complete Application
  - Ensure all tests pass, ask the user if questions arise.
  - Verify all features are integrated and working
  - Verify responsive design on mobile devices
  - Verify error handling and toast notifications
  - Verify form validation across all forms

## Notes

- Tasks marked with `*` are optional property-based and unit tests that can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at major milestones
- Property tests validate universal correctness properties with minimum 100 iterations
- Unit tests validate specific examples and edge cases
- All components follow separation of concerns: .ts (logic), .html (template), .scss (styles)
- All PrimeNG form components use size="small"
- All input and textarea elements use class="p-inputtext-sm"
- All p-table components use styleClass="p-datatable-sm"
