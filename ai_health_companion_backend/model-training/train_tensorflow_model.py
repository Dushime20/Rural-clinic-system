"""
TensorFlow Model Training Script
Trains a neural network model with vital signs and demographics support
Converts to TensorFlow Lite for mobile deployment
"""

import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
import json
import os
from datetime import datetime

print("TensorFlow version:", tf.__version__)

# Configuration
CONFIG = {
    'model_name': 'disease_classifier_v1',
    'epochs': 50,
    'batch_size': 32,
    'learning_rate': 0.001,
    'validation_split': 0.15,
    'test_split': 0.15,
    'random_state': 42
}

# Disease to ICD-10 mapping
DISEASE_ICD10_MAP = {
    'Fungal infection': 'B35.9',
    'Allergy': 'T78.40',
    'GERD': 'K21.9',
    'Chronic cholestasis': 'K83.1',
    'Drug Reaction': 'T88.7',
    'Peptic ulcer diseae': 'K27.9',
    'AIDS': 'B24',
    'Diabetes': 'E11.9',
    'Gastroenteritis': 'K52.9',
    'Bronchial Asthma': 'J45.909',
    'Hypertension': 'I10',
    'Migraine': 'G43.909',
    'Cervical spondylosis': 'M47.812',
    'Paralysis (brain hemorrhage)': 'I61.9',
    'Jaundice': 'R17',
    'Malaria': 'B54',
    'Chicken pox': 'B01.9',
    'Dengue': 'A97.9',
    'Typhoid': 'A01.00',
    'hepatitis A': 'B15.9',
    'Hepatitis B': 'B16.9',
    'Hepatitis C': 'B17.10',
    'Hepatitis D': 'B17.0',
    'Hepatitis E': 'B17.2',
    'Alcoholic hepatitis': 'K70.10',
    'Tuberculosis': 'A15.9',
    'Common Cold': 'J00',
    'Pneumonia': 'J18.9',
    'Dimorphic hemmorhoids(piles)': 'K64.9',
    'Heart attack': 'I21.9',
    'Varicose veins': 'I83.90',
    'Hypothyroidism': 'E03.9',
    'Hyperthyroidism': 'E05.90',
    'Hypoglycemia': 'E16.2',
    'Osteoarthristis': 'M19.90',
    'Arthritis': 'M13.9',
    '(vertigo) Paroymsal  Positional Vertigo': 'H81.10',
    'Acne': 'L70.0',
    'Urinary tract infection': 'N39.0',
    'Psoriasis': 'L40.9',
    'Impetigo': 'L01.00'
}

def load_and_prepare_data():
    """Load training data and prepare features"""
    print("\n" + "="*60)
    print("STEP 1: Loading and Preparing Data")
    print("="*60)
    
    # Load training data
    training_file = 'dataset/Training.csv'
    
    if not os.path.exists(training_file):
        print(f"❌ Error: {training_file} not found!")
        print("Creating synthetic dataset for demonstration...")
        return create_synthetic_dataset()
    
    df = pd.read_csv(training_file)
    print(f"✅ Loaded {len(df)} training samples")
    print(f"✅ Columns: {df.columns.tolist()[:10]}... (showing first 10)")
    
    # Get symptom columns (all except 'prognosis')
    symptom_columns = [col for col in df.columns if col != 'prognosis']
    print(f"✅ Found {len(symptom_columns)} symptom features")
    
    # Prepare features and labels
    X_symptoms = df[symptom_columns].values
    y = df['prognosis'].values
    
    print(f"✅ Feature shape: {X_symptoms.shape}")
    print(f"✅ Unique diseases: {len(np.unique(y))}")
    
    return X_symptoms, y, symptom_columns

def create_synthetic_dataset():
    """Create synthetic dataset if real data not available"""
    print("Creating synthetic dataset with 1000 samples...")
    
    # 132 symptoms (binary)
    n_samples = 1000
    n_symptoms = 132
    
    X_symptoms = np.random.randint(0, 2, size=(n_samples, n_symptoms))
    
    # 41 diseases
    diseases = list(DISEASE_ICD10_MAP.keys())
    y = np.random.choice(diseases, size=n_samples)
    
    symptom_columns = [f'symptom_{i}' for i in range(n_symptoms)]
    
    print(f"✅ Created {n_samples} synthetic samples")
    print(f"✅ {n_symptoms} symptoms, {len(diseases)} diseases")
    
    return X_symptoms, y, symptom_columns

