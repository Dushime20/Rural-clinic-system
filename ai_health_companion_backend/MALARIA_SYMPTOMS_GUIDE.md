# Malaria Symptoms Guide

## 🦟 What is Malaria?
Malaria is a life-threatening disease caused by parasites transmitted through mosquito bites. Early detection is critical for effective treatment.

---

## 🩺 Symptoms to Select for Malaria Diagnosis

Based on the ML model training data, here are the **key symptoms** for Malaria:

### ✅ Primary Symptoms (Most Important)

1. **High Fever** ⭐⭐⭐
   - Temperature usually above 38.5°C (101.3°F)
   - Often comes in cycles (every 48-72 hours)

2. **Chills** ⭐⭐⭐
   - Severe shaking and feeling cold
   - Often precedes fever spikes

3. **Sweating** ⭐⭐⭐
   - Profuse sweating
   - Usually occurs after fever breaks

4. **Vomiting** ⭐⭐
   - Nausea and vomiting
   - Common in malaria cases

5. **Headache** ⭐⭐
   - Severe headache
   - Often accompanies fever

---

## 📊 Symptom Combinations from ML Model

The model recognizes these specific combinations:

### Most Common Pattern:
```
✓ Chills
✓ Vomiting  
✓ High Fever
✓ Sweating
```

### Alternative Patterns:
```
Pattern 1:
✓ Vomiting
✓ High Fever
✓ Sweating
✓ Headache

Pattern 2:
✓ Chills
✓ High Fever
✓ Sweating
✓ Headache

Pattern 3:
✓ Chills
✓ Vomiting
✓ Sweating
✓ Headache

Pattern 4:
✓ Chills
✓ Vomiting
✓ High Fever
✓ Headache
```

---

## 🎯 How to Use in the App

### Step 1: Select Patient
Choose the patient who needs diagnosis

### Step 2: Select Symptoms
In the Symptoms tab, select:
- ✅ **Chills**
- ✅ **Vomiting**
- ✅ **High Fever**
- ✅ **Sweating**
- ✅ **Headache** (optional but helpful)

### Step 3: Enter Vital Signs
**Critical for Malaria:**
- **Temperature**: Enter actual temperature (e.g., 39.5°C)
  - Normal: 36.5-37.5°C
  - Malaria: Usually 38.5°C or higher

**Other vital signs (optional but helpful):**
- Heart Rate: May be elevated (>100 bpm)
- Blood Pressure: Usually normal or slightly low

### Step 4: Medical History
Select if applicable:
- ✅ **Malaria (Previous)** - Important! Previous malaria increases likelihood

### Step 5: Additional Notes
Mention:
- Recent travel to malaria-endemic areas
- Mosquito exposure
- Duration of symptoms
- Fever pattern (cyclic or continuous)

---

## 🧪 Example Test Case

### Patient Profile:
- Age: 35 years
- Gender: Male
- Location: Rural area (malaria-endemic)

### Symptoms Selected:
```
✓ Chills
✓ Vomiting
✓ High Fever
✓ Sweating
✓ Headache
```

### Vital Signs:
```
Temperature: 39.2°C (102.6°F)
Heart Rate: 95 bpm
Blood Pressure: 115/75 mmHg
```

### Medical History:
```
✓ Malaria (Previous)
```

### Expected Result:
```
Primary Diagnosis: Malaria
Confidence: 75-85%
ICD-10: B54

Differential Diagnoses:
- Typhoid (similar symptoms)
- Dengue (if skin rash present)
- Influenza (less likely with this pattern)
```

---

## ⚠️ Important Notes

### When to Suspect Malaria:
1. **Classic Triad**: Fever + Chills + Sweating
2. **Cyclic Pattern**: Fever comes and goes every 2-3 days
3. **Recent Exposure**: Travel to or living in malaria-endemic area
4. **Season**: More common during rainy season

### Red Flags (Severe Malaria):
If patient also has:
- ❗ Altered consciousness / confusion
- ❗ Severe anemia
- ❗ Difficulty breathing
- ❗ Dark/bloody urine
- ❗ Seizures

→ **Immediate referral to hospital required!**

### Differential Diagnosis:
Malaria symptoms overlap with:
- **Typhoid**: Also has fever, chills, vomiting
- **Dengue**: May have fever, headache, but usually with rash
- **Influenza**: Similar but usually with more respiratory symptoms

---

## 🧬 Why These Symptoms?

### Pathophysiology:
1. **Fever & Chills**: Caused by parasite rupturing red blood cells
2. **Sweating**: Body's response to fever (trying to cool down)
3. **Vomiting**: Toxins released by parasites
4. **Headache**: Inflammation and toxins affecting brain

### Cyclic Pattern:
- Malaria parasites multiply in 48-72 hour cycles
- When they burst out of red blood cells → fever spike
- Between cycles → patient feels better (sweating phase)

---

## 📱 Testing in the App

### Quick Test:
```bash
# In the app:
1. Go to Diagnosis
2. Select patient
3. Add symptoms: Chills, Vomiting, High Fever, Sweating
4. Enter temperature: 39.0°C
5. Run Diagnosis
6. Expected: Malaria with 75-85% confidence
```

### With Flask ML Service:
```bash
# Test via API:
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["chills", "vomiting", "high fever", "sweating", "headache"],
    "vitalSigns": {
      "temperature": 39.2,
      "heartRate": 95
    },
    "demographics": {
      "age": 35,
      "gender": "male"
    }
  }'
```

---

## 📚 Additional Resources

### WHO Malaria Guidelines:
- https://www.who.int/health-topics/malaria

### CDC Malaria Information:
- https://www.cdc.gov/malaria/

### Treatment:
- Requires antimalarial medication (Artemisinin-based combination therapy)
- Blood test confirmation recommended
- Follow-up after 3 days

---

## ✅ Summary

**For Malaria Diagnosis, Select:**
1. ✅ Chills
2. ✅ Vomiting
3. ✅ High Fever
4. ✅ Sweating
5. ✅ Headache (optional)

**Plus Vital Signs:**
- Temperature: >38.5°C

**Expected Confidence:** 75-85%

**ICD-10 Code:** B54

---

**Remember:** This is a diagnostic aid tool. Always confirm with laboratory testing (blood smear or rapid diagnostic test) before starting treatment!

