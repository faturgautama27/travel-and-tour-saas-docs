# Complete Implementation Guide: Supplier Service to Booking System

**Target Audience**: AI Agents (Sonnet 4.6 → Gemini Flash)  
**Purpose**: Step-by-step implementation guide with Backend + Frontend + Diagrams  
**Scope**: Complete flow from Supplier Service creation to Customer Booking  
**Date**: March 26, 2026  
**Version**: 1.0

---

## 📚 TABLE OF CONTENTS

### Part 1: Foundation
- [Overview & Architecture](#overview--architecture)
- [System Flow Diagrams](#system-flow-diagrams)
- [Implementation Principles](#implementation-principles)

### Part 2: Core Features
- [Phase 1: Supplier Service Management](#phase-1-supplier-service-management)
- [Phase 2: Service Availability System](#phase-2-service-availability-system)
- [Phase 3: Agency Procurement (Cart & PO)](#phase-3-agency-procurement)
- [Phase 4: Journey Refactoring](#phase-4-journey-refactoring)
- [Phase 5: Journey Activity Management](#phase-5-journey-activity-management)
- [Phase 6: Dynamic Service Selection](#phase-6-dynamic-service-selection)
- [Phase 7: Journey Publishing](#phase-7-journey-publishing)
- [Phase 8: Booking System](#phase-8-booking-system)

### Part 3: Testing & Deployment
- [Integration Testing](#integration-testing)
- [End-to-End Testing](#end-to-end-testing)
- [Deployment Checklist](#deployment-checklist)

---

## 🎯 OVERVIEW & ARCHITECTURE

### System Overview

This system enables:
1. **Suppliers** create services (hotel, flight, visa, etc.) with dynamic JSON details
2. **Suppliers** manage per-date availability and pricing
3. **Agencies** browse marketplace and procure services via Purchase Orders
4. **Agencies** create journeys with integrated itinerary builder
5. **Agencies** select services dynamically based on activity type and dates
6. **Agencies** publish journeys after validation
7. **Customers** book published journeys

### Technology Stack

**Backend**:
- ASP.NET Core 8.0
- PostgreSQL 15+ with JSONB support
- Entity Framework Core 8.0
- MediatR (CQRS pattern)
- FluentValidation
- MinIO (object storage for images)

**Frontend**:
- Angular 17+
- TypeScript
- RxJS
- Angular Material / PrimeNG
- TailwindCSS

### Architecture Patterns

1. **Clean Architecture**: Domain → Application → Infrastructure → API
2. **CQRS**: Commands for writes, Queries for reads
3. **Repository Pattern**: Data access abstraction
4. **DTO Pattern**: API request/response objects
5. **Service Layer**: Business logic encapsulation

---

