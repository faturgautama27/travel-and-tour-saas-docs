# Implementation Plan: Phase 1 Frontend

**Feature:** Tour & Travel ERP SaaS - Frontend Application

**Tech Stack:** Angular 20 + PrimeNG 20 + TailwindCSS 4 + NgRx

**Duration:** 10 weeks (Feb 11 - Apr 26, 2026)

---

## 📍 Navigation

- 🏠 [Back to Phase 1](../PHASE-1-COMPLETE-DOCUMENTATION.md)
- 📋 [Requirements Document](requirements.md)
- 📐 [Design Document](design.md)

---

## Overview

This implementation plan breaks down the frontend development into 10 weeks of work, organized by feature and role. Each task builds incrementally, ensuring continuous integration and early validation of core functionality.

The plan follows a role-by-role implementation approach:
- **Week 1-2**: Project setup, core infrastructure, and authentication
- **Week 3**: Platform Admin features
- **Week 4**: Supplier features
- **Week 5-6**: Agency features (most complex)
- **Week 7**: Traveler features
- **Week 8**: State management and integration
- **Week 9**: Testing and bug fixes
- **Week 10**: Polish, optimization, and demo preparation

---

## Tasks


### Week 1: Project Setup & Core Infrastructure (Feb 11-17)

- [ ] 1. Initialize Angular 20 project with standalone components
  - Create new Angular project with routing and SCSS
  - Configure TypeScript strict mode
  - Set up project structure following ibis-frontend-main pattern
  - _Requirements: 4.1, 4.2_

- [ ] 2. Install and configure dependencies
  - Install PrimeNG 20, @primeng/themes, primeicons
  - Install TailwindCSS 4, postcss, autoprefixer
  - Install NgRx (store, effects, store-devtools)
  - Install Lucide Angular for icons
  - Install RxJS
  - _Requirements: 4.1_

- [ ] 3. Configure TailwindCSS 4
  - Set up tailwind.config.js with custom theme
  - Configure content paths for Angular templates
  - Add custom color palette (primary, secondary)
  - Set up global styles in styles.scss
  - _Requirements: 4.1, 8.1_

- [ ] 4. Configure PrimeNG 20 theme
  - Set up Aura theme in app.config.ts
  - Configure CSS layer ordering
  - Import PrimeNG styles in styles.scss
  - Test basic PrimeNG components
  - _Requirements: 4.1, 8.2_

- [ ] 5. Set up folder structure
  - Create core/ directory (guards, interceptors, services, models)
  - Create shared/ directory (components, pipes, utils)
  - Create features/ directory (auth, platform-admin, supplier, agency, traveler)
  - Create layouts/ directory (main-layout, auth-layout, components)
  - Create store/ directory (auth, agency, supplier, package, booking)
  - Create environments/ directory
  - _Requirements: 3_

- [ ] 6. Configure environment files
  - Set up environment.ts for development
  - Set up environment.prod.ts for production
  - Configure API base URL and timeout
  - _Requirements: 9.3_

- [ ] 7. Checkpoint - Verify project setup
  - Ensure project builds without errors
  - Verify all dependencies installed correctly
  - Test TailwindCSS and PrimeNG integration
  - Ask user if questions arise


### Week 2: Core Services & Authentication (Feb 18-24)

- [ ] 8. Create core models and interfaces
  - [ ] 8.1 Create User model (user.model.ts)
    - Define User interface with all fields
    - Define AuthResponse interface
    - _Requirements: 5.1_
  
  - [ ] 8.2 Create API Response model (api-response.model.ts)
    - Define ApiResponse<T> generic interface
    - Define PaginationMeta interface
    - Define ApiError and ValidationError interfaces
    - _Requirements: 5.1_

- [ ] 9. Implement core services
  - [ ] 9.1 Create BaseApiService
    - Implement generic HTTP methods (get, post, put, patch, delete)
    - Implement query parameter builder
    - Handle ApiResponse unwrapping
    - _Requirements: 9.2_
  
  - [ ] 9.2 Create AuthService
    - Implement login method
    - Implement register method
    - Implement logout method
    - Implement token storage methods
    - _Requirements: US-1.1, US-1.2_
  
  - [ ] 9.3 Create NotificationService
    - Implement showSuccess, showError, showWarning, showInfo methods
    - Integrate with PrimeNG MessageService
    - _Requirements: 10.2_
  
  - [ ] 9.4 Create LoadingService
    - Implement show, hide, reset methods
    - Use BehaviorSubject for loading state
    - Handle multiple concurrent requests
    - _Requirements: 10.4_

- [ ] 10. Implement HTTP interceptors
  - [ ] 10.1 Create AuthInterceptor
    - Add JWT token to request headers
    - Get token from NgRx store
    - _Requirements: 9.1_
  
  - [ ] 10.2 Create ErrorInterceptor
    - Handle HTTP errors globally
    - Show user-friendly error messages
    - Redirect to login on 401
    - _Requirements: 9.1, 10.1_
  
  - [ ] 10.3 Create LoadingInterceptor
    - Show loading indicator on request start
    - Hide loading indicator on request complete
    - _Requirements: 9.1, 10.4_

