"""
Main Training Script

Executes the complete ML training pipeline:
1. Load and preprocess data
2. Engineer features
3. Train model
4. Evaluate performance
5. Convert to TensorFlow.js
6. Generate metadata and reports
"""

import json
import os
import sys
import logging
import numpy as np

# Add scripts directory to path
sys.path.append(os.path.dirname(__file__))

from data_preprocessor import DataPreprocessor
from feature_engineer import FeatureEngineer
from model_trainer import ModelTrainer
from model_evaluator import ModelEvaluator
from model_converter import ModelConverter

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def load_config(config_path: str = 'config/training_config.json') -> dict:
    """Load training configuration."""
    logger.info(f"Loading configuration from {config_path}")
    with open(config_path, 'r') as f:
        config = json.load(f)
    return config


def create_sample_dataset(num_samples: int = 1000) -> None:
    """Create a sample dataset for testing (when real datasets are not available)."""
    import pandas as pd
    
    logger.info(f"Creating sample dataset with {num_samples} records")
    
    diseases = [
        'Common Cold', 'Influenza', 'Malaria', 'Typhoid Fever', 'Pneumonia',
        'Tuberculosis', 'Dengue Fever', 'Hypertension', 'Diabetes', 'Gastroenteritis',
        'Urinary Tract Infection', 'Skin Infection', 'Respiratory Infection', 'Anemia', 'Dehydration'
    ]
    
    data = {
        'age': np.random.randint(1, 100, num_samples),
        'gender': np.random.choice(['male', 'female'], num_samples),
        'temperature': np.random.uniform(36.0, 40.0, num_samples),
        'bloodPressureSystolic': np.random.randint(90, 180, num_samples),
        'bloodPressureDiastolic': np.random.randint(60, 110, num_samples),
        'heartRate': np.random.randint(50, 150, num_samples),
        'respiratoryRate': np.random.randint(12, 30, num_samples),
        'oxygenSaturation': np.random.uniform(90, 100, num_samples),
        'diagnosis': np.random.choice(diseases, num_samples)
    }
    
    df = pd.DataFrame(data)
    
    # Save to data directory
    os.makedirs('data', exist_ok=True)
    df.to_csv('data/ddxplus.csv', index=False)
    logger.info("Sample dataset created: data/ddxplus.csv")


