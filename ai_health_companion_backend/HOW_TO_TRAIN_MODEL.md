# How to Train the ML Model - Simple Guide

## 🎯 Three Ways to Provide Training Data

### Option 1: Automatic Sample Data (Easiest - For Testing)

**No data needed!** The script creates sample data automatically.

```bash
cd ml-training
python scripts/train.py
```

✅ **Done!** The script will:
- Create 1000 sample patient records
- Train the model
- Generate evaluation report

---

### Option 2: Use Your Database (Recommended - For Production)

**Export real patient data from your PostgreSQL database.**

#### Step 1: Run Export Script

```bash
cd ml-training
python scripts/export_from_database.py
```

This exports confirmed diagnoses from your database to `data/ddxplus.csv`

#### Step 2: Train Model

```bash
python scripts/train.py
```

✅ **Done!** Model trained on your real data.

---

### Option 3: Manual CSV File (Custom Data)

**Create your own CSV file with patient data.**

#### Step 1: Create CSV File

Create `ml-training/data/ddxplus.csv` with this format:

```csv
age,gender,temperature,bloodPressureSystolic,bloodPressureDiastolic,heartRate,respiratoryRate,oxygenSaturation,diagnosis
35,male,38.5,120,80,85,18,96,Influenza
42,female,37.2,140,90,78,16,98,Hypertension
28,male,39.1,115,75,95,22,94,Malaria
```

**See example**: `ml-training/data/example_dataset.csv`

#### Step 2: Train Model

```bash
cd ml-training
python scripts/train.py
```

✅ **Done!** Model trained on your CSV data.

---

## 📊 CSV Format Explained

Your CSV file needs these columns:

| Column | What It Is | Example |
|--------|------------|---------|
| `age` | Patient age | 35 |
| `gender` | Patient gender | male, female |
| `temperature` | Body temp (°C) | 38.5 |
| `bloodPressureSystolic` | Upper BP number | 120 |
| `bloodPressureDiastolic` | Lower BP number | 80 |
| `heartRate` | Heart beats/min | 85 |
| `respiratoryRate` | Breaths/min | 18 |
| `oxygenSaturation` | O2 level (%) | 96 |
| `diagnosis` | Disease name | Influenza |

**Example CSV:**
```csv
age,gender,temperature,bloodPressureSystolic,bloodPressureDiastolic,heartRate,respiratoryRate,oxygenSaturation,diagnosis
35,male,38.5,120,80,85,18,96,Influenza
42,female,37.2,140,90,78,16,98,Hypertension
```

---

## 🚀 Complete Training Workflow

### Quick Start (5 Minutes)

```bash
# 1. Go to training directory
cd ml-training

# 2. Install Python dependencies (first time only)
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

# 3. Train model (creates sample data if none exists)
python scripts/train.py

# 4. Deploy model to backend
cd ..
xcopy /E /I ml-training\models\tfjs models\v1.0.0
copy ml-training\models\metadata.json models\v1.0.0\

# 5. Run backend
npm run dev
```

✅ **Done!** Your ML model is now running!

---

## 📁 Where to Put Your Data

```
ml-training/
  data/
    ddxplus.csv          ← Put your main dataset here
    afrimedqa.csv        ← Optional: African diseases
    example_dataset.csv  ← Example format (reference)
```

---

## 🔍 What Happens During Training

1. **Load Data** - Reads your CSV file
2. **Preprocess** - Cleans and normalizes data
3. **Split Data** - 70% train, 15% validation, 15% test
4. **Train Model** - Neural network learns patterns
5. **Evaluate** - Tests accuracy on unseen data
6. **Convert** - Exports to TensorFlow.js format
7. **Generate Report** - Creates evaluation report

**Output Files:**
- `models/tfjs/` - Trained model (deploy this)
- `models/metadata.json` - Model info (deploy this)
- `models/evaluation_report.html` - Performance report (review this)

---

## 📈 Data Requirements

### Minimum (For Testing)
- ✅ 100+ patient records
- ✅ 5+ different diseases
- ✅ CSV format with required columns

### Recommended (For Production)
- ✅ 10,000+ patient records
- ✅ 15+ different diseases
- ✅ Balanced data (similar counts per disease)
- ✅ Real, validated diagnoses

---

## 💡 Tips

### "I don't have any data yet"
→ Use **Option 1** (automatic sample data) for testing

### "I have patient data in my database"
→ Use **Option 2** (database export script)

### "I have data in Excel/CSV"
→ Use **Option 3** (manual CSV file)

### "I want to use public datasets"
→ Download DDXPlus dataset and place in `data/ddxplus.csv`

---

## ✅ Verify Training Success

After training, check:

1. **Console Output**
   ```
   Training completed
   Model Accuracy: 0.92
   Model Size: 15.3 MB
   ```

2. **Evaluation Report**
   - Open: `ml-training/models/evaluation_report.html`
   - Check: Accuracy ≥ 90%

3. **Model Files**
   - `models/tfjs/model.json` exists
   - `models/metadata.json` exists

---

## 🎓 Example: Training with Your Database

```bash
# 1. Make sure your .env has database credentials
# DB_HOST=localhost
# DB_NAME=health_companion
# DB_USER=postgres
# DB_PASSWORD=your_password

# 2. Export data from database
cd ml-training
python scripts/export_from_database.py

# Output:
# ✅ Fetched 5000 records from database
# ✅ Data exported to data/ddxplus.csv
# ✅ Unique diagnoses: 15

# 3. Train model
python scripts/train.py

# Output:
# ✅ Model Accuracy: 0.93
# ✅ Model saved to models/tfjs/

# 4. Deploy
cd ..
xcopy /E /I ml-training\models\tfjs models\v1.0.0
copy ml-training\models\metadata.json models\v1.0.0\

# 5. Test
npm run dev
# Check logs: "ML model initialized successfully"
```

---

## 📚 More Information

- **Detailed Guide**: `DATA_PREPARATION_GUIDE.md`
- **Implementation Guide**: `ML_MODEL_IMPLEMENTATION_GUIDE.md`
- **Quick Start**: `QUICK_START_ML.md`

---

## 🆘 Troubleshooting

### "No dataset found"
→ Place CSV at `ml-training/data/ddxplus.csv` or let script create sample data

### "Low accuracy (<90%)"
→ Need more training data or better quality data

### "Model too large (>50MB)"
→ Reduce model size in `config/training_config.json`

### "Training takes too long"
→ Reduce epochs or use smaller dataset for testing

---

## 🎉 Success!

Once training completes, you have:
- ✅ Trained ML model
- ✅ Evaluation report
- ✅ Ready to deploy

**Next**: Deploy the model and test predictions!
