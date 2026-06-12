# Complete App Translation Guide

## ✅ What's Already Done

### Pages Translated:
1. ✅ **CustomDrawer** - Side menu
2. ✅ **PharmaciesPage** - Pharmacy list and details

### ARB Keys Added:
- ✅ clinics
- ✅ pharmacies, pharmaciesAvailable
- ✅ searchPharmacies, loadingPharmacies
- ✅ errorLoadingPharmacies, noPharmaciesFound
- ✅ noMatchingPharmacies, tryDifferentSearch
- ✅ availableMedicines, noMedicinesAvailable
- ✅ openingHours, cannotOpenDialer, cannotOpenMaps

---

## 🚀 How to Translate Remaining Pages

### Step-by-Step Pattern

For each page:

1. **Add AppLocalizations import**
2. **Get localization object**
3. **Replace hardcoded strings**
4. **Add missing keys to ARB files**
5. **Run `flutter pub get`**
6. **Test**

---

## 📖 Translation Pattern (Copy This!)

### 1. Add Import

At the top of any Dart file:

```dart
import '../../../generated/app_localizations.dart';
// OR
import '../../../../generated/app_localizations.dart';
// Adjust path based on file location
```

### 2. Get Localization Object

In build method or any method with BuildContext:

```dart
final l10n = AppLocalizations.of(context)!;
```

### 3. Replace Hardcoded Strings

**Before:**
```dart
Text('Loading clinics...')
```

**After:**
```dart
Text(l10n.loadingClinics)
```

**Before:**
```dart
hintText: 'Search by name...'
```

**After:**
```dart
hintText: l10n.searchByName
```

---

## 📝 Quick Reference: Common Patterns

### Text Widgets
```dart
// Before
Text('Save Changes')

// After  
Text(l10n.saveChanges)
```

### Buttons
```dart
// Before
ElevatedButton(
  child: Text('Submit'),
  ...
)

// After
ElevatedButton(
  child: Text(l10n.submit),
  ...
)
```

### AppBar
```dart
// Before
appBar: AppBar(
  title: Text('Settings'),
)

// After
appBar: AppBar(
  title: Text(l10n.settings),
)
```

### Snackbar
```dart
// Before
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Success!')),
)

// After
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.success)),
)
```

### TextField
```dart
// Before
TextField(
  decoration: InputDecoration(
    labelText: 'Email Address',
    hintText: 'Enter your email',
  ),
)

// After
TextField(
  decoration: InputDecoration(
    labelText: l10n.email,
    hintText: l10n.enterEmail,  // Add to ARB
  ),
)
```

---

## 🎯 Priority Translation List

### Phase 1: Critical Pages (Do These First)

#### 1. ClinicsPage
**File:** `lib/features/clinic/presentation/pages/clinics_page.dart`

**Strings to translate:**
- "Clinics" → `l10n.clinics` (already exists)
- "clinics available" → Add `clinicsAvailable`
- "Search by name, specialty, or location..." → Add `searchClinics`
- "Loading clinics..." → Add `loadingClinics`
- "Error loading clinics" → Add `errorLoadingClinics`
- "No clinics found" → Add `noClinicsFound`
- "Specialties" → Add `specialties`
- "Open now" → Add `openNow`
- "Closed" → Add `closed`

