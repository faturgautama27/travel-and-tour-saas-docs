# Phase 2 ERP Modules - Trello Task List (REVISED)

**Project**: Tour & Travel ERP SaaS - Phase 2  
**Timeline**: 23 April 2026 - 12 Juni 2026 (7 weeks)  
**Team**: 2 Backend + 2 Frontend Developers  
**Modules**: 9 Modules (3 Urgent + 4 Medium + 2 Low)  
**Last Updated**: 24 April 2026

---

## HOW TO IMPORT TO TRELLO

1. Create Trello lists per Sprint (Sprint 0 through Sprint 5)
2. Each `###` heading becomes a Trello card
3. Bullet points become card checklist items
4. Labels: 🔴 Critical, 🟡 High, 🟢 Medium

---

## SPRINT 0: Tech Debt — Calculation Improvements (Week 1: Apr 23-27) 🔴

### 🔴 [BE] Materiality dalam Kalkulasi Harga Journey
**Labels**: Backend, Critical, Sprint-0, Tech-Debt  
**Due Date**: Apr 25, 2026  
**Req**: 1.1

**Checklist**:
- [ ] Enhance PriceCalculationService: jika pax < Materiality, hitung berdasarkan materiality count
- [ ] Tambah field `EffectivePaxCount` (int?) pada JourneyActivity entity
- [ ] Buat migration untuk field baru
- [ ] Update journey cost calculation untuk menggunakan effective pax
- [ ] Tambah materiality info pada price breakdown DTO (materiality count, pax aktual, effective pax)
- [ ] Update VisaTransportPricingService untuk support materiality
- [ ] Write unit tests: pax < materiality, pax >= materiality, materiality null
- [ ] Invariant test: effective_pax_count >= pax aktual

---

### 🔴 [BE] Negosiasi Full Payment Due Days
**Labels**: Backend, Critical, Sprint-0, Tech-Debt  
**Due Date**: Apr 26, 2026  
**Req**: 1.2

**Checklist**:
- [ ] Buat entity `PaymentTermsNegotiation` (journey_activity_id, requested_value, approved_value, status, notes, timestamps)
- [ ] Buat migration untuk tabel baru
- [ ] Tambah field `NegotiationStatus` pada JourneyActivity (pending_negotiation, negotiation_approved, negotiation_rejected)
- [ ] Buat CreateNegotiationRequestCommand (agency side)
- [ ] Buat ApproveNegotiationCommand + RejectNegotiationCommand (supplier side)
- [ ] Update JourneyActivity.FullPaymentDueDate berdasarkan negotiated value
- [ ] Buat GetNegotiationHistoryQuery
- [ ] Kirim notifikasi ke supplier saat request dibuat
- [ ] Kirim notifikasi ke agency saat approved/rejected
- [ ] Write unit tests

---

### 🔴 [BE] Tipe Traveler (Adult/Child/Infant) dan Kalkulasi Harga
**Labels**: Backend, Critical, Sprint-0, Tech-Debt  
**Due Date**: Apr 27, 2026  
**Req**: 1.3

**Checklist**:
- [ ] Buat enum TravelerType: Adult, Child, Infant
- [ ] Tambah field `TravelerType` pada Traveler entity + migration
- [ ] Implementasi auto-detection: Adult (≥12), Child (2-11), Infant (<2) berdasarkan DOB vs departure date
- [ ] Buat entity `TravelerTypePricingRule` (service_type, traveler_type, discount_percentage, is_free)
- [ ] Buat migration + seed default rules (infant free hotel, child 50% flight, dll)
- [ ] Update PriceCalculationService untuk apply pricing rules per TravelerType
- [ ] Tambah breakdown harga per TravelerType pada journey pricing DTO
- [ ] Default ke Adult jika DateOfBirth kosong
- [ ] Allow manual override TravelerType oleh agency
- [ ] Write unit tests: auto-detection, pricing rules, calculation property (total = sum per-traveler)
- [ ] Idempotence test: re-calculate dari DOB + departure → same TravelerType

---

### 🟡 [FE] UI untuk Materiality, Negosiasi Payment, dan Traveler Type
**Labels**: Frontend, High, Sprint-0, Tech-Debt  
**Due Date**: Apr 27, 2026  
**Req**: 1.1, 1.2, 1.3

