# Design Document - Phase 1 Frontend

**Feature:** Tour & Travel ERP SaaS - Frontend Application

**Tech Stack:** Angular 20 + PrimeNG 20 + TailwindCSS 4 + NgRx

**Duration:** 10 weeks (Feb 11 - Apr 26, 2026)

---

## 📍 Navigation

- 🏠 [Back to Phase 1](../PHASE-1-COMPLETE-DOCUMENTATION.md)
- 📋 [Requirements Document](requirements.md)
- ✅ [Tasks](tasks.md)

---

## 1. Overview

### 1.1 Purpose

This design document outlines the frontend architecture for a multi-tenant Tour & Travel ERP SaaS application. The system serves four distinct user roles (Platform Admin, Supplier, Agency Staff, Traveler) with role-specific dashboards and features.

### 1.2 Design Goals

- **Maintainability**: Feature-based folder structure with clear separation of concerns
- **Scalability**: Lazy-loaded modules and efficient state management
- **Consistency**: Reusable components and standardized patterns
- **Performance**: Optimized bundle size and loading strategies
- **Developer Experience**: Type-safe code with Angular 20 standalone components

### 1.3 Reference Architecture

This design follows the proven architecture pattern from the ibis-frontend-main project:
- Angular 20 with standalone components (no NgModules)
- PrimeNG 20 for UI components with @primeuix/themes
- TailwindCSS 4 for utility-first styling
- NgRx for centralized state management
- Lucide Angular for modern icons
- Feature-based folder structure

---

## 2. Architecture

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Angular Application                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Layouts    │  │   Features   │  │    Shared    │     │
│  │  (Dashboard, │  │  (Auth, Role │  │ (Components, │     │
│  │    Auth)     │  │   Modules)   │  │   Pipes)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  NgRx Store  │  │     Core     │  │   Routing    │     │
│  │   (State)    │  │  (Services,  │  │   (Guards,   │     │
│  │              │  │   Guards)    │  │   Routes)    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
├─────────────────────────────────────────────────────────────┤
│                    HTTP Client + Interceptors                │
└─────────────────────────────────────────────────────────────┘
                              ↓
                    ┌──────────────────┐
                    │   Backend API    │
                    │  (JWT Auth)      │
                    └──────────────────┘
```

### 2.2 Architectural Principles

1. **Standalone Components**: All components use `standalone: true` (no NgModules)
2. **Feature-Based Structure**: Each feature is self-contained with components, services, models
3. **Lazy Loading**: Features loaded on-demand via route configuration
4. **Centralized State**: NgRx store for complex state management
5. **Smart/Presentational Pattern**: Smart components handle logic, presentational components handle UI
6. **Dependency Injection**: Services provided at appropriate levels


### 2.3 Technology Stack

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Framework | Angular | 20 | Core framework with standalone components |
| UI Library | PrimeNG | 20 | Pre-built UI components (Table, Dialog, Card, etc) |
| Styling | TailwindCSS | 4 | Utility-first CSS framework |
| State Management | NgRx | Latest | Centralized state with store, effects, selectors |
| Icons | Lucide Angular | Latest | Modern icon library |
| HTTP | Angular HttpClient | 20 | API communication |
| Reactive | RxJS | Latest | Reactive programming |
| Forms | Angular Reactive Forms | 20 | Type-safe form handling |
| Routing | Angular Router | 20 | Navigation and lazy loading |

---

## 3. Folder Structure

Following the ibis-frontend-main pattern exactly:

```
src/
├── app/
│   ├── core/                           # Core module - singleton services
│   │   ├── guards/                     # Route guards
│   │   │   ├── auth.guard.ts
│   │   │   └── role.guard.ts
│   │   ├── interceptors/               # HTTP interceptors
│   │   │   ├── auth.interceptor.ts
│   │   │   ├── error.interceptor.ts
│   │   │   └── loading.interceptor.ts
│   │   ├── services/                   # Core services
│   │   │   ├── auth.service.ts
│   │   │   ├── storage.service.ts
│   │   │   └── notification.service.ts
│   │   └── models/                     # Core models/interfaces
│   │       ├── user.model.ts
│   │       └── api-response.model.ts
│   │
│   ├── shared/                         # Shared components & utilities
│   │   ├── components/                 # Reusable UI components
│   │   │   ├── data-table/
│   │   │   ├── page-header/
│   │   │   ├── confirmation-dialog/
│   │   │   ├── loading-spinner/
│   │   │   └── breadcrumb/
│   │   ├── pipes/                      # Shared pipes
│   │   │   ├── date-format.pipe.ts
│   │   │   └── currency-format.pipe.ts
│   │   └── utils/                      # Utility functions
│   │       ├── date.utils.ts
│   │       └── validation.utils.ts
│   │
│   ├── features/                       # Feature modules (standalone)
│   │   ├── auth/                       # Authentication
│   │   │   ├── components/
│   │   │   │   ├── login/
│   │   │   │   └── register/
│   │   │   ├── services/
│   │   │   │   └── auth-api.service.ts
│   │   │   └── auth.routes.ts
│   │   │
│   │   ├── platform-admin/             # Platform Admin features
│   │   │   ├── components/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── agency-list/
│   │   │   │   ├── agency-form/
│   │   │   │   ├── supplier-list/
│   │   │   │   └── supplier-approval/
│   │   │   ├── services/
│   │   │   │   ├── agency-api.service.ts
│   │   │   │   └── supplier-api.service.ts
│   │   │   ├── models/
│   │   │   │   ├── agency.model.ts
│   │   │   │   └── supplier.model.ts
│   │   │   └── platform-admin.routes.ts
│   │   │
│   │   ├── supplier/                   # Supplier features
│   │   │   ├── components/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── service-list/
│   │   │   │   ├── service-form/
│   │   │   │   └── service-detail/
│   │   │   ├── services/
│   │   │   │   └── service-api.service.ts
│   │   │   ├── models/
│   │   │   │   └── service.model.ts
│   │   │   └── supplier.routes.ts
│   │   │
│   │   ├── agency/                     # Agency features
│   │   │   ├── components/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── package-list/
│   │   │   │   ├── package-form/
│   │   │   │   ├── package-detail/
│   │   │   │   ├── booking-list/
│   │   │   │   ├── booking-detail/
│   │   │   │   └── service-catalog/
│   │   │   ├── services/
│   │   │   │   ├── package-api.service.ts
│   │   │   │   └── booking-api.service.ts
│   │   │   ├── models/
│   │   │   │   ├── package.model.ts
│   │   │   │   └── booking.model.ts
│   │   │   └── agency.routes.ts
│   │   │
│   │   └── traveler/                   # Traveler features
│   │       ├── components/
│   │       │   ├── home/
│   │       │   ├── package-browse/
│   │       │   ├── package-detail/
│   │       │   ├── booking-form/
│   │       │   ├── my-bookings/
│   │       │   └── booking-detail/
│   │       ├── services/
│   │       │   ├── package-api.service.ts
│   │       │   └── booking-api.service.ts
│   │       ├── models/
│   │       │   ├── package.model.ts
│   │       │   └── booking.model.ts
│   │       └── traveler.routes.ts
│   │
│   ├── store/                          # NgRx Store
│   │   ├── auth/
│   │   │   ├── auth.actions.ts
│   │   │   ├── auth.reducer.ts
│   │   │   ├── auth.effects.ts
│   │   │   ├── auth.selectors.ts
│   │   │   └── auth.state.ts
│   │   ├── agency/
│   │   ├── supplier/
│   │   ├── package/
│   │   ├── booking/
│   │   └── index.ts                    # Root store config
│   │
│   ├── layouts/                        # Layout components
│   │   ├── main-layout/
│   │   │   ├── main-layout.component.ts
│   │   │   ├── main-layout.component.html
│   │   │   └── main-layout.component.scss
│   │   ├── auth-layout/
│   │   ├── components/
│   │   │   ├── navbar/
│   │   │   ├── sidebar/
│   │   │   └── footer/
│   │   └── layout.routes.ts
│   │
│   ├── app.config.ts                   # App configuration
│   ├── app.routes.ts                   # Root routes
│   ├── app.ts                          # Root component
│   ├── app.html
│   └── app.scss
│
├── assets/                             # Static assets
│   ├── images/
│   └── icons/
│
├── environments/                       # Environment configs
│   ├── environment.ts                  # Development
│   └── environment.prod.ts             # Production
│
├── index.html
├── main.ts
└── styles.scss
```


---

## 4. Components and Interfaces

### 4.1 Core Components

#### 4.1.1 App Component

**File**: `app/app.ts`

```typescript
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class AppComponent {
  title = 'Tour & Travel ERP';
}
```

**Purpose**: Root component that bootstraps the application


### 4.2 Layout Components

#### 4.2.1 Main Layout Component

**File**: `layouts/main-layout/main-layout.component.ts`

**Purpose**: Dashboard layout with sidebar and navbar for authenticated users

**Structure**:
```html
<div class="flex h-screen">
  <app-sidebar />
  <div class="flex-1 flex flex-col">
    <app-navbar />
    <main class="flex-1 overflow-auto p-6 bg-gray-50">
      <router-outlet />
    </main>
  </div>
</div>
```

**Features**:
- Responsive sidebar (collapsible on mobile)
- Top navbar with user menu
- Content area with router outlet
- Role-based sidebar menu items

#### 4.2.2 Auth Layout Component

**File**: `layouts/auth-layout/auth-layout.component.ts`

**Purpose**: Simple layout for login/register pages

**Structure**:
```html
<div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-500 to-purple-600">
  <div class="w-full max-w-md">
    <router-outlet />
  </div>
