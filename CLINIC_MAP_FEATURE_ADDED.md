# Clinic Profile Interactive Map Feature

## Overview
Added interactive map functionality to the clinic profile page, matching the pharmacy profile implementation. Clinics can now:
- Click on the map to set their exact location
- Use GPS detection to auto-fill coordinates
- See a visual marker of their location
- Get automatic lat/lng updates when clicking the map

---

## Changes Made

### 1. Updated Profile Page (`clinic_dashboard/src/pages/Profile.tsx`)

**New Imports**:
```typescript
import { MapContainer, TileLayer, Marker, useMapEvents, useMap } from 'react-leaflet';
import L from 'leaflet';
import { Navigation, Info } from 'lucide-react'; // Added icons
```

**New State Variables**:
```typescript
const [gpsLoading, setGpsLoading] = useState(false);
const [markerPos, setMarkerPos] = useState<[number, number] | null>(null);
```

**New Helper Components**:
- `MapViewUpdater` - Syncs map view when marker position changes
- `MapClickHandler` - Listens for map clicks and updates coordinates

**New Functions**:
- `handleMapClick(lat, lng)` - Updates coordinates when map is clicked
- `detectLocation()` - Uses browser GPS to auto-detect location

**New UI Elements**:
- Interactive map (shown only in edit mode)
- "Detect My Location" button
- Blue info card explaining how to use the map
- Auto-updating lat/lng fields

---

## Required Dependencies

The following packages need to be installed in the clinic dashboard:

```bash
cd clinic_dashboard
npm install leaflet@^1.9.4 react-leaflet@^4.2.1 @types/leaflet@^1.9.8
```

### Package Details:
- **leaflet** (^1.9.4) - Open-source JavaScript library for interactive maps
- **react-leaflet** (^4.2.1) - React components for Leaflet maps
- **@types/leaflet** (^1.9.8) - TypeScript type definitions

---

## Installation Instructions

### Step 1: Install Dependencies
```bash
# Navigate to clinic dashboard directory
cd clinic_dashboard

# Install Leaflet packages
npm install leaflet@^1.9.4 react-leaflet@^4.2.1 @types/leaflet@^1.9.8
```

### Step 2: Restart Dev Server
```bash
# Stop the current dev server (Ctrl+C)
# Then restart it
npm run dev
```

### Step 3: Verify Installation
1. Open browser to `http://localhost:5175`
2. Login as clinic user
3. Navigate to Profile page
4. Click "Edit Profile"
5. Map should appear in the Location section

---

## Features

### 1. Interactive Map
- **OpenStreetMap** tiles for detailed street view
- **Click anywhere** on map to set clinic location
- **Zoom and pan** to find exact location
- **Marker** shows current selected position
- **Scroll wheel zoom** enabled

### 2. GPS Detection
- **"Detect My Location" button** uses browser geolocation API
- **Auto-fills** latitude and longitude fields
- **Centers map** on detected location
- **Loading indicator** while detecting
- **Error handling** if GPS unavailable or permission denied

### 3. Manual Input
- **Lat/Lng fields** still editable manually
- **Auto-synced** with map marker
- **Validation** ensures coordinates are within valid ranges
  - Latitude: -90 to 90
  - Longitude: -180 to 180

### 4. User Experience
- **Map only shown in edit mode** - cleaner view when not editing
- **Blue info card** explains how to use the map
- **Success toast** when location selected from map
- **Responsive design** - works on mobile and desktop

---

## How It Works

### Edit Mode Activated:
1. User clicks "Edit Profile"
2. Map appears in Location section
3. Map centers on current clinic location (if set) or Kigali default
4. User can:
   - Click map to set new location
   - Click "Detect My Location" to use GPS
   - Manually type lat/lng

### Map Click:
1. User clicks anywhere on map
2. `handleMapClick` function triggered
3. Lat/lng extracted from click event
4. Coordinates formatted to 7 decimal places
5. Form data updated
6. Marker moves to new position
7. Success toast shown

### GPS Detection:
1. User clicks "Detect My Location"
2. Browser requests location permission (if first time)
3. `navigator.geolocation.getCurrentPosition()` called
4. GPS coordinates retrieved
5. Form data updated
6. Map centers on new position
7. Marker updates
8. Success toast shown

### Save:
1. User clicks "Save Changes"
2. Form validates coordinates
3. API called with updated data
4. Profile updated in database
5. Edit mode exits
6. Map hidden

---

## Default Values

**Default Map Center**: Kigali, Rwanda (`-1.9441, 30.0619`)
**Default Zoom Level**: 13 (city level)
**Coordinate Precision**: 7 decimal places (~1.1 cm accuracy)

---

## Comparison: Before vs After

### Before (Manual Entry Only):
```
Location Section:
├── Address input
├── City, District, Country inputs
└── Latitude, Longitude inputs (manual typing only)
```

**Problems**:
- Hard to know exact lat/lng
- Easy to make typos
- No visual feedback
- Tedious to find coordinates

