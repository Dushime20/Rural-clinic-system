# 🏥 Patient Safety Requirements - AI Diagnosis

## ⚠️ Critical Safety Rule

**AI diagnosis MUST have internet connection to access complete patient medical records.**

---

## 🚨 Why Internet is Required for Diagnosis

### 1. Allergy Checking (CRITICAL)
```
Patient: John Doe
Symptoms: Skin infection
AI Suggests: Penicillin-based antibiotic

❌ WITHOUT Patient Record:
   → Prescribe Penicillin
   → Patient has Penicillin allergy
   → LIFE-THREATENING REACTION

✅ WITH Patient Record:
   → Check allergies: "Penicillin allergy"
   → AI suggests alternative: Azithromycin
   → SAFE TREATMENT
```

### 2. Chronic Conditions (CRITICAL)
```
Patient: Jane Smith
Symptoms: Headache, fatigue
AI Suggests: Ibuprofen

❌ WITHOUT Patient Record:
   → Prescribe Ibuprofen
   → Patient has kidney disease
   → KIDNEY DAMAGE RISK

✅ WITH Patient Record:
   → Check conditions: "Chronic kidney disease"
   → AI suggests alternative: Acetaminophen
   → SAFE TREATMENT
```

### 3. Current Medications (CRITICAL)
```
Patient: Bob Johnson
Symptoms: Anxiety
AI Suggests: Benzodiazepine

❌ WITHOUT Patient Record:
   → Prescribe Benzodiazepine
   → Patient taking opioids
   → DANGEROUS DRUG INTERACTION

✅ WITH Patient Record:
   → Check medications: "Opioid pain medication"
   → AI warns: "Dangerous interaction"
   → Suggest alternative or refer to specialist
   → SAFE TREATMENT
```

### 4. Medical History (IMPORTANT)
```
Patient: Alice Brown
Symptoms: Chest pain
AI Suggests: Antacid

❌ WITHOUT Patient Record:
   → Treat as indigestion
   → Patient has heart disease history
   → MISSED HEART ATTACK

✅ WITH Patient Record:
   → Check history: "Previous heart attack"
   → AI flags: "High-risk patient"
   → Immediate referral to hospital
   → LIFE SAVED
```

---

## 🏗️ Enhanced Architecture

### AI Diagnosis Flow with Patient Safety

```
User selects patient
    ↓
Check internet connection
    ↓
    ├─ ❌ No Internet
    │   ↓
    │   Show warning: "Internet required for safe diagnosis"
    │   ↓
    │   Options:
    │   ├─ Save symptoms for later ✅
    │   ├─ Emergency mode (with warnings) ⚠️
    │   └─ Cancel ❌
    │
    └─ ✅ Has Internet
        ↓
    Fetch complete patient record from backend
        ↓
    ┌─────────────────────────────────────┐
    │  Patient Medical Record             │
    ├─────────────────────────────────────┤
    │  • Allergies                        │
    │  • Chronic conditions               │
    │  • Current medications              │
    │  • Past diagnoses                   │
    │  • Medical history                  │
    │  • Family history                   │
    └─────────────────────────────────────┘
        ↓
    Enter symptoms + vital signs
        ↓
    Send to AI service with patient context
        ↓
    ┌─────────────────────────────────────┐
    │  AI Analysis                        │
    ├─────────────────────────────────────┤
    │  1. Predict disease (local model)   │
    │  2. Check allergies                 │
    │  3. Check drug interactions         │
    │  4. Check contraindications         │
    │  5. Adjust recommendations          │
    └─────────────────────────────────────┘
        ↓
    ┌─────────────────────────────────────┐
    │  Safe Recommendations               │
    ├─────────────────────────────────────┤
    │  ✅ Disease: Bacterial infection    │
    │  ✅ Medication: Azithromycin        │
    │     (Penicillin avoided - allergy)  │
    │  ✅ Dosage: Adjusted for kidney     │
    │  ✅ Warnings: Monitor blood sugar   │
    │     (patient has diabetes)          │
    └─────────────────────────────────────┘
        ↓
    Display to health worker
        ↓
    Save diagnosis with safety checks
        ↓
    ✅ Safe treatment plan
```