**Checklist**:
- [ ] Tampilkan materiality info pada journey activity card (materiality count, pax aktual, effective pax)
- [ ] Warning badge jika pax < materiality
- [ ] Tampilkan breakdown harga per TravelerType di journey detail page
- [ ] Auto-detect TravelerType saat input DateOfBirth di form traveler
- [ ] Dropdown override TravelerType (Adult/Child/Infant)
- [ ] Section negosiasi payment terms di journey activity detail
- [ ] Form "Request Different Terms" dengan input FullPaymentDueDays + notes
- [ ] Status badge negosiasi (pending, approved, rejected)
- [ ] Supplier side: approval/rejection UI untuk negosiasi
- [ ] Update NgRx store untuk negotiation state
- [ ] Write component tests

---

## SPRINT 1: DOKU Production Test + Invoice & PDF (Week 1-2: Apr 23 - May 4) 🔴

### 🔴 [BE] End-to-End DOKU Production Flow Test
**Labels**: Backend, Critical, Sprint-1, Payment  
**Due Date**: Apr 28, 2026  
**Req**: 2.1

**Checklist**:
- [ ] Konfigurasi DOKU production credentials di appsettings.Production.json
- [ ] Test create checkout via DokuPaymentService.CreateCheckoutAsync (production)
- [ ] Verifikasi payment URL valid dan accessible
- [ ] Test pembayaran aktual di DOKU production
- [ ] Verifikasi webhook diterima di PaymentWebhookController.DokuWebhook
- [ ] Verifikasi VerifyWebhookSignature berhasil di production
- [ ] Verifikasi status update di database (BookingInvoice + BookingPayment)
- [ ] Test subscription payment flow via DOKU
- [ ] Test booking payment flow via DOKU
- [ ] Implementasi manual reconciliation endpoint jika webhook gagal
- [ ] Tambah comprehensive logging di setiap tahap
- [ ] Dokumentasi hasil test (request/response/webhook payload)

---

### 🔴 [BE] Setup QuestPDF + Invoice Numbering System
**Labels**: Backend, Critical, Sprint-1, Invoice  
**Due Date**: Apr 30, 2026  
**Req**: 3.1, 3.2

**Checklist**:
- [ ] Install QuestPDF NuGet package
- [ ] Buat IPdfGeneratorService interface
- [ ] Implementasi QuestPdfGeneratorService
- [ ] Setup PDF storage di MinIO (bucket: invoices)
- [ ] Buat entity InvoiceNumberSequence (agency_id, year_month, last_number)
- [ ] Buat migration untuk invoice_number_sequences table
- [ ] Implementasi IInvoiceNumberService dengan format INV-YYYYMM-NNNN
- [ ] Atomic number generation (database locking / SELECT FOR UPDATE)
- [ ] Reset counter setiap awal bulan
- [ ] Unique constraint (agency_id, invoice_number)
- [ ] Update BookingInvoiceService.GenerateInvoiceNumber untuk pakai format baru
- [ ] Write unit tests: sequential, no gaps, thread-safe, monthly reset

---

### 🔴 [BE] Tax Calculation Service (PPN 11%)
**Labels**: Backend, Critical, Sprint-1, Invoice  
**Due Date**: May 1, 2026  
**Req**: 3.3

**Checklist**:
- [ ] Buat ITaxCalculationService interface
- [ ] Implementasi TaxCalculationService
- [ ] Buat TaxConfig entity (agency_id, tax_name, tax_rate, is_inclusive, is_active)
- [ ] Buat migration + seed default PPN 11%
- [ ] Logika "harga sudah termasuk PPN": DPP = Total / 1.11, PPN = Total - DPP
- [ ] Logika "harga belum termasuk PPN": PPN = DPP × 11%, Total = DPP + PPN
- [ ] Buat TaxBreakdownDto (subtotal, dpp, ppn_amount, ppn_rate, total)
- [ ] Konfigurasi tarif PPN per agency (default 11%)
- [ ] Write unit tests: inclusive, exclusive, round-trip property (DPP + PPN = Total)

---

### 🔴 [BE] Template PDF Invoice Profesional + Email Delivery
**Labels**: Backend, Critical, Sprint-1, Invoice  
**Due Date**: May 3, 2026  
**Req**: 3.4, 3.5