</div>
```

#### 4.2.3 Navbar Component

**File**: `layouts/components/navbar/navbar.component.ts`

**Features**:
- Logo and app title
- User profile dropdown
- Logout button
- Notifications icon (placeholder for Phase 1)

**PrimeNG Components**: `p-menubar`, `p-menu`, `p-avatar`

#### 4.2.4 Sidebar Component

**File**: `layouts/components/sidebar/sidebar.component.ts`

**Features**:
- Role-based menu items
- Active route highlighting
- Collapsible on mobile
- Icons from Lucide Angular

**Menu Structure by Role**:

**Platform Admin**:
- Dashboard
- Agencies
- Suppliers

**Supplier**:
- Dashboard
- My Services

**Agency Staff**:
- Dashboard
- Packages
- Bookings
- Service Catalog

**Traveler**:
- Home
- Browse Packages
- My Bookings


### 4.3 Authentication Components

#### 4.3.1 Login Component

**File**: `features/auth/components/login/login.component.ts`

**Form Fields**:
- Email (required, email validation)
- Password (required, min 6 characters)
- Remember me (checkbox)

**Features**:
- Reactive form with validation
- Loading state during authentication
- Error message display
- Link to register page (for travelers)
- Role-based redirect after login

**PrimeNG Components**: `p-card`, `p-inputtext`, `p-password`, `p-checkbox`, `p-button`

**Validation**:
```typescript
loginForm = this.fb.group({
  email: ['', [Validators.required, Validators.email]],
  password: ['', [Validators.required, Validators.minLength(6)]],
  rememberMe: [false]
});
```

#### 4.3.2 Register Component

**File**: `features/auth/components/register/register.component.ts`

**Form Fields**:
- Full Name (required)
- Email (required, email validation)
- Phone (required, phone format)
- Password (required, min 8 characters, strength validation)
- Confirm Password (required, must match password)

**Features**:
- Reactive form with validation
- Password strength indicator
- Loading state during registration
- Success message and redirect to login
- Link to login page

**PrimeNG Components**: `p-card`, `p-inputtext`, `p-password`, `p-button`


### 4.4 Platform Admin Components

#### 4.4.1 Platform Admin Dashboard

**File**: `features/platform-admin/components/dashboard/dashboard.component.ts`

**Layout**: Grid of stat cards + recent activities table

**Stat Cards**:
- Total Agencies (with active/suspended breakdown)
- Total Suppliers (with pending/active breakdown)
- Total Bookings
- Total Revenue (mock data)

**Recent Activities**: Table showing recent system activities

**PrimeNG Components**: `p-card`, `p-table`, `p-tag`

#### 4.4.2 Agency List Component

**File**: `features/platform-admin/components/agency-list/agency-list.component.ts`

**Features**:
- Data table with columns: Company Name, Email, Phone, Subscription Plan, Status
- Search by company name
- Filter by status (active, suspended, cancelled)
- Filter by subscription plan (basic, pro, enterprise)
- Pagination (10, 25, 50 per page)
- Sort by columns
- Quick actions: View, Edit, Suspend
- Create new agency button

**PrimeNG Components**: `p-table`, `p-button`, `p-inputtext`, `p-dropdown`, `p-tag`

**Table Configuration**:
```typescript
columns = [
  { field: 'company_name', header: 'Company Name' },
  { field: 'email', header: 'Email' },
  { field: 'phone', header: 'Phone' },
  { field: 'subscription_plan', header: 'Plan' },
  { field: 'is_active', header: 'Status' }
];
```

#### 4.4.3 Agency Form Component

**File**: `features/platform-admin/components/agency-form/agency-form.component.ts`

**Form Fields**:
- Company Name (required)
- Email (required, email validation)
- Phone (required)
- Address (required)
- City (required)
- Subscription Plan (dropdown: basic, pro, enterprise)

**Features**:
- Reactive form with validation
- Create and Edit modes
- Loading state during save
- Success/error messages
- Cancel button returns to list

**PrimeNG Components**: `p-card`, `p-inputtext`, `p-dropdown`, `p-button`

#### 4.4.4 Supplier List Component

**File**: `features/platform-admin/components/supplier-list/supplier-list.component.ts`

**Features**:
- Separate section for pending approvals (highlighted)
- Data table with columns: Company Name, Email, Business Type, Status
- Search by company name
- Filter by status (pending, active, suspended)
- Filter by business type
- Quick actions: View, Approve, Reject, Suspend

**PrimeNG Components**: `p-table`, `p-button`, `p-inputtext`, `p-dropdown`, `p-tag`, `p-divider`

#### 4.4.5 Supplier Approval Component

**File**: `features/platform-admin/components/supplier-approval/supplier-approval.component.ts`

**Features**:
- Display supplier details (company info, business type, documents)
- Approve button with confirmation dialog
- Reject button with reason input dialog
- Loading state during action
- Success message and return to list

**PrimeNG Components**: `p-card`, `p-button`, `p-dialog`, `p-textarea`


### 4.5 Supplier Components

#### 4.5.1 Supplier Dashboard

**File**: `features/supplier/components/dashboard/dashboard.component.ts`

**Layout**: Stat cards + recent services table

**Stat Cards**:
- Total Services
- Booking Requests (mock)
- Revenue (mock)

**Recent Services**: Table showing recently created services

**Quick Actions**: Create New Service button

**PrimeNG Components**: `p-card`, `p-table`, `p-button`

#### 4.5.2 Service List Component

**File**: `features/supplier/components/service-list/service-list.component.ts`

**Features**:
- Grid/List view toggle
- Display: Service Name, Type, Price, Status
- Search by service name
- Filter by service type (hotel, flight, visa, transport, guide)
- Filter by status (draft, published, archived)
- Sort by: name, price, created date
- Quick actions: View, Edit, Publish/Unpublish, Delete
- Create new service button

**PrimeNG Components**: `p-dataview`, `p-table`, `p-button`, `p-inputtext`, `p-dropdown`, `p-tag`, `p-selectbutton`

**View Toggle**:
```typescript
viewOptions = [
  { label: 'Grid', value: 'grid', icon: 'pi pi-th-large' },
  { label: 'List', value: 'list', icon: 'pi pi-bars' }
];
```

#### 4.5.3 Service Form Component

**File**: `features/supplier/components/service-form/service-form.component.ts`

**Multi-Step Form**:

**Step 1: Service Type Selection**
- Radio buttons for: Hotel, Flight, Visa, Transport, Guide

**Step 2: Basic Information**
- Service Name (required)
- Description (textarea, required)
- Base Price (required, number)
- Price Unit (dropdown: per_night, per_pax, per_trip)

**Step 3: Service-Specific Details**

**For Hotel**:
- Hotel Name
- Star Rating (1-5)
- Location
- Distance to Haram
- Room Types (dynamic array):
  - Type (quad, triple, double, single)
  - Capacity
  - Quantity
  - Price per Night
- Amenities (multi-select: wifi, ac, breakfast, prayer_room, etc)

**For Flight**:
- Airline
- Flight Number
- Origin
- Destination
- Departure Time
- Arrival Time
- Class (economy, business, first)
- Baggage Allowance

**For Visa**:
- Visa Type (tourist, umrah, hajj, business)
- Processing Time (days)
- Validity Period (days)
- Required Documents (textarea)

**For Transport**:
- Vehicle Type (bus, van, car)
- Capacity
- Route/Coverage Area
- Driver Included (yes/no)

**For Guide**:
- Guide Name
- Languages (multi-select)
- Specialization (umrah, hajj, tour)
- Experience (years)

**Step 4: Review & Publish**
- Display all entered information
- Save as Draft button
- Publish button

**Features**:
- Stepper navigation
- Form validation per step
- Save as draft functionality
- Loading state during save
- Success message and redirect

**PrimeNG Components**: `p-stepper`, `p-card`, `p-inputtext`, `p-textarea`, `p-inputnumber`, `p-dropdown`, `p-multiselect`, `p-radiobutton`, `p-button`


### 4.6 Agency Components

#### 4.6.1 Agency Dashboard

**File**: `features/agency/components/dashboard/dashboard.component.ts`

**Layout**: Stat cards + recent bookings table

**Stat Cards**:
- Pending Bookings
- Total Revenue (mock)
- Upcoming Departures

**Recent Bookings**: Table showing recent booking submissions

**Quick Actions**: Create Package, Create Booking buttons

**PrimeNG Components**: `p-card`, `p-table`, `p-button`

#### 4.6.2 Service Catalog Component

**File**: `features/agency/components/service-catalog/service-catalog.component.ts`

**Features**:
- Grid/List view toggle
- Display: Service Name, Supplier Name, Type, Price
- Search by service name
- Filter by service type
- Filter by price range (slider)
- Sort by: name, price, supplier
- View details button (opens dialog)
- Select for package button

**PrimeNG Components**: `p-dataview`, `p-button`, `p-inputtext`, `p-dropdown`, `p-slider`, `p-dialog`, `p-tag`

**Service Detail Dialog**:
- Display full service information
- Supplier information
- Pricing details
- Add to Package button

#### 4.6.3 Package List Component

**File**: `features/agency/components/package-list/package-list.component.ts`

**Features**:
- Grid/List view toggle
- Display: Package Name, Type, Duration, Price, Status
- Search by package name
- Filter by package type (umrah, hajj, tour, custom)
- Filter by status (draft, published, archived)
- Sort by: name, price, created date
- Quick actions: View, Edit, Publish/Unpublish, Delete
- Create new package button

**PrimeNG Components**: `p-dataview`, `p-table`, `p-button`, `p-inputtext`, `p-dropdown`, `p-tag`, `p-selectbutton`


#### 4.6.4 Package Form Component

**File**: `features/agency/components/package-form/package-form.component.ts`

**Multi-Step Form**:

**Step 1: Basic Information**
- Package Name (required)
- Package Type (dropdown: umrah, hajj, tour, custom)
- Duration Days (required, number)
- Duration Nights (required, number)
- Description (textarea, required)
- Highlights (textarea)

**Step 2: Select Services**
- Service selection from catalog
- For each service type:
  - Hotel (select from available hotels)
  - Flight (select from available flights)
  - Visa (select from available visa services)
  - Transport (select from available transport)
  - Guide (select from available guides)
- Display selected services with:
  - Service name
  - Supplier name
  - Quantity
  - Unit cost
  - Total cost
  - Remove button

**Step 3: Pricing**
- Base Cost (auto-calculated from selected services, read-only)
- Markup Type (radio: fixed, percentage)
- Markup Amount/Percentage (number input)
- Selling Price (auto-calculated, editable)
- Display pricing breakdown

**Step 4: Departures**
- Add multiple departure dates
- For each departure:
  - Departure Code (auto-generated or manual)
  - Departure Date (date picker)
  - Return Date (date picker)
  - Total Quota (number)
- Table showing all departures
- Add/Remove departure buttons

**Step 5: Review & Publish**
- Display all package information
- Display selected services
- Display pricing
- Display departures
- Save as Draft button
- Publish button

**Features**:
- Stepper navigation
- Form validation per step
- Auto-calculation of costs
- Save as draft functionality
- Loading state during save
- Success message and redirect

**PrimeNG Components**: `p-stepper`, `p-card`, `p-inputtext`, `p-textarea`, `p-inputnumber`, `p-dropdown`, `p-radiobutton`, `p-calendar`, `p-table`, `p-button`, `p-dialog`

**Pricing Calculation**:
```typescript
calculateSellingPrice() {
  if (this.markupType === 'fixed') {
    this.sellingPrice = this.baseCost + this.markupAmount;
  } else {
    this.sellingPrice = this.baseCost * (1 + this.markupPercentage / 100);
  }
}
```


#### 4.6.5 Booking List Component

**File**: `features/agency/components/booking-list/booking-list.component.ts`

**Features**:
- Separate tab/section for pending approvals (highlighted)
- Data table with columns: Booking Code, Customer Name, Package Name, Departure Date, Travelers, Total Price, Status
- Search by booking code or customer name
- Filter by status (pending, approved, confirmed, rejected, cancelled)
- Filter by package
- Filter by date range
- Sort by columns
- Quick actions: View, Approve (if pending), Reject (if pending)
- Create manual booking button

**PrimeNG Components**: `p-table`, `p-button`, `p-inputtext`, `p-dropdown`, `p-calendar`, `p-tag`, `p-tabview`

**Status Colors**:
```typescript
getStatusSeverity(status: string): string {
  const severityMap = {
    'pending': 'warning',
    'approved': 'info',
    'confirmed': 'success',
    'rejected': 'danger',
    'cancelled': 'secondary'
  };
  return severityMap[status] || 'info';
}
```

#### 4.6.6 Booking Detail Component

**File**: `features/agency/components/booking-detail/booking-detail.component.ts`

**Sections**:

**Booking Information**:
- Booking Reference
- Booking Status (with color badge)
- Booking Date
- Package Name
- Departure Date
- Return Date

**Customer Information**:
- Customer Name
- Email
- Phone

**Traveler List**:
- Table with: Traveler Number, Full Name, Gender, DOB, Nationality, Passport Number, Passport Expiry
- For female travelers: Mahram Relationship

**Pricing Breakdown**:
- Base Price per Person
- Number of Travelers
- Subtotal
- Additional Charges (if any)
- Total Amount

**Actions** (if status is pending):
- Approve Button
- Reject Button
- Internal Notes (textarea)

**Features**:
- Display all booking details
- Approve/Reject actions with confirmation
- Loading state during actions
- Success/error messages

**PrimeNG Components**: `p-card`, `p-table`, `p-tag`, `p-button`, `p-dialog`, `p-textarea`


### 4.7 Traveler Components

#### 4.7.1 Traveler Home Component

**File**: `features/traveler/components/home/home.component.ts`

**Sections**:

**Hero Section**:
- Large banner with background image
- Search bar (package name, destination)
- Call-to-action button

**Featured Packages**:
- Grid layout (3-4 columns)
- Package cards with: Image, Name, Duration, Price, Agency Name
- View Details button

**Package Categories**:
- Category cards: Umrah, Hajj, Tour
- Click to filter packages

**Features**:
- Responsive grid layout
- Search functionality
- Category filtering
- Smooth scrolling

**PrimeNG Components**: `p-card`, `p-button`, `p-inputtext`, `p-carousel`

#### 4.7.2 Package Browse Component

**File**: `features/traveler/components/package-browse/package-browse.component.ts`

**Layout**: Sidebar filters + Package grid/list

**Sidebar Filters**:
- Package Type (checkboxes: umrah, hajj, tour, custom)
- Price Range (slider with min/max)
- Duration (number input: min/max days)
- Departure Month (dropdown)

**Package Display**:
- Grid/List view toggle
- Package cards with: Image, Name, Agency Name, Duration, Price
- View Details button
- Pagination

**Sort Options**:
- Price: Low to High
- Price: High to Low
- Duration
- Popularity (mock for Phase 1)

**Features**:
- Responsive layout
- Real-time filtering
- Search by package name
- Pagination
- Loading state

**PrimeNG Components**: `p-dataview`, `p-card`, `p-button`, `p-inputtext`, `p-checkbox`, `p-slider`, `p-dropdown`, `p-paginator`, `p-selectbutton`


#### 4.7.3 Package Detail Component (Traveler)

**File**: `features/traveler/components/package-detail/package-detail.component.ts`

**Sections**:

**Package Header**:
- Package Name
- Agency Name
- Duration
- Price (prominent display)

**Package Information**:
- Description
- Highlights (bullet points)
- Package Type

**Services Included**:
- Accordion or tabs for each service type
- Hotel details (name, star rating, location, amenities)
- Flight details (airline, route, class)
- Visa details (type, processing time)
- Transport details (vehicle type, coverage)
- Guide details (name, languages, specialization)

**Available Departures**:
- Table with: Departure Date, Return Date, Available Quota, Status
- Select Departure radio button
- Book Now button

**Terms & Conditions**:
- Placeholder text for Phase 1

**Features**:
- Image gallery (placeholder images)
- Departure selection
- Quota availability display
- Book Now action
- Responsive layout

**PrimeNG Components**: `p-card`, `p-accordion`, `p-tabview`, `p-table`, `p-button`, `p-tag`, `p-galleria`

#### 4.7.4 Booking Form Component (Traveler)

**File**: `features/traveler/components/booking-form/booking-form.component.ts`

**Multi-Step Form**:

**Step 1: Select Departure & Travelers**
- Departure selection (if not pre-selected)
- Number of travelers (number input, min 1, max based on quota)
- Display price calculation

**Step 2: Traveler Details**
- Dynamic form array based on number of travelers
- For each traveler:
  - Full Name (required)
  - Gender (dropdown: male, female)
  - Date of Birth (date picker, required)
  - Nationality (dropdown, required)
  - Passport Number (required)
  - Passport Expiry Date (date picker, required)
  - For female travelers:
    - Requires Mahram (checkbox)
    - Mahram Traveler Number (dropdown, if requires mahram)
    - Mahram Relationship (dropdown: husband, father, brother, son)

**Step 3: Contact Information**
- Contact Name (required)
- Email (required, email validation)
- Phone (required, phone format)

**Step 4: Review & Submit**
- Display package details
- Display departure information
- Display all traveler details
- Display contact information
- Display pricing breakdown
- Terms & Conditions checkbox (required)
- Submit Booking button

**Features**:
- Stepper navigation
- Form validation per step
- Dynamic traveler forms
- Mahram validation (female travelers must have mahram)
- Price calculation
- Loading state during submission
- Success message with booking reference
- Redirect to My Bookings

**PrimeNG Components**: `p-stepper`, `p-card`, `p-inputtext`, `p-dropdown`, `p-calendar`, `p-checkbox`, `p-button`, `p-inputnumber`

**Mahram Validation**:
```typescript
validateMahram() {
  const travelers = this.travelersFormArray.value;
  const femaleTravelers = travelers.filter(t => t.gender === 'female' && t.requires_mahram);
  
  for (const female of femaleTravelers) {
    if (!female.mahram_traveler_number) {
      return false; // Female traveler requires mahram but none selected
    }
    const mahram = travelers.find(t => t.traveler_number === female.mahram_traveler_number);
    if (!mahram || mahram.gender !== 'male') {
      return false; // Invalid mahram
    }
  }
  return true;
}
```


#### 4.7.5 My Bookings Component

**File**: `features/traveler/components/my-bookings/my-bookings.component.ts`

**Features**:
- List view of all user bookings
- Display: Booking Code, Package Name, Departure Date, Travelers Count, Total Price, Status
- Filter by status
- Sort by date
- View Details button
- Status badges with colors

**PrimeNG Components**: `p-table`, `p-button`, `p-dropdown`, `p-tag`

#### 4.7.6 Booking Detail Component (Traveler)

**File**: `features/traveler/components/booking-detail/booking-detail.component.ts`

**Sections**:

**Booking Information**:
- Booking Reference (prominent)
- Booking Status (with color badge)
- Booking Date

**Package Details**:
- Package Name
- Agency Name
- Duration
- Departure Date
- Return Date

**Traveler List**:
- Table with all traveler details

**Pricing Breakdown**:
- Base Price per Person
- Number of Travelers
- Total Amount

**Actions** (based on status):
- Download button (placeholder for Phase 1)
- Cancel button (if status allows)

**Features**:
- Display all booking information
- Status-based actions
- Responsive layout

**PrimeNG Components**: `p-card`, `p-table`, `p-tag`, `p-button`


### 4.8 Shared Components

#### 4.8.1 Data Table Component

**File**: `shared/components/data-table/data-table.component.ts`

**Purpose**: Reusable table wrapper around PrimeNG Table

**Features**:
- Configurable columns
- Sorting
- Pagination
- Search
- Loading state
- Empty state
- Action buttons per row

**Inputs**:
```typescript
@Input() data: any[];
@Input() columns: TableColumn[];
@Input() loading: boolean;
@Input() totalRecords: number;
@Input() rows: number = 10;
@Input() paginator: boolean = true;
```

**Outputs**:
```typescript
@Output() onPageChange = new EventEmitter();
@Output() onSort = new EventEmitter();
@Output() onSearch = new EventEmitter();
@Output() onAction = new EventEmitter();
```

#### 4.8.2 Page Header Component

**File**: `shared/components/page-header/page-header.component.ts`

**Purpose**: Consistent page header with title and actions

**Features**:
- Page title
- Breadcrumb navigation
- Action buttons (configurable)

**Inputs**:
```typescript
@Input() title: string;
@Input() breadcrumbs: Breadcrumb[];
@Input() actions: HeaderAction[];
```

#### 4.8.3 Confirmation Dialog Component

**File**: `shared/components/confirmation-dialog/confirmation-dialog.component.ts`

**Purpose**: Reusable confirmation dialog

**Features**:
- Configurable title and message
- Confirm/Cancel buttons
- Loading state
- Icon (warning, info, danger)

**Usage**:
```typescript
this.confirmationService.confirm({
  message: 'Are you sure you want to delete this item?',
  header: 'Confirm Delete',
  icon: 'pi pi-exclamation-triangle',
  accept: () => {
    // Delete action
  }
});
```

#### 4.8.4 Loading Spinner Component

**File**: `shared/components/loading-spinner/loading-spinner.component.ts`

**Purpose**: Consistent loading indicator

**Features**:
- Overlay mode (full screen)
- Inline mode (within component)
- Configurable size and color

**PrimeNG Components**: `p-progressspinner`


---

## 5. Data Models

### 5.1 Core Models

#### User Model

**File**: `core/models/user.model.ts`

```typescript
export interface User {
  id: string;
  email: string;
  full_name: string;
  user_type: 'platform_admin' | 'agency_staff' | 'supplier' | 'customer';
  agency_id?: string;
  supplier_id?: string;
  is_active: boolean;
  created_at: string;
}

