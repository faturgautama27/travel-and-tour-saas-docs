# Phase 2 ERP Modules - Executive Summary (REVISED)

**Project**: Tour & Travel ERP SaaS - Phase 2  
**Timeline**: 23 April 2026 - 12 Juni 2026 (7 weeks)  
**Team**: 2 Backend + 2 Frontend Developers  
**Status**: Planning Revised ✅  
**Last Updated**: 24 April 2026

---

## 🎯 **OBJECTIVES**

Memperkuat fondasi platform Tour & Travel SaaS dengan menyelesaikan tech debt kritis, memvalidasi payment gateway di production, menambahkan invoice PDF profesional, dan membangun modul-modul ERP baru termasuk Funder Flow, Finance & Accounting, serta integrasi Amadeus.

---

## 📦 **9 MODUL — DIKELOMPOKKAN BERDASARKAN PRIORITAS**

---

### 🔴 PRIORITAS 1-3: URGENT / CRITICAL

---

### **1. Tech Debt — Calculation Improvements** (1 week)
**Why Urgent**: Kalkulasi harga journey saat ini belum akurat — materiality tidak diperhitungkan, tidak ada pembedaan harga adult/child/infant, dan payment terms tidak bisa dinegosiasi.

**Features**:
- **Materiality Pricing**: Jika pax < materiality, harga dihitung berdasarkan materiality count
- **Negotiable Full Payment Due Days**: Flow negosiasi agency-supplier untuk jangka waktu pelunasan
- **Traveler Type (Adult/Child/Infant)**: Auto-detect dari DateOfBirth, aturan harga per tipe per service

**Existing Code**:
- `SupplierService.Materiality` (int?) — sudah ada, belum dipakai
- `SupplierService.FullPaymentDueDays` (int?) — sudah ada, belum negotiable
- `Traveler.DateOfBirth` — sudah ada, belum ada `TravelerType`
- `PriceCalculationService` — perlu di-enhance

**Business Impact**:
- ✅ Harga journey lebih akurat dan kompetitif
- ✅ Fleksibilitas pembayaran untuk agency
- ✅ Pricing yang adil untuk child/infant

---

### **2. Payment Gateway — DOKU Production Flow Test** (3-5 hari)
**Why Urgent**: DOKU sudah fully implemented tapi belum pernah ditest di production environment.

**Features**:
- End-to-end production test: create checkout → bayar → webhook → status update
- Test subscription payments dan booking payments
- Validasi signature generation di production
- Manual reconciliation mechanism jika webhook gagal

**Existing Code**:
- `DokuPaymentService` — fully implemented (signature, checkout, webhook)
- `DokuPaymentGatewayService` — gateway wrapper
- `PaymentGatewayFactory` — config-based switching
- `PaymentWebhookController` — DOKU webhook endpoint sudah ada

**Business Impact**:
- ✅ Confidence bahwa payment gateway production-ready
- ✅ Alternatif payment gateway selain Xendit
- ✅ Redundansi untuk business continuity

---

### **3. Invoice & PDF Generation** (2 weeks) 🔴 CRITICAL
**Why Critical**: Customer membutuhkan invoice resmi untuk pembayaran dan reimbursement perusahaan.

**Features**:
- Setup QuestPDF untuk generate invoice/receipt PDF profesional
- Sistem penomoran baru: `INV-YYYYMM-0001` (sequential per agency per bulan)
- Tax calculation service (PPN 11%) — inclusive dan exclusive
- Template PDF dengan branding agency (logo, alamat, kontak)
- Email delivery via Resend API dengan PDF attachment

**Existing Code**:
- `BookingInvoiceService` — logika invoice sudah ada (full, split, DP, pelunasan)
- `BookingInvoice` entity — sudah ada, format nomor perlu diubah
- `EmailService` + Resend — sudah configured, belum connected ke invoice
- `MinIOService` — untuk storage PDF

**Business Impact**:
- ✅ Citra profesional agency
- ✅ Pembayaran lebih cepat
- ✅ Tax compliance (PPN 11%)
- ✅ Mengurangi kerja manual

---

### 🟡 PRIORITAS 4-7: MEDIUM

---

### **4. Amadeus Integration** (2 weeks)
**Why Medium**: Pencarian dan booking penerbangan real-time via GDS.

**Features**:
- Flight search: one-way, round-trip, multi-city via Amadeus API
- Flight booking: PNR generation, e-ticket
- Cache hasil pencarian 15 menit
- Pembatalan booking via Amadeus API

**Business Impact**:
- ✅ Opsi penerbangan real-time
- ✅ Konfirmasi reservasi instan
- ✅ Competitive advantage

---

### **5. Upload Passport Readable (OCR)** (1 week)
**Why Medium**: Mempercepat input data traveler dari scan passport.