**Checklist**:
- [ ] Design invoice PDF layout dengan QuestPDF (A4 portrait)
- [ ] Header: logo agency, nama, alamat, kontak (dari AgencySettings)
- [ ] Info customer: nama, alamat, kontak
- [ ] Info invoice: nomor, tanggal terbit, jatuh tempo
- [ ] Detail items: nama layanan, jumlah, harga satuan, subtotal
- [ ] Ringkasan: subtotal, diskon, DPP, PPN 11%, total
- [ ] Info pembayaran: rekening bank / VA / QR code
- [ ] Terms & conditions + catatan tambahan
- [ ] Support Unicode (Bahasa Indonesia + Arab)
- [ ] PDF size < 2MB
- [ ] Generation time < 3 detik
- [ ] Buat GenerateInvoicePdfCommand + endpoint POST /api/booking-invoices/{id}/generate-pdf
- [ ] Buat DownloadInvoicePdfQuery + endpoint GET /api/booking-invoices/{id}/pdf
- [ ] Integrasi email delivery via Resend API (PDF attachment)
- [ ] Template email profesional dengan branding agency
- [ ] Ringkasan invoice di body email (nomor, total, jatuh tempo)
- [ ] Retry logic: 3x dengan exponential backoff jika gagal
- [ ] Catat status pengiriman: sent, delivered, failed, bounced
- [ ] Opsi kirim ulang manual dari dashboard
- [ ] Write integration tests

---

### 🟡 [FE] Invoice PDF Viewer + List Enhancement
**Labels**: Frontend, High, Sprint-1, Invoice  
**Due Date**: May 4, 2026  
**Req**: 3.4, 3.5

**Checklist**:
- [ ] Buat invoice-pdf-viewer component (PDF.js atau ng2-pdf-viewer)
- [ ] Tombol Download PDF
- [ ] Tombol Print
- [ ] Tombol Send via Email + Send via WhatsApp
- [ ] Loading state + error handling
- [ ] Tambah "Generate PDF" button di invoice list
- [ ] Tambah "View PDF" button (jika sudah generated)
- [ ] Tambah "Send via Email" action di invoice list
- [ ] Update invoice detail page dengan PDF section
- [ ] Tampilkan tax breakdown (DPP, PPN, Total)
- [ ] Status indicator PDF generation
- [ ] Update NgRx booking-invoice store
- [ ] Write component tests

---

## SPRINT 2: Amadeus Integration + Passport OCR (Week 3-4: May 5 - May 18) 🟡

### 🟡 [BE] Amadeus Flight Search API
**Labels**: Backend, High, Sprint-2, Amadeus  
**Due Date**: May 9, 2026  
**Req**: 4.1

**Checklist**:
- [ ] Buat IAmadeusService interface
- [ ] Implementasi AmadeusService (HTTP client, auth token management)
- [ ] Integrasi Amadeus Flight Offers Search API
- [ ] Support one-way, round-trip, multi-city
- [ ] Parameter: origin, destination, dates, pax (adult/child/infant), cabin class
- [ ] Response mapping: airline, flight number, times, duration, price, availability
- [ ] Filter: price range, airline, transit count, departure time
- [ ] Sorting: price, duration, departure time
- [ ] Cache hasil pencarian 15 menit (in-memory atau Redis)
- [ ] Error handling jika Amadeus API unavailable
- [ ] Buat FlightSearchController + endpoints
- [ ] Write unit + integration tests

---

### 🟡 [BE] Amadeus Flight Booking API
**Labels**: Backend, High, Sprint-2, Amadeus  
**Due Date**: May 12, 2026  
**Req**: 4.2

**Checklist**:
- [ ] Integrasi Amadeus Flight Booking API (Flight Orders)
- [ ] Accept passenger details: nama, DOB, passport, nationality
- [ ] Receive PNR (booking reference) dari Amadeus
- [ ] Simpan booking detail di database + link ke JourneyActivity
- [ ] Generate e-ticket dengan PNR + flight details
- [ ] Rollback booking lokal jika Amadeus booking gagal
- [ ] Support pembatalan booking via Amadeus API
- [ ] Write integration tests

---

