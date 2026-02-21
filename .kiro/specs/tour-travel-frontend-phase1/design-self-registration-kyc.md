# Self-Registration with KYC Verification - Frontend Design Document

## Overview

This document extends the main frontend design with specifications for Self-Registration and KYC (Know Your Customer) Verification features for both Agencies and Suppliers. The frontend provides public registration pages, document upload interface, and platform admin verification dashboard.

### Key Features

1. **Public Registration Pages**: Agency and Supplier self-registration forms
2. **Document Upload Interface**: Multi-file upload with progress tracking
3. **Document Management**: View, upload, re-upload documents
4. **Admin Verification Dashboard**: Review and approve/reject entities
5. **Document Preview**: View uploaded documents without downloading
6. **Access Control**: Route guards based on verification status
7. **Responsive Design**: Mobile-friendly interfaces

### Technology Stack

- **Framework**: Angular 20 with Standalone Components
- **UI Library**: PrimeNG 20
- **Styling**: TailwindCSS 4
- **Icons**: Lucide Angular
- **State Management**: NGXS
- **Forms**: Reactive Forms with validation
- **File Upload**: Native HTML5 with progress tracking
- **PDF Preview**: ng2-pdf-viewer or iframe

---

## Folder Structure

```
src/app/
├── features/
│   ├── auth/
│   │   ├── pages/
│   │   │   ├── agency-registration/
│   │   │   │   ├── agency-registration.component.ts
│   │   │   │   ├── agency-registration.component.html
│   │   │   │   └── agency-registration.component.scss
│   │   │   └── supplier-registration/
│   │   │       ├── supplier-registration.component.ts
│   │   │       ├── supplier-registration.component.html
│   │   │       └── supplier-registration.component.scss
│   │   └── auth.routes.ts
│   │
│   ├── documents/
│   │   ├── pages/
│   │   │   └── document-upload/
│   │   │       ├── document-upload.component.ts
│   │   │       ├── document-upload.component.html
│   │   │       └── document-upload.component.scss
│   │   ├── components/
│   │   │   ├── document-checklist/
│   │   │   │   ├── document-checklist.component.ts
│   │   │   │   ├── document-checklist.component.html
│   │   │   │   └── document-checklist.component.scss
│   │   │   ├── document-progress-widget/
│   │   │   │   ├── document-progress-widget.component.ts
│   │   │   │   ├── document-progress-widget.component.html
│   │   │   │   └── document-progress-widget.component.scss
│   │   │   ├── document-upload-button/
│   │   │   │   ├── document-upload-button.component.ts
│   │   │   │   ├── document-upload-button.component.html
│   │   │   │   └── document-upload-button.component.scss
│   │   │   └── document-preview-modal/
│   │   │       ├── document-preview-modal.component.ts
│   │   │       ├── document-preview-modal.component.html
│   │   │       └── document-preview-modal.component.scss
│   │   ├── services/
│   │   │   └── document.service.ts
│   │   ├── store/
│   │   │   ├── document.state.ts
│   │   │   └── document.actions.ts
│   │   └── documents.routes.ts
│   │
│   └── admin/
│       ├── pages/
│       │   ├── verification-queue/
│       │   │   ├── verification-queue.component.ts
│       │   │   ├── verification-queue.component.html
│       │   │   └── verification-queue.component.scss
│       │   └── entity-verification-detail/
│       │       ├── entity-verification-detail.component.ts
│       │       ├── entity-verification-detail.component.html
│       │       └── entity-verification-detail.component.scss
│       ├── components/
│       │   └── verification-actions/
│       │       ├── verification-actions.component.ts
│       │       ├── verification-actions.component.html
│       │       └── verification-actions.component.scss
│       ├── services/
│       │   └── verification.service.ts
│       └── admin.routes.ts
│
├── core/
│   ├── guards/
│   │   └── verification.guard.ts
│   └── interceptors/
│       └── (existing interceptors)
│
└── shared/
    ├── models/
    │   ├── document.model.ts
    │   ├── document-progress.model.ts
    │   └── verification-queue.model.ts
    └── utils/
        └── file-validation.util.ts
```

---

## Models & Interfaces

### Document Models

