# Requirements Document - Phase 2 ERP Modules (Revisi)

## Introduction

Dokumen ini menspesifikasikan requirements untuk Phase 2 pengembangan platform Tour & Travel SaaS. Scope Phase 2 telah direvisi dan diprioritaskan ulang berdasarkan kebutuhan bisnis aktual. Phase 2 mencakup 9 area utama yang dikelompokkan berdasarkan prioritas: Tech Debt & Calculation Improvements, Payment Gateway Production Test, Invoice & PDF Generation, Amadeus Integration, Upload Passport Readable, Funder Flow, Finance & Accounting, B2B Marketplace Enhancement, dan Reporting & Analytics.

**Platform Stack:**
- Backend: .NET 8, PostgreSQL 16, EF Core 8, CQRS + MediatR, Clean Architecture
- Frontend: Angular 20, PrimeNG 20, TailwindCSS 4, NgRx
- Payment: Xendit + DOKU (factory pattern via `PaymentGatewayFactory`)
- Storage: MinIO, Email: Resend
- 80+ entities, 60+ controllers, full multi-tenant dengan RLS

## Glossary

- **Agency**: Tenant travel agency dalam sistem multi-tenant
- **Supplier**: Penyedia layanan (hotel, flight, visa, transport, dll.)
- **Journey**: Paket perjalanan yang dibuat oleh agency, berisi aktivitas-aktivitas
- **JourneyActivity**: Item layanan dalam journey (hotel, flight, visa, transport, dll.) — satu-satunya tabel tracking operasional
- **SupplierService**: Layanan yang ditawarkan supplier di marketplace, memiliki field `Materiality` (int?) dan `FullPaymentDueDays` (int?)
- **Traveler**: Peserta perjalanan yang terhubung ke booking, memiliki `DateOfBirth` tapi belum ada `TravelerType`
- **TravelerType**: Enum klasifikasi traveler: Adult, Child, Infant — ditentukan berdasarkan usia saat departure
- **Materiality**: Jumlah minimum pax untuk kalkulasi harga. Jika pax aktual < materiality, harga dihitung berdasarkan materiality count
- **PriceCalculationService**: Service yang menghitung effective price (seasonal > availability > base price)
- **BookingInvoice**: Entity invoice booking yang sudah ada, format nomor saat ini: `INV-{bookingRef}-{type}-{date}-{seq}`
- **BookingInvoiceService**: Service yang menangani logika pembuatan invoice (full, split, DP, pelunasan)
- **BookingPayment**: Entity pembayaran booking — single source of truth untuk semua pembayaran
- **DokuPaymentService**: Implementasi DOKU Checkout API yang sudah lengkap tapi belum ditest production
- **XenditPaymentService**: Implementasi Xendit yang sudah production-ready
- **PaymentGatewayFactory**: Factory pattern untuk switching antara Xendit dan DOKU berdasarkan konfigurasi
- **CommissionConfig**: Konfigurasi komisi platform dengan priority-based selection
- **QuestPDF**: Library .NET untuk generate PDF profesional
- **Resend**: Email delivery service yang sudah dikonfigurasi di platform
- **COA**: Chart of Accounts — struktur hierarki akun keuangan
- **GL**: General Ledger — buku besar pencatatan transaksi
- **AR**: Accounts Receivable — piutang dari customer
- **AP**: Accounts Payable — hutang ke supplier
- **Journal_Entry**: Pencatatan transaksi akuntansi dengan debit dan kredit
- **PPN**: Pajak Pertambahan Nilai (11%)
- **Amadeus_API**: Third-party GDS API untuk pencarian dan booking penerbangan
- **Funder**: Aktor/role baru — investor yang mendanai journey
- **FundingConfig**: Konfigurasi pendanaan pada journey (return percentage, funding phase toggle)
- **Bagi_Hasil**: Persentase return yang diberikan kepada funder setelah traveler membayar booking
- **IFRS**: International Financial Reporting Standards — standar pelaporan keuangan internasional
- **Accrual_Basis**: Metode akuntansi yang mencatat transaksi saat terjadi, bukan saat kas diterima/dibayar

## Requirements

---

### PRIORITAS 1-3: 🔴 URGENT / CRITICAL

---

### MODUL 1: Tech Debt — Calculation Improvements

### Requirement 1.1: Materiality dalam Kalkulasi Harga Journey

**User Story:** Sebagai agency, saya ingin harga journey dihitung berdasarkan materiality count ketika jumlah pax aktual kurang dari materiality, sehingga harga per-pax mencerminkan biaya minimum supplier.

#### Acceptance Criteria

