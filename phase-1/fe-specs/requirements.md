# Frontend Requirements - Phase 1 MVP

**Feature:** Tour & Travel ERP SaaS - Frontend Application

**Duration:** 10 weeks (Feb 11 - Apr 26, 2026)

**Tech Stack:** Angular 20 + PrimeNG 20 + TailwindCSS 4 + NgRx

---

## 📍 Navigation

- 🏠 [Back to Phase 1](../PHASE-1-COMPLETE-DOCUMENTATION.md)
- 📋 [Design Document](design.md)
- ✅ [Tasks](tasks.md)

---

## 1. Overview

### 1.1 Purpose
Build a responsive, multi-tenant SaaS frontend application for tour & travel agencies with 4 distinct user roles: Platform Admin, Agency Staff, Supplier, and Traveler (Customer).

### 1.2 Goals
- Provide role-based dashboards and features
- Ensure responsive design (desktop & tablet)
- Implement clean, maintainable code structure
- Follow Angular 20 best practices with standalone components
- Use PrimeNG 20 for UI components
- Implement state management with NgRx
- Ensure consistent styling with TailwindCSS 4

---

## 2. User Stories

### 2.1 Authentication & Authorization

**US-1.1: User Login**
- **As a** user (any role)
- **I want to** login with email and password
- **So that** I can access the system

**Acceptance Criteria:**
- Login form with email and password fields
- Form validation (required fields, email format)
- Display loading state during authentication
- Show error message on failed login
- Redirect to appropriate dashboard based on user role
- Store JWT token securely
- Remember me functionality (optional for Phase 1)

**US-1.2: User Registration (Traveler)**
- **As a** traveler
- **I want to** register a new account
- **So that** I can book tour packages

**Acceptance Criteria:**
- Registration form with: full name, email, phone, password, confirm password
- Form validation (all fields required, password strength, password match)
- Display loading state during registration
- Show success message and redirect to login
- Show error message on failed registration

**US-1.3: User Logout**
- **As a** logged-in user
- **I want to** logout from the system
- **So that** I can secure my account

**Acceptance Criteria:**
- Logout button in navbar
- Clear JWT token and user data from storage
- Redirect to login page
- Show confirmation dialog (optional)

---

### 2.2 Platform Admin Features

**US-2.1: Platform Admin Dashboard**
- **As a** platform admin
- **I want to** see system overview statistics
- **So that** I can monitor the platform

**Acceptance Criteria:**
- Display total agencies (active, suspended)
- Display total suppliers (pending, active)
- Display total bookings
- Display total revenue (mock data for Phase 1)
- Display recent activities list
- Responsive card layout

**US-2.2: Agency Management - List**
- **As a** platform admin
- **I want to** view list of all agencies
- **So that** I can manage them

**Acceptance Criteria:**
- Table/list view with: company name, email, phone, subscription plan, status
- Search by company name
- Filter by status (active, suspended, cancelled)
- Filter by subscription plan (basic, pro, enterprise)
- Pagination (10, 25, 50 items per page)
- Sort by columns
- Quick actions: view, edit, suspend

**US-2.3: Agency Management - Create**
- **As a** platform admin
- **I want to** create a new agency
- **So that** I can onboard new customers

**Acceptance Criteria:**
- Form with fields: company name, email, phone, address, city, subscription plan
- Form validation (all required fields)
- Display loading state during creation
- Show success message and redirect to agency list
- Show error message on failed creation

**US-2.4: Supplier Management - List**
- **As a** platform admin
- **I want to** view list of all suppliers
- **So that** I can manage them

**Acceptance Criteria:**
- Table/list view with: company name, email, business type, status
- Separate section for pending approvals
- Search by company name
- Filter by status (pending, active, suspended)
- Filter by business type
- Quick actions: view, approve, reject, suspend

**US-2.5: Supplier Approval**
- **As a** platform admin
- **I want to** approve or reject supplier registrations
- **So that** I can control who can provide services

**Acceptance Criteria:**
- View supplier details
- Approve button with confirmation
- Reject button with reason input
- Display loading state during action
- Show success message
- Update supplier status in list

---

### 2.3 Supplier Features

**US-3.1: Supplier Dashboard**
- **As a** supplier
- **I want to** see my business overview
- **So that** I can track my performance

**Acceptance Criteria:**
- Display total services count
- Display booking requests count (mock for Phase 1)
- Display revenue (mock for Phase 1)
- Display recent services list
- Quick action: create new service

**US-3.2: Service Management - List**
- **As a** supplier
- **I want to** view my services
- **So that** I can manage them

**Acceptance Criteria:**
- Grid/list view toggle
- Display: service name, type, price, status
- Search by service name
- Filter by service type (hotel, flight, visa, transport, guide)
- Filter by status (draft, published, archived)
- Sort by: name, price, created date
- Quick actions: view, edit, publish/unpublish, delete