export interface AuthResponse {
  token: string;
  user: User;
}
```

#### API Response Model

**File**: `core/models/api-response.model.ts`

```typescript
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  meta?: PaginationMeta;
  error?: ApiError;
}

export interface PaginationMeta {
  page: number;
  per_page: number;
  total: number;
  total_pages: number;
}

export interface ApiError {
  code: string;
  message: string;
  details?: ValidationError[];
}

export interface ValidationError {
  field: string;
  message: string;
}
```


### 5.2 Platform Admin Models

**File**: `features/platform-admin/models/agency.model.ts`

```typescript
export interface Agency {
  id: string;
  agency_code: string;
  company_name: string;
  email: string;
  phone: string;
  address?: string;
  city?: string;
  subscription_plan: 'basic' | 'pro' | 'enterprise';
  commission_rate: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface CreateAgencyDto {
  company_name: string;
  email: string;
  phone: string;
  address?: string;
  city?: string;
  subscription_plan: 'basic' | 'pro' | 'enterprise';
  commission_rate: number;
}
```

**File**: `features/platform-admin/models/supplier.model.ts`

```typescript
export interface Supplier {
  id: string;
  supplier_code: string;
  company_name: string;
  email: string;
  phone: string;
  business_type: string;
  status: 'pending' | 'active' | 'suspended';
  created_at: string;
  updated_at: string;
}

export interface SupplierApprovalDto {
  action: 'approve' | 'reject';
  reason?: string;
}
```


### 5.3 Supplier Models

**File**: `features/supplier/models/service.model.ts`

```typescript
export type ServiceType = 'hotel' | 'flight' | 'visa' | 'transport' | 'guide';

export interface Service {
  id: string;
  service_code: string;
  supplier_id: string;
  service_type: ServiceType;
  name: string;
  description: string;
  base_price: number;
  price_unit: string;
  service_details: HotelDetails | FlightDetails | VisaDetails | TransportDetails | GuideDetails;
  status: 'draft' | 'published' | 'archived';
  visibility: 'marketplace' | 'private';
  created_at: string;
  updated_at: string;
}

export interface HotelDetails {
  hotel_name: string;
  star_rating: number;
  location: string;
  distance_to_haram?: string;
  room_types: RoomType[];
  amenities: string[];
}

export interface RoomType {
  type: 'quad' | 'triple' | 'double' | 'single';
  capacity: number;
  quantity: number;
  price_per_night: number;
}

export interface FlightDetails {
  airline: string;
  flight_number: string;
  origin: string;
  destination: string;
  departure_time: string;
  arrival_time: string;
  class: 'economy' | 'business' | 'first';
  baggage_allowance: string;
}

export interface VisaDetails {
  visa_type: 'tourist' | 'umrah' | 'hajj' | 'business';
  processing_time_days: number;
  validity_period_days: number;
  required_documents: string;
}

export interface TransportDetails {
  vehicle_type: 'bus' | 'van' | 'car';
  capacity: number;
  route_coverage: string;
  driver_included: boolean;
}

export interface GuideDetails {
  guide_name: string;
  languages: string[];
  specialization: 'umrah' | 'hajj' | 'tour';
  experience_years: number;
}

export interface CreateServiceDto {
  service_type: ServiceType;
  name: string;
  description: string;
  base_price: number;
  price_unit: string;
  service_details: any;
  visibility: 'marketplace' | 'private';
}
```


### 5.4 Agency Models

**File**: `features/agency/models/package.model.ts`

```typescript
export interface Package {
  id: string;
  package_code: string;
  agency_id: string;
  package_type: 'umrah' | 'hajj' | 'tour' | 'custom';
  name: string;
  description: string;
  duration_days: number;
  duration_nights: number;
  highlights?: string;
  services: PackageService[];
  base_cost: number;
  markup_type: 'fixed' | 'percentage';
  markup_amount: number;
  selling_price: number;
  departures: PackageDeparture[];
  status: 'draft' | 'published' | 'archived';
  visibility: 'public' | 'private';
  created_at: string;
  updated_at: string;
}

export interface PackageService {
  supplier_service_id: string;
  service_type: ServiceType;
  service_name?: string;
  supplier_name?: string;
  quantity: number;
  unit: string;
  unit_cost: number;
  total_cost: number;
}

export interface PackageDeparture {
  id?: string;
  departure_code: string;
  departure_date: string;
  return_date: string;
  total_quota: number;
  booked_quota: number;
  available_quota: number;
  status: 'scheduled' | 'full' | 'cancelled';
}

export interface CreatePackageDto {
  package_type: 'umrah' | 'hajj' | 'tour' | 'custom';
  name: string;
  description: string;
  duration_days: number;
  duration_nights: number;
  highlights?: string;
  services: PackageService[];
  base_cost: number;
  markup_type: 'fixed' | 'percentage';
  markup_amount: number;
  selling_price: number;
  departures: Omit<PackageDeparture, 'id' | 'booked_quota' | 'available_quota' | 'status'>[];
  visibility: 'public' | 'private';
}
```


**File**: `features/agency/models/booking.model.ts`

```typescript
export interface Booking {
  id: string;
  booking_reference: string;
  agency_id: string;
  package_id: string;
  package_departure_id: string;
  customer_id: string;
  customer_name: string;
  customer_email: string;
  customer_phone: string;
  travelers: Traveler[];
  total_amount: number;
  booking_status: 'pending' | 'approved' | 'confirmed' | 'rejected' | 'cancelled';
  booking_date: string;
  approved_at?: string;
  rejected_at?: string;
  rejection_reason?: string;
  created_at: string;
  updated_at: string;
  