1. WHEN jumlah pax aktual kurang dari nilai `Materiality` pada SupplierService, THE PriceCalculationService SHALL menghitung harga berdasarkan materiality count (bukan pax aktual)
2. WHEN jumlah pax aktual sama dengan atau lebih dari nilai `Materiality`, THE PriceCalculationService SHALL menghitung harga berdasarkan pax aktual
3. WHEN field `Materiality` bernilai null pada SupplierService, THE PriceCalculationService SHALL mengabaikan logika materiality dan menghitung berdasarkan pax aktual
4. THE PriceCalculationService SHALL menampilkan informasi materiality pada breakdown harga journey activity (materiality count, pax aktual, effective pax untuk kalkulasi)
5. WHEN materiality diterapkan, THE JourneyActivity SHALL menyimpan `effective_pax_count` yang digunakan dalam kalkulasi harga
6. FOR ALL kalkulasi harga dengan materiality, effective_pax_count SHALL selalu >= pax aktual (invariant property)

### Requirement 1.2: Negosiasi Full Payment Due Days

**User Story:** Sebagai agency, saya ingin bisa menegosiasikan jangka waktu pelunasan (`FullPaymentDueDays`) dengan supplier, sehingga saya mendapatkan fleksibilitas pembayaran yang lebih baik.

#### Acceptance Criteria

1. THE System SHALL menyediakan flow negosiasi antara agency dan supplier untuk `FullPaymentDueDays` pada saat pemilihan service di journey
2. WHEN agency memilih supplier service yang memiliki `PaymentTermsEnabled = true`, THE System SHALL menampilkan nilai default `FullPaymentDueDays` dari SupplierService
3. THE System SHALL memungkinkan agency mengajukan perubahan `FullPaymentDueDays` melalui negotiation request
4. WHEN supplier menerima negotiation request, THE System SHALL memperbarui `FullPaymentDueDays` pada JourneyActivity terkait
5. WHEN supplier menolak negotiation request, THE System SHALL mempertahankan nilai default `FullPaymentDueDays` dan memberitahu agency
6. THE System SHALL mencatat riwayat negosiasi (requested value, approved/rejected, timestamp, notes)
7. WHILE negosiasi berlangsung, THE JourneyActivity SHALL menampilkan status negosiasi: pending_negotiation, negotiation_approved, negotiation_rejected

### Requirement 1.3: Tipe Traveler (Adult/Child/Infant) dan Kalkulasi Harga

**User Story:** Sebagai agency, saya ingin sistem membedakan tipe traveler (adult, child, infant) dan menerapkan aturan harga berbeda per tipe, sehingga harga journey lebih akurat dan kompetitif.

#### Acceptance Criteria

1. THE System SHALL menambahkan field `TravelerType` (enum: Adult, Child, Infant) pada entity Traveler
2. WHEN `DateOfBirth` traveler diisi dan departure date diketahui, THE System SHALL mendeteksi otomatis TravelerType berdasarkan usia saat departure: Adult (≥12 tahun), Child (2-11 tahun), Infant (<2 tahun)
3. THE System SHALL memungkinkan override manual TravelerType oleh agency jika diperlukan
4. THE System SHALL menyediakan konfigurasi aturan harga per service type dan per TravelerType (contoh: infant = gratis untuk hotel, child = 50% untuk flight)
5. WHEN journey pricing dihitung, THE PriceCalculationService SHALL menerapkan diskon/aturan harga berdasarkan TravelerType masing-masing traveler
6. THE System SHALL menampilkan breakdown harga per TravelerType pada halaman journey detail (jumlah adult, child, infant beserta harga masing-masing)
7. IF TravelerType tidak dapat ditentukan karena `DateOfBirth` kosong, THEN THE System SHALL memperlakukan traveler sebagai Adult (default)
8. FOR ALL kalkulasi harga journey, total harga SHALL sama dengan penjumlahan harga per-traveler berdasarkan TravelerType masing-masing (calculation property)
9. FOR ALL auto-detection TravelerType, menghitung ulang dari DateOfBirth dan departure date SHALL menghasilkan TravelerType yang sama (idempotence property)

---

### MODUL 2: Payment Gateway — Production Flow Technical Test

### Requirement 2.1: End-to-End Production Test DOKU Payment Gateway

**User Story:** Sebagai tim teknis, saya ingin melakukan test end-to-end DOKU payment gateway di environment production, sehingga saya yakin flow pembayaran berjalan sempurna sebelum digunakan customer.

#### Acceptance Criteria

1. THE System SHALL mendukung test flow lengkap: create checkout → customer bayar → webhook diterima → status terupdate, menggunakan DOKU production environment
2. WHEN checkout DOKU dibuat, THE DokuPaymentService SHALL menghasilkan payment URL yang valid dan dapat diakses
3. WHEN pembayaran selesai di DOKU, THE System SHALL menerima webhook notification dan memverifikasi signature menggunakan `VerifyWebhookSignature`
4. WHEN webhook diterima dan valid, THE System SHALL memperbarui status pembayaran di database (BookingInvoice dan BookingPayment)
5. THE System SHALL mendukung test untuk subscription payments dan booking payments melalui DOKU
6. THE System SHALL memvalidasi bahwa signature generation (`GenerateSignature`) menghasilkan signature yang diterima oleh DOKU production API
7. IF webhook gagal diterima dalam 5 menit setelah pembayaran, THEN THE System SHALL menyediakan mekanisme manual reconciliation
8. THE System SHALL mencatat log lengkap setiap tahap test (request, response, webhook payload, status update) untuk keperluan debugging

