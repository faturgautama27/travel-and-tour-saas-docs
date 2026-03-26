# Payment Tracking - Agency & Supplier Perspectives

**Project**: Tour & Travel ERP SaaS  
**Date**: March 18, 2026  
**Status**: Comprehensive Analysis - FINALIZED

---

## 📋 OVERVIEW

This document provides a comprehensive analysis of payment tracking from both **Agency** and **Supplier** perspectives, based on the finalized payment workflow design.

**Key Decisions**:
- ✅ journey_services table DEPRECATED - Use journey_activities only
- ✅ DP paid IMMEDIATELY when service selected → Locks availability
- ✅ Pelunasan paid before H-X (X = full_payment_due_days from service config)
- ✅ Commission flexible: Different rates per service type, support percentage/fixed, can charge agency/supplier/both
- ✅ Commission rates: Hotel 4.76%, Flight 5.30%, Visa 3.49%
- ✅ Supplier transfer: Hold DP until pelunasan paid, then transfer together

---

## 💰 PAYMENT FLOW - COMPLETE LIFECYCLE

### Scenario: Hotel Service with DP + Pelunasan

**Service Configuration**:
```
Hotel Grand Makkah 5 Star - Deluxe Twin
├─ Base Price: Rp 2,500,000 per night
├─ Payment Terms Enabled: Yes
├─ DP Percentage: 30%
├─ Full Payment Due Days: 7 (H-7)
└─ Commission: 4.76% from agency (from commission_configs)
```

**Journey Activity**:
```
Activity 2: Hotel Accommodation
├─ Date: 15 March 2026
├─ Check-in: 15 March 2026
├─ Check-out: 20 March 2026 (5 nights)
├─ Quantity: 20 rooms (= journey.quota)
├─ Unit Cost: Rp 2,500,000 × 5 nights = Rp 12,500,000
├─ Total Cost: Rp 12,500,000 × 20 = Rp 250,000,000
└─ Payment Status: "unpaid"
```

---

### STEP 1: Agency Pays DP (Immediately)

**Agency Action**: Click [Pay DP Now] on Journey Detail page

**System Calculation**:
```
Service Cost: Rp 250,000,000
DP Amount (30%): Rp 75,000,000

Get Commission Config:
├─ Transaction Type: journey_activity_payment
├─ Service Type: hotel
├─ Supplier ID: (specific supplier)
└─ Result: 4.76% from agency

Agency Commission: Rp 75,000,000 × 4.76% = Rp 3,570,000
Total Agency Pays: Rp 75,000,000 + Rp 3,570,000 = Rp 78,570,000
Supplier Will Receive: Rp 75,000,000 (transferred later)
```

**Payment Gateway Flow**:
```
1. Backend creates Payment record:
   ├─ payment_type: "down_payment"
   ├─ service_cost: Rp 75,000,000
   ├─ agency_commission_amount: Rp 3,570,000
   ├─ amount_paid_by_agency: Rp 78,570,000
   ├─ amount_to_supplier: Rp 75,000,000
   ├─ status: "pending"
   └─ expired_at: now + 24 hours

2. Backend calls Xendit API:
   ├─ Create invoice
   ├─ Amount: Rp 78,570,000
   └─ Return payment_url

3. Frontend redirects to Xendit payment page

4. Agency completes payment (VA BCA)

5. Xendit webhook → Backend:
   ├─ Update payment.status = "success"
   ├─ Update payment.paid_at
   ├─ Update journey_activity.payment_status = "dp_paid"
   ├─ Update journey_activity.down_payment_id
   ├─ Calculate full_payment_due_date = check_in_date - 7 days = 8 March 2026
   ├─ Update journey_activity.full_payment_due_date
   ├─ Create commission_transaction record
   ├─ Update payment.supplier_transfer_status = "pending" (hold until pelunasan)
   └─ Send notifications
```

**Database State After DP**:
```sql
-- payments table
{
  id: "pay-001",
  agency_id: "agency-123",
  supplier_id: "supplier-456",
  journey_id: "journey-789",
  journey_activity_id: "activity-002",
  payment_type: "down_payment",
  service_cost: 75000000,
  agency_commission_amount: 3570000,
  amount_paid_by_agency: 78570000,
  amount_to_supplier: 75000000,
  status: "success",
  paid_at: "2026-03-18 10:30:00",
  supplier_transfer_status: "pending", -- HOLD until pelunasan
  transferred_to_supplier_at: null
}

-- journey_activities table
{
  id: "activity-002",
  payment_status: "dp_paid",
  down_payment_id: "pay-001",
  down_payment_paid_at: "2026-03-18 10:30:00",
  full_payment_due_date: "2026-03-08" -- H-7
}

-- commission_transactions table
{
  id: "comm-001",
  transaction_type: "journey_activity_payment",
  reference_id: "pay-001",
  agency_id: "agency-123",
  supplier_id: "supplier-456",
  base_amount: 75000000,
  agency_commission_amount: 3570000,
  supplier_commission_amount: 0,
  total_commission_amount: 3570000,
  status: "collected"
}
```

---

### STEP 2: Agency Pays Pelunasan (Before H-7)

**Timeline**: 8 March 2026 (7 days before check-in)

**Agency Action**: Click [Pay Pelunasan] on Journey Detail page

**System Calculation**:
```
Service Cost: Rp 250,000,000
Pelunasan Amount (70%): Rp 175,000,000

Commission Config: Same as DP (4.76% from agency)

Agency Commission: Rp 175,000,000 × 4.76% = Rp 8,330,000
Total Agency Pays: Rp 175,000,000 + Rp 8,330,000 = Rp 183,330,000
Supplier Will Receive: Rp 175,000,000
```

**Payment Gateway Flow**: Same as DP

**Database State After Pelunasan**:
```sql
-- payments table (2nd record)
{
  id: "pay-002",
  payment_type: "full_payment",
  service_cost: 175000000,
  agency_commission_amount: 8330000,
  amount_paid_by_agency: 183330000,
  amount_to_supplier: 175000000,
  status: "success",
  paid_at: "2026-03-07 14:20:00",
  supplier_transfer_status: "pending" -- Will trigger transfer
}

-- journey_activities table
{
  payment_status: "fully_paid", -- UPDATED
  full_payment_id: "pay-002",
  full_payment_paid_at: "2026-03-07 14:20:00"
}

-- commission_transactions table (2nd record)
{
  id: "comm-002",
  base_amount: 175000000,
  agency_commission_amount: 8330000,
  total_commission_amount: 8330000
}
```

---

### STEP 3: Platform Transfers to Supplier (Background Job)

**Trigger**: Pelunasan payment success

