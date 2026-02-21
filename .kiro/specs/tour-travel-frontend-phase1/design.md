# Design Document: Tour & Travel SaaS Frontend - Phase 1 MVP

## Overview

This design document outlines the technical architecture and implementation approach for the Tour & Travel Agency ERP SaaS Platform Frontend. The application is built using Angular 20 with standalone components, following modern Angular best practices and patterns from the ibis-frontend-main reference project.

The frontend provides three distinct portals:
- **Platform Admin Portal**: Manage agencies, suppliers, subscriptions, and revenue
- **Supplier Portal**: Manage service catalog, seasonal pricing, and purchase orders
- **Agency Portal**: Complete ERP functionality including procurement, packages, journeys, bookings, documents, tasks, payments, and B2B marketplace

### Technology Stack

- **Framework**: Angular 20 with standalone components
- **State Management**: NGXS (NgRx alternative with simpler API)
- **UI Components**: PrimeNG 20
- **Styling**: TailwindCSS 4
- **Icons**: Lucide Angular
- **HTTP Client**: Angular HttpClient with interceptors
- **Forms**: Angular Reactive Forms
- **Routing**: Angular Router with lazy loading

## Architecture

### Folder Structure

```
src/
├── app/
│   ├── core/                    # Core services and models
│   │   ├── models/              # Shared interfaces and types
│   │   ├── services/            # Core services (auth, notification, loading)
│   │   ├── guards/              # Route guards (auth, role)
│   │   └── interceptors/        # HTTP interceptors
│   ├── shared/                  # Shared components and utilities
│   │   ├── components/          # Reusable UI components
│   │   └── utils/               # Utility functions
│   ├── store/                   # NGXS state management
│   │   ├── auth/                # Auth state
│   │   └── [feature]/           # Feature-specific states
│   ├── layouts/                 # Layout components
│   │   ├── main-layout/         # Main app layout
│   │   ├── auth-layout/         # Auth pages layout
│   │   └── landing-layout/      # Public landing page layout
│   ├── features/                # Feature modules
│   │   ├── auth/                # Authentication
│   │   ├── platform-admin/      # Platform admin portal
│   │   ├── supplier/            # Supplier portal
│   │   └── agency/              # Agency portal
│   └── app.config.ts            # App configuration
├── environments/                # Environment configurations
└── assets/                      # Static assets
```


### Component Architecture

The application follows a smart/presentational component pattern:

**Smart Components (Containers)**:
- Manage state using NGXS Store
- Handle business logic and side effects
- Dispatch actions and select state
- Located in feature directories

**Presentational Components**:
- Receive data via @Input()
- Emit events via @Output()
- Pure UI logic only
- Located in shared/components

### State Management with NGXS

NGXS provides a simpler alternative to NgRx with decorators and less boilerplate:

**State Structure**:
```typescript
// State Model
export interface AuthStateModel {
  token: string | null;
  user: User | null;
  loading: boolean;
  error: string | null;
}

// State Class
@State<AuthStateModel>({
  name: 'auth',
  defaults: { token: null, user: null, loading: false, error: null }
})
@Injectable()
export class AuthState {
  @Selector()
  static token(state: AuthStateModel) { return state.token; }
  
  @Action(Login)
  login(ctx: StateContext<AuthStateModel>, action: Login) {
    // Handle login action
  }
}
```

**Feature States**:
- AuthState: Authentication and user context
- AgencyState: Agency management (Platform Admin)
- SupplierState: Supplier management (Platform Admin)
- SubscriptionPlanState: Subscription plans (Platform Admin)
- CommissionState: Commission configuration (Platform Admin)
- RevenueState: Revenue metrics (Platform Admin)
- ServiceState: Service catalog (Supplier)
- PurchaseOrderState: Purchase orders (Supplier/Agency)
- PackageState: Package templates (Agency)
- JourneyState: Journey instances (Agency)
- CustomerState: Customer management (Agency)
- BookingState: Booking management (Agency)
- DocumentState: Document tracking (Agency)
- TaskState: Task management (Agency)
- NotificationState: Notification configuration (Agency)
- PaymentState: Payment tracking (Agency)
- ItineraryState: Itinerary builder (Agency)
- SupplierBillState: Supplier bills (Agency)
- CommunicationLogState: Communication logs (Agency)
- MarketplaceState: B2B marketplace (Agency)
- ProfitabilityState: Profitability tracking (Agency)


## Components and Interfaces

### Core Services

#### AuthService
Handles authentication operations and JWT token management.

**Methods**:
- `login(credentials: LoginCredentials): Observable<AuthResponse>`
- `logout(): void`
- `getToken(): string | null`
- `isAuthenticated(): boolean`
- `getUserType(): string | null`
- `getAgencyId(): number | null`
- `getSupplierId(): number | null`

**JWT Token Payload**:
```typescript
interface JwtPayload {
  user_id: number;
  email: string;
  user_type: 'platform_admin' | 'agency_staff' | 'supplier_staff';
  agency_id?: number;
  supplier_id?: number;
  exp: number;
}
```

#### NotificationService
Manages toast notifications using PrimeNG MessageService.

**Methods**:
- `success(message: string, title?: string): void`
- `error(message: string, title?: string): void`
- `warning(message: string, title?: string): void`
- `info(message: string, title?: string): void`

#### LoadingService
Manages global loading state.

**Methods**:
- `show(): void`
- `hide(): void`
- `isLoading$: Observable<boolean>`

### HTTP Interceptors

#### AuthInterceptor
Attaches JWT token to all outgoing HTTP requests.

**Implementation**:
```typescript
intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
  const token = this.authService.getToken();
  if (token) {
    req = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
  }
  return next.handle(req);
}
```

#### ErrorInterceptor
Handles HTTP errors and displays appropriate notifications.

**Error Handling**:
- 400: Display validation errors
- 401: Redirect to login
- 403: Display permission error
- 404: Display not found error
- 500: Display generic error
- All errors logged to console

#### LoadingInterceptor
Tracks pending HTTP requests and manages loading state.

**Implementation**:
- Increment counter on request start
- Decrement counter on request complete
- Show loading when counter > 0


### Route Guards

#### AuthGuard
Protects routes requiring authentication.

**Logic**:
```typescript
canActivate(): boolean {
  if (this.authService.isAuthenticated()) {
    return true;
  }
  this.router.navigate(['/login']);
  return false;
}
```

#### RoleGuard
Protects routes based on user role.

**Logic**:
```typescript
canActivate(route: ActivatedRouteSnapshot): boolean {
  const allowedRoles = route.data['roles'] as string[];
  const userType = this.authService.getUserType();
  
  if (allowedRoles.includes(userType)) {
    return true;
  }
  
  this.notificationService.error('You do not have permission to access this page');
  return false;
}
```

### Shared Components

#### DataTableComponent
Reusable table component with sorting, filtering, and pagination.

**Inputs**:
- `columns: TableColumn[]` - Column configuration
- `data: any[]` - Table data
- `loading: boolean` - Loading state
- `paginator: boolean` - Enable pagination
- `rows: number` - Rows per page

**Outputs**:
- `onRowSelect: EventEmitter<any>` - Row selection event
- `onRowEdit: EventEmitter<any>` - Row edit event
- `onRowDelete: EventEmitter<any>` - Row delete event

**Column Configuration**:
```typescript
interface TableColumn {
  field: string;
  header: string;
  sortable?: boolean;
  filterable?: boolean;
  template?: TemplateRef<any>;
}
```

#### PageHeaderComponent
Consistent page header with breadcrumbs and actions.

**Inputs**:
- `title: string` - Page title
- `breadcrumbs: Breadcrumb[]` - Breadcrumb items
- `actions: HeaderAction[]` - Action buttons

**Breadcrumb Structure**:
```typescript
interface Breadcrumb {
  label: string;
  url?: string;
  icon?: string;
}
```

#### ConfirmationDialogComponent
Reusable confirmation dialog for destructive actions.

**Inputs**:
- `visible: boolean` - Dialog visibility
- `message: string` - Confirmation message
- `header: string` - Dialog header
- `acceptLabel: string` - Accept button label
- `rejectLabel: string` - Reject button label
- `severity: 'info' | 'warning' | 'danger'` - Dialog severity

**Outputs**:
- `onAccept: EventEmitter<void>` - Accept event
- `onReject: EventEmitter<void>` - Reject event

#### LoadingSpinnerComponent
Loading indicator with overlay support.

**Inputs**:
- `size: 'small' | 'medium' | 'large'` - Spinner size
- `overlay: boolean` - Full-screen overlay mode


## Data Models

### Core Models

#### User
```typescript
interface User {
  id: number;
  email: string;
  user_type: 'platform_admin' | 'agency_staff' | 'supplier_staff';
  agency_id?: number;
  supplier_id?: number;
  created_at: string;
}
```

#### Agency
```typescript
interface Agency {
  id: number;
  agency_code: string;
  company_name: string;
  email: string;
  phone: string;
  address: string;
  city: string;
  province: string;
  postal_code: string;
  subscription_plan?: string;
  is_active: boolean;
  created_at: string;
}
```

