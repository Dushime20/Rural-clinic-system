# Complete Example: Safe AI Diagnosis with Past Patient Records

## Real-World Scenario

**Patient**: Maria, 45-year-old female diabetic patient
**Presenting Symptoms**: Fever, frequent urination, fatigue
**Medical History**: 
- Diabetes (diagnosed 2 years ago)
- Penicillin allergy
- Current medications: Metformin 500mg
- Past diagnoses: UTI (2 months ago), UTI (4 months ago)

## Step-by-Step Flow

### 1. Patient Context Retrieval

```typescript
// Automatically fetched from database
const patientContext = {
  patientId: "maria-123",
  allergies: ["Penicillin"],
  chronicConditions: ["Diabetes"],
  currentMedications: ["Metformin 500mg"],
  age: 45,
  gender: "female",
  pastDiagnoses: [
    {
      disease: "Urinary tract infection",
      diagnosisDate: "2026-02-15",
      medications: ["Ciprofloxacin"]
    },
    {
      disease: "Urinary tract infection",
      diagnosisDate: "2025-12-20",
      medications: ["Ciprofloxacin"]
    }
  ]
}
```

### 2. AI Prediction Request

```typescript
// Request to Flask ML service
POST http://localhost:5001/api/v1/predict
{
  "symptoms": [
    "fever",
    "frequent urination",
    "fatigue"
  ],
  "vitalSigns": {
    "temperature": 38.5,
    "bloodPressureSystolic": 130,
    "bloodPressureDiastolic": 85,
    "heartRate": 88
  },
  "demographics": {
    "age": 45,
    "gender": "female"
  }
}
```

### 3. AI Prediction Response

```json
{
  "success": true,
  "prediction": {
    "disease": "Urinary tract infection",
    "icd10Code": "N39.0",
    "confidence": 0.87,
    "symptoms_used": ["fever", "frequent urination", "fatigue"]
  },
  "information": {
    "description": "Urinary tract infection (UTI) is an infection in any part of the urinary system...",
    "medications": [
      "Amoxicillin 500mg",
      "Ciprofloxacin 500mg",
      "Trimethoprim 200mg"
    ],
    "precautions": [
      "Drink plenty of water",
      "Avoid caffeine and alcohol",
      "Complete full antibiotic course",
      "Practice good hygiene"
    ],
    "diet": [
      "Cranberry juice",
      "Probiotics",
      "Vitamin C rich foods"
    ],
    "workout": [
      "Light walking",
      "Avoid strenuous exercise until infection clears"
    ]
  }
}
```

### 4. Safety Checks Performed

#### Check 1: Allergy Conflicts 🚨
```
Patient allergic to: Penicillin
Suggested medications: Amoxicillin, Ciprofloxacin, Trimethoprim

⚠️ CONFLICT DETECTED!
- Amoxicillin contains penicillin → CONTRAINDICATED
- Safe alternatives: Ciprofloxacin, Levofloxacin, Azithromycin
```

#### Check 2: Drug Interactions
```
Current medications: Metformin 500mg
Suggested medications: Ciprofloxacin, Trimethoprim

✅ NO INTERACTIONS DETECTED
```

#### Check 3: Chronic Conditions
```
Patient has: Diabetes
Current disease: Urinary tract infection

⚠️ DIABETES + INFECTION RISK
Recommendations:
- Monitor blood sugar closely during treatment
- Adjust insulin dosage if needed
- Watch for signs of diabetic complications
- Ensure adequate hydration
```

#### Check 4: Age Contraindications
```
Patient age: 45 years
Suggested medications: Ciprofloxacin, Trimethoprim

✅ NO AGE-RELATED CONTRAINDICATIONS
```

#### Check 5: Past Diagnosis Patterns 📋 NEW!
```
Past diagnoses:
- UTI (2 months ago)
- UTI (4 months ago)
Current diagnosis: UTI

⚠️ PATTERN DETECTED: Recurring UTI (3rd occurrence in 6 months)

Recommendations:
- Investigate underlying cause (diabetes may be contributing)
- Consider antibiotic resistance testing
- Review patient compliance with previous treatment
- May need longer antibiotic course (7-10 days instead of 3-5)
- Consider prophylactic measures
- Refer to urologist if pattern continues
```

### 5. Adjusted Recommendations

```typescript
{
  "safeRecommendations": {
    "medications": [
      "Ciprofloxacin 500mg (safe - no allergy conflict)",
      "Trimethoprim 200mg (safe - no allergy conflict)"
      // Amoxicillin REMOVED due to penicillin allergy
    ],
    "precautions": [
      "Drink plenty of water",
      "Avoid caffeine and alcohol",
      "Complete full antibiotic course",
      "Practice good hygiene",
      // ADDED FROM SAFETY CHECKS:
      "Monitor blood sugar closely during treatment",
      "Adjust insulin dosage if needed",
      "Watch for signs of diabetic complications",
      "Ensure adequate hydration"
    ],
    "warnings": [
      "⚠️ Patient has Diabetes - requires special consideration",
      "📋 MEDICAL HISTORY: Recurring UTI (3rd occurrence in 6 months)"
    ],
    "contraindications": [
      "🚨 ALLERGY ALERT: Patient allergic to Penicillin",
      "❌ DO NOT PRESCRIBE: Amoxicillin (contains penicillin)"
    ]
  },
  "requiresSpecialistReferral": true,
  "referralReason": "Recurring UTI with diabetes - needs specialist evaluation"
}
```

