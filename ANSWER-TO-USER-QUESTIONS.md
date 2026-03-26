# Jawaban Pertanyaan User - Payment Tracking

**Date**: 18 March 2026  
**Status**: FINALIZED

---

## ❓ PERTANYAAN USER

> "lanjutkan dulu, aku ingin tau plan kamu terkait pembayaran ini nanti gimana cara tracking dari sisi agency dan suppliernya juga."

Dan dari WhatsApp Pak Habibi:
- Commission fee harus se fleksibel mungkin
- Beda komponen bisa beda commission fee (baik fixed maupun percentage)
- Bisa charge ke agency, supplier, atau kedua pihak (model Gojek)
- Margin berbeda per service type: Hotel 4.76%, Flight 5.30%, Visa 3.49%

---

## ✅ JAWABAN LENGKAP

### 1. TRACKING DARI SISI AGENCY

**Dashboard Utama** (`/agency/payments/dashboard`):
```
Menampilkan:
├─ Total journey dan activities
├─ Total service cost vs platform fees
├─ Payment progress (paid vs pending)
├─ Upcoming pelunasan (7/30 hari ke depan)
└─ Payment history
```

**Journey Detail Page**:
```
Setiap activity menampilkan:
├─ Payment status badge (unpaid, dp_paid, fully_paid, reserved)
├─ Payment breakdown:
│   ├─ Service cost
│   ├─ Platform fee (dengan persentase)
│   └─ Total yang harus dibayar
├─ Due date untuk pelunasan
├─ Button [Pay Now] atau [Pay Pelunasan]
└─ Link [View Receipt] untuk yang sudah dibayar
```

**Upcoming Payments Page**:
```
List semua pelunasan yang akan jatuh tempo:
├─ Sorted by due date (paling urgent di atas)
├─ Color coding: Red (overdue), Orange (<3 days), Yellow (<7 days)
├─ Menampilkan:
│   ├─ Journey name
│   ├─ Service name
│   ├─ DP status (sudah dibayar kapan)
│   ├─ Pelunasan amount + commission
│   ├─ Due date
│   └─ Days until due
└─ Quick action [Pay Now]
```

**Payment History**:
```
List semua payment yang sudah dilakukan:
├─ Payment date
├─ Journey dan activity
├─ Service name dan supplier
├─ Service cost + platform fee
├─ Total paid
├─ Payment method
├─ Status
└─ Actions: [View Receipt] [Download Invoice]
```

**Database Tracking**:
```sql
-- Check payment status per activity
SELECT payment_status FROM journey_activities WHERE id = :activity_id;

-- Get all payments for a journey
SELECT * FROM payments WHERE journey_id = :journey_id;

-- Get upcoming pelunasan
SELECT * FROM journey_activities 
WHERE payment_status = 'dp_paid' 
  AND full_payment_due_date BETWEEN NOW() AND NOW() + INTERVAL '30 days';
```

---

### 2. TRACKING DARI SISI SUPPLIER

**Revenue Dashboard** (`/supplier/revenue/dashboard`):
```
Menampilkan:
├─ Total bookings (jumlah services yang di-book)
├─ Gross revenue (total service cost)
├─ Platform commission deducted (jika charged to supplier)
├─ Net revenue (yang diterima supplier)
├─ Transfer status breakdown:
│   ├─ Transferred (sudah diterima)
│   ├─ Pending transfer (DP held, awaiting pelunasan)
│   └─ Awaiting payment (belum dibayar agency)
└─ Revenue by service type
```

**Transaction History** (`/supplier/revenue/transactions`):
```
List semua transfer yang sudah diterima:
├─ Transfer date
├─ Transfer reference number
├─ Agency name
├─ Journey name
├─ Service name
├─ Payment breakdown:
│   ├─ DP amount (jika ada)
│   ├─ Pelunasan amount (jika ada)
│   ├─ Total service cost
│   ├─ Commission deducted (jika ada)
│   └─ Net transferred
├─ Bank account
└─ Actions: [View Details] [Download Statement]
```