  // Populated fields
  package?: Package;
  departure?: PackageDeparture;
}

export interface Traveler {
  traveler_number: number;
  full_name: string;
  gender: 'male' | 'female';
  date_of_birth: string;
  nationality: string;
  passport_number: string;
  passport_expiry_date: string;
  requires_mahram?: boolean;
  mahram_traveler_number?: number;
  mahram_relationship?: 'husband' | 'father' | 'brother' | 'son';
}

export interface CreateBookingDto {
  package_id: string;
  package_departure_id: string;
  customer_name: string;
  customer_email: string;
  customer_phone: string;
  travelers: Traveler[];
}

export interface BookingActionDto {
  action: 'approve' | 'reject';
  reason?: string;
}
```

### 5.5 Traveler Models

**File**: `features/traveler/models/package.model.ts`

```typescript
// Reuse Package model from agency with additional fields for display
export interface TravelerPackage extends Package {
  agency_name?: string;
  agency_logo?: string;
  image_url?: string;
}
```

**File**: `features/traveler/models/booking.model.ts`

```typescript
// Reuse Booking model from agency
export { Booking, Traveler, CreateBookingDto } from '../../agency/models/booking.model';
```


---

## 6. State Management (NgRx)

### 6.1 Store Structure

```
store/
├── auth/
│   ├── auth.actions.ts
│   ├── auth.reducer.ts
│   ├── auth.effects.ts
│   ├── auth.selectors.ts
│   └── auth.state.ts
├── agency/
│   ├── agency.actions.ts
│   ├── agency.reducer.ts
│   ├── agency.effects.ts
│   ├── agency.selectors.ts
│   └── agency.state.ts
├── supplier/
├── package/
├── booking/
└── index.ts
```

### 6.2 Auth Store

**File**: `store/auth/auth.state.ts`

```typescript
export interface AuthState {
  user: User | null;
  token: string | null;
  loading: boolean;
  error: string | null;
}

export const initialAuthState: AuthState = {
  user: null,
  token: null,
  loading: false,
  error: null
};
```

**File**: `store/auth/auth.actions.ts`

```typescript
import { createAction, props } from '@ngrx/store';
import { User, AuthResponse } from '@core/models/user.model';

export const login = createAction(
  '[Auth] Login',
  props<{ email: string; password: string }>()
);

export const loginSuccess = createAction(
  '[Auth] Login Success',
  props<{ response: AuthResponse }>()
);

export const loginFailure = createAction(
  '[Auth] Login Failure',
  props<{ error: string }>()
);

export const logout = createAction('[Auth] Logout');

export const loadUser = createAction('[Auth] Load User');

export const loadUserSuccess = createAction(
  '[Auth] Load User Success',
  props<{ user: User }>()
);

export const loadUserFailure = createAction(
  '[Auth] Load User Failure',
  props<{ error: string }>()
);
```


**File**: `store/auth/auth.reducer.ts`

```typescript
import { createReducer, on } from '@ngrx/store';
import * as AuthActions from './auth.actions';
import { initialAuthState } from './auth.state';

export const authReducer = createReducer(
  initialAuthState,
  
  on(AuthActions.login, (state) => ({
    ...state,
    loading: true,
    error: null
  })),
  
  on(AuthActions.loginSuccess, (state, { response }) => ({
    ...state,
    user: response.user,
    token: response.token,
    loading: false,
    error: null
  })),
  
  on(AuthActions.loginFailure, (state, { error }) => ({
    ...state,
    loading: false,
    error
  })),
  
  on(AuthActions.logout, () => initialAuthState),
  
  on(AuthActions.loadUserSuccess, (state, { user }) => ({
    ...state,
    user
  }))
);
```

**File**: `store/auth/auth.effects.ts`

```typescript
import { Injectable } from '@angular/core';
import { Actions, createEffect, ofType } from '@ngrx/effects';
import { Router } from '@angular/router';
import { of } from 'rxjs';
import { map, catchError, tap, switchMap } from 'rxjs/operators';
import { AuthService } from '@core/services/auth.service';
import * as AuthActions from './auth.actions';

@Injectable()
export class AuthEffects {
  login$ = createEffect(() =>
    this.actions$.pipe(
      ofType(AuthActions.login),
      switchMap(({ email, password }) =>
        this.authService.login(email, password).pipe(
          map((response) => AuthActions.loginSuccess({ response })),
          catchError((error) => of(AuthActions.loginFailure({ error: error.message })))
        )
      )
    )
  );

  loginSuccess$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(AuthActions.loginSuccess),
        tap(({ response }) => {
          // Store token
          localStorage.setItem('token', response.token);
          
          // Redirect based on user type
          const redirectMap = {
            'platform_admin': '/admin/dashboard',
            'supplier': '/supplier/dashboard',
            'agency_staff': '/agency/dashboard',
            'customer': '/traveler/home'
          };
          
          const redirectUrl = redirectMap[response.user.user_type] || '/';
          this.router.navigate([redirectUrl]);
        })
      ),
    { dispatch: false }
  );

  logout$ = createEffect(
    () =>
      this.actions$.pipe(
        ofType(AuthActions.logout),
        tap(() => {
          localStorage.removeItem('token');
          this.router.navigate(['/auth/login']);
        })
      ),
    { dispatch: false }
  );

  constructor(
    private actions$: Actions,
    private authService: AuthService,
    private router: Router
  ) {}
}
```

**File**: `store/auth/auth.selectors.ts`

```typescript
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { AuthState } from './auth.state';

export const selectAuthState = createFeatureSelector<AuthState>('auth');

export const selectUser = createSelector(
  selectAuthState,
  (state) => state.user
);

export const selectToken = createSelector(
  selectAuthState,
  (state) => state.token
);

export const selectIsAuthenticated = createSelector(
  selectAuthState,
  (state) => !!state.token
);

