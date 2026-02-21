# Implementation Plan: JSON-Based Mock Data System

## Overview

This implementation plan refactors the existing factory-based mock data system to use JSON files as the single source of truth. The work is organized into phases: creating the JSON data infrastructure, migrating mock services, and ensuring comprehensive testing. Each task builds incrementally to maintain a working system throughout the refactoring.

## Tasks

- [ ] 1. Create JSON data infrastructure
  - [x] 1.1 Create mock data directory structure
    - Create `src/assets/mock-data/` directory for JSON files
    - Set up proper Angular asset configuration in `angular.json`
    - _Requirements: 1.1, 5.1_
  
  - [x] 1.2 Implement JsonDataLoaderService
    - Create `json-data-loader.service.ts` in `src/app/core/mock/services/`
    - Implement `loadData<T>(entityType: string): Observable<T[]>` method using HttpClient
    - Implement `loadAllData(): Observable<Map<string, any[]>>` method
    - Implement caching mechanism to avoid redundant file reads
    - Implement error handling for missing/malformed JSON files
    - Add date string to Date object conversion during parsing
    - _Requirements: 8.1, 8.2, 8.3, 8.4_
  
  - [ ]* 1.3 Write property test for JsonDataLoaderService caching
    - **Property 12: Data Caching Behavior**
    - **Validates: Requirements 2.5, 8.4**
  
  - [ ]* 1.4 Write unit tests for JsonDataLoaderService
    - Test loading valid JSON files
    - Test handling missing files (should return empty array)
    - Test handling malformed JSON (should return empty array and log error)
    - Test date parsing from ISO strings
    - _Requirements: 8.2, 8.3_

- [ ] 2. Generate initial JSON data files
  - [x] 2.1 Create data generation script
    - Create `scripts/generate-mock-data.ts` utility script
    - Import all existing factory classes
    - Generate sample data for each entity type using factories
    - Convert Date objects to ISO string format
    - Write formatted JSON to `src/assets/mock-data/` directory
    - _Requirements: 6.1, 6.2, 6.4_
  
  - [x] 2.2 Generate JSON files for all entity types
    - Run script to generate: packages.json (20 records)
    - Generate: bookings.json (30 records)
    - Generate: customers.json (25 records)
    - Generate: agencies.json (10 records)
    - Generate: suppliers.json (15 records)
    - Generate: services.json (40 records)
    - Generate: purchase-orders.json (20 records)
    - Generate: journeys.json (15 records)
    - Generate: subscription-plans.json (5 records)
    - Generate: commissions.json (10 records)
    - Generate: revenues.json (20 records)
    - Generate: available-services.json (10 records)
    - _Requirements: 5.1, 5.2, 5.5, 6.1_
  
  - [x] 2.3 Validate generated JSON files
    - Verify all files are valid JSON
    - Verify all required fields are present
    - Verify foreign key references are valid
    - Verify date formats are ISO 8601
    - _Requirements: 5.3, 6.3_
  
  - [ ]* 2.4 Write property test for referential integrity
    - **Property 9: Referential Integrity**
    - **Validates: Requirements 6.3, 10.4**

- [ ] 3. Checkpoint - Verify JSON infrastructure
  - Ensure JsonDataLoaderService loads all JSON files successfully
  - Ensure all JSON files are valid and contain expected data
  - Ask the user if questions arise

- [-] 4. Refactor PackageMockService (pilot migration)
  - [ ] 4.1 Refactor PackageMockService to use JSON data
    - Inject JsonDataLoaderService into constructor
    - Replace factory instantiation with JSON loading
    - Remove `seedData()` method that uses factory
    - Implement `loadData()` method that loads from JSON
    - Keep all existing public methods unchanged
    - Ensure Observable-based API patterns are preserved
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ]* 4.2 Write property test for CRUD operations consistency
    - **Property 3: CRUD Operations Consistency**
    - **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**
  
  - [ ]* 4.3 Write property test for API interface compatibility
    - **Property 10: API Interface Compatibility**
    - **Validates: Requirements 2.4, 7.4, 7.5**
  
  - [ ]* 4.4 Write unit tests for PackageMockService
    - Test getAll() returns data from JSON
    - Test getById() retrieves correct package
    - Test create() adds new package to state
    - Test update() modifies existing package
    - Test publish() changes package status
    - _Requirements: 3.1, 3.2, 3.3_