**Pending Payments** (`/supplier/revenue/pending`):
```
List semua payment yang belum diterima:

Section 1: DP Paid (Awaiting Pelunasan)
├─ Journey dan agency name
├─ Service name
├─ DP amount (sudah dibayar, held by platform)
├─ DP paid date
├─ Pelunasan amount (belum dibayar)
├─ Pelunasan due date
├─ Days until due
├─ Expected transfer: After pelunasan paid
└─ Actions: [View Details] [Contact Agency]

Section 2: Unpaid (Awaiting Agency Payment)
├─ Journey dan agency name
├─ Service name
├─ Total service cost
├─ Payment type (DP or Full)
├─ Status: Unpaid
└─ Actions: [Contact Agency]

Section 3: Overdue (Past H-7)
├─ Journey dan agency name
├─ Service name
├─ Payment details
├─ Due date
├─ Days overdue
├─ Grace period status
└─ Actions: [Contact Agency] [Report to Platform]
```

**Database Tracking**:
```sql
-- Check all payments for supplier
SELECT * FROM payments WHERE supplier_id = :supplier_id;

-- Get pending transfers (DP held)
SELECT * FROM payments 
WHERE supplier_id = :supplier_id 
  AND status = 'success'
  AND supplier_transfer_status = 'pending';

-- Get transferred amounts
SELECT * FROM payments 
WHERE supplier_id = :supplier_id 
  AND supplier_transfer_status = 'transferred';

-- Get pending pelunasan
SELECT ja.* FROM journey_activities ja
JOIN supplier_services ss ON ss.id = ja.supplier_service_id
WHERE ss.supplier_id = :supplier_id
  AND ja.payment_status = 'dp_paid';
```

---

### 3. COMMISSION FLEXIBILITY (Sesuai Pak Habibi)

**Requirement**: "Commission fee harus di bikin se fleksibel mungkin"

**Solution**: Enhanced CommissionConfig dengan fitur:

**A. Different Rates per Service Type** ✅
```
Config 1: Hotel → 4.76%
Config 2: Flight → 5.30%
Config 3: Visa → 3.49%
Config 4: Transport → 4.00%
... dst
```

**B. Support Percentage AND Fixed Amount** ✅
```
Config 1: Hotel → 4.76% percentage
Config 2: Small transactions → Rp 50,000 fixed
Config 3: Premium supplier → 3% percentage + Rp 100,000 fixed
```

**C. Can Charge Agency, Supplier, or BOTH** ✅
```
Model 1: Charge Agency Only
├─ Agency pays: Service cost + Commission
├─ Supplier receives: Service cost
└─ Platform earns: Commission

Model 2: Charge Supplier Only
├─ Agency pays: Service cost
├─ Supplier receives: Service cost - Commission
└─ Platform earns: Commission

Model 3: Charge Both (Gojek Model)
├─ Agency pays: Service cost + Agency commission
├─ Supplier receives: Service cost - Supplier commission
└─ Platform earns: Agency commission + Supplier commission
```

**D. Supplier-Specific Rates** ✅
```
Priority 20: Supplier ABC + Hotel → 3% agency + 2% supplier (override)
Priority 10: All suppliers + Hotel → 4.76% agency (default)

System picks Priority 20 for Supplier ABC
System picks Priority 10 for other suppliers
```

**E. Platform Admin Control** ✅
```
Platform admin dapat:
├─ Create unlimited commission configs
├─ Set priority (higher = applied first)
├─ Set effective date range
├─ Activate/deactivate configs
├─ View commission reports
└─ Adjust rates kapan saja
```

---

## 💡 CONTOH KONKRET

### Contoh 1: Hotel dengan DP + Pelunasan

**Service**: Hotel Grand Makkah 5 Star  
**Total**: Rp 250,000,000  
**Payment Terms**: DP 30% + Pelunasan 70%  
**Commission**: 4.76% dari agency

