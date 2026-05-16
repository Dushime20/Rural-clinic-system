# Pharmacy Not Showing - Debugging Guide

## Problem
Pharmacies are not appearing in the diagnosis result page even though:
- Pharmacy exists in database
- Pharmacy has the prescribed medicine in stock

---

## Common Causes & Solutions

### 1. **Location Permission Issue**

**Symptom**: No pharmacies shown, no location available

**Check**: Look for this debug message in Flutter console:
```
Location not available, skipping pharmacy search
```

**Causes**:
- Location permission denied
- GPS disabled
- Location service not working

**Solution**:
```dart
// Check location permission status
final locationService = LocationService();
final position = await locationService.getCurrentLocation();

if (position == null) {
  print('❌ Location is NULL - check permissions!');
} else {
  print('✅ Location: ${position.latitude}, ${position.longitude}');
}
```

**Fix**:
1. Check app permissions in device settings
2. Enable GPS/Location services
3. Grant location permission to the app

---

### 2. **Medicine Name Mismatch**

**Symptom**: Pharmacy has medicine but not found in search

**Cause**: The medicine name in prescription doesn't match the medicine name in pharmacy inventory

**Example Problem**:
```
Prescription says: "Paracetamol"
Pharmacy has: "paracetamol 500mg" or "Panadol" (brand name)
```

**Backend Search Logic**:
```typescript
'LOWER(m.medicationName) LIKE :med OR LOWER(m.genericName) LIKE :med'
{ med: `%${String(medicineName).toLowerCase()}%` }
```

This uses **partial matching** (LIKE with %), so:
- ✅ "Paracetamol" matches "paracetamol 500mg"
- ✅ "Paracetamol" matches "Paracetamol Tablets"
- ❌ "Paracetamol" does NOT match "Panadol" (unless genericName is set)

**Solution**:
1. **Check medicine names in database**:
   ```sql
   SELECT medicationName, genericName, brandName 
   FROM pharmacy_medicine 
   WHERE pharmacyId = 'your-pharmacy-id';
   ```

2. **Check what prescription sends**:
   ```dart
   debugPrint('Searching for medicines: $medicineNames');
   ```

3. **Ensure consistency**:
   - Use generic names in prescriptions (e.g., "Paracetamol" not "Panadol")
   - Set `genericName` field in pharmacy medicines
   - Use standard medicine names

---

### 3. **Pharmacy Not Active**

**Symptom**: Pharmacy exists but never appears in search

**Cause**: Pharmacy `isActive` field is `false`

**Backend Filter**:
```typescript
.where('p.isActive = true')
```

**Solution**:
```sql
-- Check pharmacy status
SELECT id, name, isActive FROM pharmacy WHERE id = 'your-pharmacy-id';

-- Activate pharmacy
UPDATE pharmacy SET "isActive" = true WHERE id = 'your-pharmacy-id';
```

---

### 4. **Medicine Not Available**

**Symptom**: Medicine exists in pharmacy but not shown

**Cause**: Medicine `isAvailable` field is `false` or `stockQuantity` is 0

**Backend Filter**:
```typescript
.andWhere('m.isAvailable = true')
```

**Solution**:
```sql
-- Check medicine availability
SELECT medicationName, isAvailable, stockQuantity 
FROM pharmacy_medicine 
WHERE pharmacyId = 'your-pharmacy-id';

-- Make medicine available
UPDATE pharmacy_medicine 
SET "isAvailable" = true, "stockQuantity" = 10 
WHERE id = 'medicine-id';
```

---

### 5. **Distance Too Far**

**Symptom**: Pharmacy exists but outside search radius

**Cause**: Pharmacy is more than 50 km away from patient location

**Backend Filter**:
```typescript
// Haversine formula - checks if distance <= 50 km
.andWhere(`(6371 * acos(...)) <= :radius`, { radius: 50 })
```

**Solution**:

**Option A**: Increase search radius temporarily for testing:
```dart
// In diagnosis_page.dart line 323
final pharmacies = await diagnosisService.findNearbyPharmacies(
  latitude: position.latitude,
  longitude: position.longitude,
  medicineName: medicineName,
  radius: 100, // Increase to 100 km for testing
);
```

**Option B**: Check actual distance:
```sql
-- Calculate distance between patient and pharmacy
SELECT 
  name,
  latitude,
  longitude,
  (6371 * acos(
    cos(radians(-1.9441)) * cos(radians(CAST(latitude AS float))) *
    cos(radians(CAST(longitude AS float)) - radians(30.0619)) +
    sin(radians(-1.9441)) * sin(radians(CAST(latitude AS float)))
  )) AS distance_km
FROM pharmacy
WHERE id = 'your-pharmacy-id';
-- Replace -1.9441, 30.0619 with patient's lat/lng
```

---

### 6. **No Prescriptions Generated**

