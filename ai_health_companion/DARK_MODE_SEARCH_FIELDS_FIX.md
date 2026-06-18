# Dark Mode Fix - Search Fields and Symptom Selector

## Issues
User reported that search fields and symptom selection components had white backgrounds in dark mode:
1. Search field at "Select Patient" page (diagnosis_page.dart)
2. Search field at "Symptoms Assessment" page (categorized_symptom_selector.dart)
3. Symptom counter info card with light gradient backgrounds
4. Symptom chips with hardcoded grey backgrounds

## Root Causes

### 1. Patient Search Field
- Using `fillColor: Colors.grey[50]` (hardcoded light grey)
- No border color specified (defaulting to theme)

### 2. Symptom Search Field  
- Container using `color: Colors.white` (hardcoded white)
- Using `fillColor: Colors.grey[50]` (hardcoded light grey)
- Icon color using static `AppTheme.primaryColor`
- Shadow always shown (should be removed in dark mode)

### 3. Symptom Counter Card
- Using `LinearGradient` with hardcoded light colors
- Text colors using `Colors.green.shade900` etc. (always dark, unreadable in dark mode)
- Secondary text using `Colors.grey[700]` (hardcoded)

### 4. Symptom Chips
- Unselected chips using `Colors.grey[100]` background
- Border using `Colors.grey[300]`
- Icon color using `Colors.grey[600]`
- Text color using `Colors.black87`

## Solutions Applied

### 1. Patient Search Field (diagnosis_page.dart)
```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.borderColor),  // Added theme-aware border
    ),
    filled: true,
    fillColor: context.searchFieldColor,  // Instead of Colors.grey[50]
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  ),
)
```

### 2. Symptom Search Field (categorized_symptom_selector.dart)
```dart
Container(
  decoration: BoxDecoration(
    color: context.cardColor,  // Instead of Colors.white
    borderRadius: BorderRadius.circular(12),
    boxShadow: context.isDarkMode ? [] : [  // Remove shadows in dark mode
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    decoration: InputDecoration(
      prefixIcon: Icon(
        Icons.search,
        color: context.adaptiveColor(  // Theme-aware icon color
          lightColor: AppTheme.primaryColor,
          darkColor: const Color(0xFF66BB6A),  // Lighter green in dark mode
        ),
      ),
      filled: true,
      fillColor: context.searchFieldColor,  // Instead of Colors.grey[50]
    ),
  ),
)
```

### 3. Symptom Counter Card
Replaced gradient with solid theme-aware colors:
```dart
// Background color
backgroundColor = isGoodCount
    ? context.adaptiveColor(
        lightColor: Colors.green.shade50,
        darkColor: const Color(0xFF1B3A1E),  // Dark green background
      )
    : isFewSymptoms
        ? context.adaptiveColor(
            lightColor: Colors.orange.shade50,
            darkColor: const Color(0xFF3A2A1E),  // Dark orange background
          )
        : context.adaptiveColor(
            lightColor: Colors.blue.shade50,
            darkColor: const Color(0xFF1E2A3A),  // Dark blue background
          );

// Border color
borderColor = isGoodCount
    ? context.adaptiveColor(
        lightColor: Colors.green.shade300,
        darkColor: const Color(0xFF4CAF50),  // Brighter green border
      )
    : // ... similar for other states

// Text color
textColor = isGoodCount
    ? context.adaptiveColor(
        lightColor: Colors.green.shade900,
        darkColor: const Color(0xFF66BB6A),  // Light green text
      )
    : // ... similar for other states

// Secondary text
color: context.secondaryTextColor,  // Instead of Colors.grey[700]
```

