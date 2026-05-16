# Pharmacy Recommendation Logic - Detailed Explanation

## Question 1: Does pharmacy need ALL prescribed medicines or SOME?

### Answer: **SOME (at least ONE medicine)**

### How It Works:

The current implementation searches for pharmacies that have **AT LEAST ONE** of the prescribed medicines, not all of them.

#### Step-by-Step Process:

1. **Extract all prescribed medicines**
   ```
   Example: Patient prescribed ["Paracetamol", "Amoxicillin", "Ibuprofen"]
   ```

2. **Search for EACH medicine separately**
   ```
   Search 1: Find pharmacies with "Paracetamol"
   Search 2: Find pharmacies with "Amoxicillin"  
   Search 3: Find pharmacies with "Ibuprofen"
   ```

3. **Combine all results**
   ```
   - Pharmacy A has Paracetamol ✓
   - Pharmacy B has Paracetamol ✓ and Amoxicillin ✓
   - Pharmacy C has Ibuprofen ✓
   - Pharmacy D has all three ✓✓✓
   
   ALL FOUR pharmacies will be recommended!
   ```

4. **Remove duplicates**
   - If Pharmacy B appears in both Paracetamol and Amoxicillin searches, it's only shown once
   - The pharmacy card will show which medicines it has available

5. **Sort by distance**
   - Closest pharmacies appear first

### Code Evidence:

**File**: `ai_health_companion/lib/features/diagnosis/presentation/pages/diagnosis_page.dart` (lines 314-332)

```dart
// Search for each medicine
for (final medicineName in medicineNames) {
  final pharmacies = await diagnosisService.findNearbyPharmacies(
    latitude: position.latitude,
    longitude: position.longitude,
    medicineName: medicineName,  // Searches ONE medicine at a time
    radius: 50,
  );
  nearbyPharmacies.addAll(pharmacies);  // Adds ALL results
}

// Remove duplicates by pharmacy ID
final uniquePharmacies = <String, NearbyPharmacy>{};
for (final pharmacy in nearbyPharmacies) {
  uniquePharmacies[pharmacy.id] = pharmacy;
}
```

### Backend Logic:

**File**: `ai_health_companion_backend/src/controllers/pharmacy-manager.controller.ts` (lines 327-332)

```typescript
.innerJoinAndSelect(
    'p.medicines', 'm',
    'LOWER(m.medicationName) LIKE :med OR LOWER(m.genericName) LIKE :med',
    { med: `%${String(medicineName).toLowerCase()}%` }
)
.where('p.isActive = true')
.andWhere('m.isAvailable = true')
```

This searches for pharmacies that have **ANY medicine matching the name** (medication name OR generic name).

---

## Question 2: How many pharmacies are recommended (max)?

### Answer: **Maximum 10 pharmacies PER MEDICINE**

### Detailed Breakdown:

#### Backend Limit (Per Medicine Search):
**File**: `ai_health_companion_backend/src/controllers/pharmacy-manager.controller.ts` (line 352)

```typescript
.orderBy('distance_km', 'ASC')
.limit(10)  // ← Maximum 10 pharmacies per medicine
.getMany();
```

Each medicine search returns **up to 10 pharmacies**.

#### Frontend Aggregation:
**File**: `ai_health_companion/lib/features/diagnosis/presentation/pages/diagnosis_page.dart`

The frontend:
1. Searches for each medicine (max 10 results each)
2. Combines all results
3. Removes duplicates
4. Sorts by distance
5. Shows **ALL unique pharmacies** (no additional limit)

### Example Scenarios:

#### Scenario 1: Single Medicine Prescribed
```
Prescribed: ["Paracetamol"]

Search Results:
- Paracetamol search → 10 pharmacies

Total Recommended: 10 pharmacies
```

#### Scenario 2: Two Medicines, No Overlap
```
Prescribed: ["Paracetamol", "Amoxicillin"]

Search Results:
- Paracetamol search → 10 pharmacies (A, B, C, D, E, F, G, H, I, J)
- Amoxicillin search → 10 pharmacies (K, L, M, N, O, P, Q, R, S, T)

Total Recommended: 20 pharmacies (all unique)
```

