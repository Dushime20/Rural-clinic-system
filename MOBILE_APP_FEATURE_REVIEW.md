# Mobile App Feature Review & Cleanup Plan

## Current Features Analysis

### ✅ **KEEP - Core Features (Fully Implemented & Essential)**

1. **Authentication**
   - ✅ Login
   - ✅ Forgot Password
   - ✅ Reset Password
   - ✅ Change Password
   - **Status**: Working, Essential

2. **AI Diagnosis**
   - ✅ Diagnosis Page (symptom input, vital signs)
   - ✅ Diagnosis Result Page
   - ✅ Diagnosis History
   - **Status**: Core feature, Keep

3. **Patient Management**
   - ✅ Patient List
   - ✅ Patient Details
   - ✅ Add Patient
   - ✅ Edit Patient
   - ✅ Patient Medical History
   - **Status**: Essential, Keep

4. **Pharmacies**
   - ✅ Pharmacy List
   - ✅ Pharmacy Details (with medicines)
   - ✅ Search by name, medicine, location
   - ✅ Call & Navigate features
   - **Status**: Recently enhanced, Keep

5. **Home Dashboard**
   - ✅ Home Page
   - **Status**: Entry point, Keep

---

### ⚠️ **REVIEW - Features to Evaluate**

6. **Analytics Dashboard**
   - 📁 Location: `features/analytics/`
   - 🔍 **Question**: Is this implemented? What analytics are shown?
   - 💡 **Recommendation**: Review if fully functional or just placeholder

7. **Settings**
   - 📁 Location: `features/settings/`
   - ✅ Theme switching
   - ✅ Language selection (EN, FR, RW)
   - 🔍 **Question**: What other settings exist?
   - 💡 **Recommendation**: Keep core settings, remove unused ones

8. **Help & Support**
   - 📁 Location: `features/settings/presentation/pages/help_support_page.dart`
   - 🔍 **Question**: Is this implemented or placeholder?
   - 💡 **Recommendation**: Implement basic help or remove

---

### ❌ **REMOVE - Features No Longer Needed**

9. **Sync Status** ⛔
   - 📁 Location: `features/sync/`
   - 📄 Files:
     - `sync_status_page.dart`
     - `offline_mode_page.dart`
   - 🗑️ **Reason**: You mentioned offline mode and sync are no longer needed
   - ✅ **Action**: Remove entire `features/sync/` directory
   - ✅ **Action**: Remove "Sync Status" from drawer menu
   - ✅ **Action**: Remove `/sync` and `/offline` routes

10. **Offline Mode** ⛔
    - 📁 Related to sync feature
    - 🗑️ **Reason**: No longer needed (online-only app)
    - ✅ **Action**: Remove offline-related code
    - ✅ **Action**: Remove Hive local storage (if only used for offline)

---

### 🔍 **INVESTIGATE - Unused/Incomplete Features**

11. **Appointment Management**
    - 📁 Location: `features/appointment/`
    - ❓ **Status**: Directory exists but not in menu/routes
    - 💡 **Decision Needed**: Implement or remove?

12. **Laboratory**
    - 📁 Location: `features/laboratory/`
    - ❓ **Status**: Directory exists but not in menu/routes
    - 💡 **Decision Needed**: Implement or remove?

13. **Prescription**
    - 📁 Location: `features/prescription/`
    - ❓ **Status**: Directory exists but not in menu/routes
    - 💡 **Decision Needed**: Implement or remove?

14. **Voice**
    - 📁 Location: `features/voice/`
    - ❓ **Status**: Directory exists but not in menu/routes
    - 💡 **Decision Needed**: Voice input for symptoms? Implement or remove?

---

## Cleanup Action Plan

### Phase 1: Remove Sync & Offline Features

**Files to Delete:**
```
features/sync/
  - presentation/pages/sync_status_page.dart
  - presentation/pages/offline_mode_page.dart
  - (entire sync directory)
```

**Code to Update:**
1. **custom_drawer.dart**
   - Remove "Sync Status" menu item
   - Remove `_showSyncStatus()` method

2. **main.dart**
   - Remove `/sync` route
   - Remove `/offline` route
   - Remove `SyncStatusPage` import
   - Remove `OfflineModePage` import

3. **app_constants.dart**
   - Remove sync-related constants:
     - `syncInterval`
     - `maxRetryAttempts`
     - `retryDelay`
     - `lastSyncKey`
     - `offlineModeKey`
     - `syncBox`
     - `syncError`
     - `syncSuccess`

4. **Hive Storage** (if only used for offline)
   - Remove Hive initialization if not needed
   - Remove local database boxes

---

### Phase 2: Review & Decide on Incomplete Features

**Questions to Answer:**

1. **Appointments** - Do you want appointment scheduling?
   - ✅ Yes → Implement
   - ❌ No → Remove directory

2. **Laboratory** - Do you want lab test orders/results?
   - ✅ Yes → Implement
   - ❌ No → Remove directory

3. **Prescriptions** - Do you want prescription management?
   - ✅ Yes → Implement (separate from diagnosis)
   - ❌ No → Remove directory (prescriptions in diagnosis are enough)

4. **Voice Input** - Do you want voice-to-text for symptoms?
   - ✅ Yes → Implement
   - ❌ No → Remove directory

5. **Analytics** - What analytics do you want?
   - Patient statistics
   - Diagnosis trends
   - Disease prevalence
   - Or remove if not needed

---

### Phase 3: Simplify Settings

**Keep:**
- Theme (Light/Dark)
- Language (EN, FR, RW)
- Profile settings
- Change password

**Remove (if exists):**
- Offline mode toggle
- Sync settings
- Any unused settings

---

### Phase 4: Clean Up Constants & Services

**Remove unused:**
- Offline-related services
- Sync services
- Local database code (if not needed)
- Unused constants

---

## Summary of Recommendations

### ✅ **KEEP (8 features)**
1. Authentication (Login, Password management)
2. AI Diagnosis
3. Patient Management
4. Pharmacies
5. Home Dashboard
6. Settings (simplified)
7. Help & Support (if implemented)
8. Analytics (if implemented)

### ❌ **REMOVE (2 features)**
1. Sync Status
2. Offline Mode

### ❓ **DECIDE (4 features)**
1. Appointments
2. Laboratory
3. Prescriptions
4. Voice Input

---

## Next Steps

**Please confirm:**

1. ✅ Remove Sync & Offline features?
2. ❓ What to do with Appointments, Laboratory, Prescriptions, Voice?
3. ❓ Keep Analytics or remove?
4. ❓ Any other features you want to add/remove?

Once you confirm, I'll proceed with the cleanup!
