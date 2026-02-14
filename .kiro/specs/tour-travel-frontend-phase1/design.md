# Design Document

## Overview

This design document specifies the technical architecture for Phase 1 MVP of the Tour & Travel Agency ERP SaaS Platform Frontend. The system is built using Angular 20 with standalone components, following Clean Architecture principles with feature-based organization. The frontend provides three distinct portals (Platform Admin, Supplier, and Agency) with comprehensive ERP functionality.

### System Architecture

The frontend follows a feature-based architecture with clear separation of concerns:

1. **Core Layer**: Singleton services, guards, interceptors, and core models
2. **Shared Layer**: Reusable components, directives, pipes, and utilities
3. **Features Layer**: Self-contained feature modules with components, services, models, and routes
4. **Store Layer**: NgRx state management organized by feature
5. **Layouts Layer**: Application layouts (main-layout, auth-layout)

### Technology Stack

- **Framework**: Angular 20 with Standalone Components
- **State Management**: NgRx 18 (Store, Effects, Selectors)
- **UI Components**: PrimeNG 20 with @primeuix/themes
- **Styling**: TailwindCSS 4 (utility-first)
- **Icons**: Lucide Angular
- **Forms**: Angular Reactive Forms with validation
- **HTTP**: Angular HttpClient with interceptors
- **Routing**: Angular Router with lazy loading
- **Build**: Angular CLI with esbuild

### Multi-Tenancy Strategy

The frontend implements multi-tenant support through:
- JWT token containing user_type, agency_id, and supplier_id
- Route guards restricting access based on user_type
- State management isolating tenant data
- API requests automatically including tenant context via interceptors


## Architecture

### Folder Structure

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
│   │   │   ├── notification.service.ts
│   │   │   └── loading.service.ts
│   │   └── models/                     # Core models/interfaces
│   │       ├── user.model.ts
│   │       ├── api-response.model.ts
│   │       └── jwt-payload.model.ts
│   │
│   ├── shared/                         # Shared components & utilities
│   │   ├── components/                 # Reusable UI components
│   │   │   ├── data-table/
│   │   │   ├── page-header/
│   │   │   ├── confirmation-dialog/
│   │   │   ├── loading-spinner/
│   │   │   └── breadcrumb/
│   │   ├── directives/                 # Shared directives
│   │   │   └── permission.directive.ts
│   │   ├── pipes/                      # Shared pipes
│   │   │   ├── date-format.pipe.ts
│   │   │   └── currency-format.pipe.ts
│   │   └── utils/                      # Utility functions
│   │       ├── date.utils.ts
│   │       └── validation.utils.ts
│   │
│   ├── features/                       # Feature modules (standalone)
│   │   ├── auth/                       # Authentication feature
│   │   │   ├── components/
│   │   │   │   ├── login/
│   │   │   │   └── forgot-password/
│   │   │   ├── services/
│   │   │   │   └── auth-api.service.ts
│   │   │   └── auth.routes.ts
│   │   │
│   │   ├── platform-admin/             # Platform Admin Portal
│   │   │   ├── components/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── agency-list/
│   │   │   │   ├── agency-form/
│   │   │   │   ├── supplier-list/
│   │   │   │   └── supplier-approval/
│   │   │   ├── services/
│   │   │   ├── models/
│   │   │   └── platform-admin.routes.ts
│   │   │
│   │   ├── supplier/                   # Supplier Portal
│   │   │   ├── components/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── service-list/
│   │   │   │   ├── service-form/
│   │   │   │   ├── seasonal-pricing/
│   │   │   │   └── purchase-order-list/
│   │   │   ├── services/
│   │   │   ├── models/
│   │   │   └── supplier.routes.ts
│   │   │
│   │   ├── agency/                     # Agency Portal
│   │   │   ├── components/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── procurement/        # Supplier browsing & PO
│   │   │   │   ├── packages/           # Package management
│   │   │   │   ├── journeys/           # Journey management
│   │   │   │   ├── customers/          # Customer CRM
│   │   │   │   ├── bookings/           # Booking management
│   │   │   │   ├── documents/          # Document tracking
│   │   │   │   ├── tasks/              # Task management
│   │   │   │   ├── notifications/      # Notification config
│   │   │   │   ├── payments/           # Payment tracking
│   │   │   │   ├── itinerary/          # Itinerary builder
│   │   │   │   ├── supplier-bills/     # Payables
│   │   │   │   ├── communication/      # Communication log
│   │   │   │   ├── marketplace/        # B2B marketplace
│   │   │   │   └── profitability/      # Profitability tracking
│   │   │   ├── services/
│   │   │   ├── models/
│   │   │   └── agency.routes.ts
│   │
│   ├── store/                          # NgRx Store
│   │   ├── auth/
│   │   │   ├── auth.actions.ts
│   │   │   ├── auth.reducer.ts
│   │   │   ├── auth.effects.ts
│   │   │   ├── auth.selectors.ts
│   │   │   └── auth.state.ts
│   │   ├── platform-admin/
│   │   ├── supplier/
│   │   ├── agency/
│   │   └── index.ts                    # Root store config
│   │
│   ├── layouts/                        # Layout components
│   │   ├── main-layout/
│   │   │   ├── main-layout.component.ts
│   │   │   ├── main-layout.component.html
│   │   │   └── main-layout.component.scss
│   │   ├── auth-layout/
│   │   ├── components/
│   │   │   ├── header/
│   │   │   ├── sidebar/
│   │   │   └── footer/
│   │   └── layout.routes.ts
│   │
│   ├── app.config.ts                   # App configuration
│   ├── app.routes.ts                   # Root routes
│   ├── app.component.ts                # Root component
│   ├── app.component.html
│   └── app.component.scss
│
├── assets/                             # Static assets
│   ├── images/
│   ├── icons/
│   └── i18n/                           # Internationalization
│       ├── en.json
│       └── id.json
│
├── environments/                       # Environment configs
│   ├── environment.ts                  # Development
│   └── environment.prod.ts             # Production
│
├── styles/                             # Global styles
│   ├── _variables.scss
│   ├── _mixins.scss
│   ├── _tailwind.scss
│   └── _primeng-theme.scss
│
├── index.html
├── main.ts
└── styles.scss
```

### Request Flow

1. User Action → Component
2. Component → Dispatch NgRx Action
3. Action → NgRx Effect
4. Effect → API Service (HTTP Request)
5. HTTP Request → Interceptors (Auth, Loading, Error)
6. API Response → Effect
7. Effect → Dispatch Success/Failure Action
8. Reducer → Update State
9. Selector → Derive State
10. Component → Subscribe to Selector → Update UI

### Authentication Flow

1. User submits credentials to LoginComponent
2. Component dispatches login action
3. Effect calls AuthService.login()
4. AuthService sends POST /api/auth/login
5. Backend returns JWT token with user_type, agency_id, supplier_id
6. Effect dispatches loginSuccess action with token and user data
7. Reducer stores token in state
8. AuthService stores token in localStorage
9. AuthGuard allows navigation to protected routes
10. AuthInterceptor attaches token to subsequent requests


## Components and Interfaces

### Core Services

#### AuthService

**Purpose**: Manages authentication state and JWT token operations

**Methods**:
- `login(credentials: LoginCredentials): Observable<AuthResponse>` - Authenticate user
- `logout(): void` - Clear authentication state
- `getToken(): string | null` - Retrieve stored JWT token
- `isAuthenticated(): boolean` - Check if user is authenticated
- `getUserType(): UserType | null` - Get current user type
- `getAgencyId(): string | null` - Get current agency ID
- `getSupplierId(): string | null` - Get current supplier ID

**Implementation**:
```typescript
@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly TOKEN_KEY = 'auth_token';
  private readonly USER_KEY = 'user_data';
  
  constructor(
    private http: HttpClient,
    private router: Router
  ) {}
  
  login(credentials: LoginCredentials): Observable<AuthResponse> {
    return this.http.post<AuthResponse>('/api/auth/login', credentials)
      .pipe(
        tap(response => {
          localStorage.setItem(this.TOKEN_KEY, response.token);
          localStorage.setItem(this.USER_KEY, JSON.stringify(response.user));
        })
      );
  }
  
  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.USER_KEY);
    this.router.navigate(['/auth/login']);
  }
  
  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }
  
  isAuthenticated(): boolean {
    const token = this.getToken();
    if (!token) return false;
    
    try {
      const payload = this.decodeToken(token);
      return payload.exp > Date.now() / 1000;
    } catch {
      return false;
    }
  }
  
  private decodeToken(token: string): JwtPayload {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    return JSON.parse(window.atob(base64));
  }
}
```

#### NotificationService

**Purpose**: Manages toast notifications using PrimeNG Toast

**Methods**:
- `success(message: string, title?: string): void` - Show success toast
- `error(message: string, title?: string): void` - Show error toast
- `warning(message: string, title?: string): void` - Show warning toast
- `info(message: string, title?: string): void` - Show info toast

**Implementation**:
```typescript
@Injectable({ providedIn: 'root' })
export class NotificationService {
  constructor(private messageService: MessageService) {}
  
