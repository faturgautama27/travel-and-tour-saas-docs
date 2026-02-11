# API Endpoints - Phase 1 (MVP Demo)

**Base URL:** `https://api.tourtravel.com/v1`

**Authentication:** Bearer Token (JWT)

---

## Authentication Endpoints

```
POST   /auth/login
POST   /auth/register
POST   /auth/logout
POST   /auth/refresh-token
GET    /auth/me
```

### Example: Login
```http
POST /v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response 200:
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "full_name": "John Doe",
      "user_type": "agency_staff",
      "agency_id": "agency-uuid"
    }
  }
}
```

---

## Platform Admin Endpoints

### Agencies
```
GET    /admin/agencies
POST   /admin/agencies
GET    /admin/agencies/{id}
PUT    /admin/agencies/{id}
DELETE /admin/agencies/{id}
PATCH  /admin/agencies/{id}/status
```

### Suppliers
```
GET    /admin/suppliers
GET    /admin/suppliers/{id}
PATCH  /admin/suppliers/{id}/approve
PATCH  /admin/suppliers/{id}/reject
```

### Dashboard
```
GET    /admin/dashboard/stats
```

---

## Supplier Endpoints

### Services
```
GET    /supplier/services
POST   /supplier/services
GET    /supplier/services/{id}
PUT    /supplier/services/{id}
DELETE /supplier/services/{id}
PATCH  /supplier/services/{id}/publish
```

### Purchase Orders
```
GET    /supplier/purchase-orders
GET    /supplier/purchase-orders/{id}
PATCH  /supplier/purchase-orders/{id}/approve
PATCH  /supplier/purchase-orders/{id}/reject
```

### Dashboard
```
GET    /supplier/dashboard/stats
```

---

## Agency Endpoints

### Purchase Orders
```
GET    /purchase-orders
POST   /purchase-orders
GET    /purchase-orders/{id}
```

### Packages
```
GET    /packages
POST   /packages
GET    /packages/{id}
PUT    /packages/{id}
DELETE /packages/{id}
PATCH  /packages/{id}/publish
```

### Package Departures
```
POST   /packages/{id}/departures
PUT    /packages/{id}/departures/{departureId}
DELETE /packages/{id}/departures/{departureId}
```

### Bookings
```
GET    /bookings
POST   /bookings
GET    /bookings/{id}
PUT    /bookings/{id}
PATCH  /bookings/{id}/approve
PATCH  /bookings/{id}/reject
PATCH  /bookings/{id}/cancel

GET    /bookings/pending-approval
```

### Supplier Services (Browse)
```
GET    /supplier-services
GET    /supplier-services/{id}
```

### Dashboard
```
GET    /dashboard/stats
```

---

## Traveler Endpoints

### Browse Packages
```
GET    /traveler/packages
GET    /traveler/packages/{id}
GET    /traveler/packages/search
```

### My Bookings
```
GET    /traveler/my-bookings
POST   /traveler/my-bookings
GET    /traveler/my-bookings/{id}
```

---

## Request/Response Examples

### Create Agency (Platform Admin)
```http
POST /v1/admin/agencies
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "company_name": "Al-Hijrah Travel",
  "email": "info@alhijrah.com",
  "phone": "+62812345678",
  "subscription_plan": "pro",
  "commission_rate": 2.0
}

Response 201:
{
  "success": true,
  "data": {
    "id": "agency-uuid",
    "agency_code": "AGN-001",
    "company_name": "Al-Hijrah Travel",
    "subscription_plan": "pro",
    "is_active": true
  }
}
```

### Create Service (Supplier)
```http
POST /v1/supplier/services
Authorization: Bearer {supplier_token}
Content-Type: application/json

{
  "service_type": "hotel",
  "name": "Elaf Al Mashaer Hotel",
  "description": "5-star hotel near Haram",
  "base_price": 500000,
  "price_unit": "per_night",
  "service_details": {
    "hotel_name": "Elaf Al Mashaer",
    "star_rating": 5,
    "location": "Mecca",
    "distance_to_haram": "100m",
    "room_types": [
      {
        "type": "quad",
        "capacity": 4,
        "quantity": 80,
        "price_per_night": 500000
      }
    ],
    "amenities": ["wifi", "ac", "breakfast", "prayer_room"]
  },
  "visibility": "marketplace"
}

Response 201:
{
  "success": true,
  "data": {
    "id": "service-uuid",
    "service_code": "SVC-001",
    "name": "Elaf Al Mashaer Hotel",
    "status": "draft"
  }
}
```

### Create Package (Agency)
```http
POST /v1/packages
Authorization: Bearer {agency_token}
X-Tenant-ID: {agency_id}
Content-Type: application/json

{
  "package_type": "umrah",
  "name": "Umrah Premium March 2026",
  "description": "15 days premium Umrah package",
  "duration_days": 15,
  "duration_nights": 14,
  "services": [
    {
      "supplier_service_id": "hotel-service-uuid",
      "service_type": "hotel",
      "quantity": 10,
      "unit": "nights",
      "unit_cost": 500000,
      "total_cost": 5000000
    },
    {
      "supplier_service_id": "flight-service-uuid",
      "service_type": "flight",
      "quantity": 1,
      "unit": "pax",
      "unit_cost": 10000000,
      "total_cost": 10000000
    }
  ],
  "base_cost": 20250000,
  "markup_type": "fixed",
  "markup_amount": 4750000,
  "selling_price": 25000000,
  "departures": [
    {
      "departure_code": "MAR15",
      "departure_date": "2026-03-15",
      "return_date": "2026-03-29",
      "total_quota": 40
    }
  ],
  "visibility": "public"
}

Response 201:
{
  "success": true,
  "data": {
    "id": "package-uuid",
    "package_code": "PKG-001",
    "name": "Umrah Premium March 2026",
    "status": "draft"
  }
}
```

