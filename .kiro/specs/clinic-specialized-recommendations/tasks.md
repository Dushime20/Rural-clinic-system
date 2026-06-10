# Implementation Plan: Clinic Specialized Recommendations

## Overview

This implementation plan breaks down the clinic specialized recommendations feature into discrete, actionable coding tasks. The feature extends the existing health companion system to provide intelligent clinic recommendations when pharmacy-based solutions are insufficient or when patients exhibit recurring/persistent disease patterns.

**Technology Stack:**
- Backend: Node.js + TypeScript + Express + TypeORM + PostgreSQL
- Admin Dashboard: React 18 + TypeScript + Vite
- Clinic Dashboard: React 18 + TypeScript + Vite (new application)
- Mobile App: Flutter 3.x + Dart

**Architecture Approach:**
- Non-disruptive integration with existing pharmacy recommendation flow
- Role-based access control with new "clinic" user type
- Geospatial search using Haversine formula (existing pattern)
- Graceful degradation for all clinic-related features

## Tasks

- [x] 1. Set up database schema and migrations
  - Create TypeORM entities for Clinic, ClinicSpecialty, DiseaseSpecialtyMapping, and AnalyticsEvent extension
  - Create database migrations for all new tables
  - Add indexes for geospatial queries (latitude, longitude)
  - Extend UserRole enum to include 'clinic' role
  - Create seed migration for disease-specialty mappings
  - _Requirements: 1.1, 1.4, 7.1, 8.1, 8.2, 23.4_

- [ ]* 1.1 Write property test for geographic coordinate validation
  - **Property 3: Geographic Coordinate Validation**
  - **Validates: Requirements 1.5**
  - Use fast-check to generate valid coordinates (lat: -90 to 90, lon: -180 to 180)
  - Test that valid coordinates are accepted and invalid coordinates are rejected

- [x] 2. Implement backend services for clinic management
  - [x] 2.1 Create ClinicService with CRUD operations
    - Implement createClinic method with credential generation
    - Implement updateClinic method with validation
    - Implement getClinicById and listClinics methods
    - Implement updateClinicStatus (activate/deactivate)
    - _Requirements: 1.3, 1.4, 1.6, 2.4_
  
  - [ ]* 2.2 Write property test for clinic creation completeness
    - **Property 1: Clinic Creation Completeness**
    - **Validates: Requirements 1.3, 1.4, 1.6, 2.8**
    - Test that valid clinic creation creates user, clinic, and returns credentials
  
  - [x] 2.3 Create ClinicSearchService for location-based queries
    - Implement searchByDisease method with specialty mapping lookup
    - Implement searchBySpecialties method
    - Implement Haversine distance calculation helper
    - Implement isClinicOpen method for operating hours validation
    - Apply 100km radius filter and distance-based sorting
    - Limit results to maximum 10 clinics
    - Add 5-second timeout protection
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 20.2, 24.7_
  
  - [ ]* 2.4 Write property test for clinic search distance calculation and filtering
    - **Property 10: Clinic Search Distance Calculation and Filtering**
    - **Validates: Requirements 12.4, 12.5, 12.6**
    - Test Haversine formula correctness
    - Test that only clinics within radius are returned
    - Test that results are sorted by distance ascending
  
  - [ ]* 2.5 Write property test for operating hours validation
    - **Property 12: Operating Hours Time Validation**
    - **Validates: Requirements 20.2**
    - Generate random times and operating hours
    - Test that isOpenAt correctly determines if clinic is open
  
  - [x] 2.6 Create DiagnosisHistoryService extensions for pattern detection
    - Implement detectRecurringDisease method (3+ occurrences in 90 days)
    - Implement detectPersistentDisease method (active > 30 days)
    - Implement matchesChronicCondition method with fuzzy matching (80% threshold)
    - Exclude resolved diagnoses from pattern detection
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 10.1, 10.2, 10.3, 10.4, 11.2, 11.4_
  
  - [ ]* 2.7 Write property test for recurring disease detection
    - **Property 7: Recurring Disease Detection**
    - **Validates: Requirements 9.2, 9.3, 9.4**
    - Generate diagnosis histories with varying occurrence counts
    - Test that 3+ occurrences within 90 days are flagged as recurring
  
  - [ ]* 2.8 Write property test for persistent disease detection
    - **Property 8: Persistent Disease Detection**
    - **Validates: Requirements 10.3, 10.4**
    - Generate diagnosis histories with varying active durations
    - Test that active diagnoses > 30 days are flagged as persistent
  
  - [ ]* 2.9 Write property test for chronic condition matching
    - **Property 9: Chronic Condition Matching**
    - **Validates: Requirements 11.4**
    - Generate disease names and chronic conditions with varying similarity
    - Test that matches at 80%+ similarity are flagged