**Background Job Logic**:
```
Find payments where:
├─ journey_activity_id = "activity-002"
├─ status = "success"
└─ supplier_transfer_status = "pending"

Result: 2 payments (DP + Pelunasan)

Calculate total to supplier:
├─ DP: Rp 75,000,000
├─ Pelunasan: Rp 175,000,000
└─ Total: Rp 250,000,000

Call Xendit Disbursement API:
├─ Recipient: Supplier bank account
├─ Amount: Rp 250,000,000
└─ Reference: "Hotel Grand Makkah - Journey JRN-001"

Update both payments:
├─ supplier_transfer_status = "transferred"
├─ transferred_to_supplier_at = "2026-03-07 15:00:00"
└─ transfer_reference_number = "XEN-TRF-20260307-001"

Send notification to supplier
```

**Final Database State**:
```sql
-- payments table (both records updated)
{
  id: "pay-001",
  supplier_transfer_status: "transferred",
  transferred_to_supplier_at: "2026-03-07 15:00:00",
  transfer_reference_number: "XEN-TRF-20260307-001"
}
{
  id: "pay-002",
  supplier_transfer_status: "transferred",
  transferred_to_supplier_at: "2026-03-07 15:00:00",
  transfer_reference_number: "XEN-TRF-20260307-001"
}
```

---

## 📊 AGENCY PERSPECTIVE - Payment Tracking

### 1. Journey Detail Page - Payment Status

**Location**: `/agency/journeys/{id}`

**Display for Activity with Payment Terms**:
```
┌─────────────────────────────────────────────────────────────┐
│ Activity 2: Hotel Accommodation                             │
│ Date: 15 March 2026                                         │
│ Service: Hotel Grand Makkah 5 Star - Deluxe Twin          │
│ Source: Supplier (Makkah Hotels Ltd)                       │
│                                                             │
│ Booking Details:                                            │
│ ├─ Check-in: 15 March 2026                                │
│ ├─ Check-out: 20 March 2026 (5 nights)                    │
│ ├─ Quantity: 20 rooms                                      │
│ ├─ Unit Cost: Rp 12,500,000 per room                      │
│ └─ Total Cost: Rp 250,000,000                             │
│                                                             │
│ Payment Terms: DP 30% + Pelunasan 70%                      │
│                                                             │
│ Payment Status: [DP PAID] ✅                               │
│                                                             │
│ Payment Breakdown:                                          │
│ ├─ DP (30%): Rp 78,570,000 ✅ PAID                        │
│ │   ├─ Service Cost: Rp 75,000,000                        │
│ │   ├─ Platform Fee: Rp 3,570,000 (4.76%)                │
│ │   ├─ Paid At: 18 March 2026 10:30 AM                   │
│ │   └─ [View Receipt]                                     │
│ │                                                           │
│ └─ Pelunasan (70%): Rp 183,330,000 ⏳ PENDING            │
│     ├─ Service Cost: Rp 175,000,000                        │
│     ├─ Platform Fee: Rp 8,330,000 (4.76%)                │
│     ├─ Due Date: 8 March 2026 (H-7)                       │
│     ├─ Days Until Due: 3 days                              │
│     └─ [Pay Now]                                           │
└─────────────────────────────────────────────────────────────┘
```

**Display for Activity without Payment Terms**:
```
┌─────────────────────────────────────────────────────────────┐
│ Activity 1: Flight to Jeddah                                │
│ Date: 15 March 2026                                         │
│ Service: Garuda Indonesia Business CGK-JED                 │
│ Source: Supplier (Garuda Indonesia)                        │
│                                                             │
│ Booking Details:                                            │
│ ├─ Quantity: 20 seats                                      │
│ ├─ Unit Cost: Rp 15,000,000 per seat                      │
│ └─ Total Cost: Rp 300,000,000                             │
│                                                             │
│ Payment Terms: Full payment required                        │
│                                                             │
│ Payment Status: [UNPAID] ⏳                                │
│                                                             │
│ Payment Details:                                            │
│ ├─ Service Cost: Rp 300,000,000                           │
│ ├─ Platform Fee: Rp 15,900,000 (5.30%)                   │
│ ├─ Total to Pay: Rp 315,900,000                           │
│ └─ [Pay Now]                                               │
└─────────────────────────────────────────────────────────────┘
```

**Display for Inventory Service**:
```
┌─────────────────────────────────────────────────────────────┐
│ Activity 3: Tour Guide                                      │
│ Date: 16 March 2026                                         │
│ Service: Arabic-English Guide - Certified                  │
│ Source: Your Inventory                                      │
│                                                             │
│ Booking Details:                                            │
│ ├─ Quantity: 20 pax                                        │
│ ├─ Unit Cost: Rp 500,000 per pax                          │
│ └─ Total Cost: Rp 10,000,000                              │
│                                                             │
│ Payment Status: [RESERVED] ✅                              │
│                                                             │
│ No payment needed - Using your inventory                    │
└─────────────────────────────────────────────────────────────┘
```

---

### 2. Agency Payment Dashboard

**Location**: `/agency/payments/dashboard`

**Overview Section**:
```
┌─────────────────────────────────────────────────────────────┐
│ Payment Overview - March 2026                               │
│                                                             │
│ Total Journeys: 5                                           │
│ Total Activities: 45                                        │
│                                                             │
│ Payment Summary:                                            │
│ ├─ Total Service Cost: Rp 2,500,000,000                   │
│ ├─ Total Platform Fees: Rp 119,000,000 (4.76% avg)        │
│ ├─ Total Paid: Rp 2,619,000,000                           │
│ │                                                           │
│ ├─ Paid: Rp 1,500,000,000 (57%)                           │
│ ├─ Pending: Rp 1,119,000,000 (43%)                        │
│ └─ Progress: [████████████░░░░░░░░] 57%                   │
│                                                             │
│ Upcoming Payments (Next 7 Days):                           │
│ ├─ Due Today: Rp 150,000,000 (3 activities)               │
│ ├─ Due in 3 Days: Rp 183,330,000 (2 activities)           │
│ └─ Due in 7 Days: Rp 250,000,000 (5 activities)           │
└─────────────────────────────────────────────────────────────┘
```

