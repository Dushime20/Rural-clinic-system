# Dynamic Clinic Messages - Flow Diagram

## 🔄 Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND (Node.js + Express)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POST /diagnosis/analyze                                        │
│      ↓                                                          │
│  1. Analyze patient history                                     │
│  2. Detect patterns:                                            │
│     • Persistent? (same disease within 30 days)                 │
│     • Recurring? (2+ times in 90 days)                          │
│     • Chronic? (matches chronic condition list)                 │
│  3. Find nearby pharmacies                                      │
│  4. Find nearby clinics                                         │
│  5. Generate clinicRecommendationReason                         │
│      ↓                                                          │
│  Response JSON:                                                 │
│  {                                                              │
│    "recommendations": {                                         │
│      "clinicRecommendationReason": "persistent|recurring|...",  │
│      "pharmacies": [...] or [],                                 │
│      "clinics": [...]                                           │
│    }                                                            │
│  }                                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (Dart)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  diagnosis_result_page.dart                                     │
│      ↓                                                          │
│  1. Receive DiagnosisResponse                                   │
│  2. Parse into _diagnosis object                                │
│  3. Extract data:                                               │
│     • reason = recommendations.clinicRecommendationReason       │
│     • hasPharmacies = recommendations.pharmacies.isNotEmpty     │
│      ↓                                                          │
│  4. Call: _getClinicReasonExplanation(reason)                   │
│      ↓                                                          │
│  5. DECISION TREE:                                              │
│                                                                 │
│     ┌─────────────────────────────────────────┐                │
│     │  Check reason.contains('persistent')    │                │
│     └─────────────────────────────────────────┘                │
│               ↓ YES                   ↓ NO                      │
│     ┌─────────────────────┐    ┌──────────────────────┐        │
│     │  hasPharmacies?     │    │ Check 'recurring'    │        │
│     └─────────────────────┘    └──────────────────────┘        │
│       ↓ YES      ↓ NO                ↓ YES      ↓ NO           │
│     Message1A  Message1B          Message2A  Check 'chronic'   │
│                                                 ↓ YES   ↓ NO    │
│                                              Message3A  ...     │
│                                                                 │
│  6. Return selected message string                              │
│      ↓                                                          │
│  7. Build UI with message                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    USER INTERFACE (Flutter)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │  📋 Clinic Recommendations                                │ │
│  ├───────────────────────────────────────────────────────────┤ │
│  │                                                           │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ ℹ️  [DYNAMIC MESSAGE DISPLAYED HERE]               │ │ │
│  │  │                                                      │ │ │
│  │  │ • Changes based on disease pattern                  │ │ │
│  │  │ • Mentions pharmacies only if available             │ │ │
│  │  │ • Context-aware wording                             │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                           │ │
│  │  🏥 [Clinic Card 1]                                       │ │
│  │  🏥 [Clinic Card 2]                                       │ │
│  │  🏥 [Clinic Card 3]                                       │ │
│  │                                                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🌳 Decision Tree (Detailed)

```
Start: _getClinicReasonExplanation(reason)
│
├─ reason contains "persistent"?
│  ├─ YES: Check hasPharmacies
│  │  ├─ YES → "While pharmacies available...also clinic..."
│  │  └─ NO  → "recommend clinic for evaluation..."
│  │
│  └─ NO: Continue checking...
│
├─ reason contains "recurring"?
│  ├─ YES: Check hasPharmacies
│  │  ├─ YES → "In addition to pharmacies...prevent occurrences..."
│  │  └─ NO  → "provide comprehensive care..."
│  │
│  └─ NO: Continue checking...
│
├─ reason contains "chronic"?
│  ├─ YES: Check hasPharmacies
│  │  ├─ YES → "medication available...long-term management..."
│  │  └─ NO  → "long-term management...chronic conditions..."
│  │
│  └─ NO: Continue checking...
│
├─ reason contains "no pharmacy"?
│  ├─ YES → "No nearby pharmacies found...visit clinics..."
│  │
│  └─ NO: Default case
│     └─ Check hasPharmacies
│        ├─ YES → "medication available...comprehensive care..."
│        └─ NO  → "recommend consulting clinics..."
│
End: Return message string
```