  success(message: string, title: string = 'Success'): void {
    this.messageService.add({
      severity: 'success',
      summary: title,
      detail: message,
      life: 5000
    });
  }
  
  error(message: string, title: string = 'Error'): void {
    this.messageService.add({
      severity: 'error',
      summary: title,
      detail: message,
      life: 5000
    });
  }
}
```

#### LoadingService

**Purpose**: Manages global loading state

**Methods**:
- `show(): void` - Show loading spinner
- `hide(): void` - Hide loading spinner
- `isLoading$: Observable<boolean>` - Observable of loading state

**Implementation**:
```typescript
@Injectable({ providedIn: 'root' })
export class LoadingService {
  private loadingSubject = new BehaviorSubject<boolean>(false);
  private requestCount = 0;
  
  isLoading$ = this.loadingSubject.asObservable();
  
  show(): void {
    this.requestCount++;
    this.loadingSubject.next(true);
  }
  
  hide(): void {
    this.requestCount--;
    if (this.requestCount <= 0) {
      this.requestCount = 0;
      this.loadingSubject.next(false);
    }
  }
}
```

### Core Guards

#### AuthGuard

**Purpose**: Protect routes requiring authentication

**Implementation**:
```typescript
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  
  if (authService.isAuthenticated()) {
    return true;
  }
  
  router.navigate(['/auth/login'], {
    queryParams: { returnUrl: state.url }
  });
  return false;
};
```

#### RoleGuard

**Purpose**: Protect routes based on user role

**Implementation**:
```typescript
export const roleGuard = (allowedRoles: UserType[]): CanActivateFn => {
  return (route, state) => {
    const authService = inject(AuthService);
    const router = inject(Router);
    const notificationService = inject(NotificationService);
    
    const userType = authService.getUserType();
    
    if (userType && allowedRoles.includes(userType)) {
      return true;
    }
    
    notificationService.error('You do not have permission to access this page');
    router.navigate(['/dashboard']);
    return false;
  };
};
```

### Core Interceptors

#### AuthInterceptor

**Purpose**: Attach JWT token to outgoing requests

**Implementation**:
```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const authService = inject(AuthService);
  const token = authService.getToken();
  
  if (token) {
    req = req.clone({
      setHeaders: {
        Authorization: `Bearer ${token}`
      }
    });
  }
  
  return next(req);
};
```

#### ErrorInterceptor

**Purpose**: Handle HTTP errors globally

**Implementation**:
```typescript
export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const notificationService = inject(NotificationService);
  const authService = inject(AuthService);
  const router = inject(Router);
  
  return next(req).pipe(
    catchError((error: HttpErrorResponse) => {
      let errorMessage = 'An unexpected error occurred';
      
      if (error.status === 401) {
        authService.logout();
        router.navigate(['/auth/login']);
        errorMessage = 'Session expired. Please login again.';
      } else if (error.status === 403) {
        errorMessage = 'You do not have permission to perform this action';
      } else if (error.status === 404) {
        errorMessage = 'Resource not found';
      } else if (error.status === 400) {
        errorMessage = error.error?.message || 'Invalid request';
      } else if (error.status === 500) {
        errorMessage = 'Server error. Please try again later.';
      }
      
      notificationService.error(errorMessage);
      return throwError(() => error);
    })
  );
};
```

#### LoadingInterceptor

**Purpose**: Track HTTP requests for loading state

**Implementation**:
```typescript
export const loadingInterceptor: HttpInterceptorFn = (req, next) => {
  const loadingService = inject(LoadingService);
  
  loadingService.show();
  
  return next(req).pipe(
    finalize(() => loadingService.hide())
  );
};
```


### Shared Components

#### DataTableComponent

**Purpose**: Reusable table component with sorting, filtering, and pagination

**Inputs**:
- `columns: TableColumn[]` - Column configuration
- `data: any[]` - Table data
- `loading: boolean` - Loading state
- `paginator: boolean` - Enable pagination
- `rows: number` - Rows per page
- `globalFilterFields: string[]` - Fields for global search

**Outputs**:
- `onRowSelect: EventEmitter<any>` - Row selection event
- `onRowEdit: EventEmitter<any>` - Row edit event
- `onRowDelete: EventEmitter<any>` - Row delete event

**Template Structure**:
```html
<p-table 
  [value]="data" 
  [columns]="columns"
  [loading]="loading"
  [paginator]="paginator"
  [rows]="rows"
  [globalFilterFields]="globalFilterFields"
  styleClass="p-datatable-sm"
  [rowHover]="true"
  [responsive]="true">
  
  <ng-template pTemplate="caption">
    <div class="flex justify-between items-center">
      <span class="p-input-icon-left w-full md:w-auto">
        <i class="pi pi-search"></i>
        <input 
          pInputText 
          type="text" 
          class="p-inputtext-sm w-full"
          (input)="onGlobalFilter($event)" 
          placeholder="Search..." />
      </span>
      <ng-content select="[actions]"></ng-content>
    </div>
  </ng-template>
  
  <ng-template pTemplate="header" let-columns>
    <tr>
      <th *ngFor="let col of columns" [pSortableColumn]="col.sortable ? col.field : null">
        {{ col.header }}
        <p-sortIcon *ngIf="col.sortable" [field]="col.field"></p-sortIcon>
      </th>
      <th *ngIf="hasActions">Actions</th>
    </tr>
  </ng-template>
  
  <ng-template pTemplate="body" let-rowData let-columns="columns">
    <tr [pSelectableRow]="rowData">
      <td *ngFor="let col of columns">
        <ng-container *ngIf="col.template; else defaultCell">
          <ng-container *ngTemplateOutlet="col.template; context: {$implicit: rowData}"></ng-container>
        </ng-container>
        <ng-template #defaultCell>
          {{ rowData[col.field] }}
        </ng-template>
      </td>
      <td *ngIf="hasActions">
        <div class="flex gap-2">
          <p-button 
            icon="pi pi-pencil" 
            size="small"
            [rounded]="true"
            severity="info"
            [outlined]="true"
            (onClick)="onRowEdit.emit(rowData)"></p-button>
          <p-button 
            icon="pi pi-trash" 
            size="small"
            [rounded]="true"
            severity="danger"
            [outlined]="true"
            (onClick)="onRowDelete.emit(rowData)"></p-button>
        </div>
      </td>
    </tr>
  </ng-template>