**Pending Payments Section**:
```
┌─────────────────────────────────────────────────────────────┐
│ Pending Payments                                            │
│                                                             │
│ Filters: [All Journeys ▼] [All Types ▼] [Sort: Due Date ▼]│
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ⚠️ DUE IN 3 DAYS                                           │
│                                                             │
│ Journey: Paket Umroh 10 Hari Awal November                 │
│ Activity: Hotel Grand Makkah                                │
│ Payment Type: Pelunasan (70%)                               │
│                                                             │
│ Service Cost: Rp 175,000,000                               │
│ Platform Fee: Rp 8,330,000 (4.76%)                        │
│ Total to Pay: Rp 183,330,000                               │
│                                                             │
│ Due Date: 8 March 2026 (H-7)                               │
│ Days Until Due: 3 days                                      │
│                                                             │
│ DP Status: ✅ Paid Rp 78,570,000 on 18 March 2026         │
│                                                             │
│ [Pay Now] [View Journey] [Request Extension]               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 📅 DUE IN 7 DAYS                                           │
│                                                             │
│ Journey: Paket Halal Tour Turki 12 Hari                    │
│ Activity: Flight Istanbul                                   │
│ Payment Type: Full Payment                                  │
│                                                             │
│ Service Cost: Rp 200,000,000                               │
│ Platform Fee: Rp 10,600,000 (5.30%)                       │
│ Total to Pay: Rp 210,600,000                               │
│                                                             │
│ Due Date: 12 March 2026                                     │
│ Days Until Due: 7 days                                      │
│                                                             │
│ [Pay Now] [View Journey]                                   │
└─────────────────────────────────────────────────────────────┘
```

---

### 3. Agency Payment History

**Location**: `/agency/payments/history`

```
┌─────────────────────────────────────────────────────────────┐
│ Payment History                                             │
│                                                             │
│ Filters: [All Journeys ▼] [All Status ▼] [Date Range]     │
│ Export: [Download CSV] [Download PDF]                      │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Payment #PAY-20260318-001                                   │
│ ├─ Date: 18 March 2026 10:30 AM                           │
│ ├─ Journey: Paket Umroh 10 Hari Awal November             │
│ ├─ Activity: Hotel Grand Makkah (DP)                       │
│ ├─ Supplier: Makkah Hotels Ltd                             │
│ │                                                           │
│ ├─ Service Cost: Rp 75,000,000                            │
│ ├─ Platform Fee: Rp 3,570,000 (4.76%)                     │
│ ├─ Total Paid: Rp 78,570,000                              │
│ │                                                           │
│ ├─ Payment Method: Virtual Account BCA                     │
│ ├─ Transaction ID: XEN-INV-20260318-001                    │
│ ├─ Status: [SUCCESS] ✅                                    │
│ │                                                           │
│ └─ Actions: [View Receipt] [Download Invoice]             │
└─────────────────────────────────────────────────────────────┘
```

---

### 4. Agency Notifications

**DP Payment Success**:
```
Subject: ✅ Payment Successful - Down Payment

Your down payment has been processed successfully.

Journey: Paket Umroh 10 Hari Awal November
Activity: Hotel Grand Makkah 5 Star
Payment Type: Down Payment (30%)

Payment Details:
├─ Service Cost: Rp 75,000,000
├─ Platform Fee: Rp 3,570,000 (4.76%)
├─ Total Paid: Rp 78,570,000
├─ Payment Method: Virtual Account BCA
└─ Transaction ID: XEN-INV-20260318-001

Remaining Payment:
├─ Pelunasan (70%): Rp 183,330,000
├─ Due Date: 8 March 2026 (H-7)
└─ Days Until Due: 18 days

[View Receipt] [View Journey] [Pay Pelunasan Now]
```

**Pelunasan Reminder (H-10, H-7, H-3)**:
```
Subject: ⏰ Payment Reminder - Pelunasan Due in 3 Days

Your full payment is due soon.

Journey: Paket Umroh 10 Hari Awal November
Activity: Hotel Grand Makkah 5 Star
Payment Type: Full Payment (70%)

Payment Details:
├─ Service Cost: Rp 175,000,000
├─ Platform Fee: Rp 8,330,000 (4.76%)
├─ Total to Pay: Rp 183,330,000
├─ Due Date: 8 March 2026 (H-7)
└─ Days Until Due: 3 days

DP Status: ✅ Paid Rp 78,570,000 on 18 March 2026

[Pay Now] [View Journey]
```

**Payment Overdue (After Grace Period)**:
```
Subject: 🔴 Payment Overdue - Service May Be Cancelled

Your payment is overdue and service may be cancelled.

Journey: Paket Umroh 10 Hari Awal November
Activity: Hotel Grand Makkah 5 Star
Payment Type: Full Payment (70%)

Payment Details:
├─ Service Cost: Rp 175,000,000
├─ Platform Fee: Rp 8,330,000 (4.76%)
├─ Total to Pay: Rp 183,330,000
├─ Due Date: 8 March 2026 (H-7)
├─ Days Overdue: 4 days (grace period expired)
└─ Grace Period: Expired

Warning: Service will be auto-cancelled in 24 hours if payment not received.
DP amount (Rp 78,570,000) will NOT be refunded.

[Pay Now Urgently] [Contact Support]
```

---

## 📊 SUPPLIER PERSPECTIVE - Payment Tracking

### 1. Supplier Revenue Dashboard

**Location**: `/supplier/revenue/dashboard`

**Overview Section**:
```
┌─────────────────────────────────────────────────────────────┐
│ Revenue Dashboard - March 2026                              │
│                                                             │
│ Total Bookings: 25 services                                │
│ Gross Revenue: Rp 1,250,000,000                            │
│ Platform Commission: Rp 0 (charged to agencies)            │
│ Net Revenue: Rp 1,250,000,000                              │
│                                                             │
│ Payment Status:                                             │
│ ├─ Transferred: Rp 800,000,000 (64%)                      │
│ ├─ Pending Transfer: Rp 300,000,000 (24%)                 │
│ └─ Awaiting Payment: Rp 150,000,000 (12%)                 │
│                                                             │
│ Progress: [████████████████░░░░] 64%                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Revenue by Service Type                                     │
│                                                             │
│ Hotel Services: Rp 750,000,000 (60%)                       │
│ ├─ Bookings: 15                                            │
│ ├─ Commission Deducted: Rp 0                               │
│ └─ Net: Rp 750,000,000                                     │
│                                                             │
│ Flight Services: Rp 400,000,000 (32%)                      │
│ ├─ Bookings: 8                                             │
│ ├─ Commission Deducted: Rp 0                               │
│ └─ Net: Rp 400,000,000                                     │
│                                                             │
│ Transport Services: Rp 100,000,000 (8%)                    │
│ ├─ Bookings: 2                                             │
│ ├─ Commission Deducted: Rp 0                               │
│ └─ Net: Rp 100,000,000                                     │
└─────────────────────────────────────────────────────────────┘
```

**Note**: Commission charged to agency, so supplier sees full service cost

---

### 2. Supplier Payment Transactions

**Location**: `/supplier/revenue/transactions`