### 4. Symptom Chips
```dart
decoration: BoxDecoration(
  color: isSelected
      ? context.adaptiveColor(
          lightColor: AppTheme.primaryColor,
          darkColor: const Color(0xFF66BB6A),  // Lighter green when selected in dark mode
        )
      : context.containerColor,  // Instead of Colors.grey[100]
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: isSelected
        ? context.adaptiveColor(
            lightColor: AppTheme.primaryColor,
            darkColor: const Color(0xFF66BB6A),
          )
        : context.borderColor,  // Instead of Colors.grey[300]
    width: 1.5,
  ),
),
child: Row(
  children: [
    Icon(
      isSelected ? Icons.check_circle : Icons.circle_outlined,
      color: isSelected
          ? Colors.white
          : context.iconColor,  // Instead of Colors.grey[600]
      size: 18,
    ),
    Text(
      translatedSymptom,
      style: TextStyle(
        color: isSelected
            ? Colors.white
            : context.textColor,  // Instead of Colors.black87
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 14,
      ),
    ),
  ],
),
```

## Files Changed

1. **ai_health_companion/lib/features/diagnosis/presentation/pages/diagnosis_page.dart**
   - Fixed patient search field background and border
   - Changed `fillColor` to `context.searchFieldColor`
   - Added theme-aware border color

2. **ai_health_companion/lib/features/diagnosis/presentation/widgets/categorized_symptom_selector.dart**
   - Added import for theme_extensions.dart
   - Fixed search bar container and TextField backgrounds
   - Made search icon color adaptive (lighter green in dark mode)
   - Removed shadows in dark mode
   - Completely rewrote symptom counter card with theme-aware colors
   - Fixed symptom chip backgrounds, borders, icons, and text colors

## Color Mappings

### Before (Hardcoded)
```dart
Colors.grey[50]           → Always light grey
Colors.white              → Always white
Colors.grey[100]          → Always light grey
Colors.grey[300]          → Always grey border
Colors.grey[600]          → Always dark grey
Colors.grey[700]          → Always darker grey
Colors.black87            → Always dark text
Colors.green.shade50/100  → Always light green gradient
Colors.green.shade900     → Always dark green (unreadable in dark mode)
AppTheme.primaryColor     → Static dark green
```

### After (Theme-Aware)
```dart
context.searchFieldColor      → Dark grey in dark mode
context.cardColor             → Dark surface in dark mode
context.containerColor        → Dark container in dark mode
context.borderColor           → Subtle border in dark mode
context.iconColor             → Light grey in dark mode
context.secondaryTextColor    → Light grey in dark mode
context.textColor             → White in dark mode
context.adaptiveColor()       → Different per theme
Color(0xFF66BB6A)            → Lighter green for dark mode
Color(0xFF1B3A1E)            → Dark green background
Color(0xFF3A2A1E)            → Dark orange background
Color(0xFF1E2A3A)            → Dark blue background
```

## Symptom Counter States in Dark Mode

The symptom counter card now properly adapts to dark mode with three states:

1. **Good Selection** (8-12 symptoms):
   - Background: Dark green (`#1B3A1E`)
   - Border: Bright green (`#4CAF50`)
   - Icon: Light green (`#66BB6A`)
   - Text: Light green (`#66BB6A`)

2. **Few Symptoms** (<8 symptoms):
   - Background: Dark orange (`#3A2A1E`)
   - Border: Bright orange (`#FF9800`)
   - Icon: Light orange (`#FFB74D`)
   - Text: Light orange (`#FFB74D`)

3. **Many Symptoms** (>12 symptoms):
   - Background: Dark blue (`#1E2A3A`)
   - Border: Bright blue (`#2196F3`)
   - Icon: Light blue (`#64B5F6`)
   - Text: Light blue (`#64B5F6`)

## Testing
After hot reload in dark mode:
1. Patient search field should have dark background
2. Symptom search field should have dark background with no shadow
3. Search icon should be lighter green
4. Symptom counter card should have appropriate dark background color
5. Symptom counter text should be readable (light colored)
6. Unselected symptom chips should have dark grey background
7. Selected symptom chips should have lighter green background
8. All text and icons should be readable with proper contrast

## Status
✅ Fixed - Ready for testing with hot reload