### 🟡 [FE] Amadeus Flight Search + Booking UI
**Labels**: Frontend, High, Sprint-2, Amadeus  
**Due Date**: May 14, 2026  
**Req**: 4.1, 4.2

**Checklist**:
- [ ] Buat flight-search page component
- [ ] Form pencarian: origin, destination, dates, pax, cabin class
- [ ] Hasil pencarian: list flights dengan detail + harga
- [ ] Filter sidebar: price, airline, transit, time
- [ ] Sort options: price, duration, departure
- [ ] Loading state + empty state
- [ ] Flight detail modal
- [ ] Booking confirmation dialog
- [ ] PNR display + e-ticket view
- [ ] NgRx state management untuk flight search
- [ ] Write component tests

---

### 🟡 [BE] Upload Passport Readable (OCR/MRZ Parsing)
**Labels**: Backend, High, Sprint-2, Passport  
**Due Date**: May 16, 2026  
**Req**: 5.1

**Checklist**:
- [ ] Buat IPassportOcrService interface
- [ ] Implementasi PassportOcrService (MRZ parsing library)
- [ ] Accept upload: JPEG, PNG, PDF
- [ ] Simpan gambar di MinIO (bucket: passports)
- [ ] Parse MRZ: full name, DOB, gender, nationality, passport number, expiry, issuing country
- [ ] Return parsed data untuk review
- [ ] Buat UploadPassportCommand + endpoint POST /api/travelers/{id}/passport-scan
- [ ] Link gambar passport ke Traveler entity
- [ ] Error handling jika OCR gagal (fallback manual input)
- [ ] Write unit tests + round-trip property test (parse → format → same data)

---

### 🟡 [FE] Passport Upload + Auto-Fill UI
**Labels**: Frontend, High, Sprint-2, Passport  
**Due Date**: May 18, 2026  
**Req**: 5.1

**Checklist**:
- [ ] Buat passport-upload component (drag & drop + file picker)
- [ ] Preview gambar passport setelah upload
- [ ] Loading state saat OCR processing
- [ ] Tampilkan hasil parsing untuk review + konfirmasi
- [ ] Auto-fill form Traveler dari parsed data
- [ ] Allow edit sebelum save
- [ ] Error state jika OCR gagal + manual input fallback
- [ ] Integrasi ke traveler form di booking page
- [ ] Write component tests

---

## SPRINT 3: Funder Flow (Week 4-5: May 12 - May 25) 🟡

### 🟡 [BE] Funder Role + Entities
**Labels**: Backend, High, Sprint-3, Funder  
**Due Date**: May 15, 2026  
**Req**: 6.1

**Checklist**:
- [ ] Tambah role FUNDER di auth system (User entity, role seeding)
- [ ] Buat permission set untuk FUNDER (Funding List, My Investments, Payment History, Profile)
- [ ] Buat entity FundingConfig (journey_id, return_percentage, is_funding_phase, total_funding_needed, funding_status)
- [ ] Buat entity FundingTransaction (funder_id, journey_id, amount, status, payment_reference)
- [ ] Buat entity FunderPayment (funder_id, supplier_id, journey_activity_id, amount, type, status)
- [ ] Buat migrations untuk semua entity baru
- [ ] Terapkan RLS pada semua entity funder
- [ ] Buat halaman registrasi + profil FUNDER
- [ ] Write entity tests

---

### 🟡 [BE] Funding Config + Funding List API
**Labels**: Backend, High, Sprint-3, Funder  
**Due Date**: May 18, 2026  
**Req**: 6.2, 6.3

**Checklist**:
- [ ] Buat CreateFundingConfigCommand (di journey create flow)
- [ ] Buat UpdateFundingConfigCommand
- [ ] Validasi ReturnPercentage: 0.1% - 50%
- [ ] total_funding_needed = Journey.BaseCost
- [ ] Buat GetFundingListQuery (filter: is_funding_phase = true, funding_status = open)
- [ ] Return: journey name, departure date, total funding needed, return percentage, agency name
- [ ] Buat CreateFundingTransactionCommand (funder memilih journey)
- [ ] Redirect ke payment gateway
- [ ] Update FundingTransaction status setelah payment success
- [ ] Update FundingConfig.funding_status = "funded" jika fully funded
- [ ] Write command/query tests

---