#### Supplier
```typescript
interface Supplier {
  id: number;
  supplier_code: string;
  company_name: string;
  business_type: string;
  email: string;
  phone: string;
  business_license_number: string;
  status: 'pending' | 'active' | 'rejected' | 'suspended';
  rejection_reason?: string;
  created_at: string;
}
```

#### SubscriptionPlan
```typescript
interface SubscriptionPlan {
  id: number;
  plan_name: string;
  plan_type: 'free' | 'basic' | 'professional' | 'enterprise';
  description: string;
  monthly_price: number;
  annual_price: number;
  features: {
    max_users: number;
    max_bookings_per_month: number;
    max_packages: number;
    marketplace_access: boolean;
    api_access: boolean;
    custom_branding: boolean;
    priority_support: boolean;
  };
  is_active: boolean;
  display_order: number;
  created_at: string;
  updated_at: string;
}
```

#### AgencySubscription
```typescript
interface AgencySubscription {
  id: number;
  agency_id: number;
  plan_id: number;
  start_date: string;
  end_date: string;
  billing_cycle: 'monthly' | 'quarterly' | 'annually';
  next_billing_date: string;
  status: 'active' | 'suspended' | 'cancelled' | 'expired';
  auto_renew: boolean;
  cancelled_at?: string;
  cancellation_reason?: string;
  created_at: string;
  updated_at: string;
}
```

#### CommissionConfig
```typescript
interface CommissionConfig {
  id: number;
  agency_id?: number; // null for global configs
  service_type: 'hotel' | 'flight' | 'visa' | 'transport' | 'guide' | 'insurance' | 'catering' | 'handling' | 'package' | 'marketplace';
  commission_type: 'percentage' | 'fixed';
  commission_value: number;
  effective_from: string;
  effective_until?: string;
  is_active: boolean;
  notes?: string;
  created_by: number;
  created_at: string;
  updated_at: string;
}

interface CommissionTransaction {
  id: number;
  transaction_type: 'booking' | 'marketplace_order' | 'purchase_order';
  reference_id: number;
  agency_id: number;
  commission_config_id?: number;
  base_amount: number;
  commission_rate: number;
  commission_amount: number;
  status: 'pending' | 'collected' | 'waived' | 'refunded';
  collected_at?: string;
  payment_reference?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}
```

#### RevenueMetrics
```typescript
interface RevenueMetrics {
  id: number;
  agency_id: number;
  metric_date: string;
  total_bookings: number;
  total_revenue: number;
  total_commission: number;
  marketplace_orders: number;
  marketplace_revenue: number;
  active_packages: number;
  active_journeys: number;
  created_at: string;
  updated_at: string;
}

interface RevenueSummary {
  total_subscription_revenue: number;
  total_commission_revenue: number;
  total_revenue: number;
  total_bookings: number;
  total_agencies: number;
}

interface RevenueByPlan {
  plan_name: string;
  revenue: number;
  agency_count: number;
}

interface AgencyRevenue {
  agency_id: number;
  agency_name: string;
  subscription_plan: string;
  subscription_revenue: number;
  commission_revenue: number;
  total_revenue: number;
}

interface CommissionRevenueTrend {
  month: string;
  revenue: number;
}
```

#### JourneyService
```typescript
interface JourneyService {
  id: number;
  journey_id: number;
  service_type: string;
  service_name: string;
  supplier_service_id?: number;
  agency_service_id?: number;
  source_type: 'supplier' | 'agency';
  booking_status: 'not_booked' | 'booked' | 'confirmed' | 'cancelled';
  execution_status: 'pending' | 'in_progress' | 'completed' | 'failed';
  payment_status: 'unpaid' | 'partially_paid' | 'paid';
  booked_at?: string;
  confirmed_at?: string;
  executed_at?: string;
  issue_notes?: string;
  created_at: string;
  updated_at: string;
}
```

### Supplier Models

#### SupplierService
```typescript
interface SupplierService {
  id: number;
  supplier_id: number;
  service_code: string;
  service_type: 'hotel' | 'flight' | 'visa' | 'transport' | 'activity' | 'other';
  name: string;
  description: string;
  base_price: number;
  currency: string;
  location_city: string;
  location_country: string;
  status: 'draft' | 'published';
  
  // Hotel-specific fields
  hotel_name?: string;
  hotel_star_rating?: number;
  room_type?: string;
  meal_plan?: string;
  
  // Flight-specific fields
  airline?: string;
  flight_class?: string;
  departure_airport?: string;
  arrival_airport?: string;
  
  // Visa-specific fields
  visa_type?: string;
  processing_days?: number;
  validity_days?: number;
  entry_type?: string;
}
```

#### SeasonalPrice
```typescript
interface SeasonalPrice {
  id: number;
  service_id: number;
  season_name: string;
  start_date: string;
  end_date: string;
  seasonal_price: number;
}
```

#### PurchaseOrder
```typescript
interface PurchaseOrder {
  id: number;
  po_number: string;
  agency_id: number;
  supplier_id: number;
  total_amount: number;
  status: 'pending' | 'approved' | 'rejected';
  rejection_reason?: string;
  created_at: string;
  items: POItem[];
}

interface POItem {
  id: number;
  po_id: number;
  service_id: number;
  quantity: number;
  unit_price: number;
  total_price: number;
}
```


### Agency Models

#### Package
```typescript
interface Package {
  id: number;
  agency_id: number;
  package_code: string;
  package_type: 'umrah' | 'hajj' | 'halal_tour' | 'general_tour' | 'custom';
  name: string;
  description: string;
  duration_days: number;
  base_cost: number;
  markup_type: 'percentage' | 'fixed';
  markup_value: number;
  selling_price: number;
  visibility: 'public' | 'private';
  status: 'draft' | 'published';
  published_at?: string;
  created_at: string;
  updated_at: string;
  services: PackageService[];
}

interface PackageService {
  id: number;
  package_id: number;
  supplier_service_id?: number;
  agency_service_id?: number;
  source_type: 'supplier' | 'agency';
  quantity: number;
  unit_cost: number;
  total_cost: number;
  created_at: string;
}
```

#### Journey
```typescript
interface Journey {
  id: number;
  agency_id: number;
  package_id: number;
  journey_code: string;
  departure_date: string;
  return_date: string;
  total_quota: number;
  confirmed_pax: number;
  available_quota: number;
  status: 'planning' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
  notes?: string;
  created_at: string;
  updated_at: string;
  services: JourneyService[];
}
```

#### Customer
```typescript
interface Customer {
  id: number;
  agency_id: number;
  customer_code: string;
  name: string;
  email?: string;
  phone: string;
  address?: string;
  city?: string;
  province?: string;
  postal_code?: string;
  country?: string;
  notes?: string;
  tags?: string[];
  total_bookings: number;
  total_spent: number;
  last_booking_date?: string;
  created_at: string;
  updated_at: string;
}
```

#### Booking
```typescript
interface Booking {
  id: number;
  agency_id: number;
  booking_reference: string;
  package_id: number;
  journey_id: number;
  customer_id: number;
  total_pax: number;
  total_amount: number;
  booking_source: 'staff' | 'phone' | 'walk_in' | 'whatsapp';
  booking_status: 'pending' | 'confirmed' | 'departed' | 'completed' | 'cancelled';
  notes?: string;
  approved_at?: string;
  approved_by?: number;
  cancelled_at?: string;
  cancelled_by?: number;
  cancellation_reason?: string;
  created_by: number;
  created_at: string;
  updated_at: string;
  travelers: Traveler[];
  documents: BookingDocument[];
  tasks: BookingTask[];
  payments: PaymentSchedule[];
}

interface Traveler {
  id: number;
  booking_id: number;
  traveler_number: number;
  full_name: string;
  gender: 'male' | 'female';
  date_of_birth: string;
  nationality: string;
  passport_number: string;
  passport_expiry: string;
  mahram_traveler_number?: number;
  created_at: string;
}
```


#### Document Management
```typescript
interface DocumentType {
  id: number;
  name: string;
  required_for_package_types: string[];
  description?: string;
  expiry_tracking_enabled: boolean;
  created_at: string;
}

interface BookingDocument {
  id: number;
  booking_id: number;
  traveler_id: number;
  document_type_id: number;
  status: 'not_submitted' | 'submitted' | 'verified' | 'rejected' | 'expired';
  document_number?: string;
  issue_date?: string;
  expiry_date?: string;
  notes?: string;
  rejection_reason?: string;
  verified_by?: number;
  verified_at?: string;
  created_at: string;
  updated_at: string;
}
```

#### Task Management
```typescript
interface TaskTemplate {
  id: number;
  agency_id?: number; // null for system templates
  name: string;
  description?: string;
  trigger_stage: 'after_booking' | 'h_30' | 'h_7';
  due_days_offset: number;
  assignee_role?: string;
  is_active: boolean;
  created_at: string;
}

interface BookingTask {
  id: number;
  booking_id: number;
  task_template_id?: number;
  title: string;
  description?: string;
  status: 'to_do' | 'in_progress' | 'done';
  priority: 'low' | 'normal' | 'high' | 'urgent';
  assigned_to?: number;
  due_date?: string;
  completed_at?: string;
  completed_by?: number;
  notes?: string;
  is_custom: boolean;
  created_at: string;
  updated_at: string;
}
```

