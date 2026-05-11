# Multiple Disease Predictions - How It Works

## ✅ YES! Your Model Returns Multiple Predictions

Your Flask ML service uses a **Random Forest classifier** that returns **TOP-3 disease predictions** with confidence scores for each.

---

## 🔬 How It Works

### 1. **Flask ML Model (Python)**

Located in: `model-training/api.py`

```python
def predict_disease(symptoms):
    """Predict top-3 diseases from symptoms with confidence scores."""
    
    # Get probability scores for ALL diseases
    probabilities = Rf.predict_proba(symptom_vector)[0]
    classes = Rf.classes_
    
    # Sort and get TOP-3 predictions
    top_indices = np.argsort(probabilities)[::-1][:3]
    
    top_predictions = [
        {
            'disease': diseases_list[int(classes[i])],
            'confidence': float(probabilities[i])
        }
        for i in top_indices
        if probabilities[i] > 0
    ]
    
    return primary_disease, primary_confidence, top_predictions
```

**Key Points:**
- Uses `predict_proba()` to get confidence scores for ALL 41 diseases
- Sorts by confidence (highest first)
- Returns TOP-3 predictions
- Each prediction has: disease name, confidence score, ICD-10 code

---

### 2. **API Response Structure**

```json
{
  "success": true,
  "prediction": {
    "disease": "Gastroenteritis",
    "confidence": 0.78,
    "icd10Code": "K52.9"
  },
  "top_predictions": [
    {
      "disease": "Gastroenteritis",
      "confidence": 0.78,
      "icd10Code": "K52.9"
    },
    {
      "disease": "Common Cold",
      "confidence": 0.75,
      "icd10Code": "J00"
    },
    {
      "disease": "Influenza",
      "confidence": 0.68,
      "icd10Code": "J11"
    }
  ],
  "information": {
    "description": "...",
    "precautions": [...],
    "medications": [...],
    "diet": [...],
    "workout": [...]
  }
}
```

---

### 3. **Node.js Backend Processing**

Located in: `src/services/ai.service.ts`

```typescript
// Extract top_predictions from Flask response
const rawPredictions = flaskResult.top_predictions;

const predictions: Prediction[] = rawPredictions.map((p, index) => ({
    disease: p.disease.trim(),
    confidence: p.confidence,
    icd10Code: p.icd10Code,
    // Full info only for primary (index 0)
    ...(index === 0 ? {
        description: flaskResult.information.description,
        precautions: flaskResult.information.precautions,
        medications: flaskResult.information.medications,
        // ...
    } : {})
}));
```

**Key Points:**
- Receives all top-3 predictions from Flask
- Primary prediction (index 0) gets full disease information
- Differential diagnoses (index 1-2) get basic info only
- All predictions stored in database

---

### 4. **Database Storage**

Located in: `src/models/Diagnosis.ts`

```typescript
@Column({ type: 'jsonb' })
aiPredictions!: Array<{
    disease: string;
    confidence: number;
    icd10Code?: string;
    recommendations?: string[];
}>;
```

**Stored in database:**
```json
{
  "aiPredictions": [
    {
      "disease": "Gastroenteritis",
      "confidence": 0.78,
      "icd10Code": "K52.9"
    },
    {
      "disease": "Common Cold",
      "confidence": 0.75,
      "icd10Code": "J00"
    },
    {
      "disease": "Influenza",
      "confidence": 0.68,
      "icd10Code": "J11"
    }
  ]
}
```

---

## 📱 Mobile App Display

Your Flutter app shows:

### Primary Diagnosis Card
```
┌─────────────────────────────────┐
│  🩺 Primary Diagnosis            │
│                                  │
│  Gastroenteritis         78.0%  │
│  ICD-10: K52.9                   │
│                                  │
│  Confidence: ████████░░ 78.0%   │
└─────────────────────────────────┘
```

### Differential Diagnoses
```
┌─────────────────────────────────┐
│  🔍 Differential Diagnoses       │
│                                  │
│  • Common Cold           75.0%  │
│    ICD-10: J00                   │
│                                  │
│  • Influenza             68.0%  │
│    ICD-10: J11                   │
└─────────────────────────────────┘
```

---

## 🧪 Test It Yourself

Run the test script:

```bash
# Make sure Flask ML service is running first
cd model-training
python api.py

# In another terminal
cd ai_health_companion_backend
node test-multiple-predictions.js
```

Expected output:
```
🧪 Testing Multiple Disease Predictions

📋 Test Case: Fever + Cough + Headache
------------------------------------------------------------
Symptoms: fever, cough, headache, fatigue

✅ Primary Diagnosis:
   Disease: Common Cold
   Confidence: 75.0%
   ICD-10: J00

🔍 Differential Diagnoses (Top 3):
   🥇 Common Cold
      Confidence: 75.0%
      ICD-10: J00
   🥈 Influenza
      Confidence: 68.0%
      ICD-10: J11
   🥉 Malaria
      Confidence: 45.0%
      ICD-10: B54
```

---

## ✅ Conclusion

**YES**, your model returns:
- ✅ **TOP-3 disease predictions**
- ✅ **Confidence score for each** (0.0 to 1.0)
- ✅ **ICD-10 code for each**
- ✅ **Full disease information for primary diagnosis**
- ✅ **Differential diagnoses for clinical decision support**

This matches exactly what your mobile app UI shows! 🎉

---

## 🚀 Next Steps

1. **Start Flask ML service** to enable AI predictions
2. **Test with real symptoms** using the test script
3. **Verify in mobile app** that all 3 predictions display correctly