---

### MODUL 3: Invoice & PDF Generation 🔴 CRITICAL

### Requirement 3.1: Setup PDF Generation Engine

**User Story:** Sebagai agency, saya ingin sistem menghasilkan dokumen PDF profesional untuk invoice dan receipt, sehingga saya bisa memberikan dokumen resmi kepada customer.

#### Acceptance Criteria

1. THE System SHALL mengintegrasikan QuestPDF (atau library PDF .NET sejenis) sebagai engine pembuatan PDF
2. THE PDF_Engine SHALL mendukung template design dengan branding agency (logo, nama, alamat, kontak)
3. THE PDF_Engine SHALL menghasilkan PDF dengan ukuran file kurang dari 2MB untuk invoice standar
4. THE PDF_Engine SHALL mendukung karakter Unicode (Bahasa Indonesia, Arab untuk nama-nama Umrah/Hajj)
5. THE PDF_Engine SHALL menghasilkan PDF dalam waktu kurang dari 3 detik per dokumen

### Requirement 3.2: Sistem Penomoran Invoice Baru

**User Story:** Sebagai agency, saya ingin sistem penomoran invoice yang terstruktur dan berurutan, sehingga mudah dilacak dan sesuai standar akuntansi.

#### Acceptance Criteria

1. THE Invoice_System SHALL menggunakan format penomoran baru: `INV-YYYYMM-NNNN` (contoh: INV-202604-0001)
2. THE Invoice_System SHALL menjamin nomor invoice berurutan (sequential) dalam satu bulan per agency
3. THE Invoice_System SHALL mereset counter ke 0001 setiap awal bulan baru
4. WHEN invoice baru dibuat, THE Invoice_System SHALL mengambil nomor urut berikutnya secara atomic (thread-safe)
5. THE Invoice_System SHALL menjamin keunikan nomor invoice dalam satu agency (unique constraint)
6. FOR ALL invoice dalam satu bulan, nomor urut SHALL berurutan tanpa gap (sequential property)

### Requirement 3.3: Kalkulasi Pajak (PPN 11%)

**User Story:** Sebagai agency, saya ingin invoice mencantumkan perhitungan pajak PPN 11% yang benar, sehingga sesuai dengan regulasi perpajakan Indonesia.

#### Acceptance Criteria

1. THE Tax_Calculation_Service SHALL menghitung PPN 11% dari DPP (Dasar Pengenaan Pajak)
2. THE Tax_Calculation_Service SHALL mendukung konfigurasi tarif PPN (default 11%, dapat diubah jika regulasi berubah)
3. THE Tax_Calculation_Service SHALL menampilkan breakdown pada invoice: subtotal, DPP, PPN, total
4. THE Tax_Calculation_Service SHALL mendukung opsi "harga sudah termasuk PPN" dan "harga belum termasuk PPN"
5. WHEN harga sudah termasuk PPN, THE Tax_Calculation_Service SHALL menghitung DPP = Total / 1.11 dan PPN = Total - DPP
6. WHEN harga belum termasuk PPN, THE Tax_Calculation_Service SHALL menghitung PPN = DPP × 11% dan Total = DPP + PPN
7. FOR ALL kalkulasi pajak, DPP + PPN SHALL sama dengan Total (round-trip calculation property)

### Requirement 3.4: Template PDF Invoice Profesional

**User Story:** Sebagai agency, saya ingin invoice PDF yang profesional dengan branding agency, sehingga meningkatkan citra bisnis saya.

#### Acceptance Criteria

1. THE Invoice_PDF SHALL menampilkan header dengan logo agency, nama, alamat, dan kontak
2. THE Invoice_PDF SHALL menampilkan informasi customer: nama, alamat, kontak
3. THE Invoice_PDF SHALL menampilkan nomor invoice, tanggal terbit, dan tanggal jatuh tempo
4. THE Invoice_PDF SHALL menampilkan detail item: nama layanan, jumlah, harga satuan, subtotal
5. THE Invoice_PDF SHALL menampilkan ringkasan: subtotal, diskon (jika ada), DPP, PPN, total
6. THE Invoice_PDF SHALL menampilkan informasi pembayaran: rekening bank, virtual account, atau QR code
7. THE Invoice_PDF SHALL menampilkan terms & conditions dan catatan tambahan
8. THE Invoice_PDF SHALL mendukung format A4 portrait dengan margin yang proporsional