**Add to ARB files:**
```json
// app_en.arb
"clinicsAvailable": "clinics available",
"searchClinics": "Search by name, specialty, or location...",
"loadingClinics": "Loading clinics...",
"errorLoadingClinics": "Error loading clinics",
"noClinicsFound": "No clinics found",
"noMatchingClinics": "No matching clinics",
"specialties": "Specialties",
"openNow": "Open now",
"closed": "Closed"

// app_fr.arb
"clinicsAvailable": "cliniques disponibles",
"searchClinics": "Rechercher par nom, spécialité ou lieu...",
"loadingClinics": "Chargement des cliniques...",
"errorLoadingClinics": "Erreur de chargement des cliniques",
"noClinicsFound": "Aucune clinique trouvée",
"noMatchingClinics": "Aucune clinique correspondante",
"specialties": "Spécialités",
"openNow": "Ouvert maintenant",
"closed": "Fermé"

// app_rw.arb
"clinicsAvailable": "amavuriro arahari",
"searchClinics": "Shakisha izina, ubwoko, cyangwa ahantu...",
"loadingClinics": "Biratangura amavuriro...",
"errorLoadingClinics": "Ikosa mu gutangiza amavuriro",
"noClinicsFound": "Nta mavuriro yabonetse",
"noMatchingClinics": "Nta mavuriro ahuye",
"specialties": "Ubwoko bw'ubuvuzi",
"openNow": "Yafunguwe",
"closed": "Yafunze"
```

#### 2. LoginPage
**File:** `lib/features/auth/presentation/pages/login_page.dart`

Keys probably already exist:
- `l10n.login`
- `l10n.email`
- `l10n.password`
- `l10n.forgotPassword`

Just need to use them!

#### 3. DiagnosisPage
**File:** `lib/features/diagnosis/presentation/pages/diagnosis_page.dart`

May need:
- `selectPatient`, `selectSymptoms`
- `enterVitalSigns`, `checkForDiagnosis`
- etc.

#### 4. DiagnosisResultPage
**File:** `lib/features/diagnosis/presentation/pages/diagnosis_result_page.dart`

May need:
- `diagnosisComplete`, `viewResults`
- `recommendedTreatment`, `prescribedMedications`
- etc.

#### 5. PatientListPage
**File:** `lib/features/patient/presentation/pages/patient_list_page.dart`

Probably can use:
- `l10n.patients`, `l10n.addPatient`
- `l10n.searchPatients` (add if missing)

#### 6. SettingsPage
**File:** `lib/features/settings/presentation/pages/settings_page.dart`

Most keys probably exist:
- `l10n.settings`, `l10n.language`
- `l10n.theme`, etc.

---

## 🛠️ Tools to Help You

### Find Hardcoded Strings

Run this in your terminal:

```bash
cd ai_health_companion

# Find all Text widgets with hardcoded strings
grep -r "Text('" lib/features --include="*.dart" | head -50

# Find hintText with hardcoded strings
grep -r "hintText:" lib/features --include="*.dart"

# Find title with hardcoded strings
grep -r "title:" lib/features --include="*.dart" | head -50
```

### Check Which Pages Need Translation

```bash
# List all page files
find lib/features -name "*_page.dart" -type f
```

---

## 📋 Translation Checklist Template

For each page, use this checklist:

### Page: _____________

- [ ] Added AppLocalizations import
- [ ] Got l10n object in build method
- [ ] Translated AppBar title
- [ ] Translated AppBar subtitle (if any)
- [ ] Translated all Text widgets
- [ ] Translated all Button labels
- [ ] Translated all TextField hints/labels
- [ ] Translated all error messages
- [ ] Translated all success messages
- [ ] Translated all empty states
- [ ] Translated all loading states
- [ ] Added missing keys to app_en.arb
- [ ] Added missing keys to app_fr.arb
- [ ] Added missing keys to app_rw.arb
- [ ] Ran `flutter pub get`
- [ ] Tested in English
- [ ] Tested in French
- [ ] Tested in Kinyarwanda

---

## 🎬 Example: Complete Translation of a Simple Page

**Before (`example_page.dart`):**
```dart
import 'package:flutter/material.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to Example Page'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Click Me'),
            ),
            SizedBox(height: 10),
            Text('Loading data...'),
          ],
        ),
      ),
    );
  }
}
```

**After (`example_page.dart`):**
```dart
import 'package:flutter/material.dart';
import '../../generated/app_localizations.dart';

class ExamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.examplePage),
      ),
      body: Center(
        child: Column(
          children: [
            Text(l10n.welcomeToExample),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text(l10n.clickMe),
            ),
            SizedBox(height: 10),
            Text(l10n.loadingData),
          ],
        ),
      ),
    );
  }
}
```

