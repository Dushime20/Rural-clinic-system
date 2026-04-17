# ML Model Implementation Guide

## Overview

This guide explains how to train and deploy the machine learning model for the AI Health Companion system. The implementation follows the specifications in `requirements.md`, `design.md`, and `tasks.md`.

## Architecture

The ML integration consists of two main components:

### 1. Python Training Pipeline (`ml-training/`)
- Data preprocessing and feature engineering
- Neural network model training
- Model evaluation and validation
- TensorFlow.js conversion
- Metadata generation

### 2. TypeScript Backend Integration (`src/services/ml/`)
- Model loading and initialization
- Inference engine for predictions
- Fallback mechanism to rule-based system
- Performance monitoring (planned)
- A/B testing framework (planned)

## Quick Start

### Step 1: Install Python Dependencies

```bash
cd ml-training
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Step 2: Prepare Datasets

Place your datasets in `ml-training/data/`:
- `ddxplus.csv` - DDXPlus dataset (1.3M cases, 49 diseases)
- `afrimedqa.csv` - AfriMedQA dataset (optional)

If datasets are not available, the training script will create a sample dataset for testing.

### Step 3: Train the Model

```bash
cd ml-training
python scripts/train.py
```

This will:
1. Load and preprocess data
2. Engineer features
3. Train the neural network
4. Evaluate performance
5. Convert to TensorFlow.js format
6. Generate metadata and reports

Output files will be in `ml-training/models/`:
- `tensorflow/` - TensorFlow SavedModel
- `tfjs/` - TensorFlow.js model (for deployment)
- `metadata.json` - Model metadata
- `evaluation_report.html` - Performance report
- `training_history.json` - Training curves

### Step 4: Deploy the Model

Copy the trained model to the backend:

```bash
# From ml-training directory
cp -r models/tfjs/* ../models/v1.0.0/
cp models/metadata.json ../models/v1.0.0/
```

### Step 5: Install Node.js Dependencies

```bash
cd ..  # Back to backend root
npm install
```

This will install `@tensorflow/tfjs-node` which is required for model inference.

### Step 6: Configure Environment

Add to your `.env` file:

```env
# ML Model Configuration
ML_MODEL_VERSION=v1.0.0
ML_USE_MODEL=true
ML_CONFIDENCE_THRESHOLD=0.6
ML_MAX_PREDICTIONS=5
ML_FALLBACK_ENABLED=true

# A/B Testing (optional)
ML_AB_TESTING_ENABLED=false
ML_AB_TRAFFIC_PERCENTAGE=50

# Monitoring (optional)
ML_MONITORING_ENABLED=true
ML_ACCURACY_THRESHOLD=0.85
```

### Step 7: Start the Backend

```bash
npm run dev
```

The AI service will automatically:
1. Load the ML model from `models/v1.0.0/`
2. Initialize the inference engine
3. Set up fallback mechanism
4. Start accepting prediction requests

## Model Training Configuration

Edit `ml-training/config/training_config.json` to customize:

### Data Configuration
```json
{
  "data": {
    "train_ratio": 0.7,
    "val_ratio": 0.15,
    "test_ratio": 0.15,
    "random_seed": 42
  }
}
```

### Model Architecture
```json
{
  "model": {
    "architecture": [
      {"type": "dense", "units": 256, "activation": "relu"},
      {"type": "dropout", "rate": 0.3},
      {"type": "dense", "units": 128, "activation": "relu"},
      {"type": "dropout", "rate": 0.2},
      {"type": "dense", "units": 64, "activation": "relu"}
    ],
    "learning_rate": 0.001
  }
}
```

### Training Parameters
```json
{
  "training": {
    "batch_size": 32,
    "epochs": 100,
    "early_stopping_patience": 10
  }
}
```

## API Usage

The ML model is integrated into the existing diagnosis API:

### Request
```http
POST /api/diagnosis
Content-Type: application/json

{
  "patientId": "patient-123",
  "symptoms": [
    {"name": "fever", "category": "general", "severity": "high"},
    {"name": "cough", "category": "respiratory", "severity": "moderate"}
  ],
  "vitalSigns": {
    "temperature": 38.5,
    "bloodPressureSystolic": 120,
    "bloodPressureDiastolic": 80,
    "heartRate": 85,
    "respiratoryRate": 18,
    "oxygenSaturation": 96
  },
  "age": 35,
  "gender": "male"
}
```

### Response
```json
{
  "predictions": [
    {
      "disease": "Influenza",
      "confidence": 0.85,
      "icd10Code": "J11",
      "recommendations": [
        "Antiviral medication within 48 hours of symptom onset",
        "Complete bed rest",
        "Isolation to prevent spread",
        "Monitor for complications"
      ]
    },
    {
      "disease": "Common Cold",
      "confidence": 0.72,
      "icd10Code": "J00",
      "recommendations": [
        "Rest and adequate sleep",
        "Increase fluid intake",
        "Over-the-counter pain relievers if needed"
      ]
    }
  ],
  "method": "ml",
  "modelVersion": "1.0.0"
}
```

## Fallback Mechanism

The system automatically falls back to rule-based predictions if:
- ML model fails to load
- Model inference throws an error
- Model is disabled via configuration

When fallback occurs:
- Response includes `"method": "rule-based"`
- `fallbackReason` field explains why
- Predictions maintain the same format

## Model Versioning

To deploy a new model version:

1. Train the new model
2. Create a new version directory:
   ```bash
   mkdir models/v1.1.0
   cp -r ml-training/models/tfjs/* models/v1.1.0/
   cp ml-training/models/metadata.json models/v1.1.0/
   ```

3. Update `.env`:
   ```env
   ML_MODEL_VERSION=v1.1.0
   ```

4. Restart the backend

The system will automatically load the new version.

## Performance Targets

The model should meet these requirements:

- **Accuracy**: 90-95% on test set
- **Model Size**: <50MB
- **Inference Time**: <2 seconds per prediction
- **Diseases Supported**: 49 from DDXPlus + African-specific diseases

Check the evaluation report after training to verify these targets.

## Troubleshooting

### Model Not Loading

**Error**: "Failed to load ML model"

**Solutions**:
1. Verify model files exist in `models/v1.0.0/`:
   - `model.json`
   - Weight files (`.bin`)
   - `metadata.json`

2. Check file permissions

3. Verify `@tensorflow/tfjs-node` is installed:
   ```bash
   npm list @tensorflow/tfjs-node
   ```

4. Check logs for detailed error messages

### Low Accuracy

**Issue**: Model accuracy below 90%

**Solutions**:
1. Increase training epochs
2. Adjust learning rate
3. Add more training data
4. Improve feature engineering
5. Try different model architecture

### Slow Inference

**Issue**: Predictions take >2 seconds

**Solutions**:
1. Reduce model size (fewer layers/units)
2. Use model quantization
3. Optimize feature preprocessing
4. Check system resources

### Fallback Always Active

**Issue**: System always uses rule-based predictions

**Solutions**:
1. Check `ML_USE_MODEL=true` in `.env`
2. Verify model files are present
3. Check backend logs for loading errors
4. Ensure `@tensorflow/tfjs-node` is installed

## Next Steps

### Planned Features (Not Yet Implemented)

1. **A/B Testing Framework** - Compare ML vs rule-based predictions
2. **Performance Monitoring** - Track accuracy and inference time
3. **Model Versioning System** - Manage multiple model versions
4. **Automatic Retraining** - Trigger retraining on accuracy drops
5. **Property-Based Tests** - Comprehensive testing with Hypothesis/fast-check

### To Implement These Features

Follow the remaining tasks in `tasks.md`:
- Tasks 15-17: A/B testing and monitoring
- Tasks 18-20: Database migrations and controller updates
- Tasks 22-25: Documentation and testing

## Support

For issues or questions:
1. Check the logs in `logs/combined.log`
2. Review the evaluation report
3. Consult the design document
4. Check the tasks checklist

## License

MIT License - See LICENSE file for details