```typescript
// src/app/shared/models/document.model.ts

export interface EntityDocument {
  id: string;
  document_type: string;
  document_label: string;
  document_category: 'identity' | 'business_legal' | 'operational' | 'service_specific';
  is_mandatory: boolean;
  file_name?: string;
  file_size?: number;
  file_url?: string;
  verification_status: 'pending' | 'verified' | 'rejected';
  rejection_reason?: string;
  uploaded_at?: string;
  verified_at?: string;
}

export interface DocumentProgress {
  total_mandatory_documents: number;
  uploaded_documents: number;
  verified_documents: number;
  rejected_documents: number;
  completion_percentage: number;
  verification_status: 'pending_documents' | 'awaiting_approval' | 'verified' | 'rejected';
  verification_attempts: number;
  max_verification_attempts: number;
  can_resubmit: boolean;
}

export interface DocumentUploadRequest {
  file: File;
  document_type: string;
}

export interface DocumentUploadResponse {
  document_id: string;
  file_url: string;
  message: string;
}
```

### Registration Models

```typescript
// src/app/features/auth/models/registration.model.ts

export interface AgencyRegistrationRequest {
  company_name: string;
  owner_name: string;
  email: string;
  phone: string;
  business_type: string;
  password: string;
  confirm_password: string;
}

export interface SupplierRegistrationRequest {
  company_name: string;
  owner_name: string;
  email: string;
  phone: string;
  business_type: string;
  service_types: string[];
  password: string;
  confirm_password: string;
  address: string;
  city: string;
  province: string;
  postal_code: string;
  country: string;
}

export interface RegistrationResponse {
  agency_id?: string;
  supplier_id?: string;
  entity_code: string;
  message: string;
  redirect_url: string;
}
```

### Verification Models

```typescript
// src/app/shared/models/verification-queue.model.ts

export interface VerificationQueueItem {
  entity_id: string;
  entity_type: 'agency' | 'supplier';
  entity_code: string;
  company_name: string;
  owner_name: string;
  email: string;
  verification_status: string;
  documents_uploaded: number;
  documents_verified: number;
  documents_rejected: number;
  created_at: string;
}

export interface EntityVerificationDetail {
  entity: {
    id: string;
    entity_type: 'agency' | 'supplier';
    entity_code: string;
    company_name: string;
    owner_name: string;
    email: string;
    phone: string;
    business_type: string;
    address?: string;
    city?: string;
    verification_status: string;
    verification_attempts: number;
    created_at: string;
  };
  documents: EntityDocument[];
}
```

---

## Services

### DocumentService

```typescript
// src/app/features/documents/services/document.service.ts

import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpEvent } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '@env/environment';

@Injectable({ providedIn: 'root' })
export class DocumentService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/documents`;

  getDocuments(): Observable<ApiResponse<EntityDocument[]>> {
    return this.http.get<ApiResponse<EntityDocument[]>>(this.apiUrl);
  }

  getDocumentProgress(): Observable<ApiResponse<DocumentProgress>> {
    return this.http.get<ApiResponse<DocumentProgress>>(`${this.apiUrl}/progress`);
  }

  uploadDocument(file: File, documentType: string): Observable<HttpEvent<ApiResponse<DocumentUploadResponse>>> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('document_type', documentType);

    return this.http.post<ApiResponse<DocumentUploadResponse>>(
      `${this.apiUrl}/upload`,
      formData,
      {
        reportProgress: true,
        observe: 'events'
      }
    );
  }

  downloadDocument(documentId: string): Observable<Blob> {
    return this.http.get(`${this.apiUrl}/${documentId}/download`, {
      responseType: 'blob'
    });
  }

  deleteDocument(documentId: string): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${documentId}`);
  }
}
```

### VerificationService

```typescript
// src/app/features/admin/services/verification.service.ts

import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '@env/environment';

@Injectable({ providedIn: 'root' })
export class VerificationService {
  private http = inject(HttpClient);
  private apiUrl = `${environment.apiUrl}/admin`;

  getVerificationQueue(filters?: {
    entity_type?: string;
    verification_status?: string;
    from_date?: string;
    to_date?: string;
    page?: number;
    page_size?: number;
  }): Observable<PaginatedResponse<VerificationQueueItem>> {
    let params = new HttpParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params = params.set(key, value.toString());
      });
    }
    return this.http.get<PaginatedResponse<VerificationQueueItem>>(
      `${this.apiUrl}/verification-queue`,
      { params }
    );
  }

  getEntityVerificationDetail(entityType: string, entityId: string): Observable<ApiResponse<EntityVerificationDetail>> {
    return this.http.get<ApiResponse<EntityVerificationDetail>>(
      `${this.apiUrl}/verification/${entityType}/${entityId}`
    );
  }

  verifyDocument(documentId: string): Observable<ApiResponse<void>> {
    return this.http.put<ApiResponse<void>>(
      `${this.apiUrl}/documents/${documentId}/verify`,
      {}
    );
  }

  rejectDocument(documentId: string, rejectionReason: string): Observable<ApiResponse<void>> {
    return this.http.put<ApiResponse<void>>(
      `${this.apiUrl}/documents/${documentId}/reject`,
      { rejection_reason: rejectionReason }
    );
  }

  approveEntity(entityType: string, entityId: string): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(
      `${this.apiUrl}/verification/${entityType}/${entityId}/approve`,
      {}
    );
  }

  rejectEntity(entityType: string, entityId: string, rejectionReason: string): Observable<ApiResponse<void>> {
    return this.http.post<ApiResponse<void>>(
      `${this.apiUrl}/verification/${entityType}/${entityId}/reject`,
      { rejection_reason: rejectionReason }
    );
  }
}
```