#### Payment Tracking
```typescript
interface PaymentSchedule {
  id: number;
  booking_id: number;
  installment_number: number;
  installment_name: string;
  due_date: string;
  amount: number;
  status: 'pending' | 'paid' | 'overdue' | 'partially_paid';
  paid_amount: number;
  paid_date?: string;
  payment_method?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
  transactions: PaymentTransaction[];
}

interface PaymentTransaction {
  id: number;
  booking_id: number;
  schedule_id?: number;
  amount: number;
  payment_method: 'bank_transfer' | 'cash' | 'credit_card' | 'e_wallet';
  payment_date: string;
  reference_number?: string;
  notes?: string;
  recorded_by: number;
  created_at: string;
}
```

#### Notification Configuration
```typescript
interface NotificationSchedule {
  id: number;
  agency_id: number;
  name: string;
  trigger_days_before: number;
  notification_type: 'email' | 'sms' | 'whatsapp';
  template_id: number;
  is_enabled: boolean;
  created_at: string;
  updated_at: string;
}

interface NotificationTemplate {
  id: number;
  agency_id?: number; // null for system templates
  name: string;
  subject: string;
  body: string;
  variables?: string[];
  created_at: string;
  updated_at: string;
}

interface NotificationLog {
  id: number;
  booking_id: number;
  schedule_id?: number;
  recipient_email?: string;
  recipient_phone?: string;
  notification_type: string;
  subject?: string;
  body: string;
  status: 'pending' | 'sent' | 'failed' | 'failed_permanently';
  sent_at?: string;
  opened_at?: string;
  error_message?: string;
  retry_count: number;
  created_at: string;
}
```

#### B2B Marketplace
```typescript
interface AgencyService {
  id: number;
  agency_id: number;
  po_id: number;
  service_type: string;
  name: string;
  description: string;
  specifications?: any;
  cost_price: number; // HIDDEN from buyers
  reseller_price: number;
  markup_percentage: number;
  total_quota: number;
  used_quota: number;
  available_quota: number;
  reserved_quota: number;
  sold_quota: number;
  is_published: boolean;
  published_at?: string;
  created_at: string;
  updated_at: string;
}

interface AgencyOrder {
  id: number;
  order_number: string;
  buyer_agency_id: number;
  seller_agency_id: number;
  agency_service_id: number;
  quantity: number;
  unit_price: number;
  total_price: number;
  status: 'pending' | 'approved' | 'rejected' | 'cancelled';
  notes?: string;
  approved_by?: number;
  approved_at?: string;
  rejection_reason?: string;
  rejected_by?: number;
  rejected_at?: string;
  created_by: number;
  created_at: string;
  updated_at: string;
}
```

#### Profitability Tracking
```typescript
interface BookingProfitability {
  booking_id: number;
  booking_reference: string;
  revenue: number;
  cost: number;
  gross_profit: number;
  gross_margin_percentage: number;
  cost_breakdown: CostBreakdown[];
}

interface CostBreakdown {
  source_type: 'supplier' | 'agency';
  service_name: string;
  cost: number;
}
```


## Mock Data Infrastructure

To enable frontend development before backend APIs are ready, the application includes a comprehensive mock data system.

### Environment Configuration

```typescript
// environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/api',
  apiReady: false,  // Toggle between mock and real API
  mockDelay: 500    // Simulated API delay in ms
};
```

### Mock Service Architecture

**InjectionToken Pattern**:
```typescript
// Define interface
export interface IAgencyApiService {
  getAll(): Observable<Agency[]>;
  getById(id: number): Observable<Agency>;
  create(data: CreateAgencyRequest): Observable<Agency>;
  update(id: number, data: UpdateAgencyRequest): Observable<Agency>;
  toggleStatus(id: number): Observable<Agency>;
}

// Create injection token
export const AGENCY_API_SERVICE = new InjectionToken<IAgencyApiService>('AgencyApiService');

// Configure in app.config.ts
providers: [
  {
    provide: AGENCY_API_SERVICE,
    useFactory: (http: HttpClient) => {
      return environment.apiReady 
        ? new AgencyApiService(http)
        : new AgencyMockService();
    },
    deps: [HttpClient]
  }
]
```

### Mock Data Factories

**BaseMockData Utilities**:
```typescript
export class BaseMockData {
  protected randomInt(min: number, max: number): number;
  protected randomElement<T>(array: T[]): T;
  protected randomDate(start: Date, end: Date): string;
  protected randomBoolean(): boolean;
}
```

**Entity-Specific Factories**:
- AgencyMockData: Generate realistic agency data
- SupplierMockData: Generate supplier data
- ServiceMockData: Generate service catalog data
- PackageMockData: Generate package templates
- JourneyMockData: Generate journey instances
- BookingMockData: Generate bookings with relationships
- CustomerMockData: Generate customer data

### Mock State Management

**MockStateService**:
Centralized in-memory state for all mock data with relationship integrity.

```typescript
@Injectable({ providedIn: 'root' })
export class MockStateService {
  private agencies: Agency[] = [];
  private suppliers: Supplier[] = [];
  private services: SupplierService[] = [];
  // ... other entities
  
  // Relationship management
  getServicesBySupplier(supplierId: number): SupplierService[];
  getBookingsByJourney(journeyId: number): Booking[];
  // ... other relationship methods
}
```

### Mock Service Implementation

**Example: AgencyMockService**:
```typescript
@Injectable()
export class AgencyMockService implements IAgencyApiService {
  constructor(private mockState: MockStateService) {}
  
  getAll(): Observable<Agency[]> {
    return of(this.mockState.getAgencies())
      .pipe(delay(environment.mockDelay));
  }
  
  create(data: CreateAgencyRequest): Observable<Agency> {
    const agency = AgencyMockData.generate(data);
    this.mockState.addAgency(agency);
    console.log('[MOCK] Created agency:', agency);
    return of(agency).pipe(delay(environment.mockDelay));
  }
  
  // ... other CRUD operations
}
```

### API Services

The application uses API services to communicate with the backend. Each service is defined as an interface to support both real and mock implementations.

#### Core API Services

**AgencyApiService**:
- `getAll(): Observable<Agency[]>`
- `getById(id: number): Observable<Agency>`
- `create(data: CreateAgencyRequest): Observable<Agency>`
- `update(id: number, data: UpdateAgencyRequest): Observable<Agency>`
- `toggleStatus(id: number): Observable<Agency>`

**SupplierApiService**:
- `getAll(): Observable<Supplier[]>`
- `getById(id: number): Observable<Supplier>`
- `approve(id: number): Observable<Supplier>`
- `reject(id: number, reason: string): Observable<Supplier>`

**SubscriptionPlanApiService**:
- `getAll(): Observable<SubscriptionPlan[]>`
- `getById(id: number): Observable<SubscriptionPlan>`
- `create(data: CreateSubscriptionPlanRequest): Observable<SubscriptionPlan>`
- `update(id: number, data: UpdateSubscriptionPlanRequest): Observable<SubscriptionPlan>`
- `toggleStatus(id: number): Observable<SubscriptionPlan>`

**CommissionApiService**:
- `getCurrent(): Observable<CommissionConfig>`
- `getHistory(): Observable<CommissionHistory[]>`
- `update(data: UpdateCommissionConfigRequest): Observable<CommissionConfig>`

**RevenueApiService**:
- `getMetrics(dateRange?: DateRange): Observable<RevenueMetrics>`
- `getByPlan(dateRange?: DateRange): Observable<RevenueByPlan[]>`
- `getTopAgencies(limit: number, dateRange?: DateRange): Observable<AgencyRevenue[]>`
- `getCommissionTrend(months: number): Observable<CommissionRevenueTrend[]>`

#### Supplier Portal API Services

**ServiceApiService**:
- `getAll(): Observable<SupplierService[]>`
- `getById(id: number): Observable<SupplierService>`
- `create(data: CreateServiceRequest): Observable<SupplierService>`
- `update(id: number, data: UpdateServiceRequest): Observable<SupplierService>`
- `publish(id: number): Observable<SupplierService>`

**PurchaseOrderApiService**:
- `getAll(): Observable<PurchaseOrder[]>`
- `getById(id: number): Observable<PurchaseOrder>`
- `approve(id: number): Observable<PurchaseOrder>`
- `reject(id: number, reason: string): Observable<PurchaseOrder>`

#### Agency Portal API Services

**PackageApiService**:
- `getAll(): Observable<Package[]>`
- `getById(id: number): Observable<Package>`
- `create(data: CreatePackageRequest): Observable<Package>`
- `update(id: number, data: UpdatePackageRequest): Observable<Package>`
- `publish(id: number): Observable<Package>`
- `getAvailableServices(): Observable<AvailableService[]>`

