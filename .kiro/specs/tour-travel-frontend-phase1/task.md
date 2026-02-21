# Implementation Plan: Tour & Travel SaaS Frontend - Phase 1 MVP

## Overview

This implementation plan breaks down the Tour & Travel SaaS Frontend into discrete, incremental coding tasks. The plan follows a bottom-up approach, starting with core infrastructure, then shared components, and finally feature-specific implementations. Each task builds on previous tasks, ensuring no orphaned code.

## Tasks

- [x] 1. Project Setup and Core Infrastructure
  - Initialize Angular 20 project with standalone components
  - Configure TailwindCSS 4, PrimeNG 20, and Lucide Angular
  - Set up folder structure (core, shared, features, store, layouts)
  - Configure environment files (development, production)
  - Set up routing configuration with lazy loading
  - _Requirements: 1.1, 1.2, 1.3, 7.1, 7.2, 7.3_

- [x] 2. Core Services and Models
  - [x] 2.1 Create core models (User, JwtPayload, ApiResponse)
    - Define TypeScript interfaces in core/models/
    - _Requirements: 2.1, 2.2_
  
  - [x] 2.2 Implement AuthService
    - Create login(), logout(), getToken(), isAuthenticated() methods
    - Implement JWT token decoding
    - Store token in localStorage
    - _Requirements: 2.1, 2.2_
  
  - [x] 2.3 Implement NotificationService
    - Create success(), error(), warning(), info() methods
    - Integrate with PrimeNG MessageService
    - _Requirements: 39.1, 39.2, 39.3, 39.4, 39.5_
  
  - [x] 2.4 Implement LoadingService
    - Create show(), hide() methods
    - Manage loading state with BehaviorSubject
    - _Requirements: 3.3_

- [x] 3. HTTP Interceptors
  - [x] 3.1 Implement AuthInterceptor
    - Attach JWT token to Authorization header
    - _Requirements: 3.1_
  
  - [ ]* 3.2 Write property test for AuthInterceptor
    - **Property 3: Authorization Header Attachment**
    - **Validates: Requirements 3.1**
  
  - [x] 3.3 Implement ErrorInterceptor
    - Handle 400, 401, 403, 404, 500 errors
    - Display toast notifications for errors
    - Redirect to login on 401
    - Log errors to console
    - _Requirements: 3.2, 3.4, 3.5, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6_
  
  - [ ]* 3.4 Write property test for ErrorInterceptor
    - **Property 4: HTTP Error Toast Notifications**
    - **Property 17: Error Logging**
    - **Validates: Requirements 3.2, 40.6_
  
  - [x] 3.5 Implement LoadingInterceptor
    - Track HTTP requests for loading state
    - _Requirements: 3.3_
  
  - [ ]* 3.6 Write property test for LoadingInterceptor
    - **Property 5: Loading State Management**
    - **Validates: Requirements 3.3**

- [x] 3A. Standardized API Response Handling (Req 50)
  - [x] 3A.1 Create API response interfaces
    - Create ApiResponse<T>, PaginatedApiResponse<T>, ApiErrorResponse interfaces
    - Create PaginationMetadata interface
    - Create ErrorCode type
    - _Requirements: 50.1, 50.2, 50.3, 50.14_
  
  - [x] 3A.2 Implement ApiResponseInterceptor
    - Automatically unwrap { success, data, message, timestamp } responses
    - Extract data property and return to components
    - _Requirements: 50.1, 50.6_
  
  - [x] 3A.3 Update ErrorHandlerInterceptor for standardized error responses
    - Handle ApiErrorResponse format with error codes
    - Map VALIDATION_ERROR to field-specific errors
    - Map UNAUTHORIZED to redirect to login
    - Map FORBIDDEN to permission error toast
    - Map NOT_FOUND to not found error toast
    - Map BUSINESS_RULE_VIOLATION to business rule error toast
    - Map INTERNAL_SERVER_ERROR to generic error toast
    - _Requirements: 50.2, 50.7, 50.8, 50.9, 50.10, 50.11, 50.12, 50.13_
  
  - [x] 3A.4 Register interceptors in app.config.ts
    - Add apiResponseInterceptor before errorHandlerInterceptor
    - Ensure correct order: auth → apiResponse → errorHandler → loading
    - _Requirements: 50.6, 50.7_
  
  - [x] 3A.5 Update all API services to use new response interfaces
    - Update return types to match unwrapped data
    - Use snake_case property names in interfaces
    - _Requirements: 50.4, 50.5_
  
  - [x] 3A.6 Update components to handle unwrapped responses
    - Remove manual response.data extraction
    - Handle pagination metadata from unwrapped responses
    - _Requirements: 50.15_
  
  - [ ]* 3A.7 Write unit tests for ApiResponseInterceptor
    - Test automatic unwrapping of success responses
    - Test passthrough for non-wrapped responses
    - _Requirements: 50.1, 50.6_
  
  - [ ]* 3A.8 Write unit tests for error handling with error codes
    - Test each error code mapping to appropriate action
    - _Requirements: 50.8, 50.9, 50.10, 50.11, 50.12, 50.13_

- [x] 4. Route Guards
  - [x] 4.1 Implement AuthGuard
    - Check authentication status
    - Redirect to login if not authenticated
    - _Requirements: 2.3_
  
  - [ ]* 4.2 Write unit tests for AuthGuard
    - Test authenticated and unauthenticated scenarios
    - _Requirements: 2.3_
  
  - [x] 4.3 Implement RoleGuard
    - Check user_type against allowed roles
    - Display permission error if unauthorized
    - _Requirements: 2.4_
  
  - [ ]* 4.4 Write property test for RoleGuard
    - **Property 2: Role-Based Route Access**
    - **Validates: Requirements 2.4**

- [x] 5. Shared Components
  - [x] 5.1 Create DataTableComponent
    - Implement with PrimeNG Table
    - Support columns, data, loading, pagination, sorting, filtering
    - Use styleClass="p-datatable-sm"
    - Emit onRowSelect, onRowEdit, onRowDelete events
    - _Requirements: 5.3, 33.1, 33.2, 33.3, 33.4, 33.5, 33.6_
  
  - [x] 5.2 Create PageHeaderComponent
    - Display title, breadcrumbs, and action buttons
    - Use responsive layout
    - Support breadcrumb format: Home > Section > Subsection > Current Page
    - Display action buttons with primary/secondary variants
    - Use Lucide icons for breadcrumb home icon
    - _Requirements: 39.1, 39.2, 39.3, 39.4, 39.5, 39.6, 39.7_
  
  - [x] 5.3 Create ConfirmationDialogComponent
    - Implement with PrimeNG Dialog
    - Support message, header, accept/reject labels, severity
    - Emit onAccept and onReject events
    - _Requirements: 35.1, 35.2, 35.3, 35.4, 35.5_
  
  - [x] 5.4 Create LoadingSpinnerComponent
    - Implement with PrimeNG ProgressSpinner
    - Support overlay and inline modes
    - _Requirements: 36.1, 36.2, 36.3, 36.4, 36.5_

- [ ] 6. Checkpoint - Core Infrastructure Complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6.5. Mock Data Infrastructure
  - [x] 6.5.1 Create environment configuration files
    - Create src/environments/environment.ts with apiReady flag
    - Create src/environments/environment.prod.ts
    - Configure apiUrl and mockDelay settings
    - _Requirements: 45.1, 45.9_
  
  - [x] 6.5.2 Create base mock data utilities
    - Create BaseMockData class with utility methods (randomInt, randomElement, randomDate, randomBoolean)
    - Create MockStateService for centralized state management
    - _Requirements: 45.4, 45.7_
  
  - [x] 6.5.3 Create API service interfaces
    - Define IAgencyApiService interface
    - Define ISupplierApiService interface
    - Define IServiceApiService interface
    - Define IPackageApiService interface
    - Define IJourneyApiService interface
    - Define ICustomerApiService interface
    - Define IBookingApiService interface
    - _Requirements: 45.2, 45.3_
  
  - [x] 6.5.4 Create mock data factories for Platform Admin entities
    - Create AgencyMockData factory
    - Create SupplierMockData factory
    - Create SubscriptionPlanMockData factory
    - Create CommissionConfigMockData factory
    - _Requirements: 45.4, 45.5, 45.8_
  
  - [x] 6.5.5 Create mock data factories for Supplier entities
    - Create ServiceMockData factory
    - Create SeasonalPriceMockData factory
    - Create PurchaseOrderMockData factory
    - _Requirements: 45.4, 45.5, 45.8_
  
  - [x] 6.5.6 Create mock data factories for Agency entities
    - Create PackageMockData factory
    - Create JourneyMockData factory
    - Create CustomerMockData factory
    - Create BookingMockData factory with relationship support
    - Create TravelerMockData factory
    - Create DocumentMockData factory
    - Create TaskMockData factory
    - Create PaymentMockData factory
    - _Requirements: 45.4, 45.5, 45.8_
  
  - [x] 6.5.7 Create mock API services for Platform Admin
    - Create AgencyMockService implementing IAgencyApiService
    - Create SupplierMockService implementing ISupplierApiService
    - Implement CRUD operations with in-memory state
    - Add simulated delays and console logging
    - _Requirements: 45.2, 45.3, 45.6, 45.7, 45.10_
  
  - [x] 6.5.8 Create mock API services for Supplier
    - Create ServiceMockService implementing IServiceApiService
    - Create PurchaseOrderMockService
    - Implement CRUD operations with in-memory state
    - _Requirements: 45.2, 45.3, 45.6, 45.7, 45.10_
  
  - [x] 6.5.9 Create mock API services for Agency
    - Create PackageMockService implementing IPackageApiService
    - Create JourneyMockService implementing IJourneyApiService
    - Create CustomerMockService implementing ICustomerApiService
    - Create BookingMockService implementing IBookingApiService
    - Implement CRUD operations with in-memory state
    - _Requirements: 45.2, 45.3, 45.6, 45.7, 45.10_
  
  - [x] 6.5.10 Configure conditional service providers
    - Create InjectionToken for each API service interface
    - Update app.config.ts to provide services based on environment.apiReady
    - When apiReady is false, use mock services
    - When apiReady is true, use real API services
    - Use factory providers to dynamically select service implementation
    - Test switching between mock and real services by toggling environment.apiReady
    - _Requirements: 45.1, 45.2, 45.3, 45.9_
  
  - [ ]* 6.5.11 Write unit tests for mock services
    - Test mock data generation
    - Test CRUD operations in mock services
    - Test relationship integrity in mock data
    - _Requirements: 45.4, 45.5, 45.7, 45.8_


