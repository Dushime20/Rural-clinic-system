# 🧪 AI/ML Model Service Testing Guide

## 📋 Overview

This guide will help you test the Flask ML service to ensure the AI model is working correctly.

---

## 🚀 Quick Start

### Step 1: Start the Flask ML Service

```bash
cd ai_health_companion_backend/model-training
python api.py
```

**Expected output:**
```
INFO:__main__:Model and datasets loaded successfully
 * Running on http://0.0.0.0:5001
```

### Step 2: Verify Service is Running

Open another terminal and run:

```bash
curl http://localhost:5001/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "service": "ml-prediction-service",
  "timestamp": "2026-04-28T14:00:00.000000",
  "model_loaded": true
}
```

✅ If you see `"model_loaded": true`, the model is working!

---

## 🧪 Test Scenarios

### Test 1: Health Check

**Purpose:** Verify the service is running and model is loaded

```bash
curl http://localhost:5001/health
```

**Expected:**
- Status code: `200`
- `"status": "healthy"`
- `"model_loaded": true`

---

### Test 2: Get Available Symptoms

**Purpose:** Check if the model has symptom data

```bash
curl http://localhost:5001/api/v1/symptoms
```

**Expected:**
- Status code: `200`
- `"success": true`
- `"count": 132` (132 symptoms available)
- Array of symptoms like: `["itching", "skin rash", "fever", ...]`

---

### Test 3: Get Available Diseases

**Purpose:** Check if the model can predict diseases

```bash
curl http://localhost:5001/api/v1/diseases
```

**Expected:**
- Status code: `200`
- `"success": true`
- `"count": 41` (41 diseases)
- Array of diseases like: `["Fungal infection", "Allergy", "GERD", ...]`

---

### Test 4: Simple Disease Prediction

**Purpose:** Test basic prediction with common symptoms

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["fever", "cough", "headache"]
  }'
```

**Expected response:**
```json
{
  "success": true,
  "prediction": {
    "disease": "Common Cold",
    "icd10Code": "J00",
    "confidence": 0.85,
    "symptoms_used": ["fever", "cough", "headache"],
    "invalid_symptoms": [],
    "vital_signs_used": false,
    "demographics_used": false
  },
  "information": {
    "description": "Common cold is a viral infection...",
    "precautions": ["Rest", "Drink fluids", "Avoid cold", "Take vitamin C"],
    "medications": ["Paracetamol", "Cough syrup"],
    "diet": ["Warm liquids", "Fruits", "Vegetables"],
    "workout": ["Light walking", "Breathing exercises"]
  },
  "timestamp": "2026-04-28T14:00:00.000000"
}
```

---

### Test 5: Prediction with Vital Signs

**Purpose:** Test enhanced prediction with vital signs

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["high fever", "headache", "nausea", "vomiting"],
    "vitalSigns": {
      "temperature": 39.5,
      "bloodPressureSystolic": 110,
      "bloodPressureDiastolic": 70,
      "heartRate": 95,
      "respiratoryRate": 20,
      "oxygenSaturation": 97
    },
    "demographics": {
      "age": 28,
      "gender": "male"
    }
  }'
```

**Expected:**
- Higher confidence score due to vital signs
- Disease prediction (likely Malaria, Typhoid, or Dengue)
- ICD-10 code included
- Comprehensive recommendations

---

### Test 6: Symptom Validation

**Purpose:** Test spell correction for misspelled symptoms

```bash
curl -X POST http://localhost:5001/api/v1/validate-symptoms \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["fver", "coff", "hedache", "nausea"]
  }'
```

**Expected response:**
```json
{
  "success": true,
  "results": [
    {
      "original": "fver",
      "corrected": "fever",
      "valid": true
    },
    {
      "original": "coff",
      "corrected": "cough",
      "valid": true
    },
    {
      "original": "hedache",
      "corrected": "headache",
      "valid": true
    },
    {
      "original": "nausea",
      "corrected": "nausea",
      "valid": true
    }
  ]
}
```

---

### Test 7: Malaria Prediction

