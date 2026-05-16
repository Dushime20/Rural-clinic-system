# Requirements Document

## Introduction

This feature adds pharmacy recommendations to the patient medical history diagnosis details page. Currently, when viewing historical diagnoses from the Patient Medical History page, pharmacy recommendations are not shown, even though they are displayed when viewing fresh diagnosis results. This creates an inconsistent user experience and limits the utility of historical diagnosis data.

The solution involves replacing mock data with real diagnosis data from the backend, performing real-time pharmacy searches when viewing historical diagnoses, and displaying pharmacy recommendations with the same UI that already exists in the DiagnosisResultPage.

## Glossary

- **Patient_Medical_History_Page**: The Flutter page that displays a patient's historical diagnoses in a timeline format
- **Diagnosis_Result_Page**: The Flutter page that displays diagnosis details including AI predictions, prescriptions, and pharmacy recommendations
- **Diagnosis_Service**: The backend service that retrieves diagnosis records from the database
- **Pharmacy_Search_Service**: The service that searches for nearby pharmacies based on location and medication availability
- **Historical_Diagnosis**: A diagnosis record that was created in the past and is stored in the database
- **Fresh_Diagnosis**: A diagnosis that was just completed and is being displayed immediately after creation
- **Pharmacy_Recommendation**: Information about a nearby pharmacy including location, distance, available medicines, and contact details
- **Prescription**: A medication recommendation including medication name, dosage, frequency, and duration
- **Backend_API**: The Node.js/TypeScript backend service that provides diagnosis and pharmacy data
- **Flutter_App**: The mobile application frontend

## Requirements

### Requirement 1: Replace Mock Data with Real Diagnosis Data

**User Story:** As a healthcare provider, I want to see real diagnosis data in the patient medical history, so that I can review accurate historical information.

#### Acceptance Criteria

1. WHEN the Patient_Medical_History_Page loads, THE Flutter_App SHALL fetch real diagnosis records from the Backend_API
2. THE Backend_API SHALL return diagnosis records sorted by diagnosis date in descending order
3. THE Patient_Medical_History_Page SHALL display diagnosis records in a timeline format with accurate dates, diagnoses, and status information
4. IF the Backend_API returns an error, THEN THE Patient_Medical_History_Page SHALL display an error message to the user
5. THE Flutter_App SHALL cache diagnosis records to improve performance on subsequent views

### Requirement 2: Fetch Full Diagnosis Details on Selection

**User Story:** As a healthcare provider, I want to view complete diagnosis details when I tap on a historical diagnosis, so that I can review all information including symptoms, vital signs, and AI predictions.

#### Acceptance Criteria

1. WHEN a user taps on a diagnosis entry in the timeline, THE Flutter_App SHALL fetch the complete diagnosis details from the Backend_API
2. THE Backend_API SHALL return the full diagnosis record including symptoms, vital signs, AI predictions, prescriptions, and notes
3. THE Flutter_App SHALL display a loading indicator while fetching diagnosis details
4. IF the diagnosis details cannot be fetched, THEN THE Flutter_App SHALL display an error message and allow the user to retry
5. THE Flutter_App SHALL navigate to the Diagnosis_Result_Page with the fetched diagnosis data

### Requirement 3: Perform Real-Time Pharmacy Search for Historical Diagnoses

**User Story:** As a healthcare provider, I want to see current pharmacy recommendations when viewing historical diagnoses, so that I can provide patients with up-to-date information about where to obtain their medications.

#### Acceptance Criteria

1. WHEN the Flutter_App navigates to the Diagnosis_Result_Page for a historical diagnosis, THE Pharmacy_Search_Service SHALL search for nearby pharmacies based on the user's current location
2. THE Pharmacy_Search_Service SHALL filter pharmacies by availability of prescribed medications
3. THE Pharmacy_Search_Service SHALL calculate distance from the user's current location to each pharmacy
4. THE Pharmacy_Search_Service SHALL return pharmacies sorted by distance in ascending order
5. THE Pharmacy_Search_Service SHALL limit results to pharmacies within 50 kilometers
6. IF no pharmacies are found with the prescribed medications, THEN THE Flutter_App SHALL display the "No Nearby Pharmacies Found" message with suggestions

### Requirement 4: Display Pharmacy Recommendations with Existing UI

**User Story:** As a healthcare provider, I want to see pharmacy recommendations in the same format for both fresh and historical diagnoses, so that I have a consistent user experience.

#### Acceptance Criteria

1. WHEN the Diagnosis_Result_Page displays a historical diagnosis with pharmacy data, THE Flutter_App SHALL use the existing _buildPharmaciesCard widget
2. THE Flutter_App SHALL display pharmacy name, address, distance, phone number, and available medicines
3. THE Flutter_App SHALL highlight pharmacies that have all prescribed medicines with a "Has all medicines" badge
4. THE Flutter_App SHALL provide "Call" and "Navigate" buttons for each pharmacy
5. WHEN a user taps on a pharmacy card, THE Flutter_App SHALL display detailed pharmacy information in a bottom sheet