```
┌─────────────────────────────────────────────────────────────┐
│ Payment Transactions                                        │
│                                                             │
│ Filters: [All Services ▼] [All Status ▼] [Date Range]     │
│ Export: [Download Statement]                                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Transfer #XEN-TRF-20260307-001                             │
│ ├─ Date: 7 March 2026 15:00 PM                            │
│ ├─ Agency: PT Berkah Travel                                │
│ ├─ Journey: Paket Umroh 10 Hari Awal November             │
│ ├─ Service: Hotel Grand Makkah 5 Star                     │
│ │                                                           │
│ ├─ Payment Breakdown:                                       │
│ │   ├─ DP (30%): Rp 75,000,000                            │
│ │   │   ├─ Paid: 18 March 2026                            │
│ │   │   └─ Held until pelunasan                           │
│ │   │                                                       │
│ │   └─ Pelunasan (70%): Rp 175,000,000                    │
│ │       ├─ Paid: 7 March 2026                             │
│ │       └─ Triggered transfer                              │
│ │                                                           │
│ ├─ Total Service Cost: Rp 250,000,000                     │
│ ├─ Platform Commission: Rp 0 (charged to agency)          │
│ ├─ Amount Transferred: Rp 250,000,000                     │
│ ├─ Transfer Method: Bank Transfer                          │
│ ├─ Bank Account: BCA 1234567890                           │
│ ├─ Status: [TRANSFERRED] ✅                                │
│ │                                                           │
│ └─ Actions: [View Details] [Download Statement]           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Payment #PAY-20260305-015 (Full Payment)                   │
│ ├─ Date: 5 March 2026 09:15 AM                            │
│ ├─ Agency: PT Amanah Travel                                │
│ ├─ Journey: Paket Halal Tour Turki                         │
│ ├─ Service: Garuda Indonesia Business                      │
│ │                                                           │
│ ├─ Payment Type: Full Payment (No DP)                      │
│ ├─ Service Cost: Rp 300,000,000                           │
│ ├─ Platform Commission: Rp 0 (charged to agency)          │
│ ├─ Amount Transferred: Rp 300,000,000                     │
│ ├─ Transfer Date: 5 March 2026 16:00 PM                   │
│ ├─ Transfer Reference: XEN-TRF-20260305-015                │
│ ├─ Status: [TRANSFERRED] ✅                                │
│ │                                                           │
│ └─ Actions: [View Details] [Download Statement]           │
└─────────────────────────────────────────────────────────────┘
```

---

### 3. Supplier Pending Payments

**Location**: `/supplier/revenue/pending`

```
┌─────────────────────────────────────────────────────────────┐
│ Pending Payments (Awaiting Agency)                         │
│                                                             │
│ Total Pending: Rp 450,000,000                              │
│ Expected Net: Rp 450,000,000                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 📅 DP PAID - Awaiting Pelunasan (Due in 5 days)           │
│                                                             │
│ Journey: Paket Umroh Ramadan                                │
│ Agency: PT Hidayah Travel                                   │
│ Service: Hotel Madinah Premium                              │
│                                                             │
│ Payment Status:                                             │
│ ├─ DP (30%): Rp 60,000,000 ✅ PAID                        │
│ │   ├─ Paid Date: 1 March 2026                            │
│ │   └─ Status: Held by platform                           │
│ │                                                           │
│ └─ Pelunasan (70%): Rp 140,000,000 ⏳ PENDING            │
│     ├─ Due Date: 10 March 2026 (H-7)                      │
│     ├─ Days Until Due: 5 days                              │
│     └─ Expected Transfer: After pelunasan paid             │
│                                                             │
│ Total You Will Receive: Rp 200,000,000                     │
│                                                             │
│ [View Details] [Contact Agency]                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ ⏳ UNPAID - Full Payment Required                          │
│                                                             │
│ Journey: Paket Umroh Maret                                  │
│ Agency: PT Barokah Travel                                   │
│ Service: Flight Jeddah-Madinah                              │
│                                                             │
│ Payment Type: Full Payment (No DP)                          │
│ Service Cost: Rp 150,000,000                               │
│ Platform Commission: Rp 0 (charged to agency)              │
│ You Will Receive: Rp 150,000,000                           │
│                                                             │
│ Status: [UNPAID] ⏳                                        │
│ Expected Payment: Before departure                          │
│                                                             │
│ [View Details] [Contact Agency]                            │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ 🔴 OVERDUE (Past H-7)                                      │
│                                                             │
│ Journey: Paket Umroh Februari                               │
│ Agency: PT Amanah Travel                                    │
│ Service: Hotel Madinah Premium                              │
│                                                             │
│ Payment Status:                                             │
│ ├─ DP (30%): Rp 45,000,000 ✅ PAID                        │
│ │   └─ Paid Date: 15 February 2026                        │
│ │                                                           │
│ └─ Pelunasan (70%): Rp 105,000,000 🔴 OVERDUE            │
│     ├─ Due Date: 1 March 2026 (H-7)                       │
│     ├─ Days Overdue: 6 days                                │
│     └─ Grace Period: Expired                               │
│                                                             │
│ Warning: Service may be auto-cancelled by platform          │
│                                                             │
│ [Contact Agency] [Report to Platform]                      │
└─────────────────────────────────────────────────────────────┘
```

---

### 4. Supplier Notifications

**DP Payment Received**:
```
Subject: 💰 Payment Received - Down Payment

You have received a down payment from agency.

Agency: PT Berkah Travel
Journey: Paket Umroh 10 Hari Awal November
Service: Hotel Grand Makkah 5 Star

Payment Details:
├─ Payment Type: Down Payment (30%)
├─ Service Cost: Rp 75,000,000
├─ Platform Commission: Rp 0 (charged to agency)
├─ Amount Held: Rp 75,000,000
├─ Paid Date: 18 March 2026 10:30 AM
└─ Status: Held by platform until pelunasan paid

Remaining Payment:
├─ Pelunasan (70%): Rp 175,000,000
├─ Due Date: 8 March 2026 (H-7)
└─ Expected Transfer: After pelunasan paid

Total You Will Receive: Rp 250,000,000

[View Transaction] [View Journey Details]
```

**Pelunasan Reminder (H-10, H-7, H-3)**:
```
Subject: ⏰ Pelunasan Due Soon - Transfer Pending

A full payment is due soon from agency.

Agency: PT Berkah Travel
Journey: Paket Umroh 10 Hari Awal November
Service: Hotel Grand Makkah 5 Star

Payment Status:
├─ DP (30%): Rp 75,000,000 ✅ PAID (Held)
└─ Pelunasan (70%): Rp 175,000,000 ⏳ PENDING

Pelunasan Details:
├─ Service Cost: Rp 175,000,000
├─ Due Date: 8 March 2026 (H-7)
├─ Days Until Due: 3 days
└─ Expected Transfer: After pelunasan paid

Total You Will Receive: Rp 250,000,000

[View Details] [Contact Agency]
```