**Features**:
- Upload gambar passport (JPEG, PNG, PDF) ke MinIO
- OCR/parsing Machine Readable Zone (MRZ)
- Auto-fill form Traveler (nama, DOB, gender, passport number, expiry)
- Review & konfirmasi sebelum simpan

**Existing Code**:
- `MinIOService` — storage sudah ada
- `Traveler` entity — target auto-fill

**Business Impact**:
- ✅ Input data 80% lebih cepat
- ✅ Mengurangi human error
- ✅ UX yang lebih baik

---

### **6. Funder Flow** (2 weeks) — FITUR BARU
**Why Medium**: Memungkinkan investor mendanai journey dan mendapatkan bagi hasil.

**Features**:
- **Role baru: FUNDER** — registrasi, profil, permission set terpisah
- **Funding Config di Journey Create** — Return Percentage + toggle Funding Phase (di bawah Pricing Summary)
- **Funding List** — halaman khusus FUNDER untuk browse journey yang butuh pendanaan
- **Split Payment ke Supplier** — pembayaran funder langsung di-split ke supplier-supplier journey (bukan ke agency)
- **Bagi Hasil** — dirilis ke funder setelah traveler membayar booking, dihitung dari (SellingPrice - BaseCost) × ReturnPercentage

**New Entities**:
- `FundingConfig` (journey_id, return_percentage, is_funding_phase, total_funding_needed, funding_status)
- `FundingTransaction` (funder_id, journey_id, amount, status)
- `FunderPayment` (funder_id, supplier_id, journey_activity_id, amount, type, status)

**Business Impact**:
- ✅ Sumber pendanaan alternatif untuk agency
- ✅ ROI untuk investor
- ✅ Service journey otomatis terbayar

---

### **7. Finance & Accounting — Accrual Basis (IFRS 19)** (3 weeks) 🔴 CRITICAL
**Why Critical**: Agency membutuhkan pencatatan keuangan yang akurat untuk compliance dan pelaporan pajak.

**Features**:
- **Chart of Accounts (COA)** — hierarki 5 level, seeding default untuk travel agency
- **General Ledger (GL)** — journal entries manual + auto-generate
- **Auto-Generate JE** — dari event booking (revenue recognition) dan supplier bill (expense recognition)
- **Accounts Receivable (AR)** — piutang customer, aging report, partial payment
- **Accounts Payable (AP)** — hutang supplier, approval workflow, aging report

**Existing Code**:
- `CommissionConfig`, `SupplierBill`, `BookingPayment` — foundation sudah ada
- `SupplierBill` — perlu ditambah approval workflow

**Business Impact**:
- ✅ Catatan keuangan akurat (accrual basis)
- ✅ Tax reporting compliance
- ✅ Cash flow management
- ✅ Financial insights

---

### � PRIORITAS 8-9: LOW

---

### **8. B2B Marketplace Enhancement** (1 week)
**Features**:
- Rating & Review system (1-5 bintang + teks)
- Dispute Resolution workflow (Open → Under_Review → Resolved → Closed)
- Marketplace Analytics dashboard (total transaksi, revenue, komisi)

**Business Impact**:
- ✅ Kepercayaan buyer meningkat
- ✅ Akuntabilitas seller
- ✅ Platform revenue tracking

---

### **9. Reporting & Analytics** (1 week)
**Features**:
- Laporan Keuangan: Trial Balance, Balance Sheet, Income Statement
- Laporan Operasional: Sales, Profitability, Customer, Supplier
- Export ke PDF dan Excel

**Business Impact**:
- ✅ Data-driven decision making
- ✅ Identifikasi package profitable
- ✅ Optimasi hubungan supplier

---

## ❌ **EXCLUDED**

- **Asosiasi BERPAHALA** — Proyek terpisah
- **HR & Payroll Module** — Phase berikutnya
- **Inventory Management** — Phase berikutnya
- **Budgeting & Cost Control** — Phase berikutnya
- **Bank Reconciliation** — Phase berikutnya

---

## 📊 **SPRINT BREAKDOWN**

| Sprint | Duration | Focus | Prioritas |
|--------|----------|-------|-----------|
| **Sprint 0** | Week 1 (Apr 23-27) | Tech Debt: Materiality, Negotiable Payment, Traveler Type | 🔴 URGENT |
| **Sprint 1** | Week 1-2 (Apr 23 - May 4) | DOKU Production Test + Invoice & PDF Generation | 🔴 CRITICAL |
| **Sprint 2** | Week 3-4 (May 5 - May 18) | Amadeus Integration + Passport OCR | 🟡 MEDIUM |
| **Sprint 3** | Week 4-5 (May 12 - May 25) | Funder Flow (Role, Config, Funding, Split Payment, Bagi Hasil) | 🟡 MEDIUM |
| **Sprint 4** | Week 5-7 (May 19 - Jun 8) | Finance & Accounting (COA, GL, AR, AP) | 🔴 CRITICAL |
| **Sprint 5** | Week 7 (Jun 9 - Jun 12) | B2B Marketplace Enhancement + Reporting & Analytics | 🟢 LOW |
| **TOTAL** | **7 weeks** | **9 Modules** | |

