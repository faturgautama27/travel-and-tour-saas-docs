# Analisis Pricing Plan - Tour & Travel SaaS Platform

## Ringkasan Eksekutif

Dokumen ini menyajikan analisis pricing plan untuk platform Tour & Travel SaaS dengan model shared cloud infrastructure (VPS). Pricing dirancang untuk affordable bagi travel agency kecil hingga menengah dengan asumsi puluhan hingga ratusan agency menggunakan platform.

---

## 🎯 Filosofi Pricing

**Model Bisnis:** SaaS Multi-Tenant dengan Shared Infrastructure
- Menggunakan VPS cloud shared untuk efisiensi biaya
- Skalabilitas horizontal untuk handle ratusan agency
- Pricing berbasis usage (user, transaksi, storage)
- Target market: Travel agency kecil-menengah di Indonesia

---

## 📊 Perbandingan Pricing Plan

### Plan 1: STARTER
**Target**: Travel agency kecil yang baru memulai atau solo agent

| Item | Detail |
|------|--------|
| **Harga Bulanan** | Rp 500.000 |
| **Harga Tahunan** | Rp 5.000.000 (hemat Rp 1 juta) |
| **Maksimal User** | 5 user aktif |
| **Biaya per User/Bulan** | Rp 100.000 |
| **Maksimal Package** | 20 package templates |
| **Maksimal Journey/Bulan** | 30 journey |
| **Maksimal Booking/Bulan** | 100 booking |
| **Storage** | 5 GB |

**Fitur yang Didapat:**
- ✅ Manajemen booking dasar
- ✅ Manajemen customer & traveler
- ✅ Manajemen dokumen traveler
- ✅ Payment tracking
- ✅ Task management
- ✅ Laporan standar (PDF/Excel)
- ✅ Email support (respon 1x24 jam)
- ❌ B2B Marketplace
- ❌ API Access
- ❌ Custom branding
- ❌ WhatsApp notification

**Cocok untuk:**
- Solo travel agent atau agency dengan 2-5 staff
- Volume booking 50-100 per bulan
- Budget terbatas
- Fokus operasional dasar

---

### Plan 2: PROFESSIONAL
**Target**: Travel agency menengah yang sedang berkembang

| Item | Detail |
|------|--------|
| **Harga Bulanan** | Rp 1.500.000 |
| **Harga Tahunan** | Rp 15.000.000 (hemat Rp 3 juta) |
| **Maksimal User** | 15 user aktif |
| **Biaya per User/Bulan** | Rp 100.000 |
| **Maksimal Package** | 100 package templates |
| **Maksimal Journey/Bulan** | 150 journey |
| **Maksimal Booking/Bulan** | 500 booking |
| **Storage** | 20 GB |

**Fitur yang Didapat:**
- ✅ Semua fitur Starter
- ✅ B2B Marketplace (jual/beli antar agency)
- ✅ Advanced reports & analytics
- ✅ Profitability tracking per booking
- ✅ WhatsApp notification (500 notif/bulan)
- ✅ Itinerary builder
- ✅ Supplier bill management
- ✅ Communication log
- ✅ Email support (respon 12 jam)
- ❌ API Access
- ❌ Custom branding
- ❌ Priority support

**Cocok untuk:**
- Travel agency dengan 8-15 staff
- Volume booking 200-500 per bulan
- Ingin ekspansi dengan B2B marketplace
- Butuh analisis profit yang detail

---

### Plan 3: BUSINESS
**Target**: Travel agency established dengan volume tinggi

| Item | Detail |
|------|--------|
| **Harga Bulanan** | Rp 3.500.000 |
| **Harga Tahunan** | Rp 35.000.000 (hemat Rp 7 juta) |
| **Maksimal User** | 30 user aktif |
| **Biaya per User/Bulan** | Rp 116.667 |
| **Maksimal Package** | Unlimited |
| **Maksimal Journey/Bulan** | Unlimited |
| **Maksimal Booking/Bulan** | Unlimited |
| **Storage** | 50 GB |