### 🟡 [BE] Split Payment ke Supplier + Bagi Hasil
**Labels**: Backend, High, Sprint-3, Funder  
**Due Date**: May 22, 2026  
**Req**: 6.4, 6.5

**Checklist**:
- [ ] Implementasi split payment logic: funder payment → split ke supplier-supplier berdasarkan JourneyActivity cost
- [ ] Update JourneyActivity.PaymentStatus = "fully_paid" per activity setelah supplier dibayar
- [ ] Catat setiap split sebagai FunderPayment (type: "supplier_payment")
- [ ] Retry logic jika split ke supplier gagal + reconciliation manual
- [ ] Notifikasi ke supplier saat pembayaran diterima
- [ ] Bagi hasil calculation: (SellingPrice - BaseCost) × ReturnPercentage
- [ ] Trigger release bagi hasil setelah SEMUA booking pada journey fully_paid
- [ ] Disbursement ke funder via payment gateway
- [ ] Catat bagi hasil sebagai FunderPayment (type: "bagi_hasil")
- [ ] Calculation property test: released amount = total profit × return percentage
- [ ] Write integration tests

---

### 🟡 [FE] Funder Flow UI
**Labels**: Frontend, High, Sprint-3, Funder  
**Due Date**: May 25, 2026  
**Req**: 6.1, 6.2, 6.3, 6.4, 6.5

**Checklist**:
- [ ] Buat FUNDER registration page
- [ ] Buat FUNDER profile page
- [ ] Tambah "Funding Configuration" section di Journey Create page (di bawah Pricing Summary)
- [ ] Toggle IsFundingPhase + input ReturnPercentage
- [ ] Buat Funding List page (hanya FUNDER role)
- [ ] Card per journey: nama, departure, total needed, return %, agency
- [ ] Tombol "Fund This Journey" → payment flow
- [ ] Buat My Investments page (funder dashboard)
- [ ] Metrics: total invested, total bagi hasil received, pending bagi hasil, ROI %
- [ ] Payment History page
- [ ] NgRx state management untuk funder module
- [ ] Write component tests

---

## SPRINT 4: Finance & Accounting (Week 5-7: May 19 - Jun 8) 🔴

### 🔴 [BE] Chart of Accounts (COA) — Entity, Database, CRUD
**Labels**: Backend, Critical, Sprint-4, Finance  
**Due Date**: May 22, 2026  
**Req**: 7.1

**Checklist**:
- [ ] Buat entity ChartOfAccount (id, agency_id, account_code, account_name, account_type, parent_account_id, level, is_active, is_postable)
- [ ] EF configuration: self-referencing relationship (parent-child)
- [ ] Migration untuk chart_of_accounts table
- [ ] Indexes: agency_id, parent_account_id, account_code
- [ ] Unique constraint: (agency_id, account_code)
- [ ] Seed default COA untuk travel agency (5 tipe: Asset, Liability, Equity, Revenue, Expense)
- [ ] Buat CreateChartOfAccountCommand + UpdateChartOfAccountCommand
- [ ] Buat DeactivateChartOfAccountCommand
- [ ] Buat GetChartOfAccountsQuery (with hierarchy tree)
- [ ] Validasi: unique code, max level 5, parent exists, cannot delete with children/transactions
- [ ] Cannot post to parent account (only leaf accounts)
- [ ] RLS enforced
- [ ] Tree property test: traversal child → root = valid path
- [ ] Write command/query tests

---

### 🔴 [BE] General Ledger (GL) — Journal Entries
**Labels**: Backend, Critical, Sprint-4, Finance  
**Due Date**: May 26, 2026  
**Req**: 7.2

**Checklist**:
- [ ] Buat entity JournalEntry (id, agency_id, entry_number, transaction_date, posting_date, description, reference_type, reference_id, status, created_by)
- [ ] Buat entity JournalEntryLine (id, journal_entry_id, account_id, debit_amount, credit_amount, description)
- [ ] EF configurations + migrations
- [ ] Check constraint: total debit = total credit per entry
- [ ] Buat CreateJournalEntryCommand (manual, multi-line)
- [ ] Buat PostJournalEntryCommand (update account balances atomically)
- [ ] Buat ReverseJournalEntryCommand (create offsetting entry + audit trail)
- [ ] Buat GetJournalEntriesQuery + GetJournalEntryByIdQuery
- [ ] Entry number generation: sequential per agency
- [ ] Validasi: balanced entry, accounts allow posting (is_postable = true)
- [ ] Transaction date terpisah dari posting date (accrual basis)
- [ ] RLS enforced
- [ ] Accounting equation property test: total debit = total kredit
- [ ] Confluence property test: any order of JE → same final balance
- [ ] Write command/query tests