**Purpose:** Test specific disease prediction

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["high fever", "chills", "sweating", "headache", "nausea", "vomiting"],
    "vitalSigns": {
      "temperature": 40.0,
      "heartRate": 105
    },
    "demographics": {
      "age": 35
    }
  }'
```

**Expected:**
- Disease: "Malaria"
- ICD-10: "B54"
- High confidence (>0.80)
- Specific malaria medications and precautions

---

### Test 8: Diabetes Prediction

**Purpose:** Test chronic disease prediction

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["excessive hunger", "increased appetite", "polyuria", "weight loss", "fatigue"],
    "vitalSigns": {
      "bloodPressureSystolic": 135,
      "bloodPressureDiastolic": 85
    },
    "demographics": {
      "age": 45,
      "gender": "male"
    }
  }'
```

**Expected:**
- Disease: "Diabetes"
- ICD-10: "E11.9"
- Dietary recommendations
- Workout plans

---

### Test 9: Invalid Symptoms

**Purpose:** Test error handling

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["xyz", "abc", "invalid"]
  }'
```

**Expected:**
- Status code: `400`
- `"success": false`
- `"error": "No valid symptoms found"`
- List of invalid symptoms

---

### Test 10: Missing Symptoms

**Purpose:** Test validation

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Expected:**
- Status code: `400`
- `"success": false`
- `"error": "Missing symptoms in request body"`

---

## 🔧 Testing from Node.js Backend

### Test 11: Node.js Integration Test

Create a test file: `test-flask-integration.js`

```javascript
const axios = require('axios');

const FLASK_URL = 'http://localhost:5001';

async function testFlaskIntegration() {
  console.log('🧪 Testing Flask ML Service Integration\n');

  // Test 1: Health Check
  console.log('1️⃣ Testing health check...');
  try {
    const health = await axios.get(`${FLASK_URL}/health`);
    console.log('✅ Health check passed:', health.data);
  } catch (error) {
    console.error('❌ Health check failed:', error.message);
    return;
  }

  // Test 2: Get Symptoms
  console.log('\n2️⃣ Testing get symptoms...');
  try {
    const symptoms = await axios.get(`${FLASK_URL}/api/v1/symptoms`);
    console.log(`✅ Got ${symptoms.data.count} symptoms`);
  } catch (error) {
    console.error('❌ Get symptoms failed:', error.message);
  }

  // Test 3: Predict Disease
  console.log('\n3️⃣ Testing disease prediction...');
  try {
    const prediction = await axios.post(`${FLASK_URL}/api/v1/predict`, {
      symptoms: ['fever', 'cough', 'headache'],
      vitalSigns: {
        temperature: 38.5,
        heartRate: 90
      },
      demographics: {
        age: 30,
        gender: 'male'
      }
    });
    console.log('✅ Prediction successful:');
    console.log('   Disease:', prediction.data.prediction.disease);
    console.log('   Confidence:', prediction.data.prediction.confidence);
    console.log('   ICD-10:', prediction.data.prediction.icd10Code);
  } catch (error) {
    console.error('❌ Prediction failed:', error.message);
  }

  console.log('\n✅ All tests completed!');
}

testFlaskIntegration();
```

Run it:
```bash
cd ai_health_companion_backend
node test-flask-integration.js
```

---

## 📊 Expected Performance

### Response Times
- Health check: < 50ms
- Get symptoms/diseases: < 100ms
- Simple prediction: 100-300ms
- Prediction with vitals: 150-400ms

### Accuracy
- Model training accuracy: 100%
- Symptom spell correction: 80%+ similarity threshold
- Confidence scores: 0.60 - 0.99

---

## 🐛 Troubleshooting

### Issue 1: Service Won't Start

**Error:**
```
Failed to load model or datasets
```

**Solution:**
```bash
# Check if model file exists
ls ai_health_companion_backend/model-training/model/RandomForest.pkl

# Check if datasets exist
ls ai_health_companion_backend/model-training/dataset/

# Install dependencies
cd ai_health_companion_backend/model-training
pip install -r requirements.txt
```

---

### Issue 2: Port Already in Use

**Error:**
```
Address already in use
```

**Solution:**
```bash
# Find process using port 5001
netstat -ano | findstr :5001