- [x] 3. Extend recommendation engine for clinic recommendations
  - [x] 3.1 Update RecommendationEngine with clinic search integration
    - Add shouldRecommendClinics decision logic
    - Invoke ClinicSearchService based on pattern analysis
    - Invoke ClinicSearchService when no pharmacy found (fallback mode)
    - Implement graceful degradation on clinic search failures
    - Include both pharmacy and clinic recommendations in response
    - _Requirements: 11.7, 13.1, 13.2, 14.1, 14.2, 15.1, 15.2, 17.4, 24.1, 24.2_
  
  - [ ]* 3.2 Write property test for recommendation engine decision logic
    - **Property 11: Recommendation Engine Decision Logic**
    - **Validates: Requirements 13.1, 14.1, 15.1**
    - Test that recurring/persistent/chronic patterns trigger clinic search
    - Test that no pharmacies triggers clinic search fallback
  
  - [ ]* 3.3 Write property test for graceful degradation
    - **Property 13: Graceful Degradation on Clinic Search Failure**
    - **Validates: Requirements 24.2, 24.4, 24.7**
    - Simulate clinic search failures
    - Test that diagnosis workflow completes successfully

- [x] 4. Implement email service for clinic credentials
  - [x] 4.1 Create clinic credentials email template
    - Design HTML email template with clinic name, login URL, credentials
    - Include instructions for first-time password change
    - Include support contact information
    - _Requirements: 3.2, 3.3, 3.4, 3.7_
  
  - [x] 4.2 Extend EmailService with sendClinicCredentialsEmail method
    - Implement email sending using Nodemailer
    - Add error handling with graceful degradation (clinic creation succeeds even if email fails)
    - Log email send success/failure
    - _Requirements: 3.1, 3.5, 3.6_
  
  - [ ]* 4.3 Write property test for email failure resilience
    - **Property 14: Email Failure Resilience**
    - **Validates: Requirements 3.5**
    - Simulate email service failures
    - Test that clinic creation still succeeds and credentials are returned

- [x] 5. Checkpoint - Ensure all backend services tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Implement backend API endpoints for admin clinic management
  - [x] 6.1 Create AdminClinicController
    - POST /api/admin/clinics - Create clinic user with profile
    - GET /api/admin/clinics - List clinics with pagination, search, filters
    - GET /api/admin/clinics/:id - Get clinic details
    - PUT /api/admin/clinics/:id/status - Update clinic active status
    - Add request validation using express-validator
    - Add admin-only authorization middleware
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.7, 22.1, 22.2, 22.3, 22.4, 22.5, 22.7_
  
  - [ ]* 6.2 Write integration tests for admin clinic endpoints
    - Test clinic creation with valid/invalid data
    - Test authentication and authorization requirements
    - Test pagination and filtering