---

## NGXS Store

### Document State

```typescript
// src/app/features/documents/store/document.state.ts

import { Injectable, inject } from '@angular/core';
import { State, Action, StateContext, Selector } from '@ngxs/store';
import { tap } from 'rxjs/operators';
import { DocumentService } from '../services/document.service';
import { DocumentActions } from './document.actions';

export interface DocumentStateModel {
  documents: EntityDocument[];
  progress: DocumentProgress | null;
  loading: boolean;
  uploadProgress: number;
}

@State<DocumentStateModel>({
  name: 'documents',
  defaults: {
    documents: [],
    progress: null,
    loading: false,
    uploadProgress: 0
  }
})
@Injectable()
export class DocumentState {
  private documentService = inject(DocumentService);

  @Selector()
  static documents(state: DocumentStateModel) {
    return state.documents;
  }

  @Selector()
  static progress(state: DocumentStateModel) {
    return state.progress;
  }

  @Selector()
  static loading(state: DocumentStateModel) {
    return state.loading;
  }

  @Selector()
  static uploadProgress(state: DocumentStateModel) {
    return state.uploadProgress;
  }

  @Action(DocumentActions.LoadDocuments)
  loadDocuments(ctx: StateContext<DocumentStateModel>) {
    ctx.patchState({ loading: true });
    return this.documentService.getDocuments().pipe(
      tap(response => {
        ctx.patchState({
          documents: response.data,
          loading: false
        });
      })
    );
  }

  @Action(DocumentActions.LoadProgress)
  loadProgress(ctx: StateContext<DocumentStateModel>) {
    return this.documentService.getDocumentProgress().pipe(
      tap(response => {
        ctx.patchState({ progress: response.data });
      })
    );
  }

  @Action(DocumentActions.UploadDocument)
  uploadDocument(ctx: StateContext<DocumentStateModel>, action: DocumentActions.UploadDocument) {
    ctx.patchState({ uploadProgress: 0 });
    return this.documentService.uploadDocument(action.file, action.documentType).pipe(
      tap(event => {
        if (event.type === HttpEventType.UploadProgress && event.total) {
          const progress = Math.round((100 * event.loaded) / event.total);
          ctx.patchState({ uploadProgress: progress });
        } else if (event.type === HttpEventType.Response) {
          ctx.patchState({ uploadProgress: 100 });
          ctx.dispatch(new DocumentActions.LoadDocuments());
          ctx.dispatch(new DocumentActions.LoadProgress());
        }
      })
    );
  }
}
```

### Document Actions

```typescript
// src/app/features/documents/store/document.actions.ts

export namespace DocumentActions {
  export class LoadDocuments {
    static readonly type = '[Documents] Load Documents';
  }

  export class LoadProgress {
    static readonly type = '[Documents] Load Progress';
  }

  export class UploadDocument {
    static readonly type = '[Documents] Upload Document';
    constructor(public file: File, public documentType: string) {}
  }

  export class DeleteDocument {
    static readonly type = '[Documents] Delete Document';
    constructor(public documentId: string) {}
  }
}
```

---

## Route Guards

### VerificationGuard

```typescript
// src/app/core/guards/verification.guard.ts

import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { Store } from '@ngxs/store';
import { AuthState } from '@app/store/auth/auth.state';

export const verificationGuard: CanActivateFn = () => {
  const store = inject(Store);
  const router = inject(Router);

  const user = store.selectSnapshot(AuthState.user);
  
  if (!user) {
    return router.createUrlTree(['/auth/login']);
  }

  // Platform admin can access everything
  if (user.user_type === 'platform_admin') {
    return true;
  }

  // Check verification status
  const verificationStatus = user.verification_status;
  
  if (verificationStatus === 'verified') {
    return true;
  }

  // Redirect unverified users to document upload
  return router.createUrlTree(['/documents/upload']);
};
```