**JourneyApiService**:
- `getAll(): Observable<Journey[]>`
- `getById(id: number): Observable<Journey>`
- `create(data: CreateJourneyRequest): Observable<Journey>`
- `update(id: number, data: UpdateJourneyRequest): Observable<Journey>`
- `getJourneyServices(journeyId: number): Observable<JourneyService[]>`
- `updateServiceStatus(journeyId: number, serviceId: number, statusUpdate: ServiceStatusUpdate): Observable<JourneyService>`

**CustomerApiService**:
- `getAll(): Observable<Customer[]>`
- `getById(id: number): Observable<Customer>`
- `create(data: CreateCustomerRequest): Observable<Customer>`
- `update(id: number, data: UpdateCustomerRequest): Observable<Customer>`

**BookingApiService**:
- `getAll(): Observable<Booking[]>`
- `getById(id: number): Observable<Booking>`
- `create(data: CreateBookingRequest): Observable<Booking>`
- `approve(id: number): Observable<Booking>`
- `cancel(id: number, reason: string): Observable<Booking>`

**MarketplaceApiService**:
- `publishService(data: PublishServiceRequest): Observable<AgencyService>`
- `unpublishService(id: number): Observable<AgencyService>`
- `getMarketplaceServices(): Observable<AgencyService[]>`
- `createOrder(data: CreateAgencyOrderRequest): Observable<AgencyOrder>`
- `approveOrder(id: number): Observable<AgencyOrder>`
- `rejectOrder(id: number, reason: string): Observable<AgencyOrder>`


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: User Authentication Token Storage

*For any* successful login response containing a valid JWT token, storing the token in localStorage and then retrieving it should return the same token value.

**Validates: Requirements 2.1**

### Property 2: Role-Based Route Access

*For any* user with a specific user_type (platform_admin, agency_staff, supplier_staff), attempting to access a route restricted to a different role should be denied and display a permission error.

**Validates: Requirements 2.4**

### Property 3: Authorization Header Attachment

*For any* HTTP request made after successful authentication, the request should include an Authorization header with the format "Bearer {token}".

**Validates: Requirements 3.1**

### Property 4: HTTP Error Toast Notifications

*For any* HTTP error response (400, 401, 403, 404, 500), the system should display a toast notification with an appropriate error message.

**Validates: Requirements 3.2, 44.1, 44.2, 44.3, 44.4, 44.5**

### Property 5: Loading State Management

*For any* HTTP request, the loading state should be true while the request is pending and false after the request completes (success or error).

**Validates: Requirements 3.3**

### Property 6: Successful Operation Feedback

*For any* successful create, update, or delete operation, the system should display a success toast notification.

**Validates: Requirements 8.5, 9.5, 10.6, 11.7, 14.7, 15.5, 16.7, 17.6, 18.7, 19.5, 20.6, 21.6, 22.6, 23.6, 24.6, 25.7, 26.6, 27.6, 28.6, 29.6, 30.6, 31.6, 32.6, 33.6, 34.6, 35.6, 36.6**

### Property 7: Date Range Validation

*For any* form with start_date and end_date fields, submitting the form with end_date earlier than start_date should be rejected with a validation error.

**Validates: Requirements 15.3, 19.3**

### Property 8: Positive Price Validation

*For any* form with price fields (base_price, selling_price, reseller_price, etc.), submitting the form with a price value less than or equal to zero should be rejected with a validation error.

**Validates: Requirements 15.4, 18.4, 33.3**

### Property 9: Form Validation Error Display

*For any* form field with validation errors, the error message should be displayed below the field in red text.

**Validates: Requirements 41.2, 41.3, 41.4, 41.5**

### Property 10: Required Field Validation

*For any* form with required fields, submitting the form with empty required fields should be rejected and display "This field is required" message for each empty field.

**Validates: Requirements 41.3**

### Property 11: Email Format Validation

*For any* form with an email field, submitting the form with an invalid email format should be rejected and display "Invalid email format" message.

**Validates: Requirements 41.4**

### Property 12: Phone Format Validation

*For any* form with a phone field, submitting the form with an invalid phone format should be rejected and display "Invalid phone format" message.

**Validates: Requirements 41.5**

### Property 13: Form Submission Error Feedback

*For any* form submission that fails due to server error, the system should display an error toast notification with the error message.

**Validates: Requirements 41.7**


### Property 14: Toast Notification Severity

*For any* toast notification, the background color should match the severity: success (green), error (red), warning (yellow), info (blue).

**Validates: Requirements 43.2, 43.3, 43.4, 43.5**

### Property 15: Toast Auto-Dismissal

*For any* toast notification, the notification should automatically dismiss after 5 seconds unless manually dismissed.

**Validates: Requirements 43.6**

### Property 16: Toast Manual Dismissal

*For any* toast notification, clicking the close button should immediately dismiss the notification.

**Validates: Requirements 43.7**

### Property 17: Error Logging

*For any* error (HTTP error or runtime error), the error details should be logged to the browser console.

**Validates: Requirements 44.6**

### Property 18: Subscription End Date Calculation

*For any* subscription assignment with billing_cycle "monthly", the subscription_end_date should be 30 days after subscription_start_date; for "annual", it should be 365 days after.

**Validates: Requirements 12.3**

### Property 19: Journey Quota Management

*For any* booking approval on a journey, the journey's confirmed_pax should increase by the booking's total_pax, and available_quota should decrease by the same amount.

**Validates: Requirements 22.5, 23.5**

### Property 20: Mahram Validation for Female Travelers

*For any* female traveler over 12 years old in an Umrah or Hajj package, the system should require a mahram_traveler_number that references an existing male traveler in the same booking.

**Validates: Requirements 23.3, 23.4**

### Property 21: Document Completion Percentage

*For any* booking, the document completion percentage should equal (number of verified documents / total required documents) × 100.

**Validates: Requirements 24.2**

### Property 22: Task Completion Percentage

*For any* booking, the task completion percentage should equal (number of done tasks / total tasks) × 100.

**Validates: Requirements 25.1**

### Property 23: Payment Status Update Logic

*For any* payment schedule, when paid_amount equals amount, status should be "paid"; when paid_amount is greater than 0 but less than amount, status should be "partially_paid"; when paid_amount is 0, status should be "pending".

**Validates: Requirements 28.4**

### Property 24: Marketplace Pricing Validation

*For any* agency service published to the marketplace, reseller_price should be at least 5% greater than cost_price.

**Validates: Requirements 32.3**

### Property 25: Package Base Cost Calculation

*For any* package, base_cost should equal the sum of all package_services total_cost values.

**Validates: Requirements 18.6**

### Property 26: Package Selling Price Calculation

*For any* package with markup_type "percentage", selling_price should equal base_cost × (1 + markup_value/100); for markup_type "fixed", selling_price should equal base_cost + markup_value.

**Validates: Requirements 18.2**

### Property 27: Booking Total Amount Calculation

*For any* booking, total_amount should equal the package's selling_price multiplied by total_pax.

**Validates: Requirements 21.4**

### Property 28: Journey Service Auto-Copy

*For any* newly created journey, the journey_services should contain all services from the associated package's package_services with default tracking statuses (booking_status: not_booked, execution_status: pending, payment_status: unpaid).

**Validates: Requirements 20.5, 20.6**

### Property 29: Subscription End Date Calculation (Monthly)

*For any* subscription assignment with billing_cycle "monthly", the subscription_end_date should be exactly 30 days after subscription_start_date.

**Validates: Requirements 13.3**

### Property 30: Subscription End Date Calculation (Annual)

*For any* subscription assignment with billing_cycle "annual", the subscription_end_date should be exactly 365 days after subscription_start_date.

**Validates: Requirements 13.3**

### Property 31: Commission Rate Percentage Validation

*For any* commission configuration with commission_type "percentage", the commission_rate should be between 0 and 100 (inclusive).

**Validates: Requirements 12.3**

### Property 32: Commission Rate Fixed Validation

*For any* commission configuration with commission_type "fixed", the commission_rate should be greater than zero.

**Validates: Requirements 12.4**

### Property 33: Marketplace Reseller Price Validation

*For any* agency service published to the marketplace, reseller_price should be at least 5% greater than cost_price.

**Validates: Requirements 33.3**

### Property 34: Journey Service Status Update Timestamps

*For any* journey service status update, when booking_status changes to 'booked', booked_at timestamp should be set; when booking_status changes to 'confirmed', confirmed_at timestamp should be set; when execution_status changes to 'completed', executed_at timestamp should be set.

**Validates: Requirements 20.9, 20.10, 20.11**

### Property 35: Service Tracking Progress Calculation

*For any* journey, the service tracking progress summary should accurately reflect the count of services in each status category (booking_status, execution_status, payment_status).

**Validates: Requirements 20.12**

### Property 36: Supplier Registration Password Validation

*For any* supplier registration form submission, the password should contain at least 8 characters, at least 1 uppercase letter, at least 1 lowercase letter, and at least 1 number.

**Validates: Requirements 49.7**

### Property 37: Supplier Registration Password Match

