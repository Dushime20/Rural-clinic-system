# Complete App Translation Implementation Plan

## 🎯 Goal
Translate the entire app to support English, French, and Kinyarwanda.

---

## 📊 Translation Priority

### Phase 1: Critical User-Facing Pages (HIGH PRIORITY)
1. ✅ **CustomDrawer** (DONE)
2. **PharmaciesPage** - Users view pharmacies
3. **ClinicsPage** - Users view clinics
4. **LoginPage** - First thing users see
5. **DiagnosisPage** - Core feature
6. **DiagnosisResultPage** - Shows diagnosis results
7. **PatientListPage** - Patient management
8. **SettingsPage** - Language selection happens here

### Phase 2: Secondary Pages (MEDIUM PRIORITY)
9. **HomePage** - Dashboard/landing
10. **AddPatientPage** - Adding patients
11. **EditPatientPage** - Editing patients
12. **PatientDetailPage** - Patient information
13. **DiagnosisHistoryPage** - Past diagnoses
14. **AnalyticsDashboardPage** - Analytics

### Phase 3: Supporting Pages (LOWER PRIORITY)
15. **HelpSupportPage** - Help content
16. **ForgotPasswordPage** - Password recovery
17. **ResetPasswordPage** - Password reset
18. **ChangePasswordPage** - Password change
19. **SplashScreen** - Initial loading
20. **MainNavigationWrapper** - Bottom nav

---

## 🔧 Implementation Strategy

### Step 1: Audit & Add Missing ARB Keys
First, identify all strings that need translation and add them to ARB files.

### Step 2: Update Pages to Use AppLocalizations
Replace hardcoded strings with `l10n.keyName`.

### Step 3: Test Each Language
Verify translations work correctly in all 3 languages.

---

## 📝 Current ARB File Analysis

### Existing Keys (141 total)
Your ARB files already have:
- ✅ Common UI (save, cancel, delete, edit, etc.)
- ✅ Auth (login, logout, password, etc.)
- ✅ Navigation (home, diagnosis, patients, etc.)
- ✅ Medical (symptoms, temperature, prescriptions, etc.)
- ✅ Patient management
- ✅ Settings

### Missing Keys (Need to Add)
Based on initial review, we need:
- Pharmacy-specific strings
- Clinic-specific strings
- Diagnosis workflow strings
- Error messages
- Success notifications
- Empty states
- Loading states

---

## 🚀 Execution Plan

I'll work through each page systematically:
1. Read the page file
2. Identify all hardcoded strings
3. Add missing keys to ARB files
4. Update the page to use AppLocalizations
5. Regenerate localization files
6. Move to next page

---

## 📋 Progress Tracking

| Page | Status | ARB Keys Added | Code Updated |
|------|--------|----------------|--------------|
| CustomDrawer | ✅ Done | clinics | ✅ |
| PharmaciesPage | 🔄 In Progress | - | - |
| ClinicsPage | ⏳ Pending | - | - |
| LoginPage | ⏳ Pending | - | - |
| DiagnosisPage | ⏳ Pending | - | - |
| DiagnosisResultPage | ⏳ Pending | - | - |
| PatientListPage | ⏳ Pending | - | - |
| SettingsPage | ⏳ Pending | - | - |

---

## 🎬 Let's Begin!

Starting with **PharmaciesPage** as it's a key user feature.