**Full Payment Received & Transferred**:
```
Subject: ✅ Payment Complete - Funds Transferred

You have received the full payment and funds have been transferred.

Agency: PT Berkah Travel
Journey: Paket Umroh 10 Hari Awal November
Service: Hotel Grand Makkah 5 Star

Payment Summary:
├─ DP (30%): Rp 75,000,000
│   ├─ Paid: 18 March 2026
│   └─ Held until pelunasan
│
└─ Pelunasan (70%): Rp 175,000,000
    ├─ Paid: 7 March 2026
    └─ Triggered transfer

Transfer Details:
├─ Total Amount: Rp 250,000,000
├─ Platform Commission: Rp 0 (charged to agency)
├─ Net Transferred: Rp 250,000,000
├─ Transfer Date: 7 March 2026 15:00 PM
├─ Transfer Reference: XEN-TRF-20260307-001
├─ Bank Account: BCA 1234567890
└─ Status: [COMPLETED] ✅

[View Statement] [Download Invoice]
```

**Payment Overdue Alert**:
```
Subject: ⚠️ Payment Overdue - Agency Not Paid

An agency payment is overdue for your service.

Agency: PT Amanah Travel
Journey: Paket Umroh Februari
Service: Hotel Madinah Premium

Payment Status:
├─ DP (30%): Rp 45,000,000 ✅ PAID (Held)
└─ Pelunasan (70%): Rp 105,000,000 🔴 OVERDUE

Overdue Details:
├─ Due Date: 1 March 2026 (H-7)
├─ Days Overdue: 6 days
├─ Grace Period: Expired
└─ Status: May be auto-cancelled

Action: Platform will auto-cancel service if payment not received within 24 hours.
DP will NOT be refunded to agency (penalty).

[Contact Agency] [Report to Platform Support]
```

---

## 🔄 PAYMENT STATE MACHINE

### Journey Activity Payment Status Flow

```
┌─────────────┐
│   UNPAID    │ ← Initial state when activity created
└──────┬──────┘
       │
       │ [Agency clicks Pay DP] (if payment terms enabled)
       │ OR [Agency clicks Pay Now] (if no payment terms)
       ↓
┌─────────────┐     ┌──────────────┐
│   DP_PAID   │────→│  FULLY_PAID  │
└──────┬──────┘     └──────────────┘
       │                    ↑
       │                    │
       │ [Agency pays       │ [Agency pays full]
       │  pelunasan         │ (no payment terms)
       │  before H-X]       │
       └────────────────────┘

Alternative path for inventory:
┌─────────────┐
│   UNPAID    │
└──────┬──────┘
       │
       │ [Service from inventory]
       ↓
┌─────────────┐
│  RESERVED   │ ← No payment needed
└─────────────┘
```

**Status Definitions**:
- `unpaid`: No payment made yet, service not locked
- `dp_paid`: DP paid, availability LOCKED, awaiting pelunasan
- `fully_paid`: All payments complete, service confirmed
- `reserved`: Using agency inventory, no payment needed

---

### Payment Record Status Flow

```
┌─────────────┐
│   PENDING   │ ← Payment link created
└──────┬──────┘
       │
       │ [Agency completes payment]
       ↓
┌─────────────┐
│ PROCESSING  │ ← Payment gateway processing
└──────┬──────┘
       │
       ├─────→ [SUCCESS] ─────→ [Supplier Transfer]
       │
       └─────→ [FAILED] ──────→ [Can retry]
       │
       └─────→ [EXPIRED] ─────→ [Can retry]
```

**Payment Status Definitions**:
- `pending`: Payment link created, awaiting agency action
- `processing`: Payment gateway processing transaction
- `success`: Payment completed successfully
- `failed`: Payment failed (can retry)
- `expired`: Payment link expired (can retry)

---

### Supplier Transfer Status Flow

```
┌─────────────┐
│   PENDING   │ ← Payment success, awaiting transfer
└──────┬──────┘
       │
       │ [For DP: Wait for pelunasan]
       │ [For Full: Transfer immediately]
       │ [For Pelunasan: Transfer both DP + Pelunasan]
       ↓
┌─────────────┐
│TRANSFERRED  │ ← Funds sent to supplier
└──────┬──────┘
       │
       └─────→ [FAILED] ──────→ [Retry transfer]
```

**Transfer Status Definitions**:
- `pending`: Awaiting transfer (DP held until pelunasan)
- `transferred`: Successfully transferred to supplier
- `failed`: Transfer failed (will retry)

---

## 📊 DATABASE QUERIES FOR TRACKING

### Agency Queries

**Query 1: Get Journey Payment Summary**
```sql
SELECT 
    j.id AS journey_id,
    j.name AS journey_name,
    j.start_date_estimated,
    COUNT(ja.id) AS total_activities,
    COUNT(CASE WHEN ja.source_type = 'supplier' THEN 1 END) AS marketplace_activities,
    COUNT(CASE WHEN ja.source_type = 'agency' THEN 1 END) AS inventory_activities,
    SUM(CASE WHEN ja.source_type = 'supplier' THEN ja.total_cost ELSE 0 END) AS total_marketplace_cost,
    SUM(CASE WHEN ja.payment_status = 'fully_paid' THEN ja.total_cost ELSE 0 END) AS total_paid,
    SUM(CASE WHEN ja.payment_status IN ('unpaid', 'dp_paid') THEN ja.total_cost ELSE 0 END) AS total_pending,
    ROUND(
        SUM(CASE WHEN ja.payment_status = 'fully_paid' THEN ja.total_cost ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN ja.source_type = 'supplier' THEN ja.total_cost ELSE 0 END), 0),
        2
    ) AS payment_progress_percentage
FROM journeys j
LEFT JOIN journey_activities ja ON ja.journey_id = j.id
WHERE j.agency_id = :agency_id
  AND j.id = :journey_id
GROUP BY j.id, j.name, j.start_date_estimated;
```

