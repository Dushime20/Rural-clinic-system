# ⚡ Quick Test: AI/ML Model Service

## 🚀 Quick Start (5 Minutes)

### Step 1: Start Flask ML Service

```bash
cd ai_health_companion_backend/model-training
python api.py
```

**Wait for:**
```
INFO:__main__:Model and datasets loaded successfully
 * Running on http://0.0.0.0:5001
```

✅ Service is running!

---

### Step 2: Quick Health Check

Open a new terminal:

```bash
curl http://localhost:5001/health
```

**Expected:**
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

✅ Model is loaded!

---

### Step 3: Test Prediction

```bash
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d "{\"symptoms\": [\"fever\", \"cough\", \"headache\"]}"
```

**Expected:**
- Disease name (e.g., "Common Cold")
- Confidence score (e.g., 0.85)
- ICD-10 code (e.g., "J00")
- Recommendations

✅ Prediction works!

---

## 🧪 Run All Tests

### Option 1: Windows Batch Script

```bash
cd ai_health_companion_backend
test-ml-service.bat
```

### Option 2: Bash Script (Git Bash/Linux)

```bash
cd ai_health_companion_backend
bash test-ml-service.sh
```

### Option 3: Node.js Test Script

```bash
cd ai_health_companion_backend
node test-flask-integration.js
```

---

## ✅ Success Checklist

- [ ] Flask service starts without errors
- [ ] Health check returns `"model_loaded": true`
- [ ] Can predict disease from symptoms
- [ ] Returns confidence score
- [ ] Includes ICD-10 code
- [ ] Provides recommendations
- [ ] Response time < 1 second

---

## 🐛 Troubleshooting

### Service won't start?

```bash
# Install dependencies
cd ai_health_companion_backend/model-training
pip install -r requirements.txt

# Try again
python api.py
```

### Port already in use?

```bash
# Use different port
PORT=5002 python api.py
```

### Connection refused?

1. Check if service is running
2. Check firewall settings
3. Try `http://127.0.0.1:5001` instead of `localhost`

---

## 📚 Full Documentation

See `TEST_AI_MODEL_SERVICE.md` for:
- Detailed test scenarios
- API documentation
- Integration with Node.js
- Performance testing
- Production deployment

---

## 🎯 What's Next?

Once tests pass:

1. ✅ Start Node.js backend
2. ✅ Configure `.env` to use Flask service
3. ✅ Test from admin dashboard
4. ✅ Test from mobile app

---

**Quick Reference:**
- Flask Service: `http://localhost:5001`
- Health Check: `GET /health`
- Predict: `POST /api/v1/predict`
- Symptoms: `GET /api/v1/symptoms`
- Diseases: `GET /api/v1/diseases`