export const selectAuthLoading = createSelector(
  selectAuthState,
  (state) => state.loading
);

export const selectAuthError = createSelector(
  selectAuthState,
  (state) => state.error
);

export const selectUserType = createSelector(
  selectUser,
  (user) => user?.user_type
);
```


### 6.3 Package Store (Example)

**File**: `store/package/package.state.ts`

```typescript
import { Package } from '@features/agency/models/package.model';

export interface PackageState {
  packages: Package[];
  selectedPackage: Package | null;
  loading: boolean;
  error: string | null;
}

export const initialPackageState: PackageState = {
  packages: [],
  selectedPackage: null,
  loading: false,
  error: null
};
```

**Actions**: Load packages, create package, update package, delete package, publish package

**Effects**: Handle API calls for package operations

**Selectors**: Select packages list, selected package, loading state, error state

### 6.4 Root Store Configuration

**File**: `store/index.ts`

```typescript
import { ActionReducerMap } from '@ngrx/store';
import { authReducer } from './auth/auth.reducer';
import { AuthState } from './auth/auth.state';

export interface AppState {
  auth: AuthState;
  // Add other feature states here
}

export const reducers: ActionReducerMap<AppState> = {
  auth: authReducer,
  // Add other reducers here
};
```

**File**: `app.config.ts`

```typescript
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideStore } from '@ngrx/store';
import { provideEffects } from '@ngrx/effects';
import { provideStoreDevtools } from '@ngrx/store-devtools';
import { provideAnimations } from '@angular/platform-browser/animations';

import { routes } from './app.routes';
import { reducers } from './store';
import { AuthEffects } from './store/auth/auth.effects';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { errorInterceptor } from './core/interceptors/error.interceptor';
import { loadingInterceptor } from './core/interceptors/loading.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(
      withInterceptors([authInterceptor, errorInterceptor, loadingInterceptor])
    ),
    provideAnimations(),
    provideStore(reducers),
    provideEffects([AuthEffects]),
    provideStoreDevtools({ maxAge: 25 })
  ]
};
```


---

## 7. Routing Configuration

### 7.1 Root Routes

**File**: `app.routes.ts`

```typescript
import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';
import { roleGuard } from './core/guards/role.guard';

export const routes: Routes = [
  {
    path: '',
    redirectTo: '/auth/login',
    pathMatch: 'full'
  },
  {
    path: 'auth',
    loadComponent: () => import('./layouts/auth-layout/auth-layout.component')
      .then(m => m.AuthLayoutComponent),
    loadChildren: () => import('./features/auth/auth.routes')
      .then(m => m.AUTH_ROUTES)
  },
  {
    path: 'admin',
    loadComponent: () => import('./layouts/main-layout/main-layout.component')
      .then(m => m.MainLayoutComponent),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['platform_admin'] },
    loadChildren: () => import('./features/platform-admin/platform-admin.routes')
      .then(m => m.PLATFORM_ADMIN_ROUTES)
  },
  {
    path: 'supplier',
    loadComponent: () => import('./layouts/main-layout/main-layout.component')
      .then(m => m.MainLayoutComponent),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['supplier'] },
    loadChildren: () => import('./features/supplier/supplier.routes')
      .then(m => m.SUPPLIER_ROUTES)
  },
  {
    path: 'agency',
    loadComponent: () => import('./layouts/main-layout/main-layout.component')
      .then(m => m.MainLayoutComponent),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['agency_staff'] },
    loadChildren: () => import('./features/agency/agency.routes')
      .then(m => m.AGENCY_ROUTES)
  },
  {
    path: 'traveler',
    loadComponent: () => import('./layouts/main-layout/main-layout.component')
      .then(m => m.MainLayoutComponent),
    canActivate: [authGuard, roleGuard],
    data: { roles: ['customer'] },
    loadChildren: () => import('./features/traveler/traveler.routes')
      .then(m => m.TRAVELER_ROUTES)
  },
  {
    path: '**',
    redirectTo: '/auth/login'
  }
];
```


### 7.2 Feature Routes

**File**: `features/auth/auth.routes.ts`

```typescript
import { Routes } from '@angular/router';

export const AUTH_ROUTES: Routes = [
  {
    path: 'login',
    loadComponent: () => import('./components/login/login.component')
      .then(m => m.LoginComponent)
  },
  {
    path: 'register',
    loadComponent: () => import('./components/register/register.component')
      .then(m => m.RegisterComponent)
  }
];
```

**File**: `features/platform-admin/platform-admin.routes.ts`

```typescript
import { Routes } from '@angular/router';

export const PLATFORM_ADMIN_ROUTES: Routes = [
  {
    path: 'dashboard',
    loadComponent: () => import('./components/dashboard/dashboard.component')
      .then(m => m.DashboardComponent)
  },
  {
    path: 'agencies',
    loadComponent: () => import('./components/agency-list/agency-list.component')
      .then(m => m.AgencyListComponent)
  },
  {
    path: 'agencies/new',
    loadComponent: () => import('./components/agency-form/agency-form.component')
      .then(m => m.AgencyFormComponent)
  },
  {
    path: 'agencies/:id/edit',
    loadComponent: () => import('./components/agency-form/agency-form.component')
      .then(m => m.AgencyFormComponent)
  },
  {
    path: 'suppliers',
    loadComponent: () => import('./components/supplier-list/supplier-list.component')
      .then(m => m.SupplierListComponent)
  },
  {
    path: 'suppliers/:id',
    loadComponent: () => import('./components/supplier-approval/supplier-approval.component')
      .then(m => m.SupplierApprovalComponent)
  }
];
```

**File**: `features/supplier/supplier.routes.ts`

```typescript
import { Routes } from '@angular/router';

export const SUPPLIER_ROUTES: Routes = [
  {
    path: 'dashboard',
    loadComponent: () => import('./components/dashboard/dashboard.component')
      .then(m => m.DashboardComponent)
  },
  {
    path: 'services',
    loadComponent: () => import('./components/service-list/service-list.component')
      .then(m => m.ServiceListComponent)
  },
  {
    path: 'services/new',
    loadComponent: () => import('./components/service-form/service-form.component')
      .then(m => m.ServiceFormComponent)
  },
  {
    path: 'services/:id/edit',
    loadComponent: () => import('./components/service-form/service-form.component')
      .then(m => m.ServiceFormComponent)
  },
  {
    path: 'services/:id',
    loadComponent: () => import('./components/service-detail/service-detail.component')
      .then(m => m.ServiceDetailComponent)
  }
];
```


**File**: `features/agency/agency.routes.ts`

```typescript
import { Routes } from '@angular/router';

export const AGENCY_ROUTES: Routes = [
  {
    path: 'dashboard',
    loadComponent: () => import('./components/dashboard/dashboard.component')
      .then(m => m.DashboardComponent)
  },
  {
    path: 'service-catalog',
    loadComponent: () => import('./components/service-catalog/service-catalog.component')
      .then(m => m.ServiceCatalogComponent)
  },
  {
    path: 'packages',
    loadComponent: () => import('./components/package-list/package-list.component')
      .then(m => m.PackageListComponent)
  },
  {
    path: 'packages/new',
    loadComponent: () => import('./components/package-form/package-form.component')
      .then(m => m.PackageFormComponent)
  },
  {
    path: 'packages/:id/edit',
    loadComponent: () => import('./components/package-form/package-form.component')
      .then(m => m.PackageFormComponent)
  },
  {
    path: 'packages/:id',
    loadComponent: () => import('./components/package-detail/package-detail.component')
      .then(m => m.PackageDetailComponent)
  },
  {
    path: 'bookings',
    loadComponent: () => import('./components/booking-list/booking-list.component')
      .then(m => m.BookingListComponent)
  },
  {
    path: 'bookings/:id',
    loadComponent: () => import('./components/booking-detail/booking-detail.component')
      .then(m => m.BookingDetailComponent)
  }
];
```

**File**: `features/traveler/traveler.routes.ts`

```typescript
import { Routes } from '@angular/router';

export const TRAVELER_ROUTES: Routes = [
  {
    path: 'home',
    loadComponent: () => import('./components/home/home.component')
      .then(m => m.HomeComponent)
  },
  {
    path: 'packages',
    loadComponent: () => import('./components/package-browse/package-browse.component')
      .then(m => m.PackageBrowseComponent)
  },
  {
    path: 'packages/:id',
    loadComponent: () => import('./components/package-detail/package-detail.component')
      .then(m => m.PackageDetailComponent)
  },
  {
    path: 'packages/:id/book',
    loadComponent: () => import('./components/booking-form/booking-form.component')
      .then(m => m.BookingFormComponent)
  },
  {
    path: 'my-bookings',
    loadComponent: () => import('./components/my-bookings/my-bookings.component')
      .then(m => m.MyBookingsComponent)
  },
  {
    path: 'my-bookings/:id',
    loadComponent: () => import('./components/booking-detail/booking-detail.component')
      .then(m => m.BookingDetailComponent)
  }
];
```

### 7.3 Route Guards

**File**: `core/guards/auth.guard.ts`

```typescript
import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { Store } from '@ngrx/store';
import { map } from 'rxjs/operators';
import { selectIsAuthenticated } from '@store/auth/auth.selectors';

export const authGuard: CanActivateFn = () => {
  const store = inject(Store);
  const router = inject(Router);

  return store.select(selectIsAuthenticated).pipe(
    map(isAuthenticated => {
      if (!isAuthenticated) {
        router.navigate(['/auth/login']);
        return false;
      }
      return true;
    })
  );
};
```

**File**: `core/guards/role.guard.ts`

```typescript
import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { Store } from '@ngrx/store';
import { map } from 'rxjs/operators';
import { selectUserType } from '@store/auth/auth.selectors';

export const roleGuard: CanActivateFn = (route) => {
  const store = inject(Store);
  const router = inject(Router);
  const allowedRoles = route.data['roles'] as string[];

  return store.select(selectUserType).pipe(
    map(userType => {
      if (!userType || !allowedRoles.includes(userType)) {
        router.navigate(['/auth/login']);
        return false;
      }
      return true;
    })
  );
};
```


---

## 8. Styling Guidelines

### 8.1 TailwindCSS Configuration

**File**: `tailwind.config.js`

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{html,ts}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          200: '#bfdbfe',
          300: '#93c5fd',
          400: '#60a5fa',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
          800: '#1e40af',
          900: '#1e3a8a',
        },
        secondary: {
          50: '#f5f3ff',
          100: '#ede9fe',
          200: '#ddd6fe',
          300: '#c4b5fd',
          400: '#a78bfa',
          500: '#8b5cf6',
          600: '#7c3aed',
          700: '#6d28d9',
          800: '#5b21b6',
          900: '#4c1d95',
        }
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
```

### 8.2 PrimeNG Theme Configuration