# Kill the process (replace PID)
taskkill /PID <PID> /F

# Or use a different port
PORT=5002 python api.py
```

---

### Issue 3: Model Returns Low Confidence

**Possible causes:**
- Not enough symptoms provided (provide 3-5 symptoms)
- Symptoms don't match a specific disease pattern
- Misspelled symptoms (use validation endpoint first)

**Solution:**
```bash
# Validate symptoms first
curl -X POST http://localhost:5001/api/v1/validate-symptoms \
  -H "Content-Type: application/json" \
  -d '{"symptoms": ["your", "symptoms", "here"]}'

# Then use corrected symptoms for prediction
```

---

### Issue 4: Connection Refused

**Error:**
```
Connection refused to localhost:5001
```

**Solution:**
1. Check if Flask service is running:
   ```bash
   curl http://localhost:5001/health
   ```

2. Start the service:
   ```bash
   cd ai_health_companion_backend/model-training
   python api.py
   ```

3. Check firewall settings

---

## 🎯 Integration with Node.js Backend

### Check Node.js Configuration

1. **Verify .env settings:**
```env
USE_FLASK_ML_SERVICE=true
FLASK_ML_SERVICE_URL=http://localhost:5001
FLASK_ML_TIMEOUT=30000
```

2. **Test from Node.js:**
```bash
# Start Node.js backend
cd ai_health_companion_backend
npm run dev

# Check health endpoint
curl http://localhost:5000/health
```

Expected response should show Flask ML service status:
```json
{
  "status": "healthy",
  "services": {
    "nodejs": "healthy",
    "flask_ml": "healthy",
    "database": "healthy"
  }
}
```

---

## 📝 Test Checklist

Use this checklist to verify everything works:

- [ ] Flask service starts without errors
- [ ] Health check returns `"model_loaded": true`
- [ ] Can retrieve 132 symptoms
- [ ] Can retrieve 41 diseases
- [ ] Simple prediction works (fever, cough, headache)
- [ ] Prediction with vital signs works
- [ ] Symptom validation/correction works
- [ ] Invalid symptoms are handled properly
- [ ] Missing data returns proper error
- [ ] Response times are acceptable (<500ms)
- [ ] Node.js can connect to Flask service
- [ ] ICD-10 codes are returned
- [ ] Confidence scores are reasonable (0.60-0.99)

---

## 🚀 Production Testing

### Load Testing

Test with multiple concurrent requests:

```bash
# Install Apache Bench (if not installed)
# Windows: Download from Apache website
# Linux: sudo apt-get install apache2-utils

# Run load test (100 requests, 10 concurrent)
ab -n 100 -c 10 -p test-payload.json -T application/json http://localhost:5001/api/v1/predict
```

Create `test-payload.json`:
```json
{
  "symptoms": ["fever", "cough", "headache"],
  "vitalSigns": {
    "temperature": 38.5
  }
}
```

**Expected:**
- All requests should succeed
- Average response time < 500ms
- No errors

---

## 📚 API Documentation

### Base URL
```
http://localhost:5001
```

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/api/v1/symptoms` | Get all symptoms |
| GET | `/api/v1/diseases` | Get all diseases |
| POST | `/api/v1/predict` | Predict disease |
| POST | `/api/v1/validate-symptoms` | Validate symptoms |

### Request/Response Examples

See test scenarios above for detailed examples.

---

## 🎉 Success Criteria

Your AI model service is working correctly if:

1. ✅ Health check shows model loaded
2. ✅ Can retrieve symptoms and diseases
3. ✅ Predictions return valid diseases
4. ✅ Confidence scores are reasonable
5. ✅ ICD-10 codes are included
6. ✅ Recommendations are provided
7. ✅ Spell correction works
8. ✅ Error handling works properly
9. ✅ Response times are acceptable
10. ✅ Node.js backend can connect

---

## 📞 Need Help?

If tests fail:

1. Check Flask service logs
2. Verify model file exists
3. Check dataset files
4. Verify Python dependencies
5. Check port availability
6. Review error messages

---

**Last Updated**: 2026-04-28
**Flask Service Port**: 5001
**Node.js Backend Port**: 5000