</p-table>
```

#### PageHeaderComponent

**Purpose**: Consistent page header with breadcrumbs and actions

**Inputs**:
- `title: string` - Page title
- `breadcrumbs: Breadcrumb[]` - Breadcrumb items
- `actions: HeaderAction[]` - Action buttons

**Template Structure**:
```html
<div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 mb-6">
  <div>
    <h1 class="text-2xl font-bold text-gray-900">{{ title }}</h1>
    <p-breadcrumb [model]="breadcrumbs" [home]="homeIcon"></p-breadcrumb>
  </div>
  
  <div class="flex gap-2">
    <p-button 
      *ngFor="let action of actions"
      [label]="action.label"
      [icon]="action.icon"
      [severity]="action.severity"
      size="small"
      (onClick)="action.command()"></p-button>
  </div>
</div>
```

#### ConfirmationDialogComponent

**Purpose**: Reusable confirmation dialog

**Inputs**:
- `visible: boolean` - Dialog visibility
- `header: string` - Dialog header
- `message: string` - Confirmation message
- `acceptLabel: string` - Accept button label
- `rejectLabel: string` - Reject button label
- `severity: 'info' | 'warning' | 'danger'` - Dialog severity

**Outputs**:
- `onAccept: EventEmitter<void>` - Accept event
- `onReject: EventEmitter<void>` - Reject event

**Template Structure**:
```html
<p-dialog 
  [(visible)]="visible"
  [header]="header"
  [modal]="true"
  [closable]="false"
  [style]="{width: '450px'}">
  
  <div class="flex items-start gap-4">
    <i [class]="getIcon()" [class.text-blue-500]="severity === 'info'"
       [class.text-yellow-500]="severity === 'warning'"
       [class.text-red-500]="severity === 'danger'"></i>
    <p class="text-gray-700">{{ message }}</p>
  </div>
  
  <ng-template pTemplate="footer">
    <p-button 
      [label]="rejectLabel"
      severity="secondary"
      size="small"
      [outlined]="true"
      (onClick)="onReject.emit()"></p-button>
    <p-button 
      [label]="acceptLabel"
      [severity]="severity === 'danger' ? 'danger' : 'primary'"
      size="small"
      (onClick)="onAccept.emit()"></p-button>
  </ng-template>
</p-dialog>
```

#### LoadingSpinnerComponent

**Purpose**: Global loading indicator

**Inputs**:
- `loading: boolean` - Loading state
- `overlay: boolean` - Show as overlay

**Template Structure**:
```html
<div *ngIf="loading" [class.overlay]="overlay" class="loading-container">
  <p-progressSpinner 
    styleClass="w-16 h-16"
    strokeWidth="4"
    animationDuration="1s"></p-progressSpinner>
</div>
```


### Feature Components

#### Platform Admin - AgencyListComponent

**Purpose**: Display and manage agencies

**Component Structure**:
```typescript
@Component({
  selector: 'app-agency-list',
  standalone: true,
  imports: [CommonModule, DataTableComponent, PageHeaderComponent, ButtonModule],
  templateUrl: './agency-list.component.html',
  styleUrl: './agency-list.component.scss'
})
export class AgencyListComponent implements OnInit {
  private store = inject(Store);
  private router = inject(Router);
  
  agencies$ = this.store.select(selectAllAgencies);
  loading$ = this.store.select(selectAgenciesLoading);
  
  columns: TableColumn[] = [
    { field: 'agency_code', header: 'Agency Code', sortable: true },
    { field: 'company_name', header: 'Company Name', sortable: true },
    { field: 'email', header: 'Email', sortable: true },
    { field: 'subscription_plan', header: 'Plan', sortable: true },
    { field: 'is_active', header: 'Status', sortable: true, template: this.statusTemplate }
  ];
  
  ngOnInit(): void {
    this.store.dispatch(loadAgencies());
  }
  
  onCreateAgency(): void {
    this.router.navigate(['/platform-admin/agencies/create']);
  }
  
  onToggleStatus(agency: Agency): void {
    const action = agency.is_active ? 'deactivate' : 'activate';
    // Show confirmation dialog
    this.confirmationService.confirm({
      message: `Are you sure you want to ${action} this agency?`,
      accept: () => {
        this.store.dispatch(toggleAgencyStatus({ agencyId: agency.id }));
      }
    });
  }
}
```

**Template Structure**:
```html
<app-page-header 
  title="Agencies"
  [breadcrumbs]="breadcrumbs"
  [actions]="headerActions">
</app-page-header>

<div class="card">
  <app-data-table
    [columns]="columns"
    [data]="agencies$ | async"
    [loading]="loading$ | async"
    [paginator]="true"
    [rows]="25"
    (onRowEdit)="onEditAgency($event)">
    
    <ng-template #statusTemplate let-agency>
      <p-tag 
        [value]="agency.is_active ? 'Active' : 'Inactive'"
        [severity]="agency.is_active ? 'success' : 'danger'">
      </p-tag>
      <p-inputSwitch 
        [(ngModel)]="agency.is_active"
        (onChange)="onToggleStatus(agency)">
      </p-inputSwitch>
    </ng-template>
  </app-data-table>
</div>
```

#### Platform Admin - SubscriptionPlanListComponent

**Purpose**: Display and manage subscription plans

**Component Structure**:
```typescript
@Component({
  selector: 'app-subscription-plan-list',
  standalone: true,
  imports: [CommonModule, DataTableComponent, PageHeaderComponent, ButtonModule, TagModule],
  templateUrl: './subscription-plan-list.component.html',
  styleUrl: './subscription-plan-list.component.scss'
})
export class SubscriptionPlanListComponent implements OnInit {
  private store = inject(Store);
  private router = inject(Router);
  
  plans$ = this.store.select(selectAllSubscriptionPlans);
  loading$ = this.store.select(selectSubscriptionPlansLoading);
  