def add_vital_signs_features(X_symptoms, n_samples):
    """Add synthetic vital signs for training"""
    print("\n" + "="*60)
    print("STEP 2: Adding Vital Signs Features")
    print("="*60)
    
    # Generate realistic vital signs
    # Temperature: 36.0-40.0°C (normal: 36.5-37.5)
    temperature = np.random.normal(37.0, 1.0, n_samples)
    temperature = np.clip(temperature, 35.0, 41.0)
    
    # Blood Pressure Systolic: 90-180 mmHg (normal: 120)
    bp_systolic = np.random.normal(120, 15, n_samples)
    bp_systolic = np.clip(bp_systolic, 80, 200)
    
    # Blood Pressure Diastolic: 60-120 mmHg (normal: 80)
    bp_diastolic = np.random.normal(80, 10, n_samples)
    bp_diastolic = np.clip(bp_diastolic, 50, 130)
    
    # Heart Rate: 50-150 bpm (normal: 60-100)
    heart_rate = np.random.normal(75, 15, n_samples)
    heart_rate = np.clip(heart_rate, 40, 180)
    
    # Respiratory Rate: 10-30 breaths/min (normal: 12-20)
    respiratory_rate = np.random.normal(16, 4, n_samples)
    respiratory_rate = np.clip(respiratory_rate, 8, 40)
    
    # Oxygen Saturation: 85-100% (normal: >95%)
    oxygen_saturation = np.random.normal(97, 3, n_samples)
    oxygen_saturation = np.clip(oxygen_saturation, 80, 100)
    
    # Age: 1-100 years
    age = np.random.randint(1, 100, n_samples)
    
    # Gender: 0=female, 1=male
    gender = np.random.randint(0, 2, n_samples)
    
    # Combine all features
    vital_signs = np.column_stack([
        temperature,
        bp_systolic,
        bp_diastolic,
        heart_rate,
        respiratory_rate,
        oxygen_saturation,
        age,
        gender
    ])
    
    # Normalize vital signs
    scaler = StandardScaler()
    vital_signs_normalized = scaler.fit_transform(vital_signs)
    
    # Combine symptoms + vital signs
    X_combined = np.concatenate([X_symptoms, vital_signs_normalized], axis=1)
    
    print(f"✅ Added 8 vital sign features")
    print(f"✅ Temperature: {temperature.min():.1f}-{temperature.max():.1f}°C")
    print(f"✅ BP: {bp_systolic.min():.0f}/{bp_diastolic.min():.0f} - {bp_systolic.max():.0f}/{bp_diastolic.max():.0f} mmHg")
    print(f"✅ Heart Rate: {heart_rate.min():.0f}-{heart_rate.max():.0f} bpm")
    print(f"✅ Combined feature shape: {X_combined.shape}")
    
    # Save scaler for later use
    scaler_params = {
        'mean': scaler.mean_.tolist(),
        'scale': scaler.scale_.tolist(),
        'feature_names': [
            'temperature', 'bp_systolic', 'bp_diastolic',
            'heart_rate', 'respiratory_rate', 'oxygen_saturation',
            'age', 'gender'
        ]
    }
    
    return X_combined, scaler_params

def encode_labels(y):
    """Encode disease labels"""
    print("\n" + "="*60)
    print("STEP 3: Encoding Labels")
    print("="*60)
    
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(y)
    
    n_classes = len(label_encoder.classes_)
    print(f"✅ Encoded {n_classes} disease classes")
    print(f"✅ Sample diseases: {label_encoder.classes_[:5].tolist()}")
    
    # One-hot encode for neural network
    y_onehot = tf.keras.utils.to_categorical(y_encoded, num_classes=n_classes)
    
    return y_onehot, label_encoder