- [x] 7. Authentication Feature
  - [x] 7.1 Create auth models and routes
    - Define LoginCredentials, AuthResponse interfaces
    - Configure auth.routes.ts with lazy loading
    - _Requirements: 2.1_
  
  - [x] 7.2 Create LoginComponent
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
  
  - [x] 7.4 Create auth NGXS store
    - Define auth.actions.ts (Login, LoginSuccess, LoginFailure, Logout)
    - Define auth.state.ts with @State decorator and @Action handlers
    - Define auth.model.ts (AuthStateModel interface)
    - Add @Selector static methods for state selection
    - Register AuthState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 7.5 Write unit tests for auth store
    - Test actions and state handlers
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 7.5.1 Integrate Authentication with Backend API
    - Remove mockLogin() method from AuthService
    - Update login() method to use real API endpoint from environment
    - Update app.routes.ts to redirect root path from '/auth/mock-login' to '/auth/login'
    - Remove mock-login route from auth.routes.ts
    - Test login flow with real backend API
    - _Requirements: 2.1, 2.2_

- [ ] 7.6. Supplier Registration Feature
  - [ ] 7.6.1 Create supplier registration models
    - Define SupplierRegistrationRequest, BusinessType interfaces
    - Add to auth models
    - _Requirements: 48.2, 48.3_
  
  - [ ] 7.6.2 Create SupplierRegistrationComponent
    - Create separate supplier-registration.component.ts, .html, .scss files
    - Implement reactive form with all required fields
    - Use class="p-inputtext-sm" for all inputs
    - Use size="small" for all form components
    - Use p-dropdown with size="small" for business_type
    - _Requirements: 48.1, 48.2, 48.3, 5.1, 5.2_
  
  - [ ] 7.6.3 Implement form validation
    - Validate required fields (company_name, business_type, email, phone, business_license_number)
    - Validate email format
    - Validate phone format
    - Display validation errors below fields
    - _Requirements: 48.4, 48.5, 48.6, 42.2, 42.3, 42.4_
  
  - [ ] 7.6.4 Implement password validation
    - Add password and confirm_password fields with p-password component
    - Implement password strength indicator
    - Validate password requirements (min 8 chars, 1 uppercase, 1 lowercase, 1 number)
    - Validate password and confirm_password match
    - Display validation errors
    - _Requirements: 48.7, 48.8, 48.9_
  
  - [ ] 7.6.5 Implement terms and conditions
    - Add checkbox for terms and conditions acceptance
    - Disable submit button until checkbox is checked
    - Validate checkbox is checked before submission
    - _Requirements: 48.12_
  
  - [ ] 7.6.6 Implement registration submission
    - Create registerSupplier() method in AuthService
    - Dispatch registration action on form submit
    - Display success message with toast notification
    - Redirect to login page after 3 seconds on success
    - Display error messages on failure
    - _Requirements: 48.10, 48.11, 48.14_
  
  - [ ] 7.6.7 Add navigation links
    - Add "Already have an account? Login" link to login page
    - Add "Register as Supplier" link on login page
    - _Requirements: 48.13_
  
  - [ ] 7.6.8 Configure registration route
    - Add /register/supplier route to auth.routes.ts
    - Ensure route is publicly accessible (no AuthGuard)
    - _Requirements: 48.1_
  
  - [ ]* 7.6.9 Write unit tests for supplier registration
    - Test form validation (required fields, email, phone, password)
    - Test password strength validation
    - Test password match validation
    - Test terms acceptance validation
    - Test successful registration flow
    - _Requirements: 48.4, 48.5, 48.6, 48.7, 48.8, 48.9, 48.12_

- [x] 8. Layout Components
  - [x] 8.1 Create MainLayoutComponent
    - Implement with header, sidebar, and content area
    - Use responsive design
    - Include p-toast for global notifications
    - _Requirements: 38.1, 38.2, 39.1_
  
  - [x] 8.2 Create HeaderComponent
    - Display search bar, notifications, user menu
    - Use PrimeNG components with size="small"
    - _Requirements: 5.1, 5.2, 5.4_
  
  - [x] 8.3 Create SidebarComponent
    - Display navigation menu
    - Support collapsible menu
    - Highlight active route
    - Show hamburger icon on mobile
    - _Requirements: 38.2_
  
  - [x] 8.4 Create AuthLayoutComponent
    - Simple layout for login page
    - _Requirements: 4.1_

- [-] 9. Platform Admin Portal - Agency Management
  - [x] 9.1 Create platform-admin models
    - Define Agency, CreateAgencyRequest interfaces
    - _Requirements: 8.1_
  
  - [x] 9.2 Create AgencyApiService
    - Implement getAll(), getById(), create(), update(), toggleStatus() methods
    - _Requirements: 8.1_
  
  - [x] 9.3 Create platform-admin NGXS store
    - Create agency.model.ts (AgencyStateModel interface)
    - Create agency.actions.ts (LoadAgencies, CreateAgency, UpdateAgency, ToggleAgencyStatus)
    - Create agency.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register AgencyState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 9.4 Create AgencyListComponent
    - Display agencies in DataTableComponent
    - Show agency_code, company_name, email, subscription_plan, is_active
    - Use @Select decorator or Store.select() for reactive state
    - Use Store.dispatch() to trigger actions
    - Implement toggle status with confirmation dialog
    - Apply design system: @include modern-card, @include modern-table
    - Use utility classes from design system
    - _Requirements: 8.1, 8.3, 8.4, 5.3, 41.8, 41.9, 37.7_
  
  - [ ]* 9.5 Write property test for agency operations
    - **Property 6: Successful Operation Feedback**
    - **Validates: Requirements 8.5**
  
  - [x] 9.6 Create AgencyFormComponent
    - Implement reactive form with company_name, email, phone, address, city, province, postal_code
    - Use class="p-inputtext-sm" for all inputs
    - Use size="small" for all form components
    - Validate required fields and email format
    - Apply design system: @include modern-input, @include modern-button
    - Use utility classes for form layout
    - _Requirements: 8.2, 5.1, 5.2, 37.1, 37.2, 37.3, 37.4, 41.8, 41.9_
  
  - [x] 9.7 Write unit tests for AgencyFormComponent
    - Test form validation and submission
    - _Requirements: 8.2, 37.1, 37.2, 37.3, 37.4_

- [x] 10. Platform Admin Portal - Supplier Approval
  - [x] 10.1 Create supplier models
    - Define Supplier, SupplierStatus interfaces
    - _Requirements: 9.1_
  
  - [x] 10.2 Create SupplierApiService
    - Implement getAll(), getById(), approve(), reject() methods
    - _Requirements: 9.1_
  
  - [x] 10.3 Create supplier NGXS store
    - Create supplier.model.ts (SupplierStateModel interface)
    - Create supplier.actions.ts (LoadSuppliers, ApproveSupplier, RejectSupplier)
    - Create supplier.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 10.4 Create SupplierListComponent
    - Display suppliers in DataTableComponent
    - Filter by status (pending, active, rejected, suspended)
    - Show approve/reject buttons for pending suppliers
    - Use confirmation dialog for approve/reject actions
    - Apply design system: @include modern-card, @include modern-table, @include modern-badge
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 37.7_
  
  - [x] 10.5 Write unit tests for SupplierListComponent
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

- [x] 12. Platform Admin Portal - Subscription Plan Management
  - [x] 12.1 Create subscription plan models
    - Define SubscriptionPlan, PlanName, AgencySubscription, SubscriptionStatus interfaces
    - _Requirements: 10.1_
  
  - [x] 12.2 Create SubscriptionPlanApiService
    - Implement getAll(), getById(), create(), update(), toggleStatus() methods
    - _Requirements: 10.1_
  
  - [x] 12.3 Create subscription plan NGXS store
    - Create subscription-plan.model.ts (SubscriptionPlanStateModel interface)
    - Create subscription-plan.actions.ts (LoadSubscriptionPlans, CreateSubscriptionPlan, UpdateSubscriptionPlan, ToggleSubscriptionPlanStatus)
    - Create subscription-plan.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register SubscriptionPlanState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 12.4 Create SubscriptionPlanListComponent
    - Display subscription plans in DataTableComponent
    - Show plan_name, monthly_price, annual_price, max_users, max_bookings_per_month, features, is_active
    - Use styleClass="p-datatable-sm"
    - Implement toggle status with confirmation dialog
    - _Requirements: 10.1, 10.4, 5.3_
  
  - [x] 12.5 Create SubscriptionPlanFormComponent
    - Implement reactive form with plan_name, description, monthly_price, annual_price, max_users, max_bookings_per_month, features
    - Use p-dropdown with size="small" for plan_name
    - Use p-multiselect with size="small" for features
    - Validate required fields and positive prices
    - _Requirements: 10.2, 10.3, 5.1, 5.2_
  
  - [ ]* 12.6 Write unit tests for SubscriptionPlanFormComponent
    - Test form validation and submission
    - _Requirements: 10.2, 10.3_

- [x] 13. Platform Admin Portal - Commission Configuration
  - [x] 21.1 Create commission models
    - Define CommissionConfig, CommissionHistory interfaces
    - _Requirements: 11.1_
  
  - [x] 21.2 Create CommissionApiService
    - Implement getCurrent(), getHistory(), update() methods
    - _Requirements: 11.1_
  
  - [x] 21.3 Create commission NGXS store
    - Create commission.model.ts (CommissionStateModel interface)
    - Create commission.actions.ts (LoadCommissionConfig, LoadCommissionHistory, UpdateCommissionConfig)
    - Create commission.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register CommissionState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 21.4 Create CommissionConfigComponent
    - Display current commission_type and commission_rate
    - Display commission history table
    - Provide edit commission button
    - _Requirements: 11.1, 11.5_
  
  - [x] 21.5 Create CommissionConfigFormComponent
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