**Fitur yang Didapat:**
- ✅ Semua fitur Professional
- ✅ API Access (REST API untuk integrasi)
- ✅ Custom branding (logo & warna)
- ✅ WhatsApp notification (2000 notif/bulan)
- ✅ Priority email support (respon 4 jam)
- ✅ Phone support (jam kerja)
- ✅ Monthly business review
- ✅ Custom report builder
- ✅ Data export unlimited

**Cocok untuk:**
- Travel agency dengan 20-30 staff
- Volume booking > 500 per bulan
- Butuh integrasi dengan sistem internal
- Brand awareness penting

---

## 💰 Perbandingan Biaya per User & Transaksi

### Tabel Perbandingan

| Plan | Harga Bulanan | Max User | Biaya/User/Bulan | Harga Tahunan | Biaya/User/Tahun | Penghematan Tahunan |
|------|---------------|----------|------------------|---------------|------------------|---------------------|
| **Starter** | Rp 500.000 | 5 | Rp 100.000 | Rp 5.000.000 | Rp 1.000.000 | Rp 1.000.000 (17%) |
| **Professional** | Rp 1.500.000 | 15 | Rp 100.000 | Rp 15.000.000 | Rp 1.000.000 | Rp 3.000.000 (17%) |
| **Business** | Rp 3.500.000 | 30 | Rp 116.667 | Rp 35.000.000 | Rp 1.166.667 | Rp 7.000.000 (17%) |

### Biaya per Transaksi (dengan asumsi usage maksimal)

| Plan | Max Booking/Bulan | Harga Bulanan | Biaya/Booking | Biaya/Journey | Biaya/Package |
|------|-------------------|---------------|---------------|---------------|---------------|
| **Starter** | 100 | Rp 500.000 | Rp 5.000 | Rp 16.667 (30 journey) | Rp 25.000 (20 package) |
| **Professional** | 500 | Rp 1.500.000 | Rp 3.000 | Rp 10.000 (150 journey) | Rp 15.000 (100 package) |
| **Business** | Unlimited | Rp 3.500.000 | Rp 3.500* | Rp 3.500* | Rp 3.500* |

*Asumsi 1000 booking/bulan untuk Business plan

### Insight Penting:
1. **Biaya per user konsisten** di Rp 100.000/bulan untuk semua plan (sangat affordable!)
2. **Semakin tinggi volume, semakin murah** biaya per transaksi
3. **Pembayaran tahunan** menghemat 17% (setara 2 bulan gratis)
4. **Break-even point**: Jika revenue per booking Rp 500.000, biaya platform hanya 1-2% dari revenue

---

## 📈 Skenario Penggunaan & Budget Planning

### Skenario 1: Solo Travel Agent / Startup Agency (3-5 staff)
**Rekomendasi: STARTER Plan**

| Item | Bulanan | Tahunan |
|------|---------|---------|
| Biaya subscription | Rp 500.000 | Rp 5.000.000 |
| Biaya per staff (5 user) | Rp 100.000 | Rp 1.000.000 |
| **Total Budget IT** | **Rp 500.000/bulan** | **Rp 5.000.000/tahun** |

**Asumsi Operasional:**
- 5 staff aktif menggunakan sistem
- Volume booking 60-80 per bulan
- 15-20 journey per bulan
- 10-15 package templates
- Belum butuh B2B marketplace

**Analisis ROI:**
- Jika average revenue per booking Rp 8 juta
- Total revenue 70 booking × Rp 8 juta = Rp 560 juta/bulan
- Biaya platform Rp 500.000 = **0,09% dari revenue**
- Penghematan waktu admin: 40 jam/bulan (manual → digital)
- Nilai waktu: 40 jam × Rp 50.000/jam = Rp 2 juta/bulan
- **Net benefit: Rp 1,5 juta/bulan**

---

### Skenario 2: Growing Travel Agency (10-12 staff)
**Rekomendasi: PROFESSIONAL Plan**