- [x] 7. Implement backend API endpoints for clinic user profile management
  - [x] 7.1 Create ClinicManagerController
    - GET /api/clinic-manager/my - Get authenticated clinic user's profile
    - POST /api/clinic-manager/register - First-time clinic profile setup
    - PUT /api/clinic-manager/my/profile - Update clinic profile
    - PUT /api/clinic-manager/my/specialties - Update clinic specialties
    - Add clinic-user-only authorization middleware
    - Validate specialty array (at least one specialty required)
    - _Requirements: 7.2, 7.3, 7.4, 7.7, 21.1, 21.2, 21.3, 21.4, 21.8_
  
  - [ ]* 7.2 Write property test for clinic specialty validation
    - **Property 5: Clinic Specialty Validation**
    - **Validates: Requirements 7.4, 7.7**
    - Test that valid specialties are accepted
    - Test that empty arrays and invalid specialties are rejected
  
  - [ ]* 7.3 Write integration tests for clinic manager endpoints
    - Test profile retrieval and updates
    - Test specialty management
    - Test authorization (clinic can only access own profile)

- [x] 8. Implement backend API endpoints for clinic search
  - [x] 8.1 Create ClinicsController for public/internal search
    - POST /api/clinics/search - Search clinics by disease and location
    - GET /api/disease-mappings/search - Get specialties for disease
    - Add authenticated user authorization
    - Support optional location parameters (graceful handling when missing)
    - _Requirements: 12.1, 12.9, 18.1, 18.2, 18.3, 18.4, 18.7_
  
  - [ ]* 8.2 Write integration tests for clinic search endpoints
    - Test search with and without location
    - Test disease-specialty mapping queries
    - Test timeout and error handling

- [x] 9. Implement backend API endpoints for disease-specialty mapping management
  - [x] 9.1 Create AdminDiseaseMappingController
    - GET /api/admin/disease-mappings - List all mappings
    - POST /api/admin/disease-mappings - Create new mapping
    - PUT /api/admin/disease-mappings/:id - Update mapping
    - Add admin-only authorization middleware
    - _Requirements: 8.7_
  
  - [ ]* 9.2 Write property test for disease-specialty mapping query
    - **Property 6: Disease-Specialty Mapping Query**
    - **Validates: Requirements 8.5, 8.6**
    - Test that mapped diseases return correct specialties
    - Test that unmapped diseases default to General_Medicine
  
  - [ ]* 9.3 Write integration tests for disease mapping endpoints
    - Test mapping CRUD operations
    - Test admin authorization

- [x] 10. Extend authentication system for clinic users
  - [x] 10.1 Update UserController and AuthService
    - Support clinic user login with temporary credentials
    - Include mustChangePassword flag in auth response
    - Implement password change endpoint (POST /api/auth/change-password)
    - Validate current password before allowing change
    - Set mustChangePassword to false after successful change
    - Implement forgot password flow for clinic users
    - _Requirements: 1.7, 4.1, 4.2, 4.3, 4.6, 4.7, 5.2, 5.3, 5.4, 5.5, 5.7_
  
  - [ ]* 10.2 Write property test for clinic user authentication
    - **Property 2: Clinic User Authentication**
    - **Validates: Requirements 1.7, 4.2**
    - Test authentication with valid temporary/permanent credentials
    - Test authentication failure with invalid credentials
  
  - [ ]* 10.3 Write property test for password security requirements
    - **Property 4: Password Security Requirements**
    - **Validates: Requirements 4.6, 4.7, 5.5**
    - Generate passwords meeting/failing requirements
    - Test that valid passwords are accepted and mustChangePassword is updated
    - Test that invalid passwords are rejected
  
  - [ ]* 10.4 Write integration tests for authentication endpoints
    - Test clinic login flow with temporary password
    - Test password change flow
    - Test forgot password flow

- [x] 11. Extend diagnosis endpoint to include clinic recommendations
  - [x] 11.1 Update DiagnosisController POST /api/diagnosis/analyze
    - Call pattern detection services before recommendation engine
    - Include patternAnalysis in response
    - Include clinics array in recommendations when applicable
    - Include clinicRecommendationReason string
    - Ensure backward compatibility (fields undefined when not applicable)
    - _Requirements: 13.3, 14.3, 15.3, 17.4, 26.4_
  
  - [ ]* 11.2 Write property test for conditional response structure
    - **Property 15: Conditional Response Structure**
    - **Validates: Requirements 26.4**
    - Test that clinic fields are only present when recommendations are generated
    - Test backward compatibility
  
  - [ ]* 11.3 Write integration tests for extended diagnosis endpoint
    - Test response structure with and without clinic recommendations
    - Test all recommendation triggers (no pharmacy, recurring, persistent, chronic)