### Requirement 3.5: Integrasi Email Delivery untuk Invoice

**User Story:** Sebagai agency, saya ingin invoice PDF dikirim otomatis ke email customer, sehingga customer menerima invoice tanpa proses manual.

#### Acceptance Criteria

1. WHEN invoice PDF berhasil di-generate, THE System SHALL mengirim email ke customer melalui Resend API
2. THE Email_System SHALL melampirkan file PDF invoice pada email
3. THE Email_System SHALL menggunakan template email profesional dengan branding agency
4. THE Email_System SHALL mencantumkan ringkasan invoice (nomor, total, jatuh tempo) di body email
5. IF pengiriman email gagal, THEN THE System SHALL mencoba ulang hingga 3 kali dengan exponential backoff
6. THE System SHALL mencatat status pengiriman email: sent, delivered, failed, bounced
7. THE System SHALL menyediakan opsi kirim ulang invoice secara manual dari dashboard agency

---

### PRIORITAS 4-7: 🟡 MEDIUM

---

### MODUL 4: Amadeus Integration

### Requirement 4.1: Pencarian Penerbangan via Amadeus GDS

**User Story:** Sebagai travel agent, saya ingin mencari penerbangan menggunakan Amadeus API, sehingga saya bisa menawarkan opsi penerbangan real-time kepada customer.

#### Acceptance Criteria

1. THE Flight_Search_System SHALL mengintegrasikan Amadeus Flight Offers Search API
2. THE Flight_Search_System SHALL mendukung pencarian one-way, round-trip, dan multi-city
3. THE Flight_Search_System SHALL menerima parameter pencarian: origin, destination, departure date, return date, jumlah penumpang (adult, child, infant), cabin class
4. THE Flight_Search_System SHALL mengembalikan opsi penerbangan dengan: airline, nomor penerbangan, waktu keberangkatan/kedatangan, durasi, harga, ketersediaan
5. THE Flight_Search_System SHALL mendukung filter berdasarkan: range harga, airline, jumlah transit, waktu keberangkatan
6. THE Flight_Search_System SHALL mendukung sorting berdasarkan: harga, durasi, waktu keberangkatan
7. THE Flight_Search_System SHALL meng-cache hasil pencarian selama 15 menit untuk mengurangi API calls
8. IF Amadeus API tidak tersedia, THEN THE Flight_Search_System SHALL menampilkan pesan error yang informatif kepada user

### Requirement 4.2: Booking Penerbangan via Amadeus GDS

**User Story:** Sebagai travel agent, saya ingin melakukan booking penerbangan melalui Amadeus API, sehingga saya bisa mengkonfirmasi reservasi customer secara instan.

#### Acceptance Criteria

1. THE Flight_Booking_System SHALL mengintegrasikan Amadeus Flight Booking API
2. THE Flight_Booking_System SHALL menerima detail penumpang: nama, tanggal lahir, nomor paspor, kewarganegaraan
3. WHEN booking penerbangan dikonfirmasi, THE Flight_Booking_System SHALL menerima PNR (booking reference) dari Amadeus
4. THE Flight_Booking_System SHALL menyimpan detail booking di database lokal dan menghubungkannya dengan JourneyActivity
5. THE Flight_Booking_System SHALL menghasilkan e-ticket dengan PNR dan detail penerbangan
6. IF booking gagal, THEN THE Flight_Booking_System SHALL melakukan rollback booking lokal dan memberitahu user dengan pesan error yang jelas
7. THE Flight_Booking_System SHALL mendukung pembatalan booking melalui Amadeus API

---

### MODUL 5: Upload Passport Readable (OCR)

### Requirement 5.1: Upload dan Parsing Passport

**User Story:** Sebagai travel agent, saya ingin mengupload foto passport dan data traveler terisi otomatis, sehingga proses input data lebih cepat dan akurat.

#### Acceptance Criteria

1. THE Passport_OCR_System SHALL menerima upload gambar passport dalam format JPEG, PNG, dan PDF
2. THE Passport_OCR_System SHALL menyimpan file gambar passport di MinIO storage
3. WHEN gambar passport diupload, THE Passport_OCR_System SHALL melakukan OCR/parsing pada Machine Readable Zone (MRZ) passport
4. THE Passport_OCR_System SHALL mengekstrak data dari MRZ: full name, date of birth, gender, nationality, passport number, passport expiry date, issuing country
5. WHEN data berhasil diekstrak, THE Passport_OCR_System SHALL mengisi otomatis field-field pada form Traveler
6. THE Passport_OCR_System SHALL menampilkan hasil ekstraksi untuk review dan konfirmasi oleh user sebelum disimpan
7. IF OCR gagal mengekstrak data, THEN THE Passport_OCR_System SHALL menampilkan pesan error dan memungkinkan input manual
8. THE Passport_OCR_System SHALL menyimpan gambar passport yang sudah diupload sebagai dokumen traveler (linked ke Traveler entity)
9. FOR ALL data yang diekstrak dari MRZ, parsing kemudian formatting kembali ke MRZ format SHALL menghasilkan data yang equivalent (round-trip property)