**File**: `app.config.ts` (add PrimeNG theme provider)

```typescript
import { providePrimeNG } from 'primeng/config';
import Aura from '@primeng/themes/aura';

export const appConfig: ApplicationConfig = {
  providers: [
    // ... other providers
    providePrimeNG({
      theme: {
        preset: Aura,
        options: {
          darkModeSelector: false,
          cssLayer: {
            name: 'primeng',
            order: 'tailwind-base, primeng, tailwind-utilities'
          }
        }
      }
    })
  ]
};
```

### 8.3 Global Styles

**File**: `styles.scss`

```scss
@import 'primeng/resources/themes/lara-light-blue/theme.css';
@import 'primeng/resources/primeng.css';
@import 'primeicons/primeicons.css';

@tailwind base;
@tailwind components;
@tailwind utilities;

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Inter', sans-serif;
  @apply bg-gray-50 text-gray-900;
}

// Custom utility classes
@layer components {
  .card {
    @apply bg-white rounded-lg shadow-sm p-6;
  }
  
  .btn-primary {
    @apply bg-primary-600 text-white px-4 py-2 rounded-md hover:bg-primary-700 transition-colors;
  }
  
  .btn-secondary {
    @apply bg-gray-200 text-gray-700 px-4 py-2 rounded-md hover:bg-gray-300 transition-colors;
  }
  
  .input-field {
    @apply w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary-500;
  }
}
```


### 8.4 Component Styling Patterns

**Consistent Spacing**:
- Use Tailwind spacing scale: `p-4`, `m-6`, `gap-4`
- Page padding: `p-6`
- Card padding: `p-6`
- Form field spacing: `space-y-4`

**Responsive Design**:
```html
<!-- Mobile-first approach -->
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <!-- Cards -->
</div>
```

**Color Usage**:
- Primary actions: `bg-primary-600 hover:bg-primary-700`
- Secondary actions: `bg-gray-200 hover:bg-gray-300`
- Danger actions: `bg-red-600 hover:bg-red-700`
- Success states: `bg-green-600`
- Warning states: `bg-yellow-600`

**Typography**:
- Page titles: `text-2xl font-bold text-gray-900`
- Section titles: `text-xl font-semibold text-gray-800`
- Body text: `text-base text-gray-700`
- Small text: `text-sm text-gray-600`

**Status Badges**:
```html
<p-tag 
  [value]="status" 
  [severity]="getStatusSeverity(status)"
  class="text-sm"
/>
```

---

## 9. API Integration

### 9.1 HTTP Interceptors

#### Auth Interceptor

**File**: `core/interceptors/auth.interceptor.ts`

```typescript
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Store } from '@ngrx/store';
import { switchMap, take } from 'rxjs/operators';
import { selectToken } from '@store/auth/auth.selectors';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const store = inject(Store);

  return store.select(selectToken).pipe(
    take(1),
    switchMap(token => {
      if (token) {
        const cloned = req.clone({
          setHeaders: {
            Authorization: `Bearer ${token}`
          }
        });
        return next(cloned);
      }
      return next(req);
    })
  );
};
```

#### Error Interceptor

**File**: `core/interceptors/error.interceptor.ts`

```typescript
import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { NotificationService } from '@core/services/notification.service';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const notificationService = inject(NotificationService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An error occurred';

      if (error.error instanceof ErrorEvent) {
        // Client-side error
        errorMessage = error.error.message;
      } else {
        // Server-side error
        if (error.status === 401) {
          // Unauthorized - redirect to login
          router.navigate(['/auth/login']);
          errorMessage = 'Session expired. Please login again.';
        } else if (error.status === 403) {
          errorMessage = 'You do not have permission to access this resource.';
        } else if (error.status === 404) {
          errorMessage = 'Resource not found.';
        } else if (error.status === 500) {
          errorMessage = 'Server error. Please try again later.';
        } else if (error.error?.error?.message) {
          errorMessage = error.error.error.message;
        }
      }

      notificationService.showError(errorMessage);
      return throwError(() => new Error(errorMessage));
    })
  );
};
```

#### Loading Interceptor

**File**: `core/interceptors/loading.interceptor.ts`

```typescript
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { finalize } from 'rxjs/operators';
import { LoadingService } from '@core/services/loading.service';

export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  const loadingService = inject(LoadingService);
  
  loadingService.show();

  return next(req).pipe(
    finalize(() => loadingService.hide())
  );
};
```


### 9.2 API Service Pattern

**Base API Service**:

**File**: `core/services/base-api.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { environment } from '@env/environment';
import { ApiResponse, PaginationMeta } from '@core/models/api-response.model';

@Injectable({
  providedIn: 'root'
})
export class BaseApiService {
  protected baseUrl = environment.apiUrl;

  constructor(protected http: HttpClient) {}

  protected get<T>(endpoint: string, params?: any): Observable<T> {
    const httpParams = this.buildParams(params);
    return this.http.get<ApiResponse<T>>(`${this.baseUrl}${endpoint}`, { params: httpParams })
      .pipe(map(response => response.data as T));
  }

  protected post<T>(endpoint: string, body: any): Observable<T> {
    return this.http.post<ApiResponse<T>>(`${this.baseUrl}${endpoint}`, body)
      .pipe(map(response => response.data as T));
  }

  protected put<T>(endpoint: string, body: any): Observable<T> {
    return this.http.put<ApiResponse<T>>(`${this.baseUrl}${endpoint}`, body)
      .pipe(map(response => response.data as T));
  }

  protected patch<T>(endpoint: string, body?: any): Observable<T> {
    return this.http.patch<ApiResponse<T>>(`${this.baseUrl}${endpoint}`, body)
      .pipe(map(response => response.data as T));
  }

  protected delete<T>(endpoint: string): Observable<T> {
    return this.http.delete<ApiResponse<T>>(`${this.baseUrl}${endpoint}`)
      .pipe(map(response => response.data as T));
  }

  private buildParams(params?: any): HttpParams {
    let httpParams = new HttpParams();
    if (params) {
      Object.keys(params).forEach(key => {
        if (params[key] !== null && params[key] !== undefined) {
          httpParams = httpParams.set(key, params[key].toString());
        }
      });
    }
    return httpParams;
  }
}
```

**Example Feature API Service**:

**File**: `features/agency/services/package-api.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { BaseApiService } from '@core/services/base-api.service';
import { Package, CreatePackageDto } from '../models/package.model';

@Injectable({
  providedIn: 'root'
})
export class PackageApiService extends BaseApiService {
  private endpoint = '/packages';

  getPackages(params?: any): Observable<Package[]> {
    return this.get<Package[]>(this.endpoint, params);
  }

  getPackageById(id: string): Observable<Package> {
    return this.get<Package>(`${this.endpoint}/${id}`);
  }

  createPackage(data: CreatePackageDto): Observable<Package> {
    return this.post<Package>(this.endpoint, data);
  }

  updatePackage(id: string, data: Partial<CreatePackageDto>): Observable<Package> {
    return this.put<Package>(`${this.endpoint}/${id}`, data);
  }

  deletePackage(id: string): Observable<void> {
    return this.delete<void>(`${this.endpoint}/${id}`);
  }

  publishPackage(id: string): Observable<Package> {
    return this.patch<Package>(`${this.endpoint}/${id}/publish`);
  }
}
```

### 9.3 Environment Configuration

**File**: `environments/environment.ts`

```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/v1',
  apiTimeout: 30000
};
```

**File**: `environments/environment.prod.ts`

```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.tourtravel.com/v1',
  apiTimeout: 30000
};
```


---

## 10. Error Handling

### 10.1 Error Handling Strategy

**Levels of Error Handling**:

1. **HTTP Interceptor Level**: Catch all HTTP errors, handle authentication errors
2. **Service Level**: Handle business logic errors, transform error messages
3. **Component Level**: Display user-friendly error messages, handle UI-specific errors
4. **NgRx Effects Level**: Handle state management errors, dispatch error actions

### 10.2 Notification Service

**File**: `core/services/notification.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { MessageService } from 'primeng/api';

@Injectable({
  providedIn: 'root'
})
export class NotificationService {
  constructor(private messageService: MessageService) {}

  showSuccess(message: string, title: string = 'Success') {
    this.messageService.add({
      severity: 'success',
      summary: title,
      detail: message,
      life: 3000
    });
  }

  showError(message: string, title: string = 'Error') {
    this.messageService.add({
      severity: 'error',
      summary: title,
      detail: message,
      life: 5000
    });
  }

  showWarning(message: string, title: string = 'Warning') {
    this.messageService.add({
      severity: 'warn',
      summary: title,
      detail: message,
      life: 4000
    });
  }

  showInfo(message: string, title: string = 'Info') {
    this.messageService.add({
      severity: 'info',
      summary: title,
      detail: message,
      life: 3000
    });
  }

  clear() {
    this.messageService.clear();
  }
}
```

### 10.3 Form Validation Error Handling

**Validation Utility**:

**File**: `shared/utils/validation.utils.ts`

```typescript
import { AbstractControl, ValidationErrors } from '@angular/forms';

export class ValidationUtils {
  static getErrorMessage(control: AbstractControl, fieldName: string): string {
    if (control.hasError('required')) {
      return `${fieldName} is required`;
    }
    if (control.hasError('email')) {
      return 'Please enter a valid email address';
    }
    if (control.hasError('minlength')) {
      const minLength = control.errors?.['minlength'].requiredLength;
      return `${fieldName} must be at least ${minLength} characters`;
    }
    if (control.hasError('maxlength')) {
      const maxLength = control.errors?.['maxlength'].requiredLength;
      return `${fieldName} must not exceed ${maxLength} characters`;
    }
    if (control.hasError('pattern')) {
      return `${fieldName} format is invalid`;
    }
    if (control.hasError('min')) {
      const min = control.errors?.['min'].min;
      return `${fieldName} must be at least ${min}`;
    }
    if (control.hasError('max')) {
      const max = control.errors?.['max'].max;
      return `${fieldName} must not exceed ${max}`;
    }
    return `${fieldName} is invalid`;
  }

  static markFormGroupTouched(formGroup: any) {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      control?.markAsTouched();

      if (control instanceof FormGroup) {
        this.markFormGroupTouched(control);
      }
    });
  }
}
```

**Component Usage**:

```typescript
// In component
getErrorMessage(fieldName: string): string {
  const control = this.form.get(fieldName);
  if (control && control.invalid && (control.dirty || control.touched)) {
    return ValidationUtils.getErrorMessage(control, fieldName);
  }
  return '';
}

onSubmit() {
  if (this.form.invalid) {
    ValidationUtils.markFormGroupTouched(this.form);
    this.notificationService.showError('Please fix the form errors');
    return;
  }
  // Submit logic
}
```