### Create Purchase Order (Agency)
```http
POST /v1/purchase-orders
Authorization: Bearer {agency_token}
X-Tenant-ID: {agency_id}
Content-Type: application/json

{
  "supplier_id": "supplier-uuid",
  "items": [
    {
      "supplier_service_id": "service-uuid-1",
      "quantity": 10,
      "unit_price": 500000
    },
    {
      "supplier_service_id": "service-uuid-2",
      "quantity": 2,
      "unit_price": 3000000
    }
  ]
}

Response 201:
{
  "success": true,
  "data": {
    "id": "po-uuid",
    "po_code": "PO-260211-001",
    "supplier_id": "supplier-uuid",
    "total_amount": 11000000,
    "status": "pending",
    "created_at": "2026-02-11T09:00:00Z"
  }
}
```

### Approve Purchase Order (Supplier)
```http
PATCH /v1/supplier/purchase-orders/{id}/approve
Authorization: Bearer {supplier_token}
X-Tenant-ID: {supplier_id}

Response 200:
{
  "success": true,
  "data": {
    "id": "po-uuid",
    "po_code": "PO-260211-001",
    "status": "approved",
    "approved_at": "2026-02-11T10:00:00Z"
  },
  "message": "Purchase order approved successfully"
}
```

### Reject Purchase Order (Supplier)
```http
PATCH /v1/supplier/purchase-orders/{id}/reject
Authorization: Bearer {supplier_token}
X-Tenant-ID: {supplier_id}
Content-Type: application/json

{
  "rejection_reason": "Service not available for requested dates"
}

Response 200:
{
  "success": true,
  "data": {
    "id": "po-uuid",
    "po_code": "PO-260211-001",
    "status": "rejected",
    "rejected_at": "2026-02-11T10:00:00Z",
    "rejection_reason": "Service not available for requested dates"
  },
  "message": "Purchase order rejected"
}
```

### Create Booking (Traveler)
```http
POST /v1/traveler/my-bookings
Authorization: Bearer {customer_token}
Content-Type: application/json

{
  "package_id": "package-uuid",
  "package_departure_id": "departure-uuid",
  "customer_name": "Ahmad Yani",
  "customer_email": "ahmad@email.com",
  "customer_phone": "+628123456789",
  "travelers": [
    {
      "traveler_number": 1,
      "full_name": "Ahmad Yani",
      "gender": "male",
      "date_of_birth": "1980-05-15",
      "nationality": "Indonesian",
      "passport_number": "A1234567",
      "passport_expiry_date": "2028-12-31"
    },
    {
      "traveler_number": 2,
      "full_name": "Siti Aisyah",
      "gender": "female",
      "date_of_birth": "1985-03-20",
      "nationality": "Indonesian",
      "passport_number": "A7654321",
      "passport_expiry_date": "2029-06-30",
      "requires_mahram": true,
      "mahram_traveler_number": 1,
      "mahram_relationship": "husband"
    }
  ]
}

Response 201:
{
  "success": true,
  "data": {
    "booking_reference": "BKG-260211-001",
    "booking_status": "pending",
    "total_amount": 50000000,
    "message": "Booking submitted. Waiting for agency approval."
  }
}
```

### Approve Booking (Agency)
```http
PATCH /v1/bookings/{id}/approve
Authorization: Bearer {agency_token}
X-Tenant-ID: {agency_id}

Response 200:
{
  "success": true,
  "data": {
    "id": "booking-uuid",
    "booking_reference": "BKG-260211-001",
    "booking_status": "approved",
    "approved_at": "2026-02-11T10:30:00Z"
  },
  "message": "Booking approved successfully"
}
```

---

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful",
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is required"
      }
    ]
  }
}
```

---

## HTTP Status Codes

- **200**: Success
- **201**: Created
- **400**: Bad Request (validation error)
- **401**: Unauthorized (invalid token)
- **403**: Forbidden (no permission)
- **404**: Not Found
- **409**: Conflict (duplicate)
- **500**: Internal Server Error

---

## Headers

### Required Headers
```
Authorization: Bearer {jwt_token}
Content-Type: application/json
```

### Optional Headers (for agency staff)
```
X-Tenant-ID: {agency_id}
```

---

## Pagination

For list endpoints, use query parameters:

```
GET /packages?page=1&per_page=20&sort=created_at&order=desc
```

Response includes meta:
```json
{
  "success": true,
  "data": [ ... ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

---

## Filtering & Search

### Filter by status
```
GET /bookings?status=pending
```

### Search by name
```
GET /packages?search=umrah
```

### Multiple filters
```
GET /bookings?status=pending&date_from=2026-02-01&date_to=2026-02-28
```

---

## Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Request validation failed |
| `UNAUTHORIZED` | Invalid or missing token |
| `FORBIDDEN` | No permission to access resource |
| `NOT_FOUND` | Resource not found |
| `DUPLICATE` | Resource already exists |
| `INTERNAL_ERROR` | Server error |