- [x] 5. Refactor remaining mock services
  - [x] 5.1 Refactor BookingMockService
    - Apply same refactoring pattern as PackageMockService
    - Replace factory with JSON loading
    - Maintain all existing methods and signatures
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.2 Refactor CustomerMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.3 Refactor AgencyMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.4 Refactor SupplierMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.5 Refactor ServiceMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.6 Refactor PurchaseOrderMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.7 Refactor JourneyMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.8 Refactor SubscriptionPlanMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.9 Refactor CommissionMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [x] 5.10 Refactor RevenueMockService
    - Apply same refactoring pattern
    - _Requirements: 2.1, 2.2, 7.1, 7.2, 7.3, 7.4, 7.5_
  
  - [ ]* 5.11 Write property test for JSON data initialization
    - **Property 1: JSON Data Initialization**
    - **Validates: Requirements 1.2, 2.1**
  
  - [ ]* 5.12 Write property test for session state persistence
    - **Property 4: Session State Persistence**
    - **Validates: Requirements 4.1, 4.5**

- [ ] 6. Checkpoint - Verify all services migrated
  - Ensure all mock services load data from JSON
  - Ensure no factory classes are instantiated in services
  - Ensure all existing functionality works correctly
  - Ask the user if questions arise

- [ ] 7. Implement data reset functionality
  - [ ] 7.1 Add reset methods to JsonDataLoaderService
    - Implement `resetData(entityType: string): Observable<void>` method
    - Implement `resetAllData(): Observable<void>` method
    - Clear cached data and reload from JSON files
    - Update MockStateService with fresh data
    - _Requirements: 4.4_
  
  - [ ]* 7.2 Write property test for data reset functionality
    - **Property 6: Data Reset Functionality**
    - **Validates: Requirements 4.4**
  
  - [ ]* 7.3 Write unit tests for reset functionality
    - Test resetData() reloads original JSON data
    - Test resetAllData() reloads all entity types
    - Test reset clears in-memory modifications
    - _Requirements: 4.4_

- [ ] 8. Implement validation and error handling
  - [ ] 8.1 Add JSON structure validation
    - Validate that loaded data is an array
    - Validate that each entity has required fields
    - Log warnings for missing or invalid fields
    - Use default values for invalid fields where possible
    - _Requirements: 1.4, 5.3, 9.4_
  
  - [ ] 8.2 Enhance error handling
    - Add specific error messages for different failure types
    - Implement retry logic for network errors
    - Ensure graceful degradation (empty data on error)
    - Add comprehensive error logging
    - _Requirements: 1.5, 2.3, 8.3_
  
  - [ ]* 8.3 Write property test for JSON structure validation
    - **Property 2: JSON Structure Validation**
    - **Validates: Requirements 1.4, 1.5**
  
  - [ ]* 8.4 Write property test for graceful error handling
    - **Property 11: Graceful Error Handling**
    - **Validates: Requirements 8.3**
  
  - [ ]* 8.5 Write property test for invalid data logging
    - **Property 13: Invalid Data Logging**
    - **Validates: Requirements 9.4**
  
  - [ ]* 8.6 Write unit tests for validation
    - Test validation catches missing required fields
    - Test validation handles invalid data types
    - Test validation logs appropriate warnings
    - _Requirements: 5.3, 9.4_

- [ ] 9. Add comprehensive property-based tests
  - [ ]* 9.1 Write property test for JSON file immutability
    - **Property 5: JSON File Immutability**
    - **Validates: Requirements 4.3**
  
  - [ ]* 9.2 Write property test for required fields completeness
    - **Property 7: Required Fields Completeness**
    - **Validates: Requirements 5.3**
  
  - [ ]* 9.3 Write property test for factory-JSON structure compatibility
    - **Property 8: Factory-JSON Structure Compatibility**
    - **Validates: Requirements 6.2**

- [ ]* 10. Documentation and cleanup
  - [ ]* 10.1 Create README for mock data system
    - Document JSON file location and structure
    - Document how to add new entity types
    - Document how to modify existing data
    - Document error handling behavior
    - Provide examples of JSON file format for each entity
    - _Requirements: 9.2_
  
  - [ ]* 10.2 Mark factory classes as deprecated
    - Add @deprecated JSDoc comments to all factory classes
    - Add comments explaining they're kept for reference only
    - Update factory index.ts with deprecation notice
    - _Requirements: 6.1_
  
  - [ ]* 10.3 Update mock system README
    - Document the new JSON-based architecture
    - Update diagrams to show JSON data flow
    - Document migration from factory-based system
    - _Requirements: 9.2_

- [ ] 11. Final checkpoint - Complete system verification
  - Run all unit tests and property-based tests
  - Verify all 12 mock services work correctly
  - Verify data consistency across all operations
  - Verify error handling works as expected
  - Test application with JSON-based mock data
  - Ensure all tests pass, ask the user if questions arise

## Notes

- Tasks marked with `*` are optional property-based and unit tests that can be skipped for faster MVP
- Each refactored service should follow the same pattern established in PackageMockService
- Factory classes are kept in the codebase but marked as deprecated for reference
- JSON files should be manually reviewed and edited after generation to ensure realistic data
- All property tests should run with minimum 100 iterations
- The refactoring maintains backward compatibility - no changes to service interfaces
