# Symptom Selection UI - Visual Flow Guide

## 🎯 Quick Start

### Option A: Use Search (Fastest - 2 minutes)
```
Type → Select → Repeat
```

### Option B: Browse Categories (Organized - 3 minutes)
```
Expand → Select → Collapse → Next Category
```

---

## 📱 Screen Layout

```
┌─────────────────────────────────────────────┐
│  AI Diagnosis Assistant                     │
│  Patient: John Doe                          │
├─────────────────────────────────────────────┤
│ [Select Patient] [Patient Info] [Symptoms]  │
│ [Vital Signs] [Voice Input] [Review]        │
├─────────────────────────────────────────────┤
│                                             │
│  Symptoms Assessment                        │
│  Select all symptoms the patient is...      │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 🔍 Search symptoms...              [X]│ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 🟢 8  ✓ Good selection!               │ │
│  │      This should give accurate results│ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 🌡️ General              [4]        ▼  │ │
│  │ 17 symptoms                           │ │
│  │                                       │ │
│  │ ┌─────────────┐ ┌─────────────┐     │ │
│  │ │✓ High Fever │ │✓ Chills     │     │ │
│  │ └─────────────┘ └─────────────┘     │ │
│  │ ┌─────────────┐ ┌─────────────┐     │ │
│  │ │✓ Sweating   │ │✓ Fatigue    │     │ │
│  │ └─────────────┘ └─────────────┘     │ │
│  │ ┌─────────────┐ ┌─────────────┐     │ │
│  │ │○ Lethargy   │ │○ Malaise    │     │ │
│  │ └─────────────┘ └─────────────┘     │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 💨 Respiratory          [0]        ▶  │ │
│  │ 13 symptoms                           │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  ┌───────────────────────────────────────┐ │
│  │ 🍽️ Digestive            [2]        ▼  │ │
│  │ 17 symptoms                           │ │
│  │                                       │ │
│  │ ┌─────────────┐ ┌─────────────┐     │ │
│  │ │✓ Vomiting   │ │✓ Nausea     │     │ │
│  │ └─────────────┘ └─────────────┘     │ │
│  └───────────────────────────────────────┘ │
│                                             │
│  [Scroll for more categories...]           │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 🔄 User Flow Examples

### Example 1: Malaria Diagnosis (Search Method)

```
Step 1: Search "fever"
┌─────────────────────────────────┐
│ 🔍 fever                     [X]│
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ 🟠 1  Select more symptoms      │
│      Select 8-10 for best...    │
└─────────────────────────────────┘
Search Results (2)
┌─────────────┐ ┌─────────────┐
│✓ High Fever │ │○ Mild Fever │
└─────────────┘ └─────────────┘

Step 2: Search "chills"
┌─────────────────────────────────┐
│ 🔍 chills                    [X]│
└─────────────────────────────────┘
┌─────────────────────────────────┐
│ 🟠 2  Select more symptoms      │
│      Select 8-10 for best...    │
└─────────────────────────────────┘
Search Results (1)
┌─────────────┐
│✓ Chills     │
└─────────────┘

Step 3: Continue searching...
- sweating → ✓ Sweating
- vomiting → ✓ Vomiting
- headache → ✓ Headache
- fatigue → ✓ Fatigue
- nausea → ✓ Nausea
- muscle pain → ✓ Muscle Pain

Step 4: Counter turns green!
┌─────────────────────────────────┐
│ 🟢 8  ✓ Good selection!         │
│      This should give accurate  │
│      results                    │
└─────────────────────────────────┘

Step 5: Proceed to Vital Signs
→ Enter temperature: 39.5°C
→ Run Diagnosis
→ Result: Malaria 89% ✅
```

### Example 2: Common Cold (Category Method)

```
Step 1: Expand "Respiratory"
┌───────────────────────────────────┐
│ 💨 Respiratory          [0]    ▼ │
│ 13 symptoms                       │
│                                   │
│ ┌─────────┐ ┌─────────┐         │
│ │○ Cough  │ │○ Runny  │         │
│ │         │ │   Nose  │         │
│ └─────────┘ └─────────┘         │
│ ┌─────────┐ ┌─────────┐         │
│ │○ Conges-│ │○ Sinus  │         │
│ │  tion   │ │ Pressure│         │
│ └─────────┘ └─────────┘         │
└───────────────────────────────────┘

Step 2: Select symptoms
✓ Cough
✓ Runny Nose
✓ Congestion
✓ Sinus Pressure

Step 3: Expand "General"
✓ Mild Fever
✓ Fatigue
✓ Headache