- [x] 12. Implement analytics logging for clinic recommendations
  - [x] 12.1 Create AnalyticsService extension
    - Implement logClinicRecommendation method
    - Store event type, reason, clinic count, diagnosis ID, patient ID
    - Log asynchronously to avoid blocking diagnosis flow
    - _Requirements: 11.7, 13.7, 14.7, 15.7, 23.1, 23.2, 23.3, 23.4, 23.5_
  
  - [x] 12.2 Add analytics endpoints for admin dashboard
    - GET /api/admin/analytics/clinic-recommendations - Get recommendation statistics
    - Support filtering by date range and reason
    - _Requirements: 23.5, 23.6_
  
  - [ ]* 12.3 Write integration tests for analytics
    - Test analytics event logging
    - Test analytics query endpoints

- [x] 13. Checkpoint - Ensure all backend API tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 14. Create admin dashboard clinics page
  - [x] 14.1 Create Clinics page component structure
    - Create src/pages/Clinics.tsx with main layout
    - Add "Clinics" navigation item to admin sidebar
    - Create ClinicsHeader component with title and "Create Clinic" button
    - Create ClinicsSearchBar component with search and filter inputs
    - _Requirements: 2.1, 2.2, 22.1_
  
  - [x] 14.2 Create ClinicsTable component
    - Display clinic list with columns: name, manager, email, phone, city, specialties, status
    - Add sorting by name, city, created date
    - Add filtering by specialty, active status
    - Integrate Pagination component (existing pattern)
    - Add row click to view clinic details
    - _Requirements: 22.2, 22.3, 22.7_
  
  - [x] 14.3 Create CreateClinicModal component
    - Create multi-step form with validation (react-hook-form + zod)
    - Step 1: Basic info (name, manager name, email, phone)
    - Step 2: Location (address, city, district, country, lat, lon)
    - Step 3: Specialties (multi-select checkboxes)
    - Step 4: Operating hours (optional)
    - Add form validation matching backend rules
    - Display success message with generated credentials
    - Provide option to copy credentials to clipboard
    - _Requirements: 2.3, 2.4, 2.5, 2.6, 2.7, 2.8_
  
  - [x] 14.4 Create ClinicDetailsModal component
    - Display full clinic information in read-only view
    - Show all profile fields, specialties as badges, operating hours
    - Add "Activate/Deactivate" button
    - _Requirements: 22.4, 22.5, 22.6_
  
  - [ ]* 14.5 Write unit tests for clinic page components
    - Test form validation
    - Test table rendering and sorting
    - Test modal interactions

- [x] 15. Set up clinic dashboard React application
  - [x] 15.1 Create new React application in clinic_dashboard/ directory
    - Initialize Vite + React + TypeScript project
    - Set up folder structure matching admin dashboard pattern
    - Install dependencies: react-router-dom, tanstack-query, axios, zod
    - Create .env.example with VITE_API_BASE_URL
    - Configure blue/indigo theme colors
    - _Requirements: 6.3, 6.6_
  
  - [x] 15.2 Create ClinicAuthContext
    - Implement clinic-specific authentication context
    - Handle JWT token storage and refresh
    - Detect mustChangePassword flag
    - Provide logout functionality
    - _Requirements: 4.3, 4.4_
  
  - [x] 15.3 Create clinic API client (lib/api.ts)
    - Configure axios with base URL and auth interceptors
    - Create API methods for clinic endpoints
    - Handle token refresh on 401 errors
    - _Requirements: 21.4_