  columns: TableColumn[] = [
    { field: 'plan_name', header: 'Plan Name', sortable: true },
    { field: 'monthly_price', header: 'Monthly Price', sortable: true },
    { field: 'annual_price', header: 'Annual Price', sortable: true },
    { field: 'max_users', header: 'Max Users', sortable: true },
    { field: 'max_bookings_per_month', header: 'Max Bookings/Month', sortable: true },
    { field: 'is_active', header: 'Status', sortable: true, template: this.statusTemplate }
  ];
  
  ngOnInit(): void {
    this.store.dispatch(loadSubscriptionPlans());
  }
  
  onCreatePlan(): void {
    this.router.navigate(['/platform-admin/subscription-plans/create']);
  }
  
  onToggleStatus(plan: SubscriptionPlan): void {
    const action = plan.is_active ? 'deactivate' : 'activate';
    this.confirmationService.confirm({
      message: `Are you sure you want to ${action} this subscription plan?`,
      accept: () => {
        this.store.dispatch(toggleSubscriptionPlanStatus({ planId: plan.id }));
      }
    });
  }
}
```

#### Platform Admin - CommissionConfigComponent

**Purpose**: Display and manage commission configuration

**Component Structure**:
```typescript
@Component({
  selector: 'app-commission-config',
  standalone: true,
  imports: [CommonModule, DataTableComponent, PageHeaderComponent, ButtonModule, TagModule, CardModule],
  templateUrl: './commission-config.component.html',
  styleUrl: './commission-config.component.scss'
})
export class CommissionConfigComponent implements OnInit {
  private store = inject(Store);
  
  currentConfig$ = this.store.select(selectCurrentCommissionConfig);
  history$ = this.store.select(selectCommissionHistory);
  loading$ = this.store.select(selectCommissionConfigLoading);
  
  historyColumns: TableColumn[] = [
    { field: 'commission_type', header: 'Type', sortable: true },
    { field: 'commission_rate', header: 'Rate', sortable: true },
    { field: 'effective_date', header: 'Effective Date', sortable: true },
    { field: 'end_date', header: 'End Date', sortable: true },
    { field: 'changed_by_name', header: 'Changed By', sortable: true }
  ];
  
  ngOnInit(): void {
    this.store.dispatch(loadCommissionConfig());
    this.store.dispatch(loadCommissionHistory());
  }
  
  onEditConfig(): void {
    // Open commission config form dialog
  }
}
```

#### Platform Admin - RevenueDashboardComponent

**Purpose**: Display revenue metrics and analytics

**Component Structure**:
```typescript
@Component({
  selector: 'app-revenue-dashboard',
  standalone: true,
  imports: [CommonModule, CardModule, ChartModule, DataTableComponent, DropdownModule],
  templateUrl: './revenue-dashboard.component.html',
  styleUrl: './revenue-dashboard.component.scss'
})
export class RevenueDashboardComponent implements OnInit {
  private store = inject(Store);
  
  metrics$ = this.store.select(selectRevenueMetrics);
  revenueByPlan$ = this.store.select(selectRevenueByPlan);
  topAgencies$ = this.store.select(selectTopRevenueAgencies);
  commissionTrend$ = this.store.select(selectCommissionRevenueTrend);
  loading$ = this.store.select(selectRevenueLoading);
  
  dateRangeOptions = [
    { label: 'This Month', value: 'this_month' },
    { label: 'Last Month', value: 'last_month' },
    { label: 'Last 3 Months', value: 'last_3_months' },
    { label: 'Last 6 Months', value: 'last_6_months' },
    { label: 'Last Year', value: 'last_year' },
    { label: 'Custom Range', value: 'custom' }
  ];
  
  selectedDateRange = 'this_month';
  
  revenueByPlanChartData: any;
  commissionTrendChartData: any;
  
  ngOnInit(): void {
    this.loadRevenueData();
  }
  
  loadRevenueData(): void {
    this.store.dispatch(loadRevenueMetrics({ dateRange: this.selectedDateRange }));
    this.store.dispatch(loadRevenueByPlan({ dateRange: this.selectedDateRange }));
    this.store.dispatch(loadTopRevenueAgencies({ dateRange: this.selectedDateRange }));
    this.store.dispatch(loadCommissionRevenueTrend());
  }
  
  onDateRangeChange(): void {
    this.loadRevenueData();
  }
}
```

#### Agency - BookingDetailComponent

**Purpose**: Display and manage booking details with travelers, documents, tasks, and payments

**Component Structure**:
```typescript
@Component({
  selector: 'app-booking-detail',
  standalone: true,
  imports: [
    CommonModule, 
    TabViewModule, 
    DataTableComponent, 
    ButtonModule,
    TagModule,
    ProgressBarModule
  ],
  templateUrl: './booking-detail.component.html',
  styleUrl: './booking-detail.component.scss'
})
export class BookingDetailComponent implements OnInit {
  private store = inject(Store);
  private route = inject(ActivatedRoute);
  
  booking$ = this.store.select(selectCurrentBooking);
  travelers$ = this.store.select(selectBookingTravelers);
  documents$ = this.store.select(selectBookingDocuments);
  tasks$ = this.store.select(selectBookingTasks);
  payments$ = this.store.select(selectBookingPayments);
  
  documentCompletion$ = this.store.select(selectDocumentCompletion);
  taskCompletion$ = this.store.select(selectTaskCompletion);
  
  ngOnInit(): void {
    const bookingId = this.route.snapshot.params['id'];
    this.store.dispatch(loadBookingDetail({ bookingId }));
  }
  
  onApproveBooking(): void {
    this.confirmationService.confirm({
      message: 'Are you sure you want to approve this booking?',
      accept: () => {
        const bookingId = this.route.snapshot.params['id'];
        this.store.dispatch(approveBooking({ bookingId }));
      }
    });
  }
  
  onAddTraveler(): void {
    // Open traveler form dialog
  }
  
  onUpdateDocumentStatus(document: BookingDocument): void {
    // Open document status dialog
  }
  
  onUpdateTaskStatus(task: BookingTask, status: TaskStatus): void {
    this.store.dispatch(updateTaskStatus({ 
      taskId: task.id, 
      status 
    }));
  }
  
  onRecordPayment(): void {
    // Open payment recording dialog
  }
}
```

**Template Structure**:
```html
<app-page-header 
  title="Booking Detail"
  [breadcrumbs]="breadcrumbs"
  [actions]="headerActions">
</app-page-header>

