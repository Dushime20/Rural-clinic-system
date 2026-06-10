# Testing Guide: Clinic Creation Simplification & Dashboard Enhancement

## Prerequisites
- All services running (backend, admin dashboard, clinic dashboard)
- Admin account credentials
- At least one patient with a diagnosis and prescription in the system

---

## Test 1: Simplified Clinic Creation (Admin Dashboard)

### Steps:
1. Open admin dashboard at `http://localhost:3000`
2. Login as admin
3. Navigate to **Clinics** page
4. Click **"Create Clinic"** button

### Expected Behavior:
- ✅ Modal opens with title "Create New Clinic"
- ✅ Blue info card visible explaining quick setup
- ✅ Only 4 fields visible:
  - Clinic Name (required)
  - Manager Name (required)
  - Email (required)
  - Phone Number (optional)
- ✅ No progress indicator
- ✅ No multi-step navigation
- ✅ Single "Create Clinic" button at bottom

### Test Case 1.1: Create with minimum fields
**Input**:
- Clinic Name: `Test Rural Clinic`
- Manager Name: `Dr. Jane Smith`
- Email: `jane.smith@testclinic.com`
- Phone Number: *(leave empty)*

**Expected Result**:
- ✅ Success modal appears
- ✅ Shows "Clinic user created successfully!"
- ✅ Shows temporary password
- ✅ Shows email confirmation message
- ✅ Copy button works for password
- ✅ "Done" button closes modal
- ✅ New clinic appears in clinics list

### Test Case 1.2: Create with all fields
**Input**:
- Clinic Name: `Kigali Health Center`
- Manager Name: `Dr. John Doe`
- Email: `john.doe@kigalihealth.rw`
- Phone Number: `+250788123456`

**Expected Result**:
- ✅ Same success flow as 1.1
- ✅ Phone number saved correctly

### Test Case 1.3: Validation errors
**Test invalid email**:
- Email: `invalidemail` (no @ or domain)
- ✅ Error message: "Invalid email format"

**Test empty required fields**:
- Leave Clinic Name empty
- ✅ Error message: "Clinic name is required"

---

## Test 2: Clinic First Login & Password Change

### Steps:
1. Open clinic dashboard at `http://localhost:5175`
2. Login with email and temporary password from Test 1

### Expected Behavior:
- ✅ Login successful
- ✅ Automatically redirected to `/change-password` page
- ✅ Cannot access other pages until password changed

### Test Case 2.1: Change password
**Input**:
- Current Password: *(temporary password from admin)*
- New Password: `NewSecure123!`
- Confirm Password: `NewSecure123!`

**Expected Result**:
- ✅ Success message: "Password changed successfully"
- ✅ Redirected to Dashboard
- ✅ Can now navigate freely

---

## Test 3: Clinic Profile Management

### Steps:
1. After logging in (from Test 2), navigate to **Profile** page
2. Click **"Edit Profile"** button

### Expected Behavior:
- ✅ All fields become editable
- ✅ Three main sections visible:
  - Basic Information
  - Location
  - **Medical Specialties** (NEW)
  - **Opening Hours** (NEW)

### Test Case 3.1: Update basic info
**Input**:
- Clinic Name: `Test Rural Clinic - Updated`
- Manager Name: `Dr. Jane Smith-Updated`
- Phone: `+250788999888`

**Expected Result**:
- ✅ Changes saved successfully
- ✅ Toast notification appears
- ✅ Edit mode exits automatically
- ✅ Data persists after page refresh

### Test Case 3.2: Update location
**Input**:
- Address: `KG 123 Street, Kimironko`
- City: `Kigali`
- District: `Gasabo`
- Country: `Rwanda`
- Latitude: `-1.9441`
- Longitude: `30.0619`

**Expected Result**:
- ✅ All location fields saved
- ✅ Coordinates validated (must be within range)
- ✅ Clinic now visible on map (if map feature exists)

### Test Case 3.3: Select medical specialties
**Actions**:
1. In edit mode, scroll to "Medical Specialties" section
2. Check the following specialties:
   - ✅ General Medicine
   - ✅ Cardiology
   - ✅ Infectious Disease
3. Leave others unchecked
4. Click "Save Changes"

**Expected Result**:
- ✅ 3 specialties saved
- ✅ When not editing, only checked specialties show checked state
- ✅ Checkboxes disabled when not editing (gray background)