---

### 🔴 [BE] Auto-Generate Journal Entries dari Event Bisnis
**Labels**: Backend, Critical, Sprint-4, Finance  
**Due Date**: May 29, 2026  
**Req**: 7.3

**Checklist**:
- [ ] Buat IJournalEntryAutoGeneratorService interface
- [ ] Implementasi JournalEntryAutoGeneratorService
- [ ] Buat configurable account mapping per transaction type
- [ ] Hook: booking confirmed → Debit AR, Credit Revenue
- [ ] Hook: BookingPayment created → Debit Cash/Bank, Credit AR
- [ ] Hook: supplier bill created → Debit Expense, Credit AP
- [ ] Hook: supplier payment → Debit AP, Credit Cash/Bank
- [ ] Map expense account berdasarkan service type (hotel expense, flight expense, dll)
- [ ] Balance property test: semua auto-generated JE → debit = kredit
- [ ] Write integration tests

---

### 🔴 [BE] Accounts Receivable (AR) + Aging Report
**Labels**: Backend, Critical, Sprint-4, Finance  
**Due Date**: Jun 2, 2026  
**Req**: 7.4

**Checklist**:
- [ ] Buat entity AccountsReceivable (id, agency_id, booking_id, customer_id, invoice_number, amount, paid_amount, status, due_date)
- [ ] Migration + EF configuration
- [ ] Auto-create AR record saat booking confirmed
- [ ] Update AR saat BookingPayment recorded + create GL journal entry
- [ ] Status tracking: Draft, Sent, Partially_Paid, Paid, Overdue
- [ ] Support partial payment dengan alokasi
- [ ] Buat GetARAgingReportQuery
- [ ] Aging buckets: Current, 1-30, 31-60, 61-90, >90 hari
- [ ] Group by customer
- [ ] Export ke Excel
- [ ] Invariant test: total pembayaran <= jumlah piutang
- [ ] Write command/query tests

---

### 🔴 [BE] Accounts Payable (AP) + Aging Report
**Labels**: Backend, Critical, Sprint-4, Finance  
**Due Date**: Jun 5, 2026  
**Req**: 7.5

**Checklist**:
- [ ] Enhance SupplierBill entity dengan approval workflow fields (approval_status, approved_by, approved_at)
- [ ] Migration untuk fields baru
- [ ] Buat ApproveSupplierBillCommand + RejectSupplierBillCommand
- [ ] Status: Draft, Pending_Approval, Approved, Partially_Paid, Paid
- [ ] Create GL journal entry saat bill approved (Debit Expense, Credit AP)
- [ ] Create GL journal entry saat payment recorded (Debit AP, Credit Cash)
- [ ] Support partial payment
- [ ] Buat GetAPAgingReportQuery
- [ ] Aging buckets: Current, 1-30, 31-60, 61-90, >90 hari
- [ ] Group by supplier
- [ ] Export ke Excel
- [ ] Invariant test: total pembayaran <= jumlah bill
- [ ] Write command/query tests

---

### 🟡 [FE] Chart of Accounts Management UI
**Labels**: Frontend, High, Sprint-4, Finance  
**Due Date**: May 28, 2026  
**Req**: 7.1

**Checklist**:
- [ ] Buat chart-of-accounts module + routes
- [ ] COA list component: tree view (expand/collapse hierarchy)
- [ ] COA form component: create/edit account
- [ ] Account type filter (Asset, Liability, Equity, Revenue, Expense)
- [ ] Search by code/name
- [ ] Activate/deactivate action
- [ ] Prevent delete jika ada children atau transactions
- [ ] NgRx state management
- [ ] Write component tests

---

### 🟡 [FE] Journal Entry Management UI
**Labels**: Frontend, High, Sprint-4, Finance  
**Due Date**: Jun 1, 2026  
**Req**: 7.2, 7.3

