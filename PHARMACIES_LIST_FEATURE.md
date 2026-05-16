# Pharmacies List Feature

## Overview
Added a new "Pharmacies" page to the Flutter app that allows Community Health Workers (CHWs) to browse all pharmacies in the system, search for specific ones, and view their details.

## Features

### 1. **Pharmacies List Page**
- Displays all active pharmacies in the system
- Shows pharmacy name, address, phone number, and active status
- Pull-to-refresh to reload pharmacy list
- Search functionality to filter pharmacies by name, address, city, or district
- Tap on any pharmacy card to view full details

### 2. **Search Functionality**
- Real-time search as you type
- Searches across:
  - Pharmacy name
  - Address
  - City
  - District
- Clear button to reset search

### 3. **Pharmacy Details Modal**
- Shows complete pharmacy information:
  - Name and active status
  - Full address
  - Phone number
  - Opening hours (if available)
  - GPS coordinates
- Action buttons:
  - **Call**: Opens phone dialer with pharmacy number
  - **Navigate**: Opens Google Maps with directions

### 4. **Navigation Integration**
- Added "Pharmacies" menu item in the app drawer
- Icon: 🏥 (local_pharmacy)
- Positioned between "Patient Management" and "Analytics"

## Files Created

### New Files
1. **`ai_health_companion/lib/features/pharmacy/presentation/pages/pharmacies_page.dart`**
   - Main pharmacies list page
   - Search functionality
   - Pharmacy details modal
   - Call and Navigate actions

## Files Modified

### Modified Files
1. **`ai_health_companion/lib/shared/widgets/custom_drawer.dart`**
   - Added "Pharmacies" menu item

2. **`ai_health_companion/lib/main.dart`**
   - Added `/pharmacies` route
   - Imported PharmaciesPage

## API Integration

### Endpoint Used
- **GET** `/api/v1/pharmacy-manager/map`
  - Returns all active pharmacies
  - No authentication required (public endpoint)
  - Response includes: id, name, address, latitude, longitude, city, district, phoneNumber, openingHours

### Service Method
- `DiagnosisService.getAllPharmacies()`
  - Already existed in the codebase
  - Returns `List<NearbyPharmacy>`

## User Experience

### Navigation Flow
1. **From Main Menu**:
   - Open drawer → Tap "Pharmacies" → View all pharmacies

2. **Search Pharmacies**:
   - Type in search bar → Results filter in real-time

3. **View Details**:
   - Tap pharmacy card → Modal opens with full details

4. **Take Action**:
   - Tap "Call" → Phone dialer opens
   - Tap "Navigate" → Google Maps opens with directions

### UI Components

#### Pharmacy Card (List View)
```
┌─────────────────────────────────────┐
│ 🏥  Kigali Central Pharmacy    >   │
│     [Active]                        │
│                                     │
│ 📍 KN 4 Ave, Kigali, Rwanda        │
│ 📞 +250788123456                    │
└─────────────────────────────────────┘
```

#### Pharmacy Details Modal
```
┌─────────────────────────────────────┐
│          ━━━━━━━━                   │
│                                     │
│ 🏥  Kigali Central Pharmacy        │
│     [Active]                        │
│                                     │
│ ─────────────────────────────────  │
│                                     │
│ 📍 Address                          │
│    KN 4 Ave, Kigali, Rwanda        │
│                                     │
│ 📞 Phone                            │
│    +250788123456                    │
│                                     │
│ 🕐 Opening Hours                    │
│    Mon-Fri: 8AM-6PM                 │
│                                     │
│ 📍 Coordinates                      │
│    -1.9555, 30.0639                 │
│                                     │
│ ┌──────────┐  ┌──────────────────┐ │
│ │ 📞 Call  │  │ 🧭 Navigate      │ │
│ └──────────┘  └──────────────────┘ │
└─────────────────────────────────────┘
```

## Error Handling

### Loading State
- Shows loading spinner with "Loading pharmacies..." message

### Error State
- Shows error icon and message
- Displays error details
- "Retry" button to reload

### Empty State
- Shows pharmacy icon
- "No pharmacies found" message
- If search active: "Try a different search term"

### Network Errors
- Graceful error handling
- User-friendly error messages
- Retry functionality

## Testing Checklist

- [ ] Pharmacies list loads successfully
- [ ] Search filters pharmacies correctly
- [ ] Pharmacy details modal opens
- [ ] Call button opens phone dialer
- [ ] Navigate button opens Google Maps
- [ ] Pull-to-refresh reloads data
- [ ] Error states display correctly
- [ ] Empty states display correctly
- [ ] Loading states display correctly
- [ ] Search clear button works
- [ ] Back navigation works

## Benefits for CHWs

1. **Quick Access**: Browse all pharmacies without needing a diagnosis
2. **Search Capability**: Find specific pharmacies by name or location
3. **Complete Information**: View all pharmacy details in one place
4. **Direct Actions**: Call or navigate to any pharmacy with one tap
5. **Offline Reference**: Can view cached pharmacy list when offline

## Future Enhancements

### Potential Improvements
1. **Filter by District/City**: Add dropdown filters
2. **Sort Options**: Sort by name, distance, etc.
3. **Favorites**: Mark frequently used pharmacies
4. **Medicine Search**: Search pharmacies by available medicines
5. **Map View**: Show all pharmacies on a map
6. **Opening Hours Indicator**: Show if pharmacy is currently open
7. **Reviews/Ratings**: Allow CHWs to rate pharmacies
8. **Stock Alerts**: Notify when medicines are in stock

## Notes

- Pharmacies page is accessible from the main drawer menu
- Uses existing `DiagnosisService.getAllPharmacies()` API
- Reuses `NearbyPharmacy` model from diagnosis feature
- Consistent UI/UX with rest of the app
- Follows Flutter best practices and app architecture
