# MinIO Directory Migration - Photo Profile & Supplier Service Images

**Date:** March 30, 2026  
**Status:** ✅ Completed  
**Build Status:** ✅ 0 Errors

---

## Summary

Migrated all photo profile and supplier service images from separate buckets to a unified `tour-travel-documents` bucket with organized subdirectories:

- **Old:** `user-profile-photos` bucket → **New:** `tour-travel-documents/photo-profile/`
- **Old:** `supplier-service-images` bucket → **New:** `tour-travel-documents/supplier-service-images/`

---

## Changes Made

### Backend Files Updated

#### 1. User Profile Photo Commands
- `UploadProfilePhotoCommandHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{objectKey}` → `photo-profile/{objectKey}`

- `DeleteProfilePhotoCommandHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{profilePhotoKey}` → `photo-profile/{profilePhotoKey}`

- `UpdateUserCommandHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{profilePhotoKey}` → `photo-profile/{profilePhotoKey}`

- `CreateUserCommandHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{profilePhotoKey}` → `photo-profile/{profilePhotoKey}`

- `UpdateProfileCommandHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{profilePhotoKey}` → `photo-profile/{profilePhotoKey}`

#### 2. User Profile Photo Queries
- `GetProfileQueryHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{profilePhotoKey}` → `photo-profile/{profilePhotoKey}`

- `GetUsersQueryHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{profilePhotoKey}` → `photo-profile/{profilePhotoKey}`

- `GetUserByIdQueryHandler.cs`
  - Bucket: `user-profile-photos` → `tour-travel-documents`
  - Path: `{profilePhotoKey}` → `photo-profile/{profilePhotoKey}`

#### 3. Supplier Service Image Commands
- `UploadSupplierServiceImageCommandHandler.cs`
  - Bucket: `supplier-service-images` → `tour-travel-documents`
  - Path: `services/{serviceId}/{fileName}` → `supplier-service-images/services/{serviceId}/{fileName}`
  - Added `FolderPath` constant for maintainability

- `DeleteSupplierServiceImageCommandHandler.cs`
  - Bucket: `supplier-service-images` → `tour-travel-documents`
  - Added `FolderPath` constant for maintainability

#### 4. Tests
- `UploadSupplierServiceImageCommandHandlerTests.cs`
  - Updated mock verification to use `tour-travel-documents` bucket

#### 5. Program.cs (Initialization)
- Removed separate bucket initialization for `user-profile-photos` and `supplier-service-images`
- Added single bucket initialization for `tour-travel-documents`

---

## New Directory Structure

```
tour-travel-documents/
├── photo-profile/
│   ├── {userId}/
│   │   └── {filename}.jpg
│   └── ...
├── supplier-service-images/
│   ├── services/
│   │   ├── {serviceId}/
│   │   │   ├── {imageId}.jpg
│   │   │   └── ...
│   │   └── ...
│   └── ...
├── kyc/
│   ├── agencies/
│   ├── suppliers/
│   └── pending/
└── public-documents/
    ├── terms/
    ├── policies/
    └── guides/
```

---

## Migration Steps (For Production)

### Step 1: Backup Existing Data

```bash
# Backup user-profile-photos bucket
mc mirror local/user-profile-photos /backup/user-profile-photos

# Backup supplier-service-images bucket
mc mirror local/supplier-service-images /backup/supplier-service-images
```

### Step 2: Create New Bucket Structure

```bash
# Create tour-travel-documents bucket (if not exists)
mc mb local/tour-travel-documents

# Create subdirectories
mc cp --recursive /dev/null local/tour-travel-documents/photo-profile/
mc cp --recursive /dev/null local/tour-travel-documents/supplier-service-images/
```

### Step 3: Migrate Existing Files

```bash
# Migrate user profile photos
mc mirror local/user-profile-photos local/tour-travel-documents/photo-profile/

# Migrate supplier service images
mc mirror local/supplier-service-images local/tour-travel-documents/supplier-service-images/
```

### Step 4: Update Database Records

If you have database records storing the old bucket names, update them:

```sql
-- Update any stored references (if applicable)
-- This depends on your database schema
```

### Step 5: Deploy Backend Code

```bash
# Build and deploy the updated backend
dotnet build
dotnet publish -c Release
```

### Step 6: Verify Migration

```bash
# Test presigned URL generation
curl -I "https://miniodev.jourva.com/tour-travel-documents/photo-profile/{userId}/{filename}.jpg?X-Amz-Algorithm=..."

# Should return 200 OK (file served)
```

### Step 7: Cleanup Old Buckets (Optional)

```bash
# After verification, remove old buckets
mc rb local/user-profile-photos
mc rb local/supplier-service-images
```

---

## Nginx Configuration Update

Update your Nginx config to serve from the new bucket:

```nginx
# /etc/nginx/sites-available/minio-api
upstream minio_api {
    server 127.0.0.1:9000;
}

server {
    listen 80;
    server_name miniodev.jourva.com;

    client_max_body_size 100M;

    location / {
        proxy_pass http://minio_api;
        proxy_http_version 1.1;
        
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_set_header Connection "";
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
```

---

## MinIO Bucket Policy (Optional)

Set custom permissions for the new bucket:

```bash
# Create policy for photo-profile folder (read-only for users)
cat > /tmp/photo-profile-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["*"]},
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::tour-travel-documents/photo-profile/*"]
    }
  ]
}
EOF

# Create policy for supplier-service-images (read-only for users)
cat > /tmp/supplier-images-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": ["*"]},
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::tour-travel-documents/supplier-service-images/*"]
    }
  ]
}
EOF

# Apply policies
mc anonymous set-json /tmp/photo-profile-policy.json local/tour-travel-documents
mc anonymous set-json /tmp/supplier-images-policy.json local/tour-travel-documents
```

---

## Verification Checklist

- [x] Backend builds successfully (0 errors)
- [x] All bucket references updated
- [x] All path references updated
- [x] Program.cs initialization updated
- [x] Tests updated
- [ ] Database migration (if needed)
- [ ] Production deployment
- [ ] Presigned URLs tested
- [ ] Old buckets backed up
- [ ] Old buckets removed (optional)

---

## Rollback Plan

If issues occur:

```bash
# Restore from backup
mc mirror /backup/user-profile-photos local/user-profile-photos
mc mirror /backup/supplier-service-images local/supplier-service-images

# Revert backend code to previous version
git revert <commit-hash>
dotnet build && dotnet publish
```

---

## Benefits

✅ **Unified Storage:** All documents in one bucket  
✅ **Better Organization:** Clear folder structure  
✅ **Easier Permissions:** Single bucket policy management  
✅ **Scalability:** Easy to add more document types  
✅ **Maintainability:** Consistent naming conventions  
✅ **Cost Efficient:** Reduced bucket overhead  

---

## References

- MinIO Documentation: https://min.io/docs/minio/linux/index.html
- MinIO Client Guide: https://min.io/docs/minio/linux/reference/minio-mc.html
- S3 Bucket Policies: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-policies.html

---

**Document Version:** 1.0  
**Last Updated:** March 30, 2026  
**Status:** ✅ Ready for Production
