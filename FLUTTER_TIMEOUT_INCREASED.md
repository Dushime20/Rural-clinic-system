# Flutter Translation Timeout Increased

## Issue

Translation completed successfully on backend (132.4 seconds), but Flutter showed "translation failed" warning because it timed out at 120 seconds.

**Logs showed:**
```
07:11:21 - Translating prescription 4 of 5
GET /api/v1/diagnosis/.../translate - - ms - -  ← Flutter gave up here (120s)
07:11:33 - Translating prescription 5 of 5
07:11:41 - Translation completed in 132.4s  ← Backend succeeded (132s)
```

## Root Cause

With prescription translation added, reports now have more items:
- **Before:** ~25 items → ~110 seconds
- **After:** 39 items (with 5 prescriptions × 3 fields) → **132 seconds**

**Flutter timeout:** 120 seconds ❌  
**Actual time needed:** 132 seconds ✅

## Solution

Increased Flutter timeout from **120 seconds to 180 seconds** (3 minutes).

### Change Made:
```dart
// Before
receiveTimeout: const Duration(seconds: 120), // 2 minutes

// After
receiveTimeout: const Duration(seconds: 180), // 3 minutes
```

## Translation Time Calculation

| Report Size | Items | Time (3.4s/item) | Timeout Needed |
|-------------|-------|------------------|----------------|
| Small | 20 items | ~68s | 120s OK ✅ |
| Medium | 30 items | ~102s | 120s OK ✅ |
| Large | 40 items | ~136s | 120s FAIL ❌ |
| Large | 40 items | ~136s | **180s OK** ✅ |

**Safety margin:** 180s - 136s = 44 seconds buffer

## Items That Increase Translation Time

### Fixed Sections (Always Present):
- Description: 1 item
- Notes: 0-1 items

### Variable Sections (Depend on Disease):
- Precautions: 3-5 items
- Medications: 3-7 items
- Diet: 3-7 items
- Lifestyle: 0-3 items
- Workout: 5-15 items

### New: Prescriptions (Per Prescription × 3):
- **1 prescription:** 3 items (+10s)
- **3 prescriptions:** 9 items (+30s)
- **5 prescriptions:** 15 items (+51s) ← This caused timeout!

**Worst case:** 50+ items = ~170 seconds  
**180-second timeout** handles this comfortably ✅

## Testing

### Hot Restart Flutter
In Flutter terminal, press **`R`**

### Expected Behavior

**Before (120s timeout):**
- Loading indicator shows
- After 120s: Orange warning appears
- Translation actually completes on backend
- User confused (warning shown but content translated!)

**After (180s timeout):**
- Loading indicator shows for full duration
- Translation completes at ~130s
- Loading disappears, content shows in Kinyarwanda
- NO warning ✅

## Performance Summary

### Current Translation Speed:
- **Average:** 3.4 seconds per item
- **Small report (20 items):** ~70 seconds
- **Medium report (30 items):** ~100 seconds
- **Large report (40 items):** ~135 seconds
- **Max expected (50 items):** ~170 seconds

**180-second timeout** covers all cases with safety margin! ✅

## Files Modified

- ✅ `ai_health_companion/lib/features/diagnosis/presentation/pages/diagnosis_result_page.dart`
  - Changed timeout from 120s to 180s
  - Updated comment to reflect prescription translation time

## Status

🟢 **FIX READY** - Hot restart Flutter to apply

**Action Required:**
1. Hot restart Flutter: Press `R` in terminal
2. Test with diagnosis that has multiple prescriptions
3. Wait up to 2.5 minutes (should complete around 2 minutes)
4. No orange warning should appear

---

## Summary

✅ **Timeout increased:** 120s → 180s  
✅ **Covers worst case:** 50 items (~170s)  
✅ **Safety margin:** 10 seconds  
✅ **No false warnings:** User sees clean loading → content  

**The translation is working perfectly - we just needed more patience!** 🎯