---

## 🎨 UI Layout Visual

```
╔═══════════════════════════════════════════════════════════════╗
║                    DIAGNOSIS RESULT PAGE                      ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │  👤 Patient Information                                 │ ║
║  │  Name: John Doe | Age: 35 | Gender: Male               │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │  🏥 Primary Diagnosis                                   │ ║
║  │  Disease: Common Cold | Confidence: 85%                │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │  💊 Prescriptions                                       │ ║
║  │  • Paracetamol 500mg - 3x daily                        │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │  🏪 Nearby Pharmacies (if available)                    │ ║
║  │  • Pharmacy A - 1.2 km                                  │ ║
║  │  • Pharmacy B - 2.5 km                                  │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
║  ┌─────────────────────────────────────────────────────────┐ ║
║  │  🏥 Clinic Recommendations                              │ ║
║  ├─────────────────────────────────────────────────────────┤ ║
║  │                                                         │ ║
║  │  ╔═══════════════════════════════════════════════════╗ │ ║
║  │  ║  ℹ️  DYNAMIC MESSAGE BOX                         ║ │ ║
║  │  ║  ────────────────────────────────────────────────║ │ ║
║  │  ║  [Message changes based on:]                     ║ │ ║
║  │  ║  • Disease pattern (persistent/recurring/chronic)║ │ ║
║  │  ║  • Pharmacy availability (yes/no)                ║ │ ║
║  │  ║                                                  ║ │ ║
║  │  ║  Example:                                        ║ │ ║
║  │  ║  "This condition has persisted for an extended   ║ │ ║
║  │  ║  period. While pharmacies are available for      ║ │ ║
║  │  ║  medication, we also recommend visiting a        ║ │ ║
║  │  ║  specialized clinic for in-depth evaluation."    ║ │ ║
║  │  ╚═══════════════════════════════════════════════════╝ │ ║
║  │                                                         │ ║
║  │  ┌───────────────────────────────────────────────────┐ │ ║
║  │  │  🏥 City General Hospital                         │ │ ║
║  │  │  📍 1.5 km | ☎️ +123456789                       │ │ ║
║  │  │  🏷️ Persistent | General Medicine               │ │ ║
║  │  └───────────────────────────────────────────────────┘ │ ║
║  │                                                         │ ║
║  │  ┌───────────────────────────────────────────────────┐ │ ║
║  │  │  🏥 Health Center North                           │ │ ║
║  │  │  📍 2.3 km | ☎️ +987654321                       │ │ ║
║  │  │  🏷️ Persistent | Internal Medicine              │ │ ║
║  │  └───────────────────────────────────────────────────┘ │ ║
║  │                                                         │ ║
║  └─────────────────────────────────────────────────────────┘ ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 📊 Message Selection Matrix

```
┌──────────────┬──────────────┬────────────────────────────────────────┐
│ Disease      │ Has          │ Message Theme                          │
│ Pattern      │ Pharmacies   │                                        │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Persistent   │ ✅ Yes       │ "While pharmacies available...         │
│              │              │  also recommend clinic..."             │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Persistent   │ ❌ No        │ "Recommend clinic for                  │
│              │              │  evaluation and treatment"             │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Recurring    │ ✅ Yes       │ "In addition to pharmacies...          │
│              │              │  prevent future occurrences"           │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Recurring    │ ❌ No        │ "Comprehensive care to prevent         │
│              │              │  future occurrences"                   │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Chronic      │ ✅ Yes       │ "Medication available...               │
│              │              │  long-term management needed"          │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Chronic      │ ❌ No        │ "Long-term management for              │
│              │              │  chronic conditions"                   │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ No Pharmacy  │ ❌ No        │ "No pharmacies found...                │
│ Found        │              │  visit clinics for alternatives"       │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Default      │ ✅ Yes       │ "Medication available...               │
│              │              │  also consult for comprehensive care"  │
├──────────────┼──────────────┼────────────────────────────────────────┤
│ Default      │ ❌ No        │ "Recommend consulting clinics          │
│              │              │  for comprehensive care"               │
└──────────────┴──────────────┴────────────────────────────────────────┘
```

---

## 🔍 Backend Pattern Detection Logic

```
┌─────────────────────────────────────────────────────────────┐
│              BACKEND: Pattern Detection                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Query patient diagnosis history                         │
│     SELECT * FROM diagnoses WHERE patientId = :id           │
│     AND diagnosisDate > NOW() - 90 days                     │
│      ↓                                                      │
│  2. Check for PERSISTENT                                    │
│     • Same disease within last 30 days?                     │
│     • If YES → reason = "persistent condition detected"     │
│      ↓                                                      │
│  3. Check for RECURRING                                     │
│     • Same disease 2+ times in 90 days?                     │
│     • If YES → reason = "recurring pattern detected"        │
│      ↓                                                      │
│  4. Check for CHRONIC                                       │
│     • Disease in chronic conditions list?                   │
│     • List: Diabetes, Hypertension, Asthma, etc.            │
│     • If YES → reason = "matches chronic condition"         │
│      ↓                                                      │
│  5. Check for PHARMACIES                                    │
│     • Query nearby pharmacies with medications              │
│     • If EMPTY → reason = "no pharmacy found"               │
│      ↓                                                      │
│  6. Set reason in response                                  │
│     • Add to recommendations.clinicRecommendationReason     │
│     • Also include pharmacies array (empty or filled)       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚡ Quick Reference: Message Keywords