---

## 🔒 Safety Checks Implementation

### Backend API Enhancement

```typescript
// src/services/ai-diagnosis.service.ts

interface PatientContext {
  allergies: string[];
  chronicConditions: string[];
  currentMedications: string[];
  pastDiagnoses: Diagnosis[];
  medicalHistory: string[];
  familyHistory?: string[];
}

interface SafetyCheck {
  passed: boolean;
  warnings: string[];
  contraindications: string[];
  adjustedRecommendations: string[];
}

export class AIDiagnosisService {
  
  async diagnoseWithSafety(
    patientId: string,
    symptoms: string[],
    vitalSigns: VitalSigns
  ): Promise<SafeDiagnosisResult> {
    
    // 1. Fetch complete patient record
    const patient = await this.getCompletePatientRecord(patientId);
    
    if (!patient) {
      throw new Error('Patient record not found');
    }
    
    // 2. Get AI prediction
    const prediction = await flaskMLService.predictDisease({
      symptoms,
      vitalSigns,
      demographics: {
        age: this.calculateAge(patient.dateOfBirth),
        gender: patient.gender
      }
    });
    
    // 3. Run safety checks
    const safetyCheck = await this.runSafetyChecks(
      prediction,
      patient
    );
    
    // 4. Adjust recommendations based on patient context
    const safeRecommendations = this.adjustRecommendations(
      prediction.information,
      patient,
      safetyCheck
    );
    
    return {
      prediction: prediction.prediction,
      safetyCheck,
      recommendations: safeRecommendations,
      patientContext: {
        allergies: patient.allergies,
        chronicConditions: patient.chronicConditions,
        currentMedications: patient.currentMedications
      }
    };
  }
  
  private async runSafetyChecks(
    prediction: any,
    patient: Patient
  ): Promise<SafetyCheck> {
    
    const warnings: string[] = [];
    const contraindications: string[] = [];
    const adjustedRecommendations: string[] = [];
    
    // Check 1: Allergies
    const allergyCheck = this.checkAllergies(
      prediction.information.medications,
      patient.allergies
    );
    
    if (allergyCheck.hasConflict) {
      contraindications.push(
        `⚠️ ALLERGY ALERT: Patient allergic to ${allergyCheck.conflictingMeds.join(', ')}`
      );
      adjustedRecommendations.push(
        `Use alternative medications: ${allergyCheck.alternatives.join(', ')}`
      );
    }
    
    // Check 2: Chronic Conditions
    const conditionCheck = this.checkChronicConditions(
      prediction.prediction.disease,
      patient.chronicConditions
    );
    
    if (conditionCheck.hasRisk) {
      warnings.push(
        `⚠️ Patient has ${conditionCheck.conditions.join(', ')} - monitor closely`
      );
      adjustedRecommendations.push(...conditionCheck.recommendations);
    }
    
    // Check 3: Drug Interactions
    const drugCheck = this.checkDrugInteractions(
      prediction.information.medications,
      patient.currentMedications
    );
    
    if (drugCheck.hasInteraction) {
      contraindications.push(
        `⚠️ DRUG INTERACTION: ${drugCheck.interactions.join(', ')}`
      );
      adjustedRecommendations.push(
        `Avoid: ${drugCheck.conflictingMeds.join(', ')}`
      );
    }
    
    // Check 4: Age-based contraindications
    const age = this.calculateAge(patient.dateOfBirth);
    const ageCheck = this.checkAgeContraindications(
      prediction.information.medications,
      age
    );
    
    if (ageCheck.hasContraindication) {
      contraindications.push(
        `⚠️ AGE CONTRAINDICATION: ${ageCheck.reason}`
      );
      adjustedRecommendations.push(...ageCheck.alternatives);
    }
    
    const passed = contraindications.length === 0;
    
    return {
      passed,
      warnings,
      contraindications,
      adjustedRecommendations
    };
  }
  
  private checkAllergies(
    suggestedMeds: string[],
    patientAllergies: string[]
  ): AllergyCheckResult {
    
    const conflictingMeds: string[] = [];
    const alternatives: string[] = [];
    
    // Drug allergy database
    const allergyDatabase = {
      'penicillin': {
        drugs: ['amoxicillin', 'ampicillin', 'penicillin'],
        alternatives: ['azithromycin', 'ciprofloxacin']
      },
      'sulfa': {
        drugs: ['sulfamethoxazole', 'trimethoprim'],
        alternatives: ['doxycycline', 'levofloxacin']
      },
      'aspirin': {
        drugs: ['aspirin', 'ibuprofen', 'naproxen'],
        alternatives: ['acetaminophen', 'celecoxib']
      }
    };
    
    for (const allergy of patientAllergies) {
      const allergyInfo = allergyDatabase[allergy.toLowerCase()];
      
      if (allergyInfo) {
        for (const med of suggestedMeds) {
          if (allergyInfo.drugs.some(drug => 
            med.toLowerCase().includes(drug)
          )) {
            conflictingMeds.push(med);
            alternatives.push(...allergyInfo.alternatives);
          }
        }
      }
    }
    
    return {
      hasConflict: conflictingMeds.length > 0,
      conflictingMeds,
      alternatives: [...new Set(alternatives)]
    };
  }
  
  private checkDrugInteractions(
    suggestedMeds: string[],
    currentMeds: string[]
  ): DrugInteractionCheck {
    
    const interactions: string[] = [];
    const conflictingMeds: string[] = [];
    
    // Drug interaction database (simplified)
    const interactionDatabase = {
      'warfarin': {
        interactsWith: ['aspirin', 'ibuprofen', 'naproxen'],
        risk: 'Increased bleeding risk'
      },
      'metformin': {
        interactsWith: ['contrast dye'],
        risk: 'Lactic acidosis risk'
      },
      'opioid': {
        interactsWith: ['benzodiazepine', 'alcohol'],
        risk: 'Respiratory depression'
      }
    };
    
    for (const currentMed of currentMeds) {
      const interaction = interactionDatabase[currentMed.toLowerCase()];
      
      if (interaction) {
        for (const suggestedMed of suggestedMeds) {
          if (interaction.interactsWith.some(drug =>
            suggestedMed.toLowerCase().includes(drug)
          )) {
            interactions.push(
              `${currentMed} + ${suggestedMed}: ${interaction.risk}`
            );
            conflictingMeds.push(suggestedMed);
          }
        }
      }
    }
    
    return {
      hasInteraction: interactions.length > 0,
      interactions,
      conflictingMeds
    };
  }
  
  private checkChronicConditions(
    disease: string,
    conditions: string[]
  ): ConditionCheck {
    
    const risks: string[] = [];
    const recommendations: string[] = [];
    
    // Condition-specific considerations
    const conditionRisks = {
      'diabetes': {
        diseases: ['infection', 'pneumonia'],
        recommendations: [
          'Monitor blood sugar closely',
          'Adjust insulin if needed',
          'Watch for diabetic complications'
        ]
      },
      'hypertension': {
        diseases: ['heart attack', 'stroke'],
        recommendations: [
          'Monitor blood pressure',
          'Avoid NSAIDs if possible',
          'Consider cardiovascular risk'
        ]
      },
      'kidney disease': {
        diseases: ['infection', 'dehydration'],
        recommendations: [
          'Adjust medication dosage for renal function',
          'Avoid nephrotoxic drugs',
          'Monitor kidney function'
        ]
      }
    };
    
    for (const condition of conditions) {
      const risk = conditionRisks[condition.toLowerCase()];
      
      if (risk) {
        if (risk.diseases.some(d => disease.toLowerCase().includes(d))) {
          risks.push(condition);
          recommendations.push(...risk.recommendations);
        }
      }
    }
    
    return {
      hasRisk: risks.length > 0,
      conditions: risks,
      recommendations
    };
  }
}
```