**Checklist**:
- [ ] Buat journal-entry module + routes
- [ ] JE list component: filter by date, type, status
- [ ] JE form component: multi-line entry (account selector + debit/credit)
- [ ] Account selector dengan search (dropdown dari COA)
- [ ] Auto-balance check (total debit = total credit) real-time
- [ ] Post / Reverse actions
- [ ] Badge untuk auto-generated vs manual entries
- [ ] NgRx state management
- [ ] Write component tests

---

### 🟡 [FE] AR & AP Management + Aging Reports UI
**Labels**: Frontend, High, Sprint-4, Finance  
**Due Date**: Jun 8, 2026  
**Req**: 7.4, 7.5

**Checklist**:
- [ ] Buat accounts-receivable module
- [ ] AR list: filter by status, customer, date
- [ ] AR detail: payment recording form
- [ ] Overdue indicator (merah)
- [ ] Buat accounts-payable module
- [ ] AP list: filter by status, supplier, date
- [ ] AP detail: approval workflow UI + payment recording
- [ ] Buat aging-reports module
- [ ] AR Aging Report component: aging buckets table, group by customer
- [ ] AP Aging Report component: aging buckets table, group by supplier
- [ ] Date range filter
- [ ] Export to Excel button
- [ ] NgRx state management
- [ ] Write component tests

---

## SPRINT 5: B2B Marketplace + Reporting (Week 7: Jun 9 - Jun 12) 🟢

### 🟢 [BE] Rating & Review System
**Labels**: Backend, Medium, Sprint-5, Marketplace  
**Due Date**: Jun 10, 2026  
**Req**: 8.1

**Checklist**:
- [ ] Buat entity ServiceReview (id, agency_id, supplier_service_id, booking_id, rating, review_text, reply_text, replied_at)
- [ ] Migration + EF configuration
- [ ] Buat SubmitReviewCommand (validasi: booking completed, no duplicate)
- [ ] Buat ReplyToReviewCommand (supplier side)
- [ ] Buat GetReviewsQuery (by service, by supplier)
- [ ] Calculate average rating per service
- [ ] Invariant test: rating 1-5
- [ ] Write command/query tests

---

### 🟢 [BE] Dispute Resolution System
**Labels**: Backend, Medium, Sprint-5, Marketplace  
**Due Date**: Jun 10, 2026  
**Req**: 8.2

**Checklist**:
- [ ] Buat entity Dispute (id, agency_id, supplier_id, order_id, category, description, status, resolution)
- [ ] Buat entity DisputeMessage (id, dispute_id, sender_id, message, attachments)
- [ ] Migrations + EF configurations
- [ ] Buat CreateDisputeCommand (category: quality_issue, pricing_dispute, service_not_delivered, other)
- [ ] Buat ResolveDisputeCommand
- [ ] Workflow: Open → Under_Review → Resolved → Escalated → Closed
- [ ] Notifikasi ke supplier + platform admin saat dispute dibuat
- [ ] Support lampiran bukti (gambar, dokumen via MinIO)
- [ ] Write command tests

---

### 🟢 [BE] Marketplace Analytics + Financial Reports API
**Labels**: Backend, Medium, Sprint-5, Reporting  
**Due Date**: Jun 11, 2026  
**Req**: 8.3, 9.1, 9.2

**Checklist**:
- [ ] Buat GetMarketplaceAnalyticsQuery (total transaksi, revenue, komisi, top suppliers, top agencies)
- [ ] Date range filtering
- [ ] Buat GetTrialBalanceQuery (semua account balances dari GL)
- [ ] Buat GetBalanceSheetQuery (Assets, Liabilities, Equity)
- [ ] Buat GetIncomeStatementQuery (Revenue, Expenses, Net Income)
- [ ] Buat GetSalesReportQuery (revenue per periode, per journey, per agent)
- [ ] Buat GetProfitabilityReportQuery (margin analysis per booking)
- [ ] Buat GetCustomerReportQuery (top customers, spending, retention)
- [ ] Buat GetSupplierReportQuery (top suppliers, payment, rating)
- [ ] Export ke Excel + PDF
- [ ] Accounting equation test: Assets = Liabilities + Equity
- [ ] Balance test: Trial Balance debit = kredit
- [ ] Write query tests

---