- [ ] 11. Implement route guards
  - [ ] 11.1 Create AuthGuard
    - Check if user is authenticated
    - Redirect to login if not authenticated
    - _Requirements: 7.3_
  
  - [ ] 11.2 Create RoleGuard
    - Check if user has required role
    - Redirect to login if unauthorized
    - _Requirements: 7.3_


- [ ] 12. Set up NgRx Auth Store
  - [ ] 12.1 Create auth state, actions, reducer
    - Define AuthState interface
    - Create login, loginSuccess, loginFailure, logout actions
    - Implement authReducer with all action handlers
    - _Requirements: 6.2_
  
  - [ ] 12.2 Create auth effects
    - Implement login$ effect
    - Implement loginSuccess$ effect with role-based redirect
    - Implement logout$ effect
    - _Requirements: 6.2_
  
  - [ ] 12.3 Create auth selectors
    - Create selectUser, selectToken, selectIsAuthenticated selectors
    - Create selectUserType selector
    - _Requirements: 6.2_
  
  - [ ]* 12.4 Write unit tests for auth reducer
    - Test initial state
    - Test login action sets loading to true
    - Test loginSuccess sets user and token
    - Test logout resets state
    - _Requirements: 11.5_

- [ ] 13. Configure root store
  - Create store/index.ts with AppState and reducers
  - Configure app.config.ts with provideStore, provideEffects
  - Add StoreDevtools for development
  - _Requirements: 6.4_

- [ ] 14. Implement authentication components
  - [ ] 14.1 Create LoginComponent
    - Create reactive form with email, password, rememberMe fields
    - Implement form validation
    - Dispatch login action on submit
    - Show loading state and error messages
    - Add link to register page
    - _Requirements: US-1.1, 4.3.1_
  
  - [ ] 14.2 Create RegisterComponent
    - Create reactive form with all required fields
    - Implement form validation and password strength
    - Call AuthService register method
    - Show success message and redirect to login
    - Add link to login page
    - _Requirements: US-1.2, 4.3.2_
  
  - [ ]* 14.3 Write property test for form validation
    - **Property 1: Form Validation Consistency**
    - Test that invalid forms prevent submission
    - Test email validation with various inputs
    - Test password validation with various inputs
    - _Requirements: US-1.1, US-1.2_

- [ ] 15. Create auth routes
  - Define AUTH_ROUTES with login and register paths
  - Configure lazy loading for auth components
  - _Requirements: 7.2_

- [ ] 16. Checkpoint - Test authentication flow
  - Ensure login works end-to-end
  - Verify token storage and retrieval
  - Test role-based redirect
  - Test logout functionality
  - Ask user if questions arise


### Week 3: Layouts & Platform Admin Features (Feb 25 - Mar 3)

- [ ] 17. Create layout components
  - [ ] 17.1 Create MainLayoutComponent
    - Implement dashboard layout with sidebar and navbar
    - Add router outlet for content area
    - Make responsive (collapsible sidebar on mobile)
    - _Requirements: 4.2.1_
  
  - [ ] 17.2 Create AuthLayoutComponent
    - Implement simple centered layout for auth pages
    - Add gradient background
    - _Requirements: 4.2.2_
  
  - [ ] 17.3 Create NavbarComponent
    - Add logo and app title
    - Add user profile dropdown with logout
    - Add notifications icon (placeholder)
    - _Requirements: 4.2.3_
  
  - [ ] 17.4 Create SidebarComponent
    - Implement role-based menu items
    - Add active route highlighting
    - Add Lucide icons for menu items
    - Make collapsible on mobile
    - _Requirements: 4.2.4_

- [ ] 18. Create shared components
  - [ ] 18.1 Create PageHeaderComponent
    - Add title, breadcrumbs, and action buttons
    - Make configurable via inputs
    - _Requirements: 4.8.2_
  
  - [ ] 18.2 Create LoadingSpinnerComponent
    - Implement overlay and inline modes
    - Use PrimeNG ProgressSpinner
    - _Requirements: 4.8.4_
  
  - [ ] 18.3 Create ConfirmationDialogComponent
    - Integrate with PrimeNG ConfirmationService
    - Add configurable title, message, icon
    - _Requirements: 4.8.3_

- [ ] 19. Create Platform Admin models
  - Create Agency model (agency.model.ts)
  - Create Supplier model (supplier.model.ts)
  - Create DTOs for create/update operations
  - _Requirements: 5.2_

- [ ] 20. Create Platform Admin API services
  - [ ] 20.1 Create AgencyApiService
    - Implement getAgencies, getAgencyById, createAgency, updateAgency, deleteAgency methods
    - Extend BaseApiService
    - _Requirements: 9.2_
  
  - [ ] 20.2 Create SupplierApiService
    - Implement getSuppliers, getSupplierById, approveSupplier, rejectSupplier methods
    - Extend BaseApiService
    - _Requirements: 9.2_