#### Scenario 3: Two Medicines, Some Overlap
```
Prescribed: ["Paracetamol", "Amoxicillin"]

Search Results:
- Paracetamol search → 10 pharmacies (A, B, C, D, E, F, G, H, I, J)
- Amoxicillin search → 10 pharmacies (A, B, C, K, L, M, N, O, P, Q)

After removing duplicates:
- Unique pharmacies: A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q

Total Recommended: 17 pharmacies
```

#### Scenario 4: Three Medicines
```
Prescribed: ["Paracetamol", "Amoxicillin", "Ibuprofen"]

Maximum possible: 30 pharmacies (if no overlap)
Typical: 15-25 pharmacies (with some overlap)
```

### Practical Limits:

In reality, the number of recommended pharmacies depends on:
1. **Number of prescribed medicines** (more medicines = potentially more pharmacies)
2. **Pharmacy inventory overlap** (pharmacies with multiple medicines appear once)
3. **Geographic distribution** (50 km radius limit)
4. **Stock availability** (only shows pharmacies with medicines in stock)

### Current Implementation Summary:

| Factor | Limit |
|--------|-------|
| **Per medicine search** | 10 pharmacies max |
| **Search radius** | 50 km |
| **Total pharmacies shown** | No hard limit (depends on medicine count and overlap) |
| **Typical range** | 5-20 pharmacies |
| **Display order** | Sorted by distance (closest first) |

---

## Pros and Cons of Current Approach

### ✅ Pros:
1. **More options for patients** - Shows all pharmacies with at least one medicine
2. **Flexible** - Patient can visit multiple pharmacies if needed
3. **Transparent** - Shows exactly which medicines each pharmacy has
4. **Distance-sorted** - Closest pharmacies appear first

### ⚠️ Potential Issues:
1. **Too many results** - Could show 20+ pharmacies if many medicines prescribed
2. **Patient confusion** - May need to visit multiple pharmacies to get all medicines
3. **No prioritization** - Doesn't prioritize pharmacies with ALL medicines

---

## Recommendations for Improvement

### Option 1: Prioritize Pharmacies with More Medicines
```dart
// Sort by: 1) Number of medicines available, 2) Distance
nearbyPharmacies.sort((a, b) {
  final countA = a.medicines.length;
  final countB = b.medicines.length;
  
  if (countA != countB) {
    return countB.compareTo(countA); // More medicines first
  }
  
  final distA = a.distance ?? double.infinity;
  final distB = b.distance ?? double.infinity;
  return distA.compareTo(distB); // Then by distance
});
```

### Option 2: Add "Complete Pharmacy" Badge
Show a badge for pharmacies that have ALL prescribed medicines:
```dart
if (pharmacy.medicines.length == totalPrescribedMedicines) {
  // Show "✓ Has all medicines" badge
}
```

### Option 3: Limit Total Results
Add a limit to prevent overwhelming the user:
```dart
nearbyPharmacies = uniquePharmacies.values.take(15).toList();
```

### Option 4: Filter by Completeness
Add a toggle to show only pharmacies with ALL medicines:
```dart
// Option to filter
if (showOnlyCompletePharmacies) {
  nearbyPharmacies = nearbyPharmacies.where((p) => 
    p.medicines.length == totalPrescribedMedicines
  ).toList();
}
```

---

## Summary

### Current Behavior:

1. **Pharmacy Requirement**: Shows pharmacies with **AT LEAST ONE** prescribed medicine (not all)
2. **Maximum Limit**: **10 pharmacies per medicine** from backend, but frontend can show more after combining results
3. **Typical Result**: 5-20 pharmacies depending on:
   - Number of prescribed medicines
   - Pharmacy inventory overlap
   - Geographic distribution

### User Experience:

**Good**: 
- Gives patients many options
- Shows exactly which medicines are available where
- Sorted by distance for convenience

**Could be better**:
- May show too many pharmacies
- Doesn't prioritize pharmacies with ALL medicines
- Patient might need to visit multiple pharmacies

### Recommendation:
Consider adding a **"Has all medicines"** indicator or sorting priority to help users find pharmacies where they can get everything in one visit.

---

**Last Updated**: May 16, 2026