---

## Components

### Agency Registration Component

```typescript
// src/app/features/auth/pages/agency-registration/agency-registration.component.ts

import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';
import { InputTextModule } from 'primeng/inputtext';
import { DropdownModule } from 'primeng/dropdown';
import { PasswordModule } from 'primeng/password';
import { MessageService } from 'primeng/api';
import { AuthService } from '@app/core/services/auth.service';

@Component({
  selector: 'app-agency-registration',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    RouterLink,
    ButtonModule,
    InputTextModule,
    DropdownModule,
    PasswordModule
  ],
  templateUrl: './agency-registration.component.html',
  styleUrls: ['./agency-registration.component.scss']
})
export class AgencyRegistrationComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);
  private router = inject(Router);
  private messageService = inject(MessageService);

  loading = signal(false);

  businessTypes = [
    { label: 'PT (Perseroan Terbatas)', value: 'PT' },
    { label: 'CV (Commanditaire Vennootschap)', value: 'CV' },
    { label: 'Individual / Perorangan', value: 'Individual' }
  ];

  registrationForm: FormGroup = this.fb.group({
    company_name: ['', [Validators.required]],
    owner_name: ['', [Validators.required]],
    email: ['', [Validators.required, Validators.email]],
    phone: ['', [Validators.required]],
    business_type: ['', [Validators.required]],
    password: ['', [Validators.required, Validators.minLength(8)]],
    confirm_password: ['', [Validators.required]]
  }, {
    validators: this.passwordMatchValidator
  });

  passwordMatchValidator(form: FormGroup) {
    const password = form.get('password');
    const confirmPassword = form.get('confirm_password');
    
    if (password && confirmPassword && password.value !== confirmPassword.value) {
      confirmPassword.setErrors({ passwordMismatch: true });
      return { passwordMismatch: true };
    }
    return null;
  }

  onSubmit() {
    if (this.registrationForm.invalid) {
      this.registrationForm.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    
    this.authService.registerAgency(this.registrationForm.value).subscribe({
      next: (response) => {
        this.messageService.add({
          severity: 'success',
          summary: 'Registration Successful',
          detail: response.data.message
        });
        this.router.navigate([response.data.redirect_url]);
      },
      error: (error) => {
        this.loading.set(false);
        this.messageService.add({
          severity: 'error',
          summary: 'Registration Failed',
          detail: error.error?.error?.message || 'An error occurred'
        });
      }
    });
  }
}
```


### Agency Registration Template