- [ ] 21. Implement Platform Admin components
  - [ ] 21.1 Create PlatformAdminDashboardComponent
    - Create stat cards for agencies, suppliers, bookings, revenue
    - Create recent activities table
    - Use PrimeNG Card and Table components
    - _Requirements: US-2.1, 4.4.1_
  
  - [ ] 21.2 Create AgencyListComponent
    - Create data table with all required columns
    - Implement search by company name
    - Implement filter by status and subscription plan
    - Implement pagination and sorting
    - Add quick action buttons (view, edit, suspend)
    - Add create new agency button
    - _Requirements: US-2.2, 4.4.2_
  
  - [ ] 21.3 Create AgencyFormComponent
    - Create reactive form with all required fields
    - Implement form validation
    - Support create and edit modes
    - Show loading state during save
    - Show success/error messages
    - _Requirements: US-2.3, 4.4.3_
  
  - [ ] 21.4 Create SupplierListComponent
    - Create separate section for pending approvals
    - Create data table with all required columns
    - Implement search and filters
    - Add quick action buttons (view, approve, reject, suspend)
    - _Requirements: US-2.4, 4.4.4_
  
  - [ ] 21.5 Create SupplierApprovalComponent
    - Display supplier details
    - Add approve button with confirmation
    - Add reject button with reason input
    - Show loading state during action
    - _Requirements: US-2.5, 4.4.5_
  
  - [ ]* 21.6 Write property test for search and filter
    - **Property 4: Search and Filter Correctness**
    - Test that search results only include matching items
    - Test that filter results only include items with selected status
    - Test combined search and filter
    - _Requirements: US-2.2, US-2.4_

- [ ] 22. Create Platform Admin routes
  - Define PLATFORM_ADMIN_ROUTES with all paths
  - Configure lazy loading for all components
  - Add role guard with 'platform_admin' role
  - _Requirements: 7.2_

- [ ] 23. Checkpoint - Test Platform Admin features
  - Ensure all CRUD operations work
  - Test search and filter functionality
  - Test pagination and sorting
  - Verify role-based access
  - Ask user if questions arise


### Week 4: Supplier Features (Mar 4-10)

- [ ] 24. Create Supplier models
  - Create Service model with all service types (service.model.ts)
  - Create HotelDetails, FlightDetails, VisaDetails, TransportDetails, GuideDetails interfaces
  - Create CreateServiceDto
  - _Requirements: 5.3_

- [ ] 25. Create Supplier API service
  - Create ServiceApiService extending BaseApiService
  - Implement getServices, getServiceById, createService, updateService, deleteService, publishService methods
  - _Requirements: 9.2_

- [ ] 26. Implement Supplier components
  - [ ] 26.1 Create SupplierDashboardComponent
    - Create stat cards for services, booking requests, revenue
    - Create recent services table
    - Add create new service button
    - _Requirements: US-3.1, 4.5.1_
  
  - [ ] 26.2 Create ServiceListComponent
    - Implement grid/list view toggle
    - Create data view with all required fields
    - Implement search by service name
    - Implement filter by service type and status
    - Implement sorting
    - Add quick action buttons (view, edit, publish/unpublish, delete)
    - Add create new service button
    - _Requirements: US-3.2, 4.5.2_
  
  - [ ] 26.3 Create ServiceFormComponent - Step 1 (Service Type Selection)
    - Create radio button group for service types
    - Implement stepper navigation
    - _Requirements: US-3.3, 4.5.3_
  
  - [ ] 26.4 Create ServiceFormComponent - Step 2 (Basic Information)
    - Create form fields for name, description, base price, price unit
    - Implement validation
    - _Requirements: US-3.3, 4.5.3_
  
  - [ ] 26.5 Create ServiceFormComponent - Step 3 (Service-Specific Details)
    - Create conditional forms based on service type
    - Implement Hotel details form with room types array
    - Implement Flight details form
    - Implement Visa details form
    - Implement Transport details form
    - Implement Guide details form
    - _Requirements: US-3.3, US-3.4, US-3.5, US-3.6, US-3.7, 4.5.3_
  
  - [ ] 26.6 Create ServiceFormComponent - Step 4 (Review & Publish)
    - Display all entered information
    - Add save as draft button
    - Add publish button
    - Implement form submission
    - _Requirements: US-3.3, 4.5.3_
  
  - [ ] 26.7 Create ServiceDetailComponent
    - Display full service information
    - Display service-specific details
    - Add edit and delete buttons
    - _Requirements: 4.5.3_
  
  - [ ]* 26.8 Write property test for draft persistence
    - **Property 12: Draft Persistence**
    - Test that saving draft preserves all form data
    - Test that loading draft restores form state
    - Test that draft can be resumed from correct step
    - _Requirements: US-3.3_

- [ ] 27. Create Supplier routes
  - Define SUPPLIER_ROUTES with all paths
  - Configure lazy loading for all components
  - Add role guard with 'supplier' role
  - _Requirements: 7.2_

- [ ] 28. Checkpoint - Test Supplier features
  - Ensure service creation works for all types
  - Test multi-step form navigation
  - Test save as draft functionality
  - Test grid/list view toggle
  - Ask user if questions arise


### Week 5: Agency Features - Part 1 (Mar 11-17)

