# Payment System - Quick Reference Guide

**For Developers** - Quick lookup for payment implementation

---

## 🔑 KEY ENTITIES

### JourneyActivity (Payment Tracking)
```csharp
public class JourneyActivity
{
    // Payment Status
    public string PaymentStatus { get; set; } = "unpaid"; 
    // Values: unpaid, dp_paid, fully_paid, reserved
    
    // Payment Links
    public Guid? DownPaymentId { get; set; }
    public Guid? FullPaymentId { get; set; }
    
    // Payment Dates
    public DateTime? DownPaymentPaidAt { get; set; }
    public DateTime? FullPaymentPaidAt { get; set; }
    public DateTime? FullPaymentDueDate { get; set; }
}
```

### Payment (Main Payment Record)
```csharp
public class Payment
{
    // References
    public Guid AgencyId { get; set; }
    public Guid SupplierId { get; set; }
    public Guid JourneyId { get; set; }
    public Guid JourneyActivityId { get; set; }
    public Guid SupplierServiceId { get; set; }
    
    // Payment Type
    public string PaymentType { get; set; } // down_payment, full_payment
    
    // Amounts
    public decimal ServiceCost { get; set; }
    public decimal AgencyCommissionAmount { get; set; }
    public decimal SupplierCommissionAmount { get; set; }
    public decimal AmountPaidByAgency { get; set; } // service_cost + agency_commission
    public decimal AmountToSupplier { get; set; } // service_cost - supplier_commission
    
    // Gateway
    public string PaymentGateway { get; set; } // xendit
    public string PaymentMethod { get; set; } // virtual_account, credit_card, ewallet, qris
    public string? TransactionId { get; set; }
    public string? PaymentUrl { get; set; }
    
    // Status
    public string Status { get; set; } // pending, processing, success, failed, expired
    public DateTime? PaidAt { get; set; }
    public DateTime? ExpiredAt { get; set; }
    
    // Supplier Transfer
    public string SupplierTransferStatus { get; set; } // pending, transferred, failed
    public DateTime? TransferredToSupplierAt { get; set; }
    public string? TransferReferenceNumber { get; set; }
}
```

### CommissionConfig (Enhanced)
```csharp
public class CommissionConfig
{
    // Filtering
    public string? ServiceType { get; set; } // hotel, flight, visa, etc. (NULL = all)
    public Guid? SupplierId { get; set; } // Specific supplier (NULL = all)
    
    // Who Pays
    public string ChargedTo { get; set; } // agency, supplier, both
    
    // Agency Commission
    public string? AgencyCommissionType { get; set; } // percentage, fixed
    public decimal? AgencyCommissionValue { get; set; }
    
    // Supplier Commission
    public string? SupplierCommissionType { get; set; } // percentage, fixed
    public decimal? SupplierCommissionValue { get; set; }
    
    // Priority
    public int Priority { get; set; } = 0; // Higher = applied first
}
```

---

## 🔄 PAYMENT FLOW - CODE SNIPPETS

### Create Payment (Agency Pays)

