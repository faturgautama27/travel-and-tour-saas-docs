# Implementation Plan: Phase 2 ERP Modules — Tour & Travel SaaS

## Overview

Rencana implementasi untuk 9 modul Phase 2 platform Tour & Travel SaaS. Modul dikelompokkan berdasarkan prioritas bisnis: Prioritas 1-3 (🔴 URGENT), Prioritas 4-7 (🟡 MEDIUM), Prioritas 8-9 (🟢 LOW). Stack: .NET 8 (C#), Angular 20, PostgreSQL 16, EF Core 8, CQRS + MediatR, Clean Architecture.

## Tasks

---

### 🔴 PRIORITAS 1-3: URGENT / CRITICAL

---

- [ ] 1. Modul 1: Tech Debt — Materiality Pricing
  - [ ] 1.1 Tambahkan field baru pada entity `JourneyActivity`: `EffectivePaxCount` (int), `IsMaterialityApplied` (bool). Buat EF Core migration untuk PostgreSQL.
    - Modifikasi entity `JourneyActivity` di Domain layer
    - Buat migration file via `dotnet ef migrations add AddMaterialityFieldsToJourneyActivity`
    - _Requirements: 1.1.5_

  - [ ] 1.2 Implementasi `IMaterialityPriceCalculationService` — extend `PriceCalculationService` yang sudah ada dengan logika materiality: `effectivePaxCount = max(actualPax, materiality ?? actualPax)`. Return `MaterialityPriceResult` dengan breakdown lengkap.
    - Buat interface `IMaterialityPriceCalculationService` dan implementasi `MaterialityPriceCalculationService`
    - Logika: jika `Materiality` null → abaikan, jika pax < materiality → gunakan materiality count
    - Register service di DI container
    - _Requirements: 1.1.1, 1.1.2, 1.1.3, 1.1.4, 1.1.6_

  - [ ]* 1.3 Tulis property test untuk materiality effective pax calculation (Property 1)
    - **Property 1: Materiality effective pax calculation**
    - Gunakan FsCheck: untuk semua `actualPax` (≥1) dan `materiality` (nullable int), verifikasi `effectivePaxCount == max(actualPax, materiality ?? actualPax)` dan `effectivePaxCount >= actualPax`
    - **Validates: Requirements 1.1.1, 1.1.2, 1.1.3, 1.1.6**

  - [ ] 1.4 Buat MediatR Command `RecalculateJourneyPricingCommand` dan handler untuk menghitung ulang harga journey dengan materiality. Integrasikan dengan endpoint existing journey pricing.
    - Buat command, validator (FluentValidation), dan handler
    - Update API controller endpoint yang sudah ada
    - _Requirements: 1.1.1, 1.1.4_

  - [ ]* 1.5 Tulis unit tests untuk `MaterialityPriceCalculationService` — test edge cases: materiality null, pax = materiality, pax > materiality, pax < materiality
    - _Requirements: 1.1.1, 1.1.2, 1.1.3_

- [ ] 2. Modul 1: Tech Debt — Negosiasi FullPaymentDueDays
  - [ ] 2.1 Buat entity `NegotiationRequest` di Domain layer dengan field: `Id`, `JourneyActivityId`, `AgencyId`, `SupplierId`, `RequestedDays`, `OriginalDays`, `ApprovedDays`, `Status` (enum: Pending, Approved, Rejected), `AgencyNotes`, `SupplierNotes`, `RequestedAt`, `RespondedAt`. Tambahkan field `NegotiationStatus` dan `NegotiatedFullPaymentDueDays` pada `JourneyActivity`. Buat EF Core migration.
    - Buat entity, enum, dan EF Core configuration (Fluent API)
    - Tambahkan DbSet di ApplicationDbContext
    - Terapkan RLS filter berdasarkan `AgencyId`
    - _Requirements: 1.2.1, 1.2.6, 1.2.7_

      - [ ] 2.2 Implementasi `INegotiationService` dengan method: `CreateNegotiationAsync`, `RespondNegotiationAsync`, `GetNegotiationHistoryAsync`. Validasi bahwa service memiliki `PaymentTermsEnabled = true` sebelum negosiasi.
    - Buat interface dan implementasi service
    - Throw `BusinessRuleException` jika `PaymentTermsEnabled` false
    - Update `JourneyActivity.NegotiationStatus` sesuai response
    - _Requirements: 1.2.2, 1.2.3, 1.2.4, 1.2.5, 1.2.6_

  - [ ] 2.3 Buat MediatR Commands dan Queries: `CreateNegotiationCommand`, `RespondNegotiationCommand`, `GetNegotiationHistoryQuery`. Buat API controller `NegotiationsController` dengan endpoints CRUD.
    - Buat commands, queries, validators, dan handlers
    - Buat `NegotiationsController` dengan endpoint: POST create, PUT respond, GET history
    - _Requirements: 1.2.1, 1.2.3, 1.2.4, 1.2.5_

  - [ ]* 2.4 Tulis unit tests untuk `NegotiationService` — test flow: create → approve, create → reject, create tanpa PaymentTermsEnabled
    - _Requirements: 1.2.2, 1.2.4, 1.2.5_

- [ ] 3. Modul 1: Tech Debt — TravelerType dan Kalkulasi Harga
  - [ ] 3.1 Tambahkan enum `TravelerType` (Adult, Child, Infant) di Domain layer. Tambahkan field `TravelerType` dan `IsManualOverride` pada entity `Traveler`. Buat entity `TravelerTypePricingRule` dengan field: `AgencyId`, `ServiceType`, `TravelerType`, `DiscountType` (percentage/fixed/free), `DiscountValue`, `IsActive`. Buat EF Core migration.
    - Buat enum, modifikasi entity Traveler, buat entity TravelerTypePricingRule
    - Konfigurasi EF Core Fluent API dan DbSet
    - Terapkan RLS pada TravelerTypePricingRule
    - _Requirements: 1.3.1, 1.3.4_

  - [ ] 3.2 Implementasi `ITravelerTypeService` dengan method `DetectTravelerType(DateOfBirth, DepartureDate)`: Adult ≥12 tahun, Child 2-11 tahun, Infant <2 tahun. Default ke Adult jika DateOfBirth null. Implementasi `CalculateTravelerPriceAsync` untuk menerapkan pricing rule berdasarkan TravelerType.
    - Buat interface dan implementasi service
    - Logika auto-detection berdasarkan age bracket
    - Logika pricing: lookup TravelerTypePricingRule, apply discount
    - _Requirements: 1.3.2, 1.3.3, 1.3.5, 1.3.7_

  - [ ]* 3.3 Tulis property test untuk TravelerType auto-detection (Property 2)
    - **Property 2: TravelerType auto-detection deterministic dan sesuai age bracket**
    - Gunakan FsCheck: untuk semua DateOfBirth dan DepartureDate valid, verifikasi age bracket benar dan idempotence
    - **Validates: Requirements 1.3.2, 1.3.7, 1.3.9**

  - [ ]* 3.4 Tulis property test untuk total harga journey = sum harga per-traveler (Property 3)
    - **Property 3: TravelerType pricing — total harga journey = sum harga per-traveler**
    - Gunakan FsCheck: untuk semua list travelers dengan TravelerType dan pricing rules, verifikasi total = sum individual
    - **Validates: Requirements 1.3.5, 1.3.8**

  - [ ] 3.5 Buat MediatR Commands dan Queries: `DetectTravelerTypeCommand`, `UpdateTravelerTypeCommand`, `GetTravelerTypePricingRulesQuery`, `UpsertTravelerTypePricingRuleCommand`. Buat/update API endpoints.
    - Buat commands, queries, validators, handlers
    - Integrasikan auto-detection ke flow existing Traveler creation/update
    - Buat endpoint CRUD untuk TravelerTypePricingRule
    - _Requirements: 1.3.2, 1.3.3, 1.3.4, 1.3.6_

  - [ ]* 3.6 Tulis unit tests untuk `TravelerTypeService` — test: age boundary (tepat 2 tahun, tepat 12 tahun), null DateOfBirth, manual override, pricing calculation
    - _Requirements: 1.3.2, 1.3.5, 1.3.7_

- [ ] 4. Checkpoint — Pastikan semua tests Modul 1 pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Modul 2: Payment Gateway — DOKU Production Test
  - [ ] 5.1 Implementasi `IDokuProductionTestService` dengan method `RunEndToEndTestAsync`: orchestrate flow create checkout → generate signature → verify payment URL valid. Implementasi `ManualReconciliationAsync` untuk fallback jika webhook tidak diterima dalam 5 menit.
    - Buat interface dan implementasi service
    - Gunakan `DokuPaymentService` dan `PaymentGatewayFactory` yang sudah ada
    - Tambahkan comprehensive logging di setiap tahap (request, response, webhook payload)
    - _Requirements: 2.1.1, 2.1.2, 2.1.6, 2.1.7, 2.1.8_

  - [ ] 5.2 Buat endpoint webhook handler untuk DOKU production: verifikasi signature via `VerifyWebhookSignature`, update status `BookingInvoice` dan `BookingPayment`. Tambahkan logging lengkap.
    - Buat/update webhook controller endpoint
    - Validasi signature, return HTTP 400 jika invalid
    - Update payment status di database secara atomic
    - _Requirements: 2.1.3, 2.1.4, 2.1.8_

  - [ ] 5.3 Buat MediatR Command `RunDokuProductionTestCommand` dan API endpoint `POST /api/admin/payment-gateway/doku-test` untuk trigger test. Buat `ManualReconciliationCommand` dan endpoint untuk reconciliation manual.
    - Buat commands, handlers, dan controller endpoints
    - Endpoint hanya accessible oleh admin role
    - Support test untuk subscription dan booking payments
    - _Requirements: 2.1.1, 2.1.5, 2.1.7_

  - [ ]* 5.4 Tulis unit tests untuk DOKU webhook signature verification dan status update flow
    - _Requirements: 2.1.3, 2.1.4_

- [ ] 6. Modul 3: Invoice & PDF — Setup Engine dan Penomoran
  - [ ] 6.1 Tambahkan NuGet package QuestPDF. Buat entity `InvoiceSequence` (AgencyId, Year, Month, LastSequence) dan entity `Invoice` (InvoiceNumber format `INV-YYYYMM-NNNN`, InvoiceDate, DueDate, Subtotal, DiscountAmount, DPP, PPNRate, PPNAmount, TotalAmount, IsTaxInclusive, Status, PdfUrl). Buat entity `InvoiceLineItem` (InvoiceId, Description, Quantity, UnitPrice, Subtotal, SortOrder). Buat EF Core migration dengan unique constraint pada InvoiceNumber per agency.
    - Tambahkan QuestPDF ke project dependencies
    - Buat entities, enums, EF Core configurations
    - Terapkan RLS dan unique constraint
    - _Requirements: 3.1.1, 3.2.1, 3.2.5_

  - [ ] 6.2 Implementasi `IInvoiceNumberGenerator` — atomic sequential number generation menggunakan `SELECT FOR UPDATE` pada tabel `InvoiceSequence`. Format: `INV-YYYYMM-NNNN`, reset counter setiap awal bulan baru.
    - Buat interface dan implementasi service
    - Gunakan database-level locking untuk thread-safety
    - Auto-create InvoiceSequence record jika belum ada untuk bulan tersebut
    - _Requirements: 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.2.5_

  - [ ]* 6.3 Tulis property test untuk invoice numbering (Property 4)
    - **Property 4: Invoice numbering — sequential, gapless, unique, dan format valid**
    - Gunakan FsCheck: untuk N invoice dalam satu agency/bulan, verifikasi sequential 0001..N, gapless, unique, format valid
    - **Validates: Requirements 3.2.1, 3.2.2, 3.2.5, 3.2.6**

  - [ ] 6.4 Implementasi `ITaxCalculationService` — kalkulasi PPN 11% dengan dukungan mode tax-inclusive dan tax-exclusive. Invariant: `DPP + PPN == Total`. Tax rate configurable (default 11%).
    - Buat interface dan implementasi service
    - Mode inclusive: `DPP = Total / (1 + rate)`, `PPN = Total - DPP`
    - Mode exclusive: `PPN = DPP × rate`, `Total = DPP + PPN`
    - Gunakan rounding strategy yang konsisten (banker's rounding)
    - _Requirements: 3.3.1, 3.3.2, 3.3.4, 3.3.5, 3.3.6_

  - [ ]* 6.5 Tulis property test untuk tax calculation (Property 5)
    - **Property 5: Tax calculation — DPP + PPN = Total (invariant)**
    - Gunakan FsCheck: untuk semua amount > 0 dan kedua mode, verifikasi `DPP + PPN == Total`
    - **Validates: Requirements 3.3.1, 3.3.4, 3.3.5, 3.3.6, 3.3.7**

  - [ ]* 6.6 Tulis unit tests untuk `TaxCalculationService` dan `InvoiceNumberGenerator` — test edge cases: amount 0, concurrent generation, month rollover
    - _Requirements: 3.2.3, 3.3.5, 3.3.6_

- [ ] 7. Modul 3: Invoice & PDF — Template dan Email Delivery
  - [ ] 7.1 Implementasi `IPdfInvoiceService` menggunakan QuestPDF — buat template PDF invoice profesional dengan: header (logo agency, nama, alamat, kontak), info customer, nomor invoice, tanggal terbit/jatuh tempo, detail items (tabel), ringkasan (subtotal, diskon, DPP, PPN, total), info pembayaran, terms & conditions. Format A4 portrait, support Unicode (Bahasa Indonesia, Arab).
    - Buat interface dan implementasi service
    - Buat QuestPDF document template class
    - Load agency branding dari database (logo, nama, alamat)
    - Pastikan file size < 2MB dan generation time < 3 detik
    - _Requirements: 3.1.2, 3.1.3, 3.1.4, 3.1.5, 3.4.1, 3.4.2, 3.4.3, 3.4.4, 3.4.5, 3.4.6, 3.4.7, 3.4.8_

  - [ ] 7.2 Buat entity `EmailDeliveryLog` (InvoiceId, RecipientEmail, Status, RetryCount, SentAt, LastRetryAt). Implementasi `IInvoiceEmailService` — kirim invoice PDF via Resend API dengan template email profesional. Implementasi retry logic (max 3 kali, exponential backoff). Catat status pengiriman.
    - Buat entity dan EF Core migration
    - Buat interface dan implementasi service
    - Integrasikan dengan Resend API yang sudah dikonfigurasi
    - Implementasi background retry mechanism
    - _Requirements: 3.5.1, 3.5.2, 3.5.3, 3.5.4, 3.5.5, 3.5.6_

  - [ ] 7.3 Buat MediatR Commands dan Queries: `GenerateInvoiceCommand`, `SendInvoiceEmailCommand`, `ResendInvoiceEmailCommand`, `GetInvoiceQuery`, `GetInvoiceListQuery`. Buat `InvoicesController` dengan endpoints: POST generate, POST send-email, POST resend-email, GET by id, GET list.
    - Buat commands, queries, validators, handlers
    - Buat controller dengan endpoints lengkap
    - Endpoint resend untuk kirim ulang manual dari dashboard
    - _Requirements: 3.5.1, 3.5.7_

  - [ ]* 7.4 Tulis unit tests untuk `PdfInvoiceService` dan `InvoiceEmailService` — test: PDF generation, email send success/failure, retry logic
    - _Requirements: 3.1.5, 3.5.5, 3.5.6_

- [ ] 8. Checkpoint — Pastikan semua tests Modul 2 dan 3 pass
  - Ensure all tests pass, ask the user if questions arise.

---

### 🟡 PRIORITAS 4-7: MEDIUM

---

- [ ] 9. Modul 4: Amadeus Integration — Flight Search
  - [ ] 9.1 Buat konfigurasi Amadeus API client: registrasi HttpClient di DI, konfigurasi API key/secret dari appsettings, implementasi OAuth2 token management (client credentials flow).
    - Buat `AmadeusApiClient` class dengan HttpClient
    - Konfigurasi base URL, credentials, dan token refresh
    - Buat `AmadeusOptions` configuration class
    - _Requirements: 4.1.1_

  - [ ] 9.2 Implementasi `IAmadeusFlightSearchService` — integrasi Amadeus Flight Offers Search API. Support pencarian one-way, round-trip, multi-city. Parameter: origin, destination, departure date, return date, jumlah penumpang (adult/child/infant), cabin class. Return hasil dengan: airline, nomor penerbangan, waktu, durasi, harga, ketersediaan.
    - Buat interface, request/response DTOs, dan implementasi service
    - Map Amadeus API response ke domain model `FlightSearchResult`
    - Implementasi filter (harga, airline, transit, waktu) dan sorting (harga, durasi, waktu)
    - _Requirements: 4.1.2, 4.1.3, 4.1.4, 4.1.5, 4.1.6_

  - [ ] 9.3 Implementasi caching layer untuk hasil pencarian penerbangan — cache selama 15 menit menggunakan IMemoryCache atau IDistributedCache. Cache key berdasarkan search parameters.
    - Buat caching decorator atau middleware
    - Cache invalidation setelah 15 menit
    - Fallback ke API call jika cache miss
    - _Requirements: 4.1.7_

  - [ ] 9.4 Buat MediatR Query `SearchFlightsQuery` dan handler. Buat `FlightsController` dengan endpoint `GET /api/flights/search`. Handle Amadeus API unavailable dengan error message informatif.
    - Buat query, validator, handler, dan controller
    - Return user-friendly error jika API unavailable
    - _Requirements: 4.1.1, 4.1.8_

  - [ ]* 9.5 Tulis unit tests untuk `AmadeusFlightSearchService` — test: search parameters mapping, response parsing, cache hit/miss, API error handling
    - _Requirements: 4.1.2, 4.1.7, 4.1.8_

- [ ] 10. Modul 4: Amadeus Integration — Flight Booking
  - [ ] 10.1 Implementasi `IAmadeusFlightBookingService` — integrasi Amadeus Flight Booking API. Method `CreateBookingAsync`: terima detail penumpang (nama, tanggal lahir, paspor, kewarganegaraan), return PNR. Method `CancelBookingAsync`: pembatalan booking via Amadeus API.
    - Buat interface, request/response DTOs, dan implementasi service
    - Simpan booking detail di database lokal, hubungkan ke `JourneyActivity`
    - Implementasi rollback local booking jika Amadeus booking gagal
    - _Requirements: 4.2.1, 4.2.2, 4.2.3, 4.2.4, 4.2.6, 4.2.7_

  - [ ] 10.2 Buat MediatR Commands: `CreateFlightBookingCommand`, `CancelFlightBookingCommand`. Buat endpoints di `FlightsController`: POST booking, DELETE booking. Generate e-ticket dengan PNR dan detail penerbangan.
    - Buat commands, validators, handlers
    - Buat endpoint untuk create dan cancel booking
    - Generate e-ticket document
    - _Requirements: 4.2.3, 4.2.5, 4.2.7_

  - [ ]* 10.3 Tulis unit tests untuk `AmadeusFlightBookingService` — test: booking success, booking failure + rollback, cancellation
    - _Requirements: 4.2.3, 4.2.6, 4.2.7_

- [ ] 11. Modul 5: Passport OCR — Upload dan MRZ Parsing
  - [ ] 11.1 Implementasi `IMrzParserService` — parsing Machine Readable Zone (MRZ) passport. Method `ParseMrz`: ekstrak full name, date of birth, gender, nationality, passport number, passport expiry, issuing country dari MRZ text. Method `FormatToMrz`: format MrzData kembali ke MRZ string.
    - Buat interface, `MrzData` record, dan implementasi service
    - Implementasi parsing sesuai ICAO 9303 MRZ format (TD3 untuk passport)
    - Handle check digit validation
    - _Requirements: 5.1.4, 5.1.9_

  - [ ]* 11.2 Tulis property test untuk MRZ round-trip (Property 6)
    - **Property 6: MRZ round-trip — parse kemudian format menghasilkan data equivalent**
    - Gunakan FsCheck: untuk semua valid `MrzData`, `ParseMrz(FormatToMrz(data))` menghasilkan data equivalent
    - **Validates: Requirements 5.1.9**

  - [ ] 11.3 Implementasi `IPassportOcrService` — upload gambar passport ke MinIO, jalankan OCR/MRZ extraction. Support format JPEG, PNG, PDF. Return `OcrResult` dengan extracted data dan confidence score.
    - Buat interface dan implementasi service
    - Integrasikan dengan MinIO storage untuk file upload
    - Gunakan MRZ parser library atau Tesseract OCR untuk text extraction
    - Handle OCR failure: return partial result + error message
    - _Requirements: 5.1.1, 5.1.2, 5.1.3, 5.1.7_

  - [ ] 11.4 Buat MediatR Commands: `UploadPassportCommand`, `ConfirmPassportDataCommand`. Buat `PassportController` dengan endpoints: POST upload (multipart/form-data), POST confirm. Auto-fill Traveler fields dari extracted data setelah user confirmation.
    - Buat commands, validators, handlers, dan controller
    - Endpoint upload: terima file, jalankan OCR, return extracted data untuk review
    - Endpoint confirm: simpan data ke Traveler entity, link gambar passport
    - _Requirements: 5.1.5, 5.1.6, 5.1.8_

  - [ ]* 11.5 Tulis unit tests untuk `MrzParserService` — test: valid MRZ parsing, invalid MRZ handling, edge cases (nama panjang, karakter khusus)
    - _Requirements: 5.1.4, 5.1.7_

- [ ] 12. Checkpoint — Pastikan semua tests Modul 4 dan 5 pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 13. Modul 6: Funder Flow — Role, Entity, dan Konfigurasi
  - [ ] 13.1 Tambahkan role `FUNDER` ke Auth system. Buat entity `Funder` (UserId, CompanyName, ContactPerson, Phone, Email, BankAccountNumber, BankName, Status). Buat entity `FundingConfig` (JourneyId, ReturnPercentage, IsFundingPhase, TotalFundingNeeded, FundingStatus). Buat entity `FundingTransaction` (FundingConfigId, FunderId, Amount, Status, PaymentReference, FundedAt). Buat entity `FunderPayment` (FundingTransactionId, FunderId, SupplierId, JourneyActivityId, Amount, PaymentType, Status, CompletedAt). Buat EF Core migration. Terapkan RLS pada semua entity baru.
    - Buat entities, enums, EF Core configurations
    - Tambahkan FUNDER role ke permission system
    - Konfigurasi RLS policies
    - Buat halaman registrasi dan profil funder
    - _Requirements: 6.1.1, 6.1.2, 6.1.3, 6.1.4, 6.1.5_

  - [ ] 13.2 Implementasi `IFundingService` — method `ConfigureFundingAsync`: validasi `ReturnPercentage` dalam range [0.1, 50.0], set `TotalFundingNeeded` = BaseCost journey. Tambahkan section "Funding Configuration" pada journey creation flow.
    - Buat interface dan implementasi service
    - Validasi range ReturnPercentage
    - Toggle IsFundingPhase untuk menampilkan/sembunyikan di Funding List
    - _Requirements: 6.2.1, 6.2.2, 6.2.3, 6.2.4, 6.2.5, 6.2.6_

  - [ ]* 13.3 Tulis property test untuk ReturnPercentage validation (Property 8)
    - **Property 8: ReturnPercentage validation — range 0.1% sampai 50%**
    - Gunakan FsCheck: verifikasi validasi menerima [0.1, 50.0] dan menolak di luar range
    - **Validates: Requirements 6.2.4**

  - [ ]* 13.4 Tulis property test untuk funding list filtering (Property 7)
    - **Property 7: Funding list filtering — journey muncul iff IsFundingPhase = true**
    - Gunakan FsCheck: untuk semua FundingConfig, journey muncul di list iff `IsFundingPhase == true` dan `FundingStatus == "open"`
    - **Validates: Requirements 6.2.3, 6.2.5**

- [ ] 14. Modul 6: Funder Flow — Pendanaan, Split Payment, dan Bagi Hasil
  - [ ] 14.1 Implementasi funding transaction flow: `CreateFundingTransactionAsync` (buat transaksi pending), `ProcessFundingPaymentAsync` (proses pembayaran via payment gateway). Buat Funding List page query yang menampilkan journey dengan `IsFundingPhase = true` dan `FundingStatus = open`.
    - Implementasi method di `FundingService`
    - Integrasikan dengan `PaymentGatewayFactory` untuk pembayaran funder
    - Update `FundingConfig.FundingStatus` ke "funded" saat fully funded
    - _Requirements: 6.3.1, 6.3.2, 6.3.3, 6.3.4, 6.3.5, 6.3.6_

  - [ ] 14.2 Implementasi `IFunderSplitPaymentService` — split pembayaran funder ke supplier-supplier berdasarkan JourneyActivity cost breakdown. Buat `FunderPayment` record per supplier. Implementasi retry logic jika split payment gagal. Kirim notifikasi ke supplier.
    - Buat interface dan implementasi service
    - Split berdasarkan proporsi cost per JourneyActivity
    - Update `PaymentStatus` pada JourneyActivity ke "fully_paid"
    - Retry + log untuk manual reconciliation jika gagal
    - _Requirements: 6.4.1, 6.4.2, 6.4.3, 6.4.4, 6.4.5_

  - [ ] 14.3 Implementasi kalkulasi dan release bagi hasil: `CalculateBagiHasilAsync` — hitung `(SellingPrice - BaseCost) × ReturnPercentage / 100`. `ReleaseBagiHasilAsync` — disbursement ke funder via payment gateway saat semua booking fully_paid. Buat funder dashboard: total invested, total bagi hasil, pending, ROI.
    - Implementasi method di `FundingService`
    - Buat `FunderPayment` dengan type "bagi_hasil"
    - Buat query untuk funder dashboard metrics
    - _Requirements: 6.5.1, 6.5.2, 6.5.3, 6.5.4, 6.5.5_

  - [ ]* 14.4 Tulis property test untuk bagi hasil calculation (Property 9)
    - **Property 9: Bagi hasil calculation — amount = profit × return percentage**
    - Gunakan FsCheck: untuk semua SellingPrice, BaseCost, ReturnPercentage, verifikasi `bagiHasil == (SellingPrice - BaseCost) × ReturnPercentage / 100`
    - **Validates: Requirements 6.5.1, 6.5.2, 6.5.6**

  - [ ] 14.5 Buat MediatR Commands dan Queries: `ConfigureFundingCommand`, `CreateFundingTransactionCommand`, `ProcessFundingPaymentCommand`, `CalculateBagiHasilQuery`, `ReleaseBagiHasilCommand`, `GetFundingListQuery`, `GetFunderDashboardQuery`. Buat `FundingController` dan `FunderController` dengan endpoints lengkap.
    - Buat commands, queries, validators, handlers
    - Buat controllers dengan endpoints untuk agency (configure funding) dan funder (list, invest, dashboard)
    - _Requirements: 6.2.1, 6.3.1, 6.5.5_

  - [ ]* 14.6 Tulis unit tests untuk `FundingService` dan `FunderSplitPaymentService` — test: funding flow end-to-end, split payment calculation, bagi hasil edge cases (zero profit)
    - _Requirements: 6.3.3, 6.4.1, 6.5.2_

- [ ] 15. Modul 7: Finance — Chart of Accounts (COA)
  - [ ] 15.1 Buat entity `COA` (AgencyId, ParentId nullable self-ref, AccountCode, AccountName, AccountType enum: Asset/Liability/Equity/Revenue/Expense, Level 1-5, IsActive, IsPostable). Buat entity `AccountMappingConfig` (AgencyId, TransactionType, DebitAccountId, CreditAccountId). Buat EF Core migration dengan unique constraint pada AccountCode per agency. Terapkan RLS.
    - Buat entities, enums, EF Core configurations
    - Self-referencing relationship untuk parent-child hierarchy
    - Unique constraint: (AgencyId, AccountCode)
    - _Requirements: 7.1.1, 7.1.2, 7.1.4_

  - [ ] 15.2 Implementasi `IChartOfAccountsService` — method `CreateAccountAsync` (validasi level ≤ 5, unique code), `SeedDefaultAccountsAsync` (seeding akun default untuk travel agency baru), `GetAccountTreeAsync` (return hierarki tree), `ValidatePostingAccountAsync` (return false jika akun punya children). Auto-set `IsPostable = false` saat akun mendapat child baru.
    - Buat interface dan implementasi service
    - Buat default COA seed data untuk travel agency
    - Implementasi tree traversal dan validation
    - _Requirements: 7.1.2, 7.1.3, 7.1.5, 7.1.6_

  - [ ]* 15.3 Tulis property test untuk COA tree traversal (Property 10)
    - **Property 10: COA tree — traversal dari child ke root menghasilkan valid path**
    - Gunakan FsCheck: untuk semua akun, parent traversal mencapai root tanpa cycle, depth ≤ 5
    - **Validates: Requirements 7.1.2, 7.1.7**

  - [ ]* 15.4 Tulis property test untuk COA posting restriction (Property 11)
    - **Property 11: COA posting restriction — parent account tidak bisa di-posting**
    - Gunakan FsCheck: untuk semua akun dengan children, posting SHALL ditolak; hanya leaf accounts boleh posting
    - **Validates: Requirements 7.1.5**

  - [ ] 15.5 Buat MediatR Commands dan Queries: `CreateCOACommand`, `UpdateCOACommand`, `DeactivateCOACommand`, `GetCOATreeQuery`, `SeedDefaultCOACommand`, `UpsertAccountMappingCommand`. Buat `ChartOfAccountsController` dengan endpoints CRUD.
    - Buat commands, queries, validators, handlers, dan controller
    - _Requirements: 7.1.1, 7.1.3, 7.1.6_

  - [ ]* 15.6 Tulis unit tests untuk `ChartOfAccountsService` — test: create account, hierarchy validation, seeding, posting validation
    - _Requirements: 7.1.2, 7.1.4, 7.1.5_

- [ ] 16. Modul 7: Finance — General Ledger (GL) dan Auto-Journal
  - [ ] 16.1 Buat entity `JournalEntry` (AgencyId, EntryNumber, TransactionDate, PostingDate, Description, Source enum, SourceEntityId, Status, ReversedFromId, CreatedBy). Buat entity `JournalEntryLine` (JournalEntryId, AccountId FK ke COA, DebitAmount, CreditAmount, Description). Buat entity `AccountBalance` (AccountId, AgencyId, Year, Month, DebitTotal, CreditTotal, Balance). Buat EF Core migration. Terapkan RLS.
    - Buat entities, enums, EF Core configurations
    - Foreign key dari JournalEntryLine ke COA
    - _Requirements: 7.2.1, 7.2.7_

  - [ ] 16.2 Implementasi `IGeneralLedgerService` — method `CreateJournalEntryAsync`: validasi total debit == total kredit (throw `BusinessRuleException` jika tidak balanced), validasi semua akun adalah leaf (postable), update `AccountBalance` secara atomic. Method `ReverseJournalEntryAsync`: buat reversal entry dengan audit trail, validasi entry belum pernah di-reverse.
    - Buat interface dan implementasi service
    - Validasi balance constraint sebelum save
    - Atomic update account balances
    - Support reversal dengan linked reference
    - _Requirements: 7.2.1, 7.2.2, 7.2.5, 7.2.6, 7.2.7_

  - [ ]* 16.3 Tulis property test untuk journal entry balance (Property 12)
    - **Property 12: Journal entry balance — total debit = total kredit**
    - Gunakan FsCheck: untuk semua journal entries, verifikasi sum(debit) == sum(credit), reject jika tidak balanced
    - **Validates: Requirements 7.2.2, 7.2.8, 7.3.6**

  - [ ]* 16.4 Tulis property test untuk account balance confluence (Property 13)
    - **Property 13: Account balance confluence — urutan journal entries tidak mempengaruhi saldo akhir**
    - Gunakan FsCheck: untuk set journal entries, apply dalam berbagai urutan permutasi, verifikasi saldo akhir identik
    - **Validates: Requirements 7.2.9**

  - [ ] 16.5 Implementasi `IAutoJournalService` — event handlers untuk auto-generate journal entries: `HandleBookingConfirmedAsync` (DR: AR, CR: Revenue), `HandlePaymentReceivedAsync` (DR: Cash, CR: AR), `HandleSupplierBillApprovedAsync` (DR: Expense, CR: AP), `HandleSupplierPaymentAsync` (DR: AP, CR: Cash). Gunakan `AccountMappingConfig` untuk lookup akun.
    - Buat interface dan implementasi service
    - Register sebagai MediatR notification handlers untuk domain events
    - Lookup debit/credit accounts dari AccountMappingConfig per transaction type
    - _Requirements: 7.3.1, 7.3.2, 7.3.3, 7.3.4, 7.3.5_

  - [ ] 16.6 Buat MediatR Commands dan Queries: `CreateJournalEntryCommand`, `ReverseJournalEntryCommand`, `GetJournalEntriesQuery`, `GetAccountBalanceQuery`. Buat `GeneralLedgerController` dengan endpoints.
    - Buat commands, queries, validators, handlers, dan controller
    - _Requirements: 7.2.1, 7.2.6_

  - [ ]* 16.7 Tulis unit tests untuk `GeneralLedgerService` dan `AutoJournalService` — test: balanced entry, unbalanced rejection, reversal, auto-journal dari events
    - _Requirements: 7.2.2, 7.2.6, 7.3.1, 7.3.2_

- [ ] 17. Modul 7: Finance — Accounts Receivable (AR)
  - [ ] 17.1 Buat entity `ARRecord` (AgencyId, BookingId, CustomerId, InvoiceNumber, OriginalAmount, PaidAmount, BalanceDue, Status enum: Draft/Sent/Partially_Paid/Paid/Overdue, DueDate). Buat EF Core migration. Terapkan RLS.
    - Buat entity, enum, EF Core configuration
    - _Requirements: 7.4.1, 7.4.4_

  - [ ] 17.2 Implementasi `IAccountsReceivableService` — method `CreateReceivableAsync`: auto-create AR record saat booking dikonfirmasi. Method `ApplyPaymentAsync`: update PaidAmount dan BalanceDue, validasi payment ≤ OriginalAmount (throw `BusinessRuleException` jika melebihi), buat GL journal entry. Method `GenerateAgingReportAsync`: hitung aging buckets (Current, 1-30, 31-60, 61-90, >90 hari).
    - Buat interface dan implementasi service
    - Integrasikan dengan domain event `BookingConfirmedEvent`
    - Support partial payment dengan alokasi
    - Generate aging report exportable ke PDF dan Excel
    - _Requirements: 7.4.1, 7.4.2, 7.4.3, 7.4.5, 7.4.6, 7.4.7_

  - [ ]* 17.3 Tulis property test untuk AR payment invariant (Property 14)
    - **Property 14: AR payment invariant — total pembayaran ≤ jumlah piutang**
    - Gunakan FsCheck: untuk semua ARRecord dan serangkaian ApplyPayment, verifikasi PaidAmount ≤ OriginalAmount
    - **Validates: Requirements 7.4.8**

  - [ ] 17.4 Buat MediatR Commands dan Queries: `ApplyARPaymentCommand`, `GetARListQuery`, `GetARAgingReportQuery`, `ExportARAgingReportCommand`. Buat `AccountsReceivableController` dengan endpoints.
    - Buat commands, queries, validators, handlers, dan controller
    - Endpoint export ke PDF dan Excel
    - _Requirements: 7.4.3, 7.4.7_

  - [ ]* 17.5 Tulis unit tests untuk `AccountsReceivableService` — test: create receivable, apply payment, partial payment, overpayment rejection, aging calculation
    - _Requirements: 7.4.2, 7.4.5, 7.4.6, 7.4.8_

- [ ] 18. Modul 7: Finance — Accounts Payable (AP)
  - [ ] 18.1 Buat entity `APRecord` (AgencyId, SupplierBillId, SupplierId, BillNumber, OriginalAmount, PaidAmount, BalanceDue, Status enum: Draft/Pending_Approval/Approved/Partially_Paid/Paid, DueDate). Buat EF Core migration. Terapkan RLS. Enhance entity `SupplierBill` yang sudah ada dengan approval workflow fields.
    - Buat entity, enum, EF Core configuration
    - Modifikasi SupplierBill entity untuk approval workflow
    - _Requirements: 7.5.1, 7.5.2_

  - [ ] 18.2 Implementasi `IAccountsPayableService` — method `CreatePayableAsync`: create AP record dari supplier bill. Method `ApplyPaymentAsync`: update PaidAmount dan BalanceDue, validasi payment ≤ OriginalAmount, buat GL journal entry saat bill diapprove dan saat pembayaran. Method `GenerateAgingReportAsync`: hitung aging buckets.
    - Buat interface dan implementasi service
    - Integrasikan dengan approval workflow
    - GL journal entry saat approve: DR Expense, CR AP
    - GL journal entry saat payment: DR AP, CR Cash
    - Support partial payment
    - _Requirements: 7.5.2, 7.5.3, 7.5.4, 7.5.5, 7.5.6, 7.5.7_

  - [ ]* 18.3 Tulis property test untuk AP payment invariant (Property 15)
    - **Property 15: AP payment invariant — total pembayaran ≤ jumlah bill**
    - Gunakan FsCheck: untuk semua APRecord dan serangkaian ApplyPayment, verifikasi PaidAmount ≤ OriginalAmount
    - **Validates: Requirements 7.5.8**

  - [ ] 18.4 Buat MediatR Commands dan Queries: `ApproveSupplierBillCommand`, `ApplyAPPaymentCommand`, `GetAPListQuery`, `GetAPAgingReportQuery`, `ExportAPAgingReportCommand`. Buat `AccountsPayableController` dengan endpoints.
    - Buat commands, queries, validators, handlers, dan controller
    - Endpoint export ke PDF dan Excel
    - _Requirements: 7.5.2, 7.5.3, 7.5.7_

  - [ ]* 18.5 Tulis unit tests untuk `AccountsPayableService` — test: create payable, approval workflow, apply payment, overpayment rejection, aging calculation
    - _Requirements: 7.5.3, 7.5.4, 7.5.6, 7.5.8_

- [ ] 19. Checkpoint — Pastikan semua tests Modul 6 dan 7 pass
  - Ensure all tests pass, ask the user if questions arise.

---

### 🟢 PRIORITAS 8-9: LOW

---

- [ ] 20. Modul 8: B2B Marketplace — Rating, Review, dan Dispute
  - [ ] 20.1 Buat entity `Review` (AgencyId, SupplierServiceId, BookingId, Rating 1-5, ReviewText, CreatedAt). Buat entity `ReviewReply` (ReviewId, SupplierId, ReplyText, CreatedAt). Buat entity `Dispute` (AgencyId, SupplierId, BookingId, Category enum, Status enum, Resolution, CreatedAt, ResolvedAt). Buat entity `DisputeMessage` (DisputeId, SenderId, SenderRole, Message, CreatedAt). Buat entity `DisputeAttachment` (DisputeMessageId, FileName, FileUrl, FileType). Buat EF Core migration. Terapkan RLS.
    - Buat entities, enums, EF Core configurations
    - Unique constraint: satu review per booking per service
    - _Requirements: 8.1.1, 8.1.5, 8.2.1_

  - [ ] 20.2 Implementasi `IReviewService` — method `CreateReviewAsync`: validasi agency telah menggunakan service (booking completed), validasi rating 1-5, cegah duplikasi. Method `ReplyToReviewAsync`: hanya supplier yang bisa reply. Method `GetServiceReviewSummaryAsync`: hitung rata-rata rating dan jumlah review.
    - Buat interface dan implementasi service
    - Validasi booking status = completed sebelum review
    - Hitung average rating: sum(ratings) / count(ratings)
    - _Requirements: 8.1.1, 8.1.2, 8.1.3, 8.1.4, 8.1.5_

  - [ ]* 20.3 Tulis property test untuk rating range invariant (Property 16)
    - **Property 16: Rating range invariant — nilai rating 1-5**
    - Gunakan FsCheck: untuk semua review, verifikasi Rating dalam range [1, 5]
    - **Validates: Requirements 8.1.6**

  - [ ]* 20.4 Tulis property test untuk review average calculation (Property 19)
    - **Property 19: Review average calculation**
    - Gunakan FsCheck: untuk set ratings, verifikasi average == sum(ratings) / count(ratings)
    - **Validates: Requirements 8.1.3**

  - [ ] 20.5 Implementasi `IDisputeService` — method `CreateDisputeAsync`: buat dispute ticket dengan kategori, notifikasi supplier dan admin. Method `UpdateDisputeStatusAsync`: workflow transition (Open → Under_Review → Resolved/Escalated → Closed). Method `AddMessageAsync`: komunikasi dalam dispute thread, support lampiran via MinIO.
    - Buat interface dan implementasi service
    - Implementasi state machine untuk dispute workflow
    - Upload attachment ke MinIO
    - Kirim notifikasi ke pihak terkait
    - _Requirements: 8.2.1, 8.2.2, 8.2.3, 8.2.4, 8.2.5, 8.2.6_

  - [ ] 20.6 Buat MediatR Commands dan Queries untuk Review dan Dispute. Buat `ReviewsController` dan `DisputesController` dengan endpoints CRUD lengkap.
    - Buat commands, queries, validators, handlers, dan controllers
    - _Requirements: 8.1.1, 8.2.1_

  - [ ]* 20.7 Tulis unit tests untuk `ReviewService` dan `DisputeService` — test: create review, duplicate prevention, reply, dispute workflow transitions
    - _Requirements: 8.1.2, 8.1.5, 8.2.2_

- [ ] 21. Modul 8: B2B Marketplace — Analytics Dashboard
  - [ ] 21.1 Implementasi queries untuk marketplace analytics: total transaksi, total revenue, total komisi platform, top suppliers (by revenue dan rating), top agencies (by volume). Support filter berdasarkan periode (daily, weekly, monthly, yearly). Buat trend data untuk grafik.
    - Buat query handlers dengan aggregation queries ke PostgreSQL
    - Optimasi dengan materialized views atau pre-computed summaries jika diperlukan
    - _Requirements: 8.3.1, 8.3.2, 8.3.3, 8.3.4, 8.3.5_

  - [ ] 21.2 Buat MediatR Queries: `GetMarketplaceAnalyticsQuery`, `GetTopSuppliersQuery`, `GetTopAgenciesQuery`, `GetTransactionTrendQuery`. Buat `MarketplaceAnalyticsController` dengan endpoints. Endpoint hanya accessible oleh platform admin.
    - Buat queries, handlers, dan controller
    - _Requirements: 8.3.1, 8.3.4_

  - [ ]* 21.3 Tulis unit tests untuk marketplace analytics queries — test: aggregation accuracy, filter by period, empty data handling
    - _Requirements: 8.3.1, 8.3.4_

- [ ] 22. Modul 9: Reporting & Analytics — Laporan Keuangan
  - [ ] 22.1 Implementasi `IFinancialReportService` — method `GenerateTrialBalanceAsync`: generate Trial Balance dari AccountBalance data, kolom debit dan kredit. Method `GenerateBalanceSheetAsync`: generate Balance Sheet dengan section Assets, Liabilities, Equity. Method `GenerateIncomeStatementAsync`: generate Income Statement dengan section Revenue, Expenses, Net Income. Support filter range tanggal.
    - Buat interface, report DTOs, dan implementasi service
    - Query AccountBalance dan JournalEntryLine untuk aggregation
    - Pastikan generation time < 10 detik untuk data 1 tahun
    - _Requirements: 9.1.1, 9.1.2, 9.1.3, 9.1.4_

  - [ ] 22.2 Implementasi export laporan keuangan ke PDF (via QuestPDF) dan Excel. Buat template PDF profesional untuk setiap jenis laporan.
    - Implementasi `ExportToPdfAsync` dan `ExportToExcelAsync` di `FinancialReportService`
    - Buat QuestPDF templates untuk Trial Balance, Balance Sheet, Income Statement
    - _Requirements: 9.1.5_

  - [ ]* 22.3 Tulis property test untuk Balance Sheet accounting equation (Property 17)
    - **Property 17: Balance Sheet accounting equation — Assets = Liabilities + Equity**
    - Gunakan FsCheck: untuk semua Balance Sheet yang di-generate, verifikasi total Assets == total Liabilities + total Equity
    - **Validates: Requirements 9.1.6**

  - [ ]* 22.4 Tulis property test untuk Trial Balance (Property 18)
    - **Property 18: Trial Balance — total debit = total kredit**
    - Gunakan FsCheck: untuk semua Trial Balance, verifikasi total kolom debit == total kolom kredit
    - **Validates: Requirements 9.1.7**

  - [ ] 22.5 Buat MediatR Queries: `GetTrialBalanceQuery`, `GetBalanceSheetQuery`, `GetIncomeStatementQuery`, `ExportFinancialReportCommand`. Buat `FinancialReportsController` dengan endpoints.
    - Buat queries, commands, handlers, dan controller
    - _Requirements: 9.1.1, 9.1.5_

  - [ ]* 22.6 Tulis unit tests untuk `FinancialReportService` — test: trial balance accuracy, balance sheet equation, income statement calculation, empty period
    - _Requirements: 9.1.1, 9.1.2, 9.1.3_

- [ ] 23. Modul 9: Reporting & Analytics — Laporan Operasional
  - [ ] 23.1 Implementasi `IOperationalReportService` — method `GenerateSalesReportAsync` (revenue per periode/journey/agent), `GenerateProfitabilityReportAsync` (margin analysis per booking), `GenerateCustomerReportAsync` (top customers, spending, retention), `GenerateSupplierReportAsync` (top suppliers, payment, rating). Support filter range tanggal dan dimensi lainnya. Support export ke PDF dan Excel.
    - Buat interface, report DTOs, dan implementasi service
    - Query data dari booking, payment, dan review tables
    - Buat QuestPDF templates untuk setiap laporan
    - _Requirements: 9.2.1, 9.2.2, 9.2.3, 9.2.4, 9.2.5, 9.2.6_

  - [ ] 23.2 Buat MediatR Queries: `GetSalesReportQuery`, `GetProfitabilityReportQuery`, `GetCustomerReportQuery`, `GetSupplierReportQuery`, `ExportOperationalReportCommand`. Buat `OperationalReportsController` dengan endpoints.
    - Buat queries, commands, handlers, dan controller
    - _Requirements: 9.2.1, 9.2.5, 9.2.6_

  - [ ]* 23.3 Tulis unit tests untuk `OperationalReportService` — test: sales aggregation, profitability margin calculation, empty data handling
    - _Requirements: 9.2.1, 9.2.2_

- [ ] 24. Checkpoint — Pastikan semua tests Modul 8 dan 9 pass
  - Ensure all tests pass, ask the user if questions arise.

---

### CROSS-MODULE: Audit Trail, RLS, dan Integrasi

---

- [ ] 25. Cross-Module: Audit Trail dan Multi-Tenant RLS
  - [ ] 25.1 Buat entity `AuditLog` (AgencyId, UserId, ActionType enum: Create/Update/Delete, EntityType, EntityId, OldValues JSON, NewValues JSON, Timestamp). Buat EF Core migration. Implementasi `IAuditTrailService` dengan method `LogAsync` dan `QueryAsync` (support filter tanggal, user, entity type). Konfigurasi retensi data minimal 7 tahun.
    - Buat entity, EF Core configuration
    - Implementasi service dengan pagination
    - Integrasikan sebagai EF Core interceptor atau MediatR pipeline behavior untuk auto-logging pada entity keuangan (COA, JournalEntry, ARRecord, APRecord, Invoice)
    - _Requirements: 10.2.1, 10.2.2, 10.2.3, 10.2.4_

  - [ ] 25.2 Verifikasi dan terapkan Row-Level Security (RLS) pada semua entity baru Phase 2. Pastikan semua CQRS commands dan queries memfilter berdasarkan `AgencyId` dari JWT token context. Buat integration test untuk validasi isolasi data antar agency.
    - Review semua entity baru dan pastikan RLS policy terpasang
    - Validasi semua query handlers menggunakan agency filter
    - Buat test untuk cross-agency data access prevention
    - _Requirements: 10.1.1, 10.1.2, 10.1.3, 10.1.4_

  - [ ]* 25.3 Tulis integration tests untuk RLS enforcement dan audit trail — test: cross-agency access blocked, audit log created on financial entity changes
    - _Requirements: 10.1.3, 10.2.1_

- [ ] 26. Cross-Module: Wiring dan Integrasi Antar Modul
  - [ ] 26.1 Integrasikan semua domain events antar modul: `BookingConfirmedEvent` → auto-create AR + auto-journal, `PaymentReceivedEvent` → update AR + auto-journal, `BillApprovedEvent` → auto-create AP + auto-journal, `SupplierPaymentEvent` → update AP + auto-journal. Pastikan event handlers terdaftar di MediatR pipeline.
    - Wire semua event handlers di DI registration
    - Verifikasi event flow end-to-end
    - _Requirements: 7.3.1, 7.3.2, 7.3.3, 7.3.4_

  - [ ] 26.2 Integrasikan Invoice module dengan Finance module: saat invoice dibuat → link ke AR record, saat invoice dibayar → trigger payment event. Integrasikan TravelerType pricing dengan Invoice line items.
    - Wire invoice creation ke AR creation
    - Wire payment recording ke AR update dan GL journal
    - Pastikan pricing breakdown per TravelerType muncul di invoice
    - _Requirements: 3.4.4, 3.4.5, 7.4.1_

  - [ ]* 26.3 Tulis integration tests untuk cross-module event flow — test: booking confirmed → AR created + journal entry created, payment received → AR updated + journal entry created
    - _Requirements: 7.3.1, 7.3.2, 7.4.1_

- [ ] 27. Final Checkpoint — Pastikan semua tests pass dan semua modul terintegrasi
  - Ensure all tests pass, ask the user if questions arise.
  - Verifikasi semua 9 modul berfungsi dan terintegrasi
  - Verifikasi performa: API response < 500ms (p95), PDF generation < 3 detik, report generation < 10 detik
  - _Requirements: 10.3.1, 10.3.2, 10.3.3, 10.3.4, 10.3.5_

## Notes

- Tasks bertanda `*` bersifat opsional dan bisa di-skip untuk MVP lebih cepat
- Setiap task mereferensikan requirements spesifik untuk traceability
- Checkpoints memastikan validasi inkremental di setiap fase
- Property tests memvalidasi correctness properties universal dari design document
- Unit tests memvalidasi contoh spesifik dan edge cases
- Gunakan FsCheck sebagai library property-based testing untuk .NET 8
- Semua entity baru HARUS menerapkan RLS berdasarkan AgencyId
- Semua operasi write HARUS melalui MediatR Command pipeline (validation + transaction)