| Item | Bulanan | Tahunan |
|------|---------|---------|
| Biaya subscription | Rp 1.500.000 | Rp 15.000.000 |
| Biaya per staff (12 user) | Rp 125.000 | Rp 1.250.000 |
| **Total Budget IT** | **Rp 1.500.000/bulan** | **Rp 15.000.000/tahun** |

**Asumsi Operasional:**
- 12 staff aktif menggunakan sistem
- Volume booking 250-350 per bulan
- 80-120 journey per bulan
- 40-60 package templates
- Aktif di B2B marketplace (jual & beli)

**Analisis ROI:**
- Revenue dari booking sendiri: 300 booking × Rp 10 juta = Rp 3 miliar/bulan
- Revenue dari B2B marketplace: 50 reselling × Rp 5 juta profit = Rp 250 juta/bulan
- Total revenue: Rp 3,25 miliar/bulan
- Biaya platform Rp 1,5 juta = **0,046% dari revenue**
- Tambahan revenue dari B2B: Rp 250 juta/bulan
- **ROI dari B2B saja: 167x lipat biaya subscription**

---

### Skenario 3: Established Travel Agency (20-25 staff)
**Rekomendasi: BUSINESS Plan**

| Item | Bulanan | Tahunan |
|------|---------|---------|
| Biaya subscription | Rp 3.500.000 | Rp 35.000.000 |
| Biaya per staff (25 user) | Rp 140.000 | Rp 1.400.000 |
| **Total Budget IT** | **Rp 3.500.000/bulan** | **Rp 35.000.000/tahun** |

**Asumsi Operasional:**
- 25 staff aktif menggunakan sistem
- Volume booking 600-800 per bulan
- 200+ journey per bulan
- 100+ package templates
- Heavy B2B marketplace user
- Integrasi dengan accounting software via API

**Analisis ROI:**
- Revenue dari booking: 700 booking × Rp 12 juta = Rp 8,4 miliar/bulan
- Revenue dari B2B: 150 reselling × Rp 6 juta profit = Rp 900 juta/bulan
- Total revenue: Rp 9,3 miliar/bulan
- Biaya platform Rp 3,5 juta = **0,038% dari revenue**
- Penghematan dari API integration: 80 jam/bulan manual data entry
- Nilai waktu: 80 jam × Rp 75.000/jam = Rp 6 juta/bulan
- **Net benefit: Rp 2,5 juta/bulan (setelah dikurangi biaya subscription)**

---

## 🎯 Rekomendasi untuk Finance

### 1. Pilihan Pembayaran
**Sangat Disarankan: Pembayaran Tahunan**
- Hemat 17% (setara 2 bulan gratis)
- Cash flow lebih predictable
- Tidak perlu renewal bulanan
- Lock-in price (tidak terpengaruh kenaikan harga)

### 2. Pertimbangan Upgrade Path

```
STARTER (Rp 500rb/bln)
    ↓ (saat team 8-10 orang atau booking > 100/bln)
PROFESSIONAL (Rp 1,5 jt/bln)
    ↓ (saat team 20-25 orang atau booking > 500/bln)
BUSINESS (Rp 3,5 jt/bln)
```

**Catatan Upgrade:**
- Upgrade bisa dilakukan kapan saja (prorated)
- Data tidak hilang saat upgrade
- Downgrade hanya bisa di akhir periode billing

### 3. Budget Allocation Guideline

| Ukuran Agency | Staff | Plan | Budget IT/Bulan | % dari Revenue* |
|---------------|-------|------|-----------------|-----------------|
| Small | 3-5 | Starter | Rp 500rb | 0,1% |
| Medium | 10-15 | Professional | Rp 1,5 jt | 0,05% |
| Large | 20-30 | Business | Rp 3,5 jt | 0,04% |

*Asumsi average booking value Rp 10 juta

**Kesimpulan Budget:**
- Biaya platform sangat kecil (< 0,1% dari revenue)
- ROI tercapai dari efisiensi operasional
- B2B marketplace bisa jadi profit center baru

### 4. Biaya Tambahan (Pay-as-you-go)

**Jika melebihi quota:**

