# System Flow Diagrams

## 1. Overall System Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         COMPLETE SYSTEM FLOW                             │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐
│   SUPPLIER   │
└──────┬───────┘
       │
       ├─► Create Service (hotel, flight, visa, etc.)
       │   └─► Store dynamic JSON details (no validation)
       │
       ├─► Upload Images (max 5)
       │   └─► Store in MinIO
       │
       ├─► Set Availability (per-date)
       │   └─► Date range + price override
       │
       └─► Publish Service
           └─► Status: draft → published

                    ↓

┌──────────────┐
│    AGENCY    │
└──────┬───────┘
       │
       ├─► Browse Marketplace
       │   └─► Filter by type, location, price, dates
       │
       ├─► Add to Cart
       │   └─► Select quantity
       │
       ├─► Create Purchase Order
       │   └─► Submit to Supplier
       │
       ├─► Supplier Approves PO
       │   └─► Services → Agency Inventory
       │
       ├─► Create Journey
       │   ├─► Basic Info (name, dates, quota, package type)
       │   ├─► Build Itinerary (activities)
       │   │   ├─► Activity 1: Flight
       │   │   ├─► Activity 2: Hotel (check-in/out dates)
       │   │   ├─► Activity 3: Transport
       │   │   └─► Activity N: ...
       │   ├─► Select Services (dynamic by type)
       │   │   ├─► GROUP A (hotel, transport, guide, catering)
       │   │   │   └─► Requires check-in/out dates FIRST
       │   │   ├─► GROUP B (flight)
       │   │   │   └─► Auto-fill departure/arrival times
       │   │   └─► GROUP C (visa, insurance, handling)
       │   │       └─► Simple selection
       │   └─► Review Pricing
       │       └─► Base cost + Markup = Selling price
       │
       └─► Publish Journey
           ├─► Validation:
           │   ├─► Has activities
           │   ├─► All services selected
           │   └─► All services available
           └─► Status: draft → published

                    ↓

┌──────────────┐
│   CUSTOMER   │
└──────┬───────┘
       │
       ├─► Browse Published Journeys
       │
       ├─► View Journey Details
       │   └─► Itinerary, pricing, availability
       │
       ├─► Create Booking
       │   ├─► Select PAX count
       │   ├─► Fill traveler details
       │   └─► Choose payment plan
       │
       └─► Complete Payment
           └─► Booking confirmed
```

---

## 2. Supplier Service Creation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│              SUPPLIER SERVICE CREATION FLOW                      │
└─────────────────────────────────────────────────────────────────┘

[Supplier Portal]
      │
      ├─► Click "Create Service"
      │
      ├─► Fill Form:
      │   ├─► Service Type: [Dropdown]
      │   │   └─► hotel, flight, visa, transport, guide, 
      │   │       insurance, catering, handling
      │   ├─► Name: [Text]
      │   ├─► Description: [Textarea]
      │   ├─► Base Price: [Number]
      │   ├─► Location: [City, Country]
      │   └─► Service Details: [JSON Editor]
      │       ├─► Hotel: {star_rating, room_type, bed_config, ...}
      │       ├─► Flight: {airline, flight_class, departure, ...}
      │       └─► etc.
      │
      ├─► Payment Terms (Optional):
      │   ├─► Enable: [Checkbox]
      │   ├─► DP Percentage: [10-90%]
      │   └─► Full Payment Due: [1-60 days before]
      │
      ├─► Submit
      │   │
      │   └─► Backend:
      │       ├─► Validate input
      │       ├─► Generate service_code
      │       ├─► Store in DB (status: draft)
      │       └─► Return service_id
      │
      ├─► Upload Images (max 5):
      │   ├─► Select files (JPG, PNG, WebP)
      │   ├─► Upload to MinIO
      │   ├─► Store metadata in DB
      │   └─► Set first as primary
      │
      ├─► Set Availability:
      │   ├─► Select date range
      │   ├─► Set price override (optional)
      │   ├─► Set available: true/false
      │   └─► Bulk create records
      │
      └─► Publish Service
          └─► Status: draft → published
              └─► Now visible in marketplace
```

---

## 3. Dynamic Service Selection Flow

```
┌─────────────────────────────────────────────────────────────────┐
│           DYNAMIC SERVICE SELECTION BY TYPE                      │
└─────────────────────────────────────────────────────────────────┘

[Journey Form - Activity Section]
      │
      ├─► Add Activity
      │
      ├─► Fill Basic Fields:
      │   ├─► Date: [Calendar]
      │   ├─► Type: [Dropdown] ◄─── DETERMINES BEHAVIOR
      │   └─► Description: [Textarea]
      │
      ├─► Type Selected → Show Conditional Fields:
      │
      ├─► IF Type = "hotel" | "transport" | "guide" | "catering"
      │   │   (GROUP A - Date Range Required)
      │   │
      │   ├─► Show Fields:
      │   │   ├─► Check-in Date: [Calendar] ◄─── REQUIRED
      │   │   └─► Check-out Date: [Calendar] ◄─── REQUIRED
      │   │
      │   ├─► "Select Services" Button:
      │   │   └─► DISABLED until both dates filled
      │   │
      │   └─► When dates filled + button clicked:
      │       ├─► Open Modal
      │       ├─► API Call:
      │       │   GET /api/journeys/available-services
      │       │   ?type=hotel
      │       │   &check_in_date=2026-03-15
      │       │   &check_out_date=2026-03-20
      │       │
      │       ├─► Backend filters:
      │       │   ├─► SupplierServices (type=hotel, status=published)
      │       │   ├─► JOIN ServiceAvailability
      │       │   ├─► WHERE date BETWEEN check_in AND check_out
      │       │   ├─► AND is_available = true
      │       │   └─► Calculate total price for date range
      │       │
      │       ├─► Show Results:
      │       │   ├─► Service cards with details
      │       │   ├─► Price per night × nights
      │       │   └─► Total price
      │       │
      │       └─► User selects → Modal closes
      │           └─► Activity form shows selected service
      │
      ├─► ELSE IF Type = "flight"
      │   │   (GROUP B - Auto-fill Times)
      │   │
      │   ├─► Show Fields: (none extra)
      │   │
      │   ├─► "Select Services" Button:
      │   │   └─► ENABLED immediately
      │   │
      │   └─► When button clicked:
      │       ├─► Open Modal
      │       ├─► API Call:
      │       │   GET /api/journeys/available-services
      │       │   ?type=flight
      │       │   &date=2026-03-15
      │       │
      │       ├─► Show flight services
      │       │
      │       └─► User selects → Modal closes
      │           ├─► Activity form shows selected service
      │           └─► AUTO-FILL (read-only):
      │               ├─► Estimated Time Departure
      │               └─► Estimated Time Arrival
      │               (from service_details JSON)
      │
      └─► ELSE (Type = "visa" | "insurance" | "handling")
          │   (GROUP C - Simple Selection)
          │
          ├─► Show Fields: (none extra)
          │
          ├─► "Select Services" Button:
          │   └─► ENABLED immediately
          │
          └─► When button clicked:
              ├─► Open Modal
              ├─► API Call:
              │   GET /api/journeys/available-services
              │   ?type=visa
              │   &date=2026-03-15
              │
              ├─► Show services
              │
              └─► User selects → Modal closes
                  └─► Activity form shows selected service
```

---