def main():
    """Main training pipeline."""
    logger.info("=" * 80)
    logger.info("Starting ML Training Pipeline")
    logger.info("=" * 80)
    
    # Load configuration
    config = load_config()
    
    # Check if datasets exist, create sample if not
    if not os.path.exists(config['data']['ddxplus_path']):
        logger.warning("DDXPlus dataset not found, creating sample dataset")
        create_sample_dataset(num_samples=1000)
    
    # Step 1: Data Preprocessing
    logger.info("\n" + "=" * 80)
    logger.info("Step 1: Data Preprocessing")
    logger.info("=" * 80)
    
    preprocessor = DataPreprocessor(config)
    
    # Load datasets
    ddxplus_df = preprocessor.load_ddxplus(config['data']['ddxplus_path'])
    afrimedqa_df = preprocessor.load_afrimedqa(config['data']['afrimedqa_path'])
    
    # Merge datasets
    merged_df = preprocessor.merge_datasets(ddxplus_df, afrimedqa_df)
    
    # Handle missing values
    clean_df = preprocessor.handle_missing_values(merged_df)
    
    # Validate data
    if not preprocessor.validate_data(clean_df):
        logger.error("Data validation failed. Exiting.")
        sys.exit(1)
    
    # Split data
    train_df, val_df, test_df = preprocessor.split_data(
        clean_df,
        train_ratio=config['data']['train_ratio'],
        val_ratio=config['data']['val_ratio']
    )
    
    # Step 2: Feature Engineering
    logger.info("\n" + "=" * 80)
    logger.info("Step 2: Feature Engineering")
    logger.info("=" * 80)
    
    feature_engineer = FeatureEngineer(config)
    
    # Process dataframes into feature matrices
    X_train, y_train, disease_labels = feature_engineer.process_dataframe(train_df)
    X_val, y_val, _ = feature_engineer.process_dataframe(val_df)
    X_test, y_test, _ = feature_engineer.process_dataframe(test_df)
    
    logger.info(f"Number of diseases: {len(disease_labels)}")
    logger.info(f"Disease labels: {disease_labels}")
    
    # Step 3: Model Training
    logger.info("\n" + "=" * 80)
    logger.info("Step 3: Model Training")
    logger.info("=" * 80)
    
    trainer = ModelTrainer(
        input_dim=feature_engineer.input_dim,
        num_classes=len(disease_labels),
        config=config
    )
    
    # Build and train model
    model = trainer.build_model()
    history = trainer.train(X_train, y_train, X_val, y_val)
    
    # Save model
    os.makedirs(config['output']['tensorflow_model_path'], exist_ok=True)
    trainer.save_model(config['output']['tensorflow_model_path'])
    trainer.save_training_history(config['output']['training_history_path'])
    
    # Step 4: Model Evaluation
    logger.info("\n" + "=" * 80)
    logger.info("Step 4: Model Evaluation")
    logger.info("=" * 80)
    
    evaluator = ModelEvaluator(model, config)
    
    # Evaluate on test set
    metrics = evaluator.evaluate(X_test, y_test, disease_labels)
    
    # Generate confusion matrix
    y_pred_probs = model.predict(X_test)
    evaluator.generate_confusion_matrix(
        y_test, y_pred_probs, disease_labels,
        save_path='models/confusion_matrix.png'
    )
    
    # Measure inference time
    inference_time = evaluator.measure_inference_time(X_test[:10])
    
    # Check model size
    model_size = evaluator.check_model_size(config['output']['tensorflow_model_path'])
    
    # Generate evaluation report
    evaluator.generate_report(
        metrics, inference_time, model_size,
        config['output']['evaluation_report_path']
    )
    
    # Step 5: Model Conversion
    logger.info("\n" + "=" * 80)
    logger.info("Step 5: Model Conversion to TensorFlow.js")
    logger.info("=" * 80)
    
    converter = ModelConverter(config)
    
    # Convert to TFJS
    converter.convert_to_tfjs(
        config['output']['tensorflow_model_path'],
        config['output']['tfjs_model_path']
    )
    
    # Validate conversion
    converter.validate_conversion(
        model,
        config['output']['tfjs_model_path'],
        X_test[:10]
    )
    
    # Generate ICD-10 mapping
    icd10_codes = converter.generate_icd10_mapping(disease_labels)
    
    # Generate metadata
    converter.generate_metadata(
        disease_labels=disease_labels,
        icd10_codes=icd10_codes,
        feature_specs=feature_engineer.get_feature_specs(),
        normalization_params={
            'vitalRanges': config['features']['vital_ranges'],
            'ageRange': config['features']['age_range']
        },
        model_version='1.0.0',
        accuracy=metrics['overall']['accuracy'],
        output_path=config['output']['metadata_path']
    )
    
    # Final Summary
    logger.info("\n" + "=" * 80)
    logger.info("Training Pipeline Completed Successfully!")
    logger.info("=" * 80)
    logger.info(f"Model Accuracy: {metrics['overall']['accuracy']:.4f}")
    logger.info(f"Model Size: {model_size:.2f} MB")
    logger.info(f"Inference Time: {inference_time*1000:.2f} ms")
    logger.info(f"Number of Diseases: {len(disease_labels)}")
    logger.info(f"\nOutput files:")
    logger.info(f"  - TensorFlow Model: {config['output']['tensorflow_model_path']}")
    logger.info(f"  - TFJS Model: {config['output']['tfjs_model_path']}")
    logger.info(f"  - Metadata: {config['output']['metadata_path']}")
    logger.info(f"  - Evaluation Report: {config['output']['evaluation_report_path']}")
    logger.info(f"  - Training History: {config['output']['training_history_path']}")
    logger.info("\nNext steps:")
    logger.info("  1. Review the evaluation report")
    logger.info("  2. Copy TFJS model to backend: cp -r models/tfjs/* ../models/v1.0.0/")
    logger.info("  3. Copy metadata: cp models/metadata.json ../models/v1.0.0/")
    logger.info("=" * 80)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        logger.error(f"Training pipeline failed: {e}", exc_info=True)
        sys.exit(1)