**Query 2: Get Upcoming Pelunasan Payments**
```sql
SELECT 
    ja.id AS activity_id,
    ja.full_payment_due_date,
    EXTRACT(DAY FROM ja.full_payment_due_date - CURRENT_DATE) AS days_until_due,
    j.name AS journey_name,
    j.start_date_estimated AS departure_date,
    ss.name AS service_name,
    ss.service_type,
    ja.total_cost AS service_cost,
    p_dp.agency_commission_amount AS dp_commission_paid,
    -- Calculate pelunasan amounts
    (ja.total_cost * (100 - ss.down_payment_percentage) / 100) AS pelunasan_service_cost,
    -- Get commission config for pelunasan
    (SELECT cc.agency_commission_value 
     FROM commission_configs cc 
     WHERE cc.transaction_type = 'journey_activity_payment'
       AND (cc.service_type = ss.service_type OR cc.service_type IS NULL)
       AND (cc.supplier_id = ss.supplier_id OR cc.supplier_id IS NULL)
       AND cc.is_active = true
       AND (cc.effective_from IS NULL OR cc.effective_from <= CURRENT_DATE)
       AND (cc.effective_to IS NULL OR cc.effective_to >= CURRENT_DATE)
     ORDER BY cc.priority DESC, cc.supplier_id DESC NULLS LAST, cc.service_type DESC NULLS LAST
     LIMIT 1
    ) AS commission_rate
FROM journey_activities ja
JOIN journeys j ON j.id = ja.journey_id
JOIN supplier_services ss ON ss.id = ja.supplier_service_id
LEFT JOIN payments p_dp ON p_dp.id = ja.down_payment_id
WHERE j.agency_id = :agency_id
  AND ja.payment_status = 'dp_paid'
  AND ja.full_payment_due_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days'
ORDER BY ja.full_payment_due_date ASC;
```

**Query 3: Get Agency Payment History**
```sql
SELECT 
    p.id AS payment_id,
    p.created_at AS payment_date,
    p.payment_type,
    j.name AS journey_name,
    ss.name AS service_name,
    ss.service_type,
    s.company_name AS supplier_name,
    p.service_cost,
    p.agency_commission_amount,
    p.amount_paid_by_agency,
    p.payment_method,
    p.status,
    p.paid_at,
    p.receipt_number
FROM payments p
JOIN journey_activities ja ON ja.id = p.journey_activity_id
JOIN journeys j ON j.id = p.journey_id
JOIN supplier_services ss ON ss.id = p.supplier_service_id
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.agency_id = :agency_id
  AND p.status = 'success'
ORDER BY p.paid_at DESC
LIMIT 50 OFFSET :offset;
```

---

### Supplier Queries

**Query 1: Get Supplier Revenue Summary**
```sql
SELECT 
    DATE_TRUNC('month', p.paid_at) AS month,
    COUNT(DISTINCT p.id) AS total_transactions,
    COUNT(DISTINCT p.journey_id) AS total_journeys,
    COUNT(DISTINCT p.agency_id) AS total_agencies,
    SUM(p.service_cost) AS gross_revenue,
    SUM(p.supplier_commission_amount) AS total_commission_deducted,
    SUM(p.amount_to_supplier) AS net_revenue,
    SUM(CASE WHEN p.supplier_transfer_status = 'transferred' THEN p.amount_to_supplier ELSE 0 END) AS transferred_amount,
    SUM(CASE WHEN p.supplier_transfer_status = 'pending' THEN p.amount_to_supplier ELSE 0 END) AS pending_transfer
FROM payments p
WHERE p.supplier_id = :supplier_id
  AND p.status = 'success'
  AND p.paid_at >= :start_date
  AND p.paid_at <= :end_date
GROUP BY DATE_TRUNC('month', p.paid_at)
ORDER BY month DESC;
```

**Query 2: Get Pending Pelunasan Payments**
```sql
SELECT 
    ja.id AS activity_id,
    ja.full_payment_due_date,
    EXTRACT(DAY FROM ja.full_payment_due_date - CURRENT_DATE) AS days_until_due,
    j.name AS journey_name,
    j.start_date_estimated AS departure_date,
    a.company_name AS agency_name,
    ss.name AS service_name,
    ja.total_cost AS total_service_cost,
    p_dp.service_cost AS dp_amount,
    p_dp.paid_at AS dp_paid_date,
    (ja.total_cost - p_dp.service_cost) AS pelunasan_amount,
    CASE 
        WHEN ja.full_payment_due_date < CURRENT_DATE THEN 'overdue'
        WHEN ja.full_payment_due_date <= CURRENT_DATE + INTERVAL '3 days' THEN 'urgent'
        WHEN ja.full_payment_due_date <= CURRENT_DATE + INTERVAL '7 days' THEN 'upcoming'
        ELSE 'scheduled'
    END AS urgency_level
FROM journey_activities ja
JOIN journeys j ON j.id = ja.journey_id
JOIN agencies a ON a.id = j.agency_id
JOIN supplier_services ss ON ss.id = ja.supplier_service_id
JOIN payments p_dp ON p_dp.id = ja.down_payment_id
WHERE ss.supplier_id = :supplier_id
  AND ja.payment_status = 'dp_paid'
  AND ja.full_payment_due_date IS NOT NULL
ORDER BY ja.full_payment_due_date ASC;
```

**Query 3: Get Transfer History**
```sql
SELECT 
    p.transfer_reference_number,
    p.transferred_to_supplier_at AS transfer_date,
    j.name AS journey_name,
    a.company_name AS agency_name,
    ss.name AS service_name,
    -- Group DP + Pelunasan by activity
    STRING_AGG(p.payment_type, ', ' ORDER BY p.payment_type) AS payment_types,
    SUM(p.service_cost) AS total_service_cost,
    SUM(p.supplier_commission_amount) AS total_commission_deducted,
    SUM(p.amount_to_supplier) AS total_transferred
FROM payments p
JOIN journey_activities ja ON ja.id = p.journey_activity_id
JOIN journeys j ON j.id = p.journey_id
JOIN agencies a ON a.id = p.agency_id
JOIN supplier_services ss ON ss.id = p.supplier_service_id
WHERE p.supplier_id = :supplier_id
  AND p.supplier_transfer_status = 'transferred'
  AND p.transferred_to_supplier_at >= :start_date
  AND p.transferred_to_supplier_at <= :end_date
GROUP BY 
    p.transfer_reference_number,
    p.transferred_to_supplier_at,
    j.name,
    a.company_name,
    ss.name
ORDER BY p.transferred_to_supplier_at DESC;
```

---

## 📈 REPORTING & ANALYTICS

### Agency Reports

**1. Payment Summary Report**
```
Period: March 2026

Total Journeys: 5
Total Activities: 45
├─ Marketplace: 38 activities
└─ Inventory: 7 activities

Payment Breakdown:
├─ Total Service Cost: Rp 2,500,000,000
├─ Total Platform Fees: Rp 119,000,000 (4.76% avg)
├─ Total Paid: Rp 2,619,000,000
│
├─ Paid (Fully): Rp 1,500,000,000 (60%)
├─ Paid (DP Only): Rp 450,000,000 (18%)
├─ Unpaid: Rp 550,000,000 (22%)
└─ Progress: 78% complete

Commission by Service Type:
├─ Hotel (4.76%): Rp 71,400,000
├─ Flight (5.30%): Rp 31,800,000
├─ Visa (3.49%): Rp 5,235,000
├─ Transport (4.00%): Rp 4,000,000
└─ Others: Rp 6,565,000

Payment Methods Used:
├─ Virtual Account: Rp 1,800,000,000 (69%)
├─ Credit Card: Rp 600,000,000 (23%)
├─ E-Wallet: Rp 150,000,000 (6%)
└─ QRIS: Rp 69,000,000 (2%)
```