- [x] 14. Platform Admin Portal - Agency Subscription Assignment
  - [x] 38.1 Create AgencySubscriptionComponent (in AgencyDetail)
    - Display current subscription plan, dates, and status
    - Show subscription status badge with colors
    - Provide assign subscription button
    - Provide upgrade/downgrade plan button
    - _Requirements: 12.1, 12.4_
  
  - [x] 38.2 Create AssignSubscriptionDialogComponent
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

- [x] 15. Platform Admin Portal - Revenue Dashboard
  - [x] 15.1 Create revenue models
    - Define RevenueMetrics, RevenueByPlan, AgencyRevenue, CommissionRevenueTrend interfaces
    - _Requirements: 13.1_
  
  - [x] 15.2 Create RevenueApiService
    - Implement getMetrics(), getByPlan(), getTopAgencies(), getCommissionTrend() methods
    - _Requirements: 13.1_
  
  - [x] 15.3 Create revenue NGXS store
    - Create revenue.model.ts (RevenueStateModel interface)
    - Create revenue.actions.ts (LoadRevenueMetrics, LoadRevenueByPlan, LoadTopAgencies, LoadCommissionTrend)
    - Create revenue.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register RevenueState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 15.4 Create RevenueDashboardComponent
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


- [x] 17. Supplier Portal - Service Catalog Management
  - [x] 17.1 Create supplier service models
    - Define SupplierService, ServiceType, SeasonalPrice interfaces
    - _Requirements: 11.1_
  
  - [x] 17.2 Create ServiceApiService
    - Implement getAll(), getById(), create(), update(), publish() methods
    - _Requirements: 11.1_
  
  - [x] 17.3 Create service NGXS store
    - Create service.model.ts (ServiceStateModel interface)
    - Create service.actions.ts (LoadServices, CreateService, UpdateService, PublishService)
    - Create service.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register ServiceState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 17.4 Create ServiceListComponent
    - Display services in DataTableComponent
    - Show service_code, service_type, name, base_price, status
    - Implement publish button
    - _Requirements: 11.1, 11.6_
  
  - [x] 17.5 Create ServiceFormComponent
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

- [x] 18. Supplier Portal - Seasonal Pricing
  - [x] 18.1 Create SeasonalPriceComponent
    - Display seasonal prices list for a service
    - Show season_name, start_date, end_date, seasonal_price
    - _Requirements: 12.1_
  
  - [x] 18.2 Create SeasonalPriceFormComponent
    - Implement reactive form with season_name, start_date, end_date, seasonal_price
    - Use p-calendar with size="small"
    - Validate date range (end_date >= start_date)
    - Validate price > 0
    - _Requirements: 12.2, 12.3, 12.4, 5.1, 5.2_
  
  - [ ]* 38.3 Write property tests for seasonal price validation
    - **Property 7: Date Range Validation**
    - **Property 8: Positive Price Validation**
    - **Validates: Requirements 12.3, 12.4**

- [x] 19. Supplier Portal - Purchase Order Management
  - [x] 27.1 Create purchase order models
    - Define PurchaseOrder, POItem, POStatus interfaces
    - _Requirements: 13.1_
  
  - [x] 27.2 Create PurchaseOrderApiService
    - Implement getAll(), getById(), approve(), reject() methods
    - _Requirements: 13.1_
  
  - [x] 27.3 Create purchase order NGXS store
    - Create purchase-order.model.ts (PurchaseOrderStateModel interface)
    - Create purchase-order.actions.ts (LoadPurchaseOrders, ApprovePurchaseOrder, RejectPurchaseOrder)
    - Create purchase-order.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register PurchaseOrderState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 27.4 Create PurchaseOrderListComponent
    - Display POs in DataTableComponent
    - Filter by status (pending, approved, rejected)
    - Show po_number, agency_name, total_amount, status, created_at
    - _Requirements: 13.1, 13.2_
  
  - [x] 27.5 Create PurchaseOrderDetailComponent
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


- [x] 21. Agency Portal - Procurement (Supplier Browsing & PO Creation)
  - [x] 21.1 Create SupplierBrowsingComponent
    - Display suppliers in DataTableComponent
    - Show supplier_code, company_name, business_type
    - Provide "View Services" button
    - _Requirements: 17.1_
  
  - [x] 21.2 Create SupplierServicesComponent
    - Display supplier services in DataTableComponent
    - Show service_code, service_type, name, base_price
    - Provide "Add to Cart" button
    - Maintain cart state in NGXS store
    - _Requirements: 17.2, 17.3_
  
  - [x] 21.3 Create PurchaseOrderFormComponent
    - Display cart items
    - Calculate total_amount
    - Submit PO with all cart items
    - Clear cart after successful submission
    - _Requirements: 17.4, 17.5_
  
  - [ ]* 21.4 Write unit tests for cart functionality
    - Test add to cart, remove from cart, calculate total
    - _Requirements: 17.3, 17.5_

- [ ] 22. Agency Portal - Package Management
  - [x] 22.1 Create package models
    - Define Package, PackageService, PackageType interfaces
    - _Requirements: 18.1_
  
  - [x] 22.2 Create PackageApiService
    - Implement getAll(), getById(), create(), update(), publish() methods
    - _Requirements: 18.1_
  
  - [x] 22.3 Create package NGXS store
    - Create package.model.ts (PackageStateModel interface)
    - Create package.actions.ts (LoadPackages, CreatePackage, UpdatePackage, PublishPackage)
    - Create package.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register PackageState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 22.4 Create PackageListComponent
    - Display packages in DataTableComponent
    - Show package_code, package_type, name, duration_days, selling_price, status
    - _Requirements: 18.1_
  
  - [x] 22.5 Create PackageFormComponent with Service Selection
    - Implement reactive form with package_type, name, description, duration_days, markup_type, markup_value, selling_price
    - Use p-dropdown with size="small" for package_type
    - Validate selling_price >= base_cost
    - _Requirements: 19.2, 19.3, 19.4, 5.1, 5.2_
  
  - [x] 22.6 Implement Service Selection Interface
    - Create service selection table displaying available services from:
      - Approved PO items (po_items from approved purchase_orders)
      - Agency services (agency_services purchased from B2B marketplace)
    - Display columns: source_type (Supplier/Agency), service_type, service_name, unit_cost, quantity selector, total_cost
    - Allow multi-select with quantity input for each service
    - _Requirements: 19.5, 19.6, 19.7_
  
  - [x] 22.7 Implement Auto-Calculation Logic
    - Calculate base_cost automatically as sum of all selected services' total_cost (quantity × unit_cost)
    - Calculate selling_price based on markup_type and markup_value:
      - If markup_type is percentage: selling_price = base_cost × (1 + markup_value/100)
      - If markup_type is fixed: selling_price = base_cost + markup_value
    - Update calculations reactively when services or markup changes
    - _Requirements: 19.8, 19.9, 19.10, 19.11_
  
  - [x] 22.8 Implement Package Services Save
    - Save selected services to package_services table with fields:
      - package_id, supplier_service_id (if from PO), agency_service_id (if from marketplace)
      - source_type, quantity, unit_cost, total_cost
    - Display selected services summary showing total number of services and base_cost breakdown by service_type
    - _Requirements: 19.12, 19.13_
  
  - [x] 22.9 Add API endpoints for service inventory
    - Create endpoint to fetch available services from approved POs: GET /api/packages/available-services
    - Return combined list of po_items and agency_services with unified structure
    - _Requirements: 19.5_
  
  - [ ]* 22.10 Write property test for package pricing validation
    - **Property 8: Positive Price Validation** (applied to selling_price)
    - Test selling_price >= base_cost validation
    - **Validates: Requirements 19.4**

