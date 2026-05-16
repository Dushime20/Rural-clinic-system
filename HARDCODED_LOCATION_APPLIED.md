# TEMPORARY FIX: Hardcoded Rwanda Location ✅

## Problem
The emulator location cache is extremely persistent. Even after rebuilding, the app keeps getting California location.

## Solution Applied
**Temporarily hardcoded Rwanda location** in the app so you can test the pharmacy feature immediately.

---

## What I Did

**File**: `ai_health_companion/lib/core/services/location_service.dart`

**Added**: Hardcoded Rwanda location at the start of `getCurrentLocation()`:

```dart
return Position(
  latitude: -1.9555,  // Kigali, Rwanda
  longitude: 30.0639,
  // ... other fields
);
```

This bypasses the emulator location completely and forces the app to use Rwanda coordinates.

---

## Next Steps

### 1. Rebuild and Run
```bash
flutter run
```

### 2. Complete a Diagnosis

### 3. Check Output

You should now see:

**Flutter Console**:
```
⚠️ USING HARDCODED RWANDA LOCATION FOR TESTING
⚠️ Location: -1.9555, 30.0639 (Kigali, Rwanda)

═══ PHARMACY SEARCH DEBUG ═══
📍 Location: -1.9555, 30.0639  ← Rwanda!
💊 Prescribed medicines: [Antibiotics]
🔍 Searching for: "Antibiotics"
   ✅ Found: 1 pharmacies  ← Your pharmacy found!
📊 FINAL RESULTS:
   Total unique pharmacies: 1
   ✅ Pharmacies to display:
      • Your Pharmacy Name (1/1 medicines) ✓ HAS ALL
═══ END PHARMACY SEARCH ═══
```

**Backend Console**:
```
═══ PHARMACY SEARCH REQUEST ═══
📍 Location: -1.9555, 30.0639  ← Rwanda!
💊 Medicine: Antibiotics
✅ Found 1 pharmacies
📍 Pharmacies found:
   1. Your Pharmacy Name - X.X km (1 medicines)
═══ END PHARMACY SEARCH ═══
```

**Result Page**:
- ✅ Pharmacy card appears
- ✅ "Has all medicines" badge (if pharmacy has all prescribed medicines)
- ✅ Medicine prices and stock levels
- ✅ Call and Navigate buttons

---

## This is TEMPORARY!

### To Remove Hardcode Later:

1. **Uninstall app completely**:
   ```bash
   adb uninstall com.ruralclinic.healthcompanion.ai_health_companion
   ```

2. **Set emulator location** to Kigali BEFORE reinstalling

3. **Edit `location_service.dart`**:
   - Delete the hardcoded return statement
   - Uncomment the original code (marked with `/* ORIGINAL CODE */`)

4. **Rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## Why This Works

```
Before (Broken):
App → Geolocator → Emulator → Cached California location

After (Temporary Fix):
App → Hardcoded Rwanda location → Works!
```

This bypasses the entire location system and just returns Rwanda coordinates directly.

---

## Summary

✅ **Immediate fix**: Hardcoded Rwanda location  
✅ **Pharmacy search will now work**  
✅ **You can test the feature immediately**  
⚠️ **Remember**: This is temporary - remove hardcode later  

---

**Run the app now and test!** The pharmacies should appear! 🎉

**Status**: ✅ TEMPORARY FIX APPLIED - Ready to test  
**Last Updated**: May 16, 2026