### After (Interactive Map):
```
Location Section (Edit Mode):
├── Address input
├── City, District, Country inputs
├── Interactive Map
│   ├── "Detect My Location" button
│   ├── Info card with instructions
│   ├── OpenStreetMap view
│   ├── Click-to-place marker
│   └── Zoom/pan controls
└── Latitude, Longitude inputs (auto-filled from map)
```

**Benefits**:
- ✅ Visual location selection
- ✅ GPS auto-detection
- ✅ Click to place marker
- ✅ Auto-fills coordinates
- ✅ Prevents typos
- ✅ Easy to use
- ✅ Accurate placement

---

## Browser Compatibility

### GPS Detection Requirements:
- **HTTPS required** for production (localhost works on HTTP)
- **User permission** required for location access
- **Browser support**: All modern browsers (Chrome, Firefox, Safari, Edge)

### Map Rendering:
- **JavaScript enabled** required
- **Canvas support** required (all modern browsers)
- **Works on mobile** devices

---

## Security Considerations

### GPS Permission:
- Browser requests user permission before accessing location
- User can deny permission - fallback to manual/map click entry
- Permission remembered per-origin (domain)

### HTTPS:
- GPS detection requires HTTPS in production
- Localhost exempted (works on HTTP for development)
- Ensure production deployment uses HTTPS

### Data Privacy:
- Coordinates only saved when user clicks "Save Changes"
- No automatic location tracking
- User fully controls what data is submitted

---

## Testing Checklist

### Installation Testing:
- [ ] Leaflet packages installed successfully
- [ ] No console errors about missing modules
- [ ] Dev server starts without errors
- [ ] TypeScript compiles without errors

### Map Display Testing:
- [ ] Map loads in edit mode
- [ ] Map hidden when not editing
- [ ] OpenStreetMap tiles load correctly
- [ ] Map centered on clinic location (or default Kigali)
- [ ] Zoom controls work
- [ ] Pan (drag) works

### GPS Detection Testing:
- [ ] "Detect My Location" button visible
- [ ] Click triggers browser permission request (first time)
- [ ] After permission granted, coordinates auto-fill
- [ ] Map centers on detected location
- [ ] Marker appears at detected location
- [ ] Success toast shown
- [ ] Loading indicator works
- [ ] Error handling works if permission denied

### Map Click Testing:
- [ ] Click anywhere on map
- [ ] Marker moves to click location
- [ ] Lat/lng fields update automatically
- [ ] Success toast shown
- [ ] Coordinates formatted correctly (7 decimals)

### Manual Input Testing:
- [ ] Can still type coordinates manually
- [ ] Marker updates when typing valid coordinates
- [ ] Invalid coordinates show error on save

### Save Testing:
- [ ] Save button works with map-selected location
- [ ] Coordinates saved to database
- [ ] Profile updates successfully
- [ ] Map hidden after save (exits edit mode)
- [ ] Coordinates persist after page refresh

### Mobile Testing:
- [ ] Map displays on mobile browsers
- [ ] Touch to select location works
- [ ] GPS button works on mobile
- [ ] Responsive layout

---

## Troubleshooting

### Issue: Map not loading
**Cause**: Leaflet packages not installed
**Solution**: Run `npm install leaflet@^1.9.4 react-leaflet@^4.2.1 @types/leaflet@^1.9.8`

### Issue: Marker icons not showing
**Cause**: Leaflet default icon paths not configured
**Solution**: Already fixed in code with icon URL merging

### Issue: GPS not working
**Possible Causes**:
1. Browser permission denied → Re-grant permission in browser settings
2. HTTPS required (production) → Ensure site uses HTTPS
3. Browser doesn't support geolocation → Use map click instead

### Issue: Map doesn't center on click
**Cause**: `MapViewUpdater` component not working
**Solution**: Already implemented - check browser console for errors

### Issue: Coordinates not syncing with map
**Cause**: `useEffect` hook not triggering
**Solution**: Verify `formData.latitude` and `formData.longitude` are updating

---

## Future Enhancements

### Potential Additions:
1. **Geocoding** - Convert address to coordinates automatically
2. **Reverse Geocoding** - Show address when clicking map
3. **Radius Circle** - Show clinic service area
4. **Multiple Maps** - Show clinic location on dashboard too
5. **Custom Marker Icon** - Clinic-specific icon instead of default pin
6. **Search Box** - Search for locations by name
7. **Nearby Clinics** - Show other clinics on map
8. **Street View** - Google Street View integration

---

## Related Files

### Modified:
- `clinic_dashboard/src/pages/Profile.tsx` - Added map feature

### New Dependencies (to install):
- `leaflet@^1.9.4`
- `react-leaflet@^4.2.1`
- `@types/leaflet@^1.9.8`

### Reference Implementation:
- `admin_dashboard/src/pages/pharmacy/PharmacyProfile.tsx` - Pharmacy map (template)

---

## Documentation References

- Leaflet Docs: https://leafletjs.com/
- React Leaflet Docs: https://react-leaflet.js.org/
- OpenStreetMap: https://www.openstreetmap.org/

---

**Feature Added**: June 10, 2026
**Status**: ✅ Code Complete, Pending Package Installation
**Next Step**: Install dependencies and test
