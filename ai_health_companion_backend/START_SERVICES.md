# Starting the AI Health Companion Services

## Overview

The AI Health Companion backend consists of two microservices:
1. **Node.js Backend** (Port 5000) - Main API server
2. **Flask ML Service** (Port 5001) - Machine Learning predictions

## Quick Start

### Option 1: Start Both Services Manually

#### Terminal 1: Start Flask ML Service

```bash
cd model-training

# Install dependencies (first time only)
pip install -r requirements.txt

# Start Flask service
python api.py
```

**Expected Output:**
```
INFO:__main__:Model and datasets loaded successfully
 * Running on http://0.0.0.0:5001
 * Press CTRL+C to quit
```

**Note:** If you see TensorFlow errors, see `model-training/PYTHON_VERSION_FIX.md`

#### Terminal 2: Start Node.js Backend

```bash
cd ai_health_companion_backend

# Install dependencies (first time only)
npm install

# Start Node.js server
npm run dev
```

**Expected Output:**
```
[info]: Email service initialized successfully
[info]: Database connected successfully
🚀 Server running on port 5000 in development mode
📚 API Documentation: http://localhost:5000/api-docs
🏥 Health Check: http://localhost:5000/health
```

### Option 2: Start with Docker (Coming Soon)

```bash
docker-compose up
```

## Service Status Check

### Check Flask ML Service

```bash
curl http://localhost:5001/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "model_loaded": true,
  "diseases_count": 41,
  "symptoms_count": 132
}
```

### Check Node.js Backend

```bash
curl http://localhost:5000/health
```

**Expected Response:**
```json
{
  "status": "healthy",
  "timestamp": "2026-04-28T...",
  "uptime": 123.456,
  "environment": "development"
}
```

## Configuration

### Node.js Backend (.env)

```env
# Disable local ML model (using Flask service instead)
ML_USE_MODEL=false

# Flask ML Service Configuration
USE_FLASK_ML_SERVICE=true
FLASK_ML_SERVICE_URL=http://localhost:5001
FLASK_ML_TIMEOUT=30000
FLASK_ML_RETRY_ATTEMPTS=3
FLASK_ML_RETRY_DELAY=1000
```

### Flask ML Service (model-training/.env)

```env
FLASK_PORT=5001
FLASK_DEBUG=True
MODEL_PATH=./model/RandomForest.pkl
```

## Testing the Integration

### Test ML Prediction via Node.js

```bash
# Login first
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@clinic.rw",
    "password": "Admin@1234"
  }'

# Use the token from login response
curl -X POST http://localhost:5000/api/v1/diagnosis/predict \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "symptoms": ["fever", "cough", "fatigue"],
    "vitalSigns": {
      "temperature": 38.5,
      "heartRate": 85
    },
    "age": 30,
    "gender": "male"
  }'
```

### Test Flask ML Service Directly

```bash
curl -X POST http://localhost:5001/api/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["fever", "cough", "fatigue"],
    "vital_signs": {
      "temperature": 38.5,
      "blood_pressure_systolic": 120,
      "blood_pressure_diastolic": 80,
      "heart_rate": 85,
      "oxygen_saturation": 98
    },
    "age": 30,
    "gender": "male"
  }'
```

## Troubleshooting

### Flask Service Won't Start

**Error:** `ModuleNotFoundError: No module named 'flask'`

**Solution:**
```bash
cd model-training
pip install -r requirements.txt
```

**Error:** `FileNotFoundError: model/RandomForest.pkl`

**Solution:**
The model file is missing. Train the model first:
```bash
cd model-training
python main.py  # This will train and save the model
```

### Node.js Service Won't Start

**Error:** `Cannot find module '@types/nodemailer'`

**Solution:**
```bash
npm install --save-dev @types/nodemailer
```

**Error:** `Database connection failed`

**Solution:**
Check your DATABASE_URL in .env file and ensure PostgreSQL is running.

### ML Model Loading Failed (This is OK!)

**Message:** `Failed to load ML model, will use rule-based fallback`

**Explanation:**
This is expected! The Node.js backend is configured to use the Flask ML service instead of loading a local TensorFlow.js model. The message is harmless and the system will work correctly using the Flask service.

**To suppress this message:**
The ML_USE_MODEL=false flag is already set in .env, which disables local model loading.

### Services Can't Communicate

**Error:** `ECONNREFUSED localhost:5001`

**Solution:**
1. Ensure Flask service is running on port 5001
2. Check firewall settings
3. Verify FLASK_ML_SERVICE_URL in .env

## Port Usage

| Service | Port | URL |
|---------|------|-----|
| Node.js Backend | 5000 | http://localhost:5000 |
| Flask ML Service | 5001 | http://localhost:5001 |
| PostgreSQL | 5432 | localhost:5432 |
| Redis | 6379 | localhost:6379 |
| Admin Dashboard | 3000 | http://localhost:3000 |

## Development Workflow

### 1. Start Services
```bash
# Terminal 1: Flask ML Service
cd model-training && python api.py

# Terminal 2: Node.js Backend
cd ai_health_companion_backend && npm run dev

# Terminal 3: Admin Dashboard (optional)
cd admin_dashboard && npm run dev
```

### 2. Make Changes
- Edit code in your IDE
- Services auto-reload on file changes

### 3. Test Changes
- Use Postman or curl to test API
- Check logs in terminal
- View API docs at http://localhost:5000/api-docs

### 4. Stop Services
- Press `Ctrl+C` in each terminal

## Production Deployment

### Environment Variables

**Node.js Backend:**
```env
NODE_ENV=production
ML_USE_MODEL=false
USE_FLASK_ML_SERVICE=true
FLASK_ML_SERVICE_URL=https://ml-service.yourdomain.com
```

**Flask ML Service:**
```env
FLASK_DEBUG=False
FLASK_PORT=5001
```

### Docker Deployment

```yaml
# docker-compose.yml
version: '3.8'
services:
  nodejs-backend:
    build: ./ai_health_companion_backend
    ports:
      - "5000:5000"
    environment:
      - FLASK_ML_SERVICE_URL=http://flask-ml:5001
    depends_on:
      - flask-ml
      - postgres
      
  flask-ml:
    build: ./model-training
    ports:
      - "5001:5001"
    volumes:
      - ./model-training/model:/app/model
      
  postgres:
    image: postgres:15
    ports:
      - "5432:5432"
```

## Monitoring

### Check Service Health

```bash
# Node.js Backend
curl http://localhost:5000/health

# Flask ML Service
curl http://localhost:5001/health
```

### View Logs

```bash
# Node.js Backend
tail -f logs/app.log

# Flask ML Service
# Logs appear in terminal where Flask is running
```

### Monitor Performance

```bash
# Node.js Backend metrics
curl http://localhost:9090/metrics
```

## Next Steps

1. ✅ Both services running
2. ✅ ML predictions working
3. ⏳ Configure email service (see EMAIL_SERVICE_GUIDE.md)
4. ⏳ Set up admin dashboard
5. ⏳ Deploy to production

## Support

- **Documentation:** See README.md files in each directory
- **API Docs:** http://localhost:5000/api-docs
- **Flask ML Docs:** See model-training/README.md
- **Email Service:** See EMAIL_SERVICE_GUIDE.md

---

**Status:** ✅ Services configured and ready to start!