---

## 📱 Mobile App Safety Implementation

### Diagnosis Screen with Safety Checks

```dart
// lib/screens/diagnosis_screen.dart

class DiagnosisScreen extends StatefulWidget {
  final Patient patient;
  
  DiagnosisScreen({required this.patient});
  
  @override
  _DiagnosisScreenState createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _apiService = ApiService();
  
  bool _hasInternet = false;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _checkInternet();
  }
  
  Future<void> _checkInternet() async {
    bool hasInternet = await _connectivity.hasInternet();
    setState(() {
      _hasInternet = hasInternet;
    });
  }
  
  Future<void> _runDiagnosis() async {
    // CRITICAL: Check internet first
    bool hasInternet = await _connectivity.hasInternet();
    
    if (!hasInternet) {
      _showSafetyWarning();
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Fetch complete patient record
      PatientRecord patientRecord = await _apiService.getPatientRecord(
        widget.patient.id
      );
      
      // Run diagnosis with patient context
      DiagnosisResult result = await _apiService.diagnoseWithSafety(
        patientId: widget.patient.id,
        symptoms: _selectedSymptoms,
        vitalSigns: _vitalSigns,
      );
      
      // Show results with safety information
      _showDiagnosisResults(result);
      
    } catch (e) {
      _showError('Failed to run diagnosis: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showSafetyWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Text('Internet Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI diagnosis requires internet connection for patient safety.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('We need to check:'),
            SizedBox(height: 8),
            _buildSafetyItem('Patient allergies'),
            _buildSafetyItem('Chronic conditions'),
            _buildSafetyItem('Current medications'),
            _buildSafetyItem('Medical history'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                '⚠️ Without this information, we might suggest medications that could harm the patient.',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveSymptomsForLater();
            },
            child: Text('Save Symptoms for Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEmergencyModeWarning();
            },
            child: Text(
              'Emergency Mode',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _checkInternet();
            },
            icon: Icon(Icons.refresh),
            label: Text('Check Connection'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSafetyItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
  
  void _showEmergencyModeWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Text('Emergency Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚠️ WARNING',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You are about to run AI diagnosis WITHOUT patient medical history.',
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text('This means:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildWarningItem('Allergies NOT checked'),
            _buildWarningItem('Chronic conditions NOT considered'),
            _buildWarningItem('Current medications NOT reviewed'),
            _buildWarningItem('Drug interactions NOT verified'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Use this mode ONLY in life-threatening emergencies when internet is unavailable.',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _runEmergencyDiagnosis();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Yes, Emergency Only'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWarningItem(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 16),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
  
  void _showDiagnosisResults(DiagnosisResult result) {
    // Show results with safety checks
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisResultScreen(
          result: result,
          patient: widget.patient,
        ),
      ),
    );
  }
}
```

