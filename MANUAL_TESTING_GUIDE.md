# Manual Testing Guide - Clinic Specialized Recommendations

## 🎉 Implementation Status: Ready for Manual Testing!

All **core implementation tasks** are complete. You can now start manual testing!

---

## ✅ Completed Tasks Summary

### Backend (100% Complete)
- ✅ Database schema and migrations
- ✅ All backend services (Clinic, ClinicSearch, DiagnosisHistory, RecommendationEngine, Email, Analytics)
- ✅ All API endpoints (15+ endpoints)
- ✅ Rate limiting and security measures
- ✅ Input validation and sanitization
- ✅ Error handling and graceful degradation

### Admin Dashboard (100% Complete)
- ✅ Clinics management page
- ✅ Multi-step clinic creation wizard
- ✅ Clinic details modal
- ✅ Search, filter, pagination

### Clinic Dashboard (100% Complete)
- ✅ New React application with blue/indigo theme
- ✅ Authentication pages (login, change password)
- ✅ Dashboard with statistics
- ✅ Profile management
- ✅ Specialties management

### Flutter App (100% Complete)
- ✅ All models (ClinicRecommendation, PatternAnalysis)
- ✅ All UI components (ClinicRecommendationCard, PatternAnalysisNotice, filters, error notices)
- ✅ DiagnosisResultPage integration
- ✅ Location permission handling
- ✅ Historical diagnosis support

### Documentation (100% Complete)
- ✅ API documentation
- ✅ Admin user guide
- ✅ Clinic user guide
- ✅ Deployment checklist
- ✅ Security implementation guide

---

## 🧪 Manual Testing Checklist

### Prerequisites

#### 1. Start Backend Server
```bash
cd ai_health_companion_backend
npm install
npm run dev
```

#### 2. Start Admin Dashboard
```bash
cd admin_dashboard
npm install
npm run dev
# Opens on http://localhost:5173
```

#### 3. Start Clinic Dashboard
```bash
cd clinic_dashboard
npm install
npm run dev
# Opens on http://localhost:5175
```

#### 4. Build Flutter App
```bash
cd ai_health_companion
flutter pub get
flutter run
```

---

## Test Flow 1: Admin Creates Clinic User

### Steps

1. **Login to Admin Dashboard**
   - Open http://localhost:5173
   - Login with admin credentials
   - ✅ Dashboard loads successfully

2. **Navigate to Clinics Page**
   - Click "Clinics" in sidebar
   - ✅ Clinics page loads with table
   - ✅ "Create Clinic" button visible

3. **Create New Clinic**
   - Click "Create Clinic" button
   - ✅ Modal opens with Step 1 (Basic Info)
   
   **Step 1: Basic Info**
   - Fill in:
     - Clinic Name: "Test Clinic"
     - Manager Name: "Dr. John Doe"
     - Email: "testclinic@example.com"
     - Phone: "+1234567890"
   - Click "Next"
   - ✅ Validation works (try invalid email first)
   - ✅ Proceeds to Step 2
   
   **Step 2: Location**
   - Fill in:
     - Address: "123 Main St"
     - City: "Test City"
     - District: "Test District"
     - Country: "Test Country"
     - Latitude: "40.7128"
     - Longitude: "-74.0060"
   - Click "Next"
   - ✅ Coordinate validation works (try lat > 90)
   - ✅ Proceeds to Step 3
   
   **Step 3: Specialties**
   - Select at least 1 specialty (e.g., "Cardiology")
   - Click "Next"
   - ✅ Validates at least one selected
   - ✅ Proceeds to Step 4
   
   **Step 4: Operating Hours** (Optional)
   - Skip or fill in operating hours
   - Click "Create Clinic"
   - ✅ Success screen shows with temporary password
   - ✅ Copy password button works
   - ✅ Email sent confirmation (check backend logs)

4. **Verify Clinic in Table**
   - Close modal
   - ✅ New clinic appears in table
   - ✅ Shows name, manager, email, specialties
   - ✅ Status is "Active"

5. **View Clinic Details**
   - Click on clinic row
   - ✅ Details modal opens
   - ✅ Shows all clinic information
   - ✅ "Deactivate" button visible

6. **Test Clinic Search/Filter**
   - Use search box to search by name
   - ✅ Search works
   - Filter by specialty
   - ✅ Filter works
   - Test pagination (if multiple clinics)
   - ✅ Pagination works