- [x] 16. Implement clinic dashboard authentication pages
  - [x] 16.1 Create ClinicLogin page
    - Email and password input fields
    - Form validation
    - Call POST /api/auth/login with clinic credentials
    - Store auth token on success
    - Redirect to password change if mustChangePassword is true
    - Redirect to dashboard otherwise
    - _Requirements: 4.1, 4.2_
  
  - [x] 16.2 Create ClinicChangePassword page
    - Current password, new password, confirm password inputs
    - Password strength indicator
    - Form validation (min 8 characters)
    - Call POST /api/auth/change-password
    - Redirect to dashboard on success
    - _Requirements: 4.5, 4.6, 4.7, 5.1, 5.2, 5.3, 5.4, 5.5_
  
  - [ ]* 16.3 Write integration tests for authentication pages
    - Test login flow with temporary password
    - Test password change flow
    - Test validation errors

- [x] 17. Create clinic dashboard home page
  - [x] 17.1 Create ClinicDashboard page component
    - Display clinic name, address, active status at top
    - Show summary statistics (total specialties, total recommendations, days since registration)
    - Add navigation cards to Profile, Specialties, Recommendations, Change Password
    - Display recent recommendation requests table
    - Show "Complete Your Profile" notice if specialties or operating hours missing
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.7_
  
  - [ ]* 17.2 Write unit tests for dashboard page
    - Test data fetching and display
    - Test navigation links
    - Test incomplete profile notice

- [x] 18. Create clinic profile management page
  - [x] 18.1 Create ClinicProfile page component
    - Fetch clinic profile on load (GET /api/clinic-manager/my)
    - Display editable form with all profile fields
    - Validate latitude (-90 to 90) and longitude (-180 to 180)
    - Call PUT /api/clinic-manager/my/profile on submit
    - Show success/error toast notifications
    - _Requirements: 21.1, 21.2, 21.5, 21.6_
  
  - [ ]* 18.2 Write integration tests for profile page
    - Test profile data loading
    - Test profile update with valid/invalid data

- [x] 19. Create clinic specialties management page
  - [x] 19.1 Create ClinicSpecialties page component
    - Display current specialties as badges
    - Provide multi-select checkboxes for all specialties
    - Validate at least one specialty is selected
    - Call PUT /api/clinic-manager/my/specialties on submit
    - Show confirmation message on success
    - _Requirements: 21.3, 21.4, 21.8_
  
  - [ ]* 19.2 Write integration tests for specialties page
    - Test specialty selection and update
    - Test validation (at least one required)

- [x] 20. Checkpoint - Ensure all admin and clinic dashboard features work end-to-end
  - Ensure all tests pass, ask the user if questions arise.

- [x] 21. Create Flutter models for clinic recommendations
  - [x] 21.1 Create ClinicRecommendation model
    - Define model with id, name, specialties, phoneNumber, address, city, district, latitude, longitude, distance, isOpenNow, openingHours, reason
    - Implement fromJson and toJson methods
    - Add computed properties: fullAddress, distanceText
    - _Requirements: 16.2, 16.8_
  
  - [x] 21.2 Create PatternAnalysis model
    - Define model with isRecurring, isPersistent, matchesChronicCondition, occurrenceCount, durationDays
    - Implement fromJson method
    - Add computed properties: hasPattern, patternDescription
    - _Requirements: 14.5, 15.5_
  
  - [x] 21.3 Extend DiagnosisResult model
    - Add optional clinics array to Recommendations
    - Add optional clinicRecommendationReason string
    - Add optional patternAnalysis object
    - Ensure backward compatibility with existing code
    - _Requirements: 13.3, 14.3, 15.3, 17.4, 26.4_
  
  - [ ]* 21.4 Write unit tests for models
    - Test JSON serialization/deserialization
    - Test computed properties

