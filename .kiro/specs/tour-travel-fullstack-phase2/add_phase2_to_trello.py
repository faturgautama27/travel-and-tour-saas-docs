"""
Script untuk import semua task Phase 2 Jourva ERP ke Trello board yang sudah ada.

Usage:
1. Install dependencies: pip3 install requests
2. Set credentials:
   export TRELLO_API_KEY=api_key_kamu
   export TRELLO_TOKEN=token_kamu
   export TRELLO_BOARD_ID=board_id_kamu
3. Jalankan: python3 add_phase2_to_trello.py
"""

import requests
import os
import time

# ============================================================
# KONFIGURASI — credentials dari environment variables
# ============================================================

API_KEY = os.environ.get("TRELLO_API_KEY", "")
TOKEN = os.environ.get("TRELLO_TOKEN", "")
BOARD_ID = os.environ.get("TRELLO_BOARD_ID", "")

TARGET_LIST_NAME = "Backlog All Task"
SPRINT_LABEL_NAME = "Sprint 8 W16"
BASE_URL = "https://api.trello.com/1"

# ============================================================
# DATA TASKS
# ============================================================

TASKS = [
    {"title": "Materiality dalam Kalkulasi Harga Journey [BE]", "label": "Backend", "due_date": "2026-04-25", "checklist": [
        "Enhance PriceCalculationService: jika pax < Materiality, hitung berdasarkan materiality count",
        "Tambah field EffectivePaxCount (int?) pada JourneyActivity entity",
        "Buat migration untuk field baru",
        "Update journey cost calculation untuk menggunakan effective pax",
        "Tambah materiality info pada price breakdown DTO",
        "Update VisaTransportPricingService untuk support materiality",
        "Write unit tests: pax < materiality, pax >= materiality, materiality null",
        "Invariant test: effective_pax_count >= pax aktual",
    ]},
    {"title": "Negosiasi Full Payment Due Days [BE]", "label": "Backend", "due_date": "2026-04-26", "checklist": [
        "Buat entity PaymentTermsNegotiation",
        "Buat migration untuk tabel baru",
        "Tambah field NegotiationStatus pada JourneyActivity",
        "Buat CreateNegotiationRequestCommand (agency side)",
        "Buat ApproveNegotiationCommand + RejectNegotiationCommand (supplier side)",
        "Update JourneyActivity.FullPaymentDueDate berdasarkan negotiated value",
        "Buat GetNegotiationHistoryQuery",
        "Kirim notifikasi ke supplier saat request dibuat",
        "Kirim notifikasi ke agency saat approved/rejected",
        "Write unit tests",
    ]},
    {"title": "Tipe Traveler (Adult/Child/Infant) dan Kalkulasi Harga [BE]", "label": "Backend", "due_date": "2026-04-27", "checklist": [
        "Buat enum TravelerType: Adult, Child, Infant",
        "Tambah field TravelerType pada Traveler entity + migration",
        "Implementasi auto-detection berdasarkan DOB vs departure date",
        "Buat entity TravelerTypePricingRule + migration + seed default rules",
        "Update PriceCalculationService untuk apply pricing rules per TravelerType",
        "Tambah breakdown harga per TravelerType pada journey pricing DTO",
        "Default ke Adult jika DateOfBirth kosong",
        "Allow manual override TravelerType oleh agency",
        "Write unit tests + idempotence test",
    ]},
    {"title": "UI Materiality, Negosiasi Payment, dan Traveler Type [FE]", "label": "Frontend", "due_date": "2026-04-27", "checklist": [
        "Tampilkan materiality info pada journey activity card",
        "Warning badge jika pax < materiality",
        "Tampilkan breakdown harga per TravelerType di journey detail page",
        "Auto-detect TravelerType saat input DateOfBirth di form traveler",
        "Dropdown override TravelerType (Adult/Child/Infant)",
        "Section negosiasi payment terms di journey activity detail",
        "Form Request Different Terms dengan input FullPaymentDueDays + notes",
        "Status badge negosiasi (pending, approved, rejected)",
        "Supplier side: approval/rejection UI untuk negosiasi",
        "Update NGXS store untuk negotiation state",
        "Write component tests",
    ]},
    {"title": "End-to-End DOKU Production Flow Test [BE]", "label": "Backend", "due_date": "2026-04-28", "checklist": [
        "Konfigurasi DOKU production credentials",
        "Test create checkout via DokuPaymentService (production)",
        "Verifikasi payment URL valid dan accessible",
        "Test pembayaran aktual di DOKU production",
        "Verifikasi webhook diterima + signature verification",
        "Verifikasi status update di database",
        "Test subscription + booking payment flow via DOKU",
        "Implementasi manual reconciliation endpoint",
        "Tambah comprehensive logging",
        "Dokumentasi hasil test",
    ]},
    {"title": "Setup QuestPDF + Invoice Numbering System [BE]", "label": "Backend", "due_date": "2026-04-30", "checklist": [
        "Install QuestPDF NuGet package",
        "Buat IPdfGeneratorService + implementasi",
        "Setup PDF storage di MinIO (bucket: invoices)",
        "Buat entity InvoiceNumberSequence + migration",
        "Implementasi IInvoiceNumberService format INV-YYYYMM-NNNN",
        "Atomic number generation (database locking)",
        "Reset counter setiap awal bulan",
        "Unique constraint (agency_id, invoice_number)",
        "Update BookingInvoiceService untuk pakai format baru",
        "Write unit tests",
    ]},
    {"title": "Tax Calculation Service (PPN 11%) [BE]", "label": "Backend", "due_date": "2026-05-01", "checklist": [
        "Buat ITaxCalculationService + implementasi",
        "Buat TaxConfig entity + migration + seed default PPN 11%",
        "Logika harga sudah termasuk PPN: DPP = Total / 1.11",
        "Logika harga belum termasuk PPN: PPN = DPP x 11%",
        "Buat TaxBreakdownDto",
        "Konfigurasi tarif PPN per agency",
        "Write unit tests: inclusive, exclusive, round-trip property",
    ]},
    {"title": "Template PDF Invoice Profesional + Email Delivery [BE]", "label": "Backend", "due_date": "2026-05-03", "checklist": [
        "Design invoice PDF layout dengan QuestPDF (A4 portrait)",
        "Header: logo agency, nama, alamat, kontak",
        "Info customer + info invoice + detail items",
        "Ringkasan: subtotal, diskon, DPP, PPN 11%, total",
        "Info pembayaran + terms & conditions",
        "Support Unicode (Bahasa Indonesia + Arab)",
        "Buat GenerateInvoicePdfCommand + DownloadInvoicePdfQuery + endpoints",
        "Integrasi email delivery via Resend API (PDF attachment)",
        "Retry logic 3x + catat status pengiriman",
        "Opsi kirim ulang manual dari dashboard",
        "Write integration tests",
    ]},
    {"title": "Invoice PDF Viewer + List Enhancement [FE]", "label": "Frontend", "due_date": "2026-05-04", "checklist": [
        "Buat invoice-pdf-viewer component",
        "Tombol Download PDF + Print",
        "Tombol Send via Email + Send via WhatsApp",
        "Loading state + error handling",
        "Tambah Generate PDF + View PDF button di invoice list",
        "Update invoice detail page dengan PDF section",
        "Tampilkan tax breakdown (DPP, PPN, Total)",
        "Update NGXS booking-invoice store",
        "Write component tests",
    ]},
    {"title": "Amadeus Flight Search API [BE]", "label": "Backend", "due_date": "2026-05-09", "checklist": [
        "Buat IAmadeusService + implementasi (HTTP client, auth token)",
        "Integrasi Amadeus Flight Offers Search API",
        "Support one-way, round-trip, multi-city",
        "Response mapping + filter + sorting",
        "Cache hasil pencarian 15 menit",
        "Error handling jika API unavailable",
        "Buat FlightSearchController + endpoints",
        "Write unit + integration tests",
    ]},
    {"title": "Amadeus Flight Booking API [BE]", "label": "Backend", "due_date": "2026-05-12", "checklist": [
        "Integrasi Amadeus Flight Booking API (Flight Orders)",
        "Accept passenger details + receive PNR",
        "Simpan booking detail + link ke JourneyActivity",
        "Generate e-ticket dengan PNR",
        "Rollback booking lokal jika Amadeus gagal",
        "Support pembatalan booking via Amadeus API",
        "Write integration tests",
    ]},
    {"title": "Amadeus Flight Search + Booking UI [FE]", "label": "Frontend", "due_date": "2026-05-14", "checklist": [
        "Buat flight-search page component",
        "Form pencarian: origin, destination, dates, pax, cabin class",
        "Hasil pencarian: list flights + detail + harga",
        "Filter sidebar + sort options",
        "Flight detail modal + booking confirmation dialog",
        "PNR display + e-ticket view",
        "NGXS state management",
        "Write component tests",
    ]},
    {"title": "Upload Passport Readable (OCR/MRZ Parsing) [BE]", "label": "Backend", "due_date": "2026-05-16", "checklist": [
        "Buat IPassportOcrService + implementasi (MRZ parsing)",
        "Accept upload: JPEG, PNG, PDF",
        "Simpan gambar di MinIO (bucket: passports)",
        "Parse MRZ: full name, DOB, gender, nationality, passport number, expiry",
        "Buat UploadPassportCommand + endpoint",
        "Link gambar passport ke Traveler entity",
        "Error handling jika OCR gagal",
        "Write unit tests + round-trip property test",
    ]},
    {"title": "Passport Upload + Auto-Fill UI [FE]", "label": "Frontend", "due_date": "2026-05-18", "checklist": [
        "Buat passport-upload component (drag & drop + file picker)",
        "Preview gambar + loading state saat OCR",
        "Tampilkan hasil parsing untuk review + konfirmasi",
        "Auto-fill form Traveler dari parsed data",
        "Error state jika OCR gagal + manual input fallback",
        "Integrasi ke traveler form di booking page",
        "Write component tests",
    ]},
    {"title": "Funder Role + Entities [BE]", "label": "Backend", "due_date": "2026-05-15", "checklist": [
        "Tambah role FUNDER di auth system + permission set",
        "Buat entity FundingConfig + FundingTransaction + FunderPayment",
        "Buat migrations untuk semua entity baru",
        "Terapkan RLS pada semua entity funder",
        "Buat halaman registrasi + profil FUNDER",
        "Write entity tests",
    ]},
    {"title": "Funding Config + Funding List API [BE]", "label": "Backend", "due_date": "2026-05-18", "checklist": [
        "Buat CreateFundingConfigCommand + UpdateFundingConfigCommand",
        "Validasi ReturnPercentage: 0.1% - 50%",
        "Buat GetFundingListQuery (is_funding_phase=true, status=open)",
        "Buat CreateFundingTransactionCommand + payment gateway redirect",
        "Update status setelah payment success",
        "Write command/query tests",
    ]},
    {"title": "Split Payment ke Supplier + Bagi Hasil [BE]", "label": "Backend", "due_date": "2026-05-22", "checklist": [
        "Split payment logic: funder -> supplier berdasarkan JourneyActivity cost",
        "Update JourneyActivity.PaymentStatus = fully_paid per activity",
        "Catat setiap split sebagai FunderPayment",
        "Retry logic + reconciliation manual",
        "Bagi hasil: (SellingPrice - BaseCost) x ReturnPercentage",
        "Release bagi hasil setelah semua booking fully_paid",
        "Disbursement ke funder via payment gateway",
        "Write integration tests",
    ]},
    {"title": "Funder Flow UI [FE]", "label": "Frontend", "due_date": "2026-05-25", "checklist": [
        "FUNDER registration + profile page",
        "Funding Configuration section di Journey Create (bawah Pricing Summary)",
        "Toggle IsFundingPhase + input ReturnPercentage",
        "Funding List page (hanya FUNDER role)",
        "Fund This Journey -> payment flow",
        "My Investments page (dashboard + metrics)",
        "Payment History page",
        "NGXS state management",
        "Write component tests",
    ]},
    {"title": "Chart of Accounts (COA) — Entity, Database, CRUD [BE]", "label": "Backend", "due_date": "2026-05-22", "checklist": [
        "Buat entity ChartOfAccount + EF config (self-referencing parent-child)",
        "Migration + indexes + unique constraint (agency_id, account_code)",
        "Seed default COA untuk travel agency",
        "Buat Create/Update/Deactivate commands + GetCOATreeQuery",
        "Validasi: unique code, max level 5, cannot post to parent",
        "RLS enforced",
        "Write command/query tests",
    ]},
    {"title": "General Ledger (GL) — Journal Entries [BE]", "label": "Backend", "due_date": "2026-05-26", "checklist": [
        "Buat entity JournalEntry + JournalEntryLine + migrations",
        "Check constraint: total debit = total credit",
        "Buat Create/Post/Reverse commands + queries",
        "Entry number generation sequential per agency",
        "Validasi: balanced entry, postable accounts only",
        "Transaction date terpisah dari posting date (accrual)",
        "RLS enforced",
        "Write command/query tests",
    ]},
    {"title": "Auto-Generate Journal Entries dari Event Bisnis [BE]", "label": "Backend", "due_date": "2026-05-29", "checklist": [
        "Buat IJournalEntryAutoGeneratorService",
        "Configurable account mapping per transaction type",
        "Hook: booking confirmed -> DR AR, CR Revenue",
        "Hook: payment received -> DR Cash, CR AR",
        "Hook: supplier bill -> DR Expense, CR AP",
        "Hook: supplier payment -> DR AP, CR Cash",
        "Map expense account per service type",
        "Write integration tests",
    ]},
    {"title": "Accounts Receivable (AR) + Aging Report [BE]", "label": "Backend", "due_date": "2026-06-02", "checklist": [
        "Buat entity AccountsReceivable + migration",
        "Auto-create AR saat booking confirmed",
        "Update AR saat payment recorded + GL journal entry",
        "Status: Draft, Sent, Partially_Paid, Paid, Overdue",
        "Aging buckets: Current, 1-30, 31-60, 61-90, >90",
        "Export ke Excel",
        "Write command/query tests",
    ]},
    {"title": "Accounts Payable (AP) + Aging Report [BE]", "label": "Backend", "due_date": "2026-06-05", "checklist": [
        "Enhance SupplierBill dengan approval workflow",
        "Buat Approve/Reject commands",
        "GL journal entry saat approved + saat payment",
        "Aging buckets: Current, 1-30, 31-60, 61-90, >90",
        "Export ke Excel",
        "Write command/query tests",
    ]},
    {"title": "Chart of Accounts Management UI [FE]", "label": "Frontend", "due_date": "2026-05-28", "checklist": [
        "COA list: tree view (p-treeTable) expand/collapse",
        "COA form: create/edit account",
        "Account type filter + search by code/name",
        "Activate/deactivate action",
        "NGXS state management",
        "Write component tests",
    ]},
    {"title": "Journal Entry Management UI [FE]", "label": "Frontend", "due_date": "2026-06-01", "checklist": [
        "JE list: filter by date, type, status",
        "JE form: multi-line entry (account selector + debit/credit)",
        "Auto-balance check real-time",
        "Post / Reverse actions",
        "Badge auto-generated vs manual",
        "NGXS state management",
        "Write component tests",
    ]},
    {"title": "AR & AP Management + Aging Reports UI [FE]", "label": "Frontend", "due_date": "2026-06-08", "checklist": [
        "AR list + detail + payment recording form",
        "AP list + detail + approval workflow UI",
        "AR Aging Report: buckets table, group by customer",
        "AP Aging Report: buckets table, group by supplier",
        "Date range filter + export to Excel",
        "NGXS state management",
        "Write component tests",
    ]},
    {"title": "Rating & Review System [BE]", "label": "Backend", "due_date": "2026-06-10", "checklist": [
        "Buat entity ServiceReview + migration",
        "SubmitReviewCommand (validasi: completed, no duplicate)",
        "ReplyToReviewCommand (supplier side)",
        "GetReviewsQuery + calculate average rating",
        "Write command/query tests",
    ]},
    {"title": "Dispute Resolution System [BE]", "label": "Backend", "due_date": "2026-06-10", "checklist": [
        "Buat entity Dispute + DisputeMessage + migrations",
        "CreateDisputeCommand + ResolveDisputeCommand",
        "Workflow: Open -> Under_Review -> Resolved -> Closed",
        "Notifikasi + lampiran bukti via MinIO",
        "Write command tests",
    ]},
    {"title": "Marketplace Analytics + Financial Reports API [BE]", "label": "Backend", "due_date": "2026-06-11", "checklist": [
        "GetMarketplaceAnalyticsQuery + date range filtering",
        "GetTrialBalanceQuery + GetBalanceSheetQuery + GetIncomeStatementQuery",
        "GetSalesReportQuery + GetProfitabilityReportQuery",
        "GetCustomerReportQuery + GetSupplierReportQuery",
        "Export ke Excel + PDF",
        "Write query tests",
    ]},
    {"title": "Rating, Dispute, Analytics + Reports UI [FE]", "label": "Frontend", "due_date": "2026-06-12", "checklist": [
        "Review form (p-rating + text) + review list + average display",
        "Supplier reply UI",
        "Dispute form + list + detail + resolution UI",
        "Marketplace analytics dashboard (p-chart)",
        "Financial statements: Trial Balance, Balance Sheet, Income Statement",
        "Operational reports: Sales, Profitability, Customer, Supplier",
        "Date range filters + export Excel/PDF",
        "NGXS state management",
        "Write component tests",
    ]},
    {"title": "Multi-Tenant RLS + Audit Trail [BE]", "label": "Backend", "due_date": "", "checklist": [
        "Terapkan RLS untuk SEMUA tabel Phase 2 baru",
        "Validasi agency_id pada semua CQRS commands dan queries",
        "Buat AuditLog entity + intercept financial entity changes",
        "Query audit log: filter by date, user, entity type",
        "Retention minimal 7 tahun",
        "Write integration tests",
    ]},
]