<div class="grid grid-cols-1 lg:grid-cols-3 gap-4 mb-4">
  <div class="card">
    <h3 class="text-lg font-semibold mb-2">Booking Information</h3>
    <ng-container *ngIf="booking$ | async as booking">
      <div class="space-y-2">
        <div><strong>Reference:</strong> {{ booking.booking_reference }}</div>
        <div><strong>Customer:</strong> {{ booking.customer_name }}</div>
        <div><strong>Package:</strong> {{ booking.package_name }}</div>
        <div><strong>Journey:</strong> {{ booking.journey_code }}</div>
        <div><strong>Total Pax:</strong> {{ booking.total_pax }}</div>
        <div><strong>Total Amount:</strong> {{ booking.total_amount | currency:'IDR' }}</div>
        <div>
          <strong>Status:</strong>
          <p-tag [value]="booking.booking_status" [severity]="getStatusSeverity(booking.booking_status)"></p-tag>
        </div>
      </div>
    </ng-container>
  </div>
  
  <div class="card">
    <h3 class="text-lg font-semibold mb-2">Document Progress</h3>
    <ng-container *ngIf="documentCompletion$ | async as completion">
      <p-progressBar [value]="completion"></p-progressBar>
      <p class="text-sm text-gray-600 mt-2">{{ completion }}% Complete</p>
    </ng-container>
  </div>
  
  <div class="card">
    <h3 class="text-lg font-semibold mb-2">Task Progress</h3>
    <ng-container *ngIf="taskCompletion$ | async as completion">
      <p-progressBar [value]="completion"></p-progressBar>
      <p class="text-sm text-gray-600 mt-2">{{ completion }}% Complete</p>
    </ng-container>
  </div>
</div>

<div class="card">
  <p-tabView>
    <p-tabPanel header="Travelers">
      <app-data-table
        [columns]="travelerColumns"
        [data]="travelers$ | async"
        [paginator]="false">
      </app-data-table>
      <p-button 
        label="Add Traveler" 
        icon="pi pi-plus"
        size="small"
        (onClick)="onAddTraveler()">
      </p-button>
    </p-tabPanel>
    
    <p-tabPanel header="Documents">
      <app-data-table
        [columns]="documentColumns"
        [data]="documents$ | async"
        [paginator]="false">
        
        <ng-template #statusTemplate let-document>
          <p-tag [value]="document.status" [severity]="getDocumentStatusSeverity(document.status)"></p-tag>
          <p-button 
            label="Update Status"
            size="small"
            [outlined]="true"
            (onClick)="onUpdateDocumentStatus(document)">
          </p-button>
        </ng-template>
      </app-data-table>
    </p-tabPanel>
    
    <p-tabPanel header="Tasks">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div *ngFor="let status of ['to_do', 'in_progress', 'done']" class="kanban-column">
          <h4 class="font-semibold mb-3">{{ status | titlecase }}</h4>
          <div *ngFor="let task of (tasks$ | async) | filterByStatus:status" 
               class="task-card p-3 mb-2 bg-white rounded shadow">
            <h5 class="font-medium">{{ task.title }}</h5>
            <p class="text-sm text-gray-600">{{ task.description }}</p>
            <div class="flex justify-between items-center mt-2">
              <span class="text-xs text-gray-500">Due: {{ task.due_date | date }}</span>
              <p-tag [value]="task.priority" [severity]="getPrioritySeverity(task.priority)"></p-tag>
            </div>
          </div>
        </div>
      </div>
    </p-tabPanel>
    
    <p-tabPanel header="Payments">
      <app-data-table
        [columns]="paymentColumns"
        [data]="payments$ | async"
        [paginator]="false">
      </app-data-table>
      <p-button 
        label="Record Payment" 
        icon="pi pi-plus"
        size="small"
        (onClick)="onRecordPayment()">
      </p-button>
    </p-tabPanel>
  </p-tabView>
</div>
```


## Data Models

### Core Models

#### User Model
```typescript
export interface User {
  id: string;
  email: string;
  user_type: UserType;
  full_name: string;
  phone?: string;
  agency_id?: string;
  supplier_id?: string;
  is_active: boolean;
  created_at: Date;
}

export type UserType = 'platform_admin' | 'agency_staff' | 'supplier_staff';
```

#### JWT Payload Model
```typescript
export interface JwtPayload {
  sub: string;  // user_id
  email: string;
  user_type: UserType;
  agency_id?: string;
  supplier_id?: string;
  exp: number;
  iat: number;
}
```

#### API Response Model
```typescript
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
  errors?: ValidationError[];
}

export interface ValidationError {
  field: string;
  message: string;
}
```

### Platform Admin Models

#### Agency Model
```typescript
export interface Agency {
  id: string;
  agency_code: string;
  company_name: string;
  email: string;
  phone?: string;
  address?: string;
  city?: string;
  province?: string;
  postal_code?: string;
  subscription_plan: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface CreateAgencyRequest {
  company_name: string;
  email: string;
  phone?: string;
  address?: string;
  city?: string;
  province?: string;
  postal_code?: string;
}
```

#### Supplier Model
```typescript
export interface Supplier {
  id: string;
  supplier_code: string;
  company_name: string;
  email: string;
  phone?: string;
  address?: string;
  business_type?: string;
  status: SupplierStatus;
  approved_at?: Date;
  approved_by?: string;
  created_at: Date;
  updated_at: Date;
}

export type SupplierStatus = 'pending' | 'active' | 'rejected' | 'suspended';
```

#### Subscription Plan Model
```typescript
export interface SubscriptionPlan {
  id: string;
  plan_name: string;
  description?: string;
  monthly_price: number;
  annual_price: number;
  max_users: number;
  max_bookings_per_month: number;
  features: string[];  // Array of feature codes
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export type PlanName = 'basic' | 'pro' | 'enterprise' | 'custom';

export interface AgencySubscription {
  id: string;
  agency_id: string;
  plan_id: string;
  billing_cycle: 'monthly' | 'annual';
  subscription_start_date: Date;
  subscription_end_date: Date;
  subscription_status: SubscriptionStatus;
  auto_renew: boolean;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  plan_name?: string;
  monthly_price?: number;
  annual_price?: number;
}

export type SubscriptionStatus = 'active' | 'expired' | 'trial' | 'suspended' | 'cancelled';
```

#### Commission Configuration Model
```typescript
export interface CommissionConfig {
  id: string;
  commission_type: 'percentage' | 'fixed';
  commission_rate: number;
  effective_date: Date;
  changed_by: string;
  notes?: string;
  created_at: Date;
  
  // Relations
  changed_by_name?: string;
}

export interface CommissionHistory {
  id: string;
  commission_type: 'percentage' | 'fixed';
  commission_rate: number;
  effective_date: Date;
  end_date?: Date;
  changed_by: string;
  notes?: string;
  created_at: Date;
}
```

#### Revenue Model
```typescript
export interface RevenueMetrics {
  total_subscription_revenue: number;
  total_commission_revenue: number;
  total_revenue: number;
  mrr: number;  // Monthly Recurring Revenue
  arr: number;  // Annual Recurring Revenue
}

export interface RevenueByPlan {
  plan_name: string;
  agency_count: number;
  subscription_revenue: number;
  percentage: number;
}

export interface AgencyRevenue {
  agency_id: string;
  agency_name: string;
  subscription_plan: string;
  subscription_revenue: number;
  commission_revenue: number;
  total_revenue: number;
}

export interface CommissionRevenueTrend {
  month: string;
  commission_revenue: number;
  transaction_count: number;
}
```

### Supplier Models

#### Service Model
```typescript
export interface SupplierService {
  id: string;
  supplier_id: string;
  service_code: string;
  service_type: ServiceType;
  name: string;
  description?: string;
  base_price: number;
  currency: string;
  location_city?: string;
  location_country?: string;
  
