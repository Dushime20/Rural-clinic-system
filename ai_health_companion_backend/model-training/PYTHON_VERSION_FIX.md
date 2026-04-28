# Python Version Compatibility Fix

## Problem

**Error:** `ERROR: Could not find a version that satisfies the requirement tensorflow>=2.13.0`

**Root Cause:** Python 3.14 is too new for TensorFlow. TensorFlow currently supports Python 3.9-3.11 only.

## Solution

Since the Flask ML API uses the existing Random Forest model (`.pkl` file) and doesn't need TensorFlow for serving predictions, we separated the requirements into two files:

### 1. `requirements.txt` - Flask API Requirements (Python 3.14 compatible)

```
Flask>=2.3.0
flask-cors>=4.0.0
numpy>=1.24.0
pandas>=2.0.0
scikit-learn>=1.3.0
fuzzywuzzy>=0.18.0
python-Levenshtein>=0.21.0
gunicorn>=21.0.0
setuptools>=65.0.0
python-dotenv>=1.0.0
```

**Use this for:** Running the Flask ML API service

### 2. `requirements-tensorflow.txt` - TensorFlow Training Requirements (Python 3.9-3.11 only)

```
tensorflow>=2.13.0,<2.18.0
tensorflowjs>=4.0.0
numpy>=1.24.0,<2.0.0
pandas>=2.0.0
scikit-learn>=1.3.0
python-dotenv>=1.0.0
```

**Use this for:** Training TensorFlow Lite models for mobile deployment

## Installation

### For Flask API Service (Current Setup)

```bash
cd model-training
pip install -r requirements.txt
python api.py
```

**Status:** ✅ Working with Python 3.14

### For TensorFlow Model Training (Future Use)

If you need to train TensorFlow models:

1. **Install Python 3.11:**
   - Download from https://www.python.org/downloads/
   - Or use pyenv: `pyenv install 3.11`

2. **Create virtual environment:**
   ```bash
   python3.11 -m venv venv-tf
   
   # Windows
   venv-tf\Scripts\activate
   
   # Linux/Mac
   source venv-tf/bin/activate
   ```

3. **Install TensorFlow requirements:**
   ```bash
   pip install -r requirements-tensorflow.txt
   ```

4. **Train model:**
   ```bash
   python train_tensorflow_model.py
   ```

## Current Architecture

```
┌─────────────────────────────────────┐
│   Flask ML API (Port 5001)         │
│   Python 3.14 ✅                    │
│                                     │
│   Uses:                             │
│   - Random Forest Model (.pkl)      │
│   - scikit-learn                    │
│   - Flask                           │
│   - pandas, numpy                   │
│                                     │
│   Does NOT need:                    │
│   - TensorFlow ❌                   │
│   - TensorFlow.js ❌                │
└─────────────────────────────────────┘
```

## Why This Works

### Random Forest Model
- Trained with scikit-learn
- Saved as `.pkl` file
- Loaded with pickle
- No TensorFlow needed for inference

### TensorFlow Models
- Only needed for mobile deployment
- Converts to TensorFlow Lite (.tflite)
- Runs on-device in Flutter app
- Training is separate from API serving

## Verification

### Check Flask Service

```bash
# Start service
cd model-training
python api.py
```

**Expected Output:**
```
INFO:__main__:Model and datasets loaded successfully
 * Running on http://0.0.0.0:5001
```

### Test Health Endpoint

```bash
curl http://localhost:5001/health
```

**Expected Response:**
```json
{
  "model_loaded": true,
  "service": "ml-prediction-service",
  "status": "healthy",
  "timestamp": "2026-04-28T..."
}
```

### Test Prediction

```bash
curl -X POST http://localhost:5001/api/predict \
  -H "Content-Type: application/json" \
  -d '{
    "symptoms": ["fever", "cough", "fatigue"],
    "vital_signs": {
      "temperature": 38.5,
      "heart_rate": 85
    },
    "age": 30,
    "gender": "male"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "predictions": [
    {
      "disease": "Common Cold",
      "confidence": 0.85,
      "icd10_code": "J00",
      "description": "...",
      "precautions": [...],
      "medications": [...],
      "diet": [...],
      "workout": [...]
    }
  ]
}
```

## Python Version Compatibility Matrix

| Component | Python 3.9 | Python 3.10 | Python 3.11 | Python 3.12 | Python 3.14 |
|-----------|------------|-------------|-------------|-------------|-------------|
| Flask API | ✅ | ✅ | ✅ | ✅ | ✅ |
| scikit-learn | ✅ | ✅ | ✅ | ✅ | ✅ |
| TensorFlow | ✅ | ✅ | ✅ | ❌ | ❌ |
| TensorFlow.js | ✅ | ✅ | ✅ | ❌ | ❌ |

## Troubleshooting

### Issue: "No module named 'flask'"

**Solution:**
```bash
pip install -r requirements.txt
```

### Issue: "FileNotFoundError: model/RandomForest.pkl"

**Solution:**
The model file is missing. Train it first:
```bash
python main.py
```

### Issue: "TensorFlow not found" (when training)

**Solution:**
Use Python 3.11 and install TensorFlow requirements:
```bash
python3.11 -m venv venv-tf
source venv-tf/bin/activate  # or venv-tf\Scripts\activate on Windows
pip install -r requirements-tensorflow.txt
```

### Issue: "ImportError: numpy.core.multiarray"

**Solution:**
Update numpy:
```bash
pip install --upgrade numpy
```

## Files Modified

1. **`requirements.txt`** - Removed TensorFlow, added comments
2. **`requirements-tensorflow.txt`** - Created new file for TensorFlow training

## Status

✅ **Flask API:** Running successfully on Python 3.14  
✅ **Random Forest Model:** Loading and predicting correctly  
✅ **All dependencies:** Installed successfully  
⏳ **TensorFlow training:** Available with Python 3.11 (optional)  

## Next Steps

1. ✅ Flask service running
2. ✅ Model loaded successfully
3. ⏳ Test predictions from Node.js backend
4. ⏳ Deploy both services together
5. ⏳ (Optional) Train TensorFlow Lite model for mobile

## Summary

**Problem:** TensorFlow incompatible with Python 3.14  
**Solution:** Separated Flask API (no TensorFlow) from TensorFlow training  
**Result:** Flask API works perfectly with Python 3.14  
**Status:** ✅ RESOLVED

---

**Date:** April 28, 2026  
**Python Version:** 3.14.3  
**Flask Version:** 3.1.3  
**Status:** ✅ Working