### 10.4 Loading States

**Loading Service**:

**File**: `core/services/loading.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class LoadingService {
  private loadingSubject = new BehaviorSubject<boolean>(false);
  private requestCount = 0;

  loading$: Observable<boolean> = this.loadingSubject.asObservable();

  show() {
    this.requestCount++;
    this.loadingSubject.next(true);
  }

  hide() {
    this.requestCount--;
    if (this.requestCount <= 0) {
      this.requestCount = 0;
      this.loadingSubject.next(false);
    }
  }

  reset() {
    this.requestCount = 0;
    this.loadingSubject.next(false);
  }
}
```

**Global Loading Indicator**:

```html
<!-- In app.html -->
<p-toast />
<p-blockUI [blocked]="loading$ | async">
  <p-progressSpinner />
</p-blockUI>
<router-outlet />
```

**Component-Level Loading**:

```typescript
// In component
isLoading = false;

loadData() {
  this.isLoading = true;
  this.apiService.getData().subscribe({
    next: (data) => {
      this.data = data;
      this.isLoading = false;
    },
    error: () => {
      this.isLoading = false;
    }
  });
}
```

```html
<!-- In template -->
<p-table [value]="data" [loading]="isLoading">
  <!-- Table content -->
</p-table>
```

---

## 11. Testing Strategy

### 11.1 Testing Approach

**Testing Pyramid**:
- **Unit Tests**: Services, utilities, pipes (70%)
- **Component Tests**: Component logic and templates (20%)
- **E2E Tests**: Critical user flows (10%) - Optional for Phase 1

**Focus Areas for Phase 1**:
- Core services (AuthService, API services)
- Utility functions (validation, date formatting)
- Critical business logic
- NgRx reducers and selectors

### 11.2 Unit Testing

**Service Testing Example**:

**File**: `core/services/auth.service.spec.ts`

```typescript
import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [AuthService]
    });
    service = TestBed.inject(AuthService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpMock.verify();
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should login successfully', () => {
    const mockResponse = {
      success: true,
      data: {
        token: 'test-token',
        user: { id: '1', email: 'test@test.com', user_type: 'customer' }
      }
    };

    service.login('test@test.com', 'password').subscribe(response => {
      expect(response.token).toBe('test-token');
      expect(response.user.email).toBe('test@test.com');
    });

    const req = httpMock.expectOne(`${service['baseUrl']}/auth/login`);
    expect(req.request.method).toBe('POST');
    req.flush(mockResponse);
  });
});
```

**Utility Testing Example**:

**File**: `shared/utils/validation.utils.spec.ts`

```typescript
import { FormControl, Validators } from '@angular/forms';
import { ValidationUtils } from './validation.utils';

describe('ValidationUtils', () => {
  it('should return required error message', () => {
    const control = new FormControl('', Validators.required);
    control.markAsTouched();
    const message = ValidationUtils.getErrorMessage(control, 'Email');
    expect(message).toBe('Email is required');
  });

  it('should return email error message', () => {
    const control = new FormControl('invalid-email', Validators.email);
    control.markAsTouched();
    const message = ValidationUtils.getErrorMessage(control, 'Email');
    expect(message).toBe('Please enter a valid email address');
  });
});
```


### 11.3 Component Testing

**Component Testing Example**:

**File**: `features/auth/components/login/login.component.spec.ts`

```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { Store } from '@ngrx/store';
import { of } from 'rxjs';
import { LoginComponent } from './login.component';

describe('LoginComponent', () => {
  let component: LoginComponent;
  let fixture: ComponentFixture<LoginComponent>;
  let mockStore: jasmine.SpyObj<Store>;

  beforeEach(async () => {
    mockStore = jasmine.createSpyObj('Store', ['dispatch', 'select']);
    mockStore.select.and.returnValue(of(false));

    await TestBed.configureTestingModule({
      imports: [LoginComponent, ReactiveFormsModule],
      providers: [
        { provide: Store, useValue: mockStore }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(LoginComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should have invalid form when empty', () => {
    expect(component.loginForm.valid).toBeFalsy();
  });

  it('should validate email field', () => {
    const email = component.loginForm.get('email');
    email?.setValue('invalid-email');
    expect(email?.hasError('email')).toBeTruthy();
    
    email?.setValue('valid@email.com');
    expect(email?.hasError('email')).toBeFalsy();
  });

  it('should dispatch login action on submit', () => {
    component.loginForm.setValue({
      email: 'test@test.com',
      password: 'password123',
      rememberMe: false
    });

    component.onSubmit();

    expect(mockStore.dispatch).toHaveBeenCalled();
  });
});
```

### 11.4 NgRx Testing

**Reducer Testing Example**:

**File**: `store/auth/auth.reducer.spec.ts`

```typescript
import { authReducer } from './auth.reducer';
import { initialAuthState } from './auth.state';
import * as AuthActions from './auth.actions';

describe('Auth Reducer', () => {
  it('should return initial state', () => {
    const action = { type: 'Unknown' };
    const state = authReducer(initialAuthState, action);
    expect(state).toBe(initialAuthState);
  });

  it('should set loading to true on login', () => {
    const action = AuthActions.login({ email: 'test@test.com', password: 'password' });
    const state = authReducer(initialAuthState, action);
    expect(state.loading).toBe(true);
    expect(state.error).toBeNull();
  });

  it('should set user and token on login success', () => {
    const mockResponse = {
      token: 'test-token',
      user: { id: '1', email: 'test@test.com', user_type: 'customer' as const }
    };
    const action = AuthActions.loginSuccess({ response: mockResponse });
    const state = authReducer(initialAuthState, action);
    
    expect(state.user).toEqual(mockResponse.user);
    expect(state.token).toBe('test-token');
    expect(state.loading).toBe(false);
    expect(state.error).toBeNull();
  });
});
```

### 11.5 Test Coverage Goals

**Phase 1 Coverage Targets**:
- Core services: 80%+
- Utilities: 90%+
- NgRx reducers: 90%+
- Components: 50%+ (focus on critical components)

**Testing Commands**:

```json
// package.json
{
  "scripts": {
    "test": "ng test",
    "test:coverage": "ng test --code-coverage",
    "test:watch": "ng test --watch"
  }
}
```

---

## 12. Correctness Properties

### 12.1 What are Correctness Properties?

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

In this frontend application, correctness properties define the invariants and behaviors that must hold true across all user interactions, data states, and system conditions.

### 12.2 Property Reflection

After analyzing all acceptance criteria, we identified the following testable properties. Through reflection, we eliminated redundant properties and combined related ones:

**Redundancy Analysis**:
- Form validation properties across different forms (login, registration, agency creation, etc.) can be generalized into a single validation property
- Loading state properties across different operations can be combined
- Success flow properties (show message + redirect) can be combined
- Multiple "display required fields" examples can be consolidated

**Combined Properties**:
- All form validation → Single property about reactive form validation
- All loading states → Single property about loading indicators
- All success flows → Single property about success handling
- Search/filter operations → Single property about data filtering


### 12.3 Core Properties

#### Property 1: Form Validation Consistency

*For any* reactive form in the application, when a required field is empty or invalid, the form should be marked as invalid and prevent submission.

**Validates: Requirements US-1.1, US-1.2, US-2.3, US-3.3, US-4.4, US-5.4**

**Rationale**: Ensures consistent validation behavior across all forms in the application.

#### Property 2: Role-Based Routing

*For any* authenticated user, when they attempt to access a route, they should only be able to access routes that match their user role, otherwise they should be redirected to login.

**Validates: Requirements 3.3 (Security - Role-based route guards)**

**Rationale**: Ensures proper access control throughout the application.

#### Property 3: Authentication Token Persistence

*For any* successful login, the JWT token should be stored in localStorage and included in all subsequent API requests.

**Validates: Requirements US-1.1 (Store JWT token securely)**

**Rationale**: Ensures authentication state is maintained across page refreshes and API calls.

#### Property 4: Search and Filter Correctness

*For any* list view with search or filter functionality, the displayed results should only include items that match all active search and filter criteria.

**Validates: Requirements US-2.2, US-3.2, US-4.3, US-5.2**

**Rationale**: Ensures data filtering works correctly across all list views.

#### Property 5: Package Cost Calculation

*For any* package being created or edited, the base cost should equal the sum of all selected service costs, and the selling price should equal base cost plus markup (fixed amount or percentage).

**Validates: Requirements US-4.4 (Auto-calculate base cost, Auto-calculate selling price)**

**Rationale**: Ensures pricing calculations are always correct.

#### Property 6: Booking Price Calculation

*For any* booking being created, the total price should equal the package selling price multiplied by the number of travelers.

**Validates: Requirements US-5.4 (Price calculation)**

**Rationale**: Ensures booking prices are calculated correctly.

#### Property 7: Quota Management

*For any* booking approval, the departure's available quota should decrease by the number of travelers in the booking, and available quota should never be negative.

**Validates: Requirements US-4.7 (Deduct quota from departure)**

**Rationale**: Ensures quota tracking is accurate and prevents overbooking.

#### Property 8: Mahram Validation

*For any* booking with female travelers, if a female traveler is marked as requiring mahram, she must have a valid mahram relationship assigned to a male traveler in the same booking.

**Validates: Requirements US-5.4 (Mahram validation)**

**Rationale**: Ensures religious requirements are properly validated.

#### Property 9: Loading State Management

*For any* asynchronous operation (API call), a loading indicator should be displayed while the operation is in progress and hidden when it completes (success or error).

**Validates: Requirements US-1.1, US-1.2, US-2.3, US-3.3, US-4.4**

**Rationale**: Ensures consistent user feedback during asynchronous operations.

#### Property 10: Error Message Display

*For any* failed operation (validation error, API error), an appropriate error message should be displayed to the user.

**Validates: Requirements US-1.1 (Show error message on failed login), 3.3 (Error handling)**

**Rationale**: Ensures users receive feedback when operations fail.

#### Property 11: Token Expiry Handling

*For any* API request that returns a 401 Unauthorized status, the user should be logged out and redirected to the login page.

**Validates: Requirements 3.3 (Token expiry handling, Automatic logout)**

**Rationale**: Ensures expired sessions are handled gracefully.

#### Property 12: Draft Persistence

*For any* multi-step form with "Save as Draft" functionality, saving a draft should persist all entered data and allow resuming from the same step later.

**Validates: Requirements US-3.3, US-4.4 (Save as draft functionality)**

**Rationale**: Ensures users don't lose work in complex forms.


### 12.4 Property Testing Implementation

**Testing Library**: Use Jasmine with Angular Testing utilities for property-based testing patterns.

