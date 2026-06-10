# Testing Guide: Dynamic Clinic Recommendation Messages

## Overview
This guide helps you test all 9 scenarios for dynamic clinic recommendation messages in the Flutter app.

## Prerequisites
- Backend server running on port 5000
- Flutter app running (full restart required after any data model changes)
- Test patient account created
- Location services enabled

## How to Test

### Setup
1. Start backend: `cd ai_health_companion_backend && npm start`
2. Start Flutter app: `cd ai_health_companion && flutter run`
3. Login to the app with a test patient account

### Test Data Requirements

For each test, you'll need to create a diagnosis with specific conditions. The backend determines the `clinicRecommendationReason` based on:
- **Persistent**: Same disease diagnosed within last 30 days
- **Recurring**: Same disease diagnosed 2+ times in last 90 days
- **Chronic**: Disease matches chronic condition list
- **No pharmacy**: Prescriptions given but no nearby pharmacies found

---

## Test Scenarios

### ✅ Scenario 1: Persistent Disease + Pharmacies Available

**Setup**:
1. Create a diagnosis for a disease (e.g., "Common Cold")
2. Wait or modify database to make it appear within last 30 days
3. Create SAME diagnosis again with prescriptions
4. Ensure nearby pharmacies exist with the medications

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": "persistent condition detected",
    "pharmacies": [/* non-empty array */],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "This condition has persisted for an extended period. While pharmacies are available for medication, we also recommend visiting a specialized clinic for in-depth evaluation and comprehensive treatment."

---

### ✅ Scenario 2: Persistent Disease + No Pharmacies

**Setup**:
1. Same as Scenario 1
2. BUT ensure no nearby pharmacies exist (test in remote location or remove pharmacies from database)

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": "persistent condition detected",
    "pharmacies": [],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "This condition has persisted for an extended period. We recommend visiting a specialized clinic for in-depth evaluation and treatment."

---

### ✅ Scenario 3: Recurring Pattern + Pharmacies Available

**Setup**:
1. Create diagnosis for a disease (e.g., "Migraine")
2. Create SAME diagnosis 2 more times (3 total within 90 days)
3. Ensure nearby pharmacies exist

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": "recurring pattern detected",
    "pharmacies": [/* non-empty array */],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "Your diagnosis history shows a recurring pattern. In addition to obtaining medication from nearby pharmacies, we recommend specialized clinic care to help prevent future occurrences."

---

### ✅ Scenario 4: Recurring Pattern + No Pharmacies

**Setup**:
1. Same as Scenario 3
2. BUT ensure no nearby pharmacies exist

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": "recurring pattern detected",
    "pharmacies": [],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "Your diagnosis history shows a recurring pattern. Specialized clinics can provide comprehensive care and help prevent future occurrences."

---

### ✅ Scenario 5: Chronic Condition + Pharmacies Available

**Setup**:
1. Create diagnosis for a chronic condition (e.g., "Diabetes", "Hypertension", "Asthma")
2. Ensure nearby pharmacies exist

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": "matches chronic condition",
    "pharmacies": [/* non-empty array */],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "Your symptoms match a chronic condition. While medication is available at nearby pharmacies, specialized clinics offer long-term management and expert care for ongoing treatment."

---

### ✅ Scenario 6: Chronic Condition + No Pharmacies

**Setup**:
1. Same as Scenario 5
2. BUT ensure no nearby pharmacies exist

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": "matches chronic condition",
    "pharmacies": [],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "Your symptoms match a chronic condition. Specialized clinics offer long-term management and expert care for chronic conditions."

---

### ✅ Scenario 7: No Pharmacy Found

**Setup**:
1. Create diagnosis with prescriptions
2. Ensure NO nearby pharmacies exist in the location

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": "no pharmacy found with medications",
    "pharmacies": [],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "No nearby pharmacies were found with the prescribed medications. We recommend visiting these specialized clinics for alternative treatment options."

---

### ✅ Scenario 8: Default Case + Pharmacies Available

