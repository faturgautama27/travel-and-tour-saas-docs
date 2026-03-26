# Complete Implementation Guide: All Phases (Backend + Frontend)

**Version**: 1.0  
**Date**: March 26, 2026  
**Scope**: Phase 1-8 Complete Implementation  
**Format**: Backend → Frontend for each phase

---

## 📚 TABLE OF CONTENTS

- [Phase 1: Supplier Service Management](#phase-1-supplier-service-management)
- [Phase 2: Service Availability System](#phase-2-service-availability-system)
- [Phase 3: Agency Procurement](#phase-3-agency-procurement)
- [Phase 4: Journey Refactoring](#phase-4-journey-refactoring)
- [Phase 5: Journey Activity Management](#phase-5-journey-activity-management)
- [Phase 6: Dynamic Service Selection](#phase-6-dynamic-service-selection)
- [Phase 7: Journey Publishing](#phase-7-journey-publishing)
- [Phase 8: Booking System](#phase-8-booking-system)

---

# PHASE 1: SUPPLIER SERVICE MANAGEMENT

## Overview
Suppliers create services (8 types) with dynamic JSON details, upload images, set availability, and publish.

## Backend Tasks Summary
1. Create entities (SupplierService, SupplierServiceImage)
2. Create EF configurations
3. Create migration
4. Create commands (Create, Update, Delete, Publish, UploadImage)
5. Create queries (GetById, GetList)
6. Create DTOs
7. Create validators
8. Create controllers
9. Create MinIO service

## Frontend Tasks Summary
1. Create service module
2. Create service form component
3. Create service list component
4. Create service detail component
5. Create image upload component
6. Create JSON editor component
7. Create service API service
8. Create routing

## Key Files to Create

### Backend (15 files):
```
Domain/Entities/SupplierService.cs
Domain/Entities/SupplierServiceImage.cs
Infrastructure/Data/Configurations/SupplierServiceConfiguration.cs
Infrastructure/Data/Configurations/SupplierServiceImageConfiguration.cs
Application/Commands/SupplierService/CreateSupplierServiceCommand.cs
Application/Commands/SupplierService/CreateSupplierServiceCommandHandler.cs
Application/Commands/SupplierService/CreateSupplierServiceCommandValidator.cs
Application/Commands/SupplierService/UpdateSupplierServiceCommand.cs
Application/Commands/SupplierService/UpdateSupplierServiceCommandHandler.cs
Application/Commands/SupplierService/PublishSupplierServiceCommand.cs
Application/Commands/SupplierService/PublishSupplierServiceCommandHandler.cs
Application/Commands/SupplierService/UploadSupplierServiceImageCommand.cs
Application/Commands/SupplierService/UploadSupplierServiceImageCommandHandler.cs
Application/Queries/SupplierService/GetSupplierServiceQuery.cs
Application/Queries/SupplierService/GetSupplierServiceQueryHandler.cs
Application/Queries/SupplierService/GetSupplierServicesListQuery.cs
Application/Queries/SupplierService/GetSupplierServicesListQueryHandler.cs
Application/DTOs/SupplierServiceDto.cs
Application/DTOs/SupplierServiceImageDto.cs
Infrastructure/Services/MinIOService.cs
API/Controllers/SupplierServicesController.cs
```

### Frontend (12 files):
```
src/app/features/supplier/services/supplier-service.module.ts
src/app/features/supplier/services/components/service-form/service-form.component.ts
src/app/features/supplier/services/components/service-form/service-form.component.html
src/app/features/supplier/services/components/service-list/service-list.component.ts
src/app/features/supplier/services/components/service-list/service-list.component.html
src/app/features/supplier/services/components/service-detail/service-detail.component.ts
src/app/features/supplier/services/components/service-detail/service-detail.component.html
src/app/features/supplier/services/components/image-upload/image-upload.component.ts
src/app/features/supplier/services/components/image-upload/image-upload.component.html
src/app/features/supplier/services/components/json-editor/json-editor.component.ts
src/app/features/supplier/services/components/json-editor/json-editor.component.html
src/app/features/supplier/services/services/supplier-service-api.service.ts
src/app/features/supplier/services/supplier-service-routing.module.ts
```

---

# PHASE 2: SERVICE AVAILABILITY SYSTEM

## Overview
Suppliers manage per-date availability and pricing for services.

## Backend Tasks Summary
1. Create ServiceAvailability entity
2. Create EF configuration
3. Create migration
4. Create bulk create command
5. Create update command
6. Create query handler
7. Create controller endpoints

## Frontend Tasks Summary
1. Create availability calendar component
2. Create bulk create form
3. Create date range picker
4. Create availability API service
5. Integrate with service detail page

## Key Files to Create

### Backend (8 files):
```
Domain/Entities/ServiceAvailability.cs
Infrastructure/Data/Configurations/ServiceAvailabilityConfiguration.cs
Application/Commands/ServiceAvailability/BulkCreateServiceAvailabilityCommand.cs
Application/Commands/ServiceAvailability/BulkCreateServiceAvailabilityCommandHandler.cs
Application/Commands/ServiceAvailability/UpdateServiceAvailabilityCommand.cs
Application/Commands/ServiceAvailability/UpdateServiceAvailabilityCommandHandler.cs
Application/Queries/ServiceAvailability/GetServiceAvailabilityQuery.cs
Application/Queries/ServiceAvailability/GetServiceAvailabilityQueryHandler.cs
Application/DTOs/ServiceAvailabilityDto.cs
API/Controllers/ServiceAvailabilityController.cs
```

### Frontend (6 files):
```
src/app/features/supplier/services/components/availability-calendar/availability-calendar.component.ts
src/app/features/supplier/services/components/availability-calendar/availability-calendar.component.html
src/app/features/supplier/services/components/bulk-availability-form/bulk-availability-form.component.ts
src/app/features/supplier/services/components/bulk-availability-form/bulk-availability-form.component.html
src/app/features/supplier/services/services/service-availability-api.service.ts
src/app/shared/components/date-range-picker/date-range-picker.component.ts
```

---

# PHASE 3: AGENCY PROCUREMENT

## Overview
Agencies browse marketplace, add to cart, create purchase orders, supplier approves, services become inventory.

## Backend Tasks Summary
1. Create Cart & CartItem entities
2. Create PurchaseOrder & POItem entities
3. Create AgencyService entity
4. Create EF configurations
5. Create migrations
6. Create cart commands (Add, Update, Remove, Clear)
7. Create PO commands (Create, Approve, Reject)
8. Create marketplace query
9. Create controllers

## Frontend Tasks Summary
1. Create marketplace component
2. Create service card component
3. Create cart component
4. Create PO list component
5. Create PO detail component
6. Create API services
7. Create routing

## Key Files to Create

### Backend (20 files):
```
Domain/Entities/Cart.cs
Domain/Entities/CartItem.cs
Domain/Entities/PurchaseOrder.cs
Domain/Entities/POItem.cs
Domain/Entities/AgencyService.cs
Infrastructure/Data/Configurations/CartConfiguration.cs
Infrastructure/Data/Configurations/CartItemConfiguration.cs
Infrastructure/Data/Configurations/PurchaseOrderConfiguration.cs
Infrastructure/Data/Configurations/POItemConfiguration.cs
Infrastructure/Data/Configurations/AgencyServiceConfiguration.cs
Application/Commands/Cart/AddCartItemCommand.cs
Application/Commands/Cart/AddCartItemCommandHandler.cs
Application/Commands/Cart/RemoveCartItemCommand.cs
Application/Commands/Cart/RemoveCartItemCommandHandler.cs
Application/Commands/Cart/ClearCartCommand.cs
Application/Commands/Cart/ClearCartCommandHandler.cs
Application/Commands/PurchaseOrder/CreatePurchaseOrderCommand.cs
Application/Commands/PurchaseOrder/CreatePurchaseOrderCommandHandler.cs
Application/Commands/PurchaseOrder/ApprovePurchaseOrderCommand.cs
Application/Commands/PurchaseOrder/ApprovePurchaseOrderCommandHandler.cs
Application/Queries/Marketplace/GetMarketplaceServicesQuery.cs
Application/Queries/Marketplace/GetMarketplaceServicesQueryHandler.cs
Application/Queries/Cart/GetCartQuery.cs
Application/Queries/Cart/GetCartQueryHandler.cs
Application/DTOs/CartDto.cs
Application/DTOs/CartItemDto.cs
Application/DTOs/PurchaseOrderDto.cs
Application/DTOs/MarketplaceServiceDto.cs
API/Controllers/MarketplaceController.cs
API/Controllers/CartController.cs
API/Controllers/PurchaseOrdersController.cs
```

### Frontend (15 files):
```
src/app/features/agency/marketplace/marketplace.module.ts
src/app/features/agency/marketplace/components/marketplace-list/marketplace-list.component.ts
src/app/features/agency/marketplace/components/marketplace-list/marketplace-list.component.html
src/app/features/agency/marketplace/components/service-card/service-card.component.ts
src/app/features/agency/marketplace/components/service-card/service-card.component.html
src/app/features/agency/marketplace/components/cart/cart.component.ts
src/app/features/agency/marketplace/components/cart/cart.component.html
src/app/features/agency/procurement/procurement.module.ts
src/app/features/agency/procurement/components/po-list/po-list.component.ts
src/app/features/agency/procurement/components/po-list/po-list.component.html
src/app/features/agency/procurement/components/po-detail/po-detail.component.ts
src/app/features/agency/procurement/components/po-detail/po-detail.component.html
src/app/features/agency/marketplace/services/marketplace-api.service.ts
src/app/features/agency/marketplace/services/cart-api.service.ts
src/app/features/agency/procurement/services/purchase-order-api.service.ts
```

---

