# Emulator Location Setup Guide

## Problem
```
LocationService: Error getting location: TimeoutException after 0:00:10.000000
📍 Location: null, null
❌ Skipped: Location not available
```

**Cause**: Android emulator doesn't have real GPS, so location requests timeout.

---

## Solution: Set Emulator Location

### Method 1: Using Extended Controls (Recommended)

1. **Open Extended Controls**
   - Click the **three dots (⋮)** on the emulator toolbar
   - Or press `Ctrl + Shift + P` (Windows/Linux) or `Cmd + Shift + P` (Mac)

2. **Go to Location Tab**
   - Click **"Location"** in the left sidebar

3. **Set Kigali Location**
   - **Latitude**: `-1.9441`
   - **Longitude**: `30.0619`
   - Click **"Send"** button

4. **Verify Location**
   - The location should now be set
   - Run your app and complete a diagnosis

### Method 2: Using Command Line

```bash
# Connect to emulator
adb -s emulator-5554 emu geo fix 30.0619 -1.9441

# Note: longitude comes first, then latitude
```

### Method 3: Using Google Maps in Emulator

1. Open **Google Maps** app in emulator
2. Search for **"Kigali, Rwanda"**
3. This will set the emulator location
4. Run your app

---

## Kigali Test Locations

Use these coordinates for testing:

| Location | Latitude | Longitude | Description |
|----------|----------|-----------|-------------|
| **Kigali City Center** | -1.9441 | 30.0619 | Downtown Kigali |
| **Kigali Airport** | -1.9686 | 30.1395 | Kigali International Airport |
| **Nyarugenge** | -1.9536 | 30.0606 | Nyarugenge District |
| **Gasabo** | -1.9167 | 30.1167 | Gasabo District |
| **Kicukiro** | -1.9833 | 30.1000 | Kicukiro District |

---

## Testing on Real Device

If using a real Android device:

1. **Enable Developer Options**
   - Go to: Settings → About Phone
   - Tap "Build Number" 7 times

2. **Enable Mock Locations**
   - Go to: Settings → Developer Options
   - Enable "Allow mock locations"

3. **Enable GPS**
   - Go to: Settings → Location
   - Turn on Location
   - Set to "High accuracy" mode

4. **Grant App Permission**
   - Go to: Settings → Apps → AI Health Companion → Permissions
   - Set Location to "Allow only while using the app"

---

## Fixes Applied

### 1. ✅ Improved Location Service

**File**: `ai_health_companion/lib/core/services/location_service.dart`

**Changes**:
- **Tries last known location first** (faster, no GPS needed)
- **Increased timeout** from 10s to 30s
- **Reduced accuracy** from high to medium (faster GPS lock)
- **Better error messages** with solutions

**New behavior**:
```dart
// 1. Try last known location (instant)
final lastPosition = await Geolocator.getLastKnownPosition();

// 2. If no last location, get current position (30s timeout)
final position = await Geolocator.getCurrentPosition(
  desiredAccuracy: LocationAccuracy.medium,
  timeLimit: const Duration(seconds: 30),
);
```

### 2. ✅ Added Backend Logging

**File**: `ai_health_companion_backend/src/controllers/pharmacy-manager.controller.ts`

**Backend will now log**:
```
═══ PHARMACY SEARCH REQUEST ═══
📍 Location: -1.9441, 30.0619
💊 Medicine: Paracetamol
📏 Radius: 50 km
🔍 Searching for pharmacies with "Paracetamol"...
✅ Found 3 pharmacies
📍 Pharmacies found:
   1. Pharmacy ABC - 2.3 km (2 medicines)
   2. Pharmacy XYZ - 4.7 km (1 medicines)
   3. Pharmacy 123 - 8.1 km (1 medicines)
═══ END PHARMACY SEARCH ═══
```

Or if no pharmacies found:
```
⚠️ No pharmacies found!
   Possible reasons:
   1. No pharmacies within radius
   2. Medicine name mismatch
   3. No active pharmacies
   4. Medicine not available in any pharmacy
```

---

## Testing Steps

### 1. Set Emulator Location
- Open emulator extended controls
- Set location to Kigali: `-1.9441, 30.0619`
- Click "Send"

### 2. Rebuild and Run App
```bash
cd ai_health_companion
flutter clean
flutter pub get
flutter run
```

### 3. Complete a Diagnosis
- Select a patient
- Enter symptoms
- Complete diagnosis

### 4. Check Logs

**Flutter Console** should show:
```
═══ PHARMACY SEARCH DEBUG ═══
📍 Location: -1.9441, 30.0619  ← Location available!
💊 Prescribed medicines: [Paracetamol]

🔍 Searching for: "Paracetamol"
   ✅ Found: 3 pharmacies
   
📊 FINAL RESULTS:
   Total unique pharmacies: 3
═══ END PHARMACY SEARCH ═══
```

**Backend Console** should show:
```
═══ PHARMACY SEARCH REQUEST ═══
📍 Location: -1.9441, 30.0619
💊 Medicine: Paracetamol
✅ Found 3 pharmacies
═══ END PHARMACY SEARCH ═══
```

---

## If Still No Pharmacies After Setting Location

### Check Database

```sql
-- 1. Check if any active pharmacies exist
SELECT id, name, "isActive", latitude, longitude 
FROM pharmacy 
WHERE "isActive" = true;

-- 2. Check if medicines are available
SELECT 
  p.name as pharmacy_name,
  pm."medicationName",
  pm."genericName",
  pm."isAvailable",
  pm."stockQuantity"
FROM pharmacy_medicine pm
JOIN pharmacy p ON pm."pharmacyId" = p.id
WHERE pm."isAvailable" = true
  AND p."isActive" = true;

-- 3. Calculate distance from test location to pharmacies
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
WHERE "isActive" = true
ORDER BY distance_km;
```

### Add Test Pharmacy

If no pharmacies exist, add a test one:

```sql
-- Insert test pharmacy in Kigali
INSERT INTO pharmacy (
  id, name, address, city, district, 
  latitude, longitude, "phoneNumber", 
  "isActive", "createdAt", "updatedAt"
) VALUES (
  gen_random_uuid(),
  'Test Pharmacy Kigali',
  'KN 5 Ave',
  'Kigali',
  'Gasabo',
  -1.9500,  -- Near Kigali center
  30.0700,
  '+250788123456',
  true,
  NOW(),
  NOW()
) RETURNING id;

-- Add test medicine (use the pharmacy ID from above)
INSERT INTO pharmacy_medicine (
  id, "pharmacyId", "medicationName", "genericName",
  strength, form, price, currency,
  "stockQuantity", "isAvailable",
  "createdAt", "updatedAt"
) VALUES (
  gen_random_uuid(),
  '<pharmacy-id-from-above>',
  'Paracetamol',
  'Paracetamol',
  '500mg',
  'Tablet',
  1500,
  'RWF',
  100,
  true,
  NOW(),
  NOW()
);
```

---

## Summary

✅ **Fixed**: Location service now tries last known location first  
✅ **Fixed**: Increased timeout from 10s to 30s  
✅ **Fixed**: Reduced accuracy requirement (faster GPS lock)  
✅ **Added**: Comprehensive backend logging  
✅ **Added**: Emulator location setup guide  

**Next Steps**:
1. **Set emulator location** to Kigali coordinates
2. **Rebuild app** (`flutter clean` then `flutter run`)
3. **Complete diagnosis** and check both Flutter and backend logs
4. **Share logs** if still not working

---

**Status**: ✅ READY FOR TESTING  
**Last Updated**: May 16, 2026