*For any* supplier registration form submission, the confirm_password field should match the password field exactly.

**Validates: Requirements 49.8**

### Property 38: Form Mode Button Display

*For any* form component in view mode, only "Edit" and "Back" buttons should be displayed in page header actions; in edit mode, only "Save" and "Cancel" buttons should be displayed; in create mode, only "Create" and "Cancel" buttons should be displayed.

**Validates: Requirements 47.2, 47.3, 47.4**

### Property 39: Mock Service Delay Simulation

*For any* mock service operation, the response should be delayed by the configured mockDelay value from environment configuration.

**Validates: Requirements 46.6**

### Property 40: Mock Data Relationship Integrity

*For any* mock data entity with foreign key relationships (e.g., booking references journey, traveler references booking), the referenced entity should exist in the mock state.

**Validates: Requirements 46.8**


## Error Handling

### HTTP Error Handling Strategy

**ErrorInterceptor Implementation**:
```typescript
intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
  return next.handle(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An unexpected error occurred';
      
      switch (error.status) {
        case 400:
          errorMessage = this.handleValidationErrors(error);
          break;
        case 401:
          errorMessage = 'Session expired. Please login again.';
          this.authService.logout();
          this.router.navigate(['/login']);
          break;
        case 403:
          errorMessage = 'You do not have permission to perform this action';
          break;
        case 404:
          errorMessage = 'Resource not found';
          break;
        case 500:
          errorMessage = 'An unexpected error occurred. Please try again later.';
          break;
      }
      
      this.notificationService.error(errorMessage);
      console.error('HTTP Error:', error);
      
      return throwError(() => error);
    })
  );
}
```

### Validation Error Handling

**Backend Validation Response Format**:
```typescript
interface ValidationErrorResponse {
  message: string;
  errors: {
    [field: string]: string[];
  };
}
```

**Frontend Validation Display**:
- Display field-specific errors below each form field
- Display general validation errors in toast notification
- Highlight invalid fields with red border

### Runtime Error Handling

**GlobalErrorHandler**:
```typescript
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  constructor(
    private notificationService: NotificationService
  ) {}
  
  handleError(error: Error): void {
    console.error('Runtime Error:', error);
    
    this.notificationService.error(
      'An unexpected error occurred. Please refresh the page.',
      'Application Error'
    );
  }
}
```

### Loading State Error Recovery

**LoadingInterceptor Error Handling**:
```typescript
intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
  this.loadingService.show();
  
  return next.handle(req).pipe(
    finalize(() => this.loadingService.hide()),
    catchError(error => {
      this.loadingService.hide(); // Ensure loading is hidden on error
      return throwError(() => error);
    })
  );
}
```


## Testing Strategy

### Dual Testing Approach

The application uses both unit tests and property-based tests for comprehensive coverage:

**Unit Tests**:
- Test specific examples and edge cases
- Test component rendering and user interactions
- Test service methods with mocked dependencies
- Test state management actions and reducers
- Focus on integration points between components

**Property-Based Tests**:
- Test universal properties across all inputs
- Use randomized input generation (minimum 100 iterations)
- Validate correctness properties from design document
- Each property test references its design document property
- Tag format: `Feature: tour-travel-frontend-phase1, Property {number}: {property_text}`

### Testing Framework Configuration

**Unit Testing**:
- Framework: Jasmine + Karma
- Component testing with TestBed
- Service testing with HttpClientTestingModule
- State testing with NgxsTestingModule

**Property-Based Testing**:
- Library: fast-check (TypeScript property-based testing)
- Configuration: Minimum 100 iterations per property
- Seed-based reproducibility for failed tests

### Test Organization

```
src/
├── app/
│   ├── core/
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   └── auth.service.spec.ts
│   │   ├── guards/
│   │   │   ├── auth.guard.ts
│   │   │   └── auth.guard.spec.ts
│   │   └── interceptors/
│   │       ├── auth.interceptor.ts
│   │       └── auth.interceptor.spec.ts
│   ├── shared/
│   │   └── components/
│   │       ├── data-table/
│   │       │   ├── data-table.component.ts
│   │       │   └── data-table.component.spec.ts
│   └── features/
│       └── agency/
│           ├── components/
│           │   ├── booking-form/
│           │   │   ├── booking-form.component.ts
│           │   │   ├── booking-form.component.spec.ts
│           │   │   └── booking-form.component.properties.spec.ts
```

### Property Test Example

```typescript
import * as fc from 'fast-check';

describe('Feature: tour-travel-frontend-phase1, Property 27: Booking Total Amount Calculation', () => {
  it('should calculate total_amount as selling_price × total_pax for any booking', () => {
    fc.assert(
      fc.property(
        fc.float({ min: 100, max: 10000 }), // selling_price
        fc.integer({ min: 1, max: 50 }),    // total_pax
        (sellingPrice, totalPax) => {
          const booking = createBooking({ sellingPrice, totalPax });
          const expectedTotal = sellingPrice * totalPax;
          
          expect(booking.total_amount).toBeCloseTo(expectedTotal, 2);
        }
      ),
      { numRuns: 100 }
    );
  });
});
```

### Unit Test Example

```typescript
describe('BookingFormComponent', () => {
  let component: BookingFormComponent;
  let fixture: ComponentFixture<BookingFormComponent>;
  
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BookingFormComponent, ReactiveFormsModule],
      providers: [
        { provide: Store, useValue: mockStore }
      ]
    }).compileComponents();
    
    fixture = TestBed.createComponent(BookingFormComponent);
    component = fixture.componentInstance;
  });
  
  it('should validate that total_pax does not exceed available_quota', () => {
    component.form.patchValue({
      journey_id: 1,
      total_pax: 15
    });
    
    component.availableQuota = 10;
    component.validateQuota();
    
    expect(component.form.get('total_pax')?.hasError('exceedsQuota')).toBe(true);
  });
});
```

### Test Coverage Goals

- Unit test coverage: Minimum 80% for services and components
- Property test coverage: All correctness properties from design document
- Integration test coverage: Critical user flows (login, booking creation, payment recording)
- E2E test coverage: Main user journeys for each portal


## Routing Configuration

### Route Structure

```typescript
// app.routes.ts
export const routes: Routes = [
  {
    path: '',
    component: LandingLayoutComponent,
    children: [
      { path: '', component: LandingPageComponent }
    ]
  },
  {
    path: 'auth',
    component: AuthLayoutComponent,
    children: [
      { path: 'login', component: LoginComponent },
      { path: 'register/supplier', component: SupplierRegistrationComponent }
    ]
  },
  {
    path: 'platform-admin',
    component: MainLayoutComponent,
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['platform_admin'] },
    children: [
      { path: 'dashboard', loadComponent: () => import('./features/platform-admin/dashboard/dashboard.component') },
      { path: 'agencies', loadComponent: () => import('./features/platform-admin/agencies/agency-list.component') },
      { path: 'suppliers', loadComponent: () => import('./features/platform-admin/suppliers/supplier-list.component') },
      { path: 'subscription-plans', loadComponent: () => import('./features/platform-admin/subscription-plans/subscription-plan-list.component') },
      { path: 'commission', loadComponent: () => import('./features/platform-admin/commission/commission-config.component') },
      { path: 'revenue', loadComponent: () => import('./features/platform-admin/revenue/revenue-dashboard.component') }
    ]
  },
  {
    path: 'supplier',
    component: MainLayoutComponent,
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['supplier_staff'] },
    children: [
      { path: 'services', loadComponent: () => import('./features/supplier/services/service-list.component') },
      { path: 'purchase-orders', loadComponent: () => import('./features/supplier/purchase-orders/purchase-order-list.component') }
    ]
  },
  {
    path: 'agency',
    component: MainLayoutComponent,
    canActivate: [AuthGuard, RoleGuard],
    data: { roles: ['agency_staff'] },
    children: [
      { path: 'procurement', loadComponent: () => import('./features/agency/procurement/supplier-browsing.component') },
      { path: 'packages', loadComponent: () => import('./features/agency/packages/package-list.component') },
      { path: 'journeys', loadComponent: () => import('./features/agency/journeys/journey-list.component') },
      { path: 'customers', loadComponent: () => import('./features/agency/customers/customer-list.component') },
      { path: 'bookings', loadComponent: () => import('./features/agency/bookings/booking-list.component') },
      { path: 'marketplace', loadComponent: () => import('./features/agency/marketplace/marketplace-browse.component') },
      { path: 'profitability', loadComponent: () => import('./features/agency/profitability/profitability-dashboard.component') }
    ]
  },
  { path: '**', redirectTo: '' }
];
```

### Lazy Loading Strategy

All feature routes use lazy loading with `loadComponent()` to reduce initial bundle size:

**Benefits**:
- Faster initial page load
- Smaller main bundle
- On-demand loading of features
- Better code splitting

**Implementation**:
```typescript
{
  path: 'bookings',
  loadComponent: () => import('./features/agency/bookings/booking-list.component')
    .then(m => m.BookingListComponent)
}
```

### Route Guards Application