```csharp
public async Task<PaymentDto> CreatePayment(
    Guid journeyId, 
    Guid activityId, 
    string paymentType, // "down_payment" or "full_payment"
    string paymentMethod)
{
    // 1. Get activity and service
    var activity = await _activityRepo.GetByIdAsync(activityId);
    var service = await _serviceRepo.GetByIdAsync(activity.SupplierServiceId);
    
    // 2. Calculate payment amount
    decimal serviceAmount;
    if (paymentType == "down_payment")
    {
        serviceAmount = activity.TotalCost * (service.DownPaymentPercentage / 100);
    }
    else
    {
        if (activity.PaymentStatus == "dp_paid")
        {
            // Pelunasan = Total - DP
            var dpPayment = await _paymentRepo.GetByIdAsync(activity.DownPaymentId);
            serviceAmount = activity.TotalCost - dpPayment.ServiceCost;
        }
        else
        {
            // Full payment
            serviceAmount = activity.TotalCost;
        }
    }
    
    // 3. Get commission config
    var commissionConfig = await _commissionService.GetApplicableConfig(
        transactionType: "journey_activity_payment",
        serviceType: service.ServiceType,
        supplierId: service.SupplierId,
        transactionAmount: serviceAmount,
        transactionDate: DateTime.UtcNow
    );
    
    // 4. Calculate commission
    var commission = _commissionService.CalculateCommission(
        serviceAmount, 
        commissionConfig
    );
    
    // 5. Create payment record
    var payment = new Payment
    {
        AgencyId = activity.Journey.AgencyId,
        SupplierId = service.SupplierId,
        JourneyId = journeyId,
        JourneyActivityId = activityId,
        SupplierServiceId = service.Id,
        PaymentType = paymentType,
        ServiceCost = serviceAmount,
        AgencyCommissionAmount = commission.AgencyAmount,
        SupplierCommissionAmount = commission.SupplierAmount,
        AmountPaidByAgency = serviceAmount + commission.AgencyAmount,
        AmountToSupplier = serviceAmount - commission.SupplierAmount,
        Status = "pending",
        ExpiredAt = DateTime.UtcNow.AddHours(paymentType == "down_payment" ? 24 : 48),
        SupplierTransferStatus = "pending"
    };
    
    await _paymentRepo.CreateAsync(payment);
    
    // 6. Create Xendit invoice
    var invoice = await _xenditService.CreateInvoice(new CreateInvoiceRequest
    {
        ExternalId = payment.Id.ToString(),
        Amount = payment.AmountPaidByAgency,
        Description = $"{service.Name} - {paymentType}",
        PaymentMethods = new[] { paymentMethod },
        SuccessRedirectUrl = _config.SuccessRedirectUrl,
        FailureRedirectUrl = _config.FailureRedirectUrl
    });
    
    // 7. Update payment with gateway info
    payment.PaymentUrl = invoice.InvoiceUrl;
    payment.TransactionId = invoice.Id;
    await _paymentRepo.UpdateAsync(payment);
    
    return _mapper.Map<PaymentDto>(payment);
}
```

---

### Process Webhook (Payment Success)

```csharp
public async Task ProcessXenditWebhook(XenditWebhookPayload payload)
{
    // 1. Verify webhook signature
    var isValid = _xenditService.VerifyWebhookSignature(payload);
    if (!isValid) throw new UnauthorizedException("Invalid webhook signature");
    
    // 2. Get payment by transaction ID
    var payment = await _paymentRepo.GetByTransactionIdAsync(payload.Id);
    if (payment == null) throw new NotFoundException("Payment not found");
    
    // 3. Update payment status
    if (payload.Status == "PAID")
    {
        payment.Status = "success";
        payment.PaidAt = payload.PaidAt;
        await _paymentRepo.UpdateAsync(payment);
        
        // 4. Update activity status
        var activity = await _activityRepo.GetByIdAsync(payment.JourneyActivityId);
        
        if (payment.PaymentType == "down_payment")
        {
            activity.PaymentStatus = "dp_paid";
            activity.DownPaymentId = payment.Id;
            activity.DownPaymentPaidAt = payment.PaidAt;
            
            // Calculate pelunasan due date
            var service = await _serviceRepo.GetByIdAsync(payment.SupplierServiceId);
            activity.FullPaymentDueDate = activity.CheckInDate.Value
                .AddDays(-service.FullPaymentDueDays.Value);
        }
        else // full_payment
        {
            activity.PaymentStatus = "fully_paid";
            activity.FullPaymentId = payment.Id;
            activity.FullPaymentPaidAt = payment.PaidAt;
        }
        
        await _activityRepo.UpdateAsync(activity);
        
        // 5. Create commission transaction
        await _commissionService.RecordCommission(payment);
        
        // 6. Trigger supplier transfer (if pelunasan or no DP)
        if (payment.PaymentType == "full_payment")
        {
            await _transferService.ScheduleSupplierTransfer(payment.JourneyActivityId);
        }
        
        // 7. Send notifications
        await _notificationService.SendPaymentSuccessNotification(payment);
    }
}
```

