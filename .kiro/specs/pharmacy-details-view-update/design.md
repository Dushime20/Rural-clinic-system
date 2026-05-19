# Pharmacy Details View Update Bugfix Design

## Overview

This bugfix addresses a usability issue in the pharmacy details modal where technical coordinate information (latitude/longitude) is displayed to end users while the valuable medicines list is not shown. The fix involves removing the coordinates display from the details section and adding a medicines list section that shows medication name, price, stock status, and other relevant details. The coordinates will still be used internally for the "Navigate" button functionality, but will not be visible to users.

## Glossary

- **Bug_Condition (C)**: The condition where the pharmacy details modal displays coordinates and does not display medicines
- **Property (P)**: The desired behavior where coordinates are hidden and medicines are displayed in the modal
- **Preservation**: Existing functionality (Call button, Navigate button, search, modal opening) that must remain unchanged
- **_showPharmacyDetails**: The method in `pharmacies_page.dart` that builds and displays the pharmacy details modal
- **NearbyPharmacy**: The model class that contains pharmacy data including the medicines list
- **PharmacyMedicine**: The model class representing individual medicine items with properties like medicationName, price, stockQuantity, isAvailable

## Bug Details

### Bug Condition

The bug manifests when a user opens the pharmacy details modal. The modal displays technical coordinate information (latitude/longitude) that is not useful for end users, while failing to display the medicines list even though the data is available in the `NearbyPharmacy.medicines` property.

**Formal Specification:**
```
FUNCTION isBugCondition(input)
  INPUT: input of type UserAction (opening pharmacy details modal)
  OUTPUT: boolean
  
  RETURN input.action == "openPharmacyDetails"
         AND modalDisplaysCoordinates(input.pharmacy)
         AND NOT modalDisplaysMedicines(input.pharmacy)
END FUNCTION
```

### Examples

- **Example 1**: User taps on "City Pharmacy" card → Modal opens showing "Coordinates: 1.9536, 30.0606" in the details section → User sees technical data instead of useful medicine information
- **Example 2**: User taps on "Health Plus Pharmacy" card → Modal opens with address, phone, hours, and coordinates → Medicines list is not shown even though the pharmacy has 15 medicines in stock
- **Example 3**: User searches for a pharmacy with specific medicine → Opens details modal → Cannot see if the medicine is available because medicines list is not displayed
- **Edge Case**: User opens details for a pharmacy with no medicines → Should see a message "No medicines currently available" instead of an empty section

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Pharmacy name, address, phone number, opening hours, and active status display must continue to work exactly as before
- "Call" button must continue to launch the phone dialer with the pharmacy's phone number
- "Navigate" button must continue to open Google Maps with the pharmacy's coordinates (coordinates are still used internally, just not displayed)
- Search functionality must continue to filter pharmacies by name, address, city, and district
- Tapping on a pharmacy card must continue to open the pharmacy details modal
- Modal appearance, animations, and draggable behavior must remain unchanged

**Scope:**
All inputs and interactions that do NOT involve viewing the details section of the pharmacy modal should be completely unaffected by this fix. This includes:
- Mouse/touch interactions with pharmacy cards
- Search bar interactions
- Refresh button functionality
- Navigation between pages
- Call and Navigate button functionality

## Hypothesized Root Cause

Based on the bug description and code analysis, the root cause is clear:

1. **Coordinates Display**: The `_showPharmacyDetails` method explicitly includes a `_buildDetailRow` call that displays coordinates:
   ```dart
   _buildDetailRow(
     Icons.gps_fixed,
     'Coordinates',
     '${pharmacy.latitude.toStringAsFixed(4)}, ${pharmacy.longitude.toStringAsFixed(4)}',
   )
   ```
   This was likely added during development for debugging purposes and was never removed.

2. **Missing Medicines Section**: The modal builder does not include any code to display the `pharmacy.medicines` list, even though:
   - The `NearbyPharmacy` model has a `medicines` property
   - The `PharmacyMedicine` model has all necessary display properties (medicationName, price, stockQuantity, isAvailable, etc.)
   - The data is already being fetched from the API

3. **Design Oversight**: The original implementation focused on location-based features (call, navigate) but overlooked the primary user need: knowing what medicines are available at each pharmacy.

## Correctness Properties

Property 1: Bug Condition - Coordinates Hidden and Medicines Displayed

_For any_ user action where the pharmacy details modal is opened, the fixed modal SHALL NOT display the coordinates row in the details section, and SHALL display a medicines list section showing all available medicines with their name, price, and stock status, or a "No medicines currently available" message if the medicines list is empty.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Preservation - Existing Modal Functionality

_For any_ user interaction that does NOT involve viewing the coordinates or medicines sections (such as using Call button, Navigate button, viewing other details, searching, or opening the modal), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing functionality.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5**

## Fix Implementation

### Changes Required

**File**: `ai_health_companion/lib/features/pharmacy/presentation/pages/pharmacies_page.dart`

**Method**: `_showPharmacyDetails`

**Specific Changes**:

1. **Remove Coordinates Display**: Delete or comment out the `_buildDetailRow` call that displays coordinates (lines showing "Coordinates" with latitude/longitude values)

