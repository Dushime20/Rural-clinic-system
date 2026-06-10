# Quick Start Guide - Clinic Management Enhancement

## ⚡ Get Started in 3 Steps

### Step 1: Install Map Dependencies (2 minutes)

**Windows**:
```bash
# Run the installer script
./install-clinic-map-dependencies.bat
```

**Or manually**:
```bash
cd clinic_dashboard
npm install leaflet@^1.9.4 react-leaflet@^4.2.1 @types/leaflet@^1.9.8
```

---

### Step 2: Start Services (1 minute)

**Terminal 1 - Backend**:
```bash
cd ai_health_companion_backend
npm run dev
```

**Terminal 2 - Admin Dashboard**:
```bash
cd admin_dashboard
npm run dev
```

**Terminal 3 - Clinic Dashboard**:
```bash
cd clinic_dashboard
npm run dev
```

**Verify Running**:
- Backend: http://localhost:5000 ✅
- Admin: http://localhost:3000 ✅
- Clinic: http://localhost:5175 ✅

---

### Step 3: Test Features (5 minutes)

#### Test 1: Admin Creates Clinic
1. Go to http://localhost:3000
2. Login as admin
3. Click Clinics → Create Clinic
4. Enter:
   - Name: `Test Clinic`
   - Manager: `Dr. John Doe`
   - Email: `john@testclinic.com`
5. Click "Create Clinic"
6. **Copy the temporary password!**

✅ Expected: Single-step form, quick creation

#### Test 2: Clinic Logs In
1. Go to http://localhost:5175
2. Login with:
   - Email: `john@testclinic.com`
   - Password: *(from step 1)*
3. Change password when prompted
4. Enter new password twice
5. Click "Change Password"

✅ Expected: Forced password change, then dashboard access

#### Test 3: Clinic Completes Profile
1. Click "Profile" in sidebar
2. Click "Edit Profile"
3. **Try the Map!**:
   - Click "Detect My Location" OR
   - Click anywhere on the map
4. Watch lat/lng auto-fill ✨
5. Select specialties (check 2-3)
6. Add opening hours (optional)
7. Click "Save Changes"

✅ Expected: Map shows, location updates, profile saves

#### Test 4: View Prescriptions
1. Click "Prescriptions" in sidebar
2. View the list
3. Search for a patient
4. Click "View Details" on any row

✅ Expected: Table loads, search works, modal opens

---

## 🎉 Done!

All features are working! Here's what you now have:

### ✅ Admin Dashboard
- **Fast clinic creation** (3 fields, 30 seconds)
- Simple single-step form

### ✅ Clinic Dashboard
- **Interactive map** with GPS detection
- **Specialties** management (11 options)
- **Opening hours** editor (7 days)
- **Prescriptions** viewing page

---

## 📚 Need More Info?

- **Detailed Testing**: See `TESTING_GUIDE_CLINIC_UPDATES.md`
- **Feature Overview**: See `FINAL_IMPLEMENTATION_SUMMARY.md`
- **Map Feature**: See `CLINIC_MAP_FEATURE_ADDED.md`
- **Troubleshooting**: Check documentation files

---

## 🆘 Quick Troubleshooting

### Map not showing?
```bash
cd clinic_dashboard
npm install leaflet@^1.9.4 react-leaflet@^4.2.1 @types/leaflet@^1.9.8
# Then restart: npm run dev
```

### Import errors?
- Restart the dev server
- Clear browser cache (Ctrl+Shift+R)

### GPS not working?
- Grant browser permission when prompted
- Or click the map instead!

---

## ⏱️ Time Investment

- **Setup**: 3 minutes (install + start services)
- **Testing**: 5 minutes (all 4 tests)
- **Total**: 8 minutes to verify everything works!

---

**Ready to go!** 🚀

Start with Step 1 above, and you'll be testing in minutes.