---

### MODUL 6: Funder Flow (Fitur Baru)

### Requirement 6.1: Role dan Entitas Funder

**User Story:** Sebagai platform admin, saya ingin menambahkan role FUNDER ke sistem, sehingga investor bisa mendanai journey dan mendapatkan bagi hasil.

#### Acceptance Criteria

1. THE Auth_System SHALL menambahkan role baru: FUNDER, dengan permission set yang terpisah dari Agency dan Supplier
2. THE System SHALL membuat entity baru: `FundingConfig` (konfigurasi pendanaan per journey), `FundingTransaction` (transaksi pendanaan), `FunderPayment` (pembayaran dari/ke funder)
3. THE System SHALL menyediakan halaman registrasi dan profil untuk FUNDER
4. THE System SHALL menerapkan RLS (Row-Level Security) pada semua entity terkait funder
5. THE FUNDER role SHALL hanya memiliki akses ke halaman: Funding List, My Investments, Payment History, Profile

### Requirement 6.2: Konfigurasi Pendanaan pada Journey

**User Story:** Sebagai agency, saya ingin mengkonfigurasi opsi pendanaan pada journey, sehingga journey bisa didanai oleh funder eksternal.

#### Acceptance Criteria

1. THE Journey_Create_Page SHALL menampilkan section "Funding Configuration" di bawah Pricing Summary
2. THE FundingConfig SHALL memiliki field: `ReturnPercentage` (decimal, persentase bagi hasil), `IsFundingPhase` (boolean, toggle aktif/nonaktif)
3. WHEN `IsFundingPhase` diset TRUE, THE Journey SHALL muncul di halaman "Funding List" yang hanya bisa diakses oleh FUNDER
4. THE System SHALL memvalidasi bahwa `ReturnPercentage` berada dalam range 0.1% - 50%
5. WHEN `IsFundingPhase` diset FALSE atau tidak dikonfigurasi, THE Journey SHALL tidak muncul di Funding List
6. THE FundingConfig SHALL menyimpan: journey_id, return_percentage, is_funding_phase, total_funding_needed (= BaseCost journey), funding_status (open, funded, closed)

### Requirement 6.3: Funding List dan Proses Pendanaan

**User Story:** Sebagai funder, saya ingin melihat daftar journey yang membutuhkan pendanaan dan memilih journey untuk didanai, sehingga saya bisa berinvestasi pada journey yang menarik.

#### Acceptance Criteria

1. THE Funding_List_Page SHALL menampilkan semua journey dengan `IsFundingPhase = true` dan `funding_status = open`
2. THE Funding_List_Page SHALL menampilkan informasi journey: nama, departure date, total funding needed, return percentage, agency name
3. WHEN funder memilih journey untuk didanai, THE System SHALL membuat FundingTransaction dengan status "pending_payment"
4. THE System SHALL mengarahkan funder ke payment gateway untuk melakukan pembayaran
5. WHEN pembayaran funder berhasil, THE System SHALL memperbarui FundingTransaction status menjadi "funded"
6. WHEN journey fully funded, THE System SHALL memperbarui FundingConfig.funding_status menjadi "funded"

### Requirement 6.4: Split Payment ke Supplier

**User Story:** Sebagai platform, saya ingin pembayaran funder langsung di-split ke supplier-supplier journey, sehingga semua layanan journey otomatis terbayar.

#### Acceptance Criteria

1. WHEN pembayaran funder diterima, THE System SHALL melakukan split payment langsung ke supplier-supplier berdasarkan JourneyActivity cost breakdown
2. THE System SHALL memperbarui PaymentStatus pada setiap JourneyActivity menjadi "fully_paid" setelah supplier menerima pembayaran
3. THE System SHALL mencatat setiap split payment sebagai FunderPayment dengan detail: funder_id, supplier_id, journey_activity_id, amount, status
4. IF split payment ke salah satu supplier gagal, THEN THE System SHALL mencoba ulang dan mencatat error untuk reconciliation manual
5. THE System SHALL mengirim notifikasi ke setiap supplier ketika pembayaran dari funder diterima

### Requirement 6.5: Kalkulasi dan Release Bagi Hasil

**User Story:** Sebagai funder, saya ingin menerima bagi hasil setelah traveler membayar booking, sehingga saya mendapatkan return dari investasi saya.

#### Acceptance Criteria