### Test Case 3.4: Set opening hours
**Input**:
- Monday: `08:00` to `17:00`
- Tuesday: `08:00` to `17:00`
- Wednesday: `08:00` to `17:00`
- Thursday: `08:00` to `17:00`
- Friday: `08:00` to `17:00`
- Saturday: `09:00` to `13:00`
- Sunday: *(leave empty)*

**Expected Result**:
- ✅ Hours saved for 6 days
- ✅ Sunday remains empty (clinic closed)
- ✅ When not editing, time inputs disabled
- ✅ Data persists after refresh

### Test Case 3.5: Validation - No specialties selected
**Actions**:
1. Click "Edit Profile"
2. Uncheck ALL specialties
3. Click "Save Changes"

**Expected Result**:
- ✅ Error toast: "Please select at least one specialty"
- ✅ Form not saved
- ✅ Still in edit mode

### Test Case 3.6: Validation - Invalid coordinates
**Input**:
- Latitude: `100` (invalid, > 90)

**Expected Result**:
- ✅ Error toast: "Latitude must be between -90 and 90"
- ✅ Form not saved

---

## Test 4: Clinic Prescriptions Page

### Prerequisite:
- Ensure at least one diagnosis with prescription exists in system
- Can create through health worker mobile app or admin dashboard

### Steps:
1. In clinic dashboard, click **"Prescriptions"** in sidebar
2. Prescriptions page loads

### Expected Behavior:
- ✅ Page title: "Patient Prescriptions"
- ✅ Subtitle: "View patient diagnoses and prescribed medications"
- ✅ Blue info card visible with explanation
- ✅ Search bar present
- ✅ Table with columns:
  - Patient (name, phone)
  - Diagnosis (disease, ICD-10, confidence)
  - Prescriptions (count)
  - Date
  - Actions (View Details button)

### Test Case 4.1: View prescription list
**Expected Result**:
- ✅ All prescriptions displayed (up to 10 per page)
- ✅ Patient names formatted correctly
- ✅ Diagnosis shows disease name
- ✅ Prescription count shows number of medications
- ✅ Date formatted properly

### Test Case 4.2: Search functionality
**Input**:
- Search: `John` (patient first name)

**Expected Result**:
- ✅ Only prescriptions for patients named John shown
- ✅ Other prescriptions filtered out
- ✅ Clear search shows all again

**Input**:
- Search: `+250788` (partial phone number)

**Expected Result**:
- ✅ Prescriptions filtered by phone number
- ✅ Partial match works

### Test Case 4.3: View prescription details
**Actions**:
1. Click **"View Details"** button on any prescription
2. Modal opens

**Expected Result - Modal Contains**:
- ✅ **Patient Information** section:
  - Name
  - Phone number
  - Date of birth (if available)
  
- ✅ **Diagnosis Information** section (indigo background):
  - Disease name
  - ICD-10 code
  - Confidence percentage
  - Diagnosis date

- ✅ **Disease Description** (if available):
  - Full description in indigo card

- ✅ **Symptoms** section:
  - List of symptoms as badges
  - Severity shown (if available)

- ✅ **Vital Signs** section:
  - Temperature (°C)
  - Blood Pressure (systolic/diastolic)
  - Heart Rate (bpm)

- ✅ **Prescribed Medications** section:
  - Each medication in indigo card
  - Shows: Medication name, Dosage, Frequency, Duration
  - "Prescribed" badge visible

- ✅ **Clinical Notes** (if available):
  - Notes in gray card

- ✅ **Performed By**:
  - Health worker name at bottom

### Test Case 4.4: Pagination
*(Only if >10 prescriptions exist)*

**Actions**:
1. Scroll to bottom of table
2. Click "Next" page

**Expected Result**:
- ✅ Page 2 loads
- ✅ Next 10 prescriptions shown
- ✅ Page number updates
- ✅ "Previous" button now enabled

---

## Test 5: Navigation & Layout

### Test Case 5.1: Sidebar navigation
**Actions**:
1. Click each sidebar item:
   - Dashboard
   - Profile
   - Specialties
   - **Prescriptions** (NEW)

**Expected Result**:
- ✅ All navigation items work
- ✅ Active item highlighted in indigo
- ✅ Prescriptions has pill icon
- ✅ Correct page loads for each item

### Test Case 5.2: Mobile navigation
**Actions**:
1. Resize browser to mobile width (<1024px)
2. Check bottom navigation bar

