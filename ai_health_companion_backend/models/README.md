# AI Model Files

Place your TensorFlow Lite (.tflite) model files in this directory.

## Expected Files

- `disease_classifier.tflite` - Main disease classification model
- `model_metadata.json` - Model metadata and labels (optional)

## Model Training

The AI model should be trained separately using TensorFlow and converted to TensorFlow Lite format for mobile deployment.

### Training Data Format

The model expects the following input features:
1. Vital signs (normalized 0-1):
   - Temperature
   - Blood pressure (systolic/diastolic)
   - Heart rate
   - Respiratory rate
   - Oxygen saturation

2. Patient demographics:
   - Age (normalized)
   - Gender (one-hot encoded)

3. Symptoms (categorical encoding):
   - Respiratory symptoms
   - Digestive symptoms
   - Neurological symptoms
   - Cardiovascular symptoms
   - General symptoms

### Output Format

The model outputs a probability distribution over disease classes.

## Note

For development/testing, the AI service includes a mock prediction function that uses rule-based logic. Replace this with actual model inference in production.
