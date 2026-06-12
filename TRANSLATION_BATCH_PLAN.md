# Translation Batch Implementation Plan

## Current Status (20% Complete)
- ✅ CustomDrawer
- ✅ PharmaciesPage
- ✅ ClinicsPage
- ✅ LoginPage

## Systematic Batch Approach

Due to the large number of pages (16 remaining) and strings to translate, I recommend a batch approach where we translate multiple pages at once following a consistent pattern.

### Batch 1: Core User Flow (HIGH PRIORITY) - 30% Progress Target
**Estimated Time: 2 hours**

1. **HomePage** - Dashboard (30-35 keys needed)
   - File: `lib/features/diagnosis/presentation/pages/home_page.dart`
   - Keys: Good Morning/Afternoon/Evening, AI Diagnosis Ready, Start New Diagnosis, Quick Actions, Main Features, Recent Activity, etc.
   
2. **SettingsPage** - User preferences (15-20 keys needed)
   - File: `lib/features/settings/presentation/pages/settings_page.dart`
   - Keys: Account Settings, App Settings, Theme, Language, Notifications, etc.

3. **PatientListPage** - Patient management (20-25 keys needed)
   - File: `lib/features/patient/presentation/pages/patient_list_page.dart`
   - Keys: Patient List, Add Patient, Search patients, Filter, etc.

### Batch 2: Diagnosis Flow (CRITICAL FEATURE) - 50% Progress Target
**Estimated Time: 2-3 hours**

4. **DiagnosisPage** - Main AI diagnosis (50-60 keys needed)
   - File: `lib/features/diagnosis/presentation/pages/diagnosis_page.dart`
   - Keys: Select Patient, Symptoms, Vital Signs, Review, Submit, etc.
   - **Note:** This is the most complex page with 5 tabs

5. **DiagnosisResultPage** - Show diagnosis results (25-30 keys needed)
   - File: `lib/features/diagnosis/presentation/pages/diagnosis_result_page.dart`
   - Keys: Diagnosis Results, Predictions, Confidence, Recommendations, etc.

6. **DiagnosisHistoryPage** - Past diagnoses (15-20 keys needed)
   - File: `lib/features/diagnosis/presentation/pages/diagnosis_history_page.dart`
   - Keys: Diagnosis History, Filter by date, Search, View details, etc.

### Batch 3: Patient Management - 65% Progress Target
**Estimated Time: 1.5 hours**

7. **AddPatientPage** - New patient registration (20-25 keys needed)
   - File: `lib/features/patient/presentation/pages/add_patient_page.dart`
   - Keys: Add New Patient, Personal Information, Medical History, Save, etc.

8. **EditPatientPage** - Update patient info (similar to AddPatientPage)
   - File: `lib/features/patient/presentation/pages/edit_patient_page.dart`
   - Keys: Edit Patient, Update Information, Save Changes, etc.

9. **PatientDetailPage** - View patient details (20-25 keys needed)
   - File: `lib/features/patient/presentation/pages/patient_detail_page.dart`
   - Keys: Patient Details, Medical History, Diagnosis History, Edit, Delete, etc.

### Batch 4: Secondary Features - 80% Progress Target
**Estimated Time: 1.5 hours**

10. **AnalyticsDashboardPage** - Statistics (15-20 keys needed)
    - File: `lib/features/analytics/presentation/pages/analytics_dashboard_page.dart`
    - Keys: Analytics Dashboard, Statistics, Charts, Trends, etc.

11. **RecentActivityPage** - Activity log (10-15 keys needed)
    - File: `lib/features/diagnosis/presentation/pages/recent_activity_page.dart`
    - Keys: Recent Activity, Today, Yesterday, Last 7 Days, etc.

12. **HelpSupportPage** - Help documentation (15-20 keys needed)
    - File: `lib/features/settings/presentation/pages/help_support_page.dart`
    - Keys: Help & Support, FAQ, Contact Us, Documentation, etc.

### Batch 5: Authentication Flow - 90% Progress Target
**Estimated Time: 1 hour**

13. **ForgotPasswordPage** - Password reset request (10-12 keys needed)
    - File: `lib/features/auth/presentation/pages/forgot_password_page.dart`
    - Keys: Forgot Password, Enter Email, Send Reset Link, etc.

14. **ResetPasswordPage** - New password entry (10-12 keys needed)
    - File: `lib/features/auth/presentation/pages/reset_password_page.dart`
    - Keys: Reset Password, New Password, Confirm Password, Submit, etc.

15. **ChangePasswordPage** - Password change (12-15 keys needed)
    - File: `lib/features/auth/presentation/pages/change_password_page.dart`
    - Keys: Change Password, Current Password, New Password, etc.

### Batch 6: Optional/Utility Pages - 100% Complete!
**Estimated Time: 30 minutes**

16. **PatientMedicalHistoryPage** - Medical history details (10-15 keys needed)
    - File: `lib/features/patient/presentation/pages/patient_medical_history_page.dart`
    - Keys: Medical History, Conditions, Medications, Allergies, etc.

17. **PharmacyStockPage** - Pharmacy inventory (if needed)
    - File: `lib/features/pharmacy/presentation/pages/pharmacy_stock_page.dart`

18. **PharmacySearchPage** - Pharmacy search (if needed)
    - File: `lib/features/pharmacy/presentation/pages/pharmacy_search_page.dart`

---

## Translation Keys Required by Batch