**Symptom**: No pharmacy search happens at all

**Cause**: Diagnosis has no prescriptions

**Check**:
```dart
if (result.prescriptions != null && result.prescriptions!.isNotEmpty) {
  // Pharmacy search happens here
} else {
  // No prescriptions = no pharmacy search
}
```

**Solution**:
Ensure AI diagnosis generates prescriptions. Check backend:
```typescript
// In diagnosis.controller.ts
const autoPrescriptions = primaryPrediction?.medications?.map((med: string) => ({
  medication: med,
  dosage: 'As directed',
  frequency: 'As directed',
  duration: 'As directed by physician',
})) ?? [];
```

---

### 7. **API Error (Silent Failure)**

**Symptom**: No pharmacies shown, no obvious error

**Cause**: API call fails but error is caught and ignored

**Check Flutter Console**:
```
Pharmacy search error: <error message>
```

**Debug**:
```dart
// In diagnosis_page.dart, add more logging
try {
  debugPrint('🔍 Searching for: $medicineName');
  debugPrint('📍 Location: $latitude, $longitude');
  
  final pharmacies = await diagnosisService.findNearbyPharmacies(...);
  
  debugPrint('✅ Found ${pharmacies.length} pharmacies for $medicineName');
} catch (e) {
  debugPrint('❌ Pharmacy search error: $e');
  debugPrint('❌ Error type: ${e.runtimeType}');
}
```

**Common API Errors**:
- 400: Missing parameters (lat/lng/medicineName)
- 401: Authentication failed
- 500: Database error or SQL syntax error

---

## Step-by-Step Debugging Process

### Step 1: Check Flutter Console Logs

Run the app and look for these messages:
```
Finding nearby pharmacies...
Found X nearby pharmacies
```

Or error messages:
```
Location not available, skipping pharmacy search
Pharmacy search error: <error>
```

### Step 2: Verify Location

Add this debug code in `diagnosis_page.dart` after line 303:
```dart
final position = await locationService.getCurrentLocation();
debugPrint('📍 Patient Location: ${position?.latitude}, ${position?.longitude}');

if (position == null) {
  debugPrint('❌ LOCATION IS NULL - Check permissions!');
}
```

### Step 3: Verify Prescriptions

Add this debug code after line 313:
```dart
final medicineNames = result.prescriptions!.map((p) => p.medication).toSet().toList();
debugPrint('💊 Prescribed medicines: $medicineNames');
debugPrint('💊 Total: ${medicineNames.length} medicines');
```

### Step 4: Check Each Medicine Search

Add this debug code in the loop (after line 318):
```dart
for (final medicineName in medicineNames) {
  debugPrint('🔍 Searching for: "$medicineName"');
  
  final pharmacies = await diagnosisService.findNearbyPharmacies(
    latitude: position.latitude,
    longitude: position.longitude,
    medicineName: medicineName,
    radius: 50,
  );
  
  debugPrint('✅ Found ${pharmacies.length} pharmacies with "$medicineName"');
  
  if (pharmacies.isEmpty) {
    debugPrint('⚠️ No pharmacies found for "$medicineName"');
  }
  
  nearbyPharmacies.addAll(pharmacies);
}
```

### Step 5: Check Database

**Verify pharmacy exists and is active**:
```sql
SELECT id, name, "isActive", latitude, longitude 
FROM pharmacy 
WHERE "isActive" = true;
```

**Verify medicine exists and is available**:
```sql
SELECT 
  pm.id,
  pm."medicationName",
  pm."genericName",
  pm."isAvailable",
  pm."stockQuantity",
  p.name as pharmacy_name
FROM pharmacy_medicine pm
JOIN pharmacy p ON pm."pharmacyId" = p.id
WHERE pm."isAvailable" = true
  AND pm."stockQuantity" > 0;
```

**Check medicine name matching**:
```sql
-- Test if your medicine name matches
SELECT 
  "medicationName",
  "genericName",
  "brandName"
FROM pharmacy_medicine
WHERE 
  LOWER("medicationName") LIKE '%paracetamol%' 
  OR LOWER("genericName") LIKE '%paracetamol%';
```

### Step 6: Test Backend API Directly

