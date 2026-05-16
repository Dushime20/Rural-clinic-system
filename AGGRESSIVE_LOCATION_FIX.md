# Aggressive Location Fix - Cached Location Won't Clear

## Problem
Even after rebuilding, the app STILL gets California location (`37.4219983, -122.084`).

The cached location is extremely persistent!

---

## SOLUTION: Uninstall App Completely

The only way to clear the cached location is to **completely uninstall the app**.

### Step 1: Uninstall App
```bash
adb uninstall com.ruralclinic.healthcompanion.ai_health_companion
```

### Step 2: Set Emulator Location FIRST
**BEFORE running the app again:**
1. Open emulator Extended Controls (three dots)
2. Go to Location tab
3. Set to Kigali: `-1.9555, 30.0639`
4. Click "Send"

Or use command line:
```bash
adb -s emulator-5554 emu geo fix 30.0639 -1.9555
```

### Step 3: Verify Location is Set
```bash
# This should return the Kigali coordinates
adb -s emulator-5554 emu geo fix
```

### Step 4: Clean and Rebuild
```bash
cd ai_health_companion
flutter clean
flutter pub get
flutter run
```

### Step 5: Grant Location Permission
When app starts, grant location permission.

### Step 6: Complete Diagnosis
The location should now be correct!

---

## Alternative: Hardcode Test Location (Temporary)

If uninstalling doesn't work, temporarily hardcode the location for testing:

**File**: `ai_health_companion/lib/core/services/location_service.dart`

Add this at the START of `getCurrentLocation()`:

```dart
Future<Position?> getCurrentLocation() async {
  // TEMPORARY: Force Rwanda location for testing
  // TODO: Remove this after fixing emulator location issue
  debugPrint('⚠️ USING HARDCODED RWANDA LOCATION FOR TESTING');
  return Position(
    latitude: -1.9555,
    longitude: 30.0639,
    timestamp: DateTime.now(),
    accuracy: 10.0,
    altitude: 1500.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );
  
  // Rest of the code...
```

This will force the app to use Rwanda location regardless of emulator settings.

---

## Why This Keeps Happening

Android caches location data in multiple places:
1. **App's SharedPreferences**
2. **System LocationManager cache**
3. **Google Play Services cache**

Simply rebuilding the app doesn't clear these caches. You MUST uninstall completely.

---

## Expected Output After Fix

```
LocationService: ✅ Got current position: -1.9555, 30.0639

═══ PHARMACY SEARCH DEBUG ═══
📍 Location: -1.9555, 30.0639  ← Rwanda!
💊 Prescribed medicines: [Antibiotics]
🔍 Searching for: "Antibiotics"
   ✅ Found: 1 pharmacies
═══ END PHARMACY SEARCH ═══
```

---

**Try uninstalling the app first, then set emulator location, then reinstall!**