```html
<!-- src/app/features/auth/pages/agency-registration/agency-registration.component.html -->

<div class="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
  <div class="max-w-md w-full space-y-8">
    <!-- Header -->
    <div class="text-center">
      <h2 class="text-3xl font-bold text-gray-900">Register Your Travel Agency</h2>
      <p class="mt-2 text-sm text-gray-600">
        Already have an account?
        <a routerLink="/auth/login" class="font-medium text-primary-600 hover:text-primary-500">
          Sign in
        </a>
      </p>
    </div>

    <!-- Registration Form -->
    <form [formGroup]="registrationForm" (ngSubmit)="onSubmit()" class="mt-8 space-y-6">
      <div class="space-y-4">
        <!-- Company Name -->
        <div>
          <label for="company_name" class="block text-sm font-medium text-gray-700">Company Name *</label>
          <input
            id="company_name"
            type="text"
            pInputText
            formControlName="company_name"
            class="p-inputtext-sm w-full mt-1"
            placeholder="Enter company name"
          />
          @if (registrationForm.get('company_name')?.invalid && registrationForm.get('company_name')?.touched) {
            <small class="text-red-600">Company name is required</small>
          }
        </div>

        <!-- Owner Name -->
        <div>
          <label for="owner_name" class="block text-sm font-medium text-gray-700">Owner Name *</label>
          <input
            id="owner_name"
            type="text"
            pInputText
            formControlName="owner_name"
            class="p-inputtext-sm w-full mt-1"
            placeholder="Enter owner name"
          />
          @if (registrationForm.get('owner_name')?.invalid && registrationForm.get('owner_name')?.touched) {
            <small class="text-red-600">Owner name is required</small>
          }
        </div>

        <!-- Email -->
        <div>
          <label for="email" class="block text-sm font-medium text-gray-700">Email Address *</label>
          <input
            id="email"
            type="email"
            pInputText
            formControlName="email"
            class="p-inputtext-sm w-full mt-1"
            placeholder="Enter email address"
          />
          @if (registrationForm.get('email')?.invalid && registrationForm.get('email')?.touched) {
            <small class="text-red-600">Valid email is required</small>
          }
        </div>

        <!-- Phone -->
        <div>
          <label for="phone" class="block text-sm font-medium text-gray-700">Phone Number *</label>
          <input
            id="phone"
            type="tel"
            pInputText
            formControlName="phone"
            class="p-inputtext-sm w-full mt-1"
            placeholder="+62812345678"
          />
          @if (registrationForm.get('phone')?.invalid && registrationForm.get('phone')?.touched) {
            <small class="text-red-600">Phone number is required</small>
          }
        </div>

        <!-- Business Type -->
        <div>
          <label for="business_type" class="block text-sm font-medium text-gray-700">Business Type *</label>
          <p-dropdown
            id="business_type"
            formControlName="business_type"
            [options]="businessTypes"
            optionLabel="label"
            optionValue="value"
            placeholder="Select business type"
            styleClass="w-full"
            [size]="'small'"
          />
          @if (registrationForm.get('business_type')?.invalid && registrationForm.get('business_type')?.touched) {
            <small class="text-red-600">Business type is required</small>
          }
        </div>

        <!-- Password -->
        <div>
          <label for="password" class="block text-sm font-medium text-gray-700">Password *</label>
          <p-password
            id="password"
            formControlName="password"
            [toggleMask]="true"
            [feedback]="true"
            styleClass="w-full"
            inputStyleClass="p-inputtext-sm w-full"
            placeholder="Enter password"
          />
          @if (registrationForm.get('password')?.invalid && registrationForm.get('password')?.touched) {
            <small class="text-red-600">Password must be at least 8 characters</small>
          }
        </div>

        <!-- Confirm Password -->
        <div>
          <label for="confirm_password" class="block text-sm font-medium text-gray-700">Confirm Password *</label>
          <p-password
            id="confirm_password"
            formControlName="confirm_password"
            [toggleMask]="true"
            [feedback]="false"
            styleClass="w-full"
            inputStyleClass="p-inputtext-sm w-full"
            placeholder="Confirm password"
          />
          @if (registrationForm.get('confirm_password')?.hasError('passwordMismatch') && registrationForm.get('confirm_password')?.touched) {
            <small class="text-red-600">Passwords do not match</small>
          }
        </div>
      </div>

      <!-- Submit Button -->
      <div>
        <p-button
          type="submit"
          label="Register"
          [loading]="loading()"
          [disabled]="registrationForm.invalid"
          styleClass="w-full"
          [size]="'small'"
        />
      </div>

      <!-- Terms -->
      <p class="text-xs text-center text-gray-600">
        By registering, you agree to our
        <a href="#" class="text-primary-600 hover:text-primary-500">Terms of Service</a>
        and
        <a href="#" class="text-primary-600 hover:text-primary-500">Privacy Policy</a>
      </p>
    </form>
  </div>
</div>
```

---

## Document Upload Page Component

```typescript
// src/app/features/documents/pages/document-upload/document-upload.component.ts

import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Store } from '@ngxs/store';
import { Observable } from 'rxjs';
import { CardModule } from 'primeng/card';
import { ProgressBarModule } from 'primeng/progressbar';
import { MessageService } from 'primeng/api';
import { DocumentChecklistComponent } from '../../components/document-checklist/document-checklist.component';
import { DocumentProgressWidgetComponent } from '../../components/document-progress-widget/document-progress-widget.component';
import { DocumentState } from '../../store/document.state';
import { DocumentActions } from '../../store/document.actions';

@Component({
  selector: 'app-document-upload',
  standalone: true,
  imports: [
    CommonModule,
    CardModule,
    ProgressBarModule,
    DocumentChecklistComponent,
    DocumentProgressWidgetComponent
  ],
  templateUrl: './document-upload.component.html',
  styleUrls: ['./document-upload.component.scss']
})
export class DocumentUploadComponent implements OnInit {
  private store = inject(Store);
  private messageService = inject(MessageService);

  documents$ = this.store.select(DocumentState.documents);
  progress$ = this.store.select(DocumentState.progress);
  loading$ = this.store.select(DocumentState.loading);

  ngOnInit() {
    this.store.dispatch(new DocumentActions.LoadDocuments());
    this.store.dispatch(new DocumentActions.LoadProgress());
  }

  onFileSelected(file: File, documentType: string) {
    this.store.dispatch(new DocumentActions.UploadDocument(file, documentType)).subscribe({
      next: () => {
        this.messageService.add({
          severity: 'success',
          summary: 'Upload Successful',
          detail: 'Document uploaded successfully'
        });
      },
      error: (error) => {
        this.messageService.add({
          severity: 'error',
          summary: 'Upload Failed',
          detail: error.error?.error?.message || 'Failed to upload document'
        });
      }
    });
  }
}
```