**Timeline**:
```
18 Maret 2026 - Agency Bayar DP:
├─ Service cost: Rp 75,000,000
├─ Platform fee: Rp 3,570,000 (4.76%)
├─ Total dibayar agency: Rp 78,570,000
├─ Platform hold: Rp 75,000,000 (untuk supplier)
├─ Platform earn: Rp 3,570,000
└─ Status: "dp_paid" ✅

7 Maret 2026 - Agency Bayar Pelunasan (H-7):
├─ Service cost: Rp 175,000,000
├─ Platform fee: Rp 8,330,000 (4.76%)
├─ Total dibayar agency: Rp 183,330,000
├─ Platform hold: Rp 175,000,000 (untuk supplier)
├─ Platform earn: Rp 8,330,000
└─ Status: "fully_paid" ✅

7 Maret 2026 - Platform Transfer ke Supplier:
├─ DP: Rp 75,000,000
├─ Pelunasan: Rp 175,000,000
├─ Total transfer: Rp 250,000,000
├─ Transfer reference: XEN-TRF-20260307-001
└─ Supplier receives: Rp 250,000,000 ✅
```

**Tracking**:
- Agency: Lihat di dashboard "Paid Rp 261,900,000" (service + fees)
- Supplier: Lihat di dashboard "Received Rp 250,000,000" (full service cost)
- Platform: Earned Rp 11,900,000 commission

---

### Contoh 2: Flight tanpa DP (Full Payment)

**Service**: Garuda Indonesia Business CGK-JED  
**Total**: Rp 300,000,000  
**Payment Terms**: Full payment immediately  
**Commission**: 5.30% dari agency

**Timeline**:
```
18 Maret 2026 - Agency Bayar Full:
├─ Service cost: Rp 300,000,000
├─ Platform fee: Rp 15,900,000 (5.30%)
├─ Total dibayar agency: Rp 315,900,000
├─ Platform hold: Rp 300,000,000 (untuk supplier)
├─ Platform earn: Rp 15,900,000
└─ Status: "fully_paid" ✅

18 Maret 2026 - Platform Transfer ke Supplier (Immediately):
├─ Total transfer: Rp 300,000,000
├─ Transfer reference: XEN-TRF-20260318-002
└─ Supplier receives: Rp 300,000,000 ✅
```

**Tracking**:
- Agency: Lihat "Paid Rp 315,900,000" (service + fee)
- Supplier: Lihat "Received Rp 300,000,000" (full service cost)
- Platform: Earned Rp 15,900,000 commission

---

### Contoh 3: Guide dari Inventory (No Payment)

**Service**: Arabic-English Guide  
**Source**: Agency inventory  
**Total**: Rp 10,000,000

**Timeline**:
```
18 Maret 2026 - Agency Pilih dari Inventory:
├─ No payment needed
├─ Quota reserved from inventory
└─ Status: "reserved" ✅
```

