# Kinyarwanda Translation Fix - Instructions

## 🔍 Problem Found

Your app has translations in the ARB files, but the UI was using **hardcoded strings** instead of `AppLocalizations`. This is why selecting Kinyarwanda didn't change the text.

---

## ✅ What I Fixed

### 1. **Updated `custom_drawer.dart`**
Changed from hardcoded strings to localized strings:

**Before:**
```dart
title: 'AI Diagnosis',
title: 'Patient Management',
title: 'Pharmacies',
```

**After:**
```dart
title: l10n.aiDiagnosis,      // "Isuzuma rya AI" in Kinyarwanda
title: l10n.patientList,       // "Urutonde rw'abarwayi"
title: l10n.nearbyPharmacies,  // "Amaduka y'imiti hafi"
```

### 2. **Added "Clinics" Translation**
Added to all three ARB files:
- English: "Clinics"
- French: "Cliniques"  
- Kinyarwanda: "Amavuriro"

### 3. **Updated Dialog Boxes**
- Logout dialog now uses translations
- About dialog now uses translations

---

## 🚀 Next Steps (CRITICAL)

### Step 1: Regenerate Localization Files

You **MUST** run this command to generate the Dart files from the ARB files:

```bash
cd ai_health_companion
flutter gen-l10n
```

Or simply:

```bash
cd ai_health_companion
flutter pub get
```

This will regenerate the `generated/app_localizations*.dart` files with the new "clinics" key.

### Step 2: Hot Restart the App

**Important**: Language changes require a **hot restart**, not hot reload:

```bash
# In your terminal where Flutter is running
R  # Press capital R for hot restart
```

Or stop and restart:
```bash
flutter run
```

### Step 3: Test

1. Open the app
2. Go to **Settings → Language**
3. Select **"Ikinyarwanda"**
4. Open the side drawer
5. You should now see:
   - "Isuzuma rya AI" (instead of "AI Diagnosis")
   - "Urutonde rw'abarwayi" (instead of "Patient Management")
   - "Amaduka y'imiti hafi" (instead of "Pharmacies")
   - "Amavuriro" (instead of "Clinics")

---

## ⚠️ Other Files That Still Need Fixing

Many other files in your app are still using hardcoded strings. Here are the main ones:

### High Priority Files

1. **PharmaciesPage** (`lib/features/pharmacy/presentation/pages/pharmacies_page.dart`)
   - Hardcoded: "Pharmacies", "Loading pharmacies...", "Error loading pharmacies"
   - Should use: `l10n.nearbyPharmacies`, etc.

2. **ClinicsPage** (`lib/features/clinic/presentation/pages/clinics_page.dart`)
   - Hardcoded: "Clinics", "Loading clinics...", "Specialties"
   - Needs: ARB entries + AppLocalizations usage

3. **LoginPage** (`lib/features/auth/presentation/pages/login_page.dart`)
   - Check if using `l10n.login`, `l10n.email`, `l10n.password`

4. **DiagnosisPage** (`lib/features/diagnosis/presentation/pages/diagnosis_page.dart`)
   - Check all buttons and labels

5. **SettingsPage** (`lib/features/settings/presentation/pages/settings_page.dart`)
   - Check if all settings labels use localization

---

## 📝 Pattern for Fixing Other Files

For each file that needs fixing:

### 1. Add Import
```dart
import '../../generated/app_localizations.dart';
```

### 2. Get Localization Object
```dart
final l10n = AppLocalizations.of(context)!;
```

### 3. Replace Hardcoded Strings
**Before:**
```dart
Text('Loading pharmacies...')
```

**After:**
```dart
Text(l10n.loading)  // If key exists
// OR add new key to ARB files
```

### Example Fix for PharmaciesPage

**Before:**
```dart
appBar: AppHeader(
  title: 'Pharmacies',
  subtitle: '${_filteredPharmacies.length} pharmacies available',
  ...
)
```

**After:**
```dart
appBar: AppHeader(
  title: l10n.nearbyPharmacies,  // "Amaduka y'imiti hafi"
  subtitle: '${_filteredPharmacies.length} ${l10n.available}',
  ...
)
```

---

## 🔍 How to Find Hardcoded Strings

Run this command to find hardcoded strings:

```bash
cd ai_health_companion
grep -r "Text('" lib/ --include="*.dart" | grep -v "AppLocalizations" | grep -v "generated"
```

This shows all `Text('...')` that aren't using localization.

---

## 📋 Checklist

- [ ] Run `flutter gen-l10n` or `flutter pub get`
- [ ] Hot restart the app (Press `R`)
- [ ] Test language switching to Kinyarwanda
- [ ] Verify drawer shows Kinyarwanda text
- [ ] Fix PharmaciesPage
- [ ] Fix ClinicsPage  
- [ ] Fix other major pages
- [ ] Add missing keys to ARB files
- [ ] Test all pages in Kinyarwanda
- [ ] Test in French too

---

## 🎯 Quick Test Script

After running `flutter gen-l10n`:

1. **Start app**: `flutter run`
2. **Open Settings** → Tap "Language"
3. **Select "Ikinyarwanda"**
4. **Open side drawer**
5. **Check if you see**:
   - ✅ "Isuzuma rya AI"
   - ✅ "Urutonde rw'abarwayi"  
   - ✅ "Amaduka y'imiti hafi"
   - ✅ "Amavuriro"
   - ✅ "Imibare"
   - ✅ "Igenamiterere"
   - ✅ "Ubufasha"
   - ✅ "Ibyerekeye"
   - ✅ "Sohoka"

6. **Try logout** → Should see "Uremeza ko ushaka gusohoka?"

---

## 🆘 Troubleshooting

### Issue: "flutter gen-l10n" not found
**Solution**: It should work automatically with `flutter pub get`

### Issue: Still showing English after selecting Kinyarwanda
**Possible causes**:
1. Didn't run `flutter gen-l10n`
2. Did hot reload instead of hot restart (Press `R`)
3. File still has hardcoded strings
4. Check if ARB key exists

### Issue: App crashes after changes
**Solution**: 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "l10n.clinics" gives error
**Solution**: Make sure you ran `flutter gen-l10n` after updating ARB files

---

## 📖 Example: Complete File Fix

Here's how to fix a complete file (example with a simple page):

```dart
// Before
import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Column(
        children: [
          Text('Welcome to my page'),
          ElevatedButton(
            onPressed: () {},
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

// After
import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myPage),  // Add "myPage" to ARB files
      ),
      body: Column(
        children: [
          Text(l10n.welcome),
          ElevatedButton(
            onPressed: () {},
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎓 Best Practices

1. **Always use AppLocalizations** for user-facing text
2. **Never hardcode strings** that users will see
3. **Keep ARB files in sync** (same keys in all languages)
4. **Run gen-l10n** after updating ARB files
5. **Hot restart** after language changes
6. **Test in all languages** before releasing

---

## ✨ Summary

**What I did:**
- ✅ Fixed CustomDrawer to use AppLocalizations
- ✅ Added "clinics" translation to all ARB files
- ✅ Updated logout and about dialogs

**What you need to do:**
1. Run `flutter gen-l10n` or `flutter pub get`
2. Hot restart app (Press `R`)
3. Test Kinyarwanda language switching
4. Fix remaining pages (PharmaciesPage, ClinicsPage, etc.)

**Expected result:**
When you select Kinyarwanda, the drawer should show Kinyarwanda text!

---

**Status**: Partially Fixed - Drawer is ready, other pages need similar updates  
**Priority**: HIGH - Run code generation first  
**Date**: June 11, 2026