- [ ] 29. Create Agency models
  - Create Package model (package.model.ts)
  - Create PackageService, PackageDeparture interfaces
  - Create CreatePackageDto
  - _Requirements: 5.4_

- [ ] 30. Create Agency API services
  - [ ] 30.1 Create PackageApiService
    - Implement getPackages, getPackageById, createPackage, updatePackage, deletePackage, publishPackage methods
    - Extend BaseApiService
    - _Requirements: 9.2_
  
  - [ ] 30.2 Create ServiceCatalogApiService
    - Implement getSupplierServices, getSupplierServiceById methods
    - Extend BaseApiService
    - _Requirements: 9.2_

- [ ] 31. Implement Agency Dashboard
  - Create AgencyDashboardComponent
  - Create stat cards for pending bookings, revenue, upcoming departures
  - Create recent bookings table
  - Add quick action buttons (create package, create booking)
  - _Requirements: US-4.1, 4.6.1_

- [ ] 32. Implement Service Catalog
  - [ ] 32.1 Create ServiceCatalogComponent
    - Implement grid/list view toggle
    - Display service cards with all required fields
    - Implement search by service name
    - Implement filter by service type and price range
    - Implement sorting
    - Add view details button (opens dialog)
    - _Requirements: US-4.2, 4.6.2_
  
  - [ ] 32.2 Create ServiceDetailDialog
    - Display full service information
    - Display supplier information
    - Display pricing details
    - Add "Add to Package" button
    - _Requirements: US-4.2, 4.6.2_

- [ ] 33. Implement Package List
  - Create PackageListComponent
  - Implement grid/list view toggle
  - Display package cards with all required fields
  - Implement search, filters, and sorting
  - Add quick action buttons (view, edit, publish/unpublish, delete)
  - Add create new package button
  - _Requirements: US-4.3, 4.6.3_


- [ ] 34. Implement Package Form - Part 1
  - [ ] 34.1 Create PackageFormComponent - Step 1 (Basic Information)
    - Create form fields for name, type, duration, description, highlights
    - Implement validation
    - Implement stepper navigation
    - _Requirements: US-4.4, 4.6.4_
  
  - [ ] 34.2 Create PackageFormComponent - Step 2 (Select Services)
    - Create service selection interface
    - Display available services by type (hotel, flight, visa, transport, guide)
    - Allow selecting services from catalog
    - Display selected services with quantity, unit cost, total cost
    - Add remove button for each service
    - Calculate base cost automatically
    - _Requirements: US-4.4, 4.6.4_
  
  - [ ]* 34.3 Write property test for base cost calculation
    - **Property 5: Package Cost Calculation (Base Cost)**
    - Test that base cost equals sum of all service costs
    - Generate random service selections
    - Verify calculation for various combinations
    - _Requirements: US-4.4_

- [ ] 35. Checkpoint - Test Agency features (Part 1)
  - Ensure service catalog works
  - Test package list view
  - Test package form steps 1-2
  - Verify base cost calculation
  - Ask user if questions arise


### Week 6: Agency Features - Part 2 (Mar 18-24)

- [ ] 36. Implement Package Form - Part 2
  - [ ] 36.1 Create PackageFormComponent - Step 3 (Pricing)
    - Display base cost (read-only)
    - Create markup type radio buttons (fixed, percentage)
    - Create markup amount/percentage input
    - Calculate selling price automatically
    - Allow manual override of selling price
    - Display pricing breakdown
    - _Requirements: US-4.4, 4.6.4_
  
  - [ ]* 36.2 Write property test for selling price calculation
    - **Property 5: Package Cost Calculation (Selling Price)**
    - Test fixed markup calculation
    - Test percentage markup calculation
    - Generate random base costs and markups
    - Verify calculations are correct
    - _Requirements: US-4.4_
  
  - [ ] 36.3 Create PackageFormComponent - Step 4 (Departures)
    - Create form to add departure dates
    - Create table showing all departures
    - Allow adding multiple departures
    - Allow editing/removing departures
    - Implement validation (departure date < return date)
    - _Requirements: US-4.4, 4.6.4_
  
  - [ ] 36.4 Create PackageFormComponent - Step 5 (Review & Publish)
    - Display all package information
    - Display selected services
    - Display pricing breakdown
    - Display departures
    - Add save as draft button
    - Add publish button
    - Implement form submission
    - _Requirements: US-4.4, 4.6.4_

- [ ] 37. Create Booking models
  - Create Booking model (booking.model.ts)
  - Create Traveler interface
  - Create CreateBookingDto, BookingActionDto
  - _Requirements: 5.4_

- [ ] 38. Create Booking API service
  - Create BookingApiService extending BaseApiService
  - Implement getBookings, getBookingById, createBooking, approveBooking, rejectBooking methods
  - _Requirements: 9.2_

- [ ] 39. Implement Booking List
  - Create BookingListComponent
  - Create separate tab for pending approvals
  - Create data table with all required columns
  - Implement search by booking code or customer name
  - Implement filters (status, package, date range)
  - Implement sorting
  - Add quick action buttons (view, approve, reject)
  - Add create manual booking button
  - _Requirements: US-4.5, 4.6.5_


