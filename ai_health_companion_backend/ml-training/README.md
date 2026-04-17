# ML Training Pipeline

This directory contains the Python-based machine learning training pipeline for the AI Health Companion system.

## Overview

The training pipeline preprocesses medical datasets (DDXPlus and AfriMedQA), trains a neural network model for disease prediction, evaluates performance, and exports the model in TensorFlow.js format for deployment in the Node.js backend.

## Setup

### Prerequisites
- Python 3.9 or higher
- pip package manager

### Installation

1. Create a virtual environment:
```bash
python -m venv venv
```

2. Activate the virtual environment:
- Windows: `venv\Scripts\activate`
- Linux/Mac: `source venv/bin/activate`

3. Install dependencies:
```bash
pip install -r requirements.txt
```

## Dataset Requirements

Place the following datasets in the `data/` directory:

- **DDXPlus Dataset**: `data/ddxplus.csv` (1.3M cases, 49 diseases)
- **AfriMedQA Dataset**: `data/afrimedqa.csv` (African-specific diseases)

## Usage

### Training a Model

```bash
python scripts/train.py
```

This will:
1. Load and preprocess datasets
2. Train the neural network model
3. Evaluate model performance
4. Convert to TensorFlow.js format
5. Generate metadata and evaluation report

### Configuration

Edit `config/training_config.json` to customize:
- Model architecture (layers, units, dropout rates)
- Training hyperparameters (learning rate, batch size, epochs)
- Data split ratios
- Confidence thresholds

### Data Validation

Before training, validate your datasets:

```bash
python scripts/validate_data.py
```

### Exploratory Data Analysis

Generate data analysis reports:

```bash
python scripts/exploratory_analysis.py
```

## Output

After training, the following artifacts are generated:

- `models/tensorflow/` - TensorFlow SavedModel format
- `models/tfjs/` - TensorFlow.js format (for deployment)
- `models/metadata.json` - Model metadata (disease labels, ICD-10 codes, feature specs)
- `models/evaluation_report.html` - Performance metrics and visualizations
- `models/training_history.json` - Training loss and accuracy curves

## Model Deployment

Copy the TensorFlow.js model to the backend:

```bash
cp -r models/tfjs/* ../models/v1.0.0/
cp models/metadata.json ../models/v1.0.0/
```

## Testing

Run unit tests:
```bash
pytest tests/
```

Run property-based tests:
```bash
pytest tests/ -k property
```

## Performance Targets

- **Accuracy**: 90-95% on test set
- **Model Size**: <50MB
- **Inference Time**: <2 seconds per prediction

## Troubleshooting

### Out of Memory Errors
- Reduce batch size in `config/training_config.json`
- Use a smaller subset of data for initial testing

### Low Accuracy
- Increase number of epochs
- Adjust learning rate
- Add more features or improve feature engineering
- Check data quality and balance

### Conversion Errors
- Ensure TensorFlow and TensorFlow.js versions are compatible
- Check model uses only supported operations

## License

MIT License - See LICENSE file for details