  // Type-specific fields
  hotel_name?: string;
  hotel_star_rating?: number;
  room_type?: string;
  meal_plan?: string;
  
  airline?: string;
  flight_class?: string;
  departure_airport?: string;
  arrival_airport?: string;
  
  visa_type?: string;
  processing_days?: number;
  validity_days?: number;
  entry_type?: string;
  
  vehicle_type?: string;
  vehicle_capacity?: number;
  
  guide_language?: string;
  guide_specialization?: string;
  
  status: string;
  published_at?: Date;
  created_at: Date;
  updated_at: Date;
}

export type ServiceType = 'hotel' | 'flight' | 'visa' | 'transport' | 'guide' | 'insurance' | 'catering' | 'handling';
```

#### Seasonal Price Model
```typescript
export interface SeasonalPrice {
  id: string;
  supplier_service_id: string;
  season_name?: string;
  start_date: Date;
  end_date: Date;
  seasonal_price: number;
  is_active: boolean;
  notes?: string;
  created_at: Date;
}
```

#### Purchase Order Model
```typescript
export interface PurchaseOrder {
  id: string;
  po_number: string;
  agency_id: string;
  supplier_id: string;
  status: POStatus;
  total_amount: number;
  notes?: string;
  rejection_reason?: string;
  approved_at?: Date;
  approved_by?: string;
  created_by: string;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  agency_name?: string;
  supplier_name?: string;
  items?: POItem[];
}

export type POStatus = 'pending' | 'approved' | 'rejected';

export interface POItem {
  id: string;
  po_id: string;
  service_id: string;
  service_type: ServiceType;
  quantity: number;
  unit_price: number;
  total_price: number;
  start_date?: Date;
  end_date?: Date;
  notes?: string;
  
  // Relations
  service_name?: string;
}
```

### Agency Models

#### Package Model
```typescript
export interface Package {
  id: string;
  agency_id: string;
  package_code: string;
  package_type: PackageType;
  name: string;
  description?: string;
  duration_days: number;
  base_cost: number;
  markup_type?: string;
  markup_value?: number;
  selling_price: number;
  visibility: string;
  status: string;
  published_at?: Date;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  services?: PackageService[];
  itinerary?: Itinerary;
}

export type PackageType = 'umrah' | 'hajj' | 'halal_tour' | 'general_tour' | 'custom';

export interface PackageService {
  id: string;
  package_id: string;
  supplier_service_id?: string;
  agency_service_id?: string;
  source_type: 'supplier' | 'agency';
  quantity: number;
  unit_cost: number;
  total_cost: number;
}
```

#### Journey Model
```typescript
export interface Journey {
  id: string;
  agency_id: string;
  package_id: string;
  journey_code: string;
  departure_date: Date;
  return_date: Date;
  total_quota: number;
  confirmed_pax: number;
  available_quota: number;
  status: JourneyStatus;
  notes?: string;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  package_name?: string;
}

export type JourneyStatus = 'planning' | 'confirmed' | 'in_progress' | 'completed' | 'cancelled';
```

#### Customer Model
```typescript
export interface Customer {
  id: string;
  agency_id: string;
  customer_code: string;
  name: string;
  email?: string;
  phone: string;
  address?: string;
  city?: string;
  province?: string;
  postal_code?: string;
  country: string;
  notes?: string;
  tags?: string[];
  total_bookings: number;
  total_spent: number;
  last_booking_date?: Date;
  created_at: Date;
  updated_at: Date;
}
```

#### Booking Model
```typescript
export interface Booking {
  id: string;
  agency_id: string;
  package_id: string;
  journey_id: string;
  customer_id: string;
  booking_reference: string;
  booking_status: BookingStatus;
  total_pax: number;
  total_amount: number;
  booking_source: BookingSource;
  notes?: string;
  approved_at?: Date;
  approved_by?: string;
  cancelled_at?: Date;
  cancelled_by?: string;
  cancellation_reason?: string;
  created_by: string;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  customer_name?: string;
  package_name?: string;
  journey_code?: string;
  travelers?: Traveler[];
  documents?: BookingDocument[];
  tasks?: BookingTask[];
  payments?: PaymentSchedule[];
}

export type BookingStatus = 'pending' | 'confirmed' | 'departed' | 'completed' | 'cancelled';
export type BookingSource = 'staff' | 'phone' | 'walk_in' | 'whatsapp';
```

#### Traveler Model
```typescript
export interface Traveler {
  id: string;
  booking_id: string;
  traveler_number: number;
  full_name: string;
  gender: 'male' | 'female';
  date_of_birth: Date;
  nationality: string;
  passport_number?: string;
  passport_expiry?: Date;
  mahram_traveler_number?: number;
  created_at: Date;
}
```

#### Document Model
```typescript
export interface BookingDocument {
  id: string;
  booking_id: string;
  traveler_id?: string;
  document_type_id: string;
  status: DocumentStatus;
  document_number?: string;
  issue_date?: Date;
  expiry_date?: Date;
  notes?: string;
  rejection_reason?: string;
  verified_by?: string;
  verified_at?: Date;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  document_type_name?: string;
  traveler_name?: string;
}

export type DocumentStatus = 'not_submitted' | 'submitted' | 'verified' | 'rejected' | 'expired';
```

#### Task Model
```typescript
export interface BookingTask {
  id: string;
  booking_id: string;
  task_template_id?: string;
  title: string;
  description?: string;
  status: TaskStatus;
  priority: TaskPriority;
  assigned_to?: string;
  due_date?: Date;
  completed_at?: Date;
  completed_by?: string;
  notes?: string;
  is_custom: boolean;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  assigned_to_name?: string;
}

export type TaskStatus = 'to_do' | 'in_progress' | 'done';
export type TaskPriority = 'low' | 'normal' | 'high' | 'urgent';
```

#### Payment Model
```typescript
export interface PaymentSchedule {
  id: string;
  booking_id: string;
  installment_number: number;
  installment_name: string;
  due_date: Date;
  amount: number;
  status: PaymentStatus;
  paid_amount: number;
  paid_date?: Date;
  payment_method?: string;
  notes?: string;
  created_at: Date;
  updated_at: Date;
}

export type PaymentStatus = 'pending' | 'paid' | 'overdue' | 'partially_paid';

export interface PaymentTransaction {
  id: string;
  booking_id: string;
  schedule_id?: string;
  amount: number;
  payment_method: PaymentMethod;
  payment_date: Date;
  reference_number?: string;
  notes?: string;
  recorded_by: string;
  created_at: Date;
}

export type PaymentMethod = 'bank_transfer' | 'cash' | 'credit_card' | 'e_wallet';
```

#### Itinerary Model
```typescript
export interface Itinerary {
  id: string;
  package_id: string;
  days: ItineraryDay[];
}

export interface ItineraryDay {
  id: string;
  itinerary_id: string;
  day_number: number;
  title: string;
  description?: string;
  activities: ItineraryActivity[];
}

export interface ItineraryActivity {
  id: string;
  day_id: string;
  time?: string;
  location?: string;
  activity: string;
  description?: string;
  meal_type: MealType;
}

export type MealType = 'breakfast' | 'lunch' | 'dinner' | 'snack' | 'none';
```

#### B2B Marketplace Models
```typescript
export interface AgencyService {
  id: string;
  agency_id: string;
  po_id: string;
  service_type: ServiceType;
  name: string;
  description?: string;
  specifications?: any;
  cost_price: number;
  reseller_price: number;
  markup_percentage: number;
  total_quota: number;
  used_quota: number;
  available_quota: number;
  reserved_quota: number;
  sold_quota: number;
  is_published: boolean;
  published_at?: Date;
  created_at: Date;
  updated_at: Date;
  
