# Debugging "Internal Server Error"

## Issue

Flask ML service responds successfully (HTTP 200), but backend shows "Internal Server Error" to the client.

## Flask Logs Show Success
```
INFO:__main__:Received symptoms: ['Fatigue', 'Vomiting', 'Sweating']
INFO:__main__:  'fatigue' → 'fatigue'
INFO:__main__:  'vomiting' → 'vomiting'
INFO:__main__:  'sweating' → 'sweating'
INFO:__main__:Corrected: ['fatigue', 'vomiting', 'sweating'], Invalid: []
INFO:__main__:Vital signs adjustment: +0.000 (base: 0.540, final: 0.540)
INFO:__main__:Prediction: Heart attack (confidence: 0.54, ICD-10: I21.9)
INFO:werkzeug:127.0.0.1 - - [11/May/2026 17:30:15] "POST /api/v1/predict HTTP/1.1" 200 -
```

✅ Flask is working correctly!

## Problem

The Node.js backend is receiving the Flask response but failing to process it.

## Changes Made

Added detailed error logging to `diagnosis.controller.ts`:

```typescript
try {
    aiPredictions = await aiService.predictDisease(aiInput);
    logger.info(`AI predictions received: ${JSON.stringify(aiPredictions).substring(0, 300)}`);
} catch (aiError: any) {
    logger.error('❌ AI service error:', aiError);
    logger.error('❌ AI error message:', aiError.message);
    logger.error('❌ AI error stack:', aiError.stack);
    throw new AppError(aiError.message || 'AI prediction failed', 500);
}
```

## How to Debug

### Step 1: Restart Backend
```bash
cd ai_health_companion_backend
npm run dev
```

### Step 2: Try Diagnosis Again
Run a diagnosis in the Flutter app with 3-4 symptoms.

### Step 3: Check Backend Logs
Look for these log messages:

**Success:**
```
Calling AI service for predictions...
AI predictions received: [{"disease":"Heart attack","confidence":0.54,...}]
Primary prediction: Heart attack, medications: 5
```

**Error:**
```
❌ AI service error: [error object]
❌ AI error message: [specific error message]
❌ AI error stack: [stack trace]
```

## Possible Causes

### 1. Response Format Mismatch
Flask might be returning a different format than expected.

**Check:** Look at the "AI predictions received" log to see the actual format.

### 2. Missing Properties
The code might be trying to access properties that don't exist.

**Check:** Look for errors like "Cannot read property 'X' of undefined"

### 3. Type Conversion Issues
TypeScript might be having issues with the response types.

**Check:** Look for type-related errors in the logs.

### 4. Database Save Error
The diagnosis might fail to save to the database.

**Check:** Look for database-related errors after the AI prediction.

## Quick Test

Test the Flask service directly:

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["fatigue", "vomiting", "sweating"],
    "vitalSigns": {"temperature": 37.5},
    "demographics": {"age": 35, "gender": "male"}
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "prediction": {
    "disease": "Heart attack",
    "confidence": 0.54,
    "icd10Code": "I21.9",
    "symptoms_used": ["fatigue", "vomiting", "sweating"],
    "invalid_symptoms": [],
    "vital_signs_used": true,
    "demographics_used": true
  },
  "top_predictions": [
    {"disease": "Heart attack", "confidence": 0.54, "icd10Code": "I21.9"},
    {"disease": "...", "confidence": 0.xx, "icd10Code": "..."},
    {"disease": "...", "confidence": 0.xx, "icd10Code": "..."}
  ],
  "information": {
    "description": "...",
    "precautions": [...],
    "medications": [...],
    "diet": [...],
    "workout": [...]
  },
  "timestamp": "2026-05-11T..."
}
```

## Next Steps

1. ✅ Restart backend with new logging
2. ✅ Try diagnosis again
3. ✅ Check backend terminal for detailed error logs
4. ✅ Share the error message here

The new logging will show exactly what's failing!

---

**Status:** Waiting for backend logs to identify the exact error.
