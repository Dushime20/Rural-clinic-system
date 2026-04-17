# AI Model Development Guide for Rural Healthcare Diagnosis

## 🎯 Overview

This guide provides a comprehensive algorithm and methodology for building, training, and evaluating an AI model that meets international healthcare standards for the Rural Clinic AI Health Companion application.

---

## 📋 Table of Contents

1. [Problem Definition & Requirements](#1-problem-definition--requirements)
2. [Data Collection & Preparation](#2-data-collection--preparation)
3. [Model Architecture Selection](#3-model-architecture-selection)
4. [Training Strategy](#4-training-strategy)
5. [Model Evaluation](#5-model-evaluation-international-standards)
6. [Model Optimization for Mobile](#6-model-optimization-for-mobile-deployment)
7. [Continuous Improvement](#7-continuous-improvement-pipeline)
8. [Implementation Checklist](#8-implementation-checklist)
9. [Success Criteria](#9-key-success-criteria)

---

## 1. Problem Definition & Requirements

### Objective
Build a multi-class disease classification model that:
- ✅ Works offline on mobile devices (TensorFlow Lite)
- ✅ Predicts diseases from symptoms, vital signs, and patient demographics
- ✅ Provides confidence scores for top 3 predictions
- ✅ Meets HIPAA/GDPR compliance standards
- ✅ Achieves clinical-grade accuracy (>85% for common diseases)

### Target Diseases (Example Set)
```
Common Rural Diseases:
1. Malaria
2. Typhoid Fever
3. Dengue Fever
4. Pneumonia
5. Tuberculosis
6. Diarrheal Diseases
7. Respiratory Infections
8. Hypertension
9. Diabetes
10. Malnutrition
11. Skin Infections
12. Urinary Tract Infections
13. Anemia
14. Gastroenteritis
15. Common Cold/Flu
```

### Constraints
- **Model Size**: <10MB (for mobile deployment)
- **Inference Time**: <100ms per prediction
- **Offline Operation**: 100% functionality without internet
- **Accuracy**: >85% overall, >90% for critical diseases
- **Privacy**: HIPAA/GDPR compliant

---

## 2. Data Collection & Preparation

### 2.1 Data Sources (International Standards)

#### Public Medical Datasets
```
1. MIMIC-III (Medical Information Mart for Intensive Care)
   - Source: MIT Lab for Computational Physiology
   - Contains: 40,000+ ICU patients
   - Access: https://mimic.mit.edu/

2. UK Biobank
   - Source: UK Biobank Limited
   - Contains: 500,000+ participants
   - Access: https://www.ukbiobank.ac.uk/

3. WHO Global Health Observatory
   - Source: World Health Organization
   - Contains: Global disease statistics
   - Access: https://www.who.int/data/gho

4. CDC Disease Surveillance Data
   - Source: Centers for Disease Control
   - Contains: US disease surveillance
   - Access: https://www.cdc.gov/

5. Kaggle Medical Datasets
   - Disease Symptom Prediction
   - Medical Diagnosis Dataset
   - Healthcare Provider Fraud Detection
```

#### Synthetic Data Generation
```python
# Use medical knowledge bases
- SNOMED CT (Systematized Nomenclature of Medicine)
- ICD-10 (International Classification of Diseases)
- UMLS (Unified Medical Language System)

# Generate realistic symptom combinations
- Rule-based generation from medical literature
- Expert physician validation
- Augment with demographic variations
```

#### Local Clinical Data
```
Requirements:
- Partner with rural clinics (anonymized data)
- Collect region-specific disease patterns
- Ensure ethical approval and consent
- IRB (Institutional Review Board) approval
- Patient consent forms
- Data anonymization protocols
```

### 2.2 Data Structure

#### Input Features Schema
```python
{
    # Symptoms (Binary Encoding: 0/1)
    "symptoms": {
        "fever": 1,
        "cough": 1,
        "headache": 0,
        "fatigue": 1,
        "nausea": 0,
        "vomiting": 0,
        "diarrhea": 0,
        "sore_throat": 1,
        "shortness_of_breath": 0,
        "dizziness": 0,
        "joint_pain": 1,
        "muscle_ache": 1,
        "chills": 1,
        "abdominal_pain": 0,
        "chest_pain": 0,
        "loss_of_appetite": 1
    },
    
    # Vital Signs (Continuous Values)
    "vital_signs": {
        "temperature": 38.5,           # °C (Normal: 36.5-37.5)
        "blood_pressure_systolic": 120, # mmHg (Normal: 90-120)
        "blood_pressure_diastolic": 80, # mmHg (Normal: 60-80)
        "heart_rate": 75,               # bpm (Normal: 60-100)
        "respiratory_rate": 16,         # breaths/min (Normal: 12-20)
        "oxygen_saturation": 98         # % (Normal: 95-100)
    },
    
    # Demographics (Mixed Types)
    "demographics": {
        "age": 45,                      # years
        "gender": "male",               # male/female/other
        "weight": 75,                   # kg
        "height": 175,                  # cm
        "bmi": 24.5                     # calculated
    },
    
    # Medical History (Binary Encoding)
    "medical_history": {
        "diabetes": 0,
        "hypertension": 1,
        "asthma": 0,
        "heart_disease": 0,
        "kidney_disease": 0,
        "hiv_aids": 0,
        "tuberculosis": 0,
        "malaria_previous": 1,
        "allergies": 0,
        "pregnancy": 0
    }
}
```

#### Output Labels Schema
```python
{
    "primary_diagnosis": "malaria",
    "confidence": 0.85,
    "top_3_predictions": [
        {"disease": "malaria", "confidence": 0.85},
        {"disease": "dengue", "confidence": 0.10},
        {"disease": "typhoid", "confidence": 0.05}
    ],
    "severity": "moderate",  # mild/moderate/severe/critical
    "recommendations": [
        "Administer antimalarial medication",
        "Monitor temperature every 4 hours",
        "Ensure adequate hydration"
    ]
}
```


### 2.3 Data Preprocessing Pipeline

#### Step 1: Data Cleaning
```python
import pandas as pd
import numpy as np

def clean_data(df):
    """Clean and validate medical data"""
    
    # 1. Remove duplicates
    df = df.drop_duplicates(subset=['patient_id', 'visit_date'])
    
    # 2. Handle missing values
    # Vital signs: Use median imputation
    vital_cols = ['temperature', 'blood_pressure_sys', 'heart_rate']
    df[vital_cols] = df[vital_cols].fillna(df[vital_cols].median())
    
    # Symptoms: Missing = Not present (0)
    symptom_cols = [col for col in df.columns if 'symptom_' in col]
    df[symptom_cols] = df[symptom_cols].fillna(0)
    
    # 3. Outlier detection for vital signs
    def remove_outliers(df, column, lower_percentile=1, upper_percentile=99):
        lower = df[column].quantile(lower_percentile/100)
        upper = df[column].quantile(upper_percentile/100)
        df[column] = df[column].clip(lower, upper)
        return df
    
    for col in vital_cols:
        df = remove_outliers(df, col)
    
    # 4. Validate data ranges
    assert df['temperature'].between(35, 42).all(), "Invalid temperature"
    assert df['heart_rate'].between(40, 200).all(), "Invalid heart rate"
    assert df['age'].between(0, 120).all(), "Invalid age"
    
    return df
```

#### Step 2: Feature Engineering
```python
def engineer_features(df):
    """Create additional features from raw data"""
    
    # 1. BMI calculation
    df['bmi'] = df['weight'] / ((df['height'] / 100) ** 2)
    
    # 2. Age groups
    df['age_group'] = pd.cut(df['age'], 
                              bins=[0, 18, 40, 60, 120],
                              labels=['child', 'adult', 'middle_age', 'senior'])
    
    # 3. Fever indicator
    df['has_fever'] = (df['temperature'] > 37.5).astype(int)
    
    # 4. Hypertension indicator
    df['has_hypertension'] = ((df['blood_pressure_sys'] > 140) | 
                               (df['blood_pressure_dia'] > 90)).astype(int)
    
    # 5. Symptom count
    symptom_cols = [col for col in df.columns if 'symptom_' in col]
    df['symptom_count'] = df[symptom_cols].sum(axis=1)
    
    # 6. Vital signs severity score
    df['vital_severity'] = (
        (df['temperature'] > 38).astype(int) +
        (df['heart_rate'] > 100).astype(int) +
        (df['respiratory_rate'] > 20).astype(int) +
        (df['oxygen_saturation'] < 95).astype(int)
    )
    
    return df
```

#### Step 3: Feature Encoding
```python
from sklearn.preprocessing import StandardScaler, LabelEncoder, OneHotEncoder

def encode_features(df):
    """Encode features for model training"""
    
    # 1. Symptom encoding (already binary 0/1)
    symptom_cols = [col for col in df.columns if 'symptom_' in col]
    X_symptoms = df[symptom_cols].values
    
    # 2. Vital signs normalization (z-score)
    vital_cols = ['temperature', 'blood_pressure_sys', 'blood_pressure_dia',
                  'heart_rate', 'respiratory_rate', 'oxygen_saturation']
    scaler = StandardScaler()
    X_vitals = scaler.fit_transform(df[vital_cols])
    
    # 3. Demographics encoding
    # Age: normalize
    age_scaler = StandardScaler()
    X_age = age_scaler.fit_transform(df[['age']])
    
    # Gender: one-hot encoding
    gender_encoder = OneHotEncoder(sparse=False)
    X_gender = gender_encoder.fit_transform(df[['gender']])
    
    # BMI: normalize
    bmi_scaler = StandardScaler()
    X_bmi = bmi_scaler.fit_transform(df[['bmi']])
    
    # 4. Medical history encoding (binary)
    history_cols = [col for col in df.columns if 'history_' in col]
    X_history = df[history_cols].values
    
    # 5. Combine all features
    X = np.concatenate([X_symptoms, X_vitals, X_age, X_gender, 
                        X_bmi, X_history], axis=1)
    
    # 6. Label encoding
    label_encoder = LabelEncoder()
    y = label_encoder.fit_transform(df['disease'])
    
    return X, y, scaler, label_encoder
```

#### Step 4: Data Balancing
```python
from imblearn.over_sampling import SMOTE
from sklearn.utils.class_weight import compute_class_weight

def balance_data(X, y):
    """Balance imbalanced disease classes"""
    
    # 1. Check class distribution
    unique, counts = np.unique(y, return_counts=True)
    print("Class distribution:", dict(zip(unique, counts)))
    
    # 2. Apply SMOTE for minority classes
    smote = SMOTE(sampling_strategy='auto', random_state=42)
    X_balanced, y_balanced = smote.fit_resample(X, y)
    
    # 3. Compute class weights (alternative to SMOTE)
    class_weights = compute_class_weight(
        'balanced',
        classes=np.unique(y),
        y=y
    )
    class_weight_dict = dict(enumerate(class_weights))
    
    return X_balanced, y_balanced, class_weight_dict
```

#### Step 5: Train/Val/Test Split
```python
from sklearn.model_selection import train_test_split

def split_data(X, y, test_size=0.15, val_size=0.15):
    """Split data with stratification"""
    
    # 1. Split into train+val and test
    X_temp, X_test, y_temp, y_test = train_test_split(
        X, y, test_size=test_size, stratify=y, random_state=42
    )
    
    # 2. Split train+val into train and val
    val_size_adjusted = val_size / (1 - test_size)
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp, test_size=val_size_adjusted, 
        stratify=y_temp, random_state=42
    )
    
    print(f"Train: {len(X_train)} samples")
    print(f"Val: {len(X_val)} samples")
    print(f"Test: {len(X_test)} samples")
    
    return X_train, X_val, X_test, y_train, y_val, y_test
```

### 2.4 Data Quality Checklist

```
✅ Data Collection:
   - Minimum 10,000 samples per disease class
   - Diverse demographics (age, gender, geography)
   - Balanced representation of disease severity

✅ Data Cleaning:
   - No duplicates
   - Missing values handled appropriately
   - Outliers detected and managed
   - Data ranges validated

✅ Feature Engineering:
   - Relevant features created
   - Domain knowledge incorporated
   - Feature correlations analyzed

✅ Data Splitting:
   - Stratified sampling
   - No data leakage
   - Representative test set

✅ Documentation:
   - Data sources documented
   - Preprocessing steps recorded
   - Feature definitions clear
   - Ethical approvals obtained
```

---

## 3. Model Architecture Selection

### 3.1 Recommended Approach: Ensemble Model

#### Architecture Overview
```
┌─────────────────────────────────────────────────────────┐
│                    Input Features                       │
│  (Symptoms + Vital Signs + Demographics + History)     │
└─────────────────────────────────────────────────────────┘
                          ↓
        ┌─────────────────┼─────────────────┐
        ↓                 ↓                 ↓
┌───────────────┐  ┌──────────────┐  ┌──────────────┐
│  Deep Neural  │  │    Random    │  │   Gradient   │
│   Network     │  │    Forest    │  │   Boosting   │
│   (Primary)   │  │ (Secondary)  │  │  (Tertiary)  │
└───────────────┘  └──────────────┘  └──────────────┘
        ↓                 ↓                 ↓
        └─────────────────┼─────────────────┘
                          ↓
                ┌──────────────────┐
                │ Weighted Ensemble │
                │  [0.5, 0.3, 0.2]  │
                └──────────────────┘
                          ↓
                ┌──────────────────┐
                │ Final Prediction │
                │  + Confidence    │
                └──────────────────┘
```

### 3.2 Model 1: Deep Neural Network (Primary)

```python
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

def build_dnn_model(input_dim, num_classes):
    """Build Deep Neural Network for disease classification"""
    
    model = keras.Sequential([
        # Input layer
        layers.Input(shape=(input_dim,)),
        
        # First hidden layer
        layers.Dense(256, activation='relu', 
                     kernel_regularizer=keras.regularizers.l2(0.001)),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        
        # Second hidden layer
        layers.Dense(128, activation='relu',
                     kernel_regularizer=keras.regularizers.l2(0.001)),
        layers.BatchNormalization(),
        layers.Dropout(0.3),
        
        # Third hidden layer
        layers.Dense(64, activation='relu',
                     kernel_regularizer=keras.regularizers.l2(0.001)),
        layers.BatchNormalization(),
        layers.Dropout(0.2),
        
        # Output layer
        layers.Dense(num_classes, activation='softmax')
    ])
    
    return model

# Model configuration
INPUT_DIM = 50  # Total features
NUM_CLASSES = 15  # Number of diseases

model = build_dnn_model(INPUT_DIM, NUM_CLASSES)

# Compile model
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.001),
    loss=keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
    metrics=['accuracy', 
             keras.metrics.TopKCategoricalAccuracy(k=3, name='top_3_accuracy'),
             keras.metrics.Precision(name='precision'),
             keras.metrics.Recall(name='recall')]
)

model.summary()
```

#### Why This Architecture?
- **256-128-64 neurons**: Captures complex patterns without overfitting
- **ReLU activation**: Prevents vanishing gradients
- **Batch Normalization**: Stabilizes training
- **Dropout (0.3, 0.3, 0.2)**: Prevents overfitting
- **L2 Regularization**: Reduces model complexity
- **Label Smoothing**: Improves generalization

### 3.3 Model 2: Random Forest (Secondary)

```python
from sklearn.ensemble import RandomForestClassifier

def build_random_forest(n_estimators=200, max_depth=20):
    """Build Random Forest classifier"""
    
    rf_model = RandomForestClassifier(
        n_estimators=n_estimators,
        max_depth=max_depth,
        min_samples_split=5,
        min_samples_leaf=2,
        max_features='sqrt',
        bootstrap=True,
        oob_score=True,
        random_state=42,
        n_jobs=-1,
        class_weight='balanced'
    )
    
    return rf_model

# Train Random Forest
rf_model = build_random_forest()
rf_model.fit(X_train, y_train)

# Feature importance
feature_importance = rf_model.feature_importances_
```

#### Why Random Forest?
- **Robust to outliers**: Handles noisy medical data
- **Feature importance**: Identifies key symptoms
- **No feature scaling needed**: Works with raw features
- **Ensemble of trees**: Reduces variance

### 3.4 Model 3: Gradient Boosting (Tertiary)

```python
from xgboost import XGBClassifier

def build_xgboost(n_estimators=200, learning_rate=0.05):
    """Build XGBoost classifier"""
    
    xgb_model = XGBClassifier(
        n_estimators=n_estimators,
        learning_rate=learning_rate,
        max_depth=10,
        min_child_weight=3,
        gamma=0.1,
        subsample=0.8,
        colsample_bytree=0.8,
        objective='multi:softprob',
        num_class=NUM_CLASSES,
        random_state=42,
        n_jobs=-1,
        eval_metric='mlogloss'
    )
    
    return xgb_model

# Train XGBoost
xgb_model = build_xgboost()
xgb_model.fit(X_train, y_train,
              eval_set=[(X_val, y_val)],
              early_stopping_rounds=20,
              verbose=False)
```

#### Why XGBoost?
- **Excellent for tabular data**: Medical data is tabular
- **Handles missing values**: Built-in missing value handling
- **Fast training**: Efficient gradient boosting
- **Regularization**: Prevents overfitting

### 3.5 Ensemble Strategy

```python
def ensemble_predict(X, dnn_model, rf_model, xgb_model, weights=[0.5, 0.3, 0.2]):
    """Combine predictions from multiple models"""
    
    # Get predictions from each model
    dnn_pred = dnn_model.predict(X)
    rf_pred = rf_model.predict_proba(X)
    xgb_pred = xgb_model.predict_proba(X)
    
    # Weighted average
    ensemble_pred = (weights[0] * dnn_pred + 
                     weights[1] * rf_pred + 
                     weights[2] * xgb_pred)
    
    # Get top 3 predictions
    top_3_indices = np.argsort(ensemble_pred, axis=1)[:, -3:][:, ::-1]
    top_3_probs = np.sort(ensemble_pred, axis=1)[:, -3:][:, ::-1]
    
    return top_3_indices, top_3_probs

def optimize_ensemble_weights(X_val, y_val, dnn_model, rf_model, xgb_model):
    """Find optimal ensemble weights using validation set"""
    from scipy.optimize import minimize
    
    def objective(weights):
        pred_indices, _ = ensemble_predict(X_val, dnn_model, rf_model, 
                                           xgb_model, weights)
        accuracy = np.mean(pred_indices[:, 0] == y_val)
        return -accuracy  # Minimize negative accuracy
    
    # Constraint: weights sum to 1
    constraints = {'type': 'eq', 'fun': lambda w: np.sum(w) - 1}
    bounds = [(0, 1), (0, 1), (0, 1)]
    
    result = minimize(objective, [0.5, 0.3, 0.2], 
                      method='SLSQP', bounds=bounds, constraints=constraints)
    
    return result.x
```

---

## 4. Training Strategy

### 4.1 Training Configuration

```python
# Hyperparameters
BATCH_SIZE = 32
EPOCHS = 100
LEARNING_RATE = 0.001
PATIENCE = 15  # Early stopping patience

# Callbacks
callbacks = [
    # Early stopping
    keras.callbacks.EarlyStopping(
        monitor='val_loss',
        patience=PATIENCE,
        restore_best_weights=True,
        verbose=1
    ),
    
    # Learning rate reduction
    keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=5,
        min_lr=1e-7,
        verbose=1
    ),
    
    # Model checkpoint
    keras.callbacks.ModelCheckpoint(
        'best_model.h5',
        monitor='val_accuracy',
        save_best_only=True,
        verbose=1
    ),
    
    # TensorBoard logging
    keras.callbacks.TensorBoard(
        log_dir='./logs',
        histogram_freq=1
    ),
    
    # CSV logger
    keras.callbacks.CSVLogger('training_log.csv')
]
```

### 4.2 Training Process

#### Step 1: Baseline Model
```python
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

# Train simple baseline
baseline_model = LogisticRegression(max_iter=1000, random_state=42)
baseline_model.fit(X_train, y_train)

# Evaluate baseline
baseline_pred = baseline_model.predict(X_test)
baseline_accuracy = accuracy_score(y_test, baseline_pred)
print(f"Baseline Accuracy: {baseline_accuracy:.4f}")

# Target: Beat baseline by at least 15%
```

#### Step 2: Deep Learning Model Training
```python
# Convert labels to categorical
from tensorflow.keras.utils import to_categorical

y_train_cat = to_categorical(y_train, num_classes=NUM_CLASSE
er, 'label_encoder.pkl')

# Save model
model.save('disease_diagnosis_model.h5')

# Save training config
training_config = {
    'batch_size': BATCH_SIZE,
    'epochs': EPOCHS,
    'learning_rate': LEARNING_RATE,
    'input_dim': INPUT_DIM,
    'num_classes': NUM_CLASSES,
    'best_val_accuracy': max(history.history['val_accuracy']),
    'best_epoch': np.argmax(history.history['val_accuracy']) + 1
}

import json
with open('training_config.json', 'w') as f:
    json.dump(training_config, f, indent=4)
```

---

    history = model.fit(
        X_train, y_train,
        epochs=100,
        callbacks=[lr_finder],
        verbose=0
    )
    
    # Plot learning rate vs loss
    lrs = 1e-7 * (10 ** (np.arange(100) / 20))
    plt.plot(lrs, history.history['loss'])
    plt.xscale('log')
    plt.xlabel('Learning Rate')
    plt.ylabel('Loss')
    plt.title('Learning Rate Finder')
    plt.show()

# 3. Save training artifacts
import joblib

# Save scalers and encoders
joblib.dump(scaler, 'scaler.pkl')
joblib.dump(label_encodc:.4f}")
        print("Suggestions:")
        print("- Increase dropout rate")
        print("- Add more regularization")
        print("- Collect more training data")
        print("- Reduce model complexity")
    else:
        print("✅ Model is not overfitting")

check_overfitting(history)

# 2. Learning rate finder
def find_optimal_lr(model, X_train, y_train):
    """Find optimal learning rate"""
    lr_finder = keras.callbacks.LearningRateScheduler(
        lambda epoch: 1e-7 * 10**(epoch / 20)
    )
    t("Best parameters:", random_search.best_params_)
print("Best score:", random_search.best_score_)
```

### 4.3 Training Best Practices

```python
# 1. Monitor overfitting
def check_overfitting(history):
    """Check if model is overfitting"""
    train_acc = history.history['accuracy'][-1]
    val_acc = history.history['val_accuracy'][-1]
    
    if train_acc - val_acc > 0.1:
        print("⚠️ Warning: Model is overfitting!")
        print(f"Train Accuracy: {train_acc:.4f}")
        print(f"Val Accuracy: {val_ac
# Hyperparameter search space
param_dist = {
    'learning_rate': [0.0001, 0.001, 0.01],
    'dropout_rate': [0.2, 0.3, 0.4],
    'neurons': [64, 128, 256],
    'batch_size': [16, 32, 64],
    'epochs': [50, 100]
}

# Random search
model_wrapper = KerasClassifier(
    model=create_model,
    verbose=0
)

random_search = RandomizedSearchCV(
    estimator=model_wrapper,
    param_distributions=param_dist,
    n_iter=20,
    cv=3,
    random_state=42,
    n_jobs=-1
)

random_search.fit(X_train, y_train)

prinnse(neurons * 2, activation='relu'),
        layers.Dropout(dropout_rate),
        layers.Dense(neurons, activation='relu'),
        layers.Dropout(dropout_rate),
        layers.Dense(neurons // 2, activation='relu'),
        layers.Dropout(dropout_rate / 2),
        layers.Dense(NUM_CLASSES, activation='softmax')
    ])
    
    model.compile(
        optimizer=keras.optimizers.Adam(learning_rate=learning_rate),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    return model
(cv_scores):.4f} (+/- {np.std(cv_scores):.4f})")
    return cv_scores

# Perform cross-validation
cv_scores = cross_validate_model(X, y, n_splits=5)
```

#### Step 4: Hyperparameter Tuning
```python
from sklearn.model_selection import RandomizedSearchCV
from scikeras.wrappers import KerasClassifier

def create_model(learning_rate=0.001, dropout_rate=0.3, neurons=128):
    """Create model with tunable hyperparameters"""
    model = keras.Sequential([
        layers.Input(shape=(INPUT_DIM,)),
        layers.De    X_train_cv, y_train_cv,
            batch_size=BATCH_SIZE,
            epochs=50,
            validation_data=(X_val_cv, y_val_cv),
            callbacks=[keras.callbacks.EarlyStopping(patience=10)],
            verbose=0
        )
        
        # Evaluate
        val_pred = np.argmax(model_cv.predict(X_val_cv), axis=1)
        accuracy = accuracy_score(y_val_cv, val_pred)
        cv_scores.append(accuracy)
        print(f"Fold {fold + 1} Accuracy: {accuracy:.4f}")
    
    print(f"\nMean CV Accuracy: {np.meanumerate(skf.split(X, y)):
        print(f"\nFold {fold + 1}/{n_splits}")
        
        X_train_cv, X_val_cv = X[train_idx], X[val_idx]
        y_train_cv, y_val_cv = y[train_idx], y[val_idx]
        
        # Build and train model
        model_cv = build_dnn_model(INPUT_DIM, NUM_CLASSES)
        model_cv.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        model_cv.fit(
        all')
    axes[1, 1].legend()
    
    plt.tight_layout()
    plt.savefig('training_history.png')
    plt.show()

plot_training_history(history)
```

#### Step 3: Cross-Validation
```python
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import accuracy_score

def cross_validate_model(X, y, n_splits=5):
    """Perform k-fold cross-validation"""
    
    skf = StratifiedKFold(n_splits=n_splits, shuffle=True, random_state=42)
    cv_scores = []
    
    for fold, (train_idx, val_idx) in en0].plot(history.history['precision'], label='Train')
    axes[1, 0].plot(history.history['val_precision'], label='Val')
    axes[1, 0].set_title('Model Precision')
    axes[1, 0].set_xlabel('Epoch')
    axes[1, 0].set_ylabel('Precision')
    axes[1, 0].legend()
    
    # Recall
    axes[1, 1].plot(history.history['recall'], label='Train')
    axes[1, 1].plot(history.history['val_recall'], label='Val')
    axes[1, 1].set_title('Model Recall')
    axes[1, 1].set_xlabel('Epoch')
    axes[1, 1].set_ylabel('Recain')
    axes[0, 0].plot(history.history['val_accuracy'], label='Val')
    axes[0, 0].set_title('Model Accuracy')
    axes[0, 0].set_xlabel('Epoch')
    axes[0, 0].set_ylabel('Accuracy')
    axes[0, 0].legend()
    
    # Loss
    axes[0, 1].plot(history.history['loss'], label='Train')
    axes[0, 1].plot(history.history['val_loss'], label='Val')
    axes[0, 1].set_title('Model Loss')
    axes[0, 1].set_xlabel('Epoch')
    axes[0, 1].set_ylabel('Loss')
    axes[0, 1].legend()
    
    # Precision
    axes[1, S)
y_val_cat = to_categorical(y_val, num_classes=NUM_CLASSES)

# Train model
history = model.fit(
    X_train, y_train_cat,
    batch_size=BATCH_SIZE,
    epochs=EPOCHS,
    validation_data=(X_val, y_val_cat),
    callbacks=callbacks,
    class_weight=class_weight_dict,
    verbose=1
)

# Plot training history
import matplotlib.pyplot as plt

def plot_training_history(history):
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    
    # Accuracy
    axes[0, 0].plot(history.history['accuracy'], label='Tr