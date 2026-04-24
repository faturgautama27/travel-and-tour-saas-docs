# Payment Flow - Visual Diagrams

**Project**: Tour & Travel ERP SaaS  
**Date**: 18 March 2026

---

## 💰 MONEY FLOW DIAGRAM

### Scenario: Hotel Service with DP + Pelunasan

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         STEP 1: DP PAYMENT                              │
└─────────────────────────────────────────────────────────────────────────┘

Agency                    Payment Gateway              Platform              Supplier
  │                             │                          │                   │
  │ [Pay DP Now]               │                          │                   │
  │ Rp 78,570,000              │                          │                   │
  ├────────────────────────────>│                          │                   │
  │                             │                          │                   │
  │                             │ Process Payment          │                   │
  │                             │ Rp 78,570,000           │                   │
  │                             ├─────────────────────────>│                   │
  │                             │                          │                   │
  │                             │                          │ Split:            │
  │                             │                          │ • Service: Rp 75M │
  │                             │                          │ • Fee: Rp 3.57M   │
  │                             │                          │                   │
  │                             │                          │ HOLD Rp 75M       │
  │                             │                          │ (Don't transfer)  │
  │                             │                          │                   │
  │ <Payment Success>           │                          │                   │
  │ <Receipt>                   │                          │                   │
  │<────────────────────────────┤                          │                   │
  │                             │                          │                   │
  │                             │                          │ Notify:           │
  │                             │                          │ "DP received"     │
  │                             │                          ├──────────────────>│
  │                             │                          │                   │

Money Position:
├─ Agency: Paid Rp 78,570,000 ✅
├─ Platform: Holds Rp 75,000,000 + Earned Rp 3,570,000
└─ Supplier: Awaiting transfer (Rp 75,000,000 held)


┌─────────────────────────────────────────────────────────────────────────┐
│                    STEP 2: PELUNASAN PAYMENT                            │
└─────────────────────────────────────────────────────────────────────────┘

Agency                    Payment Gateway              Platform              Supplier
  │                             │                          │                   │
  │ [Pay Pelunasan]            │                          │                   │
  │ Rp 183,330,000             │                          │                   │
  ├────────────────────────────>│                          │                   │
  │                             │                          │                   │
  │                             │ Process Payment          │                   │
  │                             │ Rp 183,330,000          │                   │
  │                             ├─────────────────────────>│                   │
  │                             │                          │                   │
  │                             │                          │ Split:            │
  │                             │                          │ • Service: Rp 175M│
  │                             │                          │ • Fee: Rp 8.33M   │
  │                             │                          │                   │
  │                             │                          │ HOLD Rp 175M      │
  │                             │                          │ (Trigger transfer)│
  │                             │                          │                   │
  │ <Payment Success>           │                          │                   │
  │<────────────────────────────┤                          │                   │
  │                             │                          │                   │

Money Position:
├─ Agency: Paid total Rp 261,900,000 ✅
├─ Platform: Holds Rp 250,000,000 + Earned Rp 11,900,000
└─ Supplier: Awaiting transfer (Rp 250,000,000 ready)


┌─────────────────────────────────────────────────────────────────────────┐
│                    STEP 3: SUPPLIER TRANSFER                            │
└─────────────────────────────────────────────────────────────────────────┘

Agency                    Platform                  Xendit Disbursement    Supplier
  │                          │                             │                   │
  │                          │ Background Job              │                   │
  │                          │ Detects pelunasan paid      │                   │
  │                          │                             │                   │
  │                          │ Calculate total:            │                   │
  │                          │ DP: Rp 75M                  │                   │
  │                          │ Pelunasan: Rp 175M          │                   │
  │                          │ Total: Rp 250M              │                   │
  │                          │                             │                   │
  │                          │ Transfer Rp 250,000,000     │                   │
  │                          ├────────────────────────────>│                   │
  │                          │                             │                   │
  │                          │                             │ Transfer to       │
  │                          │                             │ Supplier Bank     │
  │                          │                             ├──────────────────>│
  │                          │                             │                   │
  │                          │                             │ <Transfer Success>│
  │                          │                             │<──────────────────┤
  │                          │                             │                   │
  │                          │ <Transfer Confirmed>        │                   │
  │                          │<────────────────────────────┤                   │
  │                          │                             │                   │
  │                          │ Update:                     │                   │
  │                          │ supplier_transfer_status    │                   │
  │                          │ = "transferred"             │                   │
  │                          │                             │                   │
  │ Notify:                  │                             │ Notify:           │
  │ "Supplier paid"          │                             │ "Funds received"  │
  │<─────────────────────────┤                             │<──────────────────┤
  │                          │                             │                   │

Final Money Position:
├─ Agency: Paid Rp 261,900,000 ✅
├─ Platform: Earned Rp 11,900,000 ✅
└─ Supplier: Received Rp 250,000,000 ✅
```

---

## 🔄 COMMISSION SELECTION FLOW

### Priority-Based Commission Config Selection

```
┌─────────────────────────────────────────────────────────────┐
│ Payment Request: Hotel Service, Supplier ABC, Rp 100M      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Get All Active Configs for "journey_activity_payment"      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Filter by Criteria:                                         │
│ ├─ Service Type = "hotel" OR NULL                          │
│ ├─ Supplier ID = "ABC" OR NULL                             │
│ ├─ Effective Date = Today                                  │
│ └─ Is Active = true                                        │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Available Configs:                                          │
│                                                             │
│ Config 1:                                                   │
│ ├─ Priority: 20                                            │
│ ├─ Service Type: hotel                                     │
│ ├─ Supplier ID: ABC (specific)                             │
│ ├─ Charged To: both                                        │
│ ├─ Agency: 3% percentage                                   │
│ └─ Supplier: 2% percentage                                 │
│                                                             │
│ Config 2:                                                   │
│ ├─ Priority: 10                                            │
│ ├─ Service Type: hotel                                     │
│ ├─ Supplier ID: NULL (all)                                 │
│ ├─ Charged To: agency                                      │
│ └─ Agency: 4.76% percentage                                │
│                                                             │
│ Config 3:                                                   │
│ ├─ Priority: 5                                             │
│ ├─ Service Type: NULL (all)                                │
│ ├─ Supplier ID: NULL (all)                                 │
│ ├─ Charged To: agency                                      │
│ └─ Agency: 5% percentage                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ Sort by Priority DESC                                       │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│ SELECT Config 1 (Highest Priority + Most Specific)         │
│                                                             │
│ Result:                                                     │
│ ├─ Charged To: both                                        │
│ ├─ Agency Commission: 3% = Rp 3,000,000                   │
│ ├─ Supplier Commission: 2% = Rp 2,000,000                 │
│ ├─ Agency Pays: Rp 103,000,000                            │
│ ├─ Supplier Receives: Rp 98,000,000                       │
│ └─ Platform Earns: Rp 5,000,000                           │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 PAYMENT STATUS TRACKING

### Journey Activity Status Progression

```
┌─────────────────────────────────────────────────────────────┐
│                    MARKETPLACE SERVICE                       │
│                   (Payment Required)                         │
└─────────────────────────────────────────────────────────────┘

Initial State:
┌──────────┐
│ UNPAID   │ ← Activity created, service selected
└────┬─────┘
     │
     │ Agency clicks [Pay DP Now] (if payment terms enabled)
     ↓
┌──────────┐
│ DP_PAID  │ ← DP paid, availability LOCKED
└────┬─────┘
     │
     │ • Pelunasan due date calculated
     │ • Reminders sent at H-10, H-7, H-3
     │ • Agency pays before H-X
     ↓
┌──────────┐
│FULLY_PAID│ ← All payments complete, service confirmed
└──────────┘

Alternative (No Payment Terms):
┌──────────┐
│ UNPAID   │
└────┬─────┘
     │
     │ Agency clicks [Pay Now]
     ↓
┌──────────┐
│FULLY_PAID│ ← Full payment immediately
└──────────┘


┌─────────────────────────────────────────────────────────────┐
│                    INVENTORY SERVICE                         │
│                   (No Payment Needed)                        │
└─────────────────────────────────────────────────────────────┘

┌──────────┐
│ UNPAID   │ ← Activity created
└────┬─────┘
     │
     │ Service from agency inventory selected
     ↓
┌──────────┐
│ RESERVED │ ← No payment needed, quota reserved
└──────────┘
```

---