### Batch 1 Keys (~70 total)
```
goodMorning, goodAfternoon, goodEvening
aiDiagnosisReady, yourAIAssistantReady
startNewDiagnosis, newPatient, viewPatients
quickActions, mainFeatures, recentActivity
viewAll, noRecentActivity
diagnosisRecorded, patientAdded
minutesAgo, hoursAgo, daysAgo
```

### Batch 2 Keys (~95 total)
```
selectPatient, patientInfo, symptoms, vitalSigns, review
symptomsAssessment, medicalHistory, additionalNotes
temperature, bloodPressure, heartRate, respiratoryRate, oxygenSaturation
runAIDiagnosis, diagnosisResults, predictions, confidence
recommendations, prescriptions, nearbyPharmacies, clinicRecommendations
diagnosisHistory, filterByDate, searchDiagnoses
```

### Batch 3 Keys (~65 total)
```
addNewPatient, editPatient, patientDetails
personalInformation, contactInformation, emergencyContact
medicalHistoryInfo, currentMedications, knownAllergies
savePatient, updatePatient, deletePatient, confirmDelete
patientSaved, patientUpdated, patientDeleted
```

### Batch 4 Keys (~45 total)
```
analyticsDashboard, statistics, charts, trends, reports
totalPatients, totalDiagnoses, thisWeek, thisMonth, thisYear
recentActivity, todayActivity, yesterdayActivity, last7Days
helpAndSupport, faq, contactUs, documentation, userGuide
```

### Batch 5 Keys (~35 total)
```
forgotPassword, enterYourEmail, sendResetLink, checkYourEmail
resetPassword, enterNewPassword, confirmNewPassword, resetComplete
changePassword, currentPassword, newPassword, passwordChanged
passwordMustMatch, passwordTooShort, invalidCurrentPassword
```

### Batch 6 Keys (~25 total)
```
medicalHistoryDetails, chronicConditions, pastSurgeries
currentMedications, allergiesList, familyHistory
addCondition, editCondition, removeCondition
```

---

## Recommended Implementation Strategy

### Option A: Automated Batch Translation (FASTEST)
1. Create a script to extract all hardcoded strings from each file
2. Generate translation keys automatically
3. Add keys to ARB files in batch
4. Update each file programmatically
5. Test each batch

**Pros:** Fast, consistent, scalable
**Cons:** Requires careful testing, potential for errors

### Option B: Manual Batch Translation (SAFER)
1. Work through one batch at a time
2. For each page in batch:
   - Read file
   - Identify strings
   - Add keys to ARB files
   - Update code
   - Test
3. Move to next batch

**Pros:** More control, higher quality, easier to fix issues
**Cons:** Takes longer

### Option C: Hybrid Approach (RECOMMENDED)
1. Complete high-priority batches manually (Batches 1-3)
2. Use automated/semi-automated approach for lower priority (Batches 4-6)
3. Focus testing on critical user flows

**Pros:** Balance of speed and quality
**Cons:** Requires switching between approaches

---

## Estimated Total Time

| Batch | Pages | Keys | Time | Progress |
|-------|-------|------|------|----------|
| Current | 4 | ~50 | 4h | 20% |
| Batch 1 | 3 | ~70 | 2h | 30% |
| Batch 2 | 3 | ~95 | 3h | 50% |
| Batch 3 | 3 | ~65 | 1.5h | 65% |
| Batch 4 | 3 | ~45 | 1.5h | 80% |
| Batch 5 | 3 | ~35 | 1h | 90% |
| Batch 6 | 3 | ~25 | 0.5h | 100% |
| **TOTAL** | **22** | **~385** | **13.5h** | **100%** |

**Current Progress:** 4 hours (30% of time)  
**Remaining Work:** 9.5 hours (70% of time)  
**At current pace:** ~2-3 more sessions to complete

---

## Next Immediate Actions

### SHORT SESSION (30-60 min): Complete Batch 1
- Translate HomePage (dashboard)
- Translate SettingsPage  
- Translate PatientListPage
- **Result:** 30% total progress

### MEDIUM SESSION (2-3 hours): Complete Batches 1-2
- All of Batch 1
- DiagnosisPage + DiagnosisResultPage + DiagnosisHistoryPage
- **Result:** 50% total progress

### LONG SESSION (4-5 hours): Complete Batches 1-3
- All high-priority user flows translated
- App fully functional in Kinyarwanda for core features
- **Result:** 65% total progress

---

## Quality Checklist (Per Page)

- [ ] Import AppLocalizations added
- [ ] All hardcoded strings replaced with l10n references
- [ ] Keys added to all 3 ARB files (en, fr, rw)
- [ ] Dart localization files regenerated (`flutter pub get`)
- [ ] Hot restart performed
- [ ] Page tested in English
- [ ] Page tested in French
- [ ] Page tested in Kinyarwanda
- [ ] No missing translation errors
- [ ] UI displays correctly in all languages

---

## Success Metrics

### 50% Complete (Critical Mass)
- All entry points translated (Login, Home, Navigation)
- Core diagnosis flow working
- Patient management functional
- Users can complete primary workflows

### 80% Complete (Feature Complete)
- All major features translated
- Only secondary/utility pages remaining
- App fully usable for daily operations

### 100% Complete (Production Ready)
- Every page translated
- All strings in all languages
- Full E2E testing completed
- Ready for production deployment

---

**Current Status:** 20% Complete  
**Next Milestone:** 30% (Batch 1)  
**Critical Milestone:** 50% (Batches 1-2)  
**Target:** 100% Complete

**Recommended Next Step:** Start Batch 1 (HomePage, SettingsPage, PatientListPage)