---

### Supplier Transfer (Background Job)

```csharp
public async Task ProcessSupplierTransfers()
{
    // 1. Find activities ready for transfer
    var activities = await _activityRepo.GetActivitiesReadyForTransfer();
    
    foreach (var activity in activities)
    {
        // 2. Get all payments for this activity
        var payments = await _paymentRepo.GetByActivityIdAsync(activity.Id);
        
        // 3. Check if all payments successful and pending transfer
        var allSuccess = payments.All(p => p.Status == "success");
        var allPending = payments.All(p => p.SupplierTransferStatus == "pending");
        
        if (!allSuccess || !allPending) continue;
        
        // 4. Calculate total to transfer
        var totalAmount = payments.Sum(p => p.AmountToSupplier);
        
        // 5. Get supplier bank details
        var supplier = await _supplierRepo.GetByIdAsync(payments.First().SupplierId);
        
        // 6. Call Xendit disbursement
        var disbursement = await _xenditService.CreateDisbursement(new CreateDisbursementRequest
        {
            ExternalId = $"TRANSFER-{activity.Id}",
            Amount = totalAmount,
            BankCode = supplier.BankCode,
            AccountNumber = supplier.BankAccountNumber,
            AccountHolderName = supplier.BankAccountName,
            Description = $"Payment for {activity.Journey.Name}"
        });
        
        // 7. Update all payments
        foreach (var payment in payments)
        {
            payment.SupplierTransferStatus = "transferred";
            payment.TransferredToSupplierAt = DateTime.UtcNow;
            payment.TransferReferenceNumber = disbursement.Id;
            await _paymentRepo.UpdateAsync(payment);
        }
        
        // 8. Send notification to supplier
        await _notificationService.SendTransferCompleteNotification(
            supplier.Id, 
            totalAmount, 
            disbursement.Id
        );
    }
}
```

---

## 📊 COMMON QUERIES

### Get Journey Payment Summary
```csharp
public async Task<JourneyPaymentSummary> GetJourneyPaymentSummary(Guid journeyId)
{
    var activities = await _activityRepo.GetByJourneyIdAsync(journeyId);
    
    var marketplaceActivities = activities.Where(a => a.SourceType == "supplier");
    var totalCost = marketplaceActivities.Sum(a => a.TotalCost ?? 0);
    var paidActivities = marketplaceActivities.Where(a => a.PaymentStatus == "fully_paid");
    var paidAmount = paidActivities.Sum(a => a.TotalCost ?? 0);
    
    var payments = await _paymentRepo.GetByJourneyIdAsync(journeyId);
    var totalCommission = payments.Sum(p => p.AgencyCommissionAmount);
    
    return new JourneyPaymentSummary
    {
        TotalActivities = activities.Count,
        MarketplaceActivities = marketplaceActivities.Count(),
        TotalServiceCost = totalCost,
        TotalPlatformFees = totalCommission,
        TotalPaid = paidAmount,
        TotalPending = totalCost - paidAmount,
        PaymentProgressPercentage = totalCost > 0 ? (paidAmount / totalCost * 100) : 0
    };
}
```

