# Dark Mode Fix - Pharmacies Page

## Issue
The Pharmacies page had a white/light background in dark mode, making it inconsistent with the rest of the dark theme.

## Root Causes
The pharmacies_page.dart file had multiple hardcoded light colors:
1. `backgroundColor: AppTheme.backgroundColor` (static light color)
2. Hardcoded `Colors.grey[*]` for various UI elements
3. Static `AppTheme.textSecondary` for text and icons
4. Medicine cards using `Colors.grey[50]` background
5. Modal bottom sheet not setting dark background
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
color: context.secondaryTextColor,  // Instead of AppTheme.textSecondary

// Text colors  
style: TextStyle(color: context.secondaryTextColor),
style: TextStyle(color: context.textColor),
```

### 4. Medicine Cards
```dart
decoration: BoxDecoration(
  color: context.containerColor,  // Instead of Colors.grey[50]
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: context.borderColor),  // Instead of Colors.grey[200]
),
```

### 5. Icon Backgrounds
```dart
color: context.chipBackground(AppTheme.primaryColor),  
// Instead of AppTheme.primaryColor.withValues(alpha: 0.1)
```

### 6. Handle Bar (Modal)
```dart
decoration: BoxDecoration(
  color: context.borderColor,  // Instead of Colors.grey[300]
  borderRadius: BorderRadius.circular(2),
),
```

### 7. Empty State Container
```dart
Container(
  decoration: BoxDecoration(
    color: context.containerColor,  // Instead of Colors.grey[100]
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(
        Icons.info_outline,
        color: context.secondaryTextColor,  // Instead of Colors.grey[600]
      ),
      // ...
    ],
  ),
)
```

### 8. Error and Empty States
```dart
// Icon colors
Icon(Icons.error_outline, color: context.secondaryTextColor),

// Text colors
style: TextStyle(color: context.textColor),
style: TextStyle(color: context.secondaryTextColor),
```

## Files Changed
1. **ai_health_companion/lib/features/pharmacy/presentation/pages/pharmacies_page.dart**
   - Fixed Scaffold background
   - Fixed modal bottom sheet background
   - Fixed all text colors to use theme extensions
   - Fixed medicine card backgrounds and borders
   - Fixed icon backgrounds to use `chipBackground`
   - Fixed empty state and error message colors
   - Fixed list item text and icon colors

## Color Mappings

### Before (Hardcoded)
```dart
AppTheme.backgroundColor     → Always light
Colors.grey[50]              → Light grey
Colors.grey[100]             → Light grey
Colors.grey[200]             → Light grey border
Colors.grey[300]             → Light grey
Colors.grey[400]             → Light grey
Colors.grey[600]             → Dark grey text
AppTheme.textSecondary       → Static dark grey
```

### After (Theme-Aware)
```dart
context.backgroundColor      → Dark in dark mode
context.containerColor       → Dark grey in dark mode
context.modalBackgroundColor → Dark in dark mode
context.borderColor          → Subtle in dark mode
context.secondaryTextColor   → Light in dark mode
context.textColor            → Light in dark mode
context.chipBackground()     → Semi-transparent overlay
```

## Dark Mode Behavior
In dark mode, the pharmacies page will now show:
- **Page background**: `Color(0xFF121212)` (dark)
- **Card backgrounds**: `Color(0xFF1E1E1E)` (dark surface)
- **Modal backgrounds**: `Color(0xFF1E1E1E)` (dark surface)
- **Container backgrounds**: `Color(0xFF2C2C2C)` (dark container)
- **Text colors**: Light grey/white for readability
- **Border colors**: `Color(0xFF3C3C3C)` (subtle dark borders)
- **Icon backgrounds**: Semi-transparent colored overlays

## Testing
After hot reload in dark mode:
1. Pharmacies page background should be dark
2. Pharmacy list cards should have dark backgrounds
3. Search bar should have dark background
4. Modal bottom sheet (pharmacy details) should be dark
5. Medicine cards should have dark backgrounds
6. All text should be readable with light colors
7. Empty states should use appropriate dark theme colors
8. Error messages should use appropriate dark theme colors

## Status
✅ Fixed - Ready for testing with hot reload
