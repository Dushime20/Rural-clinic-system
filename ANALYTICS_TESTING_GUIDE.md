# Analytics Dashboard Testing Guide

## Prerequisites

1. **Backend Running**
   ```bash
   cd ai_health_companion_backend
   npm run dev
   ```
   Backend should be running on `http://localhost:5000`

2. **Test Data**
   - At least a few patients in the database
   - At least a few diagnoses recorded
   - Some users created

3. **Mobile App**
   ```bash
   cd ai_health_companion
   flutter run -d emulator-5554
   ```

---

## Test Scenarios

### 1. Initial Load

**Steps**:
1. Login to the app
2. Navigate to Analytics tab (bottom navigation)

**Expected**:
- Loading spinner appears briefly
- Summary cards populate with real numbers
- Disease trends chart renders
- Demographics charts render
- No errors in console

**Verify**:
- [ ] Total Diagnoses shows correct count
- [ ] Total Patients shows correct count
- [ ] Active Users shows correct count
- [ ] Medications shows correct count

---

### 2. Disease Trends Chart

**Expected**:
- Line chart with up to 3 disease lines
- X-axis shows last 6 months (e.g., "Dec", "Jan", "Feb", "Mar", "Apr", "May")
- Y-axis shows count of diagnoses
- Legend shows disease names with colored dots
- Smooth animated curves
- Data points visible on lines

**Verify**:
- [ ] Chart renders without errors
- [ ] Lines match legend colors
- [ ] Months are in correct order
- [ ] Data points are visible
- [ ] Animation is smooth

**Edge Cases**:
- If no diagnoses: Shows "No disease trend data available"
- If only 1-2 diseases: Shows fewer lines (not 3)

---

### 3. Patient Demographics

**Gender Distribution (Pie Chart)**:

**Expected**:
- Pie chart with colored segments
- Percentages shown on segments
- Legend shows: Male, Female, Other (if any)
- Colors: Primary (Male), Secondary (Female), Accent (Other)

**Verify**:
- [ ] Pie chart renders correctly
- [ ] Percentages add up to 100%
- [ ] Legend matches chart colors
- [ ] Counts are accurate

**Age Distribution (Bar Chart)**:

**Expected**:
- Bar chart with 5 age groups: 0-18, 19-35, 36-50, 51-65, 65+
- Bars in primary color
- Y-axis shows count
- X-axis shows age groups

**Verify**:
- [ ] All 5 age groups shown
- [ ] Bar heights match counts
- [ ] Age groups in correct order
- [ ] Counts are accurate

---

### 4. Refresh Functionality

**Steps**:
1. Tap refresh icon (top right)
2. Observe loading state
3. Verify data reloads

**Expected**:
- Loading spinner appears
- Data refreshes from backend
- Charts re-render with updated data

**Verify**:
- [ ] Refresh icon triggers reload
- [ ] Loading state appears
- [ ] Data updates correctly
- [ ] No errors occur

---

### 5. Error Handling

**Test 1: Backend Down**

**Steps**:
1. Stop the backend server
2. Open analytics page (or refresh)

**Expected**:
- Error icon appears
- Error message: "Failed to load analytics"
- Retry button visible

**Verify**:
- [ ] Error UI appears
- [ ] Error message is clear
- [ ] Retry button is visible

**Test 2: Retry After Error**

**Steps**:
1. Start backend server
2. Tap "Retry" button

**Expected**:
- Loading spinner appears
- Data loads successfully
- Charts render normally

**Verify**:
- [ ] Retry button works
- [ ] Data loads after retry
- [ ] Error UI disappears

---

### 6. Empty Data Scenarios

**Test 1: No Diagnoses**

**Setup**: Database with no diagnoses

**Expected**:
- Summary card shows "0" for Total Diagnoses
- Disease trends shows "No disease trend data available"

**Test 2: No Patients**

**Setup**: Database with no patients

**Expected**:
- Summary card shows "0" for Total Patients
- Demographics shows "No gender data available" and "No age data available"

---

### 7. Performance

**Test**: Large Dataset