### 🟢 [FE] Rating, Dispute, Analytics + Reports UI
**Labels**: Frontend, Medium, Sprint-5, Marketplace + Reporting  
**Due Date**: Jun 12, 2026  
**Req**: 8.1, 8.2, 8.3, 9.1, 9.2

**Checklist**:
- [ ] Review form component (star rating + text input)
- [ ] Review list component (on service detail page)
- [ ] Average rating display on service card
- [ ] Supplier reply UI
- [ ] Dispute form component (category, description, attachments)
- [ ] Dispute list + detail + resolution UI
- [ ] Status badges
- [ ] Marketplace analytics dashboard (charts: PrimeNG Chart)
- [ ] Top sellers/buyers tables
- [ ] Financial statements module: Trial Balance, Balance Sheet, Income Statement
- [ ] Financial reports module: Sales, Profitability, Customer, Supplier
- [ ] Date range filters
- [ ] Export to Excel/PDF buttons
- [ ] NgRx state management
- [ ] Write component tests

---

## 🔗 CROSS-MODULE TASKS

### 🔴 [BE] Multi-Tenant RLS + Audit Trail
**Labels**: Backend, Critical, Cross-Module  
**Due Date**: Ongoing (setiap sprint)  
**Req**: 10.1, 10.2

**Checklist**:
- [ ] Terapkan RLS untuk SEMUA tabel Phase 2 baru
- [ ] Validasi agency_id pada semua CQRS commands dan queries
- [ ] Buat AuditLog entity (user_id, timestamp, action_type, entity_type, entity_id, old_values, new_values)
- [ ] Intercept create/update/delete untuk entity keuangan (COA, GL, AR, AP, Invoice)
- [ ] Query audit log: filter by date range, user, entity type
- [ ] Retention: minimal 7 tahun
- [ ] Write integration tests

---

## 📊 SPRINT SUMMARY

| Sprint | Duration | Focus | Cards | Priority |
|--------|----------|-------|-------|----------|
| Sprint 0 | Week 1 (Apr 23-27) | Tech Debt: Materiality, Negotiation, TravelerType | 4 cards | 🔴 Critical |
| Sprint 1 | Week 1-2 (Apr 23 - May 4) | DOKU Production Test + Invoice & PDF | 5 cards | 🔴 Critical |
| Sprint 2 | Week 3-4 (May 5 - May 18) | Amadeus + Passport OCR | 5 cards | 🟡 High |
| Sprint 3 | Week 4-5 (May 12 - May 25) | Funder Flow | 4 cards | 🟡 High |
| Sprint 4 | Week 5-7 (May 19 - Jun 8) | Finance & Accounting (COA, GL, AR, AP) | 8 cards | 🔴 Critical |
| Sprint 5 | Week 7 (Jun 9 - Jun 12) | B2B Marketplace + Reporting | 4 cards | 🟢 Medium |
| Cross | Ongoing | RLS + Audit Trail | 1 card | 🔴 Critical |
| **TOTAL** | **7 weeks** | **9 Modules** | **31 cards** | |

---

## 🎯 DEFINITION OF DONE

**Per Card**:
- [ ] Code implemented dan reviewed
- [ ] Unit tests written dan passing (>80% coverage)
- [ ] Integration tests passing
- [ ] API documentation updated (Swagger)
- [ ] No critical bugs
- [ ] Code merged ke main branch

**Per Sprint**:
- [ ] Semua sprint cards completed
- [ ] Sprint demo conducted
- [ ] Stakeholder feedback incorporated

**Phase 2 Completion (Jun 12)**:
- [ ] Semua 9 modul working end-to-end
- [ ] System stable (no critical bugs)
- [ ] Documentation complete
- [ ] Demo ready

---

## 🚀 READY TO IMPORT TO TRELLO!

**Import Instructions**:
1. Buat 7 Trello lists: "Sprint 0", "Sprint 1", "Sprint 2", "Sprint 3", "Sprint 4", "Sprint 5", "Cross-Module"
2. Copy setiap `###` section sebagai card baru
3. Tambah labels: Backend, Frontend, Critical, High, Medium
4. Set due dates sesuai yang tertera
5. Assign team members
6. Move cards: To Do → In Progress → Review → Done

**Good luck with Phase 2! 🎉**
