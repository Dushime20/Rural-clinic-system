# 🧪 Safe Diagnosis Testing Guide

## 🎯 What We're Testing

The new safe diagnosis system that:
1. ✅ Fetches complete patient medical record
2. ✅ Checks patient allergies
3. ✅ Checks drug interactions
4. ✅ Checks chronic conditions
5. ✅ Adjusts recommendations for patient safety

---

## 🚀 Quick Start

### Step 1: Start Services

```bash
# Terminal 1: Start Flask ML Service
cd ai_health_companion_backend/model-training
python api.py

# Terminal 2: Start Node.js Backend
cd ai_health_companion_backend
npm run dev
```

### Step 2: Run Tests

```bash
# Run unit tests
npm test patient-safety

# Run integration tests
npm test safe-diagnosis

# Run manual test script
node test-safe-diagnosis.js
```

---

## 🧪 Test Scenarios

### Scenario 1: Patient with Penicillin Allergy

**Setup:**
- Patient allergic to Penicillin
- Symptoms: fever, cough, sore throat
- Expected: Bacterial infection

**Expected Result:**
- ❌ Should NOT suggest Amoxicillin/Penicillin
- ✅ Should suggest Azithromycin or Ciprofloxacin
- 🚨 Should show "ALLERGY ALERT"
- ⚠️  Risk level: CRITICAL

**Test:**
```bash
curl -X POST http://localhost:5000/api/v1/diagnoses/safe \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": "patient-with-allergy-id",
    "symptoms": ["fever", "cough", "sore throat"],
    "vitalSigns": {
      "temperature": 38.5,
      "heartRate": 95
    }
  }'
```

---

### Scenario 2: Diabetic Patient

**Setup:**
- Patient has Diabetes
- Taking Metformin and Insulin
- Symptoms: fever, frequent urination, fatigue

**Expected Result:**
- ⚠️  Should warn about blood sugar monitoring
- ✅ Should adjust treatment for diabetes
- ⚠️  Should recommend insulin adjustment
- ⚠️  Risk level: MEDIUM or HIGH

---

### Scenario 3: Patient on Warfarin

**Setup:**
- Patient taking Warfarin (blood thinner)
- Symptoms: headache, joint pain

**Expected Result:**
- ❌ Should NOT suggest NSAIDs (Ibuprofen, Aspirin)
- 🚨 Should show "DRUG INTERACTION: bleeding risk"
- ✅ Should suggest Acetaminophen instead
- ⚠️  Risk level: CRITICAL

---

### Scenario 4: Child with Fever

**Setup:**
- Patient age: 8 years old
- Symptoms: fever, headache