- [ ] 40. Implement Booking Detail
  - [ ] 40.1 Create BookingDetailComponent
    - Display booking information section
    - Display customer information section
    - Display traveler list table
    - Display pricing breakdown section
    - Add approve button (if status is pending)
    - Add reject button with reason input (if status is pending)
    - Add internal notes section
    - _Requirements: US-4.6, 4.6.6_
  
  - [ ] 40.2 Implement booking approval logic
    - Show confirmation dialog
    - Call approveBooking API
    - Update booking status
    - Show success message
    - _Requirements: US-4.7_
  
  - [ ]* 40.3 Write property test for quota deduction
    - **Property 7: Quota Management**
    - Test that approving booking decreases available quota
    - Test that quota never goes negative
    - Generate random bookings and departures
    - Verify quota calculations
    - _Requirements: US-4.7_
  
  - [ ] 40.4 Implement booking rejection logic
    - Show rejection reason dialog
    - Call rejectBooking API
    - Update booking status
    - Show success message
    - _Requirements: US-4.8_

- [ ] 41. Create Agency routes
  - Define AGENCY_ROUTES with all paths
  - Configure lazy loading for all components
  - Add role guard with 'agency_staff' role
  - _Requirements: 7.2_

- [ ] 42. Checkpoint - Test Agency features (Part 2)
  - Ensure package creation works end-to-end
  - Test pricing calculations
  - Test booking list and detail views
  - Test booking approval/rejection
  - Verify quota management
  - Ask user if questions arise


### Week 7: Traveler Features (Mar 25-31)

- [ ] 43. Create Traveler models
  - Reuse Package model from agency (add TravelerPackage with display fields)
  - Reuse Booking and Traveler models from agency
  - _Requirements: 5.5_

- [ ] 44. Create Traveler API services
  - [ ] 44.1 Create TravelerPackageApiService
    - Implement getPackages, getPackageById, searchPackages methods
    - Extend BaseApiService
    - _Requirements: 9.2_
  
  - [ ] 44.2 Create TravelerBookingApiService
    - Implement getMyBookings, getMyBookingById, createBooking methods
    - Extend BaseApiService
    - _Requirements: 9.2_

- [ ] 45. Implement Traveler Home
  - Create TravelerHomeComponent
  - Create hero section with search bar
  - Create featured packages section (grid layout)
  - Create package category cards (Umrah, Hajj, Tour)
  - Implement search functionality
  - Implement category filtering
  - _Requirements: US-5.1, 4.7.1_

- [ ] 46. Implement Package Browse
  - [ ] 46.1 Create PackageBrowseComponent
    - Implement grid/list view toggle
    - Create sidebar with filters (type, price range, duration, departure month)
    - Display package cards with all required fields
    - Implement search by package name
    - Implement real-time filtering
    - Implement sorting (price, duration, popularity)
    - Implement pagination
    - _Requirements: US-5.2, 4.7.2_
  
  - [ ]* 46.2 Write property test for package filtering
    - **Property 4: Search and Filter Correctness**
    - Test that filtered results match all criteria
    - Test price range filtering
    - Test duration filtering
    - Test combined filters
    - _Requirements: US-5.2_

- [ ] 47. Implement Package Detail (Traveler)
  - Create PackageDetailComponent (Traveler version)
  - Display package header with name, agency, duration, price
  - Display package information section
  - Display services included (accordion or tabs)
  - Display available departures table with quota
  - Add departure selection
  - Add Book Now button
  - Display terms & conditions (placeholder)
  - _Requirements: US-5.3, 4.7.3_


- [ ] 48. Implement Booking Form (Traveler)
  - [ ] 48.1 Create BookingFormComponent - Step 1 (Select Departure & Travelers)
    - Create departure selection (if not pre-selected)
    - Create number of travelers input
    - Display price calculation
    - Implement validation (quota check)
    - _Requirements: US-5.4, 4.7.4_
  
  - [ ] 48.2 Create BookingFormComponent - Step 2 (Traveler Details)
    - Create dynamic form array based on number of travelers
    - Create form fields for each traveler (name, gender, DOB, nationality, passport, etc.)
    - Implement mahram fields for female travelers
    - Implement validation for all fields
    - _Requirements: US-5.4, 4.7.4_
  
  - [ ]* 48.3 Write property test for mahram validation
    - **Property 8: Mahram Validation**
    - Test that female travelers requiring mahram have valid mahram assigned
    - Test that mahram is male traveler in same booking
    - Generate random traveler combinations
    - Verify validation logic
    - _Requirements: US-5.4_
  
  - [ ] 48.4 Create BookingFormComponent - Step 3 (Contact Information)
    - Create form fields for contact name, email, phone
    - Implement validation
    - _Requirements: US-5.4, 4.7.4_
  
  - [ ] 48.5 Create BookingFormComponent - Step 4 (Review & Submit)
    - Display package details
    - Display departure information
    - Display all traveler details
    - Display contact information
    - Display pricing breakdown
    - Add terms & conditions checkbox
    - Add submit booking button
    - Implement form submission
    - Show success message with booking reference
    - _Requirements: US-5.4, 4.7.4_
  
  - [ ]* 48.6 Write property test for booking price calculation
    - **Property 6: Booking Price Calculation**
    - Test that total price equals selling price × number of travelers
    - Generate random bookings with various traveler counts
    - Verify calculations
    - _Requirements: US-5.4_

