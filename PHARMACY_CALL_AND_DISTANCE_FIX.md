# Pharmacy Call Button and Distance Display Fix

## Issues Fixed

### 1. Distance Not Showing on Pharmacy Cards
**Problem**: Backend was calculating distance but not returning it in the response.

**Solution**: Modified backend to use `getRawAndEntities()` and map the calculated distance to each pharmacy entity.

**Changes**:
- File: `ai_health_companion_backend/src/controllers/pharmacy-manager.controller.ts`
- Used `getRawAndEntities()` instead of `getMany()` to get both raw SQL results and entities
- Mapped `distance_km` from raw results to each pharmacy entity
- Rounded distance to 1 decimal place for cleaner display

**Result**: Distance now shows in green badge on pharmacy cards (e.g., "5.2 km", "12.8 km")

---

### 2. Call Button Not Opening Phone Dialer
**Problem**: Missing Android permissions and query intents for url_launcher.

**Solution**: Added required permissions and query intents to AndroidManifest.xml.

**Changes**:
- File: `ai_health_companion/android/app/src/main/AndroidManifest.xml`
- Added `CALL_PHONE` permission
- Added query intents for:
  - Phone dialer (`ACTION_DIAL`)
  - Web browser/Maps (`https` and `http` schemes)
  - Geo intent for maps (`geo` scheme)

**Additional Improvements**:
- Added error handling to Call button with try-catch
- Added error handling to Navigate button with try-catch
- Show user-friendly error messages if dialer/maps cannot be opened
- Added debug logging for troubleshooting

---

## Files Modified

1. **Backend**:
   - `ai_health_companion_backend/src/controllers/pharmacy-manager.controller.ts`

2. **Flutter App**:
   - `ai_health_companion/android/app/src/main/AndroidManifest.xml`
   - `ai_health_companion/lib/features/diagnosis/presentation/pages/diagnosis_result_page.dart`

---

## Testing Instructions

### Test Distance Display
1. Run diagnosis with symptoms
2. Check pharmacy cards on result page
3. Verify distance shows in green badge (e.g., "5.2 km")
4. Verify pharmacies are sorted by: 1) number of medicines (more first), 2) distance (closer first)

### Test Call Button
1. Tap "Call" button on pharmacy card
2. Phone dialer should open with pharmacy number pre-filled
3. If error occurs, user-friendly message should appear

### Test Navigate Button
1. Tap "Navigate" button on pharmacy card
2. Google Maps should open with pharmacy location
3. If error occurs, user-friendly message should appear

---

## How It Works

### Distance Calculation
- Backend uses Haversine formula to calculate distance in kilometers
- Formula: `6371 * acos(cos(lat1) * cos(lat2) * cos(lng2 - lng1) + sin(lat1) * sin(lat2))`
- Distance is rounded to 1 decimal place (e.g., 5.234 km → 5.2 km)

### Call Button
- Creates `tel:` URI with pharmacy phone number
- Uses `url_launcher` package to open phone dialer
- Android automatically handles the intent with default dialer app

### Navigate Button
- Creates Google Maps URL with pharmacy GPS coordinates
- Format: `https://maps.google.com/?q=latitude,longitude`
- Opens in external app (Google Maps or browser)
- User gets turn-by-turn directions to pharmacy

---

## Next Steps

1. **Rebuild the app** to apply AndroidManifest changes:
   ```bash
   cd ai_health_companion
   flutter run
   ```

2. **Restart backend** to apply distance mapping:
   ```bash
   cd ai_health_companion_backend
   npm run dev
   ```

3. **Test the features**:
   - Complete a diagnosis
   - Verify distance shows on pharmacy cards
   - Test Call button opens dialer
   - Test Navigate button opens maps

---

## Notes

- Distance is calculated "as the crow flies" (straight line), not driving distance
- Call button uses `ACTION_DIAL` which doesn't require runtime permission
- Navigate button opens Google Maps if installed, otherwise opens in browser
- All pharmacy cards show distance, even if it says "Unknown" (when distance calculation fails)