  // Relations (for marketplace browsing)
  seller_agency_name?: string;
}

export interface AgencyOrder {
  id: string;
  order_number: string;
  buyer_agency_id: string;
  seller_agency_id: string;
  agency_service_id: string;
  quantity: number;
  unit_price: number;
  total_price: number;
  status: AgencyOrderStatus;
  notes?: string;
  rejection_reason?: string;
  approved_at?: Date;
  created_at: Date;
  updated_at: Date;
  
  // Relations
  buyer_agency_name?: string;
  seller_agency_name?: string;
  service_name?: string;
}

export type AgencyOrderStatus = 'pending' | 'approved' | 'rejected';
```


## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: JWT Token Decoding

*For any* valid JWT token stored in localStorage, the AuthService should correctly extract user_type, agency_id, and supplier_id from the token payload.

**Validates: Requirements 2.2**

### Property 2: Role-Based Route Access

*For any* user with a specific user_type, the RoleGuard should only allow access to routes configured for that user_type and deny access to routes configured for other user_types.

**Validates: Requirements 2.4**

### Property 3: Authorization Header Attachment

*For any* HTTP request made when a user is authenticated, the AuthInterceptor should attach the JWT token in the Authorization header with Bearer scheme.

**Validates: Requirements 3.1**

### Property 4: HTTP Error Toast Notifications

*For any* HTTP error response (4xx or 5xx), the ErrorInterceptor should display a toast notification with an appropriate error message.

**Validates: Requirements 3.2**

### Property 5: Loading State Management

*For any* HTTP request, the LoadingInterceptor should set loading state to true when the request starts and set it to false when the request completes (success or error).

**Validates: Requirements 3.3**

### Property 6: Successful Operation Feedback

*For any* successful create, update, or delete operation (agency, supplier, service, booking, etc.), the Frontend should display a success toast notification.

**Validates: Requirements 8.5, 10.7, 11.5**

### Property 7: Date Range Validation

*For any* form with start_date and end_date fields, the validation should reject submissions where end_date is before start_date.

**Validates: Requirements 11.3**

### Property 8: Positive Price Validation

*For any* form with price or amount fields, the validation should reject submissions where the value is less than or equal to zero.

**Validates: Requirements 11.4**

### Property 9: Form Validation Error Display

*For any* form field with validation errors, the Frontend should display the error message below the field in red text and disable the submit button until all errors are resolved.

**Validates: Requirements 37.2, 37.6**

### Property 10: Required Field Validation

*For any* required form field that is empty or contains only whitespace, the validation should display "This field is required" message.

**Validates: Requirements 37.3**

### Property 11: Email Format Validation

*For any* email input field with invalid email format, the validation should display "Invalid email format" message.

**Validates: Requirements 37.4**

### Property 12: Phone Format Validation

*For any* phone input field with invalid phone format, the validation should display "Invalid phone format" message.

**Validates: Requirements 37.5**

### Property 13: Form Submission Error Feedback

*For any* form submission that fails due to server error, the Frontend should display an error toast notification with the error message from the server.

**Validates: Requirements 37.7**

### Property 14: Toast Notification Severity

*For any* notification, the Frontend should display it with the correct severity: success (green), error (red), warning (yellow), or info (blue).

**Validates: Requirements 39.2, 39.3, 39.4, 39.5**

### Property 15: Toast Auto-Dismissal

*For any* toast notification displayed, it should automatically dismiss after 5 seconds unless manually dismissed by the user.

**Validates: Requirements 39.6**

### Property 16: Toast Manual Dismissal

*For any* toast notification displayed, clicking the close button should immediately dismiss the notification.

**Validates: Requirements 39.7**

### Property 17: Error Logging

*For any* error that occurs in the application (HTTP errors, validation errors, runtime errors), the error details should be logged to the browser console for debugging purposes.

**Validates: Requirements 40.6**


## Error Handling

### HTTP Error Handling Strategy

The ErrorInterceptor implements centralized error handling for all HTTP requests:

**Error Code Mapping**:
- **400 Bad Request**: Display validation errors from backend response
- **401 Unauthorized**: Clear authentication state, redirect to login page
- **403 Forbidden**: Display "You do not have permission to perform this action"
- **404 Not Found**: Display "Resource not found"
- **500 Internal Server Error**: Display "An unexpected error occurred. Please try again later"
- **Network Errors**: Display "Network error. Please check your connection"

**Error Response Format**:
```typescript
interface ErrorResponse {
  message: string;
  errors?: ValidationError[];
}

interface ValidationError {
  field: string;
  message: string;
}
```

**Error Handling Flow**:
1. HTTP request fails
2. ErrorInterceptor catches error
3. Extract error message from response
4. Display toast notification with error message
5. Log error to console
6. For 401 errors: Clear auth state and redirect to login
7. Return error observable for component-level handling if needed

### Form Validation Error Handling

**Client-Side Validation**:
- Required field validation
- Email format validation
- Phone format validation
- Date range validation
- Numeric range validation
- Custom business rule validation

**Validation Error Display**:
- Display error message below form field
- Use red text color for error messages
- Disable submit button when form is invalid
- Mark invalid fields with red border
- Show all validation errors simultaneously

**Server-Side Validation**:
- Display backend validation errors in toast notification
- Map field-specific errors to form controls
- Display general errors in toast notification

### Runtime Error Handling

**Global Error Handler**:
```typescript
@Injectable()
export class GlobalErrorHandler implements ErrorHandler {
  constructor(
    private notificationService: NotificationService
  ) {}
  
  handleError(error: Error): void {
    console.error('Runtime error:', error);
    
    this.notificationService.error(
      'An unexpected error occurred. Please refresh the page.',
      'Application Error'
    );
  }
}
```

**Component Error Boundaries**:
- Wrap async operations in try-catch blocks
- Handle observable errors in error callbacks
- Display user-friendly error messages
- Log technical details to console


## Testing Strategy

### Dual Testing Approach

The frontend testing strategy combines unit testing and property-based testing for comprehensive coverage:

**Unit Tests**:
- Test specific examples and edge cases
- Test component rendering and user interactions
- Test service methods with mocked dependencies
- Test guard and interceptor behavior
- Test pipe transformations
- Test utility functions

**Property-Based Tests**:
- Test universal properties across all inputs
- Test validation rules with generated inputs
- Test state management invariants
- Test error handling across error types
- Test form validation with random inputs

### Testing Tools and Libraries

**Unit Testing**:
- **Jasmine**: Test framework for writing specs
- **Karma**: Test runner for executing tests in browsers
- **Angular Testing Utilities**: TestBed, ComponentFixture, etc.
- **@testing-library/angular**: User-centric testing utilities

**Property-Based Testing**:
- **fast-check**: Property-based testing library for TypeScript
- Minimum 100 iterations per property test
- Each property test references design document property

**Mocking and Stubbing**:
- **jasmine.createSpy**: For mocking functions
- **jasmine.createSpyObj**: For mocking services
- **HttpClientTestingModule**: For mocking HTTP requests

### Unit Testing Patterns

**Component Testing**:
```typescript
describe('AgencyListComponent', () => {
  let component: AgencyListComponent;
  let fixture: ComponentFixture<AgencyListComponent>;
  let store: MockStore;
  
  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AgencyListComponent],
      providers: [
        provideMockStore({
          initialState: {
            agencies: {
              entities: {},
              loading: false
            }
          }
        })
      ]
    }).compileComponents();
    