- [ ] 23. Agency Portal - Journey Management with Service Tracking
  - [x] 23.1 Create journey models
    - Define Journey, JourneyStatus, JourneyService interfaces
    - Add JourneyService interface with tracking fields: booking_status, execution_status, payment_status, booked_at, confirmed_at, executed_at, issue_notes
    - _Requirements: 20.1_
  
  - [x] 23.2 Create JourneyApiService
    - Implement getAll(), getById(), create(), update() methods
    - Add getJourneyServices(journeyId) method
    - Add updateServiceStatus(journeyId, serviceId, statusUpdate) method
    - _Requirements: 20.1_
  
  - [x] 23.3 Create journey NGXS store
    - Create journey.model.ts (JourneyStateModel interface)
    - Create journey.actions.ts (LoadJourneys, CreateJourney, UpdateJourney, LoadJourneyServices, UpdateServiceStatus)
    - Create journey.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register JourneyState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 23.4 Create JourneyListComponent
    - Display journeys in DataTableComponent
    - Show journey_code, package_name, departure_date, return_date, total_quota, confirmed_pax, available_quota, status
    - Use PageHeaderComponent with breadcrumbs: Home > Journeys
    - Add "Create Journey" action button in page header
    - Apply design system: @include modern-card, @include modern-table
    - _Requirements: 20.1, 39.1, 39.2, 39.3, 38.7_
  
  - [x] 23.5 Create JourneyFormComponent with view/edit/create modes
    - Implement reactive form with package_id, departure_date, return_date, total_quota
    - Support three modes: view, edit, create
    - Use PageHeaderComponent with breadcrumbs: Home > Journeys > [View/Edit/Create] Journey
    - In view mode: display read-only fields with "Edit" and "Back" buttons
    - In edit mode: enable fields with "Save" and "Cancel" buttons
    - In create mode: enable fields with "Create" and "Cancel" buttons
    - Use p-calendar with size="small" for dates
    - Validate return_date > departure_date
    - Display quota information (total_quota, confirmed_pax, available_quota)
    - Show confirmation dialog on Cancel with unsaved changes
    - Apply design system: @include modern-input, @include modern-button
    - _Requirements: 20.2, 20.3, 20.4, 5.1, 5.2, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6, 40.7, 40.8, 40.9, 40.10_
  
  - [x] 23.6 Implement Journey Service Auto-Copy on Creation
    - When journey is created, automatically copy all services from package_services to journey_services
    - Initialize journey_services with default tracking status:
      - booking_status: not_booked
      - execution_status: pending
      - payment_status: unpaid
    - _Requirements: 20.5, 20.6_
  
  - [x] 23.7 Create JourneyServiceTrackingComponent
    - Display service tracking table with columns: service_type, service_name, booking_status, execution_status, payment_status, actions
    - Show status badges with appropriate colors:
      - booking_status: not_booked (gray), booked (blue), confirmed (green), cancelled (red)
      - execution_status: pending (gray), in_progress (yellow), completed (green), failed (red)
      - payment_status: unpaid (red), partially_paid (yellow), paid (green)
    - Display service tracking progress summary showing counts by status
    - _Requirements: 20.7, 20.12, 20.13_
  
  - [x] 23.8 Create Service Status Update Dialog
    - Create dialog component with fields:
      - booking_status dropdown (not_booked, booked, confirmed, cancelled)
      - execution_status dropdown (pending, in_progress, completed, failed)
      - payment_status dropdown (unpaid, partially_paid, paid)
      - issue_notes textarea
    - Implement auto-timestamp logic:
      - When booking_status changes to booked: set booked_at
      - When booking_status changes to confirmed: set confirmed_at
      - When execution_status changes to completed: set executed_at
    - _Requirements: 20.8, 20.9, 20.10, 20.11_
  
  - [x] 23.9 Add API endpoints for journey service tracking
    - Create endpoint: GET /api/journeys/{id}/services
    - Create endpoint: PATCH /api/journeys/{id}/services/{serviceId}/status
    - Backend should handle auto-copy from package_services on journey creation
    - _Requirements: 20.5, 20.7_
  
  - [ ]* 23.10 Write property test for journey date validation
    - **Property 7: Date Range Validation** (applied to departure/return dates)
    - **Validates: Requirements 20.3**

- [x] 24. Agency Portal - Customer Management
  - [x] 24.1 Create customer models
    - Define Customer interface
    - _Requirements: 21.1_
  
  - [x] 24.2 Create CustomerApiService
    - Implement getAll(), getById(), create(), update() methods
    - _Requirements: 21.1_
  
  - [x] 24.3 Create customer NGXS store
    - Create customer.model.ts (CustomerStateModel interface)
    - Create customer.actions.ts (LoadCustomers, CreateCustomer, UpdateCustomer)
    - Create customer.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register CustomerState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 24.4 Create CustomerListComponent
    - Display customers in DataTableComponent
    - Show customer_code, name, email, phone, total_bookings, total_spent, last_booking_date
    - Use PageHeaderComponent with breadcrumbs: Home > Customers
    - Add "Create Customer" action button in page header
    - Apply design system: @include modern-card, @include modern-table
    - _Requirements: 21.1, 39.1, 39.2, 39.3, 38.7_
  
  - [x] 24.5 Create CustomerFormComponent with view/edit/create modes
    - Implement reactive form with name, email, phone, address, city, province, postal_code, country
    - Support three modes: view, edit, create
    - Use PageHeaderComponent with breadcrumbs: Home > Customers > [View/Edit/Create] Customer
    - **Section 1: Customer Overview (View mode only)** - gradient header `purple-50 to pink-50`, icon `pi-info-circle`
      - Display customer_code and total_bookings
    - **Section 2: Personal Information** - gradient header `blue-50 to indigo-50`, icon `pi-user`
      - Fields: name, email, phone
      - Use p-iconfield with icons for email and phone
    - **Section 3: Address Information** - gradient header `green-50 to emerald-50`, icon `pi-map-marker`
      - Fields: address, city, province, postal_code, country
    - In view mode: display read-only fields with "Edit" and "Back" buttons in header actions
    - In edit mode: enable fields with "Save" and "Cancel" buttons in header actions
    - In create mode: enable fields with "Create" and "Cancel" buttons in header actions
    - Validate phone uniqueness
    - Validate email uniqueness if provided
    - Use class="p-inputtext-sm" for all inputs
    - Use size="small" for all PrimeNG components
    - Show confirmation dialog on Cancel with unsaved changes
    - Form actions footer with info text and action buttons using app-action-button
    - _Requirements: 21.2, 21.3, 21.4, 5.1, 5.2, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6, 40.7, 40.8, 40.9, 40.10_
  
  - [ ]* 24.6 Write property tests for customer form validation
    - **Property 10: Required Field Validation** (name, phone)
    - **Property 11: Email Format Validation**
    - **Property 12: Phone Format Validation**
    - **Validates: Requirements 21.2, 21.3, 21.4**

- [ ] 25. Checkpoint - Agency Portal Core Features Complete
  - Ensure all tests pass, ask the user if questions arise.


- [x] 26. Agency Portal - Booking Management
  - [x] 26.1 Create booking models
    - Define Booking, BookingStatus, BookingSource, Traveler interfaces
    - _Requirements: 22.1, 24.1_
  
  - [x] 26.2 Create BookingApiService
    - Implement getAll(), getById(), create(), approve(), cancel() methods
    - _Requirements: 22.1, 23.1_
  
  - [x] 26.3 Create booking NGXS store
    - Create booking.model.ts (BookingStateModel interface)
    - Create booking.actions.ts (LoadBookings, CreateBooking, ApproveBooking, CancelBooking)
    - Create booking.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register BookingState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [x] 26.4 Create BookingListComponent
    - Display bookings in DataTableComponent
    - Show booking_reference, customer_name, package_name, journey_code, total_pax, total_amount, booking_status, created_at
    - _Requirements: 22.1_
  
  - [x] 26.5 Create BookingFormComponent with view/edit/create modes
    - Implement reactive form with package_id, journey_id, customer_id, total_pax, booking_source
    - Support three modes: view, edit, create
    - Use PageHeaderComponent with breadcrumbs: Home > Bookings > [View/Edit/Create] Booking
    - **Section 1: Booking Overview (View mode only)** - gradient header `purple-50 to pink-50`, icon `pi-info-circle`
      - Display booking_reference and booking_status
    - **Section 2: Booking Details** - gradient header `blue-50 to indigo-50`, icon `pi-calendar`
      - Fields: package_id, journey_id, customer_id, total_pax, booking_source
      - Use p-dropdown with size="small" for all dropdowns
    - **Section 3: Pricing Summary** - gradient header `green-50 to emerald-50`, icon `pi-dollar`
      - Display calculated total_amount (package selling_price × total_pax)
      - Show available_quota validation
    - In view mode: display read-only fields with "Edit" and "Back" buttons in header actions
    - In edit mode: enable fields with "Save" and "Cancel" buttons in header actions
    - In create mode: enable fields with "Create" and "Cancel" buttons in header actions
    - Calculate total_amount as package selling_price × total_pax
    - Validate journey available_quota >= total_pax
    - Use size="small" for all PrimeNG components
    - Show confirmation dialog on Cancel with unsaved changes
    - Form actions footer with info text and action buttons using app-action-button
    - _Requirements: 22.2, 22.3, 22.4, 22.5, 5.1, 5.2, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6, 40.7, 40.8, 40.9, 40.10_
  
  - [ ]* 26.6 Write unit tests for BookingFormComponent
    - Test total_amount calculation
    - Test quota validation
    - _Requirements: 22.4, 22.5_

- [x] 27. Agency Portal - Booking Detail and Approval
  - [x] 27.1 Create BookingDetailComponent
    - Display booking information card
    - Display document progress card with progress bar
    - Display task progress card with progress bar
    - Use p-tabView for travelers, documents, tasks, payments tabs
    - _Requirements: 23.1, 23.2_
  
  - [x] 27.2 Implement booking approval functionality
    - Add approve button with confirmation dialog
    - Add cancel button with cancellation_reason dialog
    - Update journey quota after approval/cancellation
    - _Requirements: 23.2, 23.3, 23.4, 23.5_
  
  - [ ]* 27.3 Write unit tests for booking approval
    - Test approval with confirmation
    - Test cancellation with reason
    - _Requirements: 23.2, 23.3, 23.4, 23.5_

- [-] 28. Agency Portal - Traveler Management
  - [x] 28.1 Create TravelerFormComponent with view/edit/create modes
    - Implement reactive form with full_name, gender, date_of_birth, nationality, passport_number, passport_expiry
    - Support three modes: view, edit, create
    - **Section 1: Personal Information** - gradient header `blue-50 to indigo-50`, icon `pi-user`
      - Fields: full_name, gender, date_of_birth, nationality
      - Use p-dropdown with size="small" for gender
      - Use p-calendar with size="small" for date_of_birth
    - **Section 2: Passport Information** - gradient header `green-50 to emerald-50`, icon `pi-id-card`
      - Fields: passport_number, passport_expiry
      - Use p-calendar with size="small" for passport_expiry
    - **Section 3: Mahram Information (Conditional)** - gradient header `orange-50 to amber-50`, icon `pi-users`
      - Conditionally show mahram_traveler_number for female travelers in Umrah/Hajj packages
      - Validate mahram references existing male traveler
    - In view mode: display read-only fields with "Edit" and "Back" buttons in header actions
    - In edit mode: enable fields with "Save" and "Cancel" buttons in header actions
    - In create mode: enable fields with "Add Traveler" and "Cancel" buttons in header actions
    - Use size="small" for all PrimeNG components
    - Show confirmation dialog on Cancel with unsaved changes
    - Form actions footer with info text and action buttons using app-action-button
    - _Requirements: 24.2, 24.3, 24.4, 5.1, 5.2, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6, 40.7, 40.8, 40.9, 40.10_
  
  - [ ]* 28.2 Write unit tests for mahram validation
    - Test mahram requirement for female travelers > 12 years in Umrah/Hajj
    - Test mahram reference validation
    - _Requirements: 24.3, 24.4_

