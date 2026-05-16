# Fix: Emulator Location Not Updating

## Problem
You set emulator location to Kigali (`-1.9555, 30.0639`) but the app still gets California location (`37.4219983, -122.084`).

## Root Cause
The app is using **last known location** from before you set the emulator location. The `getLastKnownPosition()` returns the old cached California location.

---

## Solution 1: Force Fresh Location (Recommended)

Modify the location service to NOT use last known location during testing.

### Update Location Service:

**File**: `ai_health_companion/lib/core/services/location_service.dart`

**Change this section** (around line 70):

```dart
// COMMENT OUT OR REMOVE THIS SECTION TEMPORARILY:
/*
// Try to get last known location first (faster)
debugPrint('LocationService: Trying last known location...');
try {
  final lastPosition = await Geolocator.getLastKnownPosition();
  if (lastPosition != null) {
    debugPrint(
      'LocationService: ✅ Got last known position: ${lastPosition.latitude}, ${lastPosition.longitude}',
    );
    return lastPosition;
  }
  debugPrint('LocationService: No last known position available');
} catch (e) {
  debugPrint('LocationService: Error getting last known position: $e');
}
*/

// Get current position DIRECTLY (skip last known)
debugPrint('LocationService: Getting FRESH current position (30s timeout)...');
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.medium,
  timeLimit: const Duration(seconds: 30),
);
```

This forces the app to get a FRESH location from the emulator instead of using cached California location.

---

## Solution 2: Clear App Data

Clear the app's cached location data:

### Method A: Uninstall and Reinstall
```bash
# Uninstall app
adb uninstall com.ruralclinic.healthcompanion.ai_health_companion

# Reinstall
flutter run
```

### Method B: Clear App Data in Emulator
1. Open **Settings** in emulator
2. Go to **Apps** → **AI Health Companion**
3. Tap **Storage**
4. Tap **Clear Data** and **Clear Cache**
5. Run app again

---

## Solution 3: Set Location AFTER App Starts

1. **Start the app first**
2. **Then set emulator location** (while app is running)
3. **Complete a diagnosis**

This ensures the app gets the new location, not cached old one.

---

## Solution 4: Use Command Line to Set Location

Sometimes the UI doesn't work properly. Use command line:

```bash
# Set to Kigali (your saved point)
adb -s emulator-5554 emu geo fix 30.0639 -1.9555

# Verify it's set
adb -s emulator-5554 emu geo fix
```

---

## Solution 5: Restart Emulator

1. **Close emulator completely**
2. **Start emulator again**
3. **Set location to Kigali BEFORE starting app**
4. **Then run app**

---

## Quick Test Script

Add this temporary test to verify location:

**File**: `ai_health_companion/lib/features/diagnosis/presentation/pages/diagnosis_page.dart`

Add this at the start of `_submitDiagnosis()`:

```dart
// TEMPORARY TEST - Remove after fixing
debugPrint('🧪 LOCATION TEST START');
final testService = LocationService();

// Clear any cached location
debugPrint('🧪 Getting FRESH location...');
try {
  final freshPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.low,
    timeLimit: const Duration(seconds: 30),
  );
  debugPrint('🧪 Fresh location: ${freshPosition.latitude}, ${freshPosition.longitude}');
  
  if (freshPosition.latitude > 0) {
    debugPrint('🧪 ❌ ERROR: Got positive latitude (Northern hemisphere)');
    debugPrint('🧪 Expected: Negative latitude (Rwanda is in Southern hemisphere)');
    debugPrint('🧪 → Emulator location not set correctly!');
  } else {
    debugPrint('🧪 ✅ Got negative latitude (Southern hemisphere) - Correct!');
  }
} catch (e) {
  debugPrint('🧪 ❌ Error getting fresh location: $e');
}
debugPrint('🧪 LOCATION TEST END');
```

This will tell you if the emulator location is actually being used.

---

## Expected Output After Fix:

```
🧪 LOCATION TEST START
🧪 Getting FRESH location...
🧪 Fresh location: -1.9555, 30.0639
🧪 ✅ Got negative latitude (Southern hemisphere) - Correct!
🧪 LOCATION TEST END

═══ PHARMACY SEARCH DEBUG ═══
📍 Location: -1.9555, 30.0639  ← Rwanda location!
💊 Prescribed medicines: [Antibiotics]
🔍 Searching for: "Antibiotics"
   ✅ Found: 1 pharmacies
═══ END PHARMACY SEARCH ═══
```

Backend should show:
```
📍 Location: -1.9555, 30.0639  ← Rwanda!
💊 Medicine: Antibiotics
✅ Found 1 pharmacies
```

---

## Recommended Steps (In Order):

1. **First**: Comment out the "last known location" code (Solution 1)
2. **Then**: Clear app data (Solution 2)
3. **Then**: Set emulator location to Kigali
4. **Then**: Rebuild and run app
5. **Check**: Console output should show Rwanda coordinates

---

## Why This Happens:

```
Timeline:
1. You ran app BEFORE setting emulator location
   → App cached California location (37.42, -122.08)
   
2. You set emulator to Kigali (-1.9555, 30.0639)
   → Emulator now has correct location
   
3. You run app again
   → App uses CACHED California location (faster)
   → Never asks emulator for fresh location
   
Result: App still thinks it's in California!
```

**Fix**: Force app to get FRESH location, not cached one.

---

**Try Solution 1 first** (comment out last known location code), then rebuild and test!
