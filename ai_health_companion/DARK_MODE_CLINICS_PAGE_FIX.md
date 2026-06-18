# Dark Mode Fix - Clinics Page

## Issue
The Clinics page had a white/light background in dark mode, making it inconsistent with the rest of the dark theme.

## Root Causes
The clinics_page.dart file had multiple hardcoded light colors identical to the pharmacies page:
1. `backgroundColor: AppTheme.backgroundColor` (static light color)
2. Hardcoded `AppTheme.textSecondary` for text and icons
3. Icon backgrounds using `AppTheme.primaryColor.withValues(alpha: 0.1)`
4. Modal bottom sheet not setting dark background
5. Specialty chips using hardcoded green colors
6. Empty state and error messages using hardcoded grey colors

## Solutions Applied

### 1. Page Background
```dart
// Changed from
backgroundColor: AppTheme.backgroundColor,

// To
backgroundColor: context.backgroundColor,
```

### 2. Modal Bottom Sheet
```dart
showModalBottomSheet(
  backgroundColor: context.modalBackgroundColor,  // Added
  // ...
)
```

### 3. Text and Icon Colors
```dart
// Icon colors
Icon(icon, size: 20, color: context.secondaryTextColor),

// Text colors
style: TextStyle(color: context.secondaryTextColor),
```

### 4. Icon Backgrounds
```dart
decoration: BoxDecoration(
  color: context.chipBackground(AppTheme.primaryColor),
  borderRadius: BorderRadius.circular(10),
),
```

### 5. Specialty Chips
```dart
Container(
  decoration: BoxDecoration(
    color: context.chipBackground(AppTheme.primaryColor),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: context.adaptiveColor(
        lightColor: AppTheme.primaryColor.withValues(alpha: 0.3),
        darkColor: AppTheme.primaryColor.withValues(alpha: 0.5),
      ),
    ),
  ),
  child: Text(
    specialty.replaceAll('_', ' '),
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: context.adaptiveColor(
        lightColor: AppTheme.primaryColor,
        darkColor: const Color(0xFF66BB6A),  // Lighter green in dark mode
      ),
    ),
  ),
)
```

### 6. Empty State Container
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: context.containerColor,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(
        Icons.info_outline,
        color: context.iconColor,
        size: 20,
      ),
      Text(
        l10n.generalMedicine,
        style: TextStyle(
          color: context.textColor,
          fontSize: 14,
        ),
      ),
    ],
  ),
)
```

### 7. Error and Empty States
```dart
// Icon colors - with opacity for subtle appearance
Icon(Icons.error_outline, color: context.iconColor.withOpacity(0.5)),
Icon(Icons.local_hospital, color: context.iconColor.withOpacity(0.5)),

// Text colors
style: TextStyle(color: context.textColor),
style: TextStyle(color: context.secondaryTextColor),
```

## Files Changed
1. **ai_health_companion/lib/features/clinic/presentation/pages/clinics_page.dart**
   - Fixed Scaffold background
   - Fixed modal bottom sheet background
   - Fixed all text colors to use theme extensions
   - Fixed icon backgrounds to use `chipBackground`
   - Fixed specialty chip colors and borders for dark mode
   - Fixed empty state and error message colors
   - Fixed list item text and icon colors

## Color Mappings

### Before (Hardcoded)
```dart
AppTheme.backgroundColor              → Always light
AppTheme.textSecondary                → Static dark grey
AppTheme.primaryColor.withValues()    → Static opacity
Colors constant usage                 → Not theme-aware
```

### After (Theme-Aware)
```dart
context.backgroundColor               → Dark in dark mode
context.modalBackgroundColor          → Dark in dark mode
context.secondaryTextColor            → Light in dark mode
context.textColor                     → Light in dark mode
context.chipBackground()              → Semi-transparent overlay
context.containerColor                → Dark grey in dark mode
context.iconColor                     → Light grey in dark mode
context.adaptiveColor()               → Different colors per theme
```

## Specialty Chips in Dark Mode
Special attention was paid to specialty chips to ensure they're visible and attractive in dark mode:
- **Background**: Semi-transparent green overlay
- **Border**: Slightly more opaque green in dark mode (0.5 vs 0.3 in light)
- **Text color**: Lighter green (`#66BB6A`) instead of the darker primary green

## Dark Mode Behavior
In dark mode, the clinics page will now show:
- **Page background**: `Color(0xFF121212)` (dark)
- **Card backgrounds**: `Color(0xFF1E1E1E)` (dark surface)
- **Modal backgrounds**: `Color(0xFF1E1E1E)` (dark surface)
- **Container backgrounds**: `Color(0xFF2C2C2C)` (dark container)
- **Text colors**: Light grey/white for readability
- **Border colors**: `Color(0xFF3C3C3C)` (subtle dark borders)
- **Icon backgrounds**: Semi-transparent colored overlays
- **Specialty chips**: Visible with lighter green text and borders

## Testing
After hot reload in dark mode:
1. Clinics page background should be dark
2. Clinic list cards should have dark backgrounds
3. Search bar should have dark background
4. Modal bottom sheet (clinic details) should be dark
5. Specialty chips should be visible with appropriate colors
6. All text should be readable with light colors
7. Empty states should use appropriate dark theme colors
8. Error messages should use appropriate dark theme colors
9. Icon backgrounds should use semi-transparent overlays

## Status
✅ Fixed - Ready for testing with hot reload
