# ⚡ Offline/Online Quick Reference

## 🎯 Core Rule

**Patient Registration = Internet Required ✅**
**AI Diagnosis = Internet Required ✅** (for patient safety)
**AI Model = Can run offline, but needs patient data online**

---

## 📱 What Requires Internet?

### ✅ MUST Have Internet:
1. **Patient Registration** - New patients must be in central database
2. **AI Diagnosis** - Needs complete patient record for safety
   - Check allergies before suggesting medications
   - Check chronic conditions (diabetes, hypertension, etc.)
   - Check current medications (drug interactions)
   - Check medical history
3. **First Login** - Authentication with backend
4. **Initial Setup** - Download AI model and datasets
5. **User Management** - Create/update users
6. **Data Sync** - Upload diagnoses to central database

### ⚠️ Limited Offline Mode:
1. **View Cached Patients** - Basic info only (no full medical history)
2. **Symptom Entry** - Can prepare diagnosis (saved for later)
3. **View Past Diagnoses** - Cached data only
4. **Emergency Mode** - Basic AI prediction without patient context (risky)

---

## 🔄 Typical Workflow

### Day 1: Setup (Needs Internet)
```
1. Install app
2. Login (requires internet)
3. Download AI model
4. Download datasets
5. Cache recent patients
✅ Ready to work offline
```

### Day 2: Remote Clinic (No Internet)
```
1. Open app (works offline)
2. View cached patients ✅ (basic info only)
3. Try to register new patient ❌
   → Show: "Patient registration requires internet"
4. Select existing patient ✅
5. Enter symptoms ✅
6. Try to run AI diagnosis ❌
   → Show: "AI diagnosis requires internet for patient safety"
   → Reason: Need to check allergies, chronic conditions, current meds
7. Option: Save symptoms for later diagnosis ✅
   → Will diagnose when online
8. Emergency Mode: Basic prediction without patient context ⚠️
   → Shows warning about missing patient data
```

### Day 3: Back Online
```
1. App detects internet ✅
2. Auto-sync starts
3. Upload all pending diagnoses
4. Download new patients
5. Update local cache
✅ All data synced
```

---

## 🚨 User Messages

### When Trying to Register Patient Offline:
```
❌ No Internet Connection

Patient registration requires internet to ensure 
data consistency across all clinics.

Please connect to internet to register new patients.

[Check Connection] [Cancel]
```

### When Trying to Diagnose Offline:
```
⚠️ Internet Required for Safe Diagnosis

AI diagnosis requires internet connection to:
• Check patient allergies
• Review chronic conditions
• Check current medications
• Verify medical history

This ensures we don't suggest medications that 
could harm the patient.

Options:
[Save Symptoms for Later] [Emergency Mode] [Cancel]
```

### Emergency Mode Warning:
```
⚠️ WARNING: Emergency Mode

You are about to run AI diagnosis WITHOUT patient 
medical history. This means:

❌ Allergies NOT checked
❌ Chronic conditions NOT considered
❌ Current medications NOT reviewed
❌ Drug interactions NOT verified

This mode should ONLY be used in life-threatening 
emergencies when internet is unavailable.

Do you want to continue?

[Yes, Emergency Only] [No, Wait for Internet]
```

### When Internet Becomes Available:
```
🔄 Syncing Data...

Uploading 3 diagnoses
Downloading updates

[View Details]
```

---

## 💡 Why This Approach?

### Patient Registration Needs Internet Because:
1. **Prevents Duplicates** - Central database checks for existing patients
2. **Unique IDs** - Server generates unique patient IDs
3. **Cross-Clinic Access** - Patient can visit any clinic
4. **Data Consistency** - All clinics have same patient data
5. **Audit Trail** - Central logging of all registrations

### AI Diagnosis Works Offline Because:
1. **Model is Local** - TensorFlow Lite runs on device
2. **Datasets Cached** - All medical data stored locally
3. **No Server Needed** - Prediction happens on device
4. **Fast Response** - No network latency
5. **Works Anywhere** - Remote areas without internet

---

## 🎯 Implementation Priority

### Phase 1: Basic Offline (Current)
- ✅ AI model runs locally
- ✅ Local database for caching
- ✅ Patient registration requires internet

### Phase 2: Smart Sync (Next)
- ⏳ Auto-sync when online
- ⏳ Sync queue management
- ⏳ Conflict resolution

### Phase 3: Advanced Offline (Future)
- ⏳ Offline patient search
- ⏳ Partial sync
- ⏳ Background sync

---

## 📊 Data Storage

### Local (SQLite on Device)
- Patients (cached, last 100)
- Diagnoses (pending sync)
- AI Model (TensorFlow Lite)
- Datasets (symptoms, diseases, medications)
- Sync Queue

### Central (PostgreSQL on Server)
- All Patients (master database)
- All Diagnoses (synced)
- All Users
- All Clinics
- Audit Logs

---

## ✅ Quick Checklist

**Before Going to Remote Area:**
- [ ] Login while online
- [ ] Ensure AI model is downloaded
- [ ] Cache recent patients
- [ ] Test offline diagnosis
- [ ] Verify sync queue is empty

**At Remote Clinic (Offline):**
- [ ] Can view cached patients ✅
- [ ] Cannot register new patients ❌
- [ ] Can create diagnoses ✅
- [ ] Diagnoses saved to sync queue ✅

**After Returning Online:**
- [ ] App auto-syncs pending data
- [ ] All diagnoses uploaded
- [ ] New patients downloaded
- [ ] Sync queue cleared

---

## 🎉 Summary

| Feature | Online | Offline |
|---------|--------|---------|
| Patient Registration | ✅ Yes | ❌ No |
| AI Diagnosis | ✅ Yes | ✅ Yes |
| View Patients | ✅ Yes | ✅ Yes (cached) |
| Create Diagnosis | ✅ Yes | ✅ Yes (synced later) |
| Data Sync | ✅ Yes | ❌ No |
| User Login | ✅ Yes | ⚠️ Cached token |

**Key Takeaway:**
- Register patients when you have internet
- Diagnose patients anytime (online or offline)
- Data syncs automatically when online

---

**Last Updated**: 2026-04-28