def build_model(input_dim, n_classes):
    """Build TensorFlow neural network model"""
    print("\n" + "="*60)
    print("STEP 4: Building Neural Network Model")
    print("="*60)
    
    model = tf.keras.Sequential([
        # Input layer
        tf.keras.layers.Input(shape=(input_dim,)),
        
        # Hidden layers
        tf.keras.layers.Dense(256, activation='relu', name='dense_1'),
        tf.keras.layers.Dropout(0.3, name='dropout_1'),
        
        tf.keras.layers.Dense(128, activation='relu', name='dense_2'),
        tf.keras.layers.Dropout(0.2, name='dropout_2'),
        
        tf.keras.layers.Dense(64, activation='relu', name='dense_3'),
        tf.keras.layers.Dropout(0.2, name='dropout_3'),
        
        # Output layer
        tf.keras.layers.Dense(n_classes, activation='softmax', name='output')
    ])
    
    # Compile model
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=CONFIG['learning_rate']),
        loss='categorical_crossentropy',
        metrics=['accuracy', 'top_k_categorical_accuracy']
    )
    
    print("✅ Model architecture:")
    model.summary()
    
    return model

def train_model(model, X_train, y_train, X_val, y_val):
    """Train the model"""
    print("\n" + "="*60)
    print("STEP 5: Training Model")
    print("="*60)
    
    # Callbacks
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True,
            verbose=1
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-6,
            verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint(
            'model/tensorflow/best_model.h5',
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        )
    ]
    
    # Create model directory
    os.makedirs('model/tensorflow', exist_ok=True)
    
    # Train
    print(f"Training for {CONFIG['epochs']} epochs...")
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=CONFIG['epochs'],
        batch_size=CONFIG['batch_size'],
        callbacks=callbacks,
        verbose=1
    )
    
    print("\n✅ Training completed!")
    print(f"✅ Final training accuracy: {history.history['accuracy'][-1]:.4f}")
    print(f"✅ Final validation accuracy: {history.history['val_accuracy'][-1]:.4f}")
    
    return history

def evaluate_model(model, X_test, y_test, label_encoder):
    """Evaluate model performance"""
    print("\n" + "="*60)
    print("STEP 6: Evaluating Model")
    print("="*60)
    
    # Evaluate
    test_loss, test_accuracy, test_top5 = model.evaluate(X_test, y_test, verbose=0)
    
    print(f"✅ Test Loss: {test_loss:.4f}")
    print(f"✅ Test Accuracy: {test_accuracy:.4f} ({test_accuracy*100:.2f}%)")
    print(f"✅ Top-5 Accuracy: {test_top5:.4f} ({test_top5*100:.2f}%)")
    
    # Sample predictions
    sample_predictions = model.predict(X_test[:5], verbose=0)
    print("\n✅ Sample predictions:")
    for i, pred in enumerate(sample_predictions):
        top_3_idx = np.argsort(pred)[-3:][::-1]
        print(f"\nSample {i+1}:")
        for idx in top_3_idx:
            disease = label_encoder.classes_[idx]
            confidence = pred[idx]
            print(f"  - {disease}: {confidence:.4f} ({confidence*100:.2f}%)")
    
    return {
        'test_loss': float(test_loss),
        'test_accuracy': float(test_accuracy),
        'test_top5_accuracy': float(test_top5)
    }

def convert_to_tflite(model, model_name='disease_classifier'):
    """Convert TensorFlow model to TensorFlow Lite"""
    print("\n" + "="*60)
    print("STEP 7: Converting to TensorFlow Lite")
    print("="*60)
    
    # Create output directory
    os.makedirs('model/tflite', exist_ok=True)
    
    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Optimization
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save
    tflite_path = f'model/tflite/{model_name}.tflite'
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    model_size_mb = len(tflite_model) / (1024 * 1024)
    print(f"✅ TFLite model saved: {tflite_path}")
    print(f"✅ Model size: {model_size_mb:.2f} MB")
    
    # Test TFLite model
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"✅ Input shape: {input_details[0]['shape']}")
    print(f"✅ Output shape: {output_details[0]['shape']}")
    print("✅ TFLite model is ready for mobile deployment!")
    
    return tflite_path, model_size_mb