**Add to ARB files:**
```json
// app_en.arb
"examplePage": "Example Page",
"welcomeToExample": "Welcome to Example Page",
"clickMe": "Click Me",
"loadingData": "Loading data..."

// app_fr.arb
"examplePage": "Page d'exemple",
"welcomeToExample": "Bienvenue sur la page d'exemple",
"clickMe": "Cliquez-moi",
"loadingData": "Chargement des données..."

// app_rw.arb
"examplePage": "Urupapuro rw'urugero",
"welcomeToExample": "Murakaza neza kuri urupapuro rw'urugero",
"clickMe": "Kanda hano",
"loadingData": "Biratangura amakuru..."
```

**Run:**
```bash
flutter pub get
```

**Test:**
- Switch to Kinyarwanda → See Kinyarwanda text
- Switch to French → See French text
- Switch to English → See English text

---

## 🚦 Your Action Plan

### Today:
1. ✅ PharmaciesPage is done!
2. 🔄 Do **ClinicsPage** (similar to PharmaciesPage)
3. 🔄 Do **LoginPage** (should be quick)

### Tomorrow:
4. Do **DiagnosisPage**
5. Do **DiagnosisResultPage**
6. Do **PatientListPage**

### This Week:
7. Do remaining pages
8. Test all languages
9. Fix any missing translations

---

## 💡 Pro Tips

1. **Work in batches**: Do 2-3 similar pages at once
2. **Reuse keys**: If a string is the same as existing key, reuse it!
3. **Test frequently**: Switch languages after each page
4. **Keep ARB files in sync**: Always add to all 3 languages
5. **Use descriptive keys**: `loadingPharmacies` not `loading1`
6. **Group related keys**: Keep pharmacy keys together in ARB

---

## 🆘 Common Issues & Solutions

### Issue: "l10n.keyName doesn't exist"
**Solution:** 
1. Add key to all 3 ARB files
2. Run `flutter pub get`
3. Hot restart (Press `R`)

### Issue: "Can't find AppLocalizations"
**Solution:** 
```dart
// Check import path - adjust number of ../
import '../../generated/app_localizations.dart';
// OR
import '../../../generated/app_localizations.dart';
```

### Issue: "Still showing English after switching"
**Solution:** 
- That page isn't translated yet
- Or forgot to use `l10n.keyName`
- Or didn't hot restart

---

## 📊 Progress Tracking

Create a file `TRANSLATION_PROGRESS.md`:

```markdown
# Translation Progress

## Completed ✅
- [x] CustomDrawer
- [x] PharmaciesPage

## In Progress 🔄
- [ ] ClinicsPage
- [ ] LoginPage

## Todo ⏳
- [ ] DiagnosisPage
- [ ] DiagnosisResultPage
- [ ] PatientListPage
- [ ] AddPatientPage
- [ ] EditPatientPage
- [ ] PatientDetailPage
- [ ] SettingsPage
- [ ] HomePage
- [ ] AnalyticsDashboardPage
- [ ] HelpSupportPage
- [ ] ForgotPasswordPage
- [ ] ResetPasswordPage
- [ ] ChangePasswordPage
- [ ] SplashScreen
- [ ] MainNavigationWrapper
```

---

## 🎯 Summary

**What You Have:**
- ✅ Translation infrastructure working
- ✅ 141+ keys already translated
- ✅ Pattern to follow (PharmaciesPage)
- ✅ This guide

**What You Need To Do:**
1. Follow the pattern for each page
2. Add missing keys to ARB files
3. Replace hardcoded strings with `l10n.keyName`
4. Run `flutter pub get`
5. Test in all languages

**Estimated Time:**
- Simple page: 15-20 minutes
- Complex page: 30-45 minutes
- Total for all pages: 6-8 hours of focused work

**You can do this!** 🚀

Start with ClinicsPage since it's almost identical to PharmaciesPage!

---

**Last Updated:** June 11, 2026  
**Status:** PharmaciesPage Complete, ClinicsPage Next