### Requirement 5: Handle Location Permissions and Errors

**User Story:** As a healthcare provider, I want clear feedback when location services are unavailable, so that I understand why pharmacy recommendations cannot be shown.

#### Acceptance Criteria

1. WHEN the Flutter_App attempts to search for pharmacies, THE Flutter_App SHALL request location permissions if not already granted
2. IF location permissions are denied, THEN THE Flutter_App SHALL display a message explaining that pharmacy recommendations require location access
3. IF location services are disabled, THEN THE Flutter_App SHALL display a message prompting the user to enable location services
4. IF the location cannot be determined within 10 seconds, THEN THE Flutter_App SHALL display a timeout error message
5. THE Flutter_App SHALL provide a "Retry" button to attempt the pharmacy search again

### Requirement 6: Maintain Backend Diagnosis API Compatibility

**User Story:** As a system administrator, I want the backend API to remain compatible with existing clients, so that other features continue to work without modification.

#### Acceptance Criteria

1. THE Backend_API SHALL maintain the existing GET /api/diagnoses/:id endpoint
2. THE Backend_API SHALL return diagnosis records in the existing DiagnosisResponse format
3. THE Backend_API SHALL include all fields: id, diagnosisId, patientId, aiPredictions, selectedDiagnosis, prescriptions, symptoms, vitalSigns, diagnosisDate, notes, followUpRequired, followUpDate
4. THE Backend_API SHALL support filtering diagnoses by patientId query parameter
5. THE Backend_API SHALL support pagination with limit and offset query parameters

### Requirement 7: Optimize Performance for Historical Data

**User Story:** As a healthcare provider, I want the patient medical history page to load quickly, so that I can efficiently review patient information.

#### Acceptance Criteria

1. THE Flutter_App SHALL load the initial list of diagnoses within 2 seconds on a standard network connection
2. THE Flutter_App SHALL implement pagination to load diagnoses in batches of 20 records
3. THE Flutter_App SHALL cache diagnosis list data for 5 minutes to reduce API calls
4. WHEN scrolling to the bottom of the timeline, THE Flutter_App SHALL automatically load the next batch of diagnoses
5. THE Flutter_App SHALL display a loading indicator at the bottom of the list while fetching additional diagnoses

### Requirement 8: Preserve Pharmacy Search Functionality for Fresh Diagnoses

**User Story:** As a healthcare provider, I want pharmacy recommendations to continue working for fresh diagnoses, so that existing functionality is not disrupted.

#### Acceptance Criteria

1. WHEN a fresh diagnosis is completed, THE Flutter_App SHALL perform a pharmacy search as it currently does
2. THE Flutter_App SHALL pass pharmacy data to the Diagnosis_Result_Page via navigation parameters
3. THE Diagnosis_Result_Page SHALL display pharmacy recommendations using the existing UI
4. THE pharmacy search logic for fresh diagnoses SHALL remain unchanged
5. THE Flutter_App SHALL maintain backward compatibility with the existing diagnosis flow

### Requirement 9: Handle Missing or Incomplete Prescription Data

**User Story:** As a healthcare provider, I want appropriate handling of diagnoses without prescriptions, so that the UI remains functional in all scenarios.

#### Acceptance Criteria

1. WHEN a diagnosis has no prescriptions, THE Flutter_App SHALL not display the pharmacy recommendations section
2. WHEN a diagnosis has prescriptions but no pharmacy data is available, THE Flutter_App SHALL display the "No Nearby Pharmacies Found" card
3. THE Flutter_App SHALL not crash or display errors when prescription data is null or empty
4. THE Flutter_App SHALL display a message indicating "No prescriptions for this diagnosis" when appropriate
5. THE Diagnosis_Result_Page SHALL remain fully functional for diagnoses without prescriptions

### Requirement 10: Provide Audit Trail for Historical Diagnosis Views

**User Story:** As a system administrator, I want to track when historical diagnoses are viewed, so that I can monitor system usage and ensure compliance.

#### Acceptance Criteria

1. WHEN a user views a historical diagnosis, THE Backend_API SHALL log the event with timestamp, user ID, patient ID, and diagnosis ID
2. THE Backend_API SHALL store audit logs in a separate audit_logs table
3. THE audit log SHALL include the action type "VIEW_HISTORICAL_DIAGNOSIS"
4. THE Backend_API SHALL not fail the diagnosis retrieval if audit logging fails
5. THE audit logs SHALL be retained for at least 90 days for compliance purposes