- [x] 22. Create clinic recommendation UI components
  - [x] 22.1 Create ClinicRecommendationCard widget
    - Display clinic name, specialties as chips, address, distance
    - Show reason badge (Recurring, Persistent, Chronic, Specialist Care)
    - Display "Call" and "Navigate" action buttons
    - Implement phone call functionality (url_launcher package)
    - Implement map navigation (url_launcher with maps URL)
    - Add tap to show clinic details in bottom sheet
    - Use blue color scheme to differentiate from pharmacy cards (orange)
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.7, 16.8_
  
  - [x] 22.2 Create PatternAnalysisNotice widget
    - Display notice banner explaining why clinics are recommended
    - Show occurrence count or duration based on pattern type
    - Use color-coded design (orange for recurring, amber for persistent, red for chronic)
    - _Requirements: 11.6, 14.4, 14.5, 15.4, 15.5_
  
  - [ ]* 22.3 Write widget tests for clinic components
    - Test ClinicRecommendationCard rendering
    - Test PatternAnalysisNotice display
    - Test action button interactions

- [x] 23. Update DiagnosisResultPage to display clinic recommendations
  - [x] 23.1 Extend DiagnosisResultPage widget
    - Add conditional rendering for PatternAnalysisNotice
    - Add "Specialized Clinic Recommendations" section with header
    - Display recommendation explanation based on reason
    - Map clinic recommendations to ClinicRecommendationCard widgets
    - Ensure clinic recommendations appear before pharmacy recommendations when prioritized
    - Maintain existing pharmacy recommendation display
    - Handle cases: clinics only, pharmacies only, both, neither
    - _Requirements: 13.4, 13.5, 13.6, 14.2, 14.4, 14.6, 15.2, 15.4, 15.6, 16.6, 17.1, 17.2, 17.3, 17.7_
  
  - [ ]* 23.2 Write integration tests for DiagnosisResultPage
    - Test page rendering with clinic recommendations
    - Test page rendering with pharmacy recommendations only
    - Test page rendering with both recommendation types
    - Test pattern analysis notice display

- [x] 24. Handle location permissions for clinic search
  - [x] 24.1 Update location permission handling in Flutter app
    - Check location permissions before clinic search
    - Display permission request dialog with explanation
    - Handle denied permissions gracefully (show clinics without distance)
    - Handle disabled location services (prompt to enable)
    - Implement retry mechanism with 10-second timeout
    - Use last known location as fallback
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5, 18.6_
  
  - [ ]* 24.2 Write integration tests for location handling
    - Test permission request flow
    - Test graceful degradation without location

- [x] 25. Implement clinic search filtering in Flutter
  - [x] 25.1 Add specialty filter to clinic recommendations section
    - Create specialty filter dropdown widget
    - Display clinic count per specialty
    - Support multi-select filtering
    - Filter displayed clinics based on selected specialties
    - Add "Clear Filters" button
    - Persist filter during session, reset on navigation
    - _Requirements: 25.1, 25.2, 25.3, 25.4, 25.5, 25.6, 25.7_
  
  - [ ]* 25.2 Write widget tests for filter functionality
    - Test filter selection
    - Test clinic filtering logic

- [x] 26. Support clinic recommendations for historical diagnoses
  - [x] 26.1 Update historical diagnosis view
    - Re-evaluate pattern detection when viewing historical diagnosis
    - Perform real-time clinic search using current location
    - Display clinic recommendations on historical diagnosis result page
    - Cache clinic search results for 10 minutes
    - Indicate when recommendations are based on current vs. historical location
    - _Requirements: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6_
  
  - [ ]* 26.2 Write integration tests for historical diagnosis clinic search
    - Test clinic recommendations on historical diagnoses
    - Test caching behavior

- [ ] 27. Checkpoint - Ensure all Flutter UI features work end-to-end
  - Ensure all tests pass, ask the user if questions arise.

- [x] 28. Add error handling and graceful degradation
  - [x] 28.1 Implement backend error handling
    - Add try-catch blocks around clinic search with timeout
    - Fall back to General_Medicine on mapping query failure
    - Log errors but don't fail diagnosis workflow
    - Return empty clinic array on service failures
    - _Requirements: 24.1, 24.2, 24.3, 24.4, 24.7_
  
  - [x] 28.2 Implement Flutter error handling
    - Display "Clinic recommendations temporarily unavailable" message on errors
    - Provide "Retry" button for clinic search
    - Handle location service errors gracefully
    - Log errors to analytics
    - _Requirements: 18.5, 18.6, 24.5, 24.6_
  
  - [ ]* 28.3 Write integration tests for error scenarios
    - Test clinic search timeout
    - Test database connection failures
    - Test location service errors