### Document Upload Template

```html
<!-- src/app/features/documents/pages/document-upload/document-upload.component.html -->

<div class="container mx-auto px-4 py-8">
  <div class="max-w-6xl mx-auto">
    <!-- Header -->
    <div class="mb-6">
      <h1 class="text-3xl font-bold text-gray-900">Document Verification</h1>
      <p class="mt-2 text-gray-600">
        Upload required documents for KYC verification. All mandatory documents must be uploaded before verification.
      </p>
    </div>

    <!-- Progress Widget -->
    <div class="mb-6">
      <app-document-progress-widget [progress]="progress$ | async" />
    </div>

    <!-- Document Checklist -->
    <p-card>
      <ng-template pTemplate="header">
        <div class="p-4">
          <h2 class="text-xl font-semibold">Document Checklist</h2>
        </div>
      </ng-template>

      @if (loading$ | async) {
        <div class="flex justify-center items-center py-12">
          <i class="pi pi-spin pi-spinner text-4xl text-primary-500"></i>
        </div>
      } @else {
        <app-document-checklist
          [documents]="documents$ | async"
          (fileSelected)="onFileSelected($event.file, $event.documentType)"
        />
      }
    </p-card>

    <!-- Help Text -->
    <div class="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
      <div class="flex">
        <i class="pi pi-info-circle text-blue-500 mr-3 mt-1"></i>
        <div>
          <h3 class="font-semibold text-blue-900">Important Information</h3>
          <ul class="mt-2 text-sm text-blue-800 space-y-1">
            <li>• Maximum file size: 10MB</li>
            <li>• Accepted formats: PDF, JPG, JPEG, PNG, DOC, DOCX</li>
            <li>• All mandatory documents must be uploaded</li>
            <li>• You will receive email notification once verification is complete</li>
            <li>• Verification usually takes 1-2 business days</li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</div>
```

---

## Document Checklist Component

```typescript
// src/app/features/documents/components/document-checklist/document-checklist.component.ts

import { Component, Input, Output, EventEmitter, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { TagModule } from 'primeng/tag';
import { TooltipModule } from 'primeng/tooltip';
import { DocumentUploadButtonComponent } from '../document-upload-button/document-upload-button.component';

@Component({
  selector: 'app-document-checklist',
  standalone: true,
  imports: [
    CommonModule,
    TableModule,
    ButtonModule,
    TagModule,
    TooltipModule,
    DocumentUploadButtonComponent
  ],
  templateUrl: './document-checklist.component.html',
  styleUrls: ['./document-checklist.component.scss']
})
export class DocumentChecklistComponent {
  @Input() documents: EntityDocument[] = [];
  @Output() fileSelected = new EventEmitter<{ file: File; documentType: string }>();

  getStatusSeverity(status: string): 'success' | 'warning' | 'danger' | 'info' {
    switch (status) {
      case 'verified': return 'success';
      case 'pending': return 'warning';
      case 'rejected': return 'danger';
      default: return 'info';
    }
  }

  getStatusLabel(status: string): string {
    switch (status) {
      case 'verified': return 'Verified';
      case 'pending': return 'Pending';
      case 'rejected': return 'Rejected';
      default: return 'Not Uploaded';
    }
  }

  onFileSelected(file: File, documentType: string) {
    this.fileSelected.emit({ file, documentType });
  }
}
```

### Document Checklist Template