### Expected Results
- ✅ Clinic created successfully
- ✅ Temporary password generated (12 characters)
- ✅ Email sent (check backend logs or email inbox)
- ✅ Clinic appears in list
- ✅ All validations work correctly

---

## Test Flow 2: Clinic User First Login

### Steps

1. **Open Clinic Dashboard**
   - Open http://localhost:5175
   - ✅ Login page loads

2. **Login with Temporary Password**
   - Email: "testclinic@example.com"
   - Password: [temporary password from admin creation]
   - Click "Login"
   - ✅ Login successful
   - ✅ **Automatically redirected to Change Password page**

3. **Change Password**
   - Current Password: [temporary password]
   - New Password: "NewSecure123!"
   - Confirm Password: "NewSecure123!"
   - Click "Change Password"
   - ✅ Password changed successfully
   - ✅ Redirected to dashboard

4. **View Dashboard**
   - ✅ Clinic name displayed
   - ✅ Statistics shown (specialties, recommendations, days since registration)
   - ✅ Navigation cards visible (Profile, Specialties, etc.)
   - ✅ "Complete Your Profile" notice may appear

5. **Update Profile**
   - Click "Profile" card or nav link
   - ✅ Profile page loads with current data
   - Update fields (e.g., phone number)
   - Click "Save"
   - ✅ Profile updated successfully
   - ✅ Success toast appears

6. **Update Specialties**
   - Click "Specialties" card or nav link
   - ✅ Current specialties shown as badges
   - Select/deselect specialties
   - ✅ At least one specialty required (try removing all)
   - Click "Save"
   - ✅ Specialties updated successfully

7. **Logout and Login Again**
   - Logout
   - Login with new password
   - ✅ Login successful
   - ✅ Goes directly to dashboard (no password change required)

### Expected Results
- ✅ First login forces password change
- ✅ Password validation works (min 8 characters)
- ✅ New password works for subsequent logins
- ✅ Profile update works
- ✅ Specialties update works with validation

---

## Test Flow 3: Patient Receives Clinic Recommendations

### Scenario A: Recurring Disease Pattern

1. **Setup: Create Recurring Diagnosis History**
   - For a test patient, create 3+ diagnoses of the same disease within 90 days
   - Use backend API or database directly

2. **Perform New Diagnosis (Flutter App)**
   - Login to Flutter app as health worker
   - Start new diagnosis for the patient
   - Complete symptoms and get diagnosis
   - ✅ Pattern analysis detected: "Recurring"
   - ✅ PatternAnalysisNotice displayed (orange theme)
   - ✅ "Specialized Clinic Recommendations" section appears
   - ✅ Clinic recommendations displayed with reason: "Recurring Pattern"

3. **Verify Clinic Card Details**
   - ✅ Clinic name, specialties visible
   - ✅ Address and distance shown (if location available)
   - ✅ "Call" and "Navigate" buttons work
   - ✅ Tap card opens bottom sheet with full details

4. **Test Specialty Filter**
   - ✅ Specialty filter dropdown appears
   - Select a specialty
   - ✅ Clinics filtered by selected specialty
   - ✅ "Clear Filters" button works

### Scenario B: No Pharmacy Fallback

1. **Setup: Diagnosis with No Pharmacy Stock**
   - Ensure no pharmacy has the medication in stock

2. **Perform Diagnosis**
   - Complete diagnosis
   - ✅ No pharmacy recommendations displayed
   - ✅ "Specialized Clinic Recommendations" section appears
   - ✅ Reason: "No pharmacy available with medication"
   - ✅ Clinic recommendations displayed

### Scenario C: Location Permission Handling

1. **Deny Location Permission**
   - Perform diagnosis
   - Deny location permission when prompted
   - ✅ Clinic recommendations still appear (without distance)
   - ✅ Distance field shows "N/A" or hidden
   - ✅ "Navigate" button disabled or shows message

2. **Grant Location Permission**
   - Perform another diagnosis
   - Grant location permission
   - ✅ Clinic recommendations show distance
   - ✅ Sorted by distance (nearest first)
   - ✅ "Navigate" button works

### Scenario D: Error Handling

1. **Simulate Backend Error**
   - Stop backend server or cause timeout
   - Perform diagnosis
   - ✅ ClinicErrorNotice displayed (red theme)
   - ✅ "Retry" button visible
   - ✅ Diagnosis still succeeds (graceful degradation)

