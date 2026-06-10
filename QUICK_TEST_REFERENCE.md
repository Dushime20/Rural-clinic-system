# Quick Test Reference: Dynamic Clinic Messages

## 🎯 Quick Test Checklist

### Before Testing
- [ ] Backend running on port 5000
- [ ] Flutter app fully restarted (not just hot reload)
- [ ] Test patient logged in
- [ ] Location services enabled

---

## 📋 Test Scenarios Summary

| Scenario | Condition | Pharmacies | Key Message Words |
|----------|-----------|------------|-------------------|
| 1 | Persistent | ✅ | "While pharmacies available...also clinic" |
| 2 | Persistent | ❌ | "recommend clinic for evaluation" |
| 3 | Recurring | ✅ | "In addition to pharmacies...prevent occurrences" |
| 4 | Recurring | ❌ | "provide comprehensive care" |
| 5 | Chronic | ✅ | "medication available...long-term management" |
| 6 | Chronic | ❌ | "long-term management...chronic conditions" |
| 7 | No Pharmacy | ❌ | "No nearby pharmacies found" |
| 8 | Default | ✅ | "medication available...comprehensive care" |
| 9 | Default | ❌ | "recommend consulting clinics" |

---

## 🔍 What to Look For

### Message Location
```
┌─────────────────────────────────────┐
│  Clinic Recommendations             │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐  │
│  │ ℹ️  [DYNAMIC MESSAGE HERE]    │  │ ← Should change based on scenario
│  └───────────────────────────────┘  │
│                                     │
│  [Clinic Cards Below]               │
└─────────────────────────────────────┘
```

### Color Coding
- **Blue box** = Info message
- **ℹ️ icon** = Information indicator
- **Bold text** = Message should be clear and readable

---

## 🚀 Fast Testing Method

### Test Persistent (Scenarios 1-2)
```bash
1. Create diagnosis for "Common Cold"
2. Create SAME diagnosis again (within 30 days)
3. Toggle pharmacy availability:
   - With pharmacies: See "While pharmacies available..."
   - Without pharmacies: See "recommend clinic for evaluation"
```

### Test Recurring (Scenarios 3-4)
```bash
1. Create "Migraine" diagnosis
2. Create 2 more times (3 total in 90 days)
3. Toggle pharmacy availability:
   - With pharmacies: See "In addition to pharmacies..."
   - Without pharmacies: See "provide comprehensive care"
```

### Test Chronic (Scenarios 5-6)
```bash
1. Create "Diabetes" or "Hypertension" diagnosis
2. Toggle pharmacy availability:
   - With pharmacies: See "medication available...long-term"
   - Without pharmacies: See "long-term management...chronic"
```

### Test No Pharmacy (Scenario 7)
```bash
1. Create any diagnosis with prescriptions
2. Test in location with NO pharmacies
3. See: "No nearby pharmacies found"
```

### Test Default (Scenarios 8-9)
```bash
1. Create regular diagnosis (e.g., "Headache")
2. Toggle pharmacy availability:
   - With pharmacies: See "medication available...comprehensive"
   - Without pharmacies: See "recommend consulting clinics"
```

---

## 🐛 Debug Commands

### Check Backend Response
```bash
# In backend console, look for:
POST /diagnosis/analyze
GET /diagnosis/:id

# Check JSON response for:
"clinicRecommendationReason": "persistent|recurring|chronic|no pharmacy"
"pharmacies": [...] // empty or non-empty
```

### Check Flutter State
```dart
// Add to diagnosis_result_page.dart
print('Has pharmacies: ${_diagnosis?.hasPharmacies}');
print('Reason: ${_diagnosis?.recommendations?.clinicRecommendationReason}');
```

---

## ✅ Pass/Fail Criteria

### ✅ PASS if:
- Message changes based on disease pattern
- Message mentions pharmacies only when available
- Message is grammatically correct
- No crashes or errors
- Blue info box appears correctly

### ❌ FAIL if:
- Same message for all scenarios
- Message mentions pharmacies when none available
- Message doesn't mention pharmacies when they exist
- UI doesn't display properly
- App crashes

---

## 📝 Quick Notes Template

```
Scenario #: ___
Disease: _______
Has Pharmacies: Yes / No
Expected: ______________________
Actual: ________________________
Status: ✅ Pass / ❌ Fail
```

---

## 🎨 Expected UI Behavior

### When Pharmacies Available
- Pharmacy section shows cards
- Message acknowledges pharmacy availability
- Message ALSO recommends clinics

### When No Pharmacies
- Pharmacy section shows "No nearby pharmacies"
- Message does NOT mention pharmacies
- Message focuses on clinic importance

### Always
- Blue info box with ℹ️ icon
- Clear, readable message
- Clinic cards below message
- Specialty filters (if applicable)

---

## ⚡ Speed Test (5 minutes)

1. **Minute 1**: Test persistent with pharmacies (Scenario 1)
2. **Minute 2**: Test persistent without pharmacies (Scenario 2)
3. **Minute 3**: Test chronic with pharmacies (Scenario 5)
4. **Minute 4**: Test no pharmacy case (Scenario 7)
5. **Minute 5**: Test default with pharmacies (Scenario 8)

If these 5 pass, the logic is working correctly!

---

## 📞 Need Help?

**Message not changing?**
- Restart Flutter app (full restart, not hot reload)
- Check backend is sending correct `clinicRecommendationReason`

**Wrong pharmacies showing?**
- Check patient location
- Verify pharmacy database has correct locations

**Clinics not appearing?**
- Ensure clinics exist in database
- Check clinic has valid lat/lng coordinates
- Verify clinic is not at (0, 0)

---

## 🎉 Success!

When all tests pass:
1. Document any edge cases found
2. Update TESTING_GUIDE_DYNAMIC_CLINIC_MESSAGES.md
3. Mark feature as production-ready
4. Celebrate! 🎊