2. **Add Medicines Section**: After the existing details section and before the action buttons, add a new medicines list section that:
   - Displays a section header "Available Medicines"
   - Shows a list of medicines if `pharmacy.medicines.isNotEmpty`
   - For each medicine, displays:
     - Medication name (using `PharmacyMedicine.displayName` which shows brand name if available)
     - Strength and form if available (e.g., "500mg Tablet")
     - Price (using `PharmacyMedicine.priceText`)
     - Stock status (using `PharmacyMedicine.stockText` which shows "In stock", "Low stock", or "Out of stock")
   - Shows "No medicines currently available" message if `pharmacy.medicines.isEmpty`

3. **Add Helper Widget**: Create a `_buildMedicineCard` helper method to display individual medicine items in a consistent, readable format

4. **Adjust Spacing**: Ensure proper spacing between the medicines section and the action buttons for good visual hierarchy

5. **Handle Empty State**: Gracefully handle pharmacies with no medicines by showing an informative message instead of an empty section

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm that coordinates are displayed and medicines are not displayed in the current implementation.

**Test Plan**: Manually test the pharmacy details modal on the UNFIXED code by opening details for various pharmacies. Document the current behavior with screenshots or detailed observations.

**Test Cases**:
1. **Coordinates Visible Test**: Open details for any pharmacy → Observe that coordinates row is displayed with latitude/longitude values (will confirm bug on unfixed code)
2. **Medicines Missing Test**: Open details for a pharmacy known to have medicines in the database → Observe that medicines section is not displayed (will confirm bug on unfixed code)
3. **Empty Medicines Test**: Open details for a pharmacy with no medicines → Observe that no medicines section or empty state message is shown (expected on unfixed code)
4. **Navigate Button Test**: Click Navigate button → Observe that Google Maps opens correctly with coordinates (should work on unfixed code, confirming coordinates are available internally)

**Expected Counterexamples**:
- Coordinates row is visible in the details section showing technical latitude/longitude values
- Medicines section is completely absent from the modal
- No indication of medicine availability even when data exists in the model

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds (opening pharmacy details modal), the fixed modal produces the expected behavior.

**Pseudocode:**
```
FOR ALL pharmacy IN pharmacyList DO
  modal := showPharmacyDetails_fixed(pharmacy)
  ASSERT NOT modal.contains("Coordinates")
  ASSERT NOT modal.contains(pharmacy.latitude)
  ASSERT NOT modal.contains(pharmacy.longitude)
  
  IF pharmacy.medicines.isNotEmpty THEN
    ASSERT modal.contains("Available Medicines")
    FOR EACH medicine IN pharmacy.medicines DO
      ASSERT modal.contains(medicine.medicationName)
      ASSERT modal.contains(medicine.priceText)
      ASSERT modal.contains(medicine.stockText)
    END FOR
  ELSE
    ASSERT modal.contains("No medicines currently available")
  END IF
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold (interactions not involving coordinates or medicines display), the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL interaction WHERE NOT (interaction == "viewCoordinates" OR interaction == "viewMedicines") DO
  ASSERT originalBehavior(interaction) = fixedBehavior(interaction)
END FOR
```

**Testing Approach**: Manual testing is appropriate for this UI change because:
- The changes are purely visual/presentational
- The fix involves widget composition and layout
- Flutter widget tests would be ideal but may not be set up in the project yet
- Manual testing can quickly verify both the fix and preservation requirements

**Test Plan**: Test all existing functionality on UNFIXED code to document current behavior, then verify the same behavior continues after the fix.

**Test Cases**:
1. **Pharmacy Name Display**: Verify pharmacy name, active badge, and icon display correctly in both unfixed and fixed versions
2. **Address Display**: Verify address with city/district displays correctly in both versions
3. **Phone Display**: Verify phone number displays correctly in both versions
4. **Opening Hours Display**: Verify opening hours display correctly in both versions
5. **Call Button**: Click Call button → Verify phone dialer launches with correct number in both versions
6. **Navigate Button**: Click Navigate button → Verify Google Maps opens with correct location in both versions (coordinates still used internally)
7. **Search Functionality**: Search for pharmacy by name → Verify filtering works in both versions
8. **Search by Address**: Search for pharmacy by address → Verify filtering works in both versions
9. **Modal Opening**: Tap pharmacy card → Verify modal opens with draggable behavior in both versions
10. **Modal Closing**: Drag modal down or tap outside → Verify modal closes in both versions

### Unit Tests

- Test that coordinates row is not included in the modal widget tree
- Test that medicines section is included when pharmacy has medicines
- Test that empty state message is shown when pharmacy has no medicines
- Test that each medicine displays all required information (name, price, stock)
- Test that existing detail rows (address, phone, hours) are still present

### Property-Based Tests

Property-based testing is not applicable for this UI change because:
- The changes are presentational and involve Flutter widgets
- There are no complex algorithms or data transformations to test
- The input domain is limited (pharmacy objects with known structure)
- Manual testing and widget tests are more appropriate for UI verification

### Integration Tests

- Test full user flow: Open app → Navigate to Pharmacies page → Search for pharmacy → Tap pharmacy card → Verify modal shows correct information without coordinates and with medicines list
- Test with various pharmacy data: pharmacies with many medicines, few medicines, no medicines
- Test that Call and Navigate buttons continue to work after the fix
- Test that modal appearance and animations are unchanged
- Test on different screen sizes to ensure medicines list is scrollable and well-formatted