**US-3.3: Service Management - Create (Hotel)**
- **As a** supplier
- **I want to** create a hotel service
- **So that** agencies can include it in packages

**Acceptance Criteria:**
- Multi-step form:
  - Step 1: Service type selection
  - Step 2: Basic info (name, description, base price)
  - Step 3: Hotel-specific details (star rating, location, room types, amenities)
  - Step 4: Review & publish
- Form validation for each step
- Save as draft functionality
- Display loading state during creation
- Show success message and redirect to service list

**US-3.4: Service Management - Create (Flight)**
- **As a** supplier
- **I want to** create a flight service
- **So that** agencies can include it in packages

**Acceptance Criteria:**
- Multi-step form with flight-specific fields:
  - Airline, flight number
  - Route (origin, destination)
  - Departure/arrival time
  - Class (economy, business, first)
  - Baggage allowance
- Form validation
- Save as draft functionality

**US-3.5: Service Management - Create (Visa)**
- **As a** supplier
- **I want to** create a visa service
- **So that** agencies can include it in packages

**Acceptance Criteria:**
- Multi-step form with visa-specific fields:
  - Visa type (tourist, umrah, hajj, business)
  - Processing time
  - Validity period
  - Required documents
- Form validation
- Save as draft functionality

**US-3.6: Service Management - Create (Transport)**
- **As a** supplier
- **I want to** create a transport service
- **So that** agencies can include it in packages

**Acceptance Criteria:**
- Multi-step form with transport-specific fields:
  - Vehicle type (bus, van, car)
  - Capacity
  - Route/coverage area
  - Driver included (yes/no)
- Form validation
- Save as draft functionality

**US-3.7: Service Management - Create (Guide)**
- **As a** supplier
- **I want to** create a guide service
- **So that** agencies can include it in packages

**Acceptance Criteria:**
- Multi-step form with guide-specific fields:
  - Guide name
  - Language
  - Specialization (umrah, hajj, tour)
  - Experience (years)
- Form validation
- Save as draft functionality

---

### 2.4 Agency Features

**US-4.1: Agency Dashboard**
- **As an** agency staff
- **I want to** see my agency overview
- **So that** I can track business performance

**Acceptance Criteria:**
- Display pending bookings count
- Display total revenue (mock for Phase 1)
- Display upcoming departures count
- Display recent bookings list
- Quick actions: create package, create booking

**US-4.2: Browse Supplier Services**
- **As an** agency staff
- **I want to** browse available supplier services
- **So that** I can create packages

**Acceptance Criteria:**
- Service catalog view (grid/list toggle)
- Display: service name, supplier name, type, price
- Search by service name
- Filter by service type
- Filter by price range
- Sort by: name, price, supplier
- View service details in modal/dialog
- Select service for package creation

**US-4.3: Package Management - List**
- **As an** agency staff
- **I want to** view my packages
- **So that** I can manage them

**Acceptance Criteria:**
- Grid/list view toggle
- Display: package name, type, duration, price, status
- Search by package name
- Filter by package type (umrah, hajj, tour, custom)
- Filter by status (draft, published, archived)
- Sort by: name, price, created date
- Quick actions: view, edit, publish/unpublish, delete

**US-4.4: Package Management - Create**
- **As an** agency staff
- **I want to** create a tour package
- **So that** customers can book it

**Acceptance Criteria:**
- Multi-step form:
  - Step 1: Basic info (name, type, duration, description, highlights)
  - Step 2: Select services from catalog (hotel, flight, visa, transport, guide)
  - Step 3: Pricing (base cost calculation, markup type, markup amount/percentage, selling price)
  - Step 4: Departures (add multiple departure dates with quota)
  - Step 5: Review & publish
- Form validation for each step
- Auto-calculate base cost from selected services
- Auto-calculate selling price based on markup
- Save as draft functionality
- Display loading state during creation
- Show success message and redirect to package list

**US-4.5: Booking Management - List**
- **As an** agency staff
- **I want to** view all bookings
- **So that** I can manage them

**Acceptance Criteria:**
- Table view with: booking code, customer name, package name, departure date, travelers count, total price, status
- Separate tab/section for pending approvals
- Search by booking code or customer name
- Filter by status (pending, approved, confirmed, rejected, cancelled)
- Filter by package
- Filter by date range
- Sort by columns
- Quick actions: view, approve, reject

**US-4.6: Booking Management - View Details**
- **As an** agency staff
- **I want to** view booking details
- **So that** I can review before approval

**Acceptance Criteria:**
- Display booking information
- Display customer information
- Display traveler list with details
- Display package details
- Display departure information
- Display pricing breakdown
- Approve button (if status is pending)
- Reject button (if status is pending)
- Internal notes section