1. WHEN traveler menyelesaikan pembayaran booking pada journey yang didanai, THE System SHALL menghitung bagi hasil berdasarkan `ReturnPercentage` dari FundingConfig
2. THE System SHALL menghitung bagi hasil dari profit journey: (SellingPrice - BaseCost) × ReturnPercentage
3. WHEN semua booking pada journey sudah fully_paid, THE System SHALL merelease bagi hasil ke funder melalui payment gateway (disbursement)
4. THE System SHALL mencatat bagi hasil sebagai FunderPayment dengan type "bagi_hasil"
5. THE System SHALL menampilkan dashboard funder dengan: total invested, total bagi hasil received, pending bagi hasil, ROI percentage
6. FOR ALL bagi hasil, jumlah yang direlease SHALL sama dengan (total profit journey × return percentage) (calculation property)

---

### MODUL 7: Finance & Accounting (Accrual Basis — IFRS 19) 🔴 CRITICAL

### Requirement 7.1: Chart of Accounts (COA) dengan Hierarki 5 Level

**User Story:** Sebagai akuntan agency, saya ingin mengelola chart of accounts dengan hierarki hingga 5 level, sehingga saya bisa mengorganisir transaksi keuangan secara sistematis.

#### Acceptance Criteria

1. THE COA_System SHALL mendukung tipe akun: Asset, Liability, Equity, Revenue, Expense
2. THE COA_System SHALL mendukung hierarki akun parent-child hingga 5 level kedalaman
3. WHEN agency baru dibuat, THE COA_System SHALL melakukan seeding akun default untuk operasi travel agency
4. THE COA_System SHALL menjamin keunikan kode akun dalam satu agency
5. WHEN akun memiliki child accounts, THE COA_System SHALL mencegah posting langsung ke parent account
6. THE COA_System SHALL mendukung aktivasi dan deaktivasi akun
7. FOR ALL hierarki akun, traversal dari child ke root SHALL menghasilkan path yang valid (tree property)

### Requirement 7.2: General Ledger (GL) dengan Journal Entries

**User Story:** Sebagai akuntan agency, saya ingin mencatat journal entries di general ledger, sehingga saya bisa memelihara catatan keuangan yang akurat sesuai standar akuntansi accrual.

#### Acceptance Criteria

1. THE GL_System SHALL mendukung pembuatan journal entry manual dengan multiple line items
2. WHEN journal entry dibuat, THE GL_System SHALL memvalidasi kesamaan total debit dan kredit
3. THE GL_System SHALL auto-generate journal entries dari event booking (revenue recognition — accrual basis)
4. THE GL_System SHALL auto-generate journal entries dari event supplier bill (expense recognition — accrual basis)
5. WHEN journal entry diposting, THE GL_System SHALL memperbarui saldo akun secara atomic
6. THE GL_System SHALL mendukung reversal journal entry dengan audit trail
7. THE GL_System SHALL mencatat tanggal transaksi (transaction date) terpisah dari tanggal posting (posting date) sesuai prinsip accrual
8. FOR ALL journal entries, total debit SHALL sama dengan total kredit (accounting equation property)
9. FOR ALL saldo akun, menerapkan semua journal entries dalam urutan apapun SHALL menghasilkan saldo akhir yang sama (confluence property)

### Requirement 7.3: Auto-Generate Journal Entries dari Event Bisnis

**User Story:** Sebagai akuntan agency, saya ingin journal entries otomatis terbuat dari event booking dan supplier bill, sehingga pencatatan keuangan selalu up-to-date tanpa input manual.

#### Acceptance Criteria

1. WHEN booking dikonfirmasi, THE GL_System SHALL membuat journal entry: Debit AR (Piutang Customer) — Credit Revenue (Pendapatan)
2. WHEN pembayaran customer diterima (BookingPayment created), THE GL_System SHALL membuat journal entry: Debit Cash/Bank — Credit AR (Piutang Customer)
3. WHEN supplier bill dibuat, THE GL_System SHALL membuat journal entry: Debit Expense (Biaya Layanan) — Credit AP (Hutang Supplier)
4. WHEN pembayaran ke supplier dilakukan, THE GL_System SHALL membuat journal entry: Debit AP (Hutang Supplier) — Credit Cash/Bank
5. THE GL_System SHALL menggunakan mapping akun yang dapat dikonfigurasi per tipe transaksi
6. FOR ALL auto-generated journal entries, total debit SHALL sama dengan total kredit (balance property)

### Requirement 7.4: Accounts Receivable (AR) dengan Aging Report

**User Story:** Sebagai akuntan agency, saya ingin melacak piutang customer dengan aging report, sehingga saya bisa mengelola arus kas secara efektif.

#### Acceptance Criteria