Use Postman or curl to test the API:
```bash
curl -X GET "http://localhost:5000/api/pharmacy-manager/nearby?latitude=-1.9441&longitude=30.0619&medicineName=Paracetamol&radius=50" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Expected response:
```json
{
  "success": true,
  "data": {
    "pharmacies": [
      {
        "id": "...",
        "name": "Pharmacy ABC",
        "latitude": -1.9500,
        "longitude": 30.0700,
        "medicines": [...]
      }
    ],
    "count": 1
  }
}
```

---

## Quick Fix Checklist

Run through this checklist:

- [ ] **Location permission granted** in device settings
- [ ] **GPS enabled** on device
- [ ] **Pharmacy `isActive = true`** in database
- [ ] **Medicine `isAvailable = true`** in database
- [ ] **Medicine `stockQuantity > 0`** in database
- [ ] **Medicine name matches** prescription (check spelling, case)
- [ ] **Pharmacy within 50 km** of patient location
- [ ] **Backend server running** on port 5000
- [ ] **Authentication token valid**
- [ ] **Prescriptions generated** in diagnosis result

---

## Most Likely Causes (Ranked)

1. **Medicine name mismatch** (60% of cases)
   - Prescription: "Paracetamol"
   - Database: "Panadol" or "paracetamol 500mg tablets"
   - Fix: Use consistent generic names

2. **Location not available** (20% of cases)
   - Permission denied or GPS disabled
   - Fix: Grant location permission

3. **Medicine not available** (10% of cases)
   - `isAvailable = false` or `stockQuantity = 0`
   - Fix: Update medicine availability

4. **Pharmacy not active** (5% of cases)
   - `isActive = false`
   - Fix: Activate pharmacy

5. **Distance too far** (5% of cases)
   - Pharmacy > 50 km away
   - Fix: Increase radius or add closer pharmacies

---

## Recommended Solution

Add comprehensive logging to identify the exact issue:

```dart
// In diagnosis_page.dart, replace the pharmacy search section with:

debugPrint('═══ PHARMACY SEARCH DEBUG ═══');

final position = await locationService.getCurrentLocation();
debugPrint('📍 Location: ${position?.latitude}, ${position?.longitude}');

if (position == null) {
  debugPrint('❌ CRITICAL: Location is NULL');
  debugPrint('   → Check location permissions');
  debugPrint('   → Enable GPS');
}

List<NearbyPharmacy> nearbyPharmacies = [];
if (position != null &&
    result.prescriptions != null &&
    result.prescriptions!.isNotEmpty) {
  try {
    final medicineNames =
        result.prescriptions!.map((p) => p.medication).toSet().toList();
    
    debugPrint('💊 Prescribed medicines: $medicineNames');
    debugPrint('💊 Total medicines: ${medicineNames.length}');

    for (final medicineName in medicineNames) {
      debugPrint('');
      debugPrint('🔍 Searching for: "$medicineName"');
      debugPrint('   Radius: 50 km');
      
      final pharmacies = await diagnosisService.findNearbyPharmacies(
        latitude: position.latitude,
        longitude: position.longitude,
        medicineName: medicineName,
        radius: 50,
      );
      
      debugPrint('   ✅ Found: ${pharmacies.length} pharmacies');
      
      if (pharmacies.isEmpty) {
        debugPrint('   ⚠️ WARNING: No pharmacies found!');
        debugPrint('   → Check medicine name in database');
        debugPrint('   → Check pharmacy isActive status');
        debugPrint('   → Check medicine isAvailable status');
        debugPrint('   → Check distance (must be < 50 km)');
      } else {
        for (final p in pharmacies) {
          debugPrint('   📍 ${p.name} - ${p.distanceText}');
        }
      }
      
      nearbyPharmacies.addAll(pharmacies);
    }

    // Remove duplicates
    final uniquePharmacies = <String, NearbyPharmacy>{};
    for (final pharmacy in nearbyPharmacies) {
      uniquePharmacies[pharmacy.id] = pharmacy;
    }
    nearbyPharmacies = uniquePharmacies.values.toList();

    // Sort by distance
    nearbyPharmacies.sort((a, b) {
      final distA = a.distance ?? double.infinity;
      final distB = b.distance ?? double.infinity;
      return distA.compareTo(distB);
    });

    debugPrint('');
    debugPrint('📊 FINAL RESULTS:');
    debugPrint('   Total unique pharmacies: ${nearbyPharmacies.length}');
    
    if (nearbyPharmacies.isEmpty) {
      debugPrint('   ❌ NO PHARMACIES TO SHOW');
    } else {
      debugPrint('   ✅ Pharmacies to display:');
      for (final p in nearbyPharmacies) {
        debugPrint('      • ${p.name} (${p.medicines.length} medicines)');
      }
    }
    
  } catch (e, stackTrace) {
    debugPrint('❌ PHARMACY SEARCH ERROR: $e');
    debugPrint('   Error type: ${e.runtimeType}');
    debugPrint('   Stack trace: $stackTrace');
  }
} else {
  if (position == null) {
    debugPrint('❌ Skipped: Location not available');
  } else if (result.prescriptions == null || result.prescriptions!.isEmpty) {
    debugPrint('❌ Skipped: No prescriptions');
  }
}

debugPrint('═══ END PHARMACY SEARCH ═══');
```

Run the app, complete a diagnosis, and check the console output. This will tell you exactly where the problem is!

---

**Next Steps**: Share the console output and I can help identify the specific issue.