**US-4.7: Booking Management - Approve**
- **As an** agency staff
- **I want to** approve a booking
- **So that** the customer can proceed with payment

**Acceptance Criteria:**
- Confirmation dialog
- Display loading state during approval
- Update booking status to "approved"
- Deduct quota from departure
- Show success message
- Update booking list

**US-4.8: Booking Management - Reject**
- **As an** agency staff
- **I want to** reject a booking
- **So that** I can manage capacity

**Acceptance Criteria:**
- Rejection reason input (required)
- Confirmation dialog
- Display loading state during rejection
- Update booking status to "rejected"
- Show success message
- Update booking list

**US-4.9: Manual Booking Creation**
- **As an** agency staff
- **I want to** create a booking manually
- **So that** I can serve walk-in customers

**Acceptance Criteria:**
- Similar form to traveler booking
- Select package and departure
- Enter customer information
- Enter traveler details (multiple travelers)
- Auto-approved (no approval needed)
- Payment method selection (cash, transfer, etc)
- Display loading state during creation
- Show success message

---

### 2.5 Agency Features - Purchase Order

**US-4.10: Create Purchase Order**
- **As an** agency staff
- **I want to** create a purchase order to a supplier
- **So that** I can request services for my packages

**Acceptance Criteria:**
- Form with supplier selection (dropdown)
- Add multiple PO items (service, quantity, unit price)
- Display total amount calculation
- Form validation (all fields required)
- Display loading state during creation
- Show success message with PO code
- Redirect to PO list

**US-4.11: View Purchase Order List**
- **As an** agency staff
- **I want to** view all my purchase orders
- **So that** I can track their status

**Acceptance Criteria:**
- Table view with: PO Code, Supplier Name, Total Amount, Status, Created Date
- Filter by status (pending, approved, rejected)
- Filter by supplier
- Search by PO code
- Sort by columns
- Quick actions: view details
- Status badges with colors (pending=warning, approved=success, rejected=danger)

**US-4.12: View Purchase Order Details**
- **As an** agency staff
- **I want to** view PO details
- **So that** I can see all information

**Acceptance Criteria:**
- Display PO information (code, supplier, status, dates)
- Display PO items table (service, quantity, unit price, total)
- Display total amount
- Display approval/rejection information if applicable
- Create Package button (if status is approved)

**US-4.13: Create Package from Approved PO**
- **As an** agency staff
- **I want to** create a package from an approved PO
- **So that** I can use the ordered services

**Acceptance Criteria:**
- Pre-fill package form with services from PO
- Allow editing package details (name, type, duration, etc)
- Allow adding additional services not in PO
- Link package to PO (approved_po_id)
- Follow normal package creation flow
- Display PO code in package details

---

### 2.6 Supplier Features - Purchase Order

**US-4.14: View Purchase Order List (Supplier)**
- **As a** supplier
- **I want to** view purchase orders sent to me
- **So that** I can manage them

**Acceptance Criteria:**
- Table view with: PO Code, Agency Name, Total Amount, Status, Created Date
- Separate section for pending approvals (highlighted)
- Filter by status (pending, approved, rejected)
- Search by PO code or agency name
- Sort by columns
- Quick actions: view details, approve (if pending), reject (if pending)

**US-4.15: View Purchase Order Details (Supplier)**
- **As a** supplier
- **I want to** view PO details
- **So that** I can review before approval

**Acceptance Criteria:**
- Display PO information (code, agency, status, dates)
- Display PO items table (service, quantity, unit price, total)
- Display total amount
- Approve button (if status is pending)
- Reject button with reason input (if status is pending)

**US-4.16: Approve Purchase Order**
- **As a** supplier
- **I want to** approve a purchase order
- **So that** the agency can proceed with package creation

**Acceptance Criteria:**
- Confirmation dialog
- Display loading state during approval
- Update PO status to "approved"
- Show success message
- Update PO list

**US-4.17: Reject Purchase Order**
- **As a** supplier
- **I want to** reject a purchase order
- **So that** I can decline requests I cannot fulfill

**Acceptance Criteria:**
- Rejection reason input (required)
- Confirmation dialog
- Display loading state during rejection
- Update PO status to "rejected"
- Show success message
- Update PO list

---

### 2.7 Traveler Features

**US-5.1: Traveler Home Page**
- **As a** traveler
- **I want to** see featured packages
- **So that** I can discover tour options

**Acceptance Criteria:**
- Hero section with search
- Featured packages section (grid layout)
- Package categories (Umrah, Hajj, Tour)
- Call-to-action buttons
- Responsive design

**US-5.2: Package Browse & Search**
- **As a** traveler
- **I want to** browse and search packages
- **So that** I can find suitable tours

