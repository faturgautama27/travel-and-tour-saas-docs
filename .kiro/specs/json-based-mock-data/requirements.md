# Requirements Document

## Introduction

This document specifies the requirements for refactoring the mock data system in the tour-and-travel-frontend application. The current mock data system generates random data on-the-fly using factory classes, which leads to inconsistent data across different operations (create, read, update, delete). The new system will use JSON files as the single source of truth for all mock data, ensuring consistency and maintainability.

## Glossary

- **Mock_Service**: Angular service that implements API interfaces for development and testing purposes
- **JSON_Data_Source**: Static JSON files containing predefined mock data for entities
- **Mock_State_Service**: Centralized service managing in-memory state for mock data
- **Factory**: Class responsible for generating random mock data (current implementation)
- **CRUD_Operations**: Create, Read, Update, Delete operations on data entities
- **Entity**: A data model such as Package, Booking, Customer, Agency, etc.
- **Seed_Data**: Initial data loaded into the mock system at startup

## Requirements

### Requirement 1: JSON Data Source Structure

**User Story:** As a developer, I want mock data stored in JSON files, so that I can easily view, edit, and maintain consistent test data.

#### Acceptance Criteria

1. THE System SHALL store all mock data in JSON files located in a dedicated directory
2. WHEN the application starts, THE System SHALL load JSON data files into memory
3. THE System SHALL organize JSON files by entity type (packages, bookings, customers, etc.)
4. THE System SHALL validate JSON file structure on load to ensure data integrity
5. IF a JSON file is malformed or missing, THEN THE System SHALL log an error and use empty data for that entity

### Requirement 2: Mock Service Data Loading

**User Story:** As a developer, I want mock services to read from JSON files, so that all operations use the same consistent data source.

#### Acceptance Criteria

1. WHEN a Mock_Service initializes, THE System SHALL load data from the corresponding JSON_Data_Source
2. THE System SHALL replace factory-based random data generation with JSON-based data loading
3. WHEN no JSON data exists for an entity, THE System SHALL initialize with an empty collection
4. THE System SHALL maintain backward compatibility with existing Mock_Service interfaces
5. THE System SHALL load JSON data only once during application initialization

### Requirement 3: CRUD Operation Consistency

**User Story:** As a developer, I want all CRUD operations to work with the same data set, so that data remains consistent throughout the application lifecycle.

#### Acceptance Criteria

1. WHEN data is created, THE System SHALL add it to the in-memory state loaded from JSON
2. WHEN data is read, THE System SHALL retrieve it from the in-memory state
3. WHEN data is updated, THE System SHALL modify the in-memory state
4. WHEN data is deleted, THE System SHALL remove it from the in-memory state
5. THE System SHALL ensure all operations on the same entity type share the same data collection

### Requirement 4: Data Persistence Simulation

**User Story:** As a developer, I want changes to mock data to persist during a session, so that I can test workflows that span multiple operations.

#### Acceptance Criteria

1. WHEN mock data is modified during a session, THE System SHALL retain changes in memory
2. WHEN the application is refreshed, THE System SHALL reload original data from JSON files
3. THE System SHALL not write changes back to JSON files
4. THE System SHALL provide a way to reset data to the original JSON state without refreshing
5. THE System SHALL maintain data consistency across all Mock_Services during a session

### Requirement 5: JSON Data File Format

**User Story:** As a developer, I want JSON files to follow a consistent format, so that they are easy to understand and maintain.

#### Acceptance Criteria

1. THE System SHALL store each entity type in a separate JSON file
2. THE System SHALL use array format for collections of entities
3. THE System SHALL include all required fields for each entity as defined in the data models
4. THE System SHALL use consistent naming conventions matching TypeScript interfaces
5. THE System SHALL include realistic sample data that represents typical use cases

### Requirement 6: Migration from Factory-Based System

**User Story:** As a developer, I want to migrate existing factory-generated data to JSON files, so that I can preserve useful test scenarios.

#### Acceptance Criteria

1. THE System SHALL provide a way to generate JSON files from existing factories
2. THE System SHALL maintain the same data structure as factory-generated objects
3. THE System SHALL preserve relationships between entities (foreign keys, references)
4. THE System SHALL generate a reasonable number of sample records for each entity type
5. THE System SHALL allow manual editing of generated JSON files

### Requirement 7: Mock Service Refactoring

**User Story:** As a developer, I want mock services refactored to use JSON data, so that the codebase is cleaner and more maintainable.

#### Acceptance Criteria

1. THE System SHALL remove factory class instantiation from Mock_Services
2. THE System SHALL remove random data generation logic from Mock_Services
3. THE System SHALL simplify Mock_Service constructors to only load JSON data
4. THE System SHALL maintain all existing Mock_Service public methods and signatures
5. THE System SHALL preserve the same Observable-based API patterns

### Requirement 8: Data Loader Service

**User Story:** As a developer, I want a centralized data loader service, so that JSON loading logic is reusable and consistent.

#### Acceptance Criteria

1. THE System SHALL provide a Data_Loader_Service for loading JSON files
2. THE Data_Loader_Service SHALL handle file path resolution
3. THE Data_Loader_Service SHALL parse JSON content and return typed objects
4. THE Data_Loader_Service SHALL handle loading errors gracefully
5. THE Data_Loader_Service SHALL cache loaded data to avoid redundant file reads

### Requirement 9: Development Workflow Support

**User Story:** As a developer, I want to easily update mock data, so that I can test different scenarios without code changes.

#### Acceptance Criteria

1. WHEN JSON files are modified, THE System SHALL reflect changes after application refresh
2. THE System SHALL provide clear documentation on JSON file structure and location
3. THE System SHALL validate JSON data against TypeScript interfaces during development
4. THE System SHALL log warnings for missing or invalid data fields
5. THE System SHALL support adding new entities by creating new JSON files

### Requirement 10: Testing and Validation

**User Story:** As a developer, I want to validate that the JSON-based system works correctly, so that I can trust the mock data in development.

#### Acceptance Criteria

1. THE System SHALL provide unit tests for JSON data loading
2. THE System SHALL provide unit tests for CRUD operations with JSON-based data
3. THE System SHALL verify that all entity types load correctly from JSON
4. THE System SHALL verify that data relationships are maintained
5. THE System SHALL verify that Mock_Services return correct data types