> **Note**: Sprint 2-4 berjalan paralel antara BE dan FE team. Sprint 0 dan 1 berjalan bersamaan karena tech debt bisa dikerjakan paralel dengan invoice setup.

---

## 🚀 **DELIVERABLES PER MILESTONE**

### **Week 1 (Apr 27)**
- ✅ Materiality pricing logic implemented
- ✅ Negotiable FullPaymentDueDays flow working
- ✅ TravelerType enum + auto-detection + pricing rules
- ✅ DOKU production test started

### **Week 2 (May 4)**
- ✅ DOKU production test complete (checkout → webhook → status)
- ✅ QuestPDF setup + invoice numbering (INV-YYYYMM-0001)
- ✅ Tax calculation service (PPN 11%)
- ✅ Invoice PDF template + email delivery

### **Week 3-4 (May 18)**
- ✅ Amadeus flight search + booking API
- ✅ Passport OCR upload + MRZ parsing
- ✅ FUNDER role + FundingConfig entity
- ✅ Funding List page + payment flow

### **Week 5-6 (Jun 1)**
- ✅ Funder split payment ke supplier + bagi hasil
- ✅ COA 5-level hierarchy + default seeding
- ✅ General Ledger + journal entries
- ✅ Auto-generate JE dari booking & supplier bill

### **Week 7 (Jun 12)**
- ✅ AR + AP dengan aging reports
- ✅ Rating & Review system
- ✅ Dispute Resolution workflow
- ✅ Financial reports (Trial Balance, Balance Sheet, Income Statement)
- ✅ Operational reports + Export Excel/PDF
- 🎉 **Phase 2 Complete!**

---

## 💰 **BUSINESS VALUE**

### **Revenue Impact**
- **Invoice PDF**: Pembayaran lebih cepat → +15% cash flow improvement
- **Funder Flow**: Sumber pendanaan alternatif → journey lebih banyak terlaksana
- **B2B Marketplace**: Volume transaksi naik → +20% platform revenue
- **Amadeus**: Opsi penerbangan real-time → competitive advantage

### **Cost Savings**
- **Tech Debt Fix**: Kalkulasi harga akurat → mengurangi dispute pricing
- **Finance Automation**: Waktu accounting berkurang 60%
- **Passport OCR**: Input data 80% lebih cepat
- **Automated JE**: Pencatatan keuangan tanpa input manual

### **Operational Excellence**
- **DOKU Production**: Payment gateway redundancy
- **Reporting**: Data-driven decision making
- **AR/AP Aging**: Cash flow management lebih baik
- **Dispute Resolution**: Penyelesaian masalah yang terstruktur

---

## ✅ **SUCCESS CRITERIA**

### **Technical**
- [ ] Semua 9 modul berfungsi penuh dan teruji
- [ ] Unit test coverage >80%
- [ ] Integration tests passing
- [ ] API documentation updated (Swagger)
- [ ] No critical bugs

### **Functional**
- [ ] Materiality dan TravelerType pricing berjalan benar
- [ ] DOKU payment gateway production-tested end-to-end
- [ ] Invoice PDF ter-generate dengan format profesional
- [ ] Amadeus flight search mengembalikan hasil real-time
- [ ] Funder flow end-to-end: funding → split payment → bagi hasil
- [ ] Finance module (COA, GL, AR, AP) menghasilkan data akurat
- [ ] Laporan keuangan (Trial Balance, Balance Sheet, Income Statement) akurat
- [ ] Rating & Review + Dispute Resolution functional
- [ ] Reports export ke Excel/PDF

### **Performance**
- [ ] API response time <500ms (95th percentile)
- [ ] PDF generation <3 detik
- [ ] Report generation <10 detik
- [ ] 100 concurrent users tanpa degradasi

---

## 📚 **DOCUMENTATION**

- **Main Spec Folder**: `.kiro/specs/phase-2-erp-modules/`
- **Requirements**: `requirements.md` — 9 modul, 25+ requirements
- **Design**: `design.md` — Technical design (to be updated)
- **Tasks**: `tasks.md` — Detailed task breakdown
- **Trello**: `TRELLO_TASKS.md` — Ready to import
- **GitHub Repo**:
  - Backend: `Private/travel-and-tour-backend`
  - Frontend: `Private/tour-and-travel-frontend`

---

**Status**: ✅ Planning Revised — Ready to Start  
**Confidence Level**: 🟢 High (Clear scope, prioritized modules)  
**Risk Level**: 🟡 Medium (7 weeks timeline, 9 modules — tight but achievable with parallel work)