**AuthGuard**: Applied to all routes except public routes (landing, login, registration)

**RoleGuard**: Applied to portal-specific routes with role restrictions:
- Platform Admin routes: `data: { roles: ['platform_admin'] }`
- Supplier routes: `data: { roles: ['supplier_staff'] }`
- Agency routes: `data: { roles: ['agency_staff'] }`

### Navigation Flow

**After Login**:
```typescript
// auth.effects.ts
@Effect()
loginSuccess$ = this.actions$.pipe(
  ofType(LoginSuccess),
  tap((action) => {
    const userType = action.user.user_type;
    
    switch (userType) {
      case 'platform_admin':
        this.router.navigate(['/platform-admin/dashboard']);
        break;
      case 'supplier_staff':
        this.router.navigate(['/supplier/services']);
        break;
      case 'agency_staff':
        this.router.navigate(['/agency/bookings']);
        break;
    }
  })
);
```


## Styling and Design System

### TailwindCSS Configuration

**tailwind.config.js**:
```javascript
module.exports = {
  content: ['./src/**/*.{html,ts}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          // ... full color scale
          900: '#0c4a6e'
        }
      },
      spacing: {
        '128': '32rem',
        '144': '36rem'
      }
    }
  },
  plugins: []
}
```

### PrimeNG Theme Customization

**styles.scss**:
```scss
// Import PrimeNG theme
@import 'primeng/resources/themes/lara-light-blue/theme.css';
@import 'primeng/resources/primeng.css';
@import 'primeicons/primeicons.css';

// Custom theme overrides
:root {
  --primary-color: #3b82f6;
  --primary-color-text: #ffffff;
  --surface-0: #ffffff;
  --surface-50: #f8fafc;
  --surface-100: #f1f5f9;
  --surface-200: #e2e8f0;
  --text-color: #1e293b;
  --text-color-secondary: #64748b;
}

// Component size overrides
.p-inputtext-sm {
  font-size: 0.875rem;
  padding: 0.5rem 0.75rem;
}

.p-datatable-sm {
  font-size: 0.875rem;
  
  .p-datatable-thead > tr > th {
    padding: 0.5rem 0.75rem;
  }
  
  .p-datatable-tbody > tr > td {
    padding: 0.5rem 0.75rem;
  }
}
```

### Design System Mixins

**_mixins.scss**:
```scss
@mixin modern-card {
  @apply bg-white rounded-lg shadow-sm border border-gray-200 p-6;
}

@mixin modern-input {
  @apply w-full border border-gray-300 rounded-md px-3 py-2 text-sm
         focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent;
}

@mixin modern-button {
  @apply px-4 py-2 rounded-md text-sm font-medium
         transition-colors duration-200
         focus:outline-none focus:ring-2 focus:ring-offset-2;
}

@mixin modern-table {
  @apply w-full border-collapse;
  
  thead {
    @apply bg-gray-50 border-b border-gray-200;
  }
  
  th {
    @apply px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider;
  }
  
  td {
    @apply px-4 py-3 text-sm text-gray-900;
  }
  
  tbody tr {
    @apply border-b border-gray-200 hover:bg-gray-50 transition-colors;
  }
}

@mixin modern-badge {
  @apply inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium;
}
```

### Responsive Breakpoints

```scss
// Mobile first approach
$breakpoints: (
  'sm': 640px,   // Small devices
  'md': 768px,   // Medium devices
  'lg': 1024px,  // Large devices
  'xl': 1280px,  // Extra large devices
  '2xl': 1536px  // 2X Extra large devices
);

// Usage
@media (min-width: map-get($breakpoints, 'md')) {
  .sidebar {
    display: block;
  }
}
```

### Component-Specific Styling

**Form Styling**:
```scss
.form-container {
  @include modern-card;
  
  .form-field {
    @apply mb-4;
    
    label {
      @apply block text-sm font-medium text-gray-700 mb-1;
    }
    
    input, select, textarea {
      @include modern-input;
    }
    
    .error-message {
      @apply text-red-600 text-xs mt-1;
    }
  }
}
```

**Table Styling**:
```scss
.data-table-container {
  @include modern-card;
  
  table {
    @include modern-table;
  }
  
  .status-badge {
    @include modern-badge;
    
    &.active {
      @apply bg-green-100 text-green-800;
    }
    
    &.inactive {
      @apply bg-red-100 text-red-800;
    }
    
    &.pending {
      @apply bg-yellow-100 text-yellow-800;
    }
  }
}
```


## Performance Optimization

### Lazy Loading Strategy

**Route-Level Code Splitting**:
- All feature modules loaded on-demand
- Reduces initial bundle size by ~60%
- Improves Time to Interactive (TTI)

**Component-Level Lazy Loading**:
```typescript
// Heavy components loaded on-demand
@Component({
  selector: 'app-chart',
  template: `
    @if (chartData) {
      <ng-container *ngComponentOutlet="chartComponent"></ng-container>
    }
  `
})
export class ChartWrapperComponent {
  chartComponent = import('./chart.component').then(m => m.ChartComponent);
}
```

### Change Detection Optimization

**OnPush Strategy**:
```typescript
@Component({
  selector: 'app-booking-list',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `...`
})
export class BookingListComponent {
  // Component only checks for changes when:
  // 1. Input references change
  // 2. Events are triggered
  // 3. Async pipe emits new value
}
```

### Virtual Scrolling for Large Lists

```typescript
@Component({
  template: `
    <cdk-virtual-scroll-viewport itemSize="50" class="viewport">
      <div *cdkVirtualFor="let item of items" class="item">
        {{ item.name }}
      </div>
    </cdk-virtual-scroll-viewport>
  `
})
export class LargeListComponent {
  items: any[] = []; // Can handle 10,000+ items efficiently
}
```

### Image Optimization

**Lazy Loading Images**:
```html
<img 
  [src]="imageUrl" 
  loading="lazy"
  [alt]="imageAlt"
  class="w-full h-auto"
>
```

**Responsive Images**:
```html
<img 
  [srcset]="imageSrcSet"
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  [src]="imageFallback"
  [alt]="imageAlt"
>
```

### Bundle Size Optimization

**Tree Shaking**:
- Import only used PrimeNG components
- Use standalone components to eliminate NgModule overhead
- Import specific Lucide icons instead of entire library

**Example**:
```typescript
// ❌ Bad: Imports entire library
import * as lucide from 'lucide-angular';

// ✅ Good: Imports only needed icons
import { Home, User, Settings } from 'lucide-angular';
```

### Caching Strategy

**HTTP Caching**:
```typescript
@Injectable()
export class CacheInterceptor implements HttpInterceptor {
  private cache = new Map<string, HttpResponse<any>>();
  
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    if (req.method !== 'GET') {
      return next.handle(req);
    }
    
    const cachedResponse = this.cache.get(req.url);
    if (cachedResponse) {
      return of(cachedResponse);
    }
    
    return next.handle(req).pipe(
      tap(event => {
        if (event instanceof HttpResponse) {
          this.cache.set(req.url, event);
        }
      })
    );
  }
}
```

**State Caching**:
```typescript
@State<AgencyStateModel>({
  name: 'agencies',
  defaults: {
    agencies: [],
    loaded: false,
    loading: false
  }
})
export class AgencyState {
  @Action(LoadAgencies)
  loadAgencies(ctx: StateContext<AgencyStateModel>) {
    const state = ctx.getState();
    
    // Skip loading if already loaded
    if (state.loaded) {
      return;
    }
    
    ctx.patchState({ loading: true });
    
    return this.agencyService.getAll().pipe(
      tap(agencies => {
        ctx.patchState({
          agencies,
          loaded: true,
          loading: false
        });
      })
    );
  }
}
```


## Security Considerations

### Authentication Security

**JWT Token Storage**:
- Store JWT in localStorage (acceptable for MVP)
- Consider httpOnly cookies for production
- Implement token refresh mechanism
- Clear token on logout

**Token Expiration Handling**:
```typescript
@Injectable()
export class TokenExpirationInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      catchError((error: HttpErrorResponse) => {
        if (error.status === 401) {
          // Token expired
          this.authService.logout();
          this.router.navigate(['/login']);
          this.notificationService.error('Session expired. Please login again.');
        }
        return throwError(() => error);
      })
    );
  }
}
```

### XSS Prevention

**Template Sanitization**:
- Angular automatically sanitizes templates
- Use DomSanitizer for trusted content only
- Never use innerHTML with user input

**Example**:
```typescript
// ❌ Dangerous
template: `<div [innerHTML]="userInput"></div>`

// ✅ Safe
template: `<div>{{ userInput }}</div>`

// ✅ Safe with sanitization
constructor(private sanitizer: DomSanitizer) {}

get safeHtml() {
  return this.sanitizer.sanitize(SecurityContext.HTML, this.userInput);
}
```

### CSRF Protection