**2. Cash Flow Forecast**
```
Next 30 Days Payment Schedule:

Week 1 (19-25 March):
├─ Pelunasan Due: Rp 350,000,000
├─ Platform Fees: Rp 16,660,000
└─ Total Outflow: Rp 366,660,000

Week 2 (26 March - 1 April):
├─ Pelunasan Due: Rp 200,000,000
├─ Platform Fees: Rp 9,520,000
└─ Total Outflow: Rp 209,520,000

Week 3 (2-8 April):
├─ New DP: Rp 150,000,000
├─ Pelunasan Due: Rp 100,000,000
├─ Platform Fees: Rp 11,900,000
└─ Total Outflow: Rp 261,900,000

Week 4 (9-15 April):
├─ New DP: Rp 200,000,000
├─ Platform Fees: Rp 9,520,000
└─ Total Outflow: Rp 209,520,000

Total 30-Day Outflow: Rp 1,047,600,000
```

---

### Supplier Reports

**1. Revenue Summary Report**
```
Period: March 2026

Total Bookings: 25 services
Total Agencies: 8 unique agencies

Revenue Breakdown:
├─ Gross Revenue: Rp 1,250,000,000
├─ Platform Commission: Rp 0 (charged to agencies)
└─ Net Revenue: Rp 1,250,000,000

Transfer Status:
├─ Transferred: Rp 800,000,000 (64%)
├─ Pending Transfer: Rp 300,000,000 (24%)
│   ├─ DP Held: Rp 180,000,000 (awaiting pelunasan)
│   └─ Pelunasan Processing: Rp 120,000,000
└─ Awaiting Payment: Rp 150,000,000 (12%)
    ├─ Unpaid: Rp 100,000,000
    └─ DP Paid (Pelunasan Pending): Rp 50,000,000

Revenue by Service Type:
├─ Hotel: Rp 750,000,000 (60%)
├─ Flight: Rp 400,000,000 (32%)
└─ Transport: Rp 100,000,000 (8%)

Top Agencies by Revenue:
1. PT Berkah Travel: Rp 450,000,000 (36%)
2. PT Hidayah Travel: Rp 300,000,000 (24%)
3. PT Amanah Travel: Rp 250,000,000 (20%)
4. Others: Rp 250,000,000 (20%)
```

**2. Payment Timeline Report**
```
Payment Aging Analysis:

Transferred (Completed):
├─ 0-7 days: Rp 400,000,000 (50%)
├─ 8-14 days: Rp 250,000,000 (31%)
└─ 15-30 days: Rp 150,000,000 (19%)

Pending Transfer (DP Held):
├─ 0-7 days: Rp 100,000,000 (33%)
├─ 8-14 days: Rp 80,000,000 (27%)
└─ 15-30 days: Rp 120,000,000 (40%)

Awaiting Payment:
├─ Due in 0-3 days: Rp 50,000,000 (33%)
├─ Due in 4-7 days: Rp 70,000,000 (47%)
└─ Due in 8-14 days: Rp 30,000,000 (20%)

Overdue:
├─ 1-3 days (grace): Rp 20,000,000
└─ 4+ days (critical): Rp 10,000,000
```

---

## 🔔 NOTIFICATION SCHEDULE

### Agency Notifications

**Payment Success Notifications**:
- Trigger: Immediately after payment success
- Channel: Email + In-app
- Content: Payment confirmation, receipt, remaining payment details

**Pelunasan Reminder Notifications**:
- H-10: "Pelunasan due in 10 days"
- H-7: "Pelunasan due in 7 days (today is deadline)"
- H-3: "Pelunasan due in 3 days - URGENT"
- H-1: "Pelunasan due tomorrow - FINAL REMINDER"

**Overdue Notifications**:
- Overdue +1 day: "Payment overdue - Grace period active"
- Overdue +2 days: "Payment overdue - Grace period ending soon"
- Overdue +3 days: "Payment overdue - Service will be cancelled in 24h"
- Overdue +4 days: "Service cancelled - DP not refunded"

---

### Supplier Notifications

**Payment Received Notifications**:
- DP Received: "DP received and held until pelunasan"
- Pelunasan Received: "Pelunasan received, transfer initiated"
- Transfer Complete: "Funds transferred to your account"

**Pelunasan Reminder Notifications**:
- H-10: "Agency pelunasan due in 10 days"
- H-7: "Agency pelunasan due today"
- H-3: "Agency pelunasan due in 3 days - Monitor status"

**Overdue Alert Notifications**:
- Overdue +1 day: "Agency payment overdue - Grace period active"
- Overdue +3 days: "Agency payment overdue - Service may be cancelled"
- Overdue +4 days: "Service cancelled - DP held by platform"

---

## 🎯 EDGE CASES & HANDLING

### Case 1: Agency Pays Pelunasan Early

**Scenario**: Agency pays pelunasan at H-20 (before H-7 due date)

**Handling**:
```
Pelunasan paid early:
├─ Update journey_activity.payment_status = "fully_paid"
├─ Trigger supplier transfer immediately
├─ Transfer both DP + Pelunasan together
└─ Supplier receives full amount early
```

**Benefit**: Supplier gets money earlier, agency shows good payment behavior

---

### Case 2: Payment Failed Multiple Times

**Scenario**: Agency tries to pay but payment fails 3 times

**Handling**:
```
Payment attempt 1: Failed
├─ Status: "failed"
├─ Allow retry
└─ Generate new payment link

Payment attempt 2: Failed
├─ Status: "failed"
├─ Allow retry
└─ Send notification to agency

Payment attempt 3: Failed
├─ Status: "failed"
├─ Allow retry
├─ Send urgent notification
└─ Suggest alternative payment method

No limit on retries - Agency can keep trying
```

**Note**: No penalty for failed payments, only penalty for overdue after grace period

---

### Case 3: Supplier Transfer Failed

**Scenario**: Platform tries to transfer to supplier but fails (bank account issue)

**Handling**:
```
Transfer attempt 1: Failed
├─ supplier_transfer_status = "failed"
├─ Log error message
├─ Retry after 1 hour
└─ Notify platform admin

Transfer attempt 2: Failed
├─ Retry after 2 hours
└─ Notify platform admin + supplier

Transfer attempt 3: Failed
├─ Mark as "failed_permanently"
├─ Notify platform admin (urgent)
├─ Manual intervention required
└─ Supplier can update bank account details
```