- [x] 29. Agency Portal - Document Management
  - [x] 29.1 Create document models
    - Define BookingDocument, DocumentStatus interfaces
    - _Requirements: 25.1_
  
  - [x] 29.2 Create DocumentApiService
    - Implement getByBookingId(), updateStatus() methods
    - _Requirements: 25.1_
  `
  - [x] 29.3 Create document NGXS store
    - Create document.model.ts (DocumentStateModel interface)
    - Create document.actions.ts (LoadDocuments, UpdateDocumentStatus)
    - Create document.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection including document completion percentage
    - Register DocumentState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 25.2_
  
  - [x] 29.4 Create DocumentListComponent (in BookingDetail tab)
    - Display documents in DataTableComponent
    - Show document_type, traveler_name, status, document_number, expiry_date
    - Highlight expiring documents (expiry < 30 days)
    - Provide "Update Status" button
    - _Requirements: 25.1, 25.6_
  
  - [x] 29.5 Create DocumentStatusDialogComponent
    - Show form with status dropdown, document_number, issue_date, expiry_date
    - Require rejection_reason when status is rejected
    - _Requirements: 25.4, 25.5_
  
  - [ ]* 29.6 Write unit tests for document management
    - Test completion percentage calculation
    - Test expiring document highlighting
    - _Requirements: 25.2, 25.6_

- [x] 30. Agency Portal - Task Management with Kanban Board
  - [x] 30.1 Create task models
    - Define BookingTask, TaskStatus, TaskPriority interfaces
    - _Requirements: 26.1_
  
  - [x] 30.2 Create TaskApiService
    - Implement getByBookingId(), updateStatus(), assign(), create() methods
    - _Requirements: 26.1_
  
  - [x] 30.3 Create task NGXS store
    - Create task.model.ts (TaskStateModel interface)
    - Create task.actions.ts (LoadTasks, UpdateTaskStatus, AssignTask, CreateTask)
    - Create task.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection including task completion percentage
    - Register TaskState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 26.1_
  
  - [x] 30.4 Create TaskKanbanComponent (in BookingDetail tab)
    - Display three columns: to_do, in_progress, done
    - Implement drag-and-drop between columns
    - Highlight overdue tasks (due_date < today and status != done)
    - Show task cards with title, description, due_date, priority
    - _Requirements: 26.1, 26.2, 26.3, 26.4_
  
  - [x] 30.5 Create TaskFormComponent with create/edit modes
    - Implement form for custom tasks with title, description, priority, due_date
    - Support two modes: create, edit
    - **Section 1: Task Details** - gradient header `blue-50 to indigo-50`, icon `pi-check-square`
      - Fields: title, description, priority, due_date
      - Use p-dropdown with size="small" for priority
      - Use p-calendar with size="small" for due_date
    - In edit mode: enable fields with "Save" and "Cancel" buttons in header actions
    - In create mode: enable fields with "Add Task" and "Cancel" buttons in header actions
    - Use size="small" for all PrimeNG components
    - Form actions footer with info text and action buttons using app-action-button
    - _Requirements: 26.6, 5.1, 5.2, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6, 40.7, 40.8, 40.9, 40.10_
  
  - [ ]* 30.6 Write unit tests for task management
    - Test completion percentage calculation
    - Test overdue task identification
    - Test drag-and-drop status update
    - _Requirements: 26.1, 26.3, 26.4_

- [ ] 31. Checkpoint - Agency Portal Booking Features Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 32. Agency Portal - Notification Configuration
  - [ ] 32.1 Create notification models
    - Define NotificationSchedule, NotificationTemplate interfaces
    - _Requirements: 27.1, 28.1_
  
  - [ ] 32.2 Create NotificationApiService
    - Implement schedule and template CRUD methods
    - _Requirements: 27.1, 28.1_
  
  - [ ] 32.3 Create notification NGXS store
    - Create notification.model.ts (NotificationStateModel interface)
    - Create notification.actions.ts (LoadSchedules, LoadTemplates, CreateSchedule, CreateTemplate, ToggleSchedule)
    - Create notification.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register NotificationState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 32.4 Create NotificationScheduleListComponent
    - Display schedules in DataTableComponent
    - Show name, trigger_days_before, notification_type, template_name, is_enabled
    - Provide toggle for enabling/disabling schedules
    - _Requirements: 27.1, 27.4_
  
  - [ ] 32.5 Create NotificationScheduleFormComponent with view/edit/create modes
    - Implement form with name, trigger_days_before, notification_type, template_id
    - Support three modes: view, edit, create
    - **Section 1: Schedule Configuration** - gradient header `blue-50 to indigo-50`, icon `pi-clock`
      - Fields: name, trigger_days_before, notification_type, template_id
      - Use p-dropdown with size="small" for all dropdowns
      - Support trigger_days_before values: 30, 14, 7, 3, 1
    - In view mode: display read-only fields with "Edit" and "Back" buttons in header actions
    - In edit mode: enable fields with "Save" and "Cancel" buttons in header actions
    - In create mode: enable fields with "Create" and "Cancel" buttons in header actions
    - Use size="small" for all PrimeNG components
    - Show confirmation dialog on Cancel with unsaved changes
    - Form actions footer with info text and action buttons using app-action-button
    - _Requirements: 27.2, 27.3, 5.1, 5.2, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6, 40.7, 40.8, 40.9, 40.10_
  
  - [ ] 32.6 Create NotificationTemplateListComponent
    - Display templates in DataTableComponent
    - Show name, subject
    - _Requirements: 28.1_
  
  - [ ] 32.7 Create NotificationTemplateFormComponent with view/edit/create modes
    - Implement form with name, subject, body
    - Support three modes: view, edit, create
    - **Section 1: Template Information** - gradient header `blue-50 to indigo-50`, icon `pi-file-edit`
      - Fields: name, subject
    - **Section 2: Template Content** - gradient header `green-50 to emerald-50`, icon `pi-align-left`
      - Field: body (textarea)
      - Display available variables: customer_name, package_name, departure_date, return_date, booking_reference
      - Provide variable insertion buttons
    - **Section 3: Preview** - gradient header `purple-50 to pink-50`, icon `pi-eye`
      - Show template preview with sample data
    - In view mode: display read-only fields with "Edit" and "Back" buttons in header actions
    - In edit mode: enable fields with "Save" and "Cancel" buttons in header actions
    - In create mode: enable fields with "Create" and "Cancel" buttons in header actions
    - Use size="small" for all PrimeNG components
    - Show confirmation dialog on Cancel with unsaved changes
    - Form actions footer with info text and action buttons using app-action-button
    - _Requirements: 28.2, 28.3, 28.4, 28.5, 40.1, 40.2, 40.3, 40.4, 40.5, 40.6, 40.7, 40.8, 40.9, 40.10_
  
  - [ ]* 32.8 Write unit tests for notification components
    - Test schedule enable/disable
    - Test template variable insertion
    - _Requirements: 27.4, 28.4_

- [ ] 33. Agency Portal - Payment Tracking
  - [ ] 33.1 Create payment models
    - Define PaymentSchedule, PaymentTransaction, PaymentStatus, PaymentMethod interfaces
    - _Requirements: 29.1_
  
  - [ ] 33.2 Create PaymentApiService
    - Implement getByBookingId(), recordPayment() methods
    - _Requirements: 29.1_
  
  - [ ] 33.3 Create payment NGXS store
    - Create payment.model.ts (PaymentStateModel interface)
    - Create payment.actions.ts (LoadPaymentSchedules, RecordPayment)
    - Create payment.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register PaymentState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 33.4 Create PaymentScheduleComponent (in BookingDetail tab)
    - Display payment schedules in DataTableComponent
    - Show installment_name, due_date, amount, paid_amount, status
    - Highlight overdue payments (due_date < today and status = pending)
    - Display total outstanding amount
    - Provide "Record Payment" button
    - _Requirements: 29.1, 29.2, 29.5_
  
  - [ ] 33.5 Create PaymentRecordDialogComponent
    - Implement form with amount, payment_method, payment_date, reference_number
    - Use p-dropdown with size="small" for payment_method
    - Use p-calendar with size="small" for payment_date
    - Update payment schedule status after recording
    - _Requirements: 29.3, 29.4, 5.1, 5.2_
  
  - [ ]* 33.6 Write unit tests for payment tracking
    - Test overdue payment identification
    - Test outstanding amount calculation
    - Test payment status update logic
    - _Requirements: 29.2, 29.4, 29.5_

- [ ] 34. Agency Portal - Itinerary Builder
  - [ ] 34.1 Create itinerary models
    - Define Itinerary, ItineraryDay, ItineraryActivity, MealType interfaces
    - _Requirements: 30.1_
  
  - [ ] 34.2 Create ItineraryApiService
    - Implement getByPackageId(), addDay(), addActivity(), update() methods
    - _Requirements: 30.1_
  
  - [ ] 34.3 Create itinerary NGXS store
    - Create itinerary.model.ts (ItineraryStateModel interface)
    - Create itinerary.actions.ts (LoadItinerary, AddDay, AddActivity, UpdateItinerary)
    - Create itinerary.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register ItineraryState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 34.4 Create ItineraryBuilderComponent (in PackageDetail tab)
    - Display day-by-day breakdown
    - Provide "Add Day" button
    - For each day, show title, description, and activities list
    - Provide "Add Activity" button for each day
    - Support drag-and-drop for reordering days and activities
    - _Requirements: 30.1, 30.2, 30.5_
  
  - [ ] 34.5 Create ItineraryDayFormComponent
    - Implement form with day_number, title, description
    - Use class="p-inputtext-sm" for inputs
    - Use textarea with class="p-inputtext-sm" for description
    - _Requirements: 30.2, 5.1_
  
  - [ ] 34.6 Create ItineraryActivityFormComponent
    - Implement form with time, location, activity, description, meal_type
    - Use p-dropdown with size="small" for meal_type
    - Support meal_type values: breakfast, lunch, dinner, snack, none
    - _Requirements: 30.3, 30.4, 5.1, 5.2_
  
  - [ ]* 34.7 Write unit tests for itinerary builder
    - Test day and activity creation
    - Test drag-and-drop reordering
    - _Requirements: 30.2, 30.3, 30.5_

- [ ] 35. Agency Portal - Supplier Bills and Payables
  - [ ] 35.1 Create supplier bill models
    - Define SupplierBill, SupplierPayment interfaces
    - _Requirements: 31.1_
  
  - [ ] 35.2 Create SupplierBillApiService
    - Implement getAll(), getById(), recordPayment() methods
    - _Requirements: 31.1_
  
  - [ ] 35.3 Create supplier bill NGXS store
    - Create supplier-bill.model.ts (SupplierBillStateModel interface)
    - Create supplier-bill.actions.ts (LoadSupplierBills, RecordSupplierPayment)
    - Create supplier-bill.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register SupplierBillState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 35.4 Create SupplierBillListComponent
    - Display bills in DataTableComponent
    - Show bill_number, supplier_name, bill_date, due_date, total_amount, paid_amount, status
    - Filter by status (unpaid, partially_paid, paid)
    - Highlight overdue bills (due_date < today and status = unpaid)
    - Display total outstanding payables
    - Provide "Record Payment" button
    - _Requirements: 31.1, 31.2, 31.3, 31.5_
  
  - [ ] 35.5 Create SupplierPaymentDialogComponent
    - Implement form with amount, payment_method, payment_date, reference_number
    - Use p-dropdown with size="small" for payment_method
    - Use p-calendar with size="small" for payment_date
    - _Requirements: 31.4, 5.1, 5.2_
  
  - [ ]* 35.6 Write unit tests for supplier bill management
    - Test overdue bill identification
    - Test outstanding payables calculation
    - _Requirements: 31.3, 31.5_

- [ ] 36. Agency Portal - Communication Log
  - [ ] 36.1 Create communication log models
    - Define CommunicationLog interface
    - _Requirements: 32.1_
  
  - [ ] 36.2 Create CommunicationLogApiService
    - Implement getByCustomerId(), create(), markFollowUpDone() methods
    - _Requirements: 32.1_
  
  - [ ] 36.3 Create communication log NGXS store
    - Create communication-log.model.ts (CommunicationLogStateModel interface)
    - Create communication-log.actions.ts (LoadCommunicationLogs, CreateCommunicationLog, MarkFollowUpDone)
    - Create communication-log.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register CommunicationLogState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 36.4 Create CommunicationLogComponent (in CustomerDetail)
    - Display logs in DataTableComponent
    - Show communication_type, subject, notes, follow_up_date, follow_up_done
    - Filter by follow_up_required and follow_up_done
    - Provide "Mark as Done" button for follow-ups
    - _Requirements: 32.1, 32.4, 32.5_
  
  - [ ] 36.5 Create CommunicationLogFormComponent
    - Implement form with communication_type, subject, notes, follow_up_required, follow_up_date
    - Use p-dropdown with size="small" for communication_type
    - Use p-calendar with size="small" for follow_up_date
    - Support communication_type values: call, email, whatsapp, meeting, other
    - _Requirements: 32.2, 32.3, 5.1, 5.2_
  
  - [ ]* 36.6 Write unit tests for communication log
    - Test filtering by follow-up status
    - Test mark as done functionality
    - _Requirements: 32.4, 32.5_

- [ ] 37. Checkpoint - Agency Portal Extended Features Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 38. Agency Portal - B2B Marketplace Service Publishing
  - [ ] 38.1 Create marketplace models
    - Define AgencyService, AgencyOrder, AgencyOrderStatus interfaces
    - _Requirements: 33.1, 35.1_
  
  - [ ] 38.2 Create MarketplaceApiService
    - Implement publishService(), unpublishService(), getMarketplaceServices(), createOrder(), approveOrder(), rejectOrder() methods
    - _Requirements: 33.1, 34.1, 35.1_
  
  - [ ] 38.3 Create marketplace NGXS store
    - Create marketplace.model.ts (MarketplaceStateModel interface)
    - Create marketplace.actions.ts (PublishService, UnpublishService, LoadMarketplaceServices, CreateOrder, ApproveOrder, RejectOrder)
    - Create marketplace.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register MarketplaceState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 38.4 Create AgencyServiceListComponent
    - Display agency services in DataTableComponent
    - Show service_type, name, cost_price, reseller_price, markup_percentage, total_quota, available_quota, is_published
    - Provide toggle for publishing/unpublishing
    - _Requirements: 33.1, 33.5_
  
  - [ ] 38.5 Create AgencyServiceFormComponent
    - Implement form with po_id, service_type, name, description, cost_price, reseller_price, total_quota
    - Validate reseller_price > cost_price with minimum 5% markup
    - Calculate markup_percentage automatically
    - Use class="p-inputtext-sm" for inputs
    - Use p-dropdown with size="small" for dropdowns
    - _Requirements: 33.2, 33.3, 33.4, 5.1, 5.2_
  
  - [ ]* 38.6 Write property test for marketplace pricing validation
    - **Property 8: Positive Price Validation** (applied to reseller_price)
    - Test reseller_price > cost_price with 5% minimum markup
    - **Validates: Requirements 33.3**
  
  - [ ] 38.3 Create marketplace NGXS store
    - Create marketplace.model.ts (MarketplaceStateModel interface)
    - Create marketplace.actions.ts (PublishService, UnpublishService, LoadMarketplaceServices, CreateOrder, ApproveOrder, RejectOrder)
    - Create marketplace.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register MarketplaceState in app.config.ts
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

- [ ] 39. Agency Portal - B2B Marketplace Service Browsing
  - [ ] 39.1 Create MarketplaceBrowseComponent
    - Display marketplace services in DataTableComponent
    - Show service_type, name, description, reseller_price, available_quota, seller_agency_name
    - Do NOT display supplier information or cost_price
    - Filter by service_type
    - Provide "Add to Cart" button
    - Maintain cart state in NGXS store
    - _Requirements: 34.1, 34.2, 34.3, 34.4_
  
  - [ ] 39.2 Create MarketplaceCartComponent
    - Display cart items with quantity, unit_price, total_price
    - Calculate total order amount
    - Validate quantity <= available_quota
    - Provide "Create Order" button
    - Clear cart after successful order creation
    - _Requirements: 35.2, 35.3, 35.4, 35.5_
  
  - [ ]* 39.3 Write unit tests for marketplace cart
    - Test add to cart, remove from cart
    - Test quantity validation against available_quota
    - Test total calculation
    - _Requirements: 35.3, 35.4_

- [ ] 40. Agency Portal - B2B Marketplace Order Management
  - [ ] 40.1 Create IncomingOrderListComponent (for Agency A - seller)
    - Display incoming orders in DataTableComponent
    - Show order_number, buyer_agency_name, service_name, quantity, total_price, status
    - Filter by status (pending, approved, rejected)
    - Provide approve/reject buttons for pending orders
    - Use confirmation dialog for approve/reject
    - _Requirements: 36.1, 36.2, 36.5_
  
  - [ ] 40.2 Create OutgoingOrderListComponent (for Agency B - buyer)
    - Display outgoing orders in DataTableComponent
    - Show order_number, seller_agency_name, service_name, quantity, total_price, status
    - Filter by status
    - _Requirements: 35.1_
  
  - [ ]* 40.3 Write unit tests for order management
    - Test approve/reject with confirmation
    - Test order filtering by status
    - _Requirements: 36.2, 36.5_

- [ ] 41. Agency Portal - Profitability Tracking
  - [ ] 41.1 Create profitability models
    - Define BookingProfitability interface
    - _Requirements: 37.1_
  
  - [ ] 41.2 Create ProfitabilityApiService
    - Implement getDashboard(), getBookingProfitability() methods
    - _Requirements: 37.1_
  
  - [ ] 41.3 Create profitability NGXS store
    - Create profitability.model.ts (ProfitabilityStateModel interface)
    - Create profitability.actions.ts (LoadProfitabilityDashboard, LoadBookingProfitability)
    - Create profitability.state.ts with @State decorator and @Action handlers
    - Add @Selector static methods for state selection
    - Register ProfitabilityState in app.config.ts
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_
  
  - [ ] 41.4 Create ProfitabilityDashboardComponent
    - Display total revenue, total cost, total profit, average margin percentage
    - Display profit trends chart
    - Display top 10 most profitable bookings table
    - Display low margin bookings table (margin < 10%)
    - Provide filters for package_type and date range
    - _Requirements: 37.1, 37.2, 37.3, 37.4, 37.5_
  
  - [ ] 41.5 Create BookingProfitabilityDetailComponent
    - Display booking revenue, cost, gross_profit, gross_margin_percentage
    - Show breakdown of costs (services from POs and agency orders)
    - _Requirements: 37.6_
  
  - [ ]* 41.6 Write unit tests for profitability calculations
    - Test revenue, cost, profit, margin calculations
    - Test low margin identification (< 10%)
    - _Requirements: 37.1, 37.4_

- [ ] 42. Checkpoint - Agency Portal B2B and Profitability Complete
  - Ensure all tests pass, ask the user if questions arise.


- [ ] 43. Responsive Design and Mobile Optimization
  - [ ] 43.1 Implement responsive navigation
    - Display hamburger menu icon on mobile devices
    - Implement collapsible sidebar for mobile
    - _Requirements: 43.2_
  
  - [ ] 43.2 Optimize forms for mobile
    - Stack form fields vertically on mobile devices
    - Ensure touch-friendly input sizes
    - _Requirements: 43.3_
  
  - [ ] 43.3 Optimize tables for mobile
    - Make data tables horizontally scrollable on mobile
    - Consider card view for mobile table display
    - _Requirements: 38.4_
  
  - [ ]* 43.4 Write responsive design tests
    - Test navigation menu display at different breakpoints
    - Test form layout at different breakpoints
    - Test table scrolling on mobile
    - _Requirements: 38.2, 38.3, 38.4_

  - [ ] 43.3 Optimize tables for mobile
    - Make data tables horizontally scrollable on mobile
    - Consider card view for mobile table display
    - _Requirements: 43.4_
  
  - [ ]* 43.4 Write responsive design tests
    - Test navigation menu display at different breakpoints
    - Test form layout at different breakpoints
    - Test table scrolling on mobile
    - _Requirements: 43.2, 43.3, 43.4_

- [ ] 44. Toast Notification System
  - [ ] 44.1 Configure PrimeNG Toast globally
    - Add p-toast to MainLayoutComponent
    - Configure toast position and styling
    - _Requirements: 44.1_
  
  - [ ] 44.2 Implement toast notification properties
    - Ensure success toasts use green background (severity: success)
    - Ensure error toasts use red background (severity: error)
    - Ensure warning toasts use yellow background (severity: warning)
    - Ensure info toasts use blue background (severity: info)
    - Configure auto-dismiss after 5 seconds (life: 5000)
    - Enable manual dismissal with close button
    - _Requirements: 44.2, 44.3, 44.4, 44.5, 44.6, 44.7_
  
  - [ ]* 44.3 Write property tests for toast notifications
    - **Property 14: Toast Notification Severity**
    - **Property 15: Toast Auto-Dismissal**
    - **Property 16: Toast Manual Dismissal**
    - **Validates: Requirements 44.2, 44.3, 44.4, 44.5, 44.6, 44.7**

- [ ] 45. Form Validation System
  - [ ] 45.1 Create validation utility functions
    - Implement email format validator
    - Implement phone format validator
    - Implement date range validator
    - Implement positive number validator
    - _Requirements: 42.4, 42.5, 15.3, 15.4_
  
  - [ ] 45.2 Create form error display component
    - Display validation errors below form fields in red text
    - Show appropriate error messages for each validation type
    - _Requirements: 42.2, 42.3, 42.4, 42.5_
  
  - [ ] 45.3 Implement form submit button state management
    - Disable submit button when form is invalid
    - Enable submit button when form is valid
    - _Requirements: 42.6_
  
  - [ ]* 45.4 Write property tests for form validation
    - **Property 9: Form Validation Error Display**
    - **Property 10: Required Field Validation**
    - **Property 11: Email Format Validation**
    - **Property 12: Phone Format Validation**
    - **Property 13: Form Submission Error Feedback**
    - **Validates: Requirements 42.2, 42.3, 42.4, 42.5, 42.6, 42.7**

- [ ] 46. Error Handling and Logging
  - [ ] 46.1 Implement GlobalErrorHandler
    - Catch runtime errors
    - Display user-friendly error messages
    - Log technical details to console
    - _Requirements: 45.6_
  
  - [ ] 46.2 Enhance ErrorInterceptor with comprehensive error mapping
    - Map 400 Bad Request to validation errors
    - Map 401 Unauthorized to login redirect
    - Map 403 Forbidden to permission error
    - Map 404 Not Found to resource not found error
    - Map 500 Internal Server Error to generic error
    - Log all errors to console
    - _Requirements: 45.1, 45.2, 45.3, 45.4, 45.5, 45.6_
  
  - [ ]* 46.3 Write property test for error logging
    - **Property 17: Error Logging**
    - **Validates: Requirements 45.6**

- [ ] 47. Integration and Wiring
  - [ ] 47.1 Configure root NGXS store
    - Register all feature states in app.config.ts using provideStore([...states])
    - Include: AuthState, AgencyState, SupplierState, SubscriptionPlanState, CommissionState, RevenueState, ServiceState, PurchaseOrderState, PackageState, JourneyState, CustomerState, BookingState, DocumentState, TaskState, NotificationState, PaymentState, ItineraryState, SupplierBillState, CommunicationLogState, MarketplaceState, ProfitabilityState
    - Configure NGXS DevTools plugin using withNgxsReduxDevtoolsPlugin() for development
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
    - _Requirements: 44.1, 45.6_
  
  - [ ]* 47.5 Write integration tests
    - Test complete authentication flow
    - Test complete booking creation flow
    - Test error handling across features
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 22.1, 22.2_

- [ ] 48. Final Checkpoint - Complete Application
  - Ensure all tests pass, ask the user if questions arise.
  - Verify all features are integrated and working
  - Verify responsive design on mobile devices
  - Verify error handling and toast notifications
  - Verify form validation across all forms

- [ ] 49. Public Landing Page
  - [ ] 49.1 Create landing page layout component
    - Create LandingLayoutComponent with header and footer
    - Use standalone component architecture
    - Configure route for root path (/)
    - _Requirements: 47.1, 47.8_
  
  - [ ] 49.2 Create landing page navigation component
    - Create LandingNavComponent with logo, Login button, and Register button
    - Use sticky navigation on scroll
    - Implement mobile hamburger menu
    - Use Lucide icons for menu icon
    - _Requirements: 47.8, 47.6_
  
  - [ ] 49.3 Create hero section component
    - Display "Jourva" platform name with large typography
    - Display tagline: "Complete Travel Agency ERP & B2B Marketplace"
    - Add "Login" and "Register as Supplier" CTA buttons
    - Use gradient background with modern design
    - Implement responsive layout (stack on mobile)
    - _Requirements: 47.2, 47.6, 47.7_
  
  - [ ] 49.4 Create features section component
    - Display 4 feature cards in grid layout (2x2 on desktop, 1 column on mobile)
    - Feature 1: Agency Management (icon, title, description)
    - Feature 2: Supplier Network (icon, title, description)
    - Feature 3: B2B Marketplace (icon, title, description)
    - Feature 4: Booking Management (icon, title, description)
    - Use Lucide icons for each feature
    - Apply card hover effects
    - _Requirements: 47.3, 47.6, 47.7_
  
  - [ ] 49.5 Create benefits section component
    - Display 3 benefit cards for different user types
    - Benefit 1: For Platform Admins (manage agencies, track revenue)
    - Benefit 2: For Travel Agencies (create packages, manage bookings)
    - Benefit 3: For Suppliers (publish services, receive orders)
    - Use icon, title, and bullet points for each benefit
    - Implement responsive grid layout
    - _Requirements: 47.4, 47.6, 47.7_
  
  - [ ] 49.6 Create footer component
    - Display company name "Jourva"
    - Add links: About, Features, Contact, Privacy Policy, Terms of Service
    - Display contact information (email, phone)
    - Add social media icons (optional placeholders)
    - Use responsive layout (stack on mobile)
    - _Requirements: 47.5, 47.6_
  
  - [ ] 49.7 Implement smooth scroll and animations
    - Add smooth scroll behavior for anchor links
    - Implement fade-in animations on scroll using Intersection Observer
    - Add hover animations for buttons and cards
    - Optimize animation performance
    - _Requirements: 47.9_
  
  - [ ] 49.8 Optimize landing page assets
    - Use optimized image formats (WebP with fallbacks)
    - Implement lazy loading for images
    - Minimize CSS and ensure fast initial load
    - Test page load performance
    - _Requirements: 47.10_
  
  - [ ]* 49.9 Write unit tests for landing page components
    - Test navigation component rendering and interactions
    - Test responsive behavior at different breakpoints
    - Test CTA button click events
    - _Requirements: 47.1, 47.6, 47.8_

- [ ] 50. Final Checkpoint - Complete Application with Landing Page
  - Ensure all tests pass, ask the user if questions arise.
  - Verify landing page is accessible at root URL
  - Verify responsive design on mobile devices
  - Verify smooth scroll and animations work properly
  - Verify Login button redirects to login page
  - Verify all features are integrated and working

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


---

## Self-Registration with KYC Verification Tasks

- [ ] 51. Self-Registration & KYC - Models and Interfaces
  - [ ] 51.1 Create document models
    - Create EntityDocument interface with all properties
    - Create DocumentProgress interface
    - Create DocumentUploadRequest and DocumentUploadResponse interfaces
    - _Requirements: 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63_
  
  - [ ] 51.2 Create registration models
    - Create AgencyRegistrationRequest interface
    - Create SupplierRegistrationRequest interface with service_types array
    - Create RegistrationResponse interface
    - _Requirements: 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63_
  
  - [ ] 51.3 Create verification models
    - Create VerificationQueueItem interface
    - Create EntityVerificationDetail interface
    - _Requirements: 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63_

- [ ] 52. Self-Registration & KYC - Core Services
  - [ ] 52.1 Implement DocumentService
    - Create getDocuments() method
    - Create getDocumentProgress() method
    - Create uploadDocument() method with progress tracking
    - Create downloadDocument() method
    - Create deleteDocument() method
    - Use HttpClient with observe: 'events' for upload progress
    - _Requirements: 54, 55, 56, 57, 58_
  
  - [ ] 52.2 Implement VerificationService
    - Create getVerificationQueue() method with filters
    - Create getEntityVerificationDetail() method
    - Create verifyDocument() method
    - Create rejectDocument() method
    - Create approveEntity() method
    - Create rejectEntity() method
    - _Requirements: 59, 60, 61, 62, 63_
  
  - [ ] 52.3 Create file validation utility
    - Create validateFileSize() function (max 10MB)
    - Create validateFileExtension() function (.pdf, .jpg, .jpeg, .png, .doc, .docx)
    - Create getFileExtension() helper
    - Create formatFileSize() helper
    - _Requirements: 54, 55_

- [ ] 53. Self-Registration & KYC - NGXS Store
  - [ ] 53.1 Create document actions
    - Create LoadDocuments action
    - Create LoadProgress action
    - Create UploadDocument action with file and documentType
    - Create DeleteDocument action
    - _Requirements: 54, 55, 56, 57, 58_
  
  - [ ] 53.2 Implement DocumentState
    - Create DocumentStateModel with documents, progress, loading, uploadProgress
    - Implement LoadDocuments action handler
    - Implement LoadProgress action handler
    - Implement UploadDocument action handler with progress tracking
    - Create selectors: documents, progress, loading, uploadProgress
    - _Requirements: 54, 55, 56, 57, 58_

- [ ] 54. Self-Registration & KYC - Route Guards
  - [ ] 54.1 Implement VerificationGuard
    - Check user authentication status
    - Check user verification_status from JWT token
    - Allow platform_admin to access all routes
    - Redirect unverified users to /documents/upload
    - Allow verified users to access all routes
    - _Requirements: 53, 54, 55, 56, 57, 58_
  
  - [ ]* 54.2 Write unit tests for VerificationGuard
    - Test platform_admin access
    - Test verified user access
    - Test unverified user redirect
    - _Requirements: 53_

- [ ] 55. Self-Registration & KYC - Agency Registration
  - [ ] 55.1 Create AgencyRegistrationComponent
    - Create reactive form with fields: company_name, owner_name, email, phone, business_type, password, confirm_password
    - Implement password match validator
    - Add business_type dropdown with options: PT, CV, Individual
    - Implement form validation with error messages
    - Call AuthService.registerAgency() on submit
    - Show loading state during submission
    - Redirect to document upload page on success
    - _Requirements: 51, 52_
  
  - [ ] 55.2 Create agency registration template
    - Use PrimeNG form components (InputText, Dropdown, Password)
    - Apply TailwindCSS styling for responsive layout
    - Display validation errors below each field
    - Add "Already have an account? Sign in" link
    - Use p-inputtext-sm class for inputs
    - Use size="small" for all PrimeNG components
    - _Requirements: 51, 52_
  
  - [ ] 55.3 Add agency registration route
    - Add route /auth/register/agency
    - Use auth layout
    - Configure lazy loading
    - _Requirements: 51_

- [ ] 56. Self-Registration & KYC - Supplier Registration
  - [ ] 56.1 Create SupplierRegistrationComponent
    - Create reactive form with all supplier fields including service_types
    - Add service_types multi-select with options: hotel, flight, visa, transport, guide, insurance, catering, handling
    - Implement form validation
    - Call AuthService.registerSupplier() on submit
    - Show loading state during submission
    - Redirect to document upload page on success
    - _Requirements: 51, 52_
  
  - [ ] 56.2 Create supplier registration template
    - Use PrimeNG form components (InputText, MultiSelect, Password)
    - Apply responsive grid layout for address fields
    - Display validation errors
    - Add "Already have an account? Sign in" link
    - Use p-inputtext-sm class for inputs
    - Use size="small" for all PrimeNG components
    - _Requirements: 51, 52_
  
  - [ ] 56.3 Add supplier registration route
    - Add route /auth/register/supplier
    - Use auth layout
    - Configure lazy loading
    - _Requirements: 51_

- [ ] 57. Self-Registration & KYC - Document Upload Components
  - [ ] 57.1 Create DocumentUploadButtonComponent
    - Accept @Input() documentType and currentStatus
    - Emit @Output() fileSelected event
    - Show "Upload" button if no file uploaded
    - Show "Re-upload" button if file rejected
    - Show "Uploaded" disabled button if file pending/verified
    - Implement file input with hidden input element
    - Validate file before emitting event
    - _Requirements: 54, 55_
  
  - [ ] 57.2 Create DocumentPreviewModalComponent
    - Accept @Input() document
    - Display document preview using iframe for PDF
    - Display image preview for JPG/PNG
    - Show "Download" button
    - Show "Close" button
    - Use PrimeNG Dialog component
    - _Requirements: 56_
  
  - [ ] 57.3 Create DocumentChecklistComponent
    - Accept @Input() documents array
    - Emit @Output() fileSelected event
    - Display documents in PrimeNG Table
    - Show columns: Document, Category, Required, Status, File, Actions
    - Display status badges with appropriate colors
    - Show rejection reason if rejected
    - Use DocumentUploadButtonComponent for upload actions
    - Add preview button for uploaded documents
    - Use styleClass="p-datatable-sm"
    - _Requirements: 54, 55, 56_
  
  - [ ] 57.4 Create DocumentProgressWidgetComponent
    - Accept @Input() progress
    - Display completion percentage with ProgressBar
    - Show uploaded, verified, rejected counts in grid
    - Display verification status badge
    - Show verification attempts count
    - Display status-specific messages (awaiting approval, verified, rejected)
    - Show "can resubmit" warning if max attempts reached
    - Use PrimeNG Card component
    - _Requirements: 54, 55, 57, 58_

- [ ] 58. Self-Registration & KYC - Document Upload Page
  - [ ] 58.1 Create DocumentUploadComponent
    - Inject Store and dispatch LoadDocuments, LoadProgress actions
    - Select documents$ and progress$ from store
    - Implement onFileSelected() handler
    - Dispatch UploadDocument action on file selection
    - Show success/error toast notifications
    - _Requirements: 54, 55, 56, 57, 58_
  
  - [ ] 58.2 Create document upload template
    - Display page header with title and description
    - Show DocumentProgressWidgetComponent
    - Show DocumentChecklistComponent in Card
    - Display help text with file requirements
    - Use responsive layout
    - _Requirements: 54, 55, 56, 57, 58_
  
  - [ ] 58.3 Add document upload route
    - Add route /documents/upload
    - Protect with AuthGuard
    - Use main layout
    - Configure lazy loading
    - _Requirements: 54_

- [ ] 59. Self-Registration & KYC - Platform Admin Verification Queue
  - [ ] 59.1 Create VerificationQueueComponent
    - Inject VerificationService
    - Load verification queue on init
    - Implement filters: entity_type, verification_status, date range
    - Display queue in PrimeNG Table with pagination
    - Show columns: Entity Code, Company Name, Owner Name, Email, Status, Documents Progress, Created At, Actions
    - Add "View Details" button for each item
    - Implement onFilterChange() to reload queue
    - Use styleClass="p-datatable-sm"
    - _Requirements: 59, 60_
  
  - [ ] 59.2 Create verification queue template
    - Display page header with title
    - Show filter controls (dropdowns for entity_type and status, calendar for dates)
    - Display queue table
    - Show loading spinner while loading
    - Use responsive layout
    - _Requirements: 59, 60_
  
  - [ ] 59.3 Add verification queue route
    - Add route /admin/verification-queue
    - Protect with AuthGuard and RoleGuard (platform_admin only)
    - Use main layout
    - Configure lazy loading
    - _Requirements: 59_

- [ ] 60. Self-Registration & KYC - Entity Verification Detail
  - [ ] 60.1 Create EntityVerificationDetailComponent
    - Inject VerificationService and ActivatedRoute
    - Load entity verification detail on init using route params
    - Display entity information (company name, owner, email, phone, business type, etc.)
    - Display documents table with verification actions
    - Implement verifyDocument() method
    - Implement rejectDocument() method with rejection reason dialog
    - Implement approveEntity() method with confirmation
    - Implement rejectEntity() method with rejection reason dialog
    - Show success/error toast notifications
    - _Requirements: 60, 61, 62, 63_
  
  - [ ] 60.2 Create VerificationActionsComponent
    - Accept @Input() document
    - Emit @Output() verify and reject events
    - Show "Verify" button (green) for pending documents
    - Show "Reject" button (red) for pending documents
    - Show "Verified" badge for verified documents
    - Show "Rejected" badge with reason for rejected documents
    - Use size="small" for buttons
    - _Requirements: 61, 62_
  
  - [ ] 60.3 Create entity verification detail template
    - Display page header with entity code and company name
    - Show entity information card
    - Show documents table with VerificationActionsComponent
    - Add "Approve Entity" button (only if all mandatory docs verified)
    - Add "Reject Entity" button
    - Show document preview modal
    - Use responsive layout
    - _Requirements: 60, 61, 62, 63_
  
  - [ ] 60.4 Add entity verification detail route
    - Add route /admin/verification/:entityType/:entityId
    - Protect with AuthGuard and RoleGuard (platform_admin only)
    - Use main layout
    - Configure lazy loading
    - _Requirements: 60_

- [ ] 61. Self-Registration & KYC - Integration and Testing
  - [ ] 61.1 Update AuthService with registration methods
    - Add registerAgency() method
    - Add registerSupplier() method
    - Return RegistrationResponse with redirect_url
    - _Requirements: 51, 52_
  
  - [ ] 61.2 Update JWT token interface
    - Add verification_status field to JwtPayload
    - Update token decoding in AuthService
    - _Requirements: 53_
  
  - [ ] 61.3 Apply VerificationGuard to protected routes
    - Add VerificationGuard to all agency routes except /documents/upload
    - Add VerificationGuard to all supplier routes except /documents/upload
    - Ensure platform_admin can access all routes
    - _Requirements: 53_
  
  - [ ] 61.4 Test complete registration flow
    - Test agency registration → login → document upload → verification
    - Test supplier registration → login → document upload → verification
    - Test platform admin verification workflow
    - Test document rejection and re-upload
    - Test max verification attempts limit
    - _Requirements: 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63_
  
  - [ ]* 61.5 Write integration tests for registration flow
    - Test end-to-end agency registration
    - Test end-to-end supplier registration
    - Test document upload with progress tracking
    - _Requirements: 51, 52, 54, 55_
  
  - [ ]* 61.6 Write unit tests for document components
    - Test DocumentChecklistComponent rendering
    - Test DocumentProgressWidgetComponent calculations
    - Test DocumentUploadButtonComponent file validation
    - _Requirements: 54, 55, 56, 57_

- [ ] 62. Self-Registration & KYC - Final Checkpoint
  - Verify agency registration form works correctly
  - Verify supplier registration form works correctly
  - Verify document upload with progress tracking
  - Verify document preview functionality
  - Verify platform admin verification queue
  - Verify entity verification detail page
  - Verify document verification actions
  - Verify entity approval/rejection
  - Verify VerificationGuard redirects unverified users
  - Verify all toast notifications display correctly
  - Verify responsive design on mobile devices
  - Ensure all tests pass, ask the user if questions arise

