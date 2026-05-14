# Diagnosis Workflow - Updated Navigation

## 📱 New User Flow with Next Buttons

```
┌─────────────────────────────────────────────────────────────┐
│                    TAB 1: SELECT PATIENT                    │
│                                                             │
│  • Search for patient                                       │
│  • Select from list                                         │
│  • Auto-navigates to Patient Info when selected            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ (auto)
┌─────────────────────────────────────────────────────────────┐
│                    TAB 2: PATIENT INFO                      │
│                                                             │
│  • View patient details (read-only)                         │
│  • Name, Age, Gender, Blood Type                            │
│  • Last Visit, Patient ID                                   │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  [Next: Record Symptoms] →                            │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓ (click Next)
┌─────────────────────────────────────────────────────────────┐
│                     TAB 3: SYMPTOMS                         │
│                                                             │
│  • Select symptoms (categorized UI)                         │
│  • Symptom counter (8-10 recommended)                       │
│  • Medical history checkboxes                               │
│  • Additional notes (optional)                              │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  [Next: Record Vital Signs] →                         │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓ (click Next)
┌─────────────────────────────────────────────────────────────┐
│                   TAB 4: VITAL SIGNS                        │
│                                                             │
│  • Temperature (°C)                                         │
│  • Blood Pressure (mmHg)                                    │
│  • Heart Rate (bpm)                                         │
│  • Respiratory Rate (breaths/min)                           │
│  • Oxygen Saturation (%)                                    │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  [Next: Review & Submit] →                            │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓ (click Next)
┌─────────────────────────────────────────────────────────────┐
│                     TAB 5: REVIEW                           │
│                                                             │
│  • Patient Information Summary                              │
│  • Symptoms (count)                                         │
│  • Medical History                                          │
│  • Vital Signs                                              │
│  • Additional Notes                                         │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  [Run AI Diagnosis] 🤖                                │ │
│  └───────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            ↓ (click Run)
┌─────────────────────────────────────────────────────────────┐
│                   DIAGNOSIS RESULT                          │
│                                                             │
│  • Primary Diagnosis (confidence %)                         │
│  • Top 3 Predictions                                        │
│  • ICD-10 Code                                              │
│  • Recommendations                                          │
│  • Prescriptions                                            │
│  • Nearby Pharmacies                                        │
└─────────────────────────────────────────────────────────────┘
```

## 🎯 Key Improvements

### Before (Manual Tab Navigation):
```
User clicks Tab 1 → User clicks Tab 2 → User clicks Tab 3 → 
User clicks Tab 4 → User clicks Tab 5 (Voice) → User clicks Tab 6 (Review)
```
**Problems:**
- Users might skip tabs
- No clear indication of what's next
- Voice tab was confusing (not implemented)
- 6 tabs felt overwhelming

### After (Guided Navigation):
```
User clicks Tab 1 → Auto-navigate to Tab 2 → 
Click "Next" → Click "Next" → Click "Next" → Click "Run Diagnosis"
```
**Benefits:**
- Clear linear flow
- Can't skip required steps
- Button labels guide the user
- 5 tabs (simpler)
- Faster completion

## 📊 Navigation Matrix

| From Tab | Button Label | To Tab | Can Skip? |
|----------|-------------|--------|-----------|
| 1. Select Patient | (auto) | 2. Patient Info | No |
| 2. Patient Info | "Next: Record Symptoms" | 3. Symptoms | No |
| 3. Symptoms | "Next: Record Vital Signs" | 4. Vital Signs | No |
| 4. Vital Signs | "Next: Review & Submit" | 5. Review | No |
| 5. Review | "Run AI Diagnosis" | Result Page | No |

**Note:** Users can still manually click tabs if they want to go back and edit.

## 🔄 Alternative Flows

### Quick Edit Flow:
```
User on Review tab → Notices missing symptom → 
Clicks "Symptoms" tab → Adds symptom → 
Clicks "Next" twice → Back to Review
```

### Back Navigation:
```
User can click any previous tab to go back
Changes are preserved (form state maintained)
```

## 💡 Design Decisions

### Why "Next" buttons instead of "Continue"?
- "Next" is clearer about forward movement
- Shows what's coming next in the label
- Consistent with mobile app patterns

### Why not auto-advance after each section?
- Users need time to review their entries
- Some fields are optional (vital signs)
- Gives users control over pacing

### Why keep tab bar visible?
- Users can see progress (5 steps)
- Can jump back to edit
- Familiar pattern for desktop/tablet users

## 🧪 Testing Scenarios

### Happy Path:
1. Select patient → Auto to Patient Info
2. Click "Next: Record Symptoms"
3. Select 10 symptoms
4. Click "Next: Record Vital Signs"
5. Enter temperature 39°C
6. Click "Next: Review & Submit"
7. Review all data
8. Click "Run AI Diagnosis"
9. View results

### Edge Cases:
- **No patient selected**: Show error, navigate to Tab 1
- **No symptoms selected**: Show error, stay on Review
- **Missing vital signs**: Allow (optional), proceed to Review
- **Back navigation**: Preserve all entered data

## 📱 Mobile Considerations

- Buttons are full-width for easy tapping
- 16px vertical padding for comfortable touch targets
- Clear icons (arrow forward) for visual guidance
- Rounded corners (12px) for modern look

## 🎨 Button Styling

```dart
ElevatedButton.icon(
  onPressed: () => _tabController.animateTo(nextTab),
  icon: const Icon(Icons.arrow_forward),
  label: const Text('Next: [Section Name]'),
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

## 🚀 Future Enhancements

1. **Progress Indicator**: Show "Step 2 of 5" above each tab
2. **Validation**: Disable "Next" if required fields empty
3. **Keyboard Shortcuts**: Enter key to advance
4. **Animations**: Smooth slide transitions between tabs
5. **Save Draft**: Auto-save progress for later

---

**Last Updated:** May 14, 2026
**Status:** ✅ Implemented