1. WHEN booking dikonfirmasi, THE AR_System SHALL otomatis membuat record piutang customer yang terhubung ke booking
2. THE AR_System SHALL menghitung jumlah piutang dari pricing booking
3. WHEN pembayaran customer dicatat, THE AR_System SHALL memperbarui saldo piutang dan membuat GL journal entry
4. THE AR_System SHALL melacak status piutang: Draft, Sent, Partially_Paid, Paid, Overdue
5. THE AR_System SHALL menghitung aging buckets: Current, 1-30 hari, 31-60 hari, 61-90 hari, >90 hari
6. THE AR_System SHALL mendukung partial payment dengan alokasi pembayaran
7. THE AR_System SHALL menghasilkan Aging Report yang dapat di-export ke PDF dan Excel
8. FOR ALL piutang, total pembayaran SHALL TIDAK melebihi jumlah piutang (invariant property)

### Requirement 7.5: Accounts Payable (AP) dengan Aging Report

**User Story:** Sebagai akuntan agency, saya ingin melacak hutang ke supplier dengan aging report, sehingga saya bisa mengelola kewajiban pembayaran secara akurat.

#### Acceptance Criteria

1. THE AP_System SHALL meningkatkan entity SupplierBill yang sudah ada dengan approval workflow
2. THE AP_System SHALL mendukung status bill: Draft, Pending_Approval, Approved, Partially_Paid, Paid
3. WHEN supplier bill diapprove, THE AP_System SHALL membuat GL journal entry untuk expense recognition
4. WHEN pembayaran ke supplier dicatat, THE AP_System SHALL memperbarui saldo hutang dan membuat GL journal entry
5. THE AP_System SHALL menghitung aging buckets untuk hutang: Current, 1-30 hari, 31-60 hari, 61-90 hari, >90 hari
6. THE AP_System SHALL mendukung partial payment dengan alokasi pembayaran
7. THE AP_System SHALL menghasilkan Aging Report yang dapat di-export ke PDF dan Excel
8. FOR ALL supplier bills, total pembayaran SHALL TIDAK melebihi jumlah bill (invariant property)

---

### PRIORITAS 8-9: 🟢 LOW

---

### MODUL 8: B2B Marketplace Enhancement

### Requirement 8.1: Rating & Review System

**User Story:** Sebagai agency (buyer), saya ingin memberikan rating dan review untuk layanan supplier, sehingga marketplace memiliki sistem kepercayaan yang transparan.

#### Acceptance Criteria

1. WHEN booking selesai (status = completed), THE System SHALL memungkinkan agency memberikan rating (1-5 bintang) dan review teks untuk setiap supplier service yang digunakan
2. THE System SHALL memvalidasi bahwa hanya agency yang telah menggunakan service yang bisa memberikan review
3. THE System SHALL menampilkan rata-rata rating dan jumlah review pada halaman supplier service
4. THE System SHALL mendukung reply dari supplier terhadap review
5. THE System SHALL mencegah duplikasi review (satu review per booking per service)
6. FOR ALL rating, nilai SHALL berada dalam range 1-5 (invariant property)

### Requirement 8.2: Dispute Resolution Workflow

**User Story:** Sebagai agency, saya ingin mengajukan dispute jika ada masalah dengan layanan supplier, sehingga ada mekanisme penyelesaian yang adil.

#### Acceptance Criteria

1. WHEN ada masalah dengan layanan, THE System SHALL memungkinkan agency membuat dispute ticket dengan kategori: quality_issue, pricing_dispute, service_not_delivered, other
2. THE System SHALL mendukung workflow dispute: Open, Under_Review, Resolved, Escalated, Closed
3. WHEN dispute dibuat, THE System SHALL memberitahu supplier dan platform admin
4. THE System SHALL mendukung komunikasi antara agency dan supplier dalam dispute thread
5. THE System SHALL mendukung lampiran bukti (gambar, dokumen) pada dispute
6. WHEN dispute di-resolve, THE System SHALL mencatat resolusi dan memperbarui status

### Requirement 8.3: Marketplace Analytics Dashboard

**User Story:** Sebagai platform admin, saya ingin melihat analytics marketplace, sehingga saya bisa memantau performa dan mengambil keputusan strategis.

#### Acceptance Criteria

1. THE Analytics_Dashboard SHALL menampilkan metrik: total transaksi, total revenue, total komisi platform
2. THE Analytics_Dashboard SHALL menampilkan top suppliers berdasarkan revenue dan rating
3. THE Analytics_Dashboard SHALL menampilkan top agencies berdasarkan volume transaksi
4. THE Analytics_Dashboard SHALL mendukung filter berdasarkan periode waktu (daily, weekly, monthly, yearly)
5. THE Analytics_Dashboard SHALL menampilkan trend grafik untuk transaksi dan revenue

---

### MODUL 9: Reporting & Analytics

### Requirement 9.1: Laporan Keuangan

**User Story:** Sebagai manager agency, saya ingin menghasilkan laporan keuangan standar, sehingga saya bisa menganalisis performa bisnis dan memenuhi kewajiban pelaporan.

#### Acceptance Criteria