| Keyword in Reason | Triggers Message About |
|-------------------|------------------------|
| `persistent` | Extended duration condition |
| `recurring` | Multiple occurrences pattern |
| `chronic` | Long-term chronic condition |
| `no pharmacy` | Alternative treatment options |
| (none/other) | General comprehensive care |

---

## 🎯 Testing Flow Diagram

```
                    START TESTING
                         │
          ┌──────────────┴──────────────┐
          │                             │
    ┌─────▼──────┐               ┌─────▼──────┐
    │ Test       │               │ Test       │
    │ Persistent │               │ Recurring  │
    └─────┬──────┘               └─────┬──────┘
          │                             │
    ┌─────▼──────────────┐       ┌─────▼──────────────┐
    │ With Pharmacies?   │       │ With Pharmacies?   │
    ├─────┬──────────────┤       ├─────┬──────────────┤
    │ Yes │ No           │       │ Yes │ No           │
    └──┬──┴──┬───────────┘       └──┬──┴──┬───────────┘
       │     │                      │     │
    Msg1A  Msg1B                 Msg2A  Msg2B
       │     │                      │     │
       └─────┴──────────┬───────────┴─────┘
                        │
                  ┌─────▼──────┐
                  │ Test       │
                  │ Chronic    │
                  └─────┬──────┘
                        │
               ┌────────▼────────────┐
               │ Continue with       │
               │ remaining scenarios │
               └────────┬────────────┘
                        │
                     COMPLETE
```

---

## 📝 Key Takeaways

1. **Backend Responsibility**: Detect patterns, set reason keyword
2. **Flutter Responsibility**: Select appropriate message based on context
3. **User Experience**: Context-aware, helpful guidance
4. **Flexibility**: 9 different scenarios covered
5. **Scalability**: Easy to add new patterns/messages

---

**Ready for Testing!** 🚀  
See `TESTING_GUIDE_DYNAMIC_CLINIC_MESSAGES.md` for detailed testing instructions.