- [ ] 29. Add rate limiting and security measures
  - [x] 29.1 Implement rate limiting
    - Add rate limiter for clinic search API (100 req/min per IP)
    - Add rate limiter for admin clinic creation (10 req/min per admin)
    - Add rate limiter for authentication (5 failed attempts per 15 min)
    - _Requirements: Security considerations from design_
  
  - [x] 29.2 Add input validation and sanitization
    - Validate all user inputs at API level
    - Sanitize location coordinates
    - Validate specialty enums
    - Protect against SQL injection (TypeORM parameterized queries)
    - _Requirements: Security considerations from design_
  
  - [ ]* 29.3 Write security tests
    - Test rate limiting enforcement
    - Test input validation edge cases

- [ ] 30. Implement analytics and monitoring
  - [ ] 30.1 Add structured logging
    - Log clinic creation events
    - Log clinic search operations with latency
    - Log pattern detection results
    - Log email send success/failure
    - Use JSON format with correlation IDs
    - _Requirements: 23.1, 23.2, 23.3, 23.7_
  
  - [ ] 30.2 Add performance monitoring
    - Track clinic search latency
    - Track pattern detection overhead
    - Alert on search latency > 2 seconds
    - _Requirements: Performance considerations from design_

- [x] 31. Ensure backward compatibility
  - [x] 31.1 Verify existing endpoints unchanged
    - Run existing pharmacy tests to ensure no regressions
    - Verify diagnosis response structure is backward compatible
    - Test with clients not expecting clinic fields
    - _Requirements: 26.1, 26.2, 26.3, 26.4, 26.5, 26.6, 26.7_
  
  - [ ]* 31.2 Write backward compatibility tests
    - Test that existing pharmacy flow works unchanged
    - Test that diagnosis response with clinics is backward compatible

- [ ] 32. Final integration and end-to-end testing
  - [ ] 32.1 Test admin creates clinic user flow
    - Admin logs in → navigates to Clinics page → creates clinic user → sees credentials → email sent
    - _Requirements: End-to-end flow from design_
  
  - [ ] 32.2 Test clinic user first login flow
    - Clinic receives email → logs in with temporary password → changes password → sees dashboard
    - _Requirements: End-to-end flow from design_
  
  - [ ] 32.3 Test patient receives clinic recommendations flow
    - Patient completes diagnosis → recurring pattern detected → clinic recommendations displayed → patient interacts with clinic card
    - _Requirements: End-to-end flow from design_
  
  - [ ] 32.4 Test no pharmacy fallback flow
    - Patient completes diagnosis → no pharmacies found → clinic recommendations provided as fallback
    - _Requirements: End-to-end flow from design_

- [x] 33. Documentation and deployment preparation
  - [x] 33.1 Update API documentation
    - Document all new endpoints in Swagger/OpenAPI spec
    - Add request/response examples
    - Document authentication requirements
    - _Requirements: Documentation from design_
  
  - [x] 33.2 Create user guides
    - Admin guide: Creating and managing clinic users
    - Clinic user guide: Using the clinic dashboard
    - Update patient guide with clinic recommendation information
  
  - [x] 33.3 Prepare deployment checklist
    - Environment variables configuration
    - Database migration steps
    - Seed data execution (disease-specialty mappings)
    - Email service configuration
    - Monitoring setup

- [ ] 34. Final checkpoint - Complete feature verification
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property-based tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- Integration tests validate API contracts and database operations
- End-to-end tests validate complete user flows
- Checkpoints ensure incremental validation and provide opportunities for feedback
- Implementation follows existing patterns (pharmacy user creation, geospatial search)
- Graceful degradation ensures the system remains functional even when clinic features fail
- Backward compatibility is maintained throughout - existing features are not disrupted