**Expected Result:**
- ❌ Should NOT suggest Aspirin (Reye's syndrome risk)
- ✅ Should suggest Acetaminophen or Ibuprofen
- ⚠️  Should show age-based warning
- ⚠️  Risk level: MEDIUM

---

### Scenario 5: Complex Patient

**Setup:**
- Multiple allergies: Penicillin, Sulfa
- Multiple conditions: Diabetes, Hypertension, Kidney disease
- Multiple medications: Metformin, Amlodipine, Aspirin
- Age: 70+ years

**Expected Result:**
- 🚨 Multiple contraindications
- ⚠️  Multiple warnings
- 🏥 Should recommend specialist referral
- ⚠️  Risk level: CRITICAL

---

## 📊 Expected Test Results

### Unit Tests (patient-safety.test.ts)

```
✓ should detect penicillin allergy conflict
✓ should not flag safe medications
✓ should detect multiple allergy conflicts
✓ should suggest alternatives for allergic medications
✓ should detect warfarin-aspirin interaction
✓ should detect metformin-contrast interaction
✓ should not flag safe drug combinations
✓ should flag diabetes with infection
✓ should flag kidney disease with appropriate recommendations
✓ should not flag unrelated conditions
✓ should flag aspirin for children
✓ should flag NSAIDs for elderly
✓ should not flag safe medications for adults
✓ should pass safety check for safe scenario
✓ should fail safety check with allergy conflict
✓ should detect multiple safety issues
✓ should provide adjusted recommendations
✓ should return critical for contraindications
✓ should return high for multiple warnings
✓ should return medium for few warnings
✓ should return low for no issues

Test Suites: 1 passed, 1 total
Tests:       21 passed, 21 total
```

### Integration Tests (safe-diagnosis.integration.test.ts)

```
✓ should detect allergy and suggest alternatives
✓ should provide diabetes-specific warnings
✓ should handle multiple safety concerns
✓ should detect drug interactions with warfarin
✓ should avoid aspirin for children
✓ should adjust recommendations for elderly
✓ should allow emergency diagnosis with warnings
✓ should include all required safety information
✓ should throw error if patient not found

Test Suites: 1 passed, 1 total
Tests:       9 passed, 9 total
```

### Manual Test Script

```
🧪 Testing Safe Diagnosis System

✅ Flask ML Service: Running
✅ Node.js API: Running
✅ Login successful

1️⃣  Scenario 1: Patient with Penicillin Allergy
   ✅ Patient created
   ✅ Diagnosis completed
   🚨 ALLERGY ALERT: Patient allergic to Penicillin
   ✅ Alternative suggested: Azithromycin
   ✅ Test PASSED

2️⃣  Scenario 2: Diabetic Patient with Infection
   ✅ Patient created
   ✅ Diagnosis completed
   ⚠️  Warning: Monitor blood sugar closely
   ✅ Test PASSED

3️⃣  Scenario 3: Patient on Warfarin
   ✅ Patient created
   ✅ Diagnosis completed
   🚨 DRUG INTERACTION: Increased bleeding risk
   ✅ Test PASSED

4️⃣  Scenario 4: Child with Fever
   ✅ Patient created
   ✅ Diagnosis completed
   ⚠️  AGE CONSIDERATION: Aspirin not recommended
   ✅ Test PASSED

5️⃣  Scenario 5: Complex Patient
   ✅ Patient created
   ✅ Diagnosis completed
   🚨 Multiple contraindications detected
   🏥 Specialist referral required
   ✅ Test PASSED

📊 Test Summary
   Total scenarios: 5
   Passed: 5
   Failed: 0
   Success rate: 100%

🎉 All tests passed!
```

---

## 🔍 Verification Checklist

After running tests, verify:

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Manual test script completes successfully
- [ ] Allergy checking works correctly
- [ ] Drug interaction detection works
- [ ] Chronic condition warnings appear
- [ ] Age-based contraindications work
- [ ] Risk levels are calculated correctly
- [ ] Specialist referral logic works
- [ ] Emergency mode shows warnings

---

## 🐛 Troubleshooting

### Tests Fail: "Patient record not found"

**Solution:**
- Make sure database is running
- Run migrations: `npm run migration:run`
- Seed admin user: `npm run seed:admin`

### Tests Fail: "Flask ML service not available"

**Solution:**
```bash
cd model-training
python api.py
```

### Tests Fail: "Authentication failed"

**Solution:**
```bash
npm run seed:admin
# Use: admin@clinic.rw / Admin@1234
```

---

## 📝 Test Coverage

### What's Tested:

✅ Allergy checking (all common allergies)
✅ Drug interactions (major interactions)
✅ Chronic conditions (diabetes, hypertension, kidney, liver, heart, asthma)
✅ Age-based contraindications (pediatric, geriatric)
✅ Risk level calculation
✅ Recommendation adjustment
✅ Specialist referral logic
✅ Emergency mode
✅ Error handling

### What's NOT Tested (Future):

⏳ Pregnancy contraindications
⏳ Breastfeeding considerations
⏳ Genetic factors
⏳ Rare drug interactions
⏳ Complex multi-drug interactions

---

## 🎯 Success Criteria

Tests pass if:

1. ✅ All unit tests pass (21/21)
2. ✅ All integration tests pass (9/9)
3. ✅ Manual test scenarios pass (5/5)
4. ✅ Allergies are detected correctly
5. ✅ Drug interactions are flagged
6. ✅ Chronic conditions trigger warnings
7. ✅ Age contraindications work
8. ✅ Risk levels are appropriate
9. ✅ Recommendations are adjusted
10. ✅ No false positives (safe scenarios pass)

---

## 🚀 Next Steps

After tests pass:

1. ✅ Deploy to staging environment
2. ✅ Test with real patient data (anonymized)
3. ✅ Get medical professional review
4. ✅ Update mobile app to use new endpoint
5. ✅ Add more drug interaction rules
6. ✅ Add more allergy patterns
7. ✅ Monitor in production

---

**Last Updated**: 2026-04-28
**Test Status**: ✅ READY FOR TESTING