Step 4: Expand "Throat & Mouth"
✓ Throat Irritation

Counter: 🟢 8 ✓ Good selection!
```

---

## 💡 Pro Tips

### Tip 1: Use Search for Specific Symptoms
```
Known symptoms? → Use search
"I know the patient has fever and cough"
→ Search "fever" → Select
→ Search "cough" → Select
```

### Tip 2: Use Categories for Exploration
```
Not sure what symptoms? → Browse categories
"Patient has digestive issues"
→ Expand "Digestive" category
→ See: Vomiting, Nausea, Diarrhea, etc.
→ Select relevant ones
```

### Tip 3: Combine Both Methods
```
1. Search for obvious symptoms (fever, pain)
2. Browse categories for related symptoms
3. Watch counter turn green at 8 symptoms
```

### Tip 4: Follow the Counter
```
🟠 Orange (< 8): Keep selecting
🟢 Green (8-12): Perfect! Can proceed
🔵 Blue (> 12): Good, but not necessary
```

---

## 🎨 Visual States

### Symptom Chip - Unselected
```
┌─────────────┐
│ ○ Symptom   │  ← Grey background
└─────────────┘    Grey text
                   Empty circle icon
```

### Symptom Chip - Selected
```
┌─────────────┐
│ ✓ Symptom   │  ← Blue background
└─────────────┘    White text
                   Checkmark icon
```

### Category - Collapsed
```
┌───────────────────────────────────┐
│ 🌡️ General              [4]    ▶ │
│ 17 symptoms                       │
└───────────────────────────────────┘
     ↑                    ↑      ↑
   Icon              Badge    Arrow
```

### Category - Expanded
```
┌───────────────────────────────────┐
│ 🌡️ General              [4]    ▼ │
│ 17 symptoms                       │
│                                   │
│ [Symptom chips displayed here]   │
└───────────────────────────────────┘
```

---

## 📊 Counter States

### State 1: Few Symptoms (Orange)
```
┌─────────────────────────────────┐
│ 🟠 3  ⚠️ Select more symptoms   │
│      Select 8-10 symptoms for   │
│      best accuracy              │
└─────────────────────────────────┘
```

### State 2: Good Selection (Green)
```
┌─────────────────────────────────┐
│ 🟢 8  ✓ Good selection!         │
│      This should give accurate  │
│      results                    │
└─────────────────────────────────┘
```

### State 3: Many Symptoms (Blue)
```
┌─────────────────────────────────┐
│ 🔵 13  ℹ️ Symptoms selected     │
│       You can add more if       │
│       needed                    │
└─────────────────────────────────┘
```

---

## 🚀 Quick Reference

### Search Keywords
| Symptom | Search Terms |
|---------|-------------|
| High Fever | "fever", "high", "temperature" |
| Chills | "chills", "shiver", "cold" |
| Headache | "headache", "head", "pain" |
| Vomiting | "vomit", "throw up" |
| Nausea | "nausea", "sick", "queasy" |
| Fatigue | "fatigue", "tired", "weak" |
| Cough | "cough", "coughing" |
| Diarrhea | "diarrhea", "loose stool" |

### Category Quick Access
| Body System | Category Name |
|-------------|---------------|
| Fever, tiredness | General |
| Cough, breathing | Respiratory |
| Stomach, vomiting | Digestive |
| Rash, itching | Skin & Nails |
| Headache, body pain | Pain & Discomfort |
| Dizziness, confusion | Neurological |
| Eye problems | Eyes & Vision |
| Urination issues | Urinary |
| Heart, chest | Cardiovascular |
| Anxiety, mood | Mental & Behavioral |

---

## ✅ Checklist for Accurate Diagnosis

```
□ Select 8-10 symptoms (watch for green counter)
□ Include main complaint (e.g., fever, pain)
□ Include related symptoms (e.g., if fever → add chills, sweating)
□ Include general symptoms (e.g., fatigue, loss of appetite)
□ Add vital signs (especially temperature)
□ Review all selections before submitting
```

---

## 🎯 Success Criteria

**You're ready to run diagnosis when:**
- ✅ Counter is green (8-12 symptoms)
- ✅ Main symptoms selected
- ✅ Related symptoms included
- ✅ Vital signs recorded
- ✅ Patient information complete

**Expected Results:**
- 🎯 85-90% confidence for common diseases
- 🎯 Top 3 predictions shown
- 🎯 Treatment recommendations provided
- 🎯 Nearby pharmacies listed

---

**Happy Diagnosing!** 🏥