- [ ] 49. Implement My Bookings
  - [ ] 49.1 Create MyBookingsComponent
    - Create list view of all user bookings
    - Display booking code, package name, departure date, travelers, price, status
    - Implement filter by status
    - Implement sorting by date
    - Add view details button
    - Add status badges with colors
    - _Requirements: US-5.5, 4.7.5_
  
  - [ ] 49.2 Create BookingDetailComponent (Traveler version)
    - Display booking information section
    - Display package details section
    - Display traveler list table
    - Display pricing breakdown section
    - Add download button (placeholder)
    - Add cancel button (if status allows)
    - _Requirements: US-5.6, 4.7.6_

- [ ] 50. Create Traveler routes
  - Define TRAVELER_ROUTES with all paths
  - Configure lazy loading for all components
  - Add role guard with 'customer' role
  - _Requirements: 7.2_

- [ ] 51. Checkpoint - Test Traveler features
  - Ensure package browsing works
  - Test booking creation flow
  - Test mahram validation
  - Test price calculations
  - Verify my bookings display
  - Ask user if questions arise


### Week 8: State Management & Integration (Apr 1-7)

- [ ] 52. Implement NgRx stores for features
  - [ ] 52.1 Create Agency store
    - Create agency state, actions, reducer
    - Create agency effects for API calls
    - Create agency selectors
    - _Requirements: 6.3_
  
  - [ ] 52.2 Create Supplier store
    - Create supplier state, actions, reducer
    - Create supplier effects for API calls
    - Create supplier selectors
    - _Requirements: 6.3_
  
  - [ ] 52.3 Create Package store
    - Create package state, actions, reducer
    - Create package effects for API calls
    - Create package selectors
    - Use EntityAdapter for package entities
    - _Requirements: 6.3_
  
  - [ ] 52.4 Create Booking store
    - Create booking state, actions, reducer
    - Create booking effects for API calls
    - Create booking selectors
    - Use EntityAdapter for booking entities
    - _Requirements: 6.3_
  
  - [ ]* 52.5 Write unit tests for reducers
    - Test package reducer actions
    - Test booking reducer actions
    - Test initial states
    - Test state updates
    - _Requirements: 11.4_

- [ ] 53. Integrate stores with components
  - [ ] 53.1 Refactor Platform Admin components to use stores
    - Update AgencyListComponent to use agency store
    - Update SupplierListComponent to use supplier store
    - Dispatch actions instead of direct API calls
    - _Requirements: 6.1_
  
  - [ ] 53.2 Refactor Agency components to use stores
    - Update PackageListComponent to use package store
    - Update BookingListComponent to use booking store
    - Dispatch actions instead of direct API calls
    - _Requirements: 6.1_
  
  - [ ] 53.3 Refactor Traveler components to use stores
    - Update PackageBrowseComponent to use package store
    - Update MyBookingsComponent to use booking store
    - Dispatch actions instead of direct API calls
    - _Requirements: 6.1_

- [ ] 54. Implement shared utilities
  - [ ] 54.1 Create ValidationUtils
    - Implement getErrorMessage method
    - Implement markFormGroupTouched method
    - _Requirements: 10.3_
  
  - [ ] 54.2 Create DateUtils
    - Implement date formatting functions
    - Implement date validation functions
    - _Requirements: 4.8_
  
  - [ ]* 54.3 Write unit tests for utilities
    - Test ValidationUtils methods
    - Test DateUtils methods
    - Test various input scenarios
    - _Requirements: 11.2_


- [ ] 55. Implement shared pipes
  - [ ] 55.1 Create DateFormatPipe
    - Implement transform method for date formatting
    - Support multiple date formats
    - _Requirements: 4.8_
  
  - [ ] 55.2 Create CurrencyFormatPipe
    - Implement transform method for currency formatting
    - Support IDR currency
    - _Requirements: 4.8_
  
  - [ ]* 55.3 Write unit tests for pipes
    - Test DateFormatPipe with various dates
    - Test CurrencyFormatPipe with various amounts
    - _Requirements: 11.2_

- [ ] 56. Configure root routes
  - Update app.routes.ts with all feature routes
  - Configure role-based guards for all routes
  - Set up default redirects
  - Configure 404 handling
  - _Requirements: 7.1_

- [ ] 57. Implement global error handling
  - Ensure ErrorInterceptor handles all error types
  - Test 401, 403, 404, 500 error scenarios
  - Verify error messages display correctly
  - _Requirements: 10.1_

- [ ] 58. Implement global loading indicator
  - Add loading spinner to app.html
  - Connect to LoadingService
  - Test with various API calls
  - _Requirements: 10.4_

- [ ] 59. Add PrimeNG Toast for notifications
  - Add p-toast component to app.html
  - Configure MessageService in app.config.ts
  - Test success, error, warning, info notifications
  - _Requirements: 10.2_