### Get Upcoming Pelunasan Payments
```csharp
public async Task<List<UpcomingPayment>> GetUpcomingPelunasanPayments(
    Guid agencyId, 
    int daysAhead = 30)
{
    var activities = await _activityRepo.GetActivitiesWithPendingPelunasan(
        agencyId, 
        DateTime.UtcNow, 
        DateTime.UtcNow.AddDays(daysAhead)
    );
    
    var result = new List<UpcomingPayment>();
    
    foreach (var activity in activities)
    {
        var service = await _serviceRepo.GetByIdAsync(activity.SupplierServiceId);
        var dpPayment = await _paymentRepo.GetByIdAsync(activity.DownPaymentId);
        
        var pelunasanAmount = activity.TotalCost.Value - dpPayment.ServiceCost;
        var commissionConfig = await _commissionService.GetApplicableConfig(
            "journey_activity_payment",
            service.ServiceType,
            service.SupplierId,
            pelunasanAmount,
            DateTime.UtcNow
        );
        
        var commission = _commissionService.CalculateCommission(
            pelunasanAmount, 
            commissionConfig
        );
        
        result.Add(new UpcomingPayment
        {
            ActivityId = activity.Id,
            JourneyName = activity.Journey.Name,
            ServiceName = service.Name,
            PelunasanAmount = pelunasanAmount,
            CommissionAmount = commission.AgencyAmount,
            TotalToPay = pelunasanAmount + commission.AgencyAmount,
            DueDate = activity.FullPaymentDueDate.Value,
            DaysUntilDue = (activity.FullPaymentDueDate.Value - DateTime.UtcNow).Days
        });
    }
    
    return result.OrderBy(p => p.DueDate).ToList();
}
```

### Get Supplier Pending Transfers
```csharp
public async Task<List<PendingTransfer>> GetSupplierPendingTransfers(Guid supplierId)
{
    // Get activities with DP paid but pelunasan pending
    var activities = await _activityRepo.GetActivitiesWithDpPaid(supplierId);
    
    var result = new List<PendingTransfer>();
    
    foreach (var activity in activities)
    {
        var dpPayment = await _paymentRepo.GetByIdAsync(activity.DownPaymentId);
        
        result.Add(new PendingTransfer
        {
            ActivityId = activity.Id,
            JourneyName = activity.Journey.Name,
            AgencyName = activity.Journey.Agency.CompanyName,
            ServiceName = activity.SupplierService.Name,
            DpAmount = dpPayment.ServiceCost,
            DpPaidDate = dpPayment.PaidAt.Value,
            PelunasanAmount = activity.TotalCost.Value - dpPayment.ServiceCost,
            PelunasanDueDate = activity.FullPaymentDueDate.Value,
            DaysUntilDue = (activity.FullPaymentDueDate.Value - DateTime.UtcNow).Days,
            TotalExpected = activity.TotalCost.Value
        });
    }
    
    return result.OrderBy(p => p.PelunasanDueDate).ToList();
}
```

---

## 🎯 API ENDPOINTS

### Payment Creation
```
POST /api/journeys/{journeyId}/activities/{activityId}/payment

Request Body:
{
  "payment_type": "down_payment" | "full_payment",
  "payment_method": "virtual_account" | "credit_card" | "ewallet" | "qris",
  "bank_code": "BCA" | "BNI" | "BRI" | "MANDIRI" (for VA only)
}

Response:
{
  "success": true,
  "data": {
    "payment_id": "uuid",
    "payment_url": "https://checkout.xendit.co/...",
    "service_cost": 75000000,
    "agency_commission": 3570000,
    "total_amount": 78570000,
    "expired_at": "2026-03-19T10:30:00Z"
  }
}
```

### Webhook Handler
```
POST /api/payments/webhook/xendit

Headers:
- x-callback-token: {webhook_token}

Body: Xendit webhook payload

Response: 200 OK
```

### Get Payment Details
```
GET /api/payments/{paymentId}

Response:
{
  "success": true,
  "data": {
    "id": "uuid",
    "payment_type": "down_payment",
    "service_cost": 75000000,
    "agency_commission": 3570000,
    "total_paid": 78570000,
    "status": "success",
    "paid_at": "2026-03-18T10:30:00Z",
    "receipt_url": "https://...",
    "supplier_transfer_status": "pending"
  }
}
```