**Setup**:
1. Create a regular diagnosis (not persistent, recurring, or chronic)
2. Include prescriptions
3. Ensure nearby pharmacies exist

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": null, // or any other reason
    "pharmacies": [/* non-empty array */],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "Based on your diagnosis, medication is available at nearby pharmacies. We also recommend consulting with these specialized clinics for comprehensive care and expert medical guidance."

---

### ✅ Scenario 9: Default Case + No Pharmacies

**Setup**:
1. Create a regular diagnosis
2. No prescriptions or no nearby pharmacies

**Expected Backend Response**:
```json
{
  "recommendations": {
    "clinicRecommendationReason": null,
    "pharmacies": [],
    "clinics": [/* array of clinics */]
  }
}
```

**Expected Message**:
> "Based on your diagnosis, we recommend consulting with these specialized clinics for comprehensive care."

---

## Visual Verification

For each test, verify:

1. **Message Location**: Blue info box appears above clinic cards
2. **Message Icon**: Info icon (ℹ️) on the left
3. **Message Text**: Matches expected message for the scenario
4. **Pharmacy Section**: 
   - Shows pharmacies when available
   - Shows "No nearby pharmacies" when empty
5. **Clinic Section**: Shows recommended clinics below the message

---

## Quick Test Commands

### View Backend Logs
```bash
# Check what clinicRecommendationReason was sent
# Look for "GET /diagnosis/:id" in backend console
```

### Debug in Flutter
```dart
// Add this in diagnosis_result_page.dart initState or _extractData
print('Diagnosis has pharmacies: ${_diagnosis?.hasPharmacies}');
print('Clinic reason: ${_diagnosis?.recommendations?.clinicRecommendationReason}');
```

---

## Troubleshooting

### Message Not Changing
1. **Check backend response**: Verify `clinicRecommendationReason` field
2. **Check pharmacies array**: Ensure it's empty/non-empty as expected
3. **Full restart**: Stop and restart Flutter app (hot reload may not work)

### Wrong Message Displayed
1. **Check reason keywords**: Method looks for "persistent", "recurring", "chronic", "no pharmacy"
2. **Case insensitive**: Method uses `.toLowerCase()` for comparison
3. **Check hasPharmacies**: Verify `_diagnosis?.hasPharmacies` returns correct boolean

### Clinics Not Showing
1. Ensure backend returns `clinics` array in recommendations
2. Check if clinics exist in database with valid lat/lng
3. Verify location permissions are granted in app

---

## Test Matrix

| # | Disease Type | Has Pharmacies | Expected Message Theme |
|---|--------------|----------------|------------------------|
| 1 | Persistent   | ✅ Yes         | "...While pharmacies available...also clinic..." |
| 2 | Persistent   | ❌ No          | "...recommend clinic for evaluation..." |
| 3 | Recurring    | ✅ Yes         | "...In addition to pharmacies...also clinic..." |
| 4 | Recurring    | ❌ No          | "...Clinics provide comprehensive care..." |
| 5 | Chronic      | ✅ Yes         | "...medication available...also long-term care..." |
| 6 | Chronic      | ❌ No          | "...Clinics offer long-term management..." |
| 7 | No Pharmacy  | ❌ No          | "No pharmacies found...visit clinics..." |
| 8 | Default      | ✅ Yes         | "...medication available...also consult clinics..." |
| 9 | Default      | ❌ No          | "...recommend consulting clinics..." |

---

## Success Criteria

✅ All 9 scenarios display correct messages
✅ Messages change dynamically based on pharmacy availability
✅ Messages reflect disease pattern (persistent/recurring/chronic)
✅ UI displays properly with proper formatting and icons
✅ No errors in console or app crashes

---

## Reporting Issues

If any scenario fails, please provide:
1. Scenario number that failed
2. Expected message vs actual message
3. Backend response (from network logs)
4. Screenshots of the UI
5. Console logs from Flutter app

---

## Next Steps After Testing

Once all scenarios pass:
1. ✅ Mark feature as production-ready
2. 📝 Update user documentation
3. 🚀 Deploy to production
4. 📊 Monitor user feedback