**Acceptance Criteria:**
- Grid/list view toggle
- Display: package name, agency name, duration, price, image placeholder
- Search by package name
- Filter sidebar:
  - Package type (umrah, hajj, tour, custom)
  - Price range (slider)
  - Duration (days)
  - Departure month
- Sort options: price (low to high, high to low), duration, popularity
- Pagination
- Responsive design

**US-5.3: Package Detail View**
- **As a** traveler
- **I want to** view package details
- **So that** I can make informed decision

**Acceptance Criteria:**
- Display package information (name, type, duration, description, highlights)
- Display services included (hotel, flight, visa, transport, guide)
- Display pricing
- Display available departures with quota
- Display terms & conditions (placeholder for Phase 1)
- Book now button
- Responsive design

**US-5.4: Create Booking**
- **As a** traveler
- **I want to** book a package
- **So that** I can go on the tour

**Acceptance Criteria:**
- Multi-step form:
  - Step 1: Select departure & number of travelers
  - Step 2: Enter traveler details for each traveler (name, gender, DOB, nationality, passport number, passport expiry, mahram relationship if female)
  - Step 3: Enter contact information (name, email, phone)
  - Step 4: Review & submit
- Form validation for each step
- Display price calculation
- Display loading state during submission
- Show success message with booking code
- Redirect to my bookings

**US-5.5: My Bookings**
- **As a** traveler
- **I want to** view my bookings
- **So that** I can track my tours

**Acceptance Criteria:**
- List view with: booking code, package name, departure date, travelers count, total price, status
- Filter by status
- Sort by date
- View booking details
- Status badges with colors

**US-5.6: Booking Detail View**
- **As a** traveler
- **I want to** view my booking details
- **So that** I can see all information

**Acceptance Criteria:**
- Display booking information
- Display package details
- Display traveler list
- Display departure information
- Display pricing breakdown
- Display status with color badge
- Download button (placeholder for Phase 1)

---

## 3. Non-Functional Requirements

### 3.1 Performance
- Initial page load < 3 seconds
- Route navigation < 1 second
- API response handling with loading states
- Lazy loading for feature modules
- Optimized bundle size

### 3.2 Usability
- Intuitive navigation
- Consistent UI/UX across all pages
- Clear error messages
- Form validation with helpful hints
- Responsive design (desktop 1920x1080, tablet 768x1024)
- Accessibility (ARIA labels, keyboard navigation)

### 3.3 Security
- JWT token stored in localStorage
- Token expiry handling
- Automatic logout on token expiry
- Role-based route guards
- XSS protection (Angular built-in)
- CSRF protection (Angular built-in)

### 3.4 Browser Support
- Chrome (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions)
- Edge (latest 2 versions)

### 3.5 Code Quality
- TypeScript strict mode
- ESLint configuration
- Prettier formatting
- Component documentation
- Unit tests for critical services (optional for Phase 1)

---

## 4. Technical Constraints

### 4.1 Technology Stack
- Angular 20 (standalone components)
- PrimeNG 20 for UI components
- TailwindCSS 4 for styling
- NgRx for state management
- RxJS for reactive programming
- Lucide Angular for icons

### 4.2 Architecture Pattern
- Feature-based folder structure
- Standalone components (no NgModules)
- Smart/Presentational component pattern
- Service layer for API calls
- NgRx store for global state
- Route-based lazy loading

### 4.3 Styling Guidelines
- Follow ibis-frontend-main pattern
- TailwindCSS utility classes
- PrimeNG component theming
- Consistent spacing and colors
- Responsive breakpoints

---

## 5. Dependencies

### 5.1 Backend API
- All API endpoints must be available
- JWT authentication implemented
- CORS configured
- Error responses standardized

### 5.2 Design Assets
- Logo and branding
- Color palette
- Typography guidelines
- Icon set (Lucide Angular)

---

## 6. Out of Scope (Phase 1)

- Payment gateway integration (mock only)
- Document upload (text input only)
- Email notifications (UI only)
- Real-time notifications
- Advanced reporting
- Export functionality
- Print functionality
- Mobile app
- PWA features
- Internationalization (i18n)
- Dark mode
- Advanced animations

---

## 7. Success Criteria

### 7.1 Functional
- All user stories implemented
- All acceptance criteria met
- Happy path flows working end-to-end
- No critical bugs

### 7.2 Technical
- Code follows Angular style guide
- All components are standalone
- Lazy loading implemented
- State management with NgRx
- Responsive design working
- Build succeeds without errors

### 7.3 Demo
- Demo runs smoothly
- All 4 user roles demonstrated
- Booking flow complete
- UI is polished and professional

---

## 📞 Navigation

- 🏠 [Back to Phase 1](../PHASE-1-COMPLETE-DOCUMENTATION.md)
- 📋 [Design Document](design.md)
- ✅ [Tasks](tasks.md)

**Last Updated:** February 11, 2026