**Test Configuration**:
- Minimum 100 iterations per property test (using loops or data-driven tests)
- Each test should reference its design document property
- Tag format: `// Feature: phase-1-frontend, Property {number}: {property_text}`

**Example Property Test**:

```typescript
// Feature: phase-1-frontend, Property 5: Package Cost Calculation
describe('Property 5: Package Cost Calculation', () => {
  it('should calculate base cost as sum of all service costs', () => {
    // Generate 100 random package configurations
    for (let i = 0; i < 100; i++) {
      const services = generateRandomServices();
      const baseCost = calculateBaseCost(services);
      const expectedCost = services.reduce((sum, s) => sum + s.total_cost, 0);
      expect(baseCost).toBe(expectedCost);
    }
  });

  it('should calculate selling price with fixed markup', () => {
    for (let i = 0; i < 100; i++) {
      const baseCost = Math.random() * 10000;
      const markup = Math.random() * 1000;
      const sellingPrice = calculateSellingPrice(baseCost, 'fixed', markup);
      expect(sellingPrice).toBe(baseCost + markup);
    }
  });

  it('should calculate selling price with percentage markup', () => {
    for (let i = 0; i < 100; i++) {
      const baseCost = Math.random() * 10000;
      const markupPercent = Math.random() * 50; // 0-50%
      const sellingPrice = calculateSellingPrice(baseCost, 'percentage', markupPercent);
      const expected = baseCost * (1 + markupPercent / 100);
      expect(sellingPrice).toBeCloseTo(expected, 2);
    }
  });
});
```

---

## 13. Performance Considerations

### 13.1 Bundle Optimization

**Lazy Loading**:
- All feature modules loaded on-demand
- Reduces initial bundle size
- Improves first contentful paint

**Code Splitting**:
```typescript
// Route-based code splitting
{
  path: 'agency',
  loadChildren: () => import('./features/agency/agency.routes')
    .then(m => m.AGENCY_ROUTES)
}
```

**Tree Shaking**:
- Import only used PrimeNG components
- Use standalone components to eliminate unused code
- Configure production build for optimal tree shaking

### 13.2 Change Detection Optimization

**OnPush Strategy**:
```typescript
@Component({
  selector: 'app-package-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  // ...
})
```

**TrackBy Functions**:
```typescript
trackByPackageId(index: number, package: Package): string {
  return package.id;
}
```

```html
<div *ngFor="let package of packages; trackBy: trackByPackageId">
  <!-- Package card -->
</div>
```

### 13.3 Data Caching

**NgRx Entity Adapter**:
```typescript
import { createEntityAdapter, EntityAdapter, EntityState } from '@ngrx/entity';

export interface PackageState extends EntityState<Package> {
  selectedPackageId: string | null;
  loading: boolean;
  error: string | null;
}

export const packageAdapter: EntityAdapter<Package> = createEntityAdapter<Package>();

export const initialPackageState: PackageState = packageAdapter.getInitialState({
  selectedPackageId: null,
  loading: false,
  error: null
});
```

**HTTP Caching**:
- Cache GET requests for static data
- Implement cache invalidation strategy
- Use RxJS shareReplay for shared observables

### 13.4 Image Optimization

**Lazy Loading Images**:
```html
<img [src]="imageUrl" loading="lazy" alt="Package image">
```

**Placeholder Images**:
- Use low-quality placeholders during load
- Implement progressive image loading
- Optimize image sizes for different viewports

---

## 14. Security Considerations

### 14.1 Authentication Security

**Token Storage**:
- Store JWT in localStorage (acceptable for Phase 1)
- Consider httpOnly cookies for production
- Implement token refresh mechanism

**Token Expiry**:
- Handle 401 responses globally
- Automatic logout on token expiry
- Clear all user data on logout

### 14.2 XSS Protection

**Angular Built-in Protection**:
- Angular sanitizes all template bindings by default
- Use DomSanitizer only when necessary
- Avoid innerHTML binding

**Content Security Policy**:
```html
<!-- In index.html -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';">
```

### 14.3 CSRF Protection

**Angular Built-in Protection**:
- HttpClient automatically handles CSRF tokens
- Requires backend to send XSRF-TOKEN cookie
- Automatically includes X-XSRF-TOKEN header

### 14.4 Input Validation

**Client-Side Validation**:
- Validate all user inputs
- Use Angular Validators
- Implement custom validators for business rules

**Server-Side Validation**:
- Never trust client-side validation alone
- Backend must validate all inputs
- Display server validation errors to user

### 14.5 Sensitive Data Handling

**Password Fields**:
```html
<input type="password" autocomplete="new-password">
```

**No Sensitive Data in URLs**:
- Use POST for sensitive operations
- Never pass tokens or passwords in query params
- Use route parameters only for IDs

---

## 15. Accessibility

### 15.1 ARIA Labels

**Semantic HTML**:
```html
<nav aria-label="Main navigation">
  <ul>
    <li><a href="/dashboard">Dashboard</a></li>
  </ul>
</nav>
```

**Form Labels**:
```html
<label for="email">Email</label>
<input id="email" type="email" aria-required="true">
```

**Button Labels**:
```html
<button aria-label="Close dialog">
  <i class="pi pi-times"></i>
</button>
```

### 15.2 Keyboard Navigation

**Focus Management**:
- Ensure all interactive elements are keyboard accessible
- Implement proper tab order
- Trap focus in modals/dialogs

**Keyboard Shortcuts**:
- Escape to close dialogs
- Enter to submit forms
- Arrow keys for navigation

### 15.3 Screen Reader Support

**Live Regions**:
```html
<div aria-live="polite" aria-atomic="true">
  {{ statusMessage }}
</div>
```

**Skip Links**:
```html
<a href="#main-content" class="skip-link">Skip to main content</a>
```

### 15.4 Color Contrast

**WCAG AA Compliance**:
- Minimum contrast ratio 4.5:1 for normal text
- Minimum contrast ratio 3:1 for large text
- Use color contrast checker tools

**Color Independence**:
- Don't rely solely on color to convey information
- Use icons and text labels alongside colors
- Provide alternative indicators for status

---

## 16. Deployment

### 16.1 Build Configuration

**Development Build**:
```bash
ng serve
# or
npm start
```

**Production Build**:
```bash
ng build --configuration production
# Output: dist/tour-travel-frontend/
```

**Build Optimization**:
- AOT compilation enabled
- Tree shaking enabled
- Minification enabled
- Source maps disabled in production

### 16.2 Environment Configuration

**Development**:
- API URL: `http://localhost:3000/v1`
- Debug mode enabled
- Source maps enabled

**Production**:
- API URL: `https://api.tourtravel.com/v1`
- Debug mode disabled
- Source maps disabled
- Error tracking enabled

### 16.3 Hosting

**Static Hosting Options**:
- AWS S3 + CloudFront
- Netlify
- Vercel
- Firebase Hosting

**Server Configuration**:
- Configure for SPA routing (all routes → index.html)
- Enable gzip compression
- Set cache headers for static assets
- Configure CORS if needed

**Example nginx.conf**:
```nginx
server {
  listen 80;
  server_name tourtravel.com;
  root /var/www/tour-travel-frontend;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
  }
}
```

---

## 17. Development Workflow

### 17.1 Project Setup

**Prerequisites**:
- Node.js 20+ and npm 10+
- Angular CLI 20

**Installation**:
```bash
# Install Angular CLI globally
npm install -g @angular/cli@20

# Create new project
ng new tour-travel-frontend --standalone --routing --style=scss

# Navigate to project
cd tour-travel-frontend

# Install dependencies
npm install primeng@20 @primeng/themes primeicons
npm install @ngrx/store @ngrx/effects @ngrx/store-devtools
npm install lucide-angular
npm install -D tailwindcss@4 postcss autoprefixer

# Initialize Tailwind
npx tailwindcss init
```

### 17.2 Development Commands

```bash
# Start development server
npm start

# Run tests
npm test

# Run tests with coverage
npm run test:coverage

# Build for production
npm run build:prod

# Lint code
npm run lint

# Format code
npm run format
```

### 17.3 Git Workflow

**Branch Strategy**:
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature branches
- `bugfix/*`: Bug fix branches

**Commit Convention**:
```
feat: Add package creation form
fix: Fix booking price calculation
refactor: Refactor auth service
docs: Update README
test: Add tests for package service
```

### 17.4 Code Review Checklist

- [ ] Code follows Angular style guide
- [ ] All components are standalone
- [ ] TypeScript strict mode enabled
- [ ] No console.log statements
- [ ] Error handling implemented
- [ ] Loading states implemented
- [ ] Form validation implemented
- [ ] Responsive design tested
- [ ] Accessibility considerations
- [ ] Tests written (if applicable)

---

## 18. Future Enhancements (Post-Phase 1)

### 18.1 Features

- Payment gateway integration (Stripe, PayPal)
- Document upload functionality
- Email notifications
- Real-time notifications (WebSocket)
- Advanced reporting and analytics
- Export functionality (PDF, Excel)
- Print functionality
- Internationalization (i18n) - Arabic, English
- Dark mode
- Progressive Web App (PWA) features
- Mobile app (React Native or Flutter)

### 18.2 Technical Improvements

- Implement service workers for offline support
- Add end-to-end tests with Cypress or Playwright
- Implement advanced caching strategies
- Add performance monitoring (Lighthouse CI)
- Implement error tracking (Sentry)
- Add analytics (Google Analytics, Mixpanel)
- Implement A/B testing framework
- Add feature flags system

### 18.3 UX Improvements

- Advanced animations and transitions
- Skeleton loaders
- Infinite scroll for lists
- Drag-and-drop functionality
- Advanced search with autocomplete
- Bulk operations
- Keyboard shortcuts
- Tour guide for new users

---

## 19. Conclusion

This design document provides a comprehensive blueprint for building the Tour & Travel ERP SaaS frontend application. By following the ibis-frontend-main architecture pattern and leveraging Angular 20, PrimeNG 20, TailwindCSS 4, and NgRx, we ensure a maintainable, scalable, and performant application.

The design emphasizes:
- **Consistency**: Reusable components and standardized patterns
- **Maintainability**: Feature-based structure and clear separation of concerns
- **Performance**: Lazy loading, change detection optimization, and caching
- **Security**: Authentication, authorization, and input validation
- **Accessibility**: ARIA labels, keyboard navigation, and screen reader support
- **Testability**: Unit tests, component tests, and property-based testing

The implementation will be executed over 10 weeks, with incremental delivery of features for each user role (Platform Admin, Supplier, Agency Staff, Traveler).

---

## 📞 Navigation

- 🏠 [Back to Phase 1](../PHASE-1-COMPLETE-DOCUMENTATION.md)
- 📋 [Requirements Document](requirements.md)
- ✅ [Tasks](tasks.md)

**Last Updated:** February 11, 2026