**Expected Result**:
- ✅ Bottom nav bar appears
- ✅ 4 items visible: Dashboard, Profile, Specialties, Prescriptions
- ✅ Icons displayed correctly
- ✅ Active item highlighted

---

## Test 6: Backend Data Verification

### Verify Default Values
**Actions**:
1. After creating clinic in Test 1, query database or use backend API
2. Check clinic record

**Expected Result**:
- ✅ `latitude: 0`
- ✅ `longitude: 0`
- ✅ `specialties: ['General_Medicine']`
- ✅ `isActive: true`

### Verify Profile Update
**Actions**:
1. After updating profile in Test 3, query database
2. Check clinic record

**Expected Result**:
- ✅ Location fields updated
- ✅ Specialties array contains selected values
- ✅ Opening hours object contains time entries
- ✅ `updatedAt` timestamp changed

---

## Test 7: Edge Cases

### Test Case 7.1: Clinic with incomplete profile
**Scenario**: Clinic created by admin but never completed profile

**Expected Behavior**:
- ✅ Clinic can still login
- ✅ Profile shows default values (lat: 0, lng: 0, General_Medicine)
- ✅ Can edit and complete profile anytime
- ✅ Clinic appears in admin list but may not show on map

### Test Case 7.2: Email sending failure
**Scenario**: Email service down or email invalid

**Expected Behavior**:
- ✅ Clinic still created successfully
- ✅ Admin sees success modal with password
- ✅ Admin can manually share credentials
- ✅ Warning logged in backend (check logs)

### Test Case 7.3: No prescriptions in system
**Actions**:
1. Fresh database with no diagnoses
2. Navigate to Prescriptions page

**Expected Result**:
- ✅ Empty state shown: "No prescriptions found"
- ✅ No errors in console
- ✅ Search and pagination still work (no crash)

---

## Regression Testing

### Verify Existing Functionality Unaffected
- ✅ Admin can still view existing clinics
- ✅ Admin can activate/deactivate clinics
- ✅ Clinic dashboard login still works
- ✅ Clinic specialties filter works (if exists)
- ✅ Map shows clinics correctly (if exists)
- ✅ Health worker app can still see clinic recommendations

---

## Performance Testing

### Test Case: Multiple Clinics
**Actions**:
1. Create 20+ clinics via admin dashboard
2. Check admin clinics list load time
3. Check clinic dropdown/filter performance

**Expected Result**:
- ✅ Page loads in <2 seconds
- ✅ No lag when scrolling
- ✅ Pagination works smoothly

### Test Case: Many Prescriptions
**Actions**:
1. Create 100+ prescriptions in system
2. Navigate to clinic prescriptions page
3. Perform search

**Expected Result**:
- ✅ Initial load <3 seconds
- ✅ Search results <1 second
- ✅ Pagination smooth
- ✅ No memory leaks (check browser dev tools)

---

## Browser Compatibility

Test on:
- ✅ Chrome (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Edge (latest)
- ✅ Mobile Chrome (Android)
- ✅ Mobile Safari (iOS)

---

## Known Issues / Limitations

1. **No map integration in Profile page** - Clinic must manually enter coordinates (unlike pharmacy which has map)
   - *Workaround*: Clinic can use Google Maps to find lat/lng
   - *Future enhancement*: Add interactive map like pharmacy profile

2. **Prescriptions show all diagnoses** - No filter by clinic specialty
   - *Current behavior*: Shows all prescriptions in system
   - *Future enhancement*: Filter by clinic's selected specialties

3. **No email verification** - Email field not validated as real email
   - *Current behavior*: Only format checked (has @ and domain)
   - *Future enhancement*: Send verification email

---

## Success Criteria

All tests must pass for release:
- [ ] All Test 1 cases pass (Admin creation)
- [ ] All Test 2 cases pass (First login)
- [ ] All Test 3 cases pass (Profile management)
- [ ] All Test 4 cases pass (Prescriptions viewing)
- [ ] All Test 5 cases pass (Navigation)
- [ ] Test 6 passes (Backend verification)
- [ ] All Test 7 edge cases handled gracefully
- [ ] No console errors during testing
- [ ] No diagnostics/linting errors in code
- [ ] Mobile responsive layout works

---

**Testing Date**: _____________
**Tester**: _____________
**Status**: [ ] Pass [ ] Fail
**Notes**: 
