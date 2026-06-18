# Dark Mode Fix - Remove Green Gradients

## Issue
User requested to remove the green gradients/backgrounds in dark mode. The green colors appeared in:
1. App headers/banners (AppHeader widget)
2. Home page flexible space bar
3. "AI Diagnosis Ready" welcome card
4. Settings profile card

## Root Cause
The app was using `AppTheme.primaryGradient` which is a static green gradient that doesn't change based on theme:
```dart
static const LinearGradient primaryGradient = LinearGradient(
  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF66BB6A)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
```

## Solution

### 1. Created Theme-Aware Gradient
Added a new extension method `primaryGradient` to ThemeExtension:
```dart
LinearGradient get primaryGradient {
  if (isDarkMode) {
    // Dark mode - use dark surface colors
    return LinearGradient(
      colors: [
        const Color(0xFF1E1E1E),
        const Color(0xFF2C2C2C),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  } else {
    // Light mode - keep the green gradient
    return const LinearGradient(
      colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF66BB6A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
```

### 2. Updated All Components

#### Home Page
```dart
// App bar flexible space
decoration: BoxDecoration(gradient: context.primaryGradient),

// Welcome card
decoration: BoxDecoration(
  gradient: context.primaryGradient,
  borderRadius: BorderRadius.circular(24),
  boxShadow: context.isDarkMode ? [] : AppTheme.mediumShadow,
),

// Start button text color
foregroundColor: context.adaptiveColor(
  lightColor: AppTheme.primaryColor,
  darkColor: const Color(0xFF1E1E1E),
),
```

#### Settings Page
```dart
// Profile card
decoration: BoxDecoration(
  gradient: context.primaryGradient,
  borderRadius: BorderRadius.circular(20),
),
```

#### AppHeader Widget
```dart
backgroundColor: context.adaptiveColor(
  lightColor: AppTheme.primaryColor,
  darkColor: const Color(0xFF1E1E1E),
),
```

## Files Changed

1. **ai_health_companion/lib/core/theme/theme_extensions.dart**
   - Added `primaryGradient` getter that returns theme-aware gradient
   - Dark mode: uses dark gray colors (0xFF1E1E1E → 0xFF2C2C2C)
   - Light mode: uses green gradient (preserved original)

2. **ai_health_companion/lib/features/diagnosis/presentation/pages/home_page.dart**
   - Fixed app bar flexible space to use `context.primaryGradient`
   - Fixed welcome card to use `context.primaryGradient`
   - Removed shadows in dark mode for welcome card
   - Fixed button foreground color to be dark in dark mode

3. **ai_health_companion/lib/features/settings/presentation/pages/settings_page.dart**
   - Fixed profile card to use `context.primaryGradient`

4. **ai_health_companion/lib/shared/widgets/app_header.dart**
   - Added import for theme_extensions.dart
   - Fixed AppBar backgroundColor to use dark color in dark mode

## Dark Mode Behavior

In dark mode, all green gradients are replaced with:
- **Header/Banner backgrounds**: `Color(0xFF1E1E1E)` (solid dark)
- **Gradient sections**: Dark gray gradient from `0xFF1E1E1E` to `0xFF2C2C2C`
- **Text remains white** for readability on dark backgrounds
- **No shadows** for cleaner appearance

In light mode:
- **All original green gradients preserved**
- **Shadows shown** for depth
- **Original design maintained**

## Visual Changes in Dark Mode

### Before (Green everywhere)
- ❌ Green header banners
- ❌ Green welcome card
- ❌ Green profile card
- ❌ High contrast with dark background

### After (Clean dark theme)
- ✅ Dark header banners matching theme
- ✅ Dark welcome card with subtle gradient
- ✅ Dark profile card
- ✅ Consistent dark theme throughout
- ✅ Better visual coherence

## Testing
After hot reload in dark mode:
1. Home page header should be dark (not green)
2. "AI Diagnosis Ready" card should be dark (not green)
3. Settings profile card should be dark (not green)
4. All page headers should be dark (not green)
5. Text should remain readable with white/light colors
6. Light mode should still show green gradients

## Status
✅ Fixed - Ready for testing with hot reload