| Item | Biaya Tambahan |
|------|----------------|
| Extra user | Rp 100.000/user/bulan |
| Extra booking (> quota) | Rp 5.000/booking |
| Extra storage (> quota) | Rp 50.000/GB/bulan |
| Extra WhatsApp notif | Rp 500/notif |
| SMS notification | Rp 300/SMS |

**Contoh Perhitungan:**
- Plan Starter (Rp 500rb) + 2 extra user (Rp 200rb) = Rp 700rb/bulan
- Masih lebih murah daripada upgrade ke Professional

### 5. Hidden Costs yang Perlu Dipertimbangkan

**TIDAK termasuk dalam subscription:**
- ❌ Biaya training staff (estimasi Rp 2-3 juta one-time, optional)
- ❌ Biaya data migration dari sistem lama (jika ada, estimasi Rp 5-10 juta)
- ❌ Biaya internet & hardware (laptop/PC)
- ❌ Biaya SMS/WhatsApp untuk notifikasi customer (pay-per-use)
- ❌ Biaya payment gateway (jika pakai online payment)

**Sudah termasuk dalam subscription:**
- ✅ Hosting & server (VPS cloud shared)
- ✅ Maintenance & updates
- ✅ Data backup harian (retention 30 hari)
- ✅ SSL certificate & security
- ✅ Technical support (sesuai plan)
- ✅ Software updates & new features

---

## 💡 Analisis Ekonomi Platform (untuk Finance Team)

### Asumsi Infrastruktur

**VPS Cloud Shared:**
- Server: DigitalOcean/AWS Lightsail - Rp 1-2 juta/bulan
- Database: Managed PostgreSQL - Rp 1-1,5 juta/bulan
- Storage: Object Storage (S3) - Rp 500rb-1 juta/bulan
- CDN & Bandwidth - Rp 500rb/bulan
- **Total infra cost: Rp 3-5 juta/bulan**

**Break-even Analysis:**
- Biaya infra: Rp 4 juta/bulan
- Biaya operasional (support, maintenance): Rp 6 juta/bulan
- **Total cost: Rp 10 juta/bulan**

**Skenario Revenue:**

| Jumlah Agency | Mix Plan | MRR | Profit/Bulan |
|---------------|----------|-----|--------------|
| 10 agency | 7 Starter + 3 Pro | Rp 8 juta | (Rp 2 juta) - Loss |
| 20 agency | 12 Starter + 6 Pro + 2 Business | Rp 22 juta | Rp 12 juta |
| 50 agency | 25 Starter + 20 Pro + 5 Business | Rp 60 juta | Rp 50 juta |
| 100 agency | 50 Starter + 40 Pro + 10 Business | Rp 120 juta | Rp 110 juta |

**Kesimpulan:**
- Break-even di 15-20 agency
- Dengan 50 agency, profit margin 83%
- Dengan 100 agency, profit margin 92%
- Model bisnis sangat scalable dengan shared infrastructure

---

## 📋 Checklist untuk Finance Team

Sebelum memutuskan plan, pastikan sudah menjawab:

- [ ] Berapa jumlah staff yang akan menggunakan sistem? (aktif login)
- [ ] Berapa rata-rata booking per bulan saat ini?
- [ ] Berapa rata-rata journey per bulan?
- [ ] Berapa jumlah package template yang dibutuhkan?
- [ ] Berapa target pertumbuhan booking dalam 12 bulan ke depan?
- [ ] Apakah butuh integrasi dengan sistem lain (accounting, CRM)? → Business plan
- [ ] Apakah ingin ekspansi ke B2B marketplace? → Professional plan
- [ ] Berapa budget IT yang tersedia per tahun?
- [ ] Apakah lebih prefer pembayaran bulanan atau tahunan?
- [ ] Apakah butuh WhatsApp notification untuk customer?
- [ ] Berapa estimasi storage yang dibutuhkan? (dokumen, foto)

---

## 💡 Kesimpulan & Rekomendasi