```html
<!-- src/app/features/documents/components/document-checklist/document-checklist.component.html -->

<p-table
  [value]="documents"
  styleClass="p-datatable-sm"
  [tableStyle]="{ 'min-width': '50rem' }"
>
  <ng-template pTemplate="header">
    <tr>
      <th>Document</th>
      <th>Category</th>
      <th>Required</th>
      <th>Status</th>
      <th>File</th>
      <th>Actions</th>
    </tr>
  </ng-template>
  <ng-template pTemplate="body" let-doc>
    <tr>
      <td>
        <div class="font-medium">{{ doc.document_label }}</div>
        @if (doc.rejection_reason) {
          <small class="text-red-600">{{ doc.rejection_reason }}</small>
        }
      </td>
      <td>
        <span class="text-sm text-gray-600">{{ doc.document_category }}</span>
      </td>
      <td>
        @if (doc.is_mandatory) {
          <p-tag value="Mandatory" severity="danger" [size]="'small'" />
        } @else {
          <p-tag value="Optional" severity="info" [size]="'small'" />
        }
      </td>
      <td>
        <p-tag
          [value]="getStatusLabel(doc.verification_status)"
          [severity]="getStatusSeverity(doc.verification_status)"
          [size]="'small'"
        />
      </td>
      <td>
        @if (doc.file_name) {
          <span class="text-sm">{{ doc.file_name }}</span>
        } @else {
          <span class="text-sm text-gray-400">No file uploaded</span>
        }
      </td>
      <td>
        <div class="flex gap-2">
          <app-document-upload-button
            [documentType]="doc.document_type"
            [currentStatus]="doc.verification_status"
            (fileSelected)="onFileSelected($event, doc.document_type)"
          />
          @if (doc.file_url) {
            <p-button
              icon="pi pi-eye"
              [size]="'small'"
              severity="secondary"
              [outlined]="true"
              pTooltip="Preview"
              (onClick)="onPreview(doc)"
            />
          }
        </div>
      </td>
    </tr>
  </ng-template>
</p-table>
```

---

## Document Progress Widget Component

```typescript
// src/app/features/documents/components/document-progress-widget/document-progress-widget.component.ts

import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { CardModule } from 'primeng/card';
import { ProgressBarModule } from 'primeng/progressbar';
import { TagModule } from 'primeng/tag';

@Component({
  selector: 'app-document-progress-widget',
  standalone: true,
  imports: [CommonModule, CardModule, ProgressBarModule, TagModule],
  templateUrl: './document-progress-widget.component.html',
  styleUrls: ['./document-progress-widget.component.scss']
})
export class DocumentProgressWidgetComponent {
  @Input() progress: DocumentProgress | null = null;

  getStatusSeverity(status: string): 'success' | 'warning' | 'danger' | 'info' {
    switch (status) {
      case 'verified': return 'success';
      case 'awaiting_approval': return 'warning';
      case 'rejected': return 'danger';
      default: return 'info';
    }
  }

  getStatusLabel(status: string): string {
    return status.split('_').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join(' ');
  }
}
```

### Document Progress Widget Template

```html
<!-- src/app/features/documents/components/document-progress-widget/document-progress-widget.component.html -->

@if (progress) {
  <p-card>
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Left: Progress -->
      <div>
        <h3 class="text-lg font-semibold mb-4">Upload Progress</h3>
        <div class="space-y-4">
          <div>
            <div class="flex justify-between mb-2">
              <span class="text-sm font-medium">Completion</span>
              <span class="text-sm font-medium">{{ progress.completion_percentage }}%</span>
            </div>
            <p-progressBar [value]="progress.completion_percentage" />
          </div>

          <div class="grid grid-cols-3 gap-4 text-center">
            <div class="p-3 bg-blue-50 rounded-lg">
              <div class="text-2xl font-bold text-blue-600">{{ progress.uploaded_documents }}</div>
              <div class="text-xs text-gray-600">Uploaded</div>
            </div>
            <div class="p-3 bg-green-50 rounded-lg">
              <div class="text-2xl font-bold text-green-600">{{ progress.verified_documents }}</div>
              <div class="text-xs text-gray-600">Verified</div>
            </div>
            <div class="p-3 bg-red-50 rounded-lg">
              <div class="text-2xl font-bold text-red-600">{{ progress.rejected_documents }}</div>
              <div class="text-xs text-gray-600">Rejected</div>
            </div>
          </div>
        </div>
      </div>

      <!-- Right: Status -->
      <div>
        <h3 class="text-lg font-semibold mb-4">Verification Status</h3>
        <div class="space-y-4">
          <div>
            <p-tag
              [value]="getStatusLabel(progress.verification_status)"
              [severity]="getStatusSeverity(progress.verification_status)"
              styleClass="text-base px-4 py-2"
            />
          </div>

          <div class="text-sm text-gray-600">
            <p>Verification Attempts: {{ progress.verification_attempts }} / {{ progress.max_verification_attempts }}</p>
          </div>

          @if (progress.verification_status === 'awaiting_approval') {
            <div class="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <p class="text-sm text-yellow-800">
                <i class="pi pi-clock mr-2"></i>
                Your documents are being reviewed. You will receive an email notification once verification is complete.
              </p>
            </div>
          }

          @if (progress.verification_status === 'verified') {
            <div class="p-4 bg-green-50 border border-green-200 rounded-lg">
              <p class="text-sm text-green-800">
                <i class="pi pi-check-circle mr-2"></i>
                Your account has been verified! You can now access all platform features.
              </p>
            </div>
          }

          @if (progress.verification_status === 'rejected' && progress.can_resubmit) {
            <div class="p-4 bg-red-50 border border-red-200 rounded-lg">
              <p class="text-sm text-red-800">
                <i class="pi pi-times-circle mr-2"></i>
                Your verification was rejected. Please re-upload the rejected documents.
              </p>
            </div>
          }

          @if (!progress.can_resubmit) {
            <div class="p-4 bg-red-50 border border-red-200 rounded-lg">
              <p class="text-sm text-red-800">
                <i class="pi pi-exclamation-triangle mr-2"></i>
                Maximum verification attempts reached. Please contact support.
              </p>
            </div>
          }
        </div>
      </div>
    </div>
  </p-card>
}
```

