# Quick Start: ML Model Implementation

## 🎯 Goal
Train and deploy an ML model for disease prediction in the AI Health Companion system.

## ⚡ Quick Start (5 Minutes)

### Step 1: Train a Model (with sample data)

```bash
cd ml-training
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
python scripts/train.py
```

This creates a sample dataset and trains a model automatically.

### Step 2: Deploy the Model

```bash
xcopy /E /I models\tfjs ..\models\v1.0.0
copy models\metadata.json ..\models\v1.0.0\
```

### Step 3: Configure & Run

```bash
cd ..
echo ML_USE_MODEL=true >> .env
echo ML_MODEL_VERSION=v1.0.0 >> .env
npm run dev
```

### Step 4: Test

```bash
curl -X POST http://localhost:3000/api/diagnosis -H "Content-Type: application/json" -d "{\"patientId\":\"test\",\"symptoms\":[{\"name\":\"fever\",\"category\":\"general\"}],\"vitalSigns\":{\"temperature\":38.5},\"age\":35,\"gender\":\"male\"}"
```

## 📊 What You Get

- ✅ Trained neural network model
- ✅ TensorFlow.js format (offline-capable)
- ✅ Automatic fallback to rule-based predictions
- ✅ ICD-10 codes and recommendations
- ✅ Evaluation report with metrics

## 📁 Key Files

| File | Purpose |
|------|---------|
| `ml-training/scripts/train.py` | Main training script |
| `ml-training/config/training_config.json` | Training configuration |
| `models/v1.0.0/model.json` | Deployed model |
| `models/v1.0.0/metadata.json` | Model metadata |
| `src/services/ai.service.ts` | AI service (uses ML model) |

## 🔧 Configuration

Edit `.env`:

```env
# Enable ML model
ML_USE_MODEL=true
ML_MODEL_VERSION=v1.0.0

# Prediction settings
ML_CONFIDENCE_THRESHOLD=0.6
ML_MAX_PREDICTIONS=5

# Fallback (always enabled)
ML_FALLBACK_ENABLED=true
```

## 📖 Full Documentation

- **Implementation Guide**: `ML_MODEL_IMPLEMENTATION_GUIDE.md`
- **Status Report**: `ML_IMPLEMENTATION_STATUS.md`
- **Complete Guide**: `ML_IMPLEMENTATION_COMPLETE.md`
- **Training Pipeline**: `ml-training/README.md`

## 🎓 Using Real Datasets

Replace sample data with real datasets:

1. Download DDXPlus dataset → `ml-training/data/ddxplus.csv`
2. Download AfriMedQA dataset → `ml-training/data/afrimedqa.csv`
3. Run: `python scripts/train.py`

## ✅ Verification

Check if ML model is working:

```bash
# Start backend
npm run dev

# Check logs for:
# "ML model initialized successfully" ✅
# or
# "Using rule-based fallback" (no model deployed)
```

## 🚀 Production Deployment

1. Train with real datasets
2. Verify accuracy ≥90% in evaluation report
3. Deploy model to production server
4. Monitor predictions

## 💡 Tips

- **No datasets?** Training script creates sample data automatically
- **Model not loading?** System falls back to rule-based predictions
- **Want to test?** Works without ML model using fallback
- **Need help?** Check logs in `logs/combined.log`

## 🎉 Success!

You now have a working ML-powered disease prediction system!

**Next**: Train with real medical datasets for production use.