### 6. Final Diagnosis Result

```json
{
  "success": true,
  "prediction": {
    "disease": "Urinary tract infection",
    "icd10Code": "N39.0",
    "confidence": 0.87,
    "symptomsUsed": ["fever", "frequent urination", "fatigue"]
  },
  "patientContext": {
    "patientId": "maria-123",
    "allergies": ["Penicillin"],
    "chronicConditions": ["Diabetes"],
    "currentMedications": ["Metformin 500mg"],
    "age": 45,
    "gender": "female"
  },
  "safetyCheck": {
    "passed": false,
    "warnings": [
      "⚠️ Patient has Diabetes - requires special consideration",
      "📋 MEDICAL HISTORY: Recurring UTI (3rd occurrence in 6 months)"
    ],
    "contraindications": [
      "🚨 ALLERGY ALERT: Patient allergic to Penicillin"
    ],
    "adjustedRecommendations": [
      "Use alternative medications: Ciprofloxacin, Levofloxacin",
      "Monitor blood sugar closely during treatment",
      "Adjust insulin dosage if needed",
      "Watch for signs of diabetic complications",
      "Ensure adequate hydration",
      "Investigate underlying cause (diabetes may be contributing)",
      "Consider antibiotic resistance testing",
      "Review patient compliance with previous treatment",
      "May need longer antibiotic course (7-10 days)",
      "Consider prophylactic measures",
      "Refer to urologist if pattern continues"
    ],
    "riskLevel": "critical"
  },
  "originalRecommendations": {
    "medications": ["Amoxicillin 500mg", "Ciprofloxacin 500mg", "Trimethoprim 200mg"],
    "precautions": ["Drink plenty of water", "Avoid caffeine and alcohol", "Complete full antibiotic course", "Practice good hygiene"],
    "diet": ["Cranberry juice", "Probiotics", "Vitamin C rich foods"],
    "workout": ["Light walking", "Avoid strenuous exercise until infection clears"]
  },
  "safeRecommendations": {
    "medications": ["Ciprofloxacin 500mg", "Trimethoprim 200mg"],
    "precautions": [
      "Drink plenty of water",
      "Avoid caffeine and alcohol",
      "Complete full antibiotic course",
      "Practice good hygiene",
      "Monitor blood sugar closely during treatment",
      "Adjust insulin dosage if needed",
      "Watch for signs of diabetic complications",
      "Ensure adequate hydration"
    ],
    "diet": ["Cranberry juice", "Probiotics", "Vitamin C rich foods"],
    "workout": ["Light walking", "Avoid strenuous exercise until infection clears"],
    "warnings": [
      "⚠️ Patient has Diabetes - requires special consideration",
      "📋 MEDICAL HISTORY: Recurring UTI (3rd occurrence in 6 months)"
    ],
    "contraindications": [
      "🚨 ALLERGY ALERT: Patient allergic to Penicillin",
      "❌ DO NOT PRESCRIBE: Amoxicillin"
    ]
  },
  "requiresSpecialistReferral": true,
  "timestamp": "2026-04-28T14:30:00.000Z"
}
```

## Mobile App Display

### Diagnosis Screen

