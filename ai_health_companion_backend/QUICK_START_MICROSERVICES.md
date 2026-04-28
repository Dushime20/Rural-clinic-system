# Quick Start: Flask-Node.js Microservices Integration

This guide will help you quickly set up and test the Flask ML service integration with your Node.js backend.

## Prerequisites

- Python 3.10+
- Node.js 18+
- pip and npm installed

## Step 1: Set Up Flask ML Service

### 1.1 Navigate to model-training directory
```bash
cd ai_health_companion_backend/model-training
```

### 1.2 Create virtual environment (recommended)
```bash
python -m venv venv

# On Windows
venv\Scripts\activate

# On Linux/Mac
source venv/bin/activate
```

### 1.3 Install dependencies
```bash
pip install -r requirements.txt
```

### 1.4 Create .env file
```bash
cp .env.example .env
```

Edit `.env` if needed (defaults should work for local development).

### 1.5 Start Flask service
```bash
python api.py
```

The Flask service should now be running on `http://localhost:5001`

### 1.6 Test Flask service
Open a new terminal and test:

```bash
# Health check
curl http://localhost:5001/health

# Get available symptoms
curl http://localhost:5001/api/v1/symptoms

# Test prediction
curl -X POST http://localhost:5001/api/v1/predict \
  -H "Content-Type: application/json" \
  -d "{\"symptoms\": [\"fever\", \"cough\", \"headache\"]}"
```

Expected response:
```json
{
  "success": true,
  "prediction": {
    "disease": "Common Cold",
    "confidence": 0.85,
    "symptoms_used": ["fever", "cough", "headache"],
    "invalid_symptoms": []
  },
  "information": {
    "description": "...",
    "precautions": [...],
    "medications": [...],
    "diet": [...],
    "workout": [...]
  }
}
```

## Step 2: Configure Node.js Backend

### 2.1 Navigate to backend directory
```bash
cd ai_health_companion_backend
```

### 2.2 Update .env file
Add these lines to your `.env` file:

```env
# Flask ML Service Configuration
USE_FLASK_ML_SERVICE=true
FLASK_ML_SERVICE_URL=http://localhost:5001
FLASK_ML_TIMEOUT=30000
FLASK_ML_RETRY_ATTEMPTS=3
FLASK_ML_RETRY_DELAY=1000
```

### 2.3 Install dependencies (if not already done)
```bash
npm install
```

### 2.4 Build TypeScript
```bash
npm run build
```

### 2.5 Start Node.js backend
```bash
npm run dev
```

The Node.js backend should now be running on `http://localhost:5000`

## Step 3: Test Integration

### 3.1 Test health endpoint
```bash
curl http://localhost:5000/api/v1/health
```

This should show the status of both Node.js and Flask services.

### 3.2 Test diagnosis endpoint
```bash
curl -X POST http://localhost:5000/api/v1/diagnosis/predict \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "symptoms": [
      {"name": "fever", "category": "general"},
      {"name": "cough", "category": "respiratory"},
      {"name": "headache", "category": "neurological"}
    ],
    "vitalSigns": {
      "temperature": 38.5
    },
    "age": 30,
    "gender": "male"
  }'
```

## Step 4: Docker Setup (Optional)

### 4.1 Build Flask Docker image
```bash
cd ai_health_companion_backend/model-training
docker build -t flask-ml-service .
```

### 4.2 Run Flask container
```bash
docker run -d -p 5001:5001 --name flask-ml flask-ml-service
```

### 4.3 Test Docker container
```bash
curl http://localhost:5001/health
```

## Troubleshooting

### Issue: Flask service won't start

**Solution 1:** Check if port 5001 is already in use
```bash
# Windows
netstat -ano | findstr :5001

# Linux/Mac
lsof -i :5001
```

**Solution 2:** Check if all datasets and model files exist
```bash
ls -la model/RandomForest.pkl
ls -la dataset/
```

### Issue: Node.js can't connect to Flask

**Solution 1:** Verify Flask is running
```bash
curl http://localhost:5001/health
```

**Solution 2:** Check environment variables
```bash
echo $FLASK_ML_SERVICE_URL  # Linux/Mac
echo %FLASK_ML_SERVICE_URL%  # Windows
```

**Solution 3:** Check firewall settings
Make sure port 5001 is not blocked by your firewall.

### Issue: "Module not found" errors in Flask

**Solution:** Reinstall dependencies
```bash
pip install --upgrade -r requirements.txt
```

### Issue: Low prediction confidence

**Solution:** Ensure you're using valid symptom names
```bash
# Get list of valid symptoms
curl http://localhost:5001/api/v1/symptoms
```

## Testing Checklist

- [ ] Flask service starts without errors
- [ ] Flask health check returns "healthy"
- [ ] Flask prediction endpoint works
- [ ] Node.js backend starts without errors
- [ ] Node.js can connect to Flask service
- [ ] Integration test passes
- [ ] Predictions are returned correctly

## Next Steps

1. **Review the full integration guide:** `FLASK_NODEJS_MICROSERVICES_INTEGRATION.md`
2. **Add authentication:** Implement API key authentication
3. **Set up monitoring:** Add logging and metrics
4. **Deploy to staging:** Test in a staging environment
5. **Performance testing:** Load test the integration
6. **Production deployment:** Deploy with proper security and scaling

## Useful Commands

### Flask Service
```bash
# Start Flask (development)
python api.py

# Start Flask (production with gunicorn)
gunicorn --bind 0.0.0.0:5001 --workers 4 api:app

# Run tests
python -m pytest tests/

# Check logs
tail -f logs/ml-service.log
```

### Node.js Backend
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run tests
npm test

# Check logs
tail -f logs/combined.log
```

### Docker
```bash
# Build and run Flask service
docker build -t flask-ml-service ./model-training
docker run -d -p 5001:5001 flask-ml-service

# View logs
docker logs flask-ml-service

# Stop and remove
docker stop flask-ml-service
docker rm flask-ml-service
```

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the full integration guide
3. Check application logs
4. Contact the development team

---

**Last Updated:** 2026-04-28
