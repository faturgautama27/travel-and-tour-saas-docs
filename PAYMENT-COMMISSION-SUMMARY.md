# Payment & Commission System - Executive Summary

**Project**: Tour & Travel ERP SaaS  
**Date**: 18 March 2026  
**Status**: FINALIZED - Ready for Implementation

---

## 🎯 CORE DECISIONS (Based on Pak Habibi's Requirements)

### 1. Commission Flexibility ✅

**Requirement**: "Commission fee harus di bikin se fleksibel mungkin dari platform admin"

**Solution**: Enhanced CommissionConfig with:
- Different rates per service type (hotel, flight, visa, etc.)
- Different rates per supplier (supplier-specific overrides)
- Support percentage AND fixed amount
- Can charge agency, supplier, or BOTH (Gojek model)
- Priority-based selection (highest priority + most specific wins)

**Default Rates** (from Pak Habibi's data):
```
Hotel: 4.76% (margin 20 riyal out of 420 riyal)
Flight: 5.30% (margin IDR 700k out of IDR 13.2M)
Visa: 3.49% (margin $5 out of $143)
Transport: 4.00%
Guide: 5.00%
Insurance: 3.50%
Catering: 4.50%
Handling: 5.00%
```

---

### 2. Payment Timing ✅

**Requirement**: "DP atau full pelunasan itu nanti mempengaruhi di dialog payment di sisi agency nya"

**Solution**: Immediate payment when service selected

**With Payment Terms** (DP + Pelunasan):
```
Agency selects service
    ↓
Click [Pay DP Now]
    ↓
DP paid IMMEDIATELY via payment gateway
    ↓
Availability LOCKED for this agency
    ↓
Status: "dp_paid"
    ↓
Pelunasan due date calculated: departure_date - full_payment_due_days
    ↓
Agency pays pelunasan before H-X
    ↓
Status: "fully_paid"
```

**Without Payment Terms** (Full Payment):
```
Agency selects service
    ↓
Click [Pay Now]
    ↓
Full payment IMMEDIATELY via payment gateway
    ↓
Status: "fully_paid"
```

**Key Point**: NO DownPaymentDueDays - DP always paid immediately when booking

---

### 3. Journey Services Deprecation ✅

**Requirement**: "journey service tracking itu sudah sepenuhnya tidak digunakan lagi"

**Solution**: Use ONLY journey_activities table

**OLD Design** (Phase 1 spec):
```
Package → Journey → journey_services (operational tracking)
```

**NEW Design** (Unified):
```
Journey → journey_activities (itinerary + payment + operational tracking)
```

**Migration**:
```sql
DROP TABLE IF EXISTS journey_services CASCADE;
DROP TABLE IF EXISTS packages CASCADE;
DROP TABLE IF EXISTS package_services CASCADE;
```

**Benefits**:
- Single source of truth
- No data duplication
- Simpler data model
- journey_activities handles everything: itinerary, payment, tracking

---

### 4. Commission from commission_configs ✅

**Requirement**: "commission ke platform itu harusnya kamu cek dari table commission_configs ya"

**Solution**: Dynamic commission lookup with priority-based selection

**Enhanced CommissionConfig Schema**:
```sql
ALTER TABLE commission_configs
ADD COLUMN service_type VARCHAR(50),        -- hotel, flight, visa, etc.
ADD COLUMN supplier_id UUID,                -- Specific supplier or NULL
ADD COLUMN charged_to VARCHAR(20),          -- agency, supplier, both
ADD COLUMN agency_commission_type VARCHAR(20),
ADD COLUMN agency_commission_value DECIMAL(18,2),
ADD COLUMN supplier_commission_type VARCHAR(20),
ADD COLUMN supplier_commission_value DECIMAL(18,2),
ADD COLUMN priority INT;                    -- Higher = applied first
```

**Selection Algorithm**:
```
1. Get all active configs for transaction_type = "journey_activity_payment"
2. Filter by service_type match (or NULL for all)
3. Filter by supplier_id match (or NULL for all)
4. Sort by priority DESC
5. Return highest priority match
```

**Example Configs**:
```
Priority 20: Hotel + Supplier ABC → 3% agency + 2% supplier (most specific)
Priority 10: Hotel + All suppliers → 4.76% agency (service-specific)
Priority 5: All types + All suppliers → 5% agency (global default)
```

---

## 💰 PAYMENT TRACKING - BOTH PERSPECTIVES

### Agency Perspective

**What Agency Sees**:
```
Journey Detail Page:
├─ Activity payment status (unpaid, dp_paid, fully_paid, reserved)
├─ Payment breakdown (service cost + platform fee)
├─ Due dates for pelunasan
├─ [Pay Now] buttons
└─ [View Receipt] links

Payment Dashboard:
├─ Total paid vs pending
├─ Upcoming pelunasan (next 7/30 days)
├─ Payment history
└─ Cash flow forecast

Notifications:
├─ Payment success confirmation
├─ Pelunasan reminders (H-10, H-7, H-3)
├─ Overdue alerts
└─ Grace period warnings
```

**Agency Payment Flow**:
```
1. Select marketplace service in journey
2. Click [Pay DP] or [Pay Now]
3. See payment breakdown:
   ├─ Service Cost: Rp 75,000,000
   ├─ Platform Fee: Rp 3,570,000 (4.76%)
   └─ Total: Rp 78,570,000
4. Choose payment method (VA, CC, E-Wallet, QRIS)
5. Complete payment on gateway
6. Receive confirmation + receipt
7. For DP: Track pelunasan due date
8. Pay pelunasan before H-X
9. Service fully paid and confirmed
```

---

### Supplier Perspective

**What Supplier Sees**:
```
Revenue Dashboard:
├─ Total bookings and gross revenue
├─ Platform commission (if charged to supplier)
├─ Net revenue
├─ Transfer status (transferred, pending, awaiting)
└─ Revenue by service type

Transaction History:
├─ DP payments (held until pelunasan)
├─ Pelunasan payments (triggers transfer)
├─ Full payments (transferred immediately)
├─ Transfer references
└─ Bank account details

Pending Payments:
├─ DP paid (awaiting pelunasan)
├─ Unpaid (awaiting agency payment)
├─ Overdue (past H-7)
└─ Expected transfer dates

Notifications:
├─ DP received (held)
├─ Pelunasan received (transfer initiated)
├─ Transfer complete
├─ Pelunasan reminders
└─ Overdue alerts
```

**Supplier Payment Flow**:
```
1. Agency selects supplier's service
2. Agency pays DP → Supplier notified "DP received and held"
3. Platform holds DP in escrow
4. Agency pays pelunasan → Supplier notified "Pelunasan received"
5. Platform transfers BOTH DP + Pelunasan together
6. Supplier receives full amount
7. Supplier sees transfer reference and bank details
```

---

## 🔄 COMPLETE MONEY FLOW

### Example: Hotel Service with DP + Pelunasan

**Service**: Hotel Grand Makkah 5 Star  
**Total Cost**: Rp 250,000,000  
**Payment Terms**: DP 30% + Pelunasan 70%  
**Commission**: 4.76% from agency

---

**STEP 1: Agency Pays DP (Immediately)**
```
Agency clicks [Pay DP Now]
    ↓
Payment Gateway (Xendit)
    ↓
Agency pays: Rp 78,570,000
├─ Service Cost: Rp 75,000,000
└─ Platform Fee: Rp 3,570,000 (4.76%)
    ↓
Platform receives: Rp 78,570,000
├─ Hold service cost: Rp 75,000,000 (for supplier)
└─ Keep commission: Rp 3,570,000
    ↓
Status Updates:
├─ journey_activity.payment_status = "dp_paid"
├─ payment.status = "success"
├─ payment.supplier_transfer_status = "pending" (HOLD)
└─ Availability LOCKED
```

**Money Position After DP**:
- Agency: Paid Rp 78,570,000 ✅
- Platform: Holds Rp 75,000,000 + Earned Rp 3,570,000
- Supplier: Awaiting transfer (Rp 75,000,000 held)

---

**STEP 2: Agency Pays Pelunasan (Before H-7)**
```
Agency clicks [Pay Pelunasan]
    ↓
Payment Gateway (Xendit)
    ↓
Agency pays: Rp 183,330,000
├─ Service Cost: Rp 175,000,000
└─ Platform Fee: Rp 8,330,000 (4.76%)
    ↓
Platform receives: Rp 183,330,000
├─ Hold service cost: Rp 175,000,000 (for supplier)
└─ Keep commission: Rp 8,330,000
    ↓
Status Updates:
├─ journey_activity.payment_status = "fully_paid"
├─ payment.status = "success"
└─ payment.supplier_transfer_status = "pending" (TRIGGER TRANSFER)
```

**Money Position After Pelunasan**:
- Agency: Paid total Rp 261,900,000 ✅
- Platform: Holds Rp 250,000,000 + Earned Rp 11,900,000
- Supplier: Awaiting transfer (Rp 250,000,000 ready)

---

**STEP 3: Platform Transfers to Supplier (Background Job)**
```
Background Job detects:
├─ journey_activity_id has 2 payments
├─ Both payments status = "success"
├─ Both supplier_transfer_status = "pending"
└─ Pelunasan just paid → TRIGGER TRANSFER
    ↓
Calculate total to supplier:
├─ DP: Rp 75,000,000
├─ Pelunasan: Rp 175,000,000
└─ Total: Rp 250,000,000
    ↓
Call Xendit Disbursement API:
├─ Recipient: Supplier bank account
├─ Amount: Rp 250,000,000
└─ Reference: XEN-TRF-20260307-001
    ↓
Update both payments:
├─ supplier_transfer_status = "transferred"
├─ transferred_to_supplier_at = now
└─ transfer_reference_number = "XEN-TRF-20260307-001"
    ↓
Send notifications:
├─ To Supplier: "Funds transferred Rp 250,000,000"
└─ To Agency: "Payment complete, supplier paid"
```

**Final Money Position**:
- Agency: Paid total Rp 261,900,000 ✅
- Platform: Earned Rp 11,900,000 ✅
- Supplier: Received Rp 250,000,000 ✅

---

## 📊 TRACKING SUMMARY

### Agency Tracking Points

**Journey Level**:
- Total activities
- Total marketplace cost
- Total platform fees
- Payment progress percentage
- Upcoming pelunasan due dates

**Activity Level**:
- Payment status (unpaid, dp_paid, fully_paid, reserved)
- DP amount + commission
- Pelunasan amount + commission
- Due dates
- Payment receipts

**Dashboard Metrics**:
- Total paid vs pending
- Upcoming payments (next 7/30 days)
- Payment history
- Cash flow forecast

---

### Supplier Tracking Points

**Revenue Level**:
- Total bookings
- Gross revenue
- Platform commission deducted (if any)
- Net revenue
- Transfer status breakdown

**Transaction Level**:
- DP payments (held until pelunasan)
- Pelunasan payments (triggers transfer)
- Full payments (transferred immediately)
- Transfer references
- Transfer dates

**Dashboard Metrics**:
- Transferred amount
- Pending transfer (DP held)
- Awaiting payment (unpaid + dp_paid)
- Revenue by service type
- Top agencies by revenue

---

## 🗄️ DATABASE SCHEMA SUMMARY

### Key Tables

**1. commission_configs** (ENHANCED)
```sql
Key Fields:
├─ service_type VARCHAR(50)           -- hotel, flight, visa, etc.
├─ supplier_id UUID                   -- Specific supplier or NULL
├─ charged_to VARCHAR(20)             -- agency, supplier, both
├─ agency_commission_type VARCHAR(20) -- percentage, fixed
├─ agency_commission_value DECIMAL
├─ supplier_commission_type VARCHAR(20)
├─ supplier_commission_value DECIMAL
└─ priority INT                       -- Higher = applied first
```

**2. payments** (NEW)
```sql
Key Fields:
├─ agency_id, supplier_id, journey_id, journey_activity_id
├─ payment_type                       -- down_payment, full_payment
├─ service_cost DECIMAL
├─ agency_commission_amount DECIMAL
├─ supplier_commission_amount DECIMAL
├─ amount_paid_by_agency DECIMAL      -- service_cost + agency_commission
├─ amount_to_supplier DECIMAL         -- service_cost - supplier_commission
├─ status                             -- pending, success, failed, expired
├─ supplier_transfer_status           -- pending, transferred, failed
└─ transferred_to_supplier_at
```

**3. journey_activities** (UPDATED)
```sql
Key Fields:
├─ payment_status                     -- unpaid, dp_paid, fully_paid, reserved
├─ down_payment_id UUID
├─ full_payment_id UUID
├─ down_payment_paid_at
├─ full_payment_paid_at
└─ full_payment_due_date              -- Calculated: departure - full_payment_due_days
```

**4. commission_transactions** (UPDATED)
```sql
Key Fields:
├─ transaction_type                   -- journey_activity_payment
├─ reference_id                       -- payment_id
├─ agency_id, supplier_id
├─ base_amount                        -- Service cost
├─ agency_commission_amount
├─ supplier_commission_amount
└─ total_commission_amount
```

---

## 🎯 IMPLEMENTATION PRIORITIES

### Phase 1: Core Payment System (Week 1-2)

**Database**:
1. Enhance commission_configs table
2. Create payments table
3. Update journey_activities table
4. Drop journey_services table

**Backend**:
1. CommissionService (get config, calculate commission)
2. PaymentService (create payment, calculate amounts)
3. XenditService (invoice creation, webhook handling)
4. Payment entity and DTOs

**Frontend**:
1. PaymentDialog component
2. Journey Detail payment status display
3. Payment success/failure handling

---

### Phase 2: Supplier Transfer System (Week 3)

**Backend**:
1. SupplierTransferService (transfer logic)
2. Background job (hourly transfer check)
3. Xendit disbursement integration
4. Transfer status tracking

**Frontend**:
1. Supplier revenue dashboard
2. Supplier transaction history
3. Supplier pending payments page

---

### Phase 3: Tracking & Reporting (Week 4)

**Backend**:
1. Payment tracking queries
2. Revenue calculation queries
3. Commission reporting queries

**Frontend**:
1. Agency payment dashboard
2. Agency upcoming payments
3. Agency payment history
4. Platform admin commission management
5. Platform admin revenue reports

---

### Phase 4: Notifications & Automation (Week 5)

**Backend**:
1. PelunasanReminderJob (daily)
2. OverduePaymentJob (daily)
3. Email notification templates
4. In-app notification system

**Frontend**:
1. Notification center
2. Payment reminders
3. Overdue alerts

---

## 📋 ANSWERS TO USER QUESTIONS

### Q1: "Gimana cara tracking dari sisi agency?"

**Answer**: Agency tracks payments through:

**Journey Detail Page**:
- See payment status per activity (unpaid, dp_paid, fully_paid)
- See payment breakdown (service cost + platform fee)
- See due dates for pelunasan
- Click [Pay Now] to make payment
- Click [View Receipt] to download receipt

**Payment Dashboard** (`/agency/payments/dashboard`):
- Overview: Total paid vs pending, progress percentage
- Upcoming payments: Pelunasan due in next 7/30 days
- Payment history: All completed payments with receipts
- Cash flow forecast: Upcoming payment schedule

**Database Tracking**:
- `journey_activities.payment_status` - Current payment status
- `payments` table - All payment records with commission breakdown
- `commission_transactions` table - Commission tracking

---

### Q2: "Gimana cara tracking dari sisi supplier?"

**Answer**: Supplier tracks payments through:

**Revenue Dashboard** (`/supplier/revenue/dashboard`):
- Overview: Total bookings, gross revenue, net revenue
- Transfer status: Transferred, pending transfer, awaiting payment
- Revenue by service type
- Top agencies by revenue

**Transaction History** (`/supplier/revenue/transactions`):
- All completed transfers with references
- DP + Pelunasan grouped by activity
- Transfer dates and bank details
- Downloadable statements

**Pending Payments** (`/supplier/revenue/pending`):
- DP paid (awaiting pelunasan) - Shows expected transfer date
- Unpaid (awaiting agency payment) - Shows due dates
- Overdue (past H-7) - Shows days overdue
- Contact agency feature

**Database Tracking**:
- `payments` table filtered by `supplier_id`
- `payments.supplier_transfer_status` - Transfer status
- `payments.transferred_to_supplier_at` - Transfer date
- `commission_transactions` table - Commission deducted (if any)

---

### Q3: "Commission harus se fleksibel mungkin"

**Answer**: Commission system is VERY flexible:

**Flexibility Features**:
1. **Different rates per service type**:
   - Hotel: 4.76%
   - Flight: 5.30%
   - Visa: 3.49%
   - Can configure any rate for any type

2. **Support percentage AND fixed amount**:
   - Percentage: 5% of transaction
   - Fixed: Rp 50,000 flat fee
   - Can mix (agency percentage + supplier fixed)

3. **Can charge agency, supplier, or BOTH**:
   - Agency only: Agency pays commission
   - Supplier only: Deducted from supplier
   - Both: Charge both parties (Gojek model)

4. **Supplier-specific rates**:
   - Create config for specific supplier
   - Higher priority overrides general config
   - Example: Premium supplier gets 3% instead of 4.76%

5. **Priority-based selection**:
   - Priority 20: Supplier ABC + Hotel → 3% agency + 2% supplier
   - Priority 10: All suppliers + Hotel → 4.76% agency
   - Priority 5: All suppliers + All types → 5% agency
   - System picks highest priority + most specific match

**Platform Admin Control**:
- Create unlimited commission configs
- Activate/deactivate configs
- Set effective date ranges
- View commission reports
- Adjust rates anytime

---

## 🎯 KEY BENEFITS

### For Agency

**Transparency**:
- See exact commission amount before payment
- No hidden fees
- Clear breakdown (service cost + platform fee)

**Flexibility**:
- DP locks availability immediately
- Pelunasan due at H-7 (better cash flow)
- Can pay pelunasan early (no penalty)
- Unlimited retry for failed payments

**Control**:
- Dashboard shows all upcoming payments
- Reminders before due dates
- Grace period for overdue (3 days)
- Can track payment history

---

### For Supplier

**Predictability**:
- DP received early (booking secured)
- Full payment guaranteed at H-7
- Transfer after pelunasan paid
- Clear payment timeline

**Transparency**:
- See commission rates (if charged to supplier)
- See transfer amounts
- See transfer references
- Downloadable statements

**Protection**:
- DP held until pelunasan (platform escrow)
- Overdue payments flagged
- Can contact agency
- Platform support for disputes

---

### For Platform

**Revenue**:
- Commission collected automatically
- Different rates per service type
- Can charge agency, supplier, or both
- Flexible pricing strategy

**Automation**:
- Auto-calculate commission
- Auto-transfer to suppliers
- Auto-send notifications
- Auto-handle overdue

**Reporting**:
- Revenue by service type
- Revenue by agency/supplier
- Commission trends
- Transfer monitoring

---

## 📚 RELATED DOCUMENTS

**Detailed Analysis**:
- `PAYMENT-TRACKING-COMPREHENSIVE.md` - Complete payment tracking with dashboards, queries, notifications
- `COMPLETE-JOURNEY-TO-BOOKING-FLOW.md` - Full flow from journey creation to booking
- `SUPPLIER-SERVICE-MANAGEMENT-REQUIREMENTS.md` - Service features including payment terms
- `JOURNEY-REFACTOR-REQUIREMENTS.md` - Journey system refactor design

---

## ✅ STATUS

**All Requirements**: FINALIZED  
**All Decisions**: MADE  
**All Questions**: ANSWERED  
**Status**: ✅ **READY FOR IMPLEMENTATION**

**Next Action**: Begin Phase 1 implementation (Database schema updates)

---

**Document Created**: 18 March 2026  
**Last Updated**: 18 March 2026  
**Author**: System Analysis based on Pak Habibi's requirements