    fixture = TestBed.createComponent(AgencyListComponent);
    component = fixture.componentInstance;
    store = TestBed.inject(MockStore);
  });
  
  it('should display agency list', () => {
    const agencies = [
      { id: '1', agency_code: 'AG001', company_name: 'Test Agency' }
    ];
    
    store.setState({
      agencies: {
        entities: { '1': agencies[0] },
        loading: false
      }
    });
    
    fixture.detectChanges();
    
    const table = fixture.nativeElement.querySelector('p-table');
    expect(table).toBeTruthy();
  });
  
  it('should dispatch loadAgencies action on init', () => {
    spyOn(store, 'dispatch');
    component.ngOnInit();
    expect(store.dispatch).toHaveBeenCalledWith(loadAgencies());
  });
});
```

**Service Testing**:
```typescript
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
  
  it('should store token on successful login', () => {
    const credentials = { email: 'test@test.com', password: 'password' };
    const response = { token: 'jwt-token', user: { id: '1', email: 'test@test.com' } };
    
    service.login(credentials).subscribe();
    
    const req = httpMock.expectOne('/api/auth/login');
    expect(req.request.method).toBe('POST');
    req.flush(response);
    
    expect(localStorage.getItem('auth_token')).toBe('jwt-token');
  });
});
```

**Guard Testing**:
```typescript
describe('authGuard', () => {
  let authService: jasmine.SpyObj<AuthService>;
  let router: jasmine.SpyObj<Router>;
  
  beforeEach(() => {
    authService = jasmine.createSpyObj('AuthService', ['isAuthenticated']);
    router = jasmine.createSpyObj('Router', ['navigate']);
    
    TestBed.configureTestingModule({
      providers: [
        { provide: AuthService, useValue: authService },
        { provide: Router, useValue: router }
      ]
    });
  });
  
  it('should allow access when authenticated', () => {
    authService.isAuthenticated.and.returnValue(true);
    
    const result = TestBed.runInInjectionContext(() => 
      authGuard({} as ActivatedRouteSnapshot, {} as RouterStateSnapshot)
    );
    
    expect(result).toBe(true);
  });
  
  it('should redirect to login when not authenticated', () => {
    authService.isAuthenticated.and.returnValue(false);
    
    const result = TestBed.runInInjectionContext(() => 
      authGuard({} as ActivatedRouteSnapshot, { url: '/dashboard' } as RouterStateSnapshot)
    );
    
    expect(result).toBe(false);
    expect(router.navigate).toHaveBeenCalledWith(['/auth/login'], {
      queryParams: { returnUrl: '/dashboard' }
    });
  });
});
```

### Property-Based Testing Patterns

**Property Test Configuration**:
```typescript
import * as fc from 'fast-check';

describe('Property Tests', () => {
  const NUM_RUNS = 100; // Minimum iterations per property test
  
  // Feature: tour-travel-frontend-phase1, Property 7: Date Range Validation
  it('should reject date ranges where end_date is before start_date', () => {
    fc.assert(
      fc.property(
        fc.date(),
        fc.date(),
        (date1, date2) => {
          const startDate = date1 < date2 ? date1 : date2;
          const endDate = date1 < date2 ? date2 : date1;
          
          // Test with invalid range (end before start)
          const invalidForm = createFormWithDates(endDate, startDate);
          expect(invalidForm.valid).toBe(false);
          expect(invalidForm.errors).toContain('end_date_before_start_date');
          
          // Test with valid range
          const validForm = createFormWithDates(startDate, endDate);
          expect(validForm.valid).toBe(true);
        }
      ),
      { numRuns: NUM_RUNS }
    );
  });
  
  // Feature: tour-travel-frontend-phase1, Property 8: Positive Price Validation
  it('should reject non-positive prices', () => {
    fc.assert(
      fc.property(
        fc.integer({ max: 0 }),
        (price) => {
          const form = createFormWithPrice(price);
          expect(form.valid).toBe(false);
          expect(form.errors).toContain('price_must_be_positive');
        }
      ),
      { numRuns: NUM_RUNS }
    );
  });
  
  // Feature: tour-travel-frontend-phase1, Property 11: Email Format Validation
  it('should validate email format correctly', () => {
    fc.assert(
      fc.property(
        fc.emailAddress(),
        (validEmail) => {
          const form = createFormWithEmail(validEmail);
          expect(form.get('email')?.valid).toBe(true);
        }
      ),
      { numRuns: NUM_RUNS }
    );
    
    fc.assert(
      fc.property(
        fc.string().filter(s => !isValidEmail(s)),
        (invalidEmail) => {
          const form = createFormWithEmail(invalidEmail);
          expect(form.get('email')?.valid).toBe(false);
          expect(form.get('email')?.errors?.['email']).toBeTruthy();
        }
      ),
      { numRuns: NUM_RUNS }
    );
  });
  
  // Feature: tour-travel-frontend-phase1, Property 3: Authorization Header Attachment
  it('should attach Authorization header to all authenticated requests', () => {
    fc.assert(
      fc.property(
        fc.string({ minLength: 10 }), // JWT token
        fc.string(), // API endpoint
        (token, endpoint) => {
          localStorage.setItem('auth_token', token);
          
          const req = new HttpRequest('GET', endpoint);
          const next = jasmine.createSpy('next');
          
          TestBed.runInInjectionContext(() => {
            authInterceptor(req, next);
          });
          
          const modifiedReq = next.calls.mostRecent().args[0];
          expect(modifiedReq.headers.get('Authorization')).toBe(`Bearer ${token}`);
        }
      ),
      { numRuns: NUM_RUNS }
    );
  });
});
```

### Test Coverage Goals

**Minimum Coverage Targets**:
- **Statements**: 80%
- **Branches**: 75%
- **Functions**: 80%
- **Lines**: 80%

**Critical Path Coverage**:
- Authentication flow: 100%
- Authorization guards: 100%
- HTTP interceptors: 100%
- Form validation: 90%
- Error handling: 90%

### Continuous Integration

**Test Execution**:
- Run unit tests on every commit
- Run property tests on every pull request
- Generate coverage reports
- Fail build if coverage drops below threshold

**Test Commands**:
```bash
# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in headless mode (CI)
npm run test:ci

# Run property tests only
npm run test:properties
```