---

## Platform Admin Verification Queue Component

```typescript
// src/app/features/admin/pages/verification-queue/verification-queue.component.ts

import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { TableModule } from 'primeng/table';
import { ButtonModule } from 'primeng/button';
import { TagModule } from 'primeng/tag';
import { DropdownModule } from 'primeng/dropdown';
import { CalendarModule } from 'primeng/calendar';
import { VerificationService } from '../../services/verification.service';

@Component({
  selector: 'app-verification-queue',
  standalone: true,
  imports: [
    CommonModule,
    TableModule,
    ButtonModule,
    TagModule,
    DropdownModule,
    CalendarModule
  ],
  templateUrl: './verification-queue.component.html',
  styleUrls: ['./verification-queue.component.scss']
})
export class VerificationQueueComponent implements OnInit {
  private verificationService = inject(VerificationService);
  private router = inject(Router);

  queue = signal<VerificationQueueItem[]>([]);
  loading = signal(false);
  totalRecords = signal(0);

  filters = {
    entity_type: null,
    verification_status: null,
    from_date: null,
    to_date: null
  };

  entityTypes = [
    { label: 'All', value: null },
    { label: 'Agency', value: 'agency' },
    { label: 'Supplier', value: 'supplier' }
  ];

  statuses = [
    { label: 'All', value: null },
    { label: 'Pending Documents', value: 'pending_documents' },
    { label: 'Awaiting Approval', value: 'awaiting_approval' },
    { label: 'Verified', value: 'verified' },
    { label: 'Rejected', value: 'rejected' }
  ];

  ngOnInit() {
    this.loadQueue();
  }

  loadQueue(page: number = 1) {
    this.loading.set(true);
    this.verificationService.getVerificationQueue({
      ...this.filters,
      page,
      page_size: 20
    }).subscribe({
      next: (response) => {
        this.queue.set(response.data);
        this.totalRecords.set(response.pagination.total_items);
        this.loading.set(false);
      },
      error: () => {
        this.loading.set(false);
      }
    });
  }

  onFilterChange() {
    this.loadQueue();
  }

  viewDetails(item: VerificationQueueItem) {
    this.router.navigate(['/admin/verification', item.entity_type, item.entity_id]);
  }

  getStatusSeverity(status: string): 'success' | 'warning' | 'danger' | 'info' {
    switch (status) {
      case 'verified': return 'success';
      case 'awaiting_approval': return 'warning';
      case 'rejected': return 'danger';
      default: return 'info';
    }
  }
}
```

---

## Summary

This design document provides:

1. **Folder Structure**: Complete organization for Self-Registration & KYC features
2. **Models & Interfaces**: TypeScript interfaces for all data structures
3. **Services**: DocumentService and VerificationService with HTTP methods
4. **NGXS Store**: State management for documents with actions
5. **Route Guards**: VerificationGuard for access control
6. **Components**: 10+ components with TypeScript and HTML templates
7. **Responsive Design**: Mobile-friendly layouts with TailwindCSS
8. **File Upload**: Progress tracking and validation
9. **Admin Dashboard**: Verification queue and entity detail pages

The design ensures:
- **Modern Angular**: Standalone components with signals
- **Type Safety**: Strong typing with TypeScript interfaces
- **State Management**: Centralized state with NGXS
- **Responsive UI**: Mobile-first design with TailwindCSS
- **User Experience**: Loading states, error handling, progress tracking
- **Security**: Route guards and access control
- **Maintainability**: Clean separation of concerns