1. THE Financial_Report_System SHALL menghasilkan Trial Balance dengan kolom debit dan kredit
2. THE Financial_Report_System SHALL menghasilkan Balance Sheet (Neraca) dengan section: Assets, Liabilities, Equity
3. THE Financial_Report_System SHALL menghasilkan Income Statement (Laba Rugi) dengan section: Revenue, Expenses, Net Income
4. THE Financial_Report_System SHALL mendukung filter berdasarkan range tanggal untuk semua laporan
5. THE Financial_Report_System SHALL mendukung export ke PDF dan Excel
6. FOR ALL Balance Sheet, total Assets SHALL sama dengan total Liabilities + Equity (accounting equation property)
7. FOR ALL Trial Balance, total debit SHALL sama dengan total kredit (balance property)

### Requirement 9.2: Laporan Operasional

**User Story:** Sebagai manager agency, saya ingin melihat laporan operasional (sales, profitability, customer, supplier), sehingga saya bisa mengoptimalkan operasi bisnis.

#### Acceptance Criteria

1. THE Report_System SHALL menghasilkan Sales Report: revenue per periode, per journey, per agent
2. THE Report_System SHALL menghasilkan Profitability Report: margin analysis per booking (selling price vs base cost)
3. THE Report_System SHALL menghasilkan Customer Report: top customers, total spending, retention rate
4. THE Report_System SHALL menghasilkan Supplier Report: top suppliers, total payment, performance rating
5. THE Report_System SHALL mendukung filter berdasarkan range tanggal dan dimensi lainnya
6. THE Report_System SHALL mendukung export ke PDF dan Excel

---

## Cross-Module Requirements

### Requirement 10.1: Multi-Tenant Data Isolation

**User Story:** Sebagai platform administrator, saya ingin memastikan isolasi data antar agency, sehingga keamanan data terjaga.

#### Acceptance Criteria

1. THE System SHALL menerapkan Row-Level Security (RLS) untuk semua tabel Phase 2 baru
2. THE System SHALL memfilter data berdasarkan agency_id dari JWT token context
3. THE System SHALL mencegah akses data lintas agency melalui API endpoints
4. THE System SHALL memvalidasi agency_id pada semua CQRS commands dan queries

### Requirement 10.2: Audit Trail

**User Story:** Sebagai compliance officer, saya ingin melacak semua transaksi keuangan, sehingga saya bisa memenuhi kepatuhan audit.

#### Acceptance Criteria

1. THE System SHALL mencatat semua operasi create, update, delete untuk entity keuangan (COA, GL, AR, AP, Invoice)
2. THE System SHALL menyimpan audit log dengan: user ID, timestamp, action type, entity type, entity ID, old values, new values
3. THE System SHALL mendukung query audit log berdasarkan range tanggal, user, dan tipe entity
4. THE System SHALL menyimpan audit log minimal selama 7 tahun

### Requirement 10.3: Performance Requirements

**User Story:** Sebagai pengguna sistem, saya ingin response time yang cepat, sehingga saya bisa bekerja secara efisien.

#### Acceptance Criteria

1. THE System SHALL merespon API requests dalam 500ms untuk persentil ke-95
2. THE System SHALL memuat halaman dashboard dalam 2 detik untuk persentil ke-95
3. THE System SHALL menghasilkan PDF invoice dalam waktu kurang dari 3 detik
4. THE System SHALL menghasilkan laporan keuangan dalam waktu kurang dari 10 detik untuk data 1 tahun
5. THE System SHALL menangani 100 concurrent users tanpa degradasi performa

---

## ❌ EXCLUDED dari Phase 2

- **Asosiasi BERPAHALA**: Akan menjadi proyek terpisah
- **HR & Payroll Module**: Dipindahkan ke phase berikutnya
- **Inventory Management**: Dipindahkan ke phase berikutnya
- **Budgeting & Cost Control**: Dipindahkan ke phase berikutnya
- **Enhanced Notification System (SMS/WhatsApp)**: Dipindahkan ke phase berikutnya
- **Bank Reconciliation**: Dipindahkan ke phase berikutnya

---

## Success Criteria

### Kriteria Penyelesaian Phase 2

1. Semua 9 modul berfungsi penuh dan teruji
2. DOKU payment gateway berhasil ditest end-to-end di production
3. Invoice PDF ter-generate dengan format profesional dan penomoran baru
4. Kalkulasi materiality dan TravelerType berjalan benar di journey pricing
5. Amadeus flight search dan booking mengembalikan hasil real-time
6. Funder flow berjalan end-to-end: funding → split payment → bagi hasil
7. Finance module (COA, GL, AR, AP) menghasilkan data akurat
8. Laporan keuangan (Trial Balance, Balance Sheet, Income Statement) akurat
9. Semua fitur Phase 1 tetap berfungsi normal
10. Performa sistem memenuhi requirements yang ditentukan
11. Tidak ada bug critical atau high-severity di production