**CSRF Token Handling**:
```typescript
@Injectable()
export class CsrfInterceptor implements HttpInterceptor {
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const csrfToken = this.getCsrfToken();
    
    if (csrfToken && this.isModifyingRequest(req)) {
      req = req.clone({
        setHeaders: { 'X-CSRF-Token': csrfToken }
      });
    }
    
    return next.handle(req);
  }
  
  private isModifyingRequest(req: HttpRequest<any>): boolean {
    return ['POST', 'PUT', 'PATCH', 'DELETE'].includes(req.method);
  }
}
```

### Input Validation

**Client-Side Validation**:
- Validate all user inputs
- Use Angular Reactive Forms validators
- Implement custom validators for business rules
- Never trust client-side validation alone

**Example**:
```typescript
this.form = this.fb.group({
  email: ['', [Validators.required, Validators.email]],
  phone: ['', [Validators.required, this.phoneValidator]],
  amount: ['', [Validators.required, Validators.min(0)]]
});

phoneValidator(control: AbstractControl): ValidationErrors | null {
  const phoneRegex = /^\+?[1-9]\d{1,14}$/;
  return phoneRegex.test(control.value) ? null : { invalidPhone: true };
}
```

### Role-Based Access Control

**Route Protection**:
```typescript
@Injectable()
export class RoleGuard implements CanActivate {
  canActivate(route: ActivatedRouteSnapshot): boolean {
    const allowedRoles = route.data['roles'] as string[];
    const userType = this.authService.getUserType();
    
    if (!allowedRoles.includes(userType)) {
      this.notificationService.error('Access denied');
      this.router.navigate(['/']);
      return false;
    }
    
    return true;
  }
}
```

**Component-Level Protection**:
```typescript
@Component({
  template: `
    @if (hasPermission('delete_booking')) {
      <button (click)="deleteBooking()">Delete</button>
    }
  `
})
export class BookingDetailComponent {
  hasPermission(permission: string): boolean {
    return this.authService.hasPermission(permission);
  }
}
```

### Sensitive Data Handling

**Avoid Logging Sensitive Data**:
```typescript
// ❌ Bad
console.log('User data:', user);

// ✅ Good
console.log('User ID:', user.id);
```

**Mask Sensitive Information**:
```typescript
maskCreditCard(cardNumber: string): string {
  return cardNumber.replace(/\d(?=\d{4})/g, '*');
}

maskEmail(email: string): string {
  const [name, domain] = email.split('@');
  return `${name[0]}***@${domain}`;
}
```


## Accessibility

### WCAG 2.1 Compliance

**Level AA Compliance Goals**:
- Keyboard navigation support
- Screen reader compatibility
- Sufficient color contrast (4.5:1 for normal text)
- Focus indicators
- ARIA labels and roles

### Keyboard Navigation

**Focus Management**:
```typescript
@Component({
  template: `
    <button 
      #firstButton
      (click)="handleAction()"
      class="focus:ring-2 focus:ring-blue-500 focus:outline-none"
    >
      Action
    </button>
  `
})
export class ActionComponent implements AfterViewInit {
  @ViewChild('firstButton') firstButton!: ElementRef;
  
  ngAfterViewInit() {
    // Auto-focus first interactive element
    this.firstButton.nativeElement.focus();
  }
}
```

**Keyboard Shortcuts**:
```typescript
@HostListener('document:keydown', ['$event'])
handleKeyboardEvent(event: KeyboardEvent) {
  if (event.ctrlKey && event.key === 's') {
    event.preventDefault();
    this.saveForm();
  }
}
```

### Screen Reader Support

**ARIA Labels**:
```html
<!-- Form fields -->
<label for="email" class="sr-only">Email Address</label>
<input 
  id="email"
  type="email"
  aria-label="Email Address"
  aria-required="true"
  aria-invalid="false"
>

<!-- Buttons -->
<button 
  aria-label="Delete booking"
  (click)="deleteBooking()"
>
  <lucide-icon name="trash-2"></lucide-icon>
</button>

<!-- Status indicators -->
<span 
  class="status-badge"
  role="status"
  aria-label="Booking status: Approved"
>
  Approved
</span>
```

**ARIA Live Regions**:
```html
<!-- Toast notifications -->
<div 
  role="alert"
  aria-live="polite"
  aria-atomic="true"
  class="toast-notification"
>
  {{ message }}
</div>

<!-- Loading states -->
<div 
  role="status"
  aria-live="polite"
  aria-busy="true"
>
  <span class="sr-only">Loading...</span>
  <lucide-icon name="loader" class="animate-spin"></lucide-icon>
</div>
```

### Color Contrast

**Accessible Color Palette**:
```scss
// Text colors with sufficient contrast
$text-primary: #1e293b;    // Contrast ratio: 12.63:1 on white
$text-secondary: #64748b;  // Contrast ratio: 4.54:1 on white
$text-disabled: #94a3b8;   // Contrast ratio: 3.01:1 on white

// Status colors with sufficient contrast
$success: #059669;  // Contrast ratio: 4.52:1 on white
$error: #dc2626;    // Contrast ratio: 5.94:1 on white
$warning: #d97706;  // Contrast ratio: 4.51:1 on white
$info: #0284c7;     // Contrast ratio: 4.54:1 on white
```

### Form Accessibility

**Error Announcements**:
```html
<div class="form-field">
  <label for="email">Email</label>
  <input 
    id="email"
    type="email"
    [attr.aria-invalid]="emailControl.invalid && emailControl.touched"
    [attr.aria-describedby]="emailControl.invalid ? 'email-error' : null"
  >
  @if (emailControl.invalid && emailControl.touched) {
    <span 
      id="email-error"
      role="alert"
      class="error-message"
    >
      {{ getErrorMessage(emailControl) }}
    </span>
  }
</div>
```

### Skip Links

**Skip to Main Content**:
```html
<a 
  href="#main-content"
  class="skip-link"
  tabindex="0"
>
  Skip to main content
</a>

<main id="main-content" tabindex="-1">
  <!-- Main content -->
</main>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
</style>
```


## Deployment and Build Configuration

### Build Optimization

**Production Build Configuration**:
```json
// angular.json
{
  "configurations": {
    "production": {
      "optimization": true,
      "outputHashing": "all",
      "sourceMap": false,
      "namedChunks": false,
      "aot": true,
      "extractLicenses": true,
      "vendorChunk": false,
      "buildOptimizer": true,
      "budgets": [
        {
          "type": "initial",
          "maximumWarning": "500kb",
          "maximumError": "1mb"
        },
        {
          "type": "anyComponentStyle",
          "maximumWarning": "2kb",
          "maximumError": "4kb"
        }
      ]
    }
  }
}
```

### Environment Configuration

**environment.ts (Development)**:
```typescript
export const environment = {
  production: false,
  apiUrl: 'http://localhost:3000/api',
  apiReady: false,
  mockDelay: 500,
  enableDevTools: true,
  logLevel: 'debug'
};
```

**environment.prod.ts (Production)**:
```typescript
export const environment = {
  production: true,
  apiUrl: 'https://api.jourva.com/api',
  apiReady: true,
  mockDelay: 0,
  enableDevTools: false,
  logLevel: 'error'
};
```

### Docker Configuration

**Dockerfile**:
```dockerfile
# Build stage
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration=production

# Production stage
FROM nginx:alpine
COPY --from=build /app/dist/tour-travel-frontend /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**nginx.conf**:
```nginx
server {
  listen 80;
  server_name _;
  root /usr/share/nginx/html;
  index index.html;

  # Gzip compression
  gzip on;
  gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

  # Cache static assets
  location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
  }

  # Angular routing
  location / {
    try_files $uri $uri/ /index.html;
  }

  # Security headers
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Content-Type-Options "nosniff" always;
  add_header X-XSS-Protection "1; mode=block" always;
  add_header Referrer-Policy "no-referrer-when-downgrade" always;
}
```

### CI/CD Pipeline

**GitHub Actions Workflow**:
```yaml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linter
        run: npm run lint
      
      - name: Run tests
        run: npm run test:ci
      
      - name: Build
        run: npm run build -- --configuration=production
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: dist
          path: dist/
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v3
        with:
          name: dist
      
      - name: Deploy to production
        run: |
          # Deploy commands here
          echo "Deploying to production..."
```

### Monitoring and Analytics

**Error Tracking**:
```typescript
// Integrate Sentry for error tracking
import * as Sentry from '@sentry/angular';

Sentry.init({
  dsn: environment.sentryDsn,
  environment: environment.production ? 'production' : 'development',
  tracesSampleRate: 1.0
});
```

**Analytics**:
```typescript
// Integrate Google Analytics
import { GoogleAnalyticsService } from 'ngx-google-analytics';

export class AppComponent {
  constructor(private ga: GoogleAnalyticsService) {
    this.ga.pageView('/');
  }
  
  trackEvent(category: string, action: string, label?: string) {
    this.ga.event(action, category, label);
  }
}
```



---

## API Response Handling

**Validates: Requirement 50**

### Overview

The frontend handles standardized API responses from the backend with automatic unwrapping, error handling, and snake_case to camelCase conversion.

### Response Interfaces

**TypeScript Interfaces:**

```typescript
// core/models/api-response.model.ts

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
  timestamp: string;
}