# ============================================================
# FUNGSI API
# ============================================================

def api_get(path, params=None):
    p = {"key": API_KEY, "token": TOKEN}
    if params:
        p.update(params)
    resp = requests.get(f"{BASE_URL}{path}", params=p)
    resp.raise_for_status()
    return resp.json()

def api_post(path, data=None):
    p = {"key": API_KEY, "token": TOKEN}
    resp = requests.post(f"{BASE_URL}{path}", params=p, json=data or {})
    resp.raise_for_status()
    return resp.json()

def create_card(list_id, title, due_date, label_ids):
    data = {"name": title, "idList": list_id, "idLabels": ",".join(label_ids)}
    if due_date:
        data["due"] = f"{due_date}T23:59:00.000Z"
    return api_post("/cards", data)

def add_checklist(card_id, name):
    return api_post(f"/cards/{card_id}/checklists", {"name": name})

def add_checklist_item(checklist_id, item_name):
    return api_post(f"/checklists/{checklist_id}/checkItems", {"name": item_name})

def find_by_name(items, name):
    for item in items:
        if item.get("name") and item["name"].strip().lower() == name.strip().lower():
            return item["id"]
    return None

# ============================================================
# MAIN
# ============================================================

def main():
    if not API_KEY or not TOKEN or not BOARD_ID:
        print("ERROR: Set environment variables dulu:")
        print("  export TRELLO_API_KEY=key_kamu")
        print("  export TRELLO_TOKEN=token_kamu")
        print("  export TRELLO_BOARD_ID=board_id_kamu")
        return

    print(f"Board ID: {BOARD_ID}")

    lists = api_get(f"/boards/{BOARD_ID}/lists")
    labels = api_get(f"/boards/{BOARD_ID}/labels")

    list_id = find_by_name(lists, TARGET_LIST_NAME)
    if not list_id:
        print(f"ERROR: List '{TARGET_LIST_NAME}' tidak ditemukan!")
        print("Lists yang ada:", [l["name"] for l in lists])
        return

    be_label = find_by_name(labels, "Backend")
    fe_label = find_by_name(labels, "Frontend")
    sprint_label = find_by_name(labels, SPRINT_LABEL_NAME)

    if not be_label or not fe_label:
        print("ERROR: Label 'Backend' atau 'Frontend' tidak ditemukan!")
        print("Labels yang ada:", [l["name"] for l in labels if l.get("name")])
        return

    if not sprint_label:
        print(f"WARNING: Label '{SPRINT_LABEL_NAME}' tidak ditemukan, skip sprint label")

    print(f"List: {TARGET_LIST_NAME}")
    print(f"Labels: Backend={be_label}, Frontend={fe_label}, Sprint={sprint_label}")
    print(f"\nImporting {len(TASKS)} tasks...\n")

    ok = 0
    fail = 0
    for i, t in enumerate(TASKS, 1):
        try:
            lbl_ids = [be_label if t["label"] == "Backend" else fe_label]
            if sprint_label:
                lbl_ids.append(sprint_label)

            card = create_card(list_id, t["title"], t.get("due_date", ""), lbl_ids)

            if t.get("checklist"):
                cl = add_checklist(card["id"], "Checklist")
                for item in t["checklist"]:
                    add_checklist_item(cl["id"], item)
                    time.sleep(0.1)

            print(f"  [{i:02d}/{len(TASKS)}] {t['title']}")
            ok += 1
        except Exception as e:
            print(f"  FAIL [{i:02d}] {t['title']} -> {e}")
            fail += 1
        time.sleep(0.3)

    print(f"\nDone: {ok} ok, {fail} failed")

if __name__ == "__main__":
    main()