**Tracking**:
- Agency: Lihat "Reserved from inventory" (no payment)
- Supplier: N/A (agency's own service)
- Platform: No commission (internal inventory)

---

## 📱 NOTIFIKASI SYSTEM

### Agency Notifications

**Payment Success**:
```
✅ Payment Successful - Down Payment

Journey: Paket Umroh 10 Hari
Service: Hotel Grand Makkah
Total Paid: Rp 78,570,000

Remaining: Rp 183,330,000 (due 8 March 2026)
```

**Pelunasan Reminder**:
```
⏰ Payment Reminder - Due in 3 Days

Journey: Paket Umroh 10 Hari
Service: Hotel Grand Makkah
Amount: Rp 183,330,000
Due: 8 March 2026

[Pay Now]
```

**Overdue Alert**:
```
🔴 Payment Overdue - Service May Be Cancelled

Journey: Paket Umroh 10 Hari
Amount: Rp 183,330,000
Overdue: 4 days

Warning: Service will be cancelled in 24h
DP will NOT be refunded

[Pay Now Urgently]
```

---

### Supplier Notifications

**DP Received**:
```
💰 Payment Received - Down Payment

Agency: PT Berkah Travel
Service: Hotel Grand Makkah
Amount Held: Rp 75,000,000

Status: Held until pelunasan paid
Expected Transfer: After pelunasan (due 8 March 2026)
```

**Transfer Complete**:
```
✅ Funds Transferred

Agency: PT Berkah Travel
Service: Hotel Grand Makkah

Transfer Details:
├─ DP: Rp 75,000,000
├─ Pelunasan: Rp 175,000,000
├─ Total: Rp 250,000,000
├─ Reference: XEN-TRF-20260307-001
└─ Bank: BCA 1234567890

[View Statement]
```

**Pelunasan Reminder**:
```
⏰ Pelunasan Due Soon

Agency: PT Berkah Travel
Service: Hotel Grand Makkah
Pelunasan: Rp 175,000,000
Due: 8 March 2026 (in 3 days)

DP Status: Rp 75,000,000 held by platform
Expected Transfer: After pelunasan paid
```

---

## 🎯 KESIMPULAN

### Tracking dari Sisi Agency

**3 Tempat Utama**:
1. **Journey Detail Page** - Lihat payment status per activity, pay now, view receipt
2. **Payment Dashboard** - Overview total paid/pending, upcoming pelunasan
3. **Payment History** - List semua payment yang sudah dilakukan

**Key Metrics**:
- Payment progress percentage
- Total platform fees paid
- Upcoming pelunasan due dates
- Cash flow forecast

**Actions**:
- Pay DP immediately (locks availability)
- Pay pelunasan before H-X
- View receipts and invoices
- Track payment history

---

### Tracking dari Sisi Supplier

**3 Tempat Utama**:
1. **Revenue Dashboard** - Overview revenue, transfer status, revenue by type
2. **Transaction History** - List semua transfer yang sudah diterima
3. **Pending Payments** - List payment yang belum diterima (DP held, unpaid, overdue)

**Key Metrics**:
- Gross revenue vs net revenue
- Transferred amount (sudah diterima)
- Pending transfer (DP held, awaiting pelunasan)
- Awaiting payment (belum dibayar agency)

**Actions**:
- View transfer details and references
- Download statements
- Contact agency for overdue
- Report issues to platform

---

### Commission Flexibility (Sesuai Pak Habibi)

**✅ Different rates per service type**:
- Hotel: 4.76%
- Flight: 5.30%
- Visa: 3.49%
- Bisa set rate berbeda untuk setiap type

**✅ Support percentage AND fixed**:
- Percentage: 5% dari transaction
- Fixed: Rp 50,000 flat fee
- Bisa kombinasi keduanya

**✅ Charge agency, supplier, or both**:
- Agency only: Agency bayar commission
- Supplier only: Dipotong dari supplier
- Both: Charge kedua pihak (model Gojek)

**✅ Supplier-specific rates**:
- Bisa set rate khusus untuk supplier tertentu
- Priority lebih tinggi override rate default
- Example: Premium supplier 3% instead of 4.76%

**✅ Platform admin control**:
- Create unlimited configs
- Set priority
- Activate/deactivate
- View reports
- Adjust kapan saja

---

## 📚 DOKUMEN LENGKAP

Untuk detail lebih lengkap, lihat:

1. **PAYMENT-TRACKING-COMPREHENSIVE.md**
   - Payment flow lifecycle lengkap
   - Dashboard designs (agency & supplier)
   - Database queries
   - Notifications
   - Edge cases handling

2. **PAYMENT-COMMISSION-SUMMARY.md**
   - Executive summary
   - Money flow diagrams
   - Implementation checklist
   - Key benefits

3. **PAYMENT-FLOW-DIAGRAM.md**
   - Visual diagrams
   - Money flow step-by-step
   - Commission selection flow
   - Status progression

4. **COMPLETE-JOURNEY-TO-BOOKING-FLOW.md**
   - Complete flow analysis
   - Integration with booking system
   - All decisions finalized

---

## ✅ STATUS

**Semua Pertanyaan**: TERJAWAB  
**Semua Keputusan**: FINALIZED  
**Semua Dokumen**: COMPLETE  
**Status**: ✅ **READY FOR IMPLEMENTATION**

**Next Action**: Begin implementation Phase 1 (Database schema updates)

---

**Dibuat**: 18 Maret 2026  
**Terakhir Update**: 18 Maret 2026