### Untuk Solo Agent / Agency Kecil (< 5 staff)
**Mulai dengan STARTER Plan (Rp 500rb/bulan atau Rp 5 juta/tahun)**
- Sangat affordable untuk startup
- Cukup untuk operasional dasar 100 booking/bulan
- Bisa upgrade kapan saja saat berkembang
- ROI tercapai dari penghematan waktu admin
- **Biaya hanya 0,1% dari revenue**

### Untuk Agency Menengah (8-15 staff)
**Pilih PROFESSIONAL Plan (Rp 1,5 juta/bulan atau Rp 15 juta/tahun)**
- B2B marketplace bisa jadi revenue stream baru
- Advanced analytics membantu optimasi profit
- WhatsApp notification meningkatkan customer satisfaction
- ROI tercapai dengan tambahan revenue dari B2B
- **Biaya hanya 0,05% dari revenue**

### Untuk Agency Established (> 20 staff)
**Pilih BUSINESS Plan (Rp 3,5 juta/bulan atau Rp 35 juta/tahun)**
- Unlimited booking untuk high volume
- API integration menghemat banyak waktu manual work
- Custom branding untuk brand awareness
- Priority support mengurangi downtime
- ROI tercapai dari efisiensi operasional & time saving
- **Biaya hanya 0,04% dari revenue**

---

## 🚀 Strategi Go-to-Market

### Phase 1: Early Adopters (Bulan 1-3)
**Target: 20 agency**
- Fokus ke agency kecil-menengah (Starter & Professional)
- Offer: Diskon 50% untuk 3 bulan pertama
- Free onboarding & training
- **Expected MRR: Rp 10-15 juta**

### Phase 2: Growth (Bulan 4-12)
**Target: 50 agency**
- Expand ke agency menengah-besar
- Referral program: 1 bulan gratis untuk referrer
- Case study & testimonial dari early adopters
- **Expected MRR: Rp 50-60 juta**

### Phase 3: Scale (Tahun 2)
**Target: 100-200 agency**
- Partnership dengan asosiasi travel agent
- White-label option untuk agency besar
- Regional expansion
- **Expected MRR: Rp 120-200 juta**

---

## 📞 Next Steps

1. **Tentukan ukuran team** dan volume booking saat ini
2. **Hitung budget IT** yang tersedia untuk 12 bulan
3. **Pilih plan** yang sesuai dengan checklist di atas
4. **Diskusikan dengan sales** untuk kemungkinan:
   - Custom pricing (jika > 30 users)
   - Volume discount (jika multi-branch)
   - Trial period (14 hari gratis)
5. **Request demo** untuk melihat fitur secara langsung
6. **Mulai dengan plan kecil**, upgrade sesuai pertumbuhan

---

## 📊 Perbandingan dengan Kompetitor

| Fitur | Platform Ini | Kompetitor A | Kompetitor B |
|-------|--------------|--------------|--------------|
| Harga entry level | Rp 500rb/bln | Rp 2 juta/bln | Rp 1,5 juta/bln |
| Max user (entry) | 5 user | 3 user | 5 user |
| B2B Marketplace | ✅ (Pro plan) | ❌ | ✅ (Enterprise only) |
| API Access | ✅ (Business) | ✅ (semua plan) | ❌ |
| WhatsApp notif | ✅ (Pro+) | ❌ | ✅ (pay extra) |
| Custom branding | ✅ (Business) | ❌ | ✅ (Enterprise) |
| Support | Email/Phone | Email only | Email/Phone |

**Keunggulan:**
- ✅ Harga paling kompetitif (75% lebih murah dari kompetitor)
- ✅ B2B Marketplace (unique selling point)
- ✅ Flexible pricing (pay for what you use)
- ✅ Local support (Bahasa Indonesia)

---

**Catatan:** 
- Harga dalam dokumen ini adalah estimasi dan dapat berubah
- Untuk harga final, custom pricing, dan trial period, silakan hubungi tim sales
- Pricing ini sudah memperhitungkan model shared infrastructure dengan asumsi 50-200 agency

**Dokumen dibuat:** Februari 2025  
**Versi:** 2.0 (Revised - Affordable Pricing Model)