### Agency Dashboard
```
GET /api/agency/payments/dashboard

Response:
{
  "success": true,
  "data": {
    "total_journeys": 5,
    "total_activities": 45,
    "total_service_cost": 2500000000,
    "total_platform_fees": 119000000,
    "total_paid": 1500000000,
    "total_pending": 1000000000,
    "payment_progress_percentage": 60.0
  }
}
```

### Supplier Dashboard
```
GET /api/supplier/revenue/dashboard

Response:
{
  "success": true,
  "data": {
    "total_bookings": 25,
    "gross_revenue": 1250000000,
    "platform_commission_deducted": 0,
    "net_revenue": 1250000000,
    "transferred_amount": 800000000,
    "pending_transfer_amount": 300000000,
    "awaiting_payment_amount": 150000000
  }
}
```

---

## 🔔 NOTIFICATION TRIGGERS

### Agency Notifications

```csharp
// Payment success
await _notificationService.Send(
    userId: agency.UserId,
    type: "payment_success",
    title: "Payment Successful",
    message: $"DP payment of Rp {payment.AmountPaidByAgency:N0} completed",
    data: new { payment_id = payment.Id }
);

// Pelunasan reminder (H-10, H-7, H-3)
await _notificationService.Send(
    userId: agency.UserId,
    type: "pelunasan_reminder",
    title: $"Payment Due in {daysUntilDue} Days",
    message: $"Pelunasan of Rp {amount:N0} due on {dueDate:dd MMM yyyy}",
    data: new { activity_id = activity.Id }
);

// Overdue alert
await _notificationService.Send(
    userId: agency.UserId,
    type: "payment_overdue",
    title: "Payment Overdue",
    message: $"Payment overdue by {daysOverdue} days. Service may be cancelled.",
    data: new { activity_id = activity.Id },
    priority: "urgent"
);
```

### Supplier Notifications

```csharp
// DP received
await _notificationService.Send(
    userId: supplier.UserId,
    type: "dp_received",
    title: "Down Payment Received",
    message: $"DP of Rp {payment.ServiceCost:N0} received and held",
    data: new { payment_id = payment.Id }
);

// Transfer complete
await _notificationService.Send(
    userId: supplier.UserId,
    type: "transfer_complete",
    title: "Funds Transferred",
    message: $"Rp {totalAmount:N0} transferred to your account",
    data: new { 
        transfer_reference = transferReference,
        activity_id = activity.Id 
    }
);
```

---

## ⚙️ BACKGROUND JOBS

### Supplier Transfer Job (Hourly)
```csharp
[AutomaticRetry(Attempts = 3)]
public async Task ProcessSupplierTransfers()
{
    var activities = await _activityRepo.GetActivitiesReadyForTransfer();
    
    foreach (var activity in activities)
    {
        try
        {
            await _transferService.TransferToSupplier(activity.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, $"Transfer failed for activity {activity.Id}");
            // Will retry on next job run
        }
    }
}
```

### Pelunasan Reminder Job (Daily 08:00)
```csharp
public async Task SendPelunasanReminders()
{
    var today = DateTime.UtcNow.Date;
    
    // H-10 reminders
    var h10Activities = await _activityRepo.GetActivitiesWithPelunasanDue(
        today.AddDays(10)
    );
    foreach (var activity in h10Activities)
    {
        await _notificationService.SendPelunasanReminder(activity, 10);
    }
    
    // H-7 reminders
    var h7Activities = await _activityRepo.GetActivitiesWithPelunasanDue(
        today.AddDays(7)
    );
    foreach (var activity in h7Activities)
    {
        await _notificationService.SendPelunasanReminder(activity, 7);
    }
    
    // H-3 reminders
    var h3Activities = await _activityRepo.GetActivitiesWithPelunasanDue(
        today.AddDays(3)
    );
    foreach (var activity in h3Activities)
    {
        await _notificationService.SendPelunasanReminder(activity, 3);
    }
}
```