- [ ] 60. Checkpoint - Test full integration
  - Ensure all features work together
  - Test navigation between all pages
  - Test state management across features
  - Verify error handling and notifications
  - Ask user if questions arise


### Week 9: Testing & Bug Fixes (Apr 8-14)

- [ ] 61. Write core service tests
  - [ ]* 61.1 Write tests for AuthService
    - Test login method
    - Test register method
    - Test logout method
    - Test token storage
    - _Requirements: 11.2_
  
  - [ ]* 61.2 Write tests for BaseApiService
    - Test HTTP methods (get, post, put, patch, delete)
    - Test query parameter building
    - Test response unwrapping
    - _Requirements: 11.2_
  
  - [ ]* 61.3 Write tests for NotificationService
    - Test showSuccess, showError, showWarning, showInfo
    - Test message display
    - _Requirements: 11.2_

- [ ] 62. Write property tests for correctness properties
  - [ ]* 62.1 Write property test for role-based routing
    - **Property 2: Role-Based Routing**
    - Test that users can only access routes matching their role
    - Test redirect to login for unauthorized access
    - _Requirements: 3.3_
  
  - [ ]* 62.2 Write property test for token persistence
    - **Property 3: Authentication Token Persistence**
    - Test that token is stored after login
    - Test that token is included in API requests
    - Test that token persists across page refresh
    - _Requirements: US-1.1_
  
  - [ ]* 62.3 Write property test for loading states
    - **Property 9: Loading State Management**
    - Test that loading indicator shows during API calls
    - Test that loading indicator hides after completion
    - Test with multiple concurrent requests
    - _Requirements: US-1.1, US-1.2_
  
  - [ ]* 62.4 Write property test for error messages
    - **Property 10: Error Message Display**
    - Test that error messages display on failed operations
    - Test various error scenarios
    - _Requirements: US-1.1, 3.3_
  
  - [ ]* 62.5 Write property test for token expiry
    - **Property 11: Token Expiry Handling**
    - Test that 401 response triggers logout
    - Test redirect to login page
    - _Requirements: 3.3_

- [ ] 63. Write component tests for critical components
  - [ ]* 63.1 Write tests for LoginComponent
    - Test form validation
    - Test login action dispatch
    - Test error display
    - _Requirements: 11.3_
  
  - [ ]* 63.2 Write tests for PackageFormComponent
    - Test multi-step navigation
    - Test cost calculations
    - Test form validation
    - _Requirements: 11.3_
  
  - [ ]* 63.3 Write tests for BookingFormComponent
    - Test traveler form array
    - Test mahram validation
    - Test price calculation
    - _Requirements: 11.3_


- [ ] 64. Run test coverage report
  - Run `npm run test:coverage`
  - Review coverage report
  - Identify gaps in coverage
  - Add tests for uncovered critical code
  - _Requirements: 11.5_

- [ ] 65. Manual testing and bug fixes
  - [ ] 65.1 Test all user flows for Platform Admin
    - Test agency CRUD operations
    - Test supplier approval flow
    - Fix any bugs found
    - _Requirements: US-2.1, US-2.2, US-2.3, US-2.4, US-2.5_
  
  - [ ] 65.2 Test all user flows for Supplier
    - Test service creation for all types
    - Test service list and filters
    - Test draft functionality
    - Fix any bugs found
    - _Requirements: US-3.1, US-3.2, US-3.3_
  
  - [ ] 65.3 Test all user flows for Agency
    - Test package creation end-to-end
    - Test booking list and approval
    - Test service catalog
    - Fix any bugs found
    - _Requirements: US-4.1, US-4.2, US-4.3, US-4.4, US-4.5, US-4.6, US-4.7, US-4.8_
  
  - [ ] 65.4 Test all user flows for Traveler
    - Test package browsing and search
    - Test booking creation
    - Test my bookings
    - Fix any bugs found
    - _Requirements: US-5.1, US-5.2, US-5.3, US-5.4, US-5.5, US-5.6_

- [ ] 66. Cross-browser testing
  - Test on Chrome (latest)
  - Test on Firefox (latest)
  - Test on Safari (latest)
  - Test on Edge (latest)
  - Fix any browser-specific issues
  - _Requirements: 3.4_

- [ ] 67. Responsive design testing
  - Test on desktop (1920x1080)
  - Test on tablet (768x1024)
  - Test on mobile (375x667)
  - Fix any responsive issues
  - _Requirements: 3.2_

- [ ] 68. Checkpoint - Verify all tests pass
  - Ensure all unit tests pass
  - Ensure all property tests pass
  - Ensure no critical bugs remain
  - Ask user if questions arise


### Week 10: Polish, Optimization & Demo Preparation (Apr 15-21)

- [ ] 69. Performance optimization
  - [ ] 69.1 Implement OnPush change detection strategy
    - Update all list components to use OnPush
    - Update all card components to use OnPush
    - Test performance improvements
    - _Requirements: 13.2_
  
  - [ ] 69.2 Add trackBy functions to all ngFor loops
    - Identify all ngFor loops
    - Add trackBy functions
    - Test rendering performance
    - _Requirements: 13.2_
  
  - [ ] 69.3 Optimize bundle size
    - Analyze bundle with webpack-bundle-analyzer
    - Remove unused imports
    - Verify tree shaking is working
    - _Requirements: 13.1_
  
  - [ ] 69.4 Add lazy loading for images
    - Add loading="lazy" to all images
    - Test image loading behavior
    - _Requirements: 13.4_