export interface PaginatedApiResponse<T> {
  success: boolean;
  data: T[];
  pagination: PaginationMetadata;
  message: string;
  timestamp: string;
}

export interface PaginationMetadata {
  page: number;
  page_size: number;
  total_items: number;
  total_pages: number;
}

export interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details: any[];
  };
  timestamp: string;
}

export type ErrorCode = 
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'BUSINESS_RULE_VIOLATION'
  | 'INTERNAL_SERVER_ERROR';
```

### HTTP Interceptors

**1. ApiResponseInterceptor - Automatic Unwrapping:**

```typescript
// core/interceptors/api-response.interceptor.ts

import { HttpInterceptorFn } from '@angular/common/http';
import { map } from 'rxjs/operators';

export const apiResponseInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe(
    map(event => {
      if (event.type === HttpEventType.Response) {
        const body = event.body;
        
        // Check if response is wrapped in ApiResponse format
        if (body && typeof body === 'object' && 'success' in body && 'data' in body) {
          // Automatically unwrap and return only the data
          return event.clone({ body: body.data });
        }
      }
      return event;
    })
  );
};
```

**2. ErrorHandlerInterceptor - Standardized Error Handling:**

```typescript
// core/interceptors/error-handler.interceptor.ts

import { HttpInterceptorFn, HttpErrorResponse } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';
import { NotificationService } from '../services/notification.service';
import { ApiErrorResponse, ErrorCode } from '../models/api-response.model';

export const errorHandlerInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  const notificationService = inject(NotificationService);

  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      if (error.error && typeof error.error === 'object' && 'error' in error.error) {
        const apiError = error.error as ApiErrorResponse;
        handleApiError(apiError, router, notificationService);
      } else {
        // Handle non-API errors
        notificationService.error('An unexpected error occurred');
      }
      
      return throwError(() => error);
    })
  );
};

function handleApiError(
  apiError: ApiErrorResponse,
  router: Router,
  notificationService: NotificationService
): void {
  const errorCode = apiError.error.code as ErrorCode;
  
  switch (errorCode) {
    case 'VALIDATION_ERROR':
      // Display validation errors
      if (apiError.error.details && apiError.error.details.length > 0) {
        apiError.error.details.forEach((detail: any) => {
          notificationService.error(`${detail.field}: ${detail.message}`);
        });
      } else {
        notificationService.error(apiError.error.message);
      }
      break;
      
    case 'UNAUTHORIZED':
      notificationService.error('Session expired. Please login again.');
      router.navigate(['/login']);
      break;
      
    case 'FORBIDDEN':
      notificationService.error('You do not have permission to perform this action');
      break;
      
    case 'NOT_FOUND':
      notificationService.error(apiError.error.message || 'Resource not found');
      break;
      
    case 'CONFLICT':
      notificationService.error(apiError.error.message || 'Resource conflict');
      break;
      
    case 'BUSINESS_RULE_VIOLATION':
      notificationService.error(apiError.error.message);
      if (apiError.error.details && apiError.error.details.length > 0) {
        console.error('Business rule violation details:', apiError.error.details);
      }
      break;
      
    case 'INTERNAL_SERVER_ERROR':
      notificationService.error('An unexpected error occurred. Please try again later.');
      break;
      
    default:
      notificationService.error(apiError.error.message || 'An error occurred');
  }
}
```

**3. Register Interceptors in app.config.ts:**

```typescript
// app.config.ts

import { ApplicationConfig } from '@angular/core';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { apiResponseInterceptor } from './core/interceptors/api-response.interceptor';
import { errorHandlerInterceptor } from './core/interceptors/error-handler.interceptor';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { loadingInterceptor } from './core/interceptors/loading.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideHttpClient(
      withInterceptors([
        authInterceptor,
        apiResponseInterceptor,  // Unwrap responses
        errorHandlerInterceptor, // Handle errors
        loadingInterceptor
      ])
    ),
    // ... other providers
  ]
};
```

### API Service Usage

**With Automatic Unwrapping:**

```typescript
// core/services/agency-api.service.ts

@Injectable({ providedIn: 'root' })
export class AgencyApiService {
  private apiUrl = `${environment.apiUrl}/admin/agencies`;

  constructor(private http: HttpClient) {}

  getAll(page: number = 1, pageSize: number = 20): Observable<PaginatedResult<Agency>> {
    // Backend returns: { success: true, data: { agencies, pagination }, ... }
    // Interceptor unwraps to: { agencies, pagination }
    return this.http.get<PaginatedResult<Agency>>(
      `${this.apiUrl}?page=${page}&page_size=${pageSize}`
    );
  }

  getById(id: string): Observable<Agency> {
    // Backend returns: { success: true, data: { id, agency_code, ... }, ... }
    // Interceptor unwraps to: { id, agency_code, ... }
    return this.http.get<Agency>(`${this.apiUrl}/${id}`);
  }

  create(data: CreateAgencyRequest): Observable<Agency> {
    // Backend returns: { success: true, data: { id, agency_code, ... }, ... }
    // Interceptor unwraps to: { id, agency_code, ... }
    return this.http.post<Agency>(this.apiUrl, data);
  }
}

// Response interfaces (matching backend snake_case)
export interface Agency {
  id: string;
  agency_code: string;
  company_name: string;
  email: string;
  phone: string;
  is_active: boolean;
  created_at: string;
}

export interface PaginatedResult<T> {
  agencies: T[];  // or data: T[] depending on endpoint
  pagination: PaginationMetadata;
}
```

### Component Usage

**Clean Component Code:**

```typescript
// features/platform-admin/agencies/agency-list/agency-list.component.ts

@Component({
  selector: 'app-agency-list',
  standalone: true,
  imports: [CommonModule, PrimeNgModules],
  templateUrl: './agency-list.component.html'
})
export class AgencyListComponent implements OnInit {
  agencies: Agency[] = [];
  pagination: PaginationMetadata | null = null;
  loading = false;

  constructor(
    private agencyService: AgencyApiService,
    private notificationService: NotificationService
  ) {}

  ngOnInit(): void {
    this.loadAgencies();
  }

  loadAgencies(page: number = 1): void {
    this.loading = true;
    
    this.agencyService.getAll(page, 20).subscribe({
      next: (result) => {
        // Data already unwrapped by interceptor
        this.agencies = result.agencies;
        this.pagination = result.pagination;
        this.loading = false;
      },
      error: () => {
        // Error already handled by interceptor (toast shown)
        this.loading = false;
      }
    });
  }

  createAgency(data: CreateAgencyRequest): void {
    this.agencyService.create(data).subscribe({
      next: (agency) => {
        // Success! Data already unwrapped
        this.notificationService.success('Agency created successfully');
        this.loadAgencies();
      },
      error: () => {
        // Error already handled by interceptor
      }
    });
  }
}
```

### Benefits

✅ **Automatic Unwrapping:** Components receive clean data without wrapper
✅ **Consistent Error Handling:** All errors handled in one place
✅ **Type Safety:** TypeScript interfaces match backend responses
✅ **Clean Code:** No repetitive error handling in every component
✅ **Centralized Logic:** Change error handling behavior in one place

### snake_case to camelCase Conversion (Optional)

If you prefer camelCase in frontend:

```typescript
// core/interceptors/case-converter.interceptor.ts

import { HttpInterceptorFn } from '@angular/common/http';
import { map } from 'rxjs/operators';

export const caseConverterInterceptor: HttpInterceptorFn = (req, next) => {
  return next(req).pipe(
    map(event => {
      if (event.type === HttpEventType.Response && event.body) {
        // Convert snake_case to camelCase
        return event.clone({ body: convertKeysToCamelCase(event.body) });
      }
      return event;
    })
  );
};

function convertKeysToCamelCase(obj: any): any {
  if (Array.isArray(obj)) {
    return obj.map(item => convertKeysToCamelCase(item));
  } else if (obj !== null && typeof obj === 'object') {
    return Object.keys(obj).reduce((result, key) => {
      const camelKey = key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());
      result[camelKey] = convertKeysToCamelCase(obj[key]);
      return result;
    }, {} as any);
  }
  return obj;
}
```

**Note:** Untuk Phase 1, kita akan keep snake_case di frontend untuk consistency dengan backend. Conversion bisa ditambahkan nanti jika diperlukan.

---

## Additional Design Documents

### Self-Registration with KYC Verification

For detailed design specifications of the Self-Registration and KYC (Know Your Customer) Verification features for both Agencies and Suppliers, refer to:

**#[[file:design-self-registration-kyc.md]]**

This document covers:
- Public registration pages for agencies and suppliers
- Document upload interface with progress tracking
- Platform admin verification dashboard
- Document management and preview functionality
- Access control based on verification status
- MinIO integration for document storage
- Complete component specifications with TypeScript and HTML templates

The Self-Registration & KYC feature extends the main design with additional:
- 10+ new components (registration forms, document upload, verification queue)
- Document and Verification services
- NGXS store for document state management
- Verification route guard
- Responsive UI with PrimeNG and TailwindCSS

---