---

### Case 4: Journey Cancelled After DP Paid

**Scenario**: Agency cancels journey after paying DP for some activities

**Handling**:
```
Journey cancellation:
├─ Check all activities payment_status
├─ For activities with "dp_paid":
│   ├─ Initiate refund process
│   ├─ Refund amount: service_cost only (not commission)
│   ├─ Commission kept by platform (processing fee)
│   └─ Refund timeline: 7-14 business days
│
├─ For activities with "fully_paid":
│   ├─ Contact supplier for cancellation policy
│   ├─ Refund based on supplier policy
│   └─ May have cancellation fee
│
└─ Update journey.status = "cancelled"
```

**Note**: Refund policy skipped for now (too complex)

---

## 💡 KEY INSIGHTS & RECOMMENDATIONS

### For Agency

**Cash Flow Management**:
- DP paid immediately locks availability (secure booking)
- Pelunasan due at H-7 (pay closer to departure)
- Can see all upcoming payments in dashboard
- Plan cash flow based on departure dates

**Cost Transparency**:
- Platform fees shown separately (not hidden in price)
- Commission rates vary by service type (4.76% - 5.30%)
- Can calculate total cost before payment
- Receipt and invoice available for accounting

**Payment Flexibility**:
- Unlimited retry for failed payments
- Multiple payment methods (VA, CC, E-Wallet, QRIS)
- Can pay pelunasan early (no penalty)
- Grace period for overdue (3 days)

---

### For Supplier

**Revenue Predictability**:
- DP received early (locks booking)
- Full payment guaranteed at H-7
- Transfer after pelunasan paid (both DP + Pelunasan together)
- Clear payment timeline

**Commission Transparency**:
- Commission charged to agency (not deducted from supplier)
- Supplier receives full service cost
- Can see commission rates in platform
- No surprise deductions

**Risk Mitigation**:
- DP held by platform until pelunasan (protection)
- Overdue payments flagged automatically
- Can contact agency directly
- Platform support for disputes

---

### For Platform Admin

**Revenue Tracking**:
- Commission collected from agency (transparent)
- Different rates per service type (flexible)
- Can charge supplier or both if needed (Gojek model)
- Priority-based config selection (supplier-specific > service-specific > global)

**Operational Efficiency**:
- Automated transfer to suppliers (background job)
- Automated overdue handling (grace period + auto-cancel)
- Automated notifications (reminders, alerts)
- Comprehensive reporting (revenue, transfers, overdue)

**Flexibility**:
- Can create supplier-specific commission rates
- Can adjust rates per service type
- Can change charged_to (agency/supplier/both)
- Priority system for complex scenarios

---

## 🎯 IMPLEMENTATION CHECKLIST

### Backend Tasks

**Database**:
- [ ] Enhance commission_configs table (add service_type, supplier_id, charged_to, priority)
- [ ] Create payments table (with commission tracking)
- [ ] Update journey_activities table (add payment tracking fields)
- [ ] Update commission_transactions table (add supplier_id, split commissions)
- [ ] Drop journey_services table (deprecated)

**Entities**:
- [ ] Update CommissionConfig entity
- [ ] Create Payment entity
- [ ] Update JourneyActivity entity (add payment fields)
- [ ] Update CommissionTransaction entity

**Services**:
- [ ] CommissionService (get applicable config, calculate commission)
- [ ] PaymentService (create payment, process webhook)
- [ ] SupplierTransferService (background job, transfer logic)
- [ ] XenditService (invoice creation, webhook verification, disbursement)

**API Endpoints**:
- [ ] POST /api/journeys/{id}/activities/{id}/payment (create payment)
- [ ] POST /api/payments/webhook/xendit (webhook handler)
- [ ] GET /api/payments/{id} (get payment details)
- [ ] GET /api/payments/{id}/receipt (download receipt)
- [ ] GET /api/agency/payments/dashboard (agency dashboard data)
- [ ] GET /api/agency/payments/upcoming (upcoming pelunasan)
- [ ] GET /api/agency/payments/history (payment history)
- [ ] GET /api/supplier/revenue/dashboard (supplier dashboard data)
- [ ] GET /api/supplier/revenue/transactions (transaction history)
- [ ] GET /api/supplier/revenue/pending (pending payments)

**Background Jobs**:
- [ ] SupplierTransferJob (hourly - transfer funds to suppliers)
- [ ] PelunasanReminderJob (daily - send reminders at H-10, H-7, H-3)
- [ ] OverduePaymentJob (daily - check overdue, send alerts, auto-cancel)

---

### Frontend Tasks

**Components**:
- [ ] PaymentDialog component (show breakdown, select method)
- [ ] PaymentStatusBadge component (unpaid, dp_paid, fully_paid, reserved)
- [ ] PaymentBreakdown component (service cost + commission)
- [ ] AgencyPaymentDashboard page
- [ ] AgencyPaymentHistory page
- [ ] AgencyUpcomingPayments page
- [ ] SupplierRevenueDashboard page
- [ ] SupplierTransactionHistory page
- [ ] SupplierPendingPayments page

**Journey Detail Enhancements**:
- [ ] Show payment status per activity
- [ ] Show payment breakdown (DP + Pelunasan)
- [ ] Show due dates for pelunasan
- [ ] Add [Pay Now] buttons
- [ ] Add [View Receipt] links

**Notifications**:
- [ ] Payment success toast
- [ ] Pelunasan reminder notifications
- [ ] Overdue payment alerts
- [ ] Transfer complete notifications (supplier)

---

## 📋 SUMMARY

**Payment Flow**: ✅ FINALIZED
- Agency pays DP immediately → Locks availability
- Agency pays pelunasan before H-X → Service confirmed
- Platform holds DP until pelunasan paid
- Platform transfers both DP + Pelunasan together to supplier

**Commission System**: ✅ FINALIZED
- Flexible: Different rates per service type
- Support percentage AND fixed amount
- Can charge agency, supplier, or both
- Priority-based selection (supplier-specific > service-specific > global)
- Default rates: Hotel 4.76%, Flight 5.30%, Visa 3.49%

**Tracking**: ✅ COMPREHENSIVE
- Agency: Dashboard, upcoming payments, history
- Supplier: Revenue dashboard, transactions, pending payments
- Platform: Commission reports, transfer monitoring

**Status**: ✅ **READY FOR IMPLEMENTATION**

---

**Document Created**: 18 March 2026  
**Last Updated**: 18 March 2026  
**Status**: FINALIZED - Ready for development