- [ ] 70. Accessibility improvements
  - [ ] 70.1 Add ARIA labels to all interactive elements
    - Add aria-label to buttons without text
    - Add aria-required to required form fields
    - Add aria-live regions for dynamic content
    - _Requirements: 15.1, 15.3_
  
  - [ ] 70.2 Verify keyboard navigation
    - Test tab order on all pages
    - Test escape key closes dialogs
    - Test enter key submits forms
    - Fix any keyboard navigation issues
    - _Requirements: 15.2_
  
  - [ ] 70.3 Check color contrast
    - Use color contrast checker tool
    - Verify WCAG AA compliance
    - Fix any contrast issues
    - _Requirements: 15.4_

- [ ] 71. UI polish
  - [ ] 71.1 Add loading skeletons
    - Add skeleton loaders for tables
    - Add skeleton loaders for cards
    - Test loading states
    - _Requirements: 3.2_
  
  - [ ] 71.2 Add empty states
    - Add empty state for empty lists
    - Add empty state for no search results
    - Add helpful messages and actions
    - _Requirements: 3.2_
  
  - [ ] 71.3 Add transitions and animations
    - Add fade-in animations for page loads
    - Add smooth transitions for dialogs
    - Add hover effects for buttons
    - Keep animations subtle and professional
    - _Requirements: 3.2_
  
  - [ ] 71.4 Review and polish all forms
    - Ensure consistent spacing
    - Ensure consistent validation messages
    - Ensure consistent button placement
    - _Requirements: 3.2_


- [ ] 72. Documentation
  - [ ] 72.1 Update README.md
    - Add project description
    - Add setup instructions
    - Add development commands
    - Add build instructions
    - _Requirements: 17.1_
  
  - [ ] 72.2 Add code comments
    - Add JSDoc comments to complex functions
    - Add comments to complex business logic
    - Add comments to utility functions
    - _Requirements: 4.5_
  
  - [ ] 72.3 Create deployment guide
    - Document build process
    - Document environment configuration
    - Document hosting options
    - _Requirements: 16_

- [ ] 73. Prepare demo data
  - [ ] 73.1 Create seed data for Platform Admin
    - Create sample agencies
    - Create sample suppliers (some pending approval)
    - _Requirements: 7.3_
  
  - [ ] 73.2 Create seed data for Supplier
    - Create sample services (all types)
    - Create mix of draft and published services
    - _Requirements: 7.3_
  
  - [ ] 73.3 Create seed data for Agency
    - Create sample packages (Umrah, Hajj, Tour)
    - Create sample bookings (various statuses)
    - _Requirements: 7.3_
  
  - [ ] 73.4 Create seed data for Traveler
    - Create sample customer account
    - Create sample bookings
    - _Requirements: 7.3_

- [ ] 74. Prepare demo script
  - [ ] 74.1 Document Platform Admin demo flow
    - Login as platform admin
    - Show dashboard
    - Show agency management
    - Show supplier approval
    - _Requirements: 7.3_
  
  - [ ] 74.2 Document Supplier demo flow
    - Login as supplier
    - Show dashboard
    - Create new service (hotel)
    - Show service list
    - _Requirements: 7.3_
  
  - [ ] 74.3 Document Agency demo flow
    - Login as agency staff
    - Show dashboard
    - Browse service catalog
    - Create new package
    - Show booking list
    - Approve booking
    - _Requirements: 7.3_
  
  - [ ] 74.4 Document Traveler demo flow
    - Login as traveler
    - Browse packages
    - View package details
    - Create booking
    - Show my bookings
    - _Requirements: 7.3_

- [ ] 75. Final testing and validation
  - [ ] 75.1 Run full demo script
    - Execute all demo flows
    - Verify all features work
    - Fix any last-minute issues
    - _Requirements: 7.3_
  
  - [ ] 75.2 Verify all acceptance criteria
    - Review requirements document
    - Verify each user story is implemented
    - Verify each acceptance criterion is met
    - _Requirements: 7.1_
  
  - [ ] 75.3 Build production bundle
    - Run `npm run build:prod`
    - Verify build succeeds
    - Check bundle size
    - Test production build locally
    - _Requirements: 16.1_

- [ ] 76. Final checkpoint - Demo ready
  - Ensure all features are polished
  - Ensure demo runs smoothly
  - Ensure all documentation is complete
  - Ready for client presentation

---

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation and early issue detection
- Property tests validate universal correctness properties across all inputs
- Unit tests validate specific examples and edge cases
- The 10-week timeline allows for iterative development with continuous integration

---

## 📞 Navigation

- 🏠 [Back to Phase 1](../PHASE-1-COMPLETE-DOCUMENTATION.md)
- 📋 [Requirements Document](requirements.md)
- 📐 [Design Document](design.md)

**Last Updated:** February 11, 2026
