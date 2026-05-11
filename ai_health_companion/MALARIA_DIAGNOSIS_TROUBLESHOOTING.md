# Malaria Diagnosis Troubleshooting

## Problem
App shows **Gastroenteritis** instead of **Malaria** even when selecting malaria symptoms.

---

## Possible Causes

### 1. **Wrong Symptoms Selected**
The app might have similar-sounding symptoms that don't match the model.

### 2. **Symptom Name Mismatch**
Flutter app uses Title Case ("High Fever") but model expects lowercase ("high fever").

### 3. **Missing Key Symptoms**
Not all required symptoms were selected.

### 4. **Temperature Not High Enough**
Vital signs adjustment might be lowering confidence.

---

## Solution: Exact Symptoms to Select

### ✅ **For Malaria, Select EXACTLY:**

1. **Chills** (not "Shivering" or "Cold")
2. **Vomiting** (not "Nausea" alone)
3. **High Fever** (not "Mild Fever" or just "Fever")
4. **Sweating** (not "Perspiration")
5. **Headache** (optional but helpful)

### ❌ **Common Mistakes:**

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| Fever | High Fever |
| Shivering | Chills |
| Nausea | Vomiting |
| Cold | Chills |
| Perspiring | Sweating |

---

## Step-by-Step Fix

### Step 1: Check Symptom Names in App

The symptoms in `symptoms_constants.dart` should match:
```dart
'Chills',          // ✅ Correct
'Vomiting',        // ✅ Correct  
'High Fever',      // ✅ Correct
'Sweating',        // ✅ Correct
'Headache',        // ✅ Correct
```

NOT:
```dart
'Fever',           // ❌ Wrong - too generic
'Shivering',       // ❌ Wrong - different symptom
'Nausea',          // ❌ Wrong - not strong enough
```

### Step 2: Verify Vital Signs

```
Temperature: 39.0°C or higher
(38.5°C minimum for malaria)
```

If temperature is <38.5°C, the model might predict something else.

### Step 3: Check Backend Logs

If Flask ML service is running, check what symptoms it received:

```bash
# In Flask terminal, you should see:
Received symptoms: ['chills', 'vomiting', 'high fever', 'sweating', 'headache']
Corrected: ['chills', 'vomiting', 'high fever', 'sweating', 'headache']
Prediction: Malaria (confidence: 0.78)
```

---

## Test Cases

### Test 1: Minimal Malaria (Should work)
```
Symptoms:
✓ Chills
✓ Vomiting
✓ High Fever
✓ Sweating

Vital Signs:
Temperature: 39.0°C

Expected: Malaria (75-80%)
```

### Test 2: Complete Malaria (Best result)
```
Symptoms:
✓ Chills
✓ Vomiting
✓ High Fever
✓ Sweating
✓ Headache

Vital Signs:
Temperature: 39.5°C
Heart Rate: 95 bpm

Expected: Malaria (80-85%)
```

### Test 3: Wrong Symptoms (Will fail)
```
Symptoms:
✓ Fever (not "High Fever")
✓ Nausea (not "Vomiting")
✓ Shivering (not "Chills")

Expected: NOT Malaria (will predict something else)
```

---

## Debugging Steps

### 1. Check Flutter App Symptoms List

```bash
cd ai_health_companion
grep -A 5 "High Fever" lib/core/constants/symptoms_constants.dart
```

Should show:
```dart
'High Fever',
```

### 2. Test Flask ML Service Directly

```bash
cd ai_health_companion_backend
node test-malaria-diagnosis.js
```

This will test different symptom formats.

### 3. Check Backend Logs

Start Flask with verbose logging:
```bash
cd model-training
python api.py
```

Watch for:
```
Received symptoms: [...]
Corrected: [...]
Prediction: ...
```

### 4. Verify Symptom Matching

```bash
curl -X POST http://localhost:5001/api/v1/validate-symptoms \
  -H "Content-Type: application/json" \
  -d '{"symptoms": ["chills", "vomiting", "high fever", "sweating"]}'
```

Should return:
```json
{
  "success": true,
  "results": [
    {"original": "chills", "corrected": "chills", "valid": true},
    {"original": "vomiting", "corrected": "vomiting", "valid": true},
    {"original": "high fever", "corrected": "high fever", "valid": true},
    {"original": "sweating", "corrected": "sweating", "valid": true}
  ]
}
```

---

## Quick Fix

If symptoms are correct but still not working, try:

### Option 1: Add More Symptoms
```
✓ Chills
✓ Vomiting
✓ High Fever
✓ Sweating
✓ Headache
✓ Fatigue        ← Add this
✓ Muscle Pain    ← Add this
```

### Option 2: Increase Temperature
```
Temperature: 40.0°C (instead of 39.0°C)
```

### Option 3: Add Medical History
```
✓ Malaria (Previous)
```

---

## Why Gastroenteritis Instead?

Gastroenteritis symptoms:
- Vomiting ✓
- Diarrhea
- Dehydration
- Sunken eyes

If you selected "Vomiting" but NOT "High Fever" or "Chills", the model will predict Gastroenteritis.

**Solution:** Make sure you select **High Fever** and **Chills** together with Vomiting!

---

## Contact for Help

If still not working:

1. **Check symptoms selected** - Screenshot the symptoms tab
2. **Check vital signs** - Screenshot the vital signs tab
3. **Check backend logs** - Copy Flask terminal output
4. **Run test script** - `node test-malaria-diagnosis.js`

---

## Expected Behavior

When working correctly:

```
Input:
- Chills
- Vomiting  
- High Fever (39.5°C)
- Sweating
- Headache

Output:
Primary Diagnosis: Malaria (78-85%)
ICD-10: B54

Differential:
1. Malaria (85%)
2. Typhoid (12%)
3. Dengue (8%)
```

NOT:
```
Primary Diagnosis: Gastroenteritis (78%)  ← Wrong!
```