### Overdue Payment Job (Daily 09:00)
```csharp
public async Task ProcessOverduePayments()
{
    var today = DateTime.UtcNow.Date;
    
    // Get overdue activities
    var overdueActivities = await _activityRepo.GetOverdueActivities(today);
    
    foreach (var activity in overdueActivities)
    {
        var daysOverdue = (today - activity.FullPaymentDueDate.Value).Days;
        
        if (daysOverdue <= 3)
        {
            // Grace period - send reminder
            await _notificationService.SendOverdueAlert(activity, daysOverdue);
        }
        else
        {
            // Grace period expired - auto-cancel
            await _activityService.CancelActivity(
                activity.Id, 
                reason: "Payment overdue - auto-cancelled after grace period"
            );
            
            // DP not refunded (penalty)
            await _notificationService.SendCancellationNotification(activity);
        }
    }
}
```

---

## 🎯 VALIDATION RULES

### Publish Journey Validation
```csharp
public async Task<ValidationResult> ValidatePublish(Guid journeyId)
{
    var journey = await _journeyRepo.GetByIdAsync(journeyId);
    var errors = new List<string>();
    
    // Check has activities
    if (!journey.Activities.Any())
    {
        errors.Add("Journey must have at least 1 activity");
    }
    
    // Check all service-based activities have services
    var serviceTypes = new[] { "hotel", "flight", "visa", "transport", "guide", "insurance", "catering", "handling" };
    var serviceActivities = journey.Activities.Where(a => serviceTypes.Contains(a.Type));
    
    foreach (var activity in serviceActivities)
    {
        if (activity.SupplierServiceId == null && activity.AgencyServiceId == null)
        {
            errors.Add($"Activity {activity.ActivityNumber} requires a service");
        }
    }
    
    // Check marketplace services payment status
    var marketplaceActivities = journey.Activities.Where(a => a.SourceType == "supplier");
    
    foreach (var activity in marketplaceActivities)
    {
        var service = await _serviceRepo.GetByIdAsync(activity.SupplierServiceId);
        
        // If payment terms enabled, check DP paid
        if (service.PaymentTermsEnabled)
        {
            if (activity.PaymentStatus != "dp_paid" && activity.PaymentStatus != "fully_paid")
            {
                errors.Add($"Activity {activity.ActivityNumber}: DP payment required");
            }
        }
        // If no payment terms, check fully paid
        else
        {
            if (activity.PaymentStatus != "fully_paid")
            {
                errors.Add($"Activity {activity.ActivityNumber}: Full payment required");
            }
        }
        
        // Check service availability
        if (!activity.IsServiceAvailable)
        {
            errors.Add($"Activity {activity.ActivityNumber}: Service no longer available");
        }
    }
    
    return new ValidationResult
    {
        IsValid = !errors.Any(),
        Errors = errors
    };
}
```

---

## 📋 STATUS VALUES

### JourneyActivity.PaymentStatus
- `unpaid` - No payment made
- `dp_paid` - DP paid, awaiting pelunasan
- `fully_paid` - All payments complete
- `reserved` - Using inventory (no payment)

### Payment.Status
- `pending` - Payment link created
- `processing` - Gateway processing
- `success` - Payment completed
- `failed` - Payment failed (can retry)
- `expired` - Payment link expired (can retry)

### Payment.SupplierTransferStatus
- `pending` - Awaiting transfer (DP held until pelunasan)
- `transferred` - Funds sent to supplier
- `failed` - Transfer failed (will retry)

---

## 🔗 RELATED DOCUMENTS

- `PAYMENT-TRACKING-COMPREHENSIVE.md` - Complete tracking analysis
- `PAYMENT-COMMISSION-SUMMARY.md` - Executive summary
- `PAYMENT-FLOW-DIAGRAM.md` - Visual diagrams
- `ANSWER-TO-USER-QUESTIONS.md` - Jawaban lengkap (Indonesian)

---

**Last Updated**: 18 March 2026