```
┌─────────────────────────────────────────┐
│  🏥 Diagnosis Result                    │
├─────────────────────────────────────────┤
│                                         │
│  Patient: Maria (45F)                   │
│  Date: April 28, 2026                   │
│                                         │
│  🔍 Diagnosis                           │
│  Urinary Tract Infection (UTI)          │
│  ICD-10: N39.0                          │
│  Confidence: 87%                        │
│                                         │
├─────────────────────────────────────────┤
│  🚨 CRITICAL ALERTS                     │
├─────────────────────────────────────────┤
│  ⚠️ ALLERGY ALERT                       │
│  Patient allergic to Penicillin         │
│  DO NOT PRESCRIBE: Amoxicillin          │
│                                         │
│  📋 RECURRING CONDITION                 │
│  3rd UTI in 6 months                    │
│  Specialist referral recommended        │
│                                         │
├─────────────────────────────────────────┤
│  💊 Safe Medications                    │
├─────────────────────────────────────────┤
│  ✅ Ciprofloxacin 500mg                 │
│     Take twice daily for 7-10 days      │
│                                         │
│  ✅ Trimethoprim 200mg                  │
│     Alternative option                  │
│                                         │
│  ❌ Amoxicillin (CONTRAINDICATED)       │
│     Contains penicillin - AVOID         │
│                                         │
├─────────────────────────────────────────┤
│  ⚠️ Special Considerations              │
├─────────────────────────────────────────┤
│  • Patient has Diabetes                 │
│  • Monitor blood sugar closely          │
│  • Adjust insulin if needed             │
│  • Ensure adequate hydration            │
│  • Complete full antibiotic course      │
│                                         │
├─────────────────────────────────────────┤
│  📋 Medical History Pattern             │
├─────────────────────────────────────────┤
│  Recurring UTI detected                 │
│                                         │
│  Previous occurrences:                  │
│  • Feb 15, 2026 (2 months ago)          │
│  • Dec 20, 2025 (4 months ago)          │
│                                         │
│  Recommendations:                       │
│  • Investigate underlying cause         │
│  • Consider resistance testing          │
│  • May need longer treatment            │
│  • Refer to urologist                   │
│                                         │
├─────────────────────────────────────────┤
│  🏥 Specialist Referral Required        │
├─────────────────────────────────────────┤
│  Reason: Recurring UTI with diabetes    │
│                                         │
│  [Schedule Referral]                    │
│                                         │
├─────────────────────────────────────────┤
│  📝 Precautions                         │
├─────────────────────────────────────────┤
│  • Drink plenty of water (8-10 glasses) │
│  • Avoid caffeine and alcohol           │
│  • Practice good hygiene                │
│  • Monitor blood sugar 3x daily         │
│                                         │
├─────────────────────────────────────────┤
│  🥗 Diet Recommendations                │
├─────────────────────────────────────────┤
│  • Cranberry juice                      │
│  • Probiotics                           │
│  • Vitamin C rich foods                 │
│                                         │
├─────────────────────────────────────────┤
│  [Print Prescription]  [Save]           │
└─────────────────────────────────────────┘
```

## Why This Matters

### Without Past Diagnosis Checking ❌
```
Diagnosis: UTI
Medication: Amoxicillin 500mg (3-5 days)
Result: 
- Patient has allergic reaction (penicillin allergy not checked)
- UTI returns in 2 months (pattern not recognized)
- Diabetes complications not considered
```

### With Past Diagnosis Checking ✅
```
Diagnosis: UTI (3rd recurrence)
Medication: Ciprofloxacin 500mg (7-10 days, longer course)
Safety Checks:
- ✅ Allergy checked - Amoxicillin avoided
- ✅ Diabetes considered - blood sugar monitoring added
- ✅ Pattern recognized - specialist referral recommended
- ✅ Longer treatment course to prevent recurrence
Result:
- Patient receives safe medication
- Underlying cause investigated
- Better chance of preventing future UTIs
```

## Code Implementation

### API Endpoint
```typescript
// src/routes/diagnosis.routes.ts
router.post('/safe', authenticate, async (req, res) => {
  try {
    const result = await safeDiagnosisService.diagnoseWithSafety(req.body);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### Mobile App Call
```dart
// lib/services/diagnosis_service.dart
Future<SafeDiagnosisResult> diagnoseSafely({
  required String patientId,
  required List<String> symptoms,
  required VitalSigns vitalSigns,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/v1/diagnoses/safe'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'patientId': patientId,
      'symptoms': symptoms,
      'vitalSigns': vitalSigns.toJson(),
    }),
  );
  
  if (response.statusCode == 200) {
    return SafeDiagnosisResult.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Diagnosis failed: ${response.body}');
  }
}
```

## Testing

### Run the Example
```bash
# 1. Start Flask ML service
cd ai_health_companion_backend/model-training
python api.py

# 2. Start Node.js backend
cd ai_health_companion_backend
npm run dev

# 3. Run manual test
node test-safe-diagnosis.js

# 4. Run automated tests
npm test
```

### Expected Output
```
✅ Patient context loaded: 1 allergies, 1 conditions, 1 medications
✅ AI prediction: Urinary tract infection (confidence: 0.87)
✅ Safety check complete: FAILED (risk level: critical)
⚠️ Allergy conflict detected: Amoxicillin
⚠️ Chronic condition risk: Diabetes + Infection
📋 Pattern detected: Recurring UTI (3rd occurrence)
✅ Recommendations adjusted
✅ Specialist referral recommended
```

## Conclusion

This example demonstrates how the complete system works:

1. **Patient context** is automatically fetched from the database
2. **AI prediction** is obtained from Flask ML service
3. **Comprehensive safety checks** are performed:
   - Allergy conflicts
   - Drug interactions
   - Chronic conditions
   - Age contraindications
   - **Past diagnosis patterns** ← NEW!
4. **Recommendations are adjusted** based on safety checks
5. **Specialist referral** is recommended when needed
6. **Complete information** is returned to the mobile app

**Result**: Safe, personalized, and effective diagnosis that considers the patient's complete medical history! 🎉