2. **Simulate Location Service Error**
   - Disable location services on device
   - Perform diagnosis
   - ✅ LocationServiceErrorNotice displayed (orange theme)
   - ✅ "Enable Location" button visible
   - ✅ Clinic recommendations still appear

### Expected Results
- ✅ Pattern detection works (recurring, persistent, chronic)
- ✅ Clinic recommendations appear correctly
- ✅ Specialty filtering works
- ✅ Location permissions handled gracefully
- ✅ Error handling works (diagnosis doesn't fail)
- ✅ Call and navigate buttons work

---

## Test Flow 4: Historical Diagnosis Support

### Steps

1. **View Historical Diagnosis**
   - In Flutter app, navigate to diagnosis history
   - Tap on a past diagnosis
   - ✅ DiagnosisResultPage loads

2. **Verify Re-evaluation**
   - ✅ Historical diagnosis banner appears (blue)
   - ✅ Explains recommendations based on current location
   - ✅ Clinic recommendations displayed (if pattern exists)
   - ✅ Uses current location, not historical

3. **Verify Caching**
   - View same historical diagnosis again within 10 minutes
   - ✅ Clinic recommendations load quickly (cached)

### Expected Results
- ✅ Historical diagnoses show clinic recommendations
- ✅ Uses current location for recommendations
- ✅ Clear indication of historical vs. current
- ✅ Caching works (10-minute cache)

---

## Test Flow 5: Rate Limiting

### Test Authentication Rate Limit

```bash
# Run this script to test auth rate limiting
for i in {1..6}; do
  curl -X POST http://localhost:3000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"wrong@example.com","password":"wrong"}' \
    -w "\nHTTP Status: %{http_code}\n\n"
done
```

**Expected Result**:
- First 5 attempts: 401 Unauthorized
- 6th attempt: 429 Too Many Requests with rate limit message

### Test Clinic Search Rate Limit

```bash
# Create a script to hit clinic search endpoint 101 times
for i in {1..101}; do
  curl -X POST http://localhost:3000/api/clinics/search \
    -H "Authorization: Bearer YOUR_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"diseaseName":"diabetes"}' \
    -w "\nRequest $i: %{http_code}\n"
done
```

**Expected Result**:
- First 100 requests: 200 OK
- 101st request: 429 Too Many Requests

### Test Clinic Creation Rate Limit

```bash
# Try creating 11 clinics rapidly as admin
for i in {1..11}; do
  curl -X POST http://localhost:3000/api/admin/clinics \
    -H "Authorization: Bearer ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"Clinic'$i'", ...other fields...}' \
    -w "\nRequest $i: %{http_code}\n"
done
```

**Expected Result**:
- First 10 requests: 201 Created
- 11th request: 429 Too Many Requests

---

## Test Flow 6: Input Validation

### Test Coordinate Validation

**Invalid Latitude**:
```bash
curl -X POST http://localhost:3000/api/admin/clinics \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "latitude": 100,  # Invalid (> 90)
    "longitude": -74,
    ...
  }'
```

**Expected**: 400 Bad Request with validation error

**Invalid Longitude**:
```bash
curl -X POST http://localhost:3000/api/admin/clinics \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test",
    "latitude": 40,
    "longitude": 200,  # Invalid (> 180)
    ...
  }'
```

**Expected**: 400 Bad Request with validation error

### Test Email Validation

```bash
curl -X POST http://localhost:3000/api/admin/clinics \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "not-an-email",  # Invalid email
    ...
  }'
```

**Expected**: 400 Bad Request with email validation error

### Test Specialty Validation

```bash
curl -X PUT http://localhost:3000/api/clinic-manager/my/specialties \
  -H "Authorization: Bearer CLINIC_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "specialties": []  # Invalid (at least 1 required)
  }'
```

**Expected**: 400 Bad Request with validation error

---

## Test Flow 7: Backward Compatibility

### Test Diagnosis Endpoint (No Clinics)

1. **Perform diagnosis that doesn't trigger clinic recommendations**
   - Disease with pharmacy availability
   - No recurring/persistent/chronic pattern

2. **Verify Response Structure**
   ```json
   {
     "success": true,
     "data": {
       "diagnosis": {...},
       "recommendations": {
         "pharmacies": [...],
         // clinics field should be undefined (not present)
         // patternAnalysis should be undefined
         // clinicRecommendationReason should be undefined
       }
     }
   }
   ```

3. **Verify Pharmacy Flow Unchanged**
   - ✅ Pharmacy recommendations still work
   - ✅ No clinic-related fields in response
   - ✅ Existing Flutter app versions handle response correctly

### Expected Results
- ✅ Diagnosis endpoint backward compatible
- ✅ Clinic fields only present when applicable
- ✅ Existing pharmacy flow unaffected

---

## Common Issues and Troubleshooting

### Issue: Clinic Dashboard Not Loading

**Possible Causes**:
- Backend not running
- CORS configuration
- API URL mismatch

**Solution**:
```bash
# Check backend is running
curl http://localhost:3000/api/health

# Check CORS in backend (should allow localhost:5175)
# Verify .env file in clinic_dashboard:
VITE_API_BASE_URL=http://localhost:3000
```

### Issue: Email Not Sent

**Possible Causes**:
- SMTP credentials not configured
- Email service disabled

**Solution**:
```bash
# Check backend .env file:
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Check backend logs for email errors
```

### Issue: Rate Limiting Not Working

**Possible Causes**:
- Rate limiter not applied to route
- Testing too slowly

**Solution**:
- Check route file has rate limiter imported and applied
- Use script to rapidly hit endpoint (see Test Flow 5)

### Issue: Location Permission Always Denied (Flutter)

**Possible Causes**:
- Permission not requested in AndroidManifest.xml / Info.plist
- Device settings

**Solution**:
```xml
<!-- Android: Check AndroidManifest.xml has: -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- iOS: Check Info.plist has: -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby clinics</string>
```

---

## Performance Testing

### Test Clinic Search Performance

```bash
# Measure clinic search latency
time curl -X POST http://localhost:3000/api/clinics/search \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "diseaseName": "diabetes",
    "latitude": 40.7128,
    "longitude": -74.0060
  }'
```

**Expected**: < 5 seconds (with timeout protection)

### Test Diagnosis with Clinic Recommendations

```bash
# Measure full diagnosis flow latency
time curl -X POST http://localhost:3000/api/v1/diagnosis \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "uuid",
    "symptoms": ["fever", "cough"],
    ...
  }'
```

**Expected**: < 3 seconds total

---

## Security Testing

### Test SQL Injection Attempt

```bash
curl -X POST http://localhost:3000/api/clinics/search \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "diseaseName": "diabetes; DROP TABLE clinics;--"
  }'
```

**Expected**: Query sanitized, no SQL injection, 200 OK with results

### Test XSS Attempt

```bash
curl -X POST http://localhost:3000/api/admin/clinics \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "<script>alert(\"XSS\")</script>",
    ...
  }'
```

**Expected**: HTML escaped, stored as `&lt;script&gt;alert(&quot;XSS&quot;)&lt;/script&gt;`

---

## Success Criteria

### All Tests Pass When:

- ✅ Admin can create clinic users
- ✅ Clinic users can login and manage profile
- ✅ Patients receive clinic recommendations correctly
- ✅ Pattern detection works (recurring, persistent, chronic)
- ✅ Location permissions handled gracefully
- ✅ Error handling works (diagnosis doesn't fail)
- ✅ Rate limiting enforced correctly
- ✅ Input validation prevents invalid data
- ✅ Backward compatibility maintained
- ✅ Performance within acceptable limits (<5s clinic search)
- ✅ Security measures prevent common attacks

---

## After Manual Testing

### If All Tests Pass:

1. **Document any issues found** (and fix them)
2. **Update deployment checklist** if needed
3. **Proceed to staging deployment**
4. **Monitor closely in staging**
5. **Deploy to production** after staging verification

### If Issues Found:

1. **Document the issue** (steps to reproduce, expected vs. actual)
2. **Prioritize** (critical, major, minor)
3. **Fix critical issues** before production
4. **Re-test after fixes**

---

## Contact

If you encounter issues during testing:
- Check backend logs for errors
- Check browser console for frontend errors
- Check Flutter logs for mobile app errors
- Review SECURITY_IMPLEMENTATION.md for security-related issues
- Review DEPLOYMENT_CHECKLIST.md for deployment-related issues

---

**Happy Testing! 🎉**

The feature is ready for production deployment after successful manual testing.

---

**Document Version**: 1.0  
**Last Updated**: January 2024  
**Prepared By**: Development Team
