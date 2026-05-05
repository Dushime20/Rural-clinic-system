# Theme & i18n - Quick Reference

## 🚀 Quick Start

### 1. Generate Localization Files
```bash
cd ai_health_companion
flutter gen-l10n
flutter pub get
flutter run
```

### 2. Use in Code
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Get translations
final l10n = AppLocalizations.of(context)!;
Text(l10n.welcome)  // Translated text
```

## 🎨 Theme Switching

### In Settings Page
- Toggle switch automatically changes theme
- Saved in SharedPreferences
- Restored on app restart

### Programmatically
```dart
// Toggle
ref.read(themeModeProvider.notifier).toggleTheme();

// Set specific
ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

// Check current
final isDark = ref.watch(isDarkModeProvider);
```

## 🌍 Language Switching

### In Settings Page
- Tap "Language" → Select from bottom sheet
- Saved in SharedPreferences
- Restored on app restart

### Programmatically
```dart
// Set language
ref.read(languageProvider.notifier).setLanguage(AppLanguage.french);

// Get current
final lang = ref.watch(currentLanguageProvider);
```

## 📝 Translation Keys

### Common Keys
```dart
l10n.welcome          // Welcome
l10n.login            // Login
l10n.save             // Save
l10n.cancel           // Cancel
l10n.loading          // Loading...
```

### Diagnosis
```dart
l10n.aiDiagnosis      // AI Diagnosis
l10n.symptoms         // Symptoms
l10n.vitalSigns       // Vital Signs
l10n.prescriptions    // Prescriptions
l10n.pharmacy         // Pharmacy
```

### Settings
```dart
l10n.theme            // Theme
l10n.lightMode        // Light Mode
l10n.darkMode         // Dark Mode
l10n.language         // Language
l10n.settings         // Settings
```

## 🎯 Supported Languages

| Code | Native Name | English Name |
|------|-------------|--------------|
| en   | English     | English      |
| fr   | Français    | French       |
| rw   | Ikinyarwanda| Kinyarwanda  |

## ✅ Features

- ✅ Instant switching (no restart)
- ✅ Offline support (0ms latency)
- ✅ Persistent preferences
- ✅ Type-safe translations
- ✅ 150+ translation keys
- ✅ Light & Dark themes

## 📁 Key Files

```
lib/
├── l10n/
│   ├── app_en.arb              # English
│   ├── app_fr.arb              # French
│   └── app_rw.arb              # Kinyarwanda
├── core/providers/
│   ├── theme_provider.dart     # Theme state
│   └── language_provider.dart  # Language state
└── main.dart                   # App config
```

## 🐛 Troubleshooting

**Error: AppLocalizations not found**
→ Run `flutter gen-l10n`

**Theme not persisting**
→ Check SharedPreferences initialization

**Language not changing**
→ Verify ARB files exist and are valid

---

**Quick Setup**: `flutter gen-l10n && flutter pub get && flutter run`
