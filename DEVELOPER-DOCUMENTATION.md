# Tour & Travel ERP SaaS - Developer Documentation

**Project:** Multi-Tenant Tour & Travel Agency ERP Platform  
**Phase:** Phase 1 - MVP Demo  
**Version:** 3.0 (Revised)  
**Last Updated:** February 14, 2026

---

## 📋 Table of Contents

1. [Technology Stack](#technology-stack)
2. [Architecture Overview](#architecture-overview)
3. [Database Schema](#database-schema)
4. [API Endpoints](#api-endpoints)
5. [Business Rules](#business-rules)
6. [Frontend Components](#frontend-components)
7. [Background Jobs](#background-jobs)
8. [Development Setup](#development-setup)
9. [Testing Strategy](#testing-strategy)
10. [Deployment](#deployment)

---

## Technology Stack

### Backend
- **Runtime:** .NET 8 (C# 12)
- **Web Framework:** ASP.NET Core 8
- **Database:** PostgreSQL 16
- **ORM:** Entity Framework Core 8
- **CQRS:** MediatR 12
- **Validation:** FluentValidation 11
- **Authentication:** JWT Bearer tokens
- **Password Hashing:** BCrypt.Net-Next
- **API Documentation:** Swashbuckle (Swagger/OpenAPI)
- **Logging:** Serilog
- **Background Jobs:** Hangfire
- **Testing:** xUnit, Testcontainers

### Frontend
- **Framework:** Angular 20 (Standalone Components)
- **UI Library:** PrimeNG 20
- **Styling:** TailwindCSS 4
- **State Management:** NgRx 18
- **Icons:** Lucide Angular
- **HTTP:** Angular HttpClient
- **Reactive:** RxJS 7
- **Forms:** Angular Reactive Forms
- **Routing:** Angular Router (Lazy Loading)

### Infrastructure
- **Containerization:** Docker, Docker Compose
- **Database:** PostgreSQL 16 with Row-Level Security (RLS)
- **Reverse Proxy:** Nginx (production)

---

## Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                      API Layer                          │
│  Controllers, Middleware, Filters, Startup             │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                  Application Layer                      │
│  CQRS Commands/Queries, DTOs, Validators, Interfaces   │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   Domain Layer                          │
│  Entities, Value Objects, Domain Interfaces            │
└─────────────────────────────────────────────────────────┘
                          ↑
┌─────────────────────────────────────────────────────────┐
│                Infrastructure Layer                     │
│  EF Core, Repositories, External Services, Jobs        │
└─────────────────────────────────────────────────────────┘
```

### Multi-Tenancy Strategy

**Row-Level Security (RLS) in PostgreSQL:**
- Each agency is a tenant with unique `tenant_id`
- RLS policies automatically filter data per tenant
- Session variable `app.current_tenant_id` set on each request
- Complete data isolation between agencies

---

## Database Schema

### Core Tables (Foundation)

#### users
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(50) NOT NULL, -- platform_admin, agency_staff, supplier_staff
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    agency_id UUID REFERENCES agencies(id),
    supplier_id UUID REFERENCES suppliers(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_agency_id ON users(agency_id);
CREATE INDEX idx_users_supplier_id ON users(supplier_id);
```

#### agencies
```sql
CREATE TABLE agencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_code VARCHAR(50) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    subscription_plan VARCHAR(50) DEFAULT 'basic',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_agencies_code ON agencies(agency_code);
CREATE INDEX idx_agencies_active ON agencies(is_active);
```

#### suppliers
```sql
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_code VARCHAR(50) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    business_type VARCHAR(100),
    status VARCHAR(50) DEFAULT 'pending', -- pending, active, rejected, suspended
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_suppliers_code ON suppliers(supplier_code);
CREATE INDEX idx_suppliers_status ON suppliers(status);
```

### Supplier Services (Modified - Specific Fields)

#### supplier_services
```sql
CREATE TABLE supplier_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    service_code VARCHAR(50) UNIQUE NOT NULL,
    service_type VARCHAR(50) NOT NULL, -- hotel, flight, visa, transport, guide, insurance, catering, handling
    name VARCHAR(255) NOT NULL,
    description TEXT,
    base_price DECIMAL(15,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'IDR',
    
    -- Location (common for all)
    location_city VARCHAR(100),
    location_country VARCHAR(100),
    
    -- Flight Specific
    airline VARCHAR(100),
    flight_class VARCHAR(50), -- Economy, Business, First
    departure_airport VARCHAR(10),
    arrival_airport VARCHAR(10),
    departure_time TIME,
    arrival_time TIME,
    baggage_allowance VARCHAR(50),
    
    -- Hotel Specific
    hotel_name VARCHAR(255),
    hotel_star_rating INTEGER,
    room_type VARCHAR(100),
    bed_configuration VARCHAR(100),
    max_occupancy INTEGER,
    meal_plan VARCHAR(50), -- Room Only, Breakfast, Half Board, Full Board
    check_in_time TIME,
    check_out_time TIME,
    distance_to_haram DECIMAL(10,2), -- for Makkah/Madinah hotels
    
    -- Visa Specific
    visa_type VARCHAR(100), -- Tourist, Business, Umrah, Hajj
    processing_days INTEGER,
    validity_days INTEGER,
    entry_type VARCHAR(50), -- Single, Multiple
    required_documents TEXT,
    
    -- Transport Specific
    vehicle_type VARCHAR(100), -- Bus, Van, Car
    vehicle_capacity INTEGER,
    vehicle_features TEXT,
    driver_included BOOLEAN,
    fuel_included BOOLEAN,
    
    -- Guide Specific
    guide_language JSONB, -- ["English", "Arabic", "Indonesian"]
    guide_specialization VARCHAR(255),
    guide_certification VARCHAR(255),
    years_of_experience INTEGER,
    
    -- Insurance Specific
    insurance_type VARCHAR(100),
    coverage_amount DECIMAL(15,2),
    coverage_details TEXT,
    age_limit_min INTEGER,
    age_limit_max INTEGER,
    
    -- Catering Specific
    meal_type VARCHAR(50),
    cuisine_type VARCHAR(100),
    serving_style VARCHAR(50),
    pax_capacity INTEGER,
    halal_certified BOOLEAN,
    
    -- Handling Specific
    handling_type VARCHAR(100),
    service_location VARCHAR(255),
    service_duration_hours DECIMAL(5,2),
    
    -- Additional info (non-critical)
    service_details JSONB, -- photos, amenities, etc
    
    visibility VARCHAR(50) DEFAULT 'marketplace',
    status VARCHAR(50) DEFAULT 'draft',
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_supplier_services_supplier ON supplier_services(supplier_id);
CREATE INDEX idx_supplier_services_type ON supplier_services(service_type);
CREATE INDEX idx_supplier_services_status ON supplier_services(status);
CREATE INDEX idx_supplier_services_airline ON supplier_services(airline);
CREATE INDEX idx_supplier_services_hotel_name ON supplier_services(hotel_name);
CREATE INDEX idx_supplier_services_visa_type ON supplier_services(visa_type);
```

#### supplier_service_seasonal_prices
```sql
CREATE TABLE supplier_service_seasonal_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    supplier_service_id UUID NOT NULL REFERENCES supplier_services(id) ON DELETE CASCADE,
    season_name VARCHAR(100), -- "Christmas Holiday", "Ramadan", "High Season"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    seasonal_price DECIMAL(15,2) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    
    CONSTRAINT valid_date_range CHECK (end_date >= start_date),
    CONSTRAINT valid_price CHECK (seasonal_price > 0)
);

CREATE INDEX idx_seasonal_prices_service ON supplier_service_seasonal_prices(supplier_service_id);
CREATE INDEX idx_seasonal_prices_dates ON supplier_service_seasonal_prices(start_date, end_date);

-- Function to get price for specific date
CREATE OR REPLACE FUNCTION get_service_price_for_date(
    p_service_id UUID,
    p_date DATE
) RETURNS DECIMAL(15,2) AS $$
DECLARE
    v_seasonal_price DECIMAL(15,2);
    v_base_price DECIMAL(15,2);
BEGIN
    -- Check for seasonal price
    SELECT seasonal_price INTO v_seasonal_price
    FROM supplier_service_seasonal_prices
    WHERE supplier_service_id = p_service_id
      AND p_date BETWEEN start_date AND end_date
      AND is_active = true
    LIMIT 1;
    
    -- If seasonal price found, return it
    IF v_seasonal_price IS NOT NULL THEN
        RETURN v_seasonal_price;
    END IF;
    
    -- Otherwise return base price
    SELECT base_price INTO v_base_price
    FROM supplier_services
    WHERE id = p_service_id;
    
    RETURN v_base_price;
END;
$$ LANGUAGE plpgsql;
```

### Purchase Order Tables

#### purchase_orders
```sql
CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number VARCHAR(50) UNIQUE NOT NULL,
    agency_id UUID NOT NULL REFERENCES agencies(id),
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    status VARCHAR(50) DEFAULT 'pending',
    total_amount DECIMAL(15,2),
    notes TEXT,
    rejection_reason TEXT,
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    rejected_at TIMESTAMP,
    rejected_by UUID REFERENCES users(id),
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_po_agency ON purchase_orders(agency_id);
CREATE INDEX idx_po_supplier ON purchase_orders(supplier_id);
CREATE INDEX idx_po_status ON purchase_orders(status);

-- RLS Policy
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_po_policy ON purchase_orders
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

#### po_items
```sql
CREATE TABLE po_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES supplier_services(id),
    service_type VARCHAR(50) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    start_date DATE,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_po_items_po ON po_items(po_id);
CREATE INDEX idx_po_items_service ON po_items(service_id);
```

### Package & Journey Tables

#### packages (Template - NO dates)
```sql
CREATE TABLE packages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    package_code VARCHAR(50) UNIQUE NOT NULL,
    package_type VARCHAR(50) NOT NULL, -- umrah, hajj, halal_tour, general_tour, custom
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration_days INTEGER NOT NULL,
    base_cost DECIMAL(15,2) NOT NULL,
    markup_type VARCHAR(50),
    markup_value DECIMAL(15,2),
    selling_price DECIMAL(15,2) NOT NULL,
    visibility VARCHAR(50) DEFAULT 'public',
    status VARCHAR(50) DEFAULT 'draft',
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_packages_agency ON packages(agency_id);
CREATE INDEX idx_packages_type ON packages(package_type);

-- RLS Policy
ALTER TABLE packages ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_packages_policy ON packages
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

#### package_services
```sql
CREATE TABLE package_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id UUID NOT NULL REFERENCES packages(id) ON DELETE CASCADE,
    supplier_service_id UUID REFERENCES supplier_services(id),
    agency_service_id UUID REFERENCES agency_services(id),
    source_type VARCHAR(50) NOT NULL, -- supplier, agency
    quantity INTEGER NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_package_services_package ON package_services(package_id);
```

#### journeys (Actual trips with dates)
```sql
CREATE TABLE journeys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    package_id UUID NOT NULL REFERENCES packages(id),
    journey_code VARCHAR(50) UNIQUE NOT NULL,
    departure_date DATE NOT NULL,
    return_date DATE NOT NULL,
    total_quota INTEGER NOT NULL,
    confirmed_pax INTEGER DEFAULT 0,
    available_quota INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'planning', -- planning, confirmed, in_progress, completed, cancelled
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_journeys_agency ON journeys(agency_id);
CREATE INDEX idx_journeys_package ON journeys(package_id);
CREATE INDEX idx_journeys_departure_date ON journeys(departure_date);

-- RLS Policy
ALTER TABLE journeys ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_journeys_policy ON journeys
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

#### journey_services (Service tracking per journey)
```sql
CREATE TABLE journey_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journey_id UUID NOT NULL REFERENCES journeys(id) ON DELETE CASCADE,
    service_type VARCHAR(50) NOT NULL,
    supplier_service_id UUID REFERENCES supplier_services(id),
    agency_service_id UUID REFERENCES agency_services(id),
    source_type VARCHAR(50) NOT NULL, -- supplier, agency
    
    -- Tracking
    booking_status VARCHAR(50) DEFAULT 'not_booked', -- not_booked, booked, confirmed, cancelled
    execution_status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, failed
    payment_status VARCHAR(50) DEFAULT 'unpaid', -- unpaid, partially_paid, paid
    
    -- Details
    booked_at TIMESTAMP,
    confirmed_at TIMESTAMP,
    executed_at TIMESTAMP,
    issue_notes TEXT,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_journey_services_journey ON journey_services(journey_id);
```

### Customer & Booking Tables

#### customers
```sql
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Indonesia',
    notes TEXT,
    tags JSONB, -- ["VIP", "Regular", "First-time", "Repeat"]
    total_bookings INTEGER DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0,
    last_booking_date DATE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_customers_agency ON customers(agency_id);
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_phone ON customers(phone);

-- RLS Policy
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_customers_policy ON customers
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

#### bookings
```sql
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    package_id UUID NOT NULL REFERENCES packages(id),
    journey_id UUID NOT NULL REFERENCES journeys(id),
    customer_id UUID NOT NULL REFERENCES customers(id),
    booking_reference VARCHAR(50) UNIQUE NOT NULL,
    booking_status VARCHAR(50) DEFAULT 'pending',
    total_pax INTEGER NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    booking_source VARCHAR(50) DEFAULT 'staff', -- staff, phone, walk_in, whatsapp
    notes TEXT,
    approved_at TIMESTAMP,
    approved_by UUID REFERENCES users(id),
    cancelled_at TIMESTAMP,
    cancelled_by UUID REFERENCES users(id),
    cancellation_reason TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_bookings_agency ON bookings(agency_id);
CREATE INDEX idx_bookings_journey ON bookings(journey_id);
CREATE INDEX idx_bookings_customer ON bookings(customer_id);
CREATE INDEX idx_bookings_status ON bookings(booking_status);

-- RLS Policy
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_bookings_policy ON bookings
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

#### travelers
```sql
CREATE TABLE travelers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    traveler_number INTEGER NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    date_of_birth DATE NOT NULL,
    nationality VARCHAR(100) DEFAULT 'Indonesia',
    passport_number VARCHAR(50),
    passport_expiry DATE,
    mahram_traveler_number INTEGER,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_travelers_booking ON travelers(booking_id);
CREATE UNIQUE INDEX idx_travelers_booking_number ON travelers(booking_id, traveler_number);
```

---

**NOTE:** This is Part 1 of Developer Documentation. Due to length, I'll continue with remaining sections (Document Management, Task Management, Notifications, Payments, Itinerary, B2B Marketplace, API Endpoints, Business Rules, Frontend Components, Background Jobs, Development Setup, Testing, Deployment) in the next parts.

**Shall I continue with the remaining sections?**


### Document Management Tables

#### document_types
```sql
CREATE TABLE document_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    required_for_package_types JSONB, -- ["umrah", "hajj", "halal_tour"]
    description TEXT,
    expiry_tracking_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Seed data
INSERT INTO document_types (name, required_for_package_types, description, expiry_tracking_enabled) VALUES
('passport', '["umrah", "hajj", "halal_tour", "general_tour"]', 'Passport for international travel', true),
('visa', '["umrah", "hajj"]', 'Visa for Saudi Arabia', true),
('ktp', '["umrah", "hajj", "halal_tour", "general_tour"]', 'Indonesian ID Card', false),
('kartu_keluarga', '["umrah", "hajj"]', 'Family Card', false),
('akta_kelahiran', '["umrah", "hajj"]', 'Birth Certificate for children', false),
('vaccination_certificate', '["umrah", "hajj"]', 'Meningitis vaccination', true),
('surat_nikah', '["umrah", "hajj"]', 'Marriage certificate', false),
('surat_mahram', '["umrah", "hajj"]', 'Mahram letter for female travelers', false);
```

#### booking_documents
```sql
CREATE TABLE booking_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    traveler_id UUID REFERENCES travelers(id),
    document_type_id UUID NOT NULL REFERENCES document_types(id),
    status VARCHAR(50) DEFAULT 'not_submitted', -- not_submitted, submitted, verified, rejected, expired
    document_number VARCHAR(100),
    issue_date DATE,
    expiry_date DATE,
    notes TEXT,
    rejection_reason TEXT,
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_booking_documents_booking ON booking_documents(booking_id);
CREATE INDEX idx_booking_documents_traveler ON booking_documents(traveler_id);
CREATE INDEX idx_booking_documents_status ON booking_documents(status);
```

### Task Management Tables

#### task_templates
```sql
CREATE TABLE task_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID REFERENCES agencies(id), -- NULL for system templates
    name VARCHAR(255) NOT NULL,
    description TEXT,
    trigger_stage VARCHAR(50) NOT NULL, -- after_booking, h_30, h_7
    due_days_offset INTEGER, -- Days offset from trigger
    assignee_role VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### booking_tasks
```sql
CREATE TABLE booking_tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    task_template_id UUID REFERENCES task_templates(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'to_do', -- to_do, in_progress, done
    priority VARCHAR(50) DEFAULT 'normal', -- low, normal, high, urgent
    assigned_to UUID REFERENCES users(id),
    due_date DATE,
    completed_at TIMESTAMP,
    completed_by UUID REFERENCES users(id),
    notes TEXT,
    is_custom BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_booking_tasks_booking ON booking_tasks(booking_id);
CREATE INDEX idx_booking_tasks_status ON booking_tasks(status);
CREATE INDEX idx_booking_tasks_assigned ON booking_tasks(assigned_to);
CREATE INDEX idx_booking_tasks_due_date ON booking_tasks(due_date);
```

### Notification Tables

#### notification_schedules
```sql
CREATE TABLE notification_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    name VARCHAR(255) NOT NULL,
    trigger_days_before INTEGER NOT NULL, -- 30, 14, 7, 3, 1
    notification_type VARCHAR(50) DEFAULT 'email',
    template_id UUID REFERENCES notification_templates(id),
    is_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notification_schedules_agency ON notification_schedules(agency_id);

-- RLS Policy
ALTER TABLE notification_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_notification_schedules_policy ON notification_schedules
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

#### notification_templates
```sql
CREATE TABLE notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID REFERENCES agencies(id), -- NULL for system templates
    name VARCHAR(255) NOT NULL,
    subject VARCHAR(255),
    body TEXT NOT NULL,
    variables JSONB, -- {"customer_name": "string", "package_name": "string"}
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### notification_logs
```sql
CREATE TABLE notification_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    schedule_id UUID REFERENCES notification_schedules(id),
    recipient_email VARCHAR(255),
    recipient_phone VARCHAR(50),
    notification_type VARCHAR(50) NOT NULL,
    subject VARCHAR(255),
    body TEXT,
    status VARCHAR(50) DEFAULT 'pending', -- pending, sent, failed
    sent_at TIMESTAMP,
    opened_at TIMESTAMP,
    error_message TEXT,
    retry_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notification_logs_booking ON notification_logs(booking_id);
CREATE INDEX idx_notification_logs_status ON notification_logs(status);
CREATE INDEX idx_notification_logs_sent_at ON notification_logs(sent_at);
```

### Payment Tracking Tables

#### payment_schedules
```sql
CREATE TABLE payment_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    installment_number INTEGER NOT NULL,
    installment_name VARCHAR(100), -- "DP", "Installment 1", "Final Payment"
    due_date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending', -- pending, paid, overdue, partially_paid
    paid_amount DECIMAL(15,2) DEFAULT 0,
    paid_date DATE,
    payment_method VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_payment_schedules_booking ON payment_schedules(booking_id);
CREATE INDEX idx_payment_schedules_status ON payment_schedules(status);
CREATE INDEX idx_payment_schedules_due_date ON payment_schedules(due_date);
CREATE UNIQUE INDEX idx_payment_schedules_booking_installment ON payment_schedules(booking_id, installment_number);
```

#### payment_transactions
```sql
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES bookings(id),
    schedule_id UUID REFERENCES payment_schedules(id),
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL, -- bank_transfer, cash, credit_card, e_wallet
    payment_date DATE NOT NULL,
    reference_number VARCHAR(100),
    notes TEXT,
    recorded_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_payment_transactions_booking ON payment_transactions(booking_id);
CREATE INDEX idx_payment_transactions_schedule ON payment_transactions(schedule_id);
CREATE INDEX idx_payment_transactions_date ON payment_transactions(payment_date);
```

### Itinerary Tables

#### itineraries
```sql
CREATE TABLE itineraries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id UUID NOT NULL REFERENCES packages(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(package_id) -- One itinerary per package
);

CREATE INDEX idx_itineraries_package ON itineraries(package_id);
```

#### itinerary_days
```sql
CREATE TABLE itinerary_days (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    itinerary_id UUID NOT NULL REFERENCES itineraries(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_itinerary_days_itinerary ON itinerary_days(itinerary_id);
CREATE UNIQUE INDEX idx_itinerary_days_itinerary_day ON itinerary_days(itinerary_id, day_number);
```

#### itinerary_activities
```sql
CREATE TABLE itinerary_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    day_id UUID NOT NULL REFERENCES itinerary_days(id) ON DELETE CASCADE,
    time TIME,
    location VARCHAR(255),
    activity VARCHAR(255) NOT NULL,
    description TEXT,
    meal_type VARCHAR(50), -- breakfast, lunch, dinner, snack, none
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_itinerary_activities_day ON itinerary_activities(day_id);
```

### Supplier Bills & Payables Tables

#### supplier_bills
```sql
CREATE TABLE supplier_bills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    po_id UUID NOT NULL REFERENCES purchase_orders(id),
    bill_number VARCHAR(50) UNIQUE NOT NULL,
    bill_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    paid_amount DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'unpaid', -- unpaid, partially_paid, paid, overdue
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_supplier_bills_agency ON supplier_bills(agency_id);
CREATE INDEX idx_supplier_bills_supplier ON supplier_bills(supplier_id);
CREATE INDEX idx_supplier_bills_po ON supplier_bills(po_id);
CREATE INDEX idx_supplier_bills_status ON supplier_bills(status);

-- RLS Policy
ALTER TABLE supplier_bills ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_supplier_bills_policy ON supplier_bills
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

#### supplier_payments
```sql
CREATE TABLE supplier_payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bill_id UUID NOT NULL REFERENCES supplier_bills(id),
    payment_date DATE NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    reference_number VARCHAR(100),
    notes TEXT,
    recorded_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_supplier_payments_bill ON supplier_payments(bill_id);
CREATE INDEX idx_supplier_payments_date ON supplier_payments(payment_date);
```

### Communication Log Tables

#### communication_logs
```sql
CREATE TABLE communication_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id),
    customer_id UUID NOT NULL REFERENCES customers(id),
    booking_id UUID REFERENCES bookings(id),
    communication_type VARCHAR(50) NOT NULL, -- call, email, whatsapp, meeting, other
    subject VARCHAR(255),
    notes TEXT NOT NULL,
    follow_up_required BOOLEAN DEFAULT false,
    follow_up_date DATE,
    follow_up_done BOOLEAN DEFAULT false,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_communication_logs_agency ON communication_logs(agency_id);
CREATE INDEX idx_communication_logs_customer ON communication_logs(customer_id);
CREATE INDEX idx_communication_logs_booking ON communication_logs(booking_id);
CREATE INDEX idx_communication_logs_follow_up ON communication_logs(follow_up_required, follow_up_done);

-- RLS Policy
ALTER TABLE communication_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_communication_logs_policy ON communication_logs
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);
```

### B2B Marketplace Tables

#### agency_services
```sql
CREATE TABLE agency_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agency_id UUID NOT NULL REFERENCES agencies(id), -- Seller agency (Agency A)
    po_id UUID NOT NULL REFERENCES purchase_orders(id),
    service_type VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    specifications JSONB,
    
    -- Pricing (cost_price HIDDEN from buyers)
    cost_price DECIMAL(15,2) NOT NULL,
    reseller_price DECIMAL(15,2) NOT NULL,
    markup_percentage DECIMAL(5,2),
    
    -- Inventory
    total_quota INTEGER NOT NULL,
    used_quota INTEGER DEFAULT 0,
    available_quota INTEGER NOT NULL,
    reserved_quota INTEGER DEFAULT 0,
    sold_quota INTEGER DEFAULT 0,
    
    -- Visibility
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_agency_services_agency ON agency_services(agency_id);
CREATE INDEX idx_agency_services_po ON agency_services(po_id);
CREATE INDEX idx_agency_services_type ON agency_services(service_type);
CREATE INDEX idx_agency_services_published ON agency_services(is_published);

-- RLS Policy
ALTER TABLE agency_services ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_services_owner_policy ON agency_services
    FOR ALL
    USING (agency_id = current_setting('app.current_agency_id')::UUID);

CREATE POLICY agency_services_marketplace_policy ON agency_services
    FOR SELECT
    USING (is_published = true AND agency_id != current_setting('app.current_agency_id')::UUID);
```

#### agency_orders
```sql
CREATE TABLE agency_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) UNIQUE NOT NULL, -- AO-YYMMDD-XXX
    
    -- Parties
    buyer_agency_id UUID NOT NULL REFERENCES agencies(id),
    seller_agency_id UUID NOT NULL REFERENCES agencies(id),
    
    -- Order details
    agency_service_id UUID NOT NULL REFERENCES agency_services(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    
    -- Status
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    notes TEXT,
    
    -- Approval
    approved_by UUID REFERENCES users(id),
    approved_at TIMESTAMP,
    rejection_reason TEXT,
    rejected_by UUID REFERENCES users(id),
    rejected_at TIMESTAMP,
    
    -- Metadata
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_agency_orders_buyer ON agency_orders(buyer_agency_id);
CREATE INDEX idx_agency_orders_seller ON agency_orders(seller_agency_id);
CREATE INDEX idx_agency_orders_service ON agency_orders(agency_service_id);
CREATE INDEX idx_agency_orders_status ON agency_orders(status);
CREATE INDEX idx_agency_orders_number ON agency_orders(order_number);

-- RLS Policy
ALTER TABLE agency_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY agency_orders_buyer_policy ON agency_orders
    FOR ALL
    USING (buyer_agency_id = current_setting('app.current_agency_id')::UUID);

CREATE POLICY agency_orders_seller_policy ON agency_orders
    FOR ALL
    USING (seller_agency_id = current_setting('app.current_agency_id')::UUID);
```

---

## API Endpoints

### Authentication Endpoints
```
POST   /api/auth/login
POST   /api/auth/register
POST   /api/auth/refresh-token
POST   /api/auth/logout
GET    /api/auth/me
```

### Platform Admin Endpoints

#### Agencies
```
GET    /api/admin/agencies
POST   /api/admin/agencies
GET    /api/admin/agencies/{id}
PUT    /api/admin/agencies/{id}
PATCH  /api/admin/agencies/{id}/status
DELETE /api/admin/agencies/{id}
```

#### Suppliers
```
GET    /api/admin/suppliers
GET    /api/admin/suppliers/{id}
PATCH  /api/admin/suppliers/{id}/approve
PATCH  /api/admin/suppliers/{id}/reject
```

#### Dashboard
```
GET    /api/admin/dashboard
GET    /api/admin/marketplace/services
GET    /api/admin/marketplace/orders
GET    /api/admin/marketplace/stats
```

### Supplier Endpoints

#### Services
```
GET    /api/supplier/services
POST   /api/supplier/services
GET    /api/supplier/services/{id}
PUT    /api/supplier/services/{id}
PATCH  /api/supplier/services/{id}/publish
PATCH  /api/supplier/services/{id}/unpublish
DELETE /api/supplier/services/{id}
```

#### Seasonal Pricing
```
GET    /api/supplier/services/{id}/seasonal-prices
POST   /api/supplier/services/{id}/seasonal-prices
PUT    /api/supplier/seasonal-prices/{id}
DELETE /api/supplier/seasonal-prices/{id}
```

#### Purchase Orders
```
GET    /api/supplier/purchase-orders
GET    /api/supplier/purchase-orders/{id}
PATCH  /api/supplier/purchase-orders/{id}/approve
PATCH  /api/supplier/purchase-orders/{id}/reject
```

#### Dashboard
```
GET    /api/supplier/dashboard
```

### Agency Endpoints

#### Services & Purchase Orders
```
GET    /api/services (browse supplier services)
GET    /api/services/{id}
GET    /api/services/{id}/price?date=YYYY-MM-DD (get price for specific date)

POST   /api/purchase-orders
GET    /api/purchase-orders
GET    /api/purchase-orders/{id}
DELETE /api/purchase-orders/{id}
```

#### Packages & Journeys
```
GET    /api/packages
POST   /api/packages
GET    /api/packages/{id}
PUT    /api/packages/{id}
PATCH  /api/packages/{id}/publish
DELETE /api/packages/{id}

POST   /api/journeys
GET    /api/journeys
GET    /api/journeys/{id}
PUT    /api/journeys/{id}
DELETE /api/journeys/{id}
GET    /api/journeys/{id}/services
PATCH  /api/journeys/{id}/services/{serviceId}/status
```

#### Customers
```
GET    /api/customers
POST   /api/customers
GET    /api/customers/{id}
PUT    /api/customers/{id}
DELETE /api/customers/{id}
POST   /api/customers/{id}/notes
POST   /api/customers/{id}/tags
DELETE /api/customers/{id}/tags/{tagId}
GET    /api/customers/{id}/bookings
GET    /api/customers/export
```

#### Bookings
```
GET    /api/bookings
POST   /api/bookings
GET    /api/bookings/{id}
PUT    /api/bookings/{id}
PATCH  /api/bookings/{id}/approve
PATCH  /api/bookings/{id}/reject
PATCH  /api/bookings/{id}/cancel
DELETE /api/bookings/{id}

POST   /api/bookings/{id}/travelers
PUT    /api/bookings/{id}/travelers/{travelerId}
DELETE /api/bookings/{id}/travelers/{travelerId}
```

#### Documents
```
GET    /api/bookings/{id}/documents
PATCH  /api/documents/{id}/status
PUT    /api/documents/{id}
GET    /api/documents/incomplete
GET    /api/documents/expiring
POST   /api/documents/{id}/send-reminder
```

#### Tasks
```
GET    /api/tasks
GET    /api/tasks/my-tasks
GET    /api/tasks/overdue
GET    /api/bookings/{id}/tasks
POST   /api/bookings/{id}/tasks
PATCH  /api/tasks/{id}/status
PATCH  /api/tasks/{id}/assign
PUT    /api/tasks/{id}
DELETE /api/tasks/{id}
```

#### Notifications
```
GET    /api/notification-schedules
POST   /api/notification-schedules
PUT    /api/notification-schedules/{id}
DELETE /api/notification-schedules/{id}

GET    /api/notification-templates
POST   /api/notification-templates
PUT    /api/notification-templates/{id}

GET    /api/bookings/{id}/notifications
POST   /api/bookings/{id}/notifications/send
GET    /api/notifications/dashboard
```

#### Payments
```
GET    /api/bookings/{id}/payments
POST   /api/bookings/{id}/payments
POST   /api/bookings/{id}/payments/{scheduleId}/record
GET    /api/payments/outstanding
GET    /api/payments/overdue
POST   /api/payments/{id}/send-reminder
GET    /api/payments/dashboard
GET    /api/payments/export
```

#### Itineraries
```
GET    /api/packages/{id}/itinerary
POST   /api/packages/{id}/itinerary
PUT    /api/itineraries/{id}
POST   /api/itineraries/{id}/days
PUT    /api/itineraries/days/{id}
DELETE /api/itineraries/days/{id}
POST   /api/itineraries/days/{id}/activities
PUT    /api/itineraries/activities/{id}
DELETE /api/itineraries/activities/{id}
GET    /api/itinerary-templates
POST   /api/itineraries/{id}/apply-template
GET    /api/itineraries/{id}/pdf
GET    /api/itineraries/{id}/share
```

#### Supplier Bills & Payables
```
GET    /api/supplier-bills
POST   /api/supplier-bills
GET    /api/supplier-bills/{id}
PUT    /api/supplier-bills/{id}
POST   /api/supplier-bills/{id}/payments
GET    /api/supplier-bills/outstanding
GET    /api/supplier-bills/overdue
GET    /api/supplier-bills/dashboard
```

#### Communication Log
```
GET    /api/communication-logs
POST   /api/communication-logs
GET    /api/communication-logs/{id}
PUT    /api/communication-logs/{id}
DELETE /api/communication-logs/{id}
GET    /api/customers/{id}/communications
GET    /api/bookings/{id}/communications
GET    /api/communication-logs/follow-ups
```

#### B2B Marketplace - Seller (Agency A)
```
POST   /api/agency-services (publish to marketplace)
GET    /api/agency-services (my published services)
GET    /api/agency-services/{id}
PUT    /api/agency-services/{id}
PATCH  /api/agency-services/{id}/publish
PATCH  /api/agency-services/{id}/unpublish
DELETE /api/agency-services/{id}

GET    /api/agency-orders/incoming
PATCH  /api/agency-orders/{id}/approve
PATCH  /api/agency-orders/{id}/reject
GET    /api/agency-services/sales-report
```

#### B2B Marketplace - Buyer (Agency B)
```
GET    /api/marketplace/services (browse marketplace)
GET    /api/marketplace/services/{id}

POST   /api/agency-orders (create order to Agency A)
GET    /api/agency-orders/outgoing
GET    /api/agency-orders/{id}
PATCH  /api/agency-orders/{id}/cancel
GET    /api/agency-orders/purchase-history
```

#### Profitability
```
GET    /api/reports/profitability/{bookingId}
GET    /api/reports/profitability/dashboard
GET    /api/reports/profitability/export
```

#### Dashboard & Reports
```
GET    /api/dashboard
```

### System Endpoints
```
GET    /health
GET    /swagger
```

### Background Job Endpoints (Admin Only)
```
POST   /api/jobs/notifications/daily
POST   /api/jobs/notifications/retry
POST   /api/jobs/tasks/generate-h30
POST   /api/jobs/tasks/generate-h7
POST   /api/jobs/orders/auto-reject
POST   /api/jobs/services/auto-unpublish
```

---

## Business Rules

### Authentication & Authorization
1. JWT token expires after 24 hours
2. Refresh token expires after 7 days
3. Password must be at least 8 characters
4. Password hashed using BCrypt with salt rounds = 12
5. Failed login attempts locked after 5 attempts (15 minutes)

### Multi-Tenancy
1. Each agency is completely isolated (RLS)
2. Platform admin can view all agencies' data
3. Supplier can only view their own data
4. Agency staff can only view their agency's data

### Supplier Services
1. Service code format: SVC-{SUPPLIER_CODE}-{SEQUENCE}
2. Base price must be > 0
3. Service must be published to be visible to agencies
4. Service cannot be deleted if used in any package
5. Seasonal price overrides base price for specific date ranges
6. If multiple seasonal prices overlap, use the most recent one

### Purchase Orders
1. PO number format: PO-YYMMDD-XXX
2. PO must have at least one service
3. PO status workflow: Pending → Approved/Rejected
4. Only supplier can approve/reject PO
5. Approved PO cannot be modified
6. PO cannot be deleted if linked to any package

### Packages & Journeys
1. Package code format: PKG-{AGENCY_CODE}-{SEQUENCE}
2. Packages are templates (NO dates)
3. Selling price must be >= base cost
4. Package must have at least one service
5. Package cannot be deleted if has confirmed bookings
6. Journey code format: JRN-{PACKAGE_CODE}-{YYMMDD}
7. Journeys have specific departure & return dates
8. Journey quota management: total = confirmed + available
9. Journey status: Planning → Confirmed → In Progress → Completed

### Bookings
1. Booking reference format: BKG-YYYY-XXXX
2. Minimum 1 traveler per booking
3. Maximum 50 travelers per booking (configurable)
4. Female traveler (age > 12) must have mahram for Umrah/Hajj
5. Mahram must be male traveler in same booking
6. Booking status workflow: Pending → Confirmed → Departed → Completed
7. Booking can be cancelled at any status (with reason)
8. Confirmed booking decrements journey quota
9. Cancelled booking increments journey quota
10. Total amount = selling price × total pax

### Customers
1. Customer code format: CUST-YYMMDD-XXX
2. Email must be unique per agency (if provided)
3. Phone must be unique per agency
4. Customer statistics auto-calculated on booking changes
5. Customer soft-deleted (preserve history)

### Documents
1. Document checklist auto-generated on booking creation
2. Document types based on package type
3. Document status: Not Submitted → Submitted → Verified/Rejected
4. Passport expiry must be > 6 months from departure date
5. Visa expiry must be > departure date
6. Document completion % = (verified / total required) × 100
7. Expiring soon = expiry date < 30 days from today

### Tasks
1. Tasks auto-generated from templates on booking creation
2. Tasks auto-generated on H-30 and H-7 before departure
3. Task status: To Do → In Progress → Done
4. Task completion % = (completed / total) × 100
5. Overdue task = due date < today AND status != Done
6. Auto-generated tasks cannot be deleted (only custom tasks)

### Notifications
1. Notification schedules: H-30, H-14, H-7, H-3, H-1
2. Notifications sent daily at 09:00 AM (configurable)
3. Notification triggered if: booking confirmed AND departure date - today = trigger days
4. Failed notifications retry up to 3 times (1 hour interval)
5. Notification variables: {customer_name}, {package_name}, {departure_date}, etc.

### Payments
1. Default schedule: DP (40%), Installment 1 (30%), Installment 2 (30%)
2. DP due date: booking date + 3 days
3. Installment 1 due date: departure date - 60 days
4. Installment 2 due date: departure date - 30 days
5. Payment status: Pending → Paid → Overdue
6. Overdue = due date < today AND status = Pending
7. Payment methods: Bank Transfer, Cash, Credit Card, E-wallet

### Itineraries
1. One itinerary per package
2. Minimum 1 day, maximum 60 days
3. Activities sorted by time
4. Meal types: Breakfast, Lunch, Dinner, Snack, None
5. Itinerary templates: Umrah 9D8N, Hajj 40D39N

### Supplier Bills
1. Bill auto-generated when PO status = Approved
2. Bill due date = PO approval date + 30 days (configurable)
3. Bill amount = sum of PO items
4. Bill status: Unpaid → Partially Paid → Paid → Overdue
5. Payment can be partial or full

### B2B Marketplace
1. Agency A can only publish from approved PO
2. Reseller price must be > cost price (minimum 5% markup)
3. Available quota = total - used - sold - reserved
4. Supplier name HIDDEN from marketplace
5. Agency B cannot order from own agency
6. Order quantity must be ≤ available quota
7. Order creates reservation (quota locked)
8. Order status: Pending → Approved/Rejected/Cancelled
9. If approved: quota transferred (reserved → sold)
10. If rejected: quota released (reserved → available)
11. If no response in 24 hours: auto-reject
12. Service auto-unpublished if available quota = 0
13. Order number format: AO-YYMMDD-XXX

### Profitability
1. Revenue = Package Price × Total Pax
2. Cost = Sum of Supplier Costs (from PO) + Sum of Agency Order Costs
3. Gross Profit = Revenue - Cost
4. Gross Margin % = (Gross Profit / Revenue) × 100
5. Low margin = gross margin < 10%
6. High margin = gross margin > 30%

---

## Frontend Components

### Shared Components (10 components)
- LoadingSpinnerComponent
- ErrorMessageComponent
- ConfirmationDialogComponent
- SuccessToastComponent
- DataTableComponent
- FormInputComponent
- DatePickerComponent
- DropdownComponent
- FileUploadComponent (placeholder)
- StatusBadgeComponent

### Platform Admin (10 components)
- PlatformDashboardComponent
- AgencyListComponent
- AgencyFormComponent
- AgencyDetailComponent
- SupplierListComponent
- SupplierApprovalComponent
- SupplierDetailComponent
- MarketplaceAdminComponent
- AgencyTransactionsComponent
- MarketplaceStatsComponent

### Supplier (15 components)
- SupplierDashboardComponent
- ServiceListComponent
- ServiceFormComponent
- ServiceDetailComponent
- SeasonalPricingComponent
- POListComponent
- PODetailComponent
- POApprovalComponent
- ServiceCatalogComponent
- ServiceFilterComponent
- ServiceCardComponent
- POItemsComponent
- POStatusBadgeComponent
- ServicePublishComponent
- SupplierStatsComponent

### Agency - Core (25 components)
- AgencyDashboardComponent
- ServiceCatalogComponent
- ServiceDetailDialogComponent
- POListComponent
- POFormComponent
- PODetailComponent
- PackageListComponent
- PackageFormComponent
- PackageDetailComponent
- PackagePricingComponent
- JourneyListComponent
- JourneyFormComponent
- JourneyDetailComponent
- JourneyServiceTrackingComponent
- BookingListComponent
- BookingFormComponent (multi-step)
- BookingDetailComponent
- TravelerFormComponent
- CustomerSearchComponent
- CustomerSelectComponent
- PackageCardComponent
- JourneyCardComponent
- BookingStatusBadgeComponent
- QuotaIndicatorComponent
- PriceCalculatorComponent

### Agency - Customer Management (5 components)
- CustomerListComponent
- CustomerFormComponent
- CustomerDetailComponent
- CustomerNotesComponent
- CustomerTagsComponent

### Agency - Document Management (5 components)
- DocumentChecklistComponent
- DocumentStatusComponent
- DocumentVerificationComponent
- DocumentDashboardComponent
- DocumentReminderComponent

### Agency - Task Management (10 components)
- TaskBoardComponent (Kanban)
- TaskListComponent
- TaskCardComponent
- TaskFormComponent
- TaskDetailComponent
- TaskAssignmentComponent
- MyTasksComponent
- OverdueTasksComponent
- TaskTemplateComponent
- TaskFilterComponent

### Agency - Notifications (10 components)
- NotificationScheduleListComponent
- NotificationScheduleFormComponent
- NotificationTemplateListComponent
- NotificationTemplateFormComponent
- NotificationTemplateEditorComponent
- NotificationHistoryComponent
- NotificationDashboardComponent
- NotificationTriggerComponent
- NotificationLogComponent
- NotificationSettingsComponent

### Agency - Payments (10 components)
- PaymentScheduleComponent
- PaymentRecordingFormComponent
- PaymentHistoryComponent
- OutstandingPaymentsComponent
- OverduePaymentsComponent
- PaymentDashboardComponent
- PaymentReminderComponent
- PaymentExportComponent
- PaymentSummaryComponent
- PaymentFilterComponent

### Agency - Itinerary (10 components)
- ItineraryBuilderComponent
- ItineraryDayComponent
- ItineraryActivityComponent
- ItineraryTemplateComponent
- ItineraryPreviewComponent
- ItineraryPdfExportComponent
- ItineraryShareComponent
- ItineraryTimelineComponent
- ItineraryMealPlanComponent
- ItineraryEditorComponent

### Agency - Supplier Bills (10 components)
- SupplierBillListComponent
- SupplierBillFormComponent
- SupplierBillDetailComponent
- SupplierPaymentFormComponent
- OutstandingPayablesComponent
- OverduePayablesComponent
- PayablesDashboardComponent
- SupplierPaymentHistoryComponent
- PayablesReportComponent
- PayablesFilterComponent

### Agency - B2B Marketplace (20 components)

**Seller (Agency A) - 10 components:**
- AgencyServiceListComponent
- AgencyServiceFormComponent
- AgencyServicePricingComponent
- AgencyServicePublishComponent
- IncomingOrdersComponent
- OrderApprovalComponent
- OrderRejectionComponent
- AgencySalesReportComponent
- AgencyServiceDetailComponent
- AgencyServiceQuotaComponent

**Buyer (Agency B) - 10 components:**
- MarketplaceComponent
- MarketplaceFilterComponent
- MarketplaceServiceCardComponent
- MarketplaceServiceDetailComponent
- AgencyOrderFormComponent
- OutgoingOrdersComponent
- AgencyOrderDetailComponent
- AgencyPurchaseHistoryComponent
- MarketplaceSearchComponent
- MarketplaceDashboardComponent

### Agency - Profitability (10 components)
- BookingProfitabilityComponent
- PackageProfitabilityComponent
- ProfitabilityDashboardComponent
- ProfitabilityReportComponent
- ProfitabilityChartComponent
- MarginIndicatorComponent
- RevenueBreakdownComponent
- CostBreakdownComponent
- ProfitTrendComponent
- ProfitabilityFilterComponent

### Agency - Communication Log (10 components)
- CommunicationLogListComponent
- CommunicationLogFormComponent
- CommunicationLogDetailComponent
- CommunicationHistoryComponent
- FollowUpListComponent
- CommunicationDashboardComponent
- CommunicationTimelineComponent
- CommunicationFilterComponent
- CommunicationExportComponent
- CommunicationReminderComponent

**Total Components: ~150 components**

---

## Background Jobs (Hangfire)

### 1. Daily Notification Job
**Schedule:** Daily at 09:00 AM  
**Purpose:** Send pre-departure notifications

```csharp
public class DailyNotificationJob
{
    public async Task Execute()
    {
        // 1. Get all confirmed bookings
        var bookings = await GetConfirmedBookings();
        
        // 2. For each booking, check notification schedules
        foreach (var booking in bookings)
        {
            var daysBefore = (booking.DepartureDate - DateTime.Today).Days;
            var schedules = await GetMatchingSchedules(booking.AgencyId, daysBefore);
            
            // 3. Create notification logs and send
            foreach (var schedule in schedules)
            {
                await CreateAndSendNotification(booking, schedule);
            }
        }
    }
}
```

### 2. Notification Retry Job
**Schedule:** Every hour  
**Purpose:** Retry failed notifications

```csharp
public class NotificationRetryJob
{
    public async Task Execute()
    {
        // 1. Get failed notifications with retry_count < 3
        var failedNotifications = await GetFailedNotifications();
        
        // 2. Retry sending
        foreach (var notification in failedNotifications)
        {
            var success = await RetrySendNotification(notification);
            
            if (success)
            {
                notification.Status = "sent";
                notification.SentAt = DateTime.Now;
            }
            else
            {
                notification.RetryCount++;
                if (notification.RetryCount >= 3)
                {
                    notification.Status = "failed_permanently";
                }
            }
            
            await UpdateNotificationLog(notification);
        }
    }
}
```

### 3. Auto-Generate H-30 Tasks Job
**Schedule:** Daily at 08:00 AM  
**Purpose:** Generate tasks 30 days before departure

```csharp
public class GenerateH30TasksJob
{
    public async Task Execute()
    {
        // 1. Get bookings where departure_date = today + 30 days
        var targetDate = DateTime.Today.AddDays(30);
        var bookings = await GetBookingsByDepartureDate(targetDate);
        
        // 2. Get H-30 task templates
        foreach (var booking in bookings)
        {
            var templates = await GetTaskTemplates(booking.AgencyId, "h_30");
            
            // 3. Generate tasks
            foreach (var template in templates)
            {
                await CreateTaskFromTemplate(booking, template);
            }
        }
    }
}
```

### 4. Auto-Generate H-7 Tasks Job
**Schedule:** Daily at 08:00 AM  
**Purpose:** Generate tasks 7 days before departure

```csharp
public class GenerateH7TasksJob
{
    public async Task Execute()
    {
        // 1. Get bookings where departure_date = today + 7 days
        var targetDate = DateTime.Today.AddDays(7);
        var bookings = await GetBookingsByDepartureDate(targetDate);
        
        // 2. Get H-7 task templates
        foreach (var booking in bookings)
        {
            var templates = await GetTaskTemplates(booking.AgencyId, "h_7");
            
            // 3. Generate tasks
            foreach (var template in templates)
            {
                await CreateTaskFromTemplate(booking, template);
            }
        }
    }
}
```

### 5. Auto-Reject Pending Agency Orders Job
**Schedule:** Every hour  
**Purpose:** Auto-reject orders not responded within 24 hours

```csharp
public class AutoRejectAgencyOrdersJob
{
    public async Task Execute()
    {
        // 1. Get pending orders created > 24 hours ago
        var cutoffTime = DateTime.Now.AddHours(-24);
        var pendingOrders = await GetPendingOrdersOlderThan(cutoffTime);
        
        // 2. Reject and release quota
        foreach (var order in pendingOrders)
        {
            // Release reserved quota
            await ReleaseQuota(order.AgencyServiceId, order.Quantity);
            
            // Update order status
            order.Status = "rejected";
            order.RejectionReason = "Auto-rejected: No response within 24 hours";
            order.RejectedAt = DateTime.Now;
            
            await UpdateOrder(order);
            
            // Send notification to buyer
            await SendOrderRejectedNotification(order);
        }
    }
}
```

### 6. Auto-Unpublish Zero Quota Services Job
**Schedule:** Daily at 10:00 AM  
**Purpose:** Unpublish marketplace services with zero available quota

```csharp
public class AutoUnpublishServicesJob
{
    public async Task Execute()
    {
        // 1. Get published services with available_quota = 0
        var services = await GetPublishedServicesWithZeroQuota();
        
        // 2. Unpublish each service
        foreach (var service in services)
        {
            service.IsPublished = false;
            await UpdateAgencyService(service);
            
            // Log action
            await LogAutoUnpublish(service);
        }
    }
}
```

---

## Development Setup

### Prerequisites
- .NET 8 SDK
- Node.js 20+
- PostgreSQL 16
- Docker & Docker Compose (optional)
- Git

### Backend Setup

1. **Clone repository**
```bash
git clone <repository-url>
cd tour-travel-erp/backend
```

2. **Install dependencies**
```bash
dotnet restore
```

3. **Setup database**
```bash
# Create database
createdb tour_travel_erp

# Update connection string in appsettings.Development.json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Database=tour_travel_erp;Username=postgres;Password=your_password"
  }
}
```

4. **Run migrations**
```bash
dotnet ef database update
```

5. **Seed data**
```bash
dotnet run --seed
```

6. **Run backend**
```bash
dotnet run
# API available at: http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

### Frontend Setup

1. **Navigate to frontend**
```bash
cd tour-travel-erp/frontend
```

2. **Install dependencies**
```bash
npm install
```

3. **Update environment**
```typescript
// src/environments/environment.ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:5000/api'
};
```

4. **Run frontend**
```bash
npm start
# App available at: http://localhost:4200
```

### Docker Setup (Recommended)

1. **Start all services**
```bash
docker-compose up -d
```

2. **Services available at:**
- Backend API: http://localhost:5000
- Frontend: http://localhost:4200
- PostgreSQL: localhost:5432
- Swagger: http://localhost:5000/swagger

3. **Stop services**
```bash
docker-compose down
```

### Environment Variables

**Backend (.env)**
```
DATABASE_URL=Host=localhost;Database=tour_travel_erp;Username=postgres;Password=your_password
JWT_SECRET=your-super-secret-jwt-key-min-32-characters
JWT_EXPIRY_HOURS=24
REFRESH_TOKEN_EXPIRY_DAYS=7
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
HANGFIRE_DASHBOARD_USERNAME=admin
HANGFIRE_DASHBOARD_PASSWORD=admin123
```

**Frontend (.env)**
```
VITE_API_URL=http://localhost:5000/api
VITE_APP_NAME=Tour & Travel ERP
```

---

## Testing Strategy

### Backend Testing

#### Unit Tests
```csharp
[Fact]
public async Task CreateBooking_WithValidData_ShouldSucceed()
{
    // Arrange
    var command = new CreateBookingCommand
    {
        PackageId = Guid.NewGuid(),
        JourneyId = Guid.NewGuid(),
        CustomerId = Guid.NewGuid(),
        Travelers = new List<TravelerDto>
        {
            new TravelerDto { FullName = "John Doe", Gender = "male" }
        }
    };
    
    // Act
    var result = await _handler.Handle(command, CancellationToken.None);
    
    // Assert
    Assert.NotNull(result);
    Assert.True(result.Success);
    Assert.NotNull(result.Data.BookingReference);
}
```

#### Integration Tests
```csharp
public class BookingApiTests : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task POST_CreateBooking_ReturnsCreated()
    {
        // Arrange
        var client = _factory.CreateClient();
        var booking = new CreateBookingRequest { /* ... */ };
        
        // Act
        var response = await client.PostAsJsonAsync("/api/bookings", booking);
        
        // Assert
        response.EnsureSuccessStatusCode();
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    }
}
```

#### Database Tests (Testcontainers)
```csharp
public class DatabaseTests : IAsyncLifetime
{
    private PostgreSqlContainer _container;
    
    public async Task InitializeAsync()
    {
        _container = new PostgreSqlBuilder()
            .WithImage("postgres:16")
            .Build();
        await _container.StartAsync();
    }
    
    [Fact]
    public async Task RLS_Policy_ShouldIsolateAgencies()
    {
        // Test RLS policies
    }
}
```

### Frontend Testing

#### Component Tests
```typescript
describe('BookingListComponent', () => {
  let component: BookingListComponent;
  let fixture: ComponentFixture<BookingListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BookingListComponent]
    }).compileComponents();
    
    fixture = TestBed.createComponent(BookingListComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load bookings on init', () => {
    component.ngOnInit();
    expect(component.bookings.length).toBeGreaterThan(0);
  });
});
```

#### Service Tests
```typescript
describe('BookingService', () => {
  let service: BookingService;
  let httpMock: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule],
      providers: [BookingService]
    });
    service = TestBed.inject(BookingService);
    httpMock = TestBed.inject(HttpTestingController);
  });

  it('should fetch bookings', () => {
    const mockBookings = [{ id: '1', bookingReference: 'BKG-001' }];
    
    service.getBookings().subscribe(bookings => {
      expect(bookings).toEqual(mockBookings);
    });
    
    const req = httpMock.expectOne('/api/bookings');
    expect(req.request.method).toBe('GET');
    req.flush(mockBookings);
  });
});
```

### E2E Tests (Playwright)
```typescript
test('complete booking flow', async ({ page }) => {
  // Login
  await page.goto('http://localhost:4200/auth/login');
  await page.fill('[name="email"]', 'agency@test.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');
  
  // Navigate to bookings
  await page.click('text=Bookings');
  await page.click('text=Create Booking');
  
  // Fill booking form
  await page.selectOption('[name="package"]', 'PKG-001');
  await page.selectOption('[name="journey"]', 'JRN-001');
  await page.fill('[name="customerName"]', 'John Doe');
  await page.fill('[name="customerEmail"]', 'john@example.com');
  
  // Submit
  await page.click('button:has-text("Create Booking")');
  
  // Verify
  await expect(page.locator('text=Booking created successfully')).toBeVisible();
});
```

### Test Coverage Goals
- Backend: > 80% code coverage
- Frontend: > 70% code coverage
- Critical paths: 100% coverage

---

## Deployment

### Docker Compose Production

**docker-compose.prod.yml**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: tour_travel_erp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    environment:
      DATABASE_URL: Host=postgres;Database=tour_travel_erp;Username=postgres;Password=${DB_PASSWORD}
      JWT_SECRET: ${JWT_SECRET}
      ASPNETCORE_ENVIRONMENT: Production
    depends_on:
      - postgres
    networks:
      - app-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

### Backend Dockerfile
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["TourTravelERP.API/TourTravelERP.API.csproj", "TourTravelERP.API/"]
RUN dotnet restore "TourTravelERP.API/TourTravelERP.API.csproj"
COPY . .
WORKDIR "/src/TourTravelERP.API"
RUN dotnet build "TourTravelERP.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "TourTravelERP.API.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TourTravelERP.API.dll"]
```

### Frontend Dockerfile
```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/tour-travel-erp /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Nginx Configuration
```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Deployment Steps

1. **Build images**
```bash
docker-compose -f docker-compose.prod.yml build
```

2. **Run migrations**
```bash
docker-compose -f docker-compose.prod.yml run backend dotnet ef database update
```

3. **Start services**
```bash
docker-compose -f docker-compose.prod.yml up -d
```

4. **Check logs**
```bash
docker-compose -f docker-compose.prod.yml logs -f
```

5. **Scale services (if needed)**
```bash
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

### Health Checks

**Backend Health Check**
```
GET /health
Response: { "status": "healthy", "database": "connected", "version": "1.0.0" }
```

**Monitoring**
- Use Prometheus + Grafana for metrics
- Use Serilog + Seq for centralized logging
- Use Hangfire Dashboard for background job monitoring

---

## Security Best Practices

### Backend Security
1. **JWT Token:** Use strong secret (min 32 characters)
2. **Password Hashing:** BCrypt with salt rounds = 12
3. **SQL Injection:** Use parameterized queries (EF Core)
4. **CORS:** Configure allowed origins
5. **Rate Limiting:** Implement rate limiting per IP
6. **Input Validation:** FluentValidation for all inputs
7. **RLS:** Row-Level Security for multi-tenancy
8. **HTTPS:** Enforce HTTPS in production

### Frontend Security
1. **XSS Protection:** Sanitize user inputs
2. **CSRF Protection:** Use Angular's built-in CSRF protection
3. **Token Storage:** Store JWT in httpOnly cookie (not localStorage)
4. **Route Guards:** Protect routes with AuthGuard and RoleGuard
5. **Content Security Policy:** Configure CSP headers
6. **Dependency Scanning:** Regular npm audit

---

## Performance Optimization

### Backend
1. **Database Indexing:** Index all foreign keys and frequently queried columns
2. **Query Optimization:** Use EF Core query optimization
3. **Caching:** Use Redis for frequently accessed data
4. **Async/Await:** Use async operations for I/O
5. **Connection Pooling:** Configure connection pool size
6. **Pagination:** Always paginate large result sets

### Frontend
1. **Lazy Loading:** Lazy load feature modules
2. **OnPush Change Detection:** Use OnPush strategy
3. **TrackBy:** Use trackBy in *ngFor
4. **Virtual Scrolling:** Use CDK virtual scrolling for large lists
5. **Image Optimization:** Compress and lazy load images
6. **Bundle Size:** Analyze and optimize bundle size

---

## API Documentation

API documentation available at: **http://localhost:5000/swagger**

Swagger provides:
- Interactive API testing
- Request/response schemas
- Authentication requirements
- Example requests
- Error responses

---

## Support & Maintenance

### Logging
- **Backend:** Serilog with structured logging
- **Frontend:** Console logging (development), Sentry (production)
- **Database:** PostgreSQL query logging

### Monitoring
- **Application:** Prometheus + Grafana
- **Database:** pg_stat_statements
- **Background Jobs:** Hangfire Dashboard

### Backup Strategy
- **Database:** Daily automated backups
- **Retention:** 30 days
- **Recovery:** Tested monthly

---

**END OF DEVELOPER DOCUMENTATION**

**Status:** ✅ Complete

**Last Updated:** February 14, 2026