---

## ✅ Safety Checklist

### Before Diagnosis:
- [ ] Internet connection verified
- [ ] Patient record fetched
- [ ] Allergies loaded
- [ ] Chronic conditions loaded
- [ ] Current medications loaded
- [ ] Medical history loaded

### During Diagnosis:
- [ ] AI prediction generated
- [ ] Allergy check performed
- [ ] Drug interaction check performed
- [ ] Chronic condition check performed
- [ ] Age contraindication check performed
- [ ] Recommendations adjusted for patient

### After Diagnosis:
- [ ] Safety warnings displayed
- [ ] Contraindications highlighted
- [ ] Alternative medications suggested
- [ ] Health worker acknowledges warnings
- [ ] Diagnosis saved with safety flags

---

## 🎯 Summary

**Why Internet is REQUIRED for AI Diagnosis:**

1. **Allergies** - Prevent life-threatening allergic reactions
2. **Chronic Conditions** - Adjust treatment for existing diseases
3. **Current Medications** - Avoid dangerous drug interactions
4. **Medical History** - Consider past conditions and treatments
5. **Patient Safety** - Ensure recommendations won't harm patient

**Emergency Mode:**
- Available ONLY for life-threatening situations
- Shows multiple warnings
- Requires explicit confirmation
- Logs as "emergency diagnosis without patient context"
- Recommends follow-up when online

**Result:**
- Safe, personalized treatment recommendations
- Reduced medical errors
- Better patient outcomes
- Legal compliance
- Professional standard of care

---

**Last Updated**: 2026-04-28
**Priority**: CRITICAL - PATIENT SAFETY