def save_metadata(label_encoder, scaler_params, symptom_columns, metrics, model_size_mb):
    """Save model metadata"""
    print("\n" + "="*60)
    print("STEP 8: Saving Metadata")
    print("="*60)
    
    metadata = {
        'model_info': {
            'name': CONFIG['model_name'],
            'version': '1.0.0',
            'created_at': datetime.now().isoformat(),
            'framework': 'TensorFlow',
            'model_size_mb': model_size_mb
        },
        'diseases': {
            'count': len(label_encoder.classes_),
            'labels': label_encoder.classes_.tolist(),
            'icd10_codes': {disease: DISEASE_ICD10_MAP.get(disease, 'Unknown') 
                           for disease in label_encoder.classes_}
        },
        'features': {
            'symptoms': {
                'count': len(symptom_columns),
                'names': symptom_columns
            },
            'vital_signs': scaler_params['feature_names'],
            'total_features': len(symptom_columns) + len(scaler_params['feature_names'])
        },
        'scaler': scaler_params,
        'performance': metrics,
        'config': CONFIG
    }
    
    # Save metadata
    metadata_path = 'model/metadata.json'
    with open(metadata_path, 'w') as f:
        json.dump(metadata, f, indent=2)
    
    print(f"✅ Metadata saved: {metadata_path}")
    print(f"✅ Diseases: {metadata['diseases']['count']}")
    print(f"✅ Features: {metadata['features']['total_features']}")
    print(f"✅ Accuracy: {metrics['test_accuracy']:.4f}")
    
    return metadata

def main():
    """Main training pipeline"""
    print("\n" + "="*60)
    print("TENSORFLOW MODEL TRAINING PIPELINE")
    print("Disease Prediction with Vital Signs Support")
    print("="*60)
    
    # Set random seeds
    np.random.seed(CONFIG['random_state'])
    tf.random.set_seed(CONFIG['random_state'])
    
    # Step 1: Load data
    X_symptoms, y, symptom_columns = load_and_prepare_data()
    n_samples = len(y)
    
    # Step 2: Add vital signs
    X_combined, scaler_params = add_vital_signs_features(X_symptoms, n_samples)
    
    # Step 3: Encode labels
    y_onehot, label_encoder = encode_labels(y)
    
    # Step 4: Split data
    print("\n" + "="*60)
    print("Splitting Data")
    print("="*60)
    
    # First split: train+val vs test
    X_temp, X_test, y_temp, y_test = train_test_split(
        X_combined, y_onehot,
        test_size=CONFIG['test_split'],
        random_state=CONFIG['random_state'],
        stratify=np.argmax(y_onehot, axis=1)
    )
    
    # Second split: train vs val
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp,
        test_size=CONFIG['validation_split'] / (1 - CONFIG['test_split']),
        random_state=CONFIG['random_state'],
        stratify=np.argmax(y_temp, axis=1)
    )
    
    print(f"✅ Training set: {len(X_train)} samples")
    print(f"✅ Validation set: {len(X_val)} samples")
    print(f"✅ Test set: {len(X_test)} samples")
    
    # Step 5: Build model
    input_dim = X_combined.shape[1]
    n_classes = y_onehot.shape[1]
    model = build_model(input_dim, n_classes)
    
    # Step 6: Train model
    history = train_model(model, X_train, y_train, X_val, y_val)
    
    # Step 7: Evaluate model
    metrics = evaluate_model(model, X_test, y_test, label_encoder)
    
    # Step 8: Save TensorFlow model
    print("\n" + "="*60)
    print("Saving TensorFlow Model")
    print("="*60)
    model.save('model/tensorflow/disease_classifier.h5')
    print("✅ TensorFlow model saved: model/tensorflow/disease_classifier.h5")
    
    # Step 9: Convert to TFLite
    tflite_path, model_size_mb = convert_to_tflite(model, CONFIG['model_name'])
    
    # Step 10: Save metadata
    metadata = save_metadata(label_encoder, scaler_params, symptom_columns, metrics, model_size_mb)
    
    # Final summary
    print("\n" + "="*60)
    print("TRAINING COMPLETE! 🎉")
    print("="*60)
    print(f"✅ TensorFlow Model: model/tensorflow/disease_classifier.h5")
    print(f"✅ TFLite Model: {tflite_path}")
    print(f"✅ Metadata: model/metadata.json")
    print(f"✅ Model Size: {model_size_mb:.2f} MB")
    print(f"✅ Test Accuracy: {metrics['test_accuracy']:.4f} ({metrics['test_accuracy']*100:.2f}%)")
    print(f"✅ Top-5 Accuracy: {metrics['test_top5_accuracy']:.4f} ({metrics['test_top5_accuracy']*100:.2f}%)")
    print("\n📱 Next Steps:")
    print("1. Copy model/tflite/*.tflite to your Flutter app")
    print("2. Copy model/metadata.json to your Flutter app")
    print("3. Use TFLite interpreter in Flutter for offline predictions")
    print("4. Update Flask API to use TensorFlow model (optional)")
    print("="*60)

if __name__ == '__main__':
    main()
