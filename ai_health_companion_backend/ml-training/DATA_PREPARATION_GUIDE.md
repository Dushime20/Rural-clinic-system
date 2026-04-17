# Data Preparation Guide for ML Model Training

## Overview

This guide explains how to prepare and provide data to train the ML model for disease prediction.

## Data Format Requirements

### Required CSV Format

Your training data should be a CSV file with these columns:

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| age | integer | Patient age (0-100) | 35 |
| gender | string | Patient gender | male, female, other |
| temperature | float | Body temperature (°C) | 38.5 |
| bloodPressureSystolic | integer | Systolic BP (mmHg) | 120 |
| bloodPressureDiastolic | integer | Diastolic BP (mmHg) | 80 |
| heartRate | integer | Heart rate (bpm) | 85 |
| respiratoryRate | integer | Respiratory rate (breaths/min) | 18 |
| oxygenSaturation | float | O2 saturation (%) | 96 |
| diagnosis | string | Disease name | Influenza, Malaria, etc. |

### Example CSV File

```csv
age,gender,temperature,bloodPressureSystolic,bloodPressureDiastolic,heartRate,respiratoryRate,oxygenSaturation,diagnosis
35,male,38.5,120,80,85,18,96,Influenza
42,female,37.2,140,90,78,16,98,Hypertension
28,male,39.1,115,75,95,22,94,Malaria
55,female,36.8,150,95,82,17,97,Diabetes
30,male,38.9,118,78,92,20,95,Pneumonia
```

## Method 1: Use Existing Medical Datasets

### DDXPlus Dataset (Recommended)

1. **Download DDXPlus dataset**
   - Source: [DDXPlus on GitHub](https://github.com/mila-iqia/ddxplus)
   - Contains: 1.3M cases, 49 diseases
   - Format: CSV with symptoms and diagnoses

2. **Place in data directory**
   ```bash
   # Download and extract
   # Then move to:
   ml-training/data/ddxplus.csv
   ```

3. **Train the model**
   ```bash
   python scripts/train.py
   ```

### AfriMedQA Dataset (Optional)

For African-specific diseases:

1. Download AfriMedQA dataset
2. Place in: `ml-training/data/afrimedqa.csv`
3. The training script will automatically merge it with DDXPlus

## Method 2: Export from Your Database

If you have patient data in your PostgreSQL database:

### Step 1: Install Required Package

```bash
pip install psycopg2-binary python-dotenv
```

### Step 2: Configure Database Connection

Make sure your `.env` file has database credentials:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=health_companion
DB_USER=postgres
DB_PASSWORD=your_password
```

### Step 3: Run Export Script

```bash
cd ml-training
python scripts/export_from_database.py
```

This will:
1. Connect to your database
2. Query confirmed diagnosis records
3. Export to `data/ddxplus.csv`
4. Show statistics about exported data

### Step 4: Train the Model

```bash
python scripts/train.py
```

## Method 3: Create Sample Data (For Testing)

If you don't have real data yet, the training script automatically creates sample data:

```bash
cd ml-training
python scripts/train.py
```

The script will:
1. Detect no dataset exists
2. Generate 1000 sample records with realistic values
3. Save to `data/ddxplus.csv`
4. Train on the sample data

**Note:** Sample data is for testing only. Use real medical data for production.

## Method 4: Manual CSV Creation

### Step 1: Create CSV File

Create `ml-training/data/ddxplus.csv` with your data:

```csv
age,gender,temperature,bloodPressureSystolic,bloodPressureDiastolic,heartRate,respiratoryRate,oxygenSaturation,diagnosis
35,male,38.5,120,80,85,18,96,Influenza
42,female,37.2,140,90,78,16,98,Hypertension
28,male,39.1,115,75,95,22,94,Malaria
```

### Step 2: Validate Data

```bash
python scripts/validate_data.py
```

### Step 3: Train Model

```bash
python scripts/train.py
```

## Data Quality Requirements

### Minimum Requirements

- **Minimum records**: 100 (for testing), 10,000+ (for production)
- **Minimum diseases**: 5 (for testing), 15+ (for production)
- **Data balance**: Each disease should have at least 50 examples
- **Missing values**: <10% per column

### Data Quality Checklist

✅ All required columns present
✅ Age values between 0-120
✅ Gender values: male, female, or other
✅ Vital signs in realistic ranges
✅ Diagnosis names consistent (no typos)
✅ No duplicate records
✅ Sufficient examples per disease

## Data Preprocessing (Automatic)

The training script automatically handles:

- **Missing values**: Median imputation for vitals, zero-fill for symptoms
- **Normalization**: All features scaled to [0, 1]
- **Encoding**: Gender one-hot encoded, symptoms multi-hot encoded
- **Splitting**: 70% train, 15% validation, 15% test

## Advanced: Adding Symptoms Data

If your data includes symptoms, create a more detailed CSV:

```csv
age,gender,temperature,bloodPressureSystolic,bloodPressureDiastolic,heartRate,respiratoryRate,oxygenSaturation,symptom_fever,symptom_cough,symptom_headache,diagnosis
35,male,38.5,120,80,85,18,96,1,1,0,Influenza
42,female,37.2,140,90,78,16,98,0,0,1,Hypertension
```

Where symptom columns are binary (1 = present, 0 = absent).

## Example: Complete Workflow

### Using Database Export

```bash
# 1. Export from database
cd ml-training
python scripts/export_from_database.py

# 2. Review exported data
# Check: data/ddxplus.csv

# 3. Train model
python scripts/train.py

# 4. Review results
# Check: models/evaluation_report.html

# 5. Deploy model
cd ..
xcopy /E /I ml-training\models\tfjs models\v1.0.0
copy ml-training\models\metadata.json models\v1.0.0\
```

### Using Manual CSV

```bash
# 1. Create CSV file
# Edit: ml-training/data/ddxplus.csv

# 2. Train model
cd ml-training
python scripts/train.py

# 3. Deploy model
cd ..
xcopy /E /I ml-training\models\tfjs models\v1.0.0
copy ml-training\models\metadata.json models\v1.0.0\
```

## Troubleshooting

### "Dataset not found"

**Solution**: Place CSV file at `ml-training/data/ddxplus.csv` or let the script create sample data.

### "Missing required columns"

**Solution**: Ensure your CSV has all required columns (age, gender, vitals, diagnosis).

### "Insufficient data"

**Solution**: Need at least 100 records. Use sample data for testing or collect more real data.

### "Low accuracy"

**Solutions**:
- Increase training data (more records)
- Balance disease distribution (similar counts per disease)
- Improve data quality (remove outliers, fix errors)
- Adjust hyperparameters in `config/training_config.json`

## Data Privacy & Security

⚠️ **Important**: When using real patient data:

1. **Anonymize data**: Remove patient identifiers (names, IDs, etc.)
2. **Comply with regulations**: Follow HIPAA, GDPR, or local laws
3. **Secure storage**: Encrypt data files
4. **Access control**: Limit who can access training data
5. **Audit trail**: Log data access and usage

## Next Steps

After preparing your data:

1. ✅ Place CSV in `ml-training/data/ddxplus.csv`
2. ✅ Run `python scripts/train.py`
3. ✅ Review evaluation report
4. ✅ Deploy model to backend
5. ✅ Test predictions

## Support

For questions about data preparation:
- Check training logs in console output
- Review `ml-training/README.md`
- Check `ML_MODEL_IMPLEMENTATION_GUIDE.md`