**Setup**: Database with 100+ patients, 500+ diagnoses

**Expected**:
- Page loads within 2-3 seconds
- Charts render smoothly
- No lag when scrolling
- No memory issues

**Verify**:
- [ ] Load time acceptable
- [ ] Smooth scrolling
- [ ] No performance warnings
- [ ] Charts render correctly

---

### 8. Visual Verification

**Summary Cards**:
- [ ] Cards have proper spacing
- [ ] Icons are visible and colored
- [ ] Text is readable
- [ ] Values are bold and prominent
- [ ] Cards are responsive (2 columns)

**Charts**:
- [ ] Chart titles are clear
- [ ] Charts have proper padding
- [ ] Grid lines are subtle
- [ ] Colors match app theme
- [ ] Text is readable
- [ ] Charts are responsive

**Overall Layout**:
- [ ] Proper spacing between sections
- [ ] Scrolling works smoothly
- [ ] No overflow issues
- [ ] Consistent with app design

---

## Common Issues & Solutions

### Issue 1: "Failed to load analytics"

**Possible Causes**:
- Backend not running
- Wrong API URL in `app_constants.dart`
- Network connectivity issue
- Authentication token expired

**Solution**:
1. Check backend is running: `http://localhost:5000/api/v1/health`
2. Verify API URL: `app_constants.dart` → `baseUrl`
3. Check emulator network: `10.0.2.2:5000` for Android emulator
4. Re-login to refresh token

### Issue 2: Charts not rendering

**Possible Causes**:
- Empty data from backend
- Chart widget error
- fl_chart dependency issue

**Solution**:
1. Check backend response in browser/Postman
2. Check console for errors
3. Verify fl_chart is installed: `flutter pub get`

### Issue 3: Wrong data displayed

**Possible Causes**:
- Backend returning incorrect data
- Data model mismatch
- Caching issue

**Solution**:
1. Check backend response format
2. Verify model parsing in `analytics_models.dart`
3. Clear app data and restart

### Issue 4: Loading forever

**Possible Causes**:
- Backend timeout
- Network issue
- Infinite loading state

**Solution**:
1. Check backend logs for errors
2. Increase timeout in `api_service.dart`
3. Check Riverpod provider state

---

## API Testing (Optional)

Test backend endpoints directly:

### 1. Dashboard Analytics

```bash
curl -X GET http://localhost:5000/api/v1/analytics/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "totalUsers": 5,
    "activeUsers": 4,
    "totalPatients": 25,
    "totalDiagnoses": 50,
    "diseaseTrends": [...],
    "topDiseases": [...]
  }
}
```

### 2. Patient Demographics

```bash
curl -X GET http://localhost:5000/api/v1/analytics/patients \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "totalPatients": 25,
    "genderDistribution": {
      "male": 12,
      "female": 13,
      "other": 0
    },
    "ageDistribution": {
      "0-18": 5,
      "19-35": 10,
      "36-50": 7,
      "51-65": 2,
      "65+": 1
    }
  }
}
```

---

## Checklist Summary

### Functionality
- [ ] Analytics page loads successfully
- [ ] Summary cards show real data
- [ ] Disease trends chart renders
- [ ] Demographics charts render
- [ ] Refresh button works
- [ ] Error handling works
- [ ] Retry button works
- [ ] Empty data handled gracefully

### Visual
- [ ] Layout is clean and organized
- [ ] Colors match app theme
- [ ] Text is readable
- [ ] Charts are properly sized
- [ ] Spacing is consistent
- [ ] Responsive on different screen sizes

### Performance
- [ ] Page loads quickly (< 3 seconds)
- [ ] Smooth scrolling
- [ ] No memory leaks
- [ ] Charts animate smoothly

### Edge Cases
- [ ] Works with no data
- [ ] Works with large datasets
- [ ] Handles backend errors
- [ ] Handles network issues
- [ ] Handles authentication errors

---

## Sign-off

**Tester**: _______________  
**Date**: _______________  
**Result**: ☐ Pass  ☐ Fail  
**Notes**: _______________________________________________